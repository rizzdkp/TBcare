// lib/screens/features/notification_setting_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/user_data_service.dart';

class NotificationSettingScreen extends StatefulWidget {
  const NotificationSettingScreen({super.key});

  @override
  _NotificationSettingScreenState createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  late bool _generalNotification;
  late bool _soundEnabled;
  late bool _vibrationEnabled;
  late bool _recordNotifications;
  late bool _analysisNotifications;

  @override
  void initState() {
    super.initState();
    // Initialize with current settings
    _loadCurrentSettings();
    UserDataService.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    UserDataService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _loadCurrentSettings() {
    _generalNotification = UserDataService.generalNotification;
    _soundEnabled = UserDataService.soundEnabled;
    _vibrationEnabled = UserDataService.vibrationEnabled;
    _recordNotifications = UserDataService.recordNotifications;
    _analysisNotifications = UserDataService.analysisNotifications;
  }

  void _onSettingsChanged() {
    if (mounted) {
      setState(() {
        _loadCurrentSettings();
      });
    }
  }

  void _updateGeneralNotification(bool value) {
    setState(() {
      _generalNotification = value;
    });

    UserDataService.updateSettings(generalNotification: value);

    if (!value) {
      setState(() {
        _soundEnabled = false;
        _vibrationEnabled = false;
        _recordNotifications = false;
        _analysisNotifications = false;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'All notifications enabled' : 'All notifications disabled',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: value ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateSetting(String settingName, bool value) {
    setState(() {
      switch (settingName) {
        case 'sound':
          _soundEnabled = _generalNotification ? value : false;
          break;
        case 'vibration':
          _vibrationEnabled = _generalNotification ? value : false;
          break;
        case 'record':
          _recordNotifications = _generalNotification ? value : false;
          break;
        case 'analysis':
          _analysisNotifications = _generalNotification ? value : false;
          break;
      }
    });

    UserDataService.updateSettings(
      soundEnabled: settingName == 'sound' ? value : null,
      vibrationEnabled: settingName == 'vibration' ? value : null,
      recordNotifications: settingName == 'record' ? value : null,
      analysisNotifications: settingName == 'analysis' ? value : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: GoogleFonts.poppins(
            color: const Color(0xFF00A8C5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF00A8C5)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('General'),
          _buildSwitchCard(
            'All Notifications',
            'Enable or disable all notifications',
            Icons.notifications,
            _generalNotification,
            _updateGeneralNotification,
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Sound & Vibration'),
          _buildSwitchCard(
            'Sound',
            'Play sound for notifications',
            Icons.volume_up,
            _soundEnabled,
            (value) => _updateSetting('sound', value),
            enabled: _generalNotification,
          ),
          _buildSwitchCard(
            'Vibration',
            'Vibrate for notifications',
            Icons.vibration,
            _vibrationEnabled,
            (value) => _updateSetting('vibration', value),
            enabled: _generalNotification,
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('App Notifications'),
          _buildSwitchCard(
            'Record Notifications',
            'Notify when records are saved or deleted',
            Icons.save,
            _recordNotifications,
            (value) => _updateSetting('record', value),
            enabled: _generalNotification,
          ),
          _buildSwitchCard(
            'Analysis Results',
            'Notify when analysis is complete',
            Icons.analytics,
            _analysisNotifications,
            (value) => _updateSetting('analysis', value),
            enabled: _generalNotification,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF00A8C5),
        ),
      ),
    );
  }

  Widget _buildSwitchCard(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged, {
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.black87 : Colors.grey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: enabled ? Colors.grey[600] : Colors.grey[400],
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xFF00A8C5).withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: enabled ? const Color(0xFF00A8C5) : Colors.grey,
          ),
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
        activeColor: const Color(0xFFF39C12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
