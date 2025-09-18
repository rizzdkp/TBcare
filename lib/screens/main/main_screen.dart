// lib/screens/main/main_screen.dart

import 'package:flutter/material.dart';
// Ditambahkan untuk styling
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Color(0xFFE9F6FE), // Changed to light blue color
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Analysis',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFFF39C12), // Orange for selected
          unselectedItemColor: Color.fromARGB(255, 35, 128, 154), // Changed to grey for better contrast on light background
          backgroundColor: Colors.transparent, // Keep transparent
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 11,
          ),
          selectedFontSize: 12,
          unselectedFontSize: 11,
        ),
      ),
    );
  }
}
