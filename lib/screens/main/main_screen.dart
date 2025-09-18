// lib/screens/main/main_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ditambahkan untuk styling
import 'home_screen.dart';
import 'histori_screen.dart';
import 'my_profile_screen.dart';
import 'analysis_screen.dart'; // <-- Import halaman analisis yang baru

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan, sekarang dengan AnalysisScreen
  final List<Widget> _pages = [
    HomeScreen(),
    AnalysisScreen(), // <-- Placeholder sudah diganti
    HistoriScreen(),
    MyProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF00A8C5), // Warna ikon saat aktif
        unselectedItemColor: Colors.grey, // Warna ikon saat tidak aktif
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed, // Agar posisi item tetap
        onTap: _onItemTapped,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold), // Style untuk label aktif
        unselectedLabelStyle: GoogleFonts.poppins(), // Style untuk label tidak aktif
      ),
    );
  }
}