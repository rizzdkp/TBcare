// lib/screens/main/histori_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoriScreen extends StatelessWidget {
  const HistoriScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Analisys Record',
          style: GoogleFonts.poppins(
            color: Color(0xFF00A8C5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildHistoryCard(
            'Hasil: Terindikasi Positif',
            'Berdasarkan analisis, ditemukan gejala yang mengarah kuat. Segera konsultasikan dengan dokter.',
            [Color(0xFFFF8A8A), Color(0xFFFF5252)],
          ),
          _buildHistoryCard(
            'Hasil: Gejala Ringan',
            'Ditemukan beberapa gejala ringan. Disarankan untuk memantau kondisi dan beristirahat cukup.',
            [Color(0xFFFFF176), Color(0xFFFFD54F)],
          ),
          _buildHistoryCard(
            'Hasil: Negatif',
            'Tidak ditemukan indikasi gejala TBC. Tetap jaga kesehatan dan pola hidup sehat.',
            [Color(0xFFA5D6A7), Color(0xFF66BB6A)],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    String title,
    String subtitle,
    List<Color> gradientColors,
  ) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9)),
            ),
          ],
        ),
      ),
    );
  }
}
