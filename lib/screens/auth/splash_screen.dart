import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pkm/screens/auth/welcome_screen.dart';
import 'package:pkm/screens/main/main_screen.dart';
import 'package:pkm/services/api_service.dart';
import 'package:pkm/services/user_data_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Tunggu frame pertama selesai render dulu sebelum cek login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    try {
      // Tampilkan splash minimal 1.5 detik
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      // Check if user is already logged in (async, tidak blocking)
      final isLoggedIn = await ApiService.isLoggedIn();

      if (!mounted) return;

      if (isLoggedIn) {
        // User already logged in - fetch latest data from API
        print('✅ User logged in, fetching latest data...');
        await _loadUserDataOnStartup();

        // Delay kecil sebelum navigasi untuk smooth transition
        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted) return;

        // Go to main screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      } else {
        // No token, go to welcome screen
        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } catch (e) {
      print('❌ Error in splash: $e');
      // Jika error, langsung ke welcome screen
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    }
  }

  // Load user data saat app dibuka (untuk user yang sudah login)
  Future<void> _loadUserDataOnStartup() async {
    try {
      print('🔄 SPLASH - Fetching user data from API...');
      final response = await ApiService.getPatientHistory();

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // Sync patient data (including tbcareProfile)
        if (data['patient'] != null) {
          UserDataService.syncFromAPI(data['patient']);
          print('✅ SPLASH - User data synced (with tbcareProfile)');
        }

        // Use first history item as "firstExam"
        if (data['history'] != null &&
            data['history'] is List &&
            (data['history'] as List).isNotEmpty) {
          final firstHistoryItem = (data['history'] as List)[0];
          UserDataService.setFirstExamData(firstHistoryItem);
          UserDataService.setHistoryData(data['history']);
          print(
              '✅ SPLASH - Data synced: ${(data['history'] as List).length} history items');
        } else {
          UserDataService.setFirstExamData(null);
          UserDataService.setHistoryData([]);
          print('⚠️ SPLASH - No history available');
        }
      }
    } catch (e) {
      print('❌ SPLASH - Error loading user data: $e');
      // Continue to main screen even if data fetch fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1FBABF),
      body: Center(
        child: _SplashContent(),
      ),
    );
  }
}

// Separate widget untuk optimasi rebuild
class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo TBCare dari assets
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/images/logotbcare.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback jika gambar gagal load
                return Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    size: 80,
                    color: Color(0xFF1FBABF),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'TBCare',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
        ],
      ),
    );
  }
}
