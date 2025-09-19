import 'package:flutter/material.dart';
import 'package:pkm/screens/auth/splash_screen.dart'; // Pastikan path ini benar

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBCare',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(), // Memulai aplikasi dari Splash Screen
      debugShowCheckedModeBanner: false,
    );
  }
}
