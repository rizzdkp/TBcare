// lib/services/user_data_service.dart

import 'package:flutter/material.dart';

class UserDataService {
  static final List<VoidCallback> _listeners = [];

  // User Profile Data
  static Map<String, dynamic> _userData = {
    'fullName': 'Jane Doe',
    'phone': '+123 567 89000',
    'email': 'janedoe@example.com',
    'dateOfBirth': '15/06/1990',
    'profileImageUrl': 'https://i.pravatar.cc/150?u=janedoe',
  };

  // Settings Data
  static Map<String, dynamic> _settingsData = {
    'generalNotification': true,
    'soundEnabled': true,
    'vibrationEnabled': true,
    'recordNotifications': true,
    'analysisNotifications': true,
  };

  // Password Data
  static Map<String, String> _passwordData = {
    'currentPassword': 'defaultPassword123',
  };

  // Getters for User Data
  static Map<String, dynamic> getUserData() => Map.from(_userData);
  static String get fullName => _userData['fullName'] ?? 'User';
  static String get phone => _userData['phone'] ?? '';
  static String get email => _userData['email'] ?? '';
  static String get dateOfBirth => _userData['dateOfBirth'] ?? '';
  static String get profileImageUrl => _userData['profileImageUrl'] ?? '';

  // Getters for Settings
  static Map<String, dynamic> getSettingsData() => Map.from(_settingsData);
  static bool get generalNotification =>
      _settingsData['generalNotification'] ?? true;
  static bool get soundEnabled => _settingsData['soundEnabled'] ?? true;
  static bool get vibrationEnabled => _settingsData['vibrationEnabled'] ?? true;
  static bool get recordNotifications =>
      _settingsData['recordNotifications'] ?? true;
  static bool get analysisNotifications =>
      _settingsData['analysisNotifications'] ?? true;

  // Update User Profile
  static void updateProfile({
    String? fullName,
    String? phone,
    String? email,
    String? dateOfBirth,
    String? profileImageUrl,
  }) {
    bool hasChanges = false;

    if (fullName != null && fullName != _userData['fullName']) {
      _userData['fullName'] = fullName;
      hasChanges = true;
    }
    if (phone != null && phone != _userData['phone']) {
      _userData['phone'] = phone;
      hasChanges = true;
    }
    if (email != null && email != _userData['email']) {
      _userData['email'] = email;
      hasChanges = true;
    }
    if (dateOfBirth != null && dateOfBirth != _userData['dateOfBirth']) {
      _userData['dateOfBirth'] = dateOfBirth;
      hasChanges = true;
    }
    if (profileImageUrl != null &&
        profileImageUrl != _userData['profileImageUrl']) {
      _userData['profileImageUrl'] = profileImageUrl;
      hasChanges = true;
    }

    if (hasChanges) {
      print('✅ Profile updated: $_userData');
      _notifyListeners();
    }
  }

  // Update Settings
  static void updateSettings({
    bool? generalNotification,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? recordNotifications,
    bool? analysisNotifications,
  }) {
    bool hasChanges = false;

    if (generalNotification != null &&
        generalNotification != _settingsData['generalNotification']) {
      _settingsData['generalNotification'] = generalNotification;
      hasChanges = true;

      // If general notification is turned off, turn off all other notifications
      if (!generalNotification) {
        _settingsData['soundEnabled'] = false;
        _settingsData['vibrationEnabled'] = false;
        _settingsData['recordNotifications'] = false;
        _settingsData['analysisNotifications'] = false;
      }
    }

    if (soundEnabled != null && soundEnabled != _settingsData['soundEnabled']) {
      _settingsData['soundEnabled'] =
          _settingsData['generalNotification'] ? soundEnabled : false;
      hasChanges = true;
    }
    if (vibrationEnabled != null &&
        vibrationEnabled != _settingsData['vibrationEnabled']) {
      _settingsData['vibrationEnabled'] =
          _settingsData['generalNotification'] ? vibrationEnabled : false;
      hasChanges = true;
    }
    if (recordNotifications != null &&
        recordNotifications != _settingsData['recordNotifications']) {
      _settingsData['recordNotifications'] =
          _settingsData['generalNotification'] ? recordNotifications : false;
      hasChanges = true;
    }
    if (analysisNotifications != null &&
        analysisNotifications != _settingsData['analysisNotifications']) {
      _settingsData['analysisNotifications'] =
          _settingsData['generalNotification'] ? analysisNotifications : false;
      hasChanges = true;
    }

    if (hasChanges) {
      print('✅ Settings updated: $_settingsData');
      _notifyListeners();
    }
  }

  // Update Password
  static bool updatePassword(String currentPassword, String newPassword) {
    if (_passwordData['currentPassword'] == currentPassword) {
      _passwordData['currentPassword'] = newPassword;
      print('✅ Password updated successfully');
      return true;
    }
    print('❌ Wrong current password');
    return false;
  }

  // Verify Password
  static bool verifyPassword(String password) {
    return _passwordData['currentPassword'] == password;
  }

  // Add Listener
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  // Remove Listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  // Notify Listeners
  static void _notifyListeners() {
    for (final listener in _listeners) {
      try {
        listener();
      } catch (e) {
        print('Error calling listener: $e');
      }
    }
  }

  // Debug method to see all data
  static void debugPrintAllData() {
    print('🔍 UserData: $_userData');
    print('🔍 SettingsData: $_settingsData');
    print('🔍 Active Listeners: ${_listeners.length}');
  }
}
