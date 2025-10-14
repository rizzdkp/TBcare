// lib/services/user_data_service.dart

import 'package:flutter/material.dart';
import 'api_service.dart';

class UserDataService {
  static final List<VoidCallback> _listeners = [];

  // User Profile Data
  static final Map<String, dynamic> _userData = {
    'fullName': 'User',
    'phone': '',
    'email': '',
    'dateOfBirth': '',
    'profileImageUrl': 'https://i.pravatar.cc/150?u=default',
    'userName': '',
    'city': '',
    'address1': '',
    'address2': '',
    'mobileNumber1': '',
    'mobileNumber2': '',
    'role': 'patient',
  };

  // TBCare Profile Data (demographics and health info)
  static final Map<String, dynamic> _tbcareProfile = {
    'sex': '',
    'age': 0,
    'height': 0.0,
    'weight': 0.0,
    'bmi': 0.0,
    'weightStatus': '',
    'comorbidities': <String>[],
    'isCoughProductive': '',
    'coughDurationDays': 0,
    'hasHemoptysis': '',
    'hasChestPain': '',
    'hasShortBreath': '',
    'hasFever': '',
    'hasNightSweats': '',
    'hasWeightLoss': '',
    'weightLossAmountKg': 0,
    'tobaccoUse': '',
    'cigarettesPerDay': 0,
    'smokingSinceMonths': 0,
    'stoppedSmokingMonths': 0,
    'hadPriorTB': '',
    'comorbiditiesOther': '',
    'district': '',
    'province': '',
  };

  // Settings Data
  static final Map<String, dynamic> _settingsData = {
    'generalNotification': true,
    'soundEnabled': true,
    'vibrationEnabled': true,
    'recordNotifications': true,
    'analysisNotifications': true,
  };

  // Password Data
  static final Map<String, String> _passwordData = {
    'currentPassword': 'defaultPassword123',
  };

  // First Exam Data (untuk hasil analisis dan peringatan)
  static Map<String, dynamic>? _firstExamData;

  // History Data (untuk notifikasi count)
  static List<Map<String, dynamic>> _historyData = [];

  // Simpan firstExam data
  static void setFirstExamData(Map<String, dynamic>? data) {
    _firstExamData = data;
    print('✅ First exam data saved: $_firstExamData');
    _notifyListeners();
  }

  // Get firstExam data
  static Map<String, dynamic>? getFirstExamData() => _firstExamData;

  // Simpan history data
  static void setHistoryData(List<dynamic>? data) {
    if (data != null) {
      _historyData = data.map((e) => e as Map<String, dynamic>).toList();
      print('✅ History data saved: ${_historyData.length} records');
      _notifyListeners();
    }
  }

  // Get history count (untuk badge notifikasi)
  static int getHistoryCount() => _historyData.length;

  // Get history data
  static List<Map<String, dynamic>> getHistoryData() => _historyData;

  // Get specific firstExam fields
  static String get examResult => _firstExamData?['result']?.toString() ?? '';
  static String get examDate => _firstExamData?['createdAt']?.toString() ?? '';
  static String get sputumCondition =>
      _firstExamData?['sputumCondition']?.toString() ?? '';
  static String get examId => _firstExamData?['id']?.toString() ?? '';

  // Check if TB positive
  static bool get isTBPositive => examResult.toUpperCase() == 'TB';

  // Sync user data from API response
  static void syncFromAPI(Map<String, dynamic> patientData) {
    // Email
    if (patientData['email'] != null) {
      _userData['email'] = patientData['email'];
    }

    // Full Name dari first + last
    if (patientData['fullName'] != null) {
      final fullName = patientData['fullName'];
      if (fullName is Map) {
        final firstName = fullName['first'] ?? '';
        final lastName = fullName['last'] ?? '';
        _userData['fullName'] = '$firstName $lastName'.trim();
      } else {
        _userData['fullName'] = fullName.toString();
      }
    }

    // ID
    if (patientData['id'] != null || patientData['_id'] != null) {
      _userData['id'] = patientData['id'] ?? patientData['_id'];
    }

    // Username
    if (patientData['userName'] != null) {
      _userData['userName'] = patientData['userName'];
    }

    // City
    if (patientData['city'] != null) {
      _userData['city'] = patientData['city'];
    }

    // Phone numbers
    if (patientData['mobileNumber1'] != null) {
      _userData['mobileNumber1'] = patientData['mobileNumber1'];
      _userData['phone'] = patientData['mobileNumber1']; // Set as primary phone
    }
    if (patientData['mobileNumber2'] != null) {
      _userData['mobileNumber2'] = patientData['mobileNumber2'];
    }

    // Address
    if (patientData['address1'] != null) {
      _userData['address1'] = patientData['address1'];
    }
    if (patientData['address2'] != null) {
      _userData['address2'] = patientData['address2'];
    }

    // Role
    if (patientData['role'] != null) {
      _userData['role'] = patientData['role'];
    }

    // ====== SYNC TBCARE PROFILE DATA ======
    if (patientData['tbcareProfile'] != null) {
      final profile = patientData['tbcareProfile'];

      // Demographics
      if (profile['sex'] != null) _tbcareProfile['sex'] = profile['sex'];
      if (profile['age'] != null) _tbcareProfile['age'] = profile['age'];
      if (profile['height'] != null)
        _tbcareProfile['height'] = profile['height'];
      if (profile['weight'] != null)
        _tbcareProfile['weight'] = profile['weight'];
      if (profile['bmi'] != null) _tbcareProfile['bmi'] = profile['bmi'];
      if (profile['weightStatus'] != null)
        _tbcareProfile['weightStatus'] = profile['weightStatus'];

      // Location from profile (overrides patient city if exists)
      if (profile['city'] != null) _userData['city'] = profile['city'];
      if (profile['district'] != null)
        _tbcareProfile['district'] = profile['district'];
      if (profile['province'] != null)
        _tbcareProfile['province'] = profile['province'];

      // Date of birth from profile
      if (profile['dateOfBirth'] != null) {
        _userData['dateOfBirth'] = profile['dateOfBirth'];
      }

      // Comorbidities
      if (profile['comorbidities'] != null &&
          profile['comorbidities'] is List) {
        _tbcareProfile['comorbidities'] =
            List<String>.from(profile['comorbidities']);
      }

      // Symptoms
      if (profile['isCoughProductive'] != null)
        _tbcareProfile['isCoughProductive'] = profile['isCoughProductive'];
      if (profile['coughDurationDays'] != null)
        _tbcareProfile['coughDurationDays'] = profile['coughDurationDays'];
      if (profile['hasHemoptysis'] != null)
        _tbcareProfile['hasHemoptysis'] = profile['hasHemoptysis'];
      if (profile['hasChestPain'] != null)
        _tbcareProfile['hasChestPain'] = profile['hasChestPain'];
      if (profile['hasShortBreath'] != null)
        _tbcareProfile['hasShortBreath'] = profile['hasShortBreath'];
      if (profile['hasFever'] != null)
        _tbcareProfile['hasFever'] = profile['hasFever'];
      if (profile['hasNightSweats'] != null)
        _tbcareProfile['hasNightSweats'] = profile['hasNightSweats'];
      if (profile['hasWeightLoss'] != null)
        _tbcareProfile['hasWeightLoss'] = profile['hasWeightLoss'];
      if (profile['weightLossAmountKg'] != null)
        _tbcareProfile['weightLossAmountKg'] = profile['weightLossAmountKg'];

      // Tobacco use
      if (profile['tobaccoUse'] != null)
        _tbcareProfile['tobaccoUse'] = profile['tobaccoUse'];
      if (profile['cigarettesPerDay'] != null)
        _tbcareProfile['cigarettesPerDay'] = profile['cigarettesPerDay'];
      if (profile['smokingSinceMonths'] != null)
        _tbcareProfile['smokingSinceMonths'] = profile['smokingSinceMonths'];
      if (profile['stoppedSmokingMonths'] != null)
        _tbcareProfile['stoppedSmokingMonths'] =
            profile['stoppedSmokingMonths'];

      // TB History
      if (profile['hadPriorTB'] != null)
        _tbcareProfile['hadPriorTB'] = profile['hadPriorTB'];
      if (profile['comorbiditiesOther'] != null)
        _tbcareProfile['comorbiditiesOther'] = profile['comorbiditiesOther'];

      print(
          '✅ TBCare profile synced: Age ${_tbcareProfile['age']}, Sex ${_tbcareProfile['sex']}, BMI ${_tbcareProfile['bmi']}');
    }

    print('✅ User data synced from API:');
    print('   Name: ${_userData['fullName']}');
    print('   Email: ${_userData['email']}');
    print('   City: ${_userData['city']}');
    print('   Phone: ${_userData['phone']}');
    _notifyListeners();
  }

  // Getters for User Data
  static Map<String, dynamic> getUserData() => Map.from(_userData);
  static String get fullName => _userData['fullName'] ?? 'User';
  static String get userName => _userData['userName'] ?? '';
  static String get phone =>
      _userData['phone'] ?? _userData['mobileNumber1'] ?? '';
  static String get email => _userData['email'] ?? '';
  static String get dateOfBirth => _userData['dateOfBirth'] ?? '';
  static String get profileImageUrl => _userData['profileImageUrl'] ?? '';
  static String get city => _userData['city'] ?? '';
  static String get address => _userData['address1'] ?? '';
  static String get role => _userData['role'] ?? 'patient';

  // Getters for TBCare Profile (Demographics & Health Info)
  static Map<String, dynamic> getTbcareProfile() => Map.from(_tbcareProfile);
  static String get sex => _tbcareProfile['sex'] ?? '';
  static int get age => _tbcareProfile['age'] ?? 0;
  static double get height => _tbcareProfile['height']?.toDouble() ?? 0.0;
  static double get weight => _tbcareProfile['weight']?.toDouble() ?? 0.0;
  static double get bmi => _tbcareProfile['bmi']?.toDouble() ?? 0.0;
  static String get weightStatus => _tbcareProfile['weightStatus'] ?? '';
  static List<String> get comorbidities =>
      List<String>.from(_tbcareProfile['comorbidities'] ?? []);
  static String get district => _tbcareProfile['district'] ?? '';
  static String get province => _tbcareProfile['province'] ?? '';

  // Symptoms getters
  static String get isCoughProductive =>
      _tbcareProfile['isCoughProductive'] ?? '';
  static int get coughDurationDays => _tbcareProfile['coughDurationDays'] ?? 0;
  static String get hasHemoptysis => _tbcareProfile['hasHemoptysis'] ?? '';
  static String get hasChestPain => _tbcareProfile['hasChestPain'] ?? '';
  static String get hasShortBreath => _tbcareProfile['hasShortBreath'] ?? '';
  static String get hasFever => _tbcareProfile['hasFever'] ?? '';
  static String get hasNightSweats => _tbcareProfile['hasNightSweats'] ?? '';
  static String get hasWeightLoss => _tbcareProfile['hasWeightLoss'] ?? '';
  static int get weightLossAmountKg =>
      _tbcareProfile['weightLossAmountKg'] ?? 0;

  // Tobacco use getters
  static String get tobaccoUse => _tbcareProfile['tobaccoUse'] ?? '';
  static int get cigarettesPerDay => _tbcareProfile['cigarettesPerDay'] ?? 0;
  static int get smokingSinceMonths =>
      _tbcareProfile['smokingSinceMonths'] ?? 0;
  static int get stoppedSmokingMonths =>
      _tbcareProfile['stoppedSmokingMonths'] ?? 0;

  // TB History getters
  static String get hadPriorTB => _tbcareProfile['hadPriorTB'] ?? '';
  static String get comorbiditiesOther =>
      _tbcareProfile['comorbiditiesOther'] ?? '';

  // Getters for Settings
  static Map<String, dynamic> getSettingsData() => Map.from(_settingsData);
  static bool get generalNotification =>
      _settingsData['generalNotification'] ?? true;
  static bool get soundEnabled => _settingsData['soundEnabled'] ?? true;
  static bool get vibrationEnabled => _settingsData['vibrationEnabled'] ?? true;
  static bool get recordNotifications =>
      _settingsData['recordNotifications'] ?? true;
  static bool get analysisNotifications =>
      _settingsData['analysisNotifications'] ?? true;

  // Update User Profile
  static void updateProfile({
    String? fullName,
    String? phone,
    String? email,
    String? dateOfBirth,
    String? profileImageUrl,
  }) {
    bool hasChanges = false;

    if (fullName != null && fullName != _userData['fullName']) {
      _userData['fullName'] = fullName;
      hasChanges = true;
    }
    if (phone != null && phone != _userData['phone']) {
      _userData['phone'] = phone;
      hasChanges = true;
    }
    if (email != null && email != _userData['email']) {
      _userData['email'] = email;
      hasChanges = true;
    }
    if (dateOfBirth != null && dateOfBirth != _userData['dateOfBirth']) {
      _userData['dateOfBirth'] = dateOfBirth;
      hasChanges = true;
    }
    if (profileImageUrl != null &&
        profileImageUrl != _userData['profileImageUrl']) {
      _userData['profileImageUrl'] = profileImageUrl;
      hasChanges = true;
    }

    if (hasChanges) {
      print('✅ Profile updated: $_userData');
      _notifyListeners();
    }
  }

  // Update Settings
  static void updateSettings({
    bool? generalNotification,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? recordNotifications,
    bool? analysisNotifications,
  }) {
    bool hasChanges = false;

    if (generalNotification != null &&
        generalNotification != _settingsData['generalNotification']) {
      _settingsData['generalNotification'] = generalNotification;
      hasChanges = true;

      // If general notification is turned off, turn off all other notifications
      if (!generalNotification) {
        _settingsData['soundEnabled'] = false;
        _settingsData['vibrationEnabled'] = false;
        _settingsData['recordNotifications'] = false;
        _settingsData['analysisNotifications'] = false;
      }
    }

    if (soundEnabled != null && soundEnabled != _settingsData['soundEnabled']) {
      _settingsData['soundEnabled'] =
          _settingsData['generalNotification'] ? soundEnabled : false;
      hasChanges = true;
    }
    if (vibrationEnabled != null &&
        vibrationEnabled != _settingsData['vibrationEnabled']) {
      _settingsData['vibrationEnabled'] =
          _settingsData['generalNotification'] ? vibrationEnabled : false;
      hasChanges = true;
    }
    if (recordNotifications != null &&
        recordNotifications != _settingsData['recordNotifications']) {
      _settingsData['recordNotifications'] =
          _settingsData['generalNotification'] ? recordNotifications : false;
      hasChanges = true;
    }
    if (analysisNotifications != null &&
        analysisNotifications != _settingsData['analysisNotifications']) {
      _settingsData['analysisNotifications'] =
          _settingsData['generalNotification'] ? analysisNotifications : false;
      hasChanges = true;
    }

    if (hasChanges) {
      print('✅ Settings updated: $_settingsData');
      _notifyListeners();
    }
  }

  // Update Password
  static bool updatePassword(String currentPassword, String newPassword) {
    if (_passwordData['currentPassword'] == currentPassword) {
      _passwordData['currentPassword'] = newPassword;
      print('✅ Password updated successfully');
      return true;
    }
    print('❌ Wrong current password');
    return false;
  }

  // Verify Password
  static bool verifyPassword(String password) {
    return _passwordData['currentPassword'] == password;
  }

  // Logout User
  static Future<void> logout() async {
    // Reset user data
    _userData['fullName'] = 'User';
    _userData['email'] = '';
    _userData['phone'] = '';
    _userData['profileImage'] = '';
    _userData['gender'] = '';
    _userData['address'] = '';
    _userData['bloodType'] = '';
    _userData['dateOfBirth'] = '';

    // Clear API session
    await ApiService.logout();

    // Notify listeners
    _notifyListeners();
  }

  // Add Listener
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
    print(
        '📌 UserDataService - Listener added. Total listeners: ${_listeners.length}');
  }

  // Remove Listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
    print(
        '📌 UserDataService - Listener removed. Total listeners: ${_listeners.length}');
  }

  // Notify Listeners
  static void _notifyListeners() {
    print('📢 UserDataService - Notifying ${_listeners.length} listeners...');
    for (final listener in _listeners) {
      try {
        listener();
      } catch (e) {
        print('Error calling listener: $e');
      }
    }
  }

  // Debug method to see all data
  static void debugPrintAllData() {
    print('🔍 UserData: $_userData');
    print('🔍 SettingsData: $_settingsData');
    print('🔍 Active Listeners: ${_listeners.length}');
  }
}
