// lib/services/notification_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'user_data_service.dart';
import '../screens/features/notifikasi_screen.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Timer? _pollingTimer;
  static int _lastHistoryCount = 0;
  static String? _lastResultId;
  static bool _isInitialized = false;
  static String? _lastFirstExamId; // Track firstExam changes
  static bool _lastFirstExamAvailable = false; // Track availability state
  static int _missingFirstExamPolls = 0; // Consecutive polls without firstExam

  // Initialize notification service
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ NotificationService already initialized');
      return;
    }

    print('🔔 Initializing NotificationService...');

    // Android settings
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Request permissions untuk Android 13+
      await _requestPermissions();

      _isInitialized = true;
      print('✅ NotificationService initialized');

      // Load last known state
      await _loadLastState();
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    try {
      // Android 13+ requires runtime permission
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // Create notification channel for analysis results with MAX importance
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'analysis_results',
          'Hasil Analisis',
          description: 'Notifikasi untuk hasil analisis TBC',
          importance: Importance.max, // MAX untuk memastikan muncul
          playSound: true,
          enableVibration: true,
          showBadge: true,
          enableLights: true,
        );

        await androidPlugin.createNotificationChannel(channel);

        final granted = await androidPlugin.requestNotificationsPermission();
        print('✅ Android notification permission: $granted');
        print('✅ Notification channel created with MAX importance');
      }

      // iOS permission
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        print('✅ iOS notification permission requested');
      }
    } catch (e) {
      print('⚠️ Error requesting permissions: $e');
    }
  }

  // Handle notification tap
  static void _onNotificationTap(NotificationResponse response) {
    print('🔔 Notification tapped: ${response.payload}');
    // TODO: Navigate to analysis screen
  }

  // Start polling API setiap 30 detik (foreground + background)
  static void startPolling() {
    if (_pollingTimer?.isActive ?? false) {
      print('⚠️ Polling already active');
      return;
    }

    print('🔄 Starting API polling (every 30 seconds)...');

    // Initial check
    _checkForNewResults();

    // Polling (when app is open or in background)
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkForNewResults();
    });

    print('✅ Polling started (every 30 seconds)');
  }

  // Stop polling
  static void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;

    print('🛑 Polling stopped');
  }

  // Check for new analysis results
  static Future<void> _checkForNewResults() async {
    try {
      // Check if user is logged in
      final isLoggedIn = await ApiService.isLoggedIn();
      if (!isLoggedIn) {
        print('⚠️ User not logged in, skipping poll');
        return;
      }

      print('🔍 Checking for new analysis results...');

      // Test server connection first (quick check)
      final serverReachable = await ApiService.testServerConnection();
      if (!serverReachable) {
        print('⚠️ Server not reachable, skipping this poll cycle');
        return;
      }

      final response = await ApiService.getPatientHistory().timeout(
        const Duration(seconds: 30), // Match API timeout
        onTimeout: () {
          print('⏱️ Notification check timeout');
          return {'success': false, 'message': 'Timeout'};
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // Update user data
        if (data['patient'] != null) {
          UserDataService.syncFromAPI(data['patient']);
        }

        // ===== CEK PERUBAHAN HISTORY (NEW API STRUCTURE) =====
        // Use first history item as "firstExam"
        Map<String, dynamic>? currentFirstExam;
        String? currentFirstExamId;

        if (data['history'] != null &&
            data['history'] is List &&
            (data['history'] as List).isNotEmpty) {
          currentFirstExam =
              (data['history'] as List)[0] as Map<String, dynamic>;
          currentFirstExamId = currentFirstExam['_id']?.toString() ??
              currentFirstExam['id']?.toString();

          // Update history data di UserDataService
          UserDataService.setHistoryData(data['history']);
        }

        final hasCurrentFirstExam = currentFirstExamId != null;

        print('🔍 FirstExam check (from history[0]):');
        print('   Current ID: $currentFirstExamId');
        print('   Last ID: $_lastFirstExamId');
        print('   Last has data: $_lastFirstExamAvailable');

        if (hasCurrentFirstExam) {
          final isNewId = currentFirstExamId != _lastFirstExamId;

          if (!_lastFirstExamAvailable || isNewId) {
            // Ada data baru atau sebelumnya belum ada data
            print('🎯 FirstExam ACTIVE - Mengirim notifikasi hasil analisis');
            await _showNewResultNotification(currentFirstExam!);
          } else {
            print('✔️ FirstExam masih sama, tidak kirim notifikasi');
          }

          // Simpan state terbaru
          _lastFirstExamAvailable = true;
          _lastFirstExamId = currentFirstExamId;
          _missingFirstExamPolls = 0;
          await _saveLastState();
        } else {
          // Tidak ada firstExam saat ini (history kosong)
          _missingFirstExamPolls += 1;

          if (_lastFirstExamAvailable && _missingFirstExamPolls >= 2) {
            // Sebelumnya ada data, sekarang hilang selama beberapa polling -> analisis ulang
            print(
                '🔄 FirstExam REMOVED ($_missingFirstExamPolls polls) - Mengirim notifikasi analisis ulang');
            await _showAnalysisInProgressNotification();
            _lastFirstExamAvailable = false;
            _lastFirstExamId = null;
            _missingFirstExamPolls = 0; // reset setelah kirim notif
            await _saveLastState();
          } else {
            print(
                'ℹ️ FirstExam masih kosong, belum ada data (poll $_missingFirstExamPolls)');
          }
        }

        // Update firstExam di UserDataService (from first history item)
        UserDataService.setFirstExamData(currentFirstExam);
      }
    } catch (e) {
      print('❌ Error checking for new results: $e');
    }
  }

  // Show notification for data being re-analyzed
  static Future<void> _showAnalysisInProgressNotification() async {
    try {
      const String title = 'Data Sedang Dianalisis Ulang';
      const String body =
          'Data analisis Anda sedang diproses ulang oleh tim medis.';
      const String bigText =
          'Data analisis Anda sebelumnya telah dihapus dan sedang dianalisis ulang oleh tim medis. Anda akan menerima notifikasi ketika hasil baru sudah tersedia.';

      const androidDetails = AndroidNotificationDetails(
        'analysis_results',
        'Hasil Analisis',
        channelDescription: 'Notifikasi untuk hasil analisis TBC',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        playSound: true,
        enableVibration: true,
        enableLights: true,
        color: Color(0xFF00A8C5),
        ticker: title,
        autoCancel: true,
        ongoing: false,
        visibility: NotificationVisibility.public,
        channelShowBadge: true,
        styleInformation: BigTextStyleInformation(
          bigText,
          contentTitle: '🔄 $title',
          summaryText: 'TBCare',
          htmlFormatBigText: false,
          htmlFormatContentTitle: false,
        ),
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await _notifications.show(
        1001, // Unique ID untuk re-analysis
        '🔄 $title',
        body,
        notificationDetails,
        payload: 'analysis_in_progress',
      );

      // Tambahkan ke in-app notification list
      await NotifikasiScreen.addNotification(
        title: '🔄 $title',
        message: bigText,
        type: NotificationType.info,
      );

      print('✅ Analysis in progress notification sent');
      print('   Title: $title');
      print('   Body: $body');
    } catch (e) {
      print('❌ Error showing analysis in progress notification: $e');
    }
  }

  // Show notification for new result
  static Future<void> _showNewResultNotification(
      Map<String, dynamic> result) async {
    try {
      final resultType =
          result['result']?.toString().toUpperCase() ?? 'UNKNOWN';

      // Simplified: "Hasil Anda Sudah Keluar"
      const String title = 'Hasil Anda Sudah Keluar';
      String body;
      String bigText;
      Color notifColor;

      if (resultType == 'TB' || resultType == 'DANGER') {
        body =
            'Hasil analisis menunjukkan terdeteksi TBC. Segera konsultasi dokter.';
        bigText =
            'Hasil analisis Anda telah selesai dan menunjukkan adanya indikasi Tuberkulosis (TBC). '
            'Segera konsultasikan dengan dokter untuk tindakan lebih lanjut. '
            'Jangan tunda pengobatan untuk hasil yang lebih baik.';
        notifColor = const Color(0xFFFF5252);
      } else if (resultType == 'SAFE' ||
          resultType == 'NEGATIF' ||
          resultType == 'NORMAL') {
        body = 'Hasil analisis menunjukkan negatif TBC. Tetap jaga kesehatan.';
        bigText =
            'Hasil analisis Anda telah selesai dan menunjukkan tidak ada indikasi Tuberkulosis. '
            'Tetap jaga kesehatan dan lakukan pemeriksaan berkala. '
            'Konsultasikan dengan dokter jika ada gejala yang muncul.';
        notifColor = const Color(0xFF4CAF50);
      } else {
        body = 'Hasil memerlukan pemeriksaan lanjutan. Konsultasi dokter.';
        bigText =
            'Hasil analisis Anda telah selesai namun memerlukan pemeriksaan lebih lanjut. '
            'Silakan konsultasikan dengan dokter untuk tes tambahan. '
            'Pemeriksaan lanjutan akan membantu diagnosis yang lebih akurat.';
        notifColor = const Color(0xFFF39C12);
      }

      // Android notification details dengan ALL parameters
      final androidDetails = AndroidNotificationDetails(
        'analysis_results',
        'Hasil Analisis',
        channelDescription: 'Notifikasi untuk hasil analisis TBC',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        when: DateTime.now().millisecondsSinceEpoch,
        icon: '@mipmap/ic_launcher',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        playSound: true,
        enableVibration: true,
        enableLights: true,
        color: notifColor,
        ledColor: notifColor,
        ledOnMs: 1000,
        ledOffMs: 500,
        ticker: '🎯 $title',
        autoCancel: true,
        ongoing: false,
        visibility: NotificationVisibility.public,
        channelShowBadge: true,
        styleInformation: BigTextStyleInformation(
          bigText,
          contentTitle: '🎯 $title',
          summaryText: 'TBCare',
          htmlFormatBigText: false,
          htmlFormatContentTitle: false,
        ),
      );

      final notificationDetails = NotificationDetails(android: androidDetails);

      // Show push notification
      await _notifications.show(
        1000, // Fixed ID untuk result
        '🎯 $title',
        body,
        notificationDetails,
        payload: 'analysis_result_${result['id']}',
      );

      // Add to in-app notification list
      await NotifikasiScreen.addNotification(
        title: '🎯 $title',
        message: bigText,
        type: resultType == 'TB' || resultType == 'DANGER'
            ? NotificationType.warning
            : NotificationType.analysisComplete,
      );

      print('✅ Notification sent successfully');
      print('   Title: 🎯 $title');
      print('   Body: $body');
      print('   BigText: ${bigText.substring(0, 50)}...');
      print('   ResultType: $resultType');
    } catch (e) {
      print('❌ Error showing notification: $e');
      print('   Stack: ${StackTrace.current}');
    }
  }

  // Manual check (untuk testing atau refresh button)
  static Future<void> checkNow() async {
    print('🔄 Manual check triggered...');
    await _checkForNewResults();
  }

  // Save last known state
  static Future<void> _saveLastState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_history_count', _lastHistoryCount);
      if (_lastResultId != null) {
        await prefs.setString('last_result_id', _lastResultId!);
      }
      if (_lastFirstExamId != null) {
        await prefs.setString('last_first_exam_id', _lastFirstExamId!);
      } else {
        await prefs.remove('last_first_exam_id');
      }
      await prefs.setBool('last_first_exam_available', _lastFirstExamAvailable);
      print(
          '💾 State saved: count=$_lastHistoryCount, resultId=$_lastResultId, firstExamId=$_lastFirstExamId, hasFirstExam=$_lastFirstExamAvailable');
    } catch (e) {
      print('❌ Error saving state: $e');
    }
  }

  // Load last known state
  static Future<void> _loadLastState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastHistoryCount = prefs.getInt('last_history_count') ?? 0;
      _lastResultId = prefs.getString('last_result_id');
      _lastFirstExamId = prefs.getString('last_first_exam_id');
      _lastFirstExamAvailable =
          prefs.getBool('last_first_exam_available') ?? false;
      print(
          '📥 State loaded: count=$_lastHistoryCount, resultId=$_lastResultId, firstExamId=$_lastFirstExamId, hasFirstExam=$_lastFirstExamAvailable');
    } catch (e) {
      print('❌ Error loading state: $e');
    }
  }

  // Reset state (for logout)
  static Future<void> resetState() async {
    _lastHistoryCount = 0;
    _lastResultId = null;
    _lastFirstExamId = null;
    _lastFirstExamAvailable = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_history_count');
    await prefs.remove('last_result_id');
    await prefs.remove('last_first_exam_id');
    await prefs.remove('last_first_exam_available');
    print('🔄 State reset');
  }

  // Get notification badge count (untuk UI)
  static int getNotificationCount() {
    // This would be calculated based on unread notifications
    // For now, return 0
    return 0;
  }

  // Clear all notifications
  static Future<void> clearAll() async {
    await _notifications.cancelAll();
    print('🗑️ All notifications cleared');
  }
}
