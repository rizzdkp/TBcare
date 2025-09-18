// lib/screens/features/help_center_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Help Center',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color(0xFF1CB5E0),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              '\n\nHow Can We Help You?',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
            ),
            titlePadding: EdgeInsets.only(left: 20, bottom: 50),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 50, // Fixed height for consistent sizing
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors
                      .grey
                      .shade100, // Background color for unselected area
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Color(0xFFF39C12), // Orange color when selected
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFF39C12).withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab, // Full tab width
                  dividerColor: Colors.transparent, // Remove default divider
                  splashFactory: NoSplash.splashFactory, // Remove splash effect
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  tabs: [
                    Container(
                      height: 42,
                      alignment: Alignment.center,
                      child: Text('FAQ'),
                    ),
                    Container(
                      height: 42,
                      alignment: Alignment.center,
                      child: Text('Contact Us'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [_buildFaqTab(), _buildContactUsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTab() {
    // ... (kode FAQ tetap sama)
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildExpansionTile(
          'Apa itu TBCare?',
          'TBCare adalah aplikasi mobile untuk skrining awal...',
        ),
        _buildExpansionTile(
          'Bagaimana cara kerja aplikasi?',
          'Aplikasi menggunakan...',
        ),
        _buildExpansionTile(
          'Apakah hasilnya akurat?',
          'Hasil dari aplikasi ini adalah...',
        ),
      ],
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    // ... (kode expansion tile tetap sama)
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Color(0xFF00A8C5),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(content, style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildContactUsTab() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      children: [
        _buildContactItem(Icons.headset_mic_outlined, 'Customer Service'),
        _buildContactItem(Icons.public, 'Website'),
        _buildContactItem(Icons.message_outlined, 'Whatsapp'), // Ikon generik
        _buildContactItem(
          Icons.camera_alt_outlined,
          'Instagram',
        ), // Ikon generik
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String title) {
    return Card(
      elevation: 0.5,
      shadowColor: Colors.grey.withOpacity(0.1),
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFF39C12).withOpacity(0.1),
          child: Icon(icon, color: Color(0xFFF39C12)),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(Icons.keyboard_arrow_down, color: Color(0xFFF39C12)),
        onTap: () {},
      ),
    );
  }
}
