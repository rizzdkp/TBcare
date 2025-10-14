import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pkm/screens/auth/splash_screen.dart';
import 'package:pkm/services/api_service.dart';
import 'package:pkm/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable runtime fetching untuk Google Fonts di device
  // Ini memungkinkan font di-download saat pertama kali digunakan
  GoogleFonts.config.allowRuntimeFetching = true;

  // Initialize ApiService in background (non-blocking)
  ApiService.initialize().catchError((e) {
    print('Error initializing ApiService: $e');
  });

  // Initialize NotificationService
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Buat base theme dulu
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A8C5)),
      useMaterial3: true,
      fontFamily: 'Roboto', // Fallback font
    );

    // Try to apply Google Fonts dengan error handling
    TextTheme? poppinsTextTheme;
    try {
      poppinsTextTheme = GoogleFonts.poppinsTextTheme(baseTheme.textTheme);
    } catch (e) {
      print('⚠️ Google Fonts gagal load, menggunakan font default: $e');
      poppinsTextTheme = baseTheme.textTheme;
    }

    return MaterialApp(
      title: 'TBCare',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: poppinsTextTheme,
      ),
      home: const SplashScreen(),
    );
  }
}
