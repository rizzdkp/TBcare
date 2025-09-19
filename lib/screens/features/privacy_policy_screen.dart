// lib/screens/features/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            color: const Color(0xFF00A8C5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00A8C5)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last Update: 18/09/2025',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent pellentesque congue lorem, vel tincidunt tortor placerat a. Proin ac diam quam...',
              style: GoogleFonts.poppins(height: 1.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Terms & Conditions',
              style: GoogleFonts.poppins(
                color: const Color(0xFFF39C12),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '1. Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n\n2. Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
              style: GoogleFonts.poppins(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
