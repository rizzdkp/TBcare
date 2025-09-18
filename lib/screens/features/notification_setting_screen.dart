// lib/screens/features/notification_setting_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  _NotificationSettingScreenState createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  bool _generalNotification = true;
  bool _sound = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notification Setting',
          style: GoogleFonts.poppins(
            color: Color(0xFF00A8C5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF00A8C5)),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSwitchTile(
            'General Notification',
            _generalNotification,
            (value) => setState(() => _generalNotification = value),
          ),
          _buildSwitchTile(
            'Sound',
            _sound,
            (value) => setState(() => _sound = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFFF39C12),
      ),
    );
  }
}
