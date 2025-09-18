// lib/screens/features/notifikasi_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Color(0xFF00A8C5),
        foregroundColor: Colors.white,
        title: Text(
          'Notification',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSection('Today'),
            SizedBox(height: 16),
            _buildNotificationItem(
              'Hasilmu Sudah Keluar',
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
              '2 M',
              Color.fromARGB(255, 197, 0, 0),
              Icons.medical_services,
            ),
            SizedBox(height: 12),
            _buildNotificationItem(
              'Hasilmu Sudah Keluar',
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
              '2 H',
              Color(0xFFF39C12),
              Icons.medical_services,
            ),
            SizedBox(height: 12),
            _buildNotificationItem(
              'Hasilmu Sudah Keluar',
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor.',
              '3 H',
              Color(0xFF4CAF50),
              Icons.medical_services,
            ),
            SizedBox(height: 24),
            _buildDateSection('Yesterday'),
            SizedBox(height: 16),
            _buildNotificationItem(
              'Record Saved',
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod aliqua.',
              '1 D',
              Color(0xFFF39C12),
              Icons.save_alt,
            ),
            SizedBox(height: 24),
            _buildDateSection('15 April'),
            SizedBox(height: 16),
            _buildNotificationItem(
              'Record Saved',
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod aliqua.',
              '5 D',
              Color(0xFFF39C12),
              Icons.save_alt,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(String date) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF00A8C5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        date,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String description,
    String time,
    Color titleColor,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF00A8C5), // Same color for all icons
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: titleColor, // Color applied to title text
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
