// lib/screens/features/notifikasi_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/user_data_service.dart';

// Simple notification model for this screen only
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type.toString(),
    };
  }

  // Create from JSON
  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.info,
      ),
    );
  }
}

enum NotificationType {
  welcome,
  analysisComplete,
  dataLoaded,
  reminder,
  warning,
  info,
}

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  _NotifikasiScreenState createState() => _NotifikasiScreenState();

  // Static method untuk menambah notifikasi dari luar
  static Future<void> addNotification({
    required String title,
    required String message,
    required NotificationType type,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<NotificationItem> notifications = [];

      final notifJson = prefs.getString('app_notifications');
      if (notifJson != null) {
        final List<dynamic> decoded = json.decode(notifJson);
        notifications =
            decoded.map((item) => NotificationItem.fromJson(item)).toList();
      }

      // Add new notification
      notifications.insert(
        0,
        NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          message: message,
          timestamp: DateTime.now(),
          isRead: false,
          type: type,
        ),
      );

      // Keep only last 50 notifications
      if (notifications.length > 50) {
        notifications = notifications.sublist(0, 50);
      }

      // Save
      final encoded = json.encode(
        notifications.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('app_notifications', encoded);

      print('✅ Notification added: $title');
    } catch (e) {
      print('❌ Error adding notification: $e');
    }
  }
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    UserDataService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    UserDataService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      _loadNotifications();
    }
  }

  // Load notifications from SharedPreferences
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifJson = prefs.getString('app_notifications');

      if (notifJson != null) {
        final List<dynamic> decoded = json.decode(notifJson);
        setState(() {
          notifications =
              decoded.map((item) => NotificationItem.fromJson(item)).toList();
          notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        });
      } else {
        setState(() {
          notifications = [];
        });
      }

      print('📥 Loaded ${notifications.length} notifications');
    } catch (e) {
      print('❌ Error loading notifications: $e');
      setState(() {
        notifications = [];
      });
    }
  }

  // Save notifications to SharedPreferences
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifJson = json.encode(
        notifications.map((item) => item.toJson()).toList(),
      );
      await prefs.setString('app_notifications', notifJson);
      print('💾 Saved ${notifications.length} notifications');
    } catch (e) {
      print('❌ Error saving notifications: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      notifications = notifications.map((notif) {
        return NotificationItem(
          id: notif.id,
          title: notif.title,
          message: notif.message,
          timestamp: notif.timestamp,
          isRead: true,
          type: notif.type,
        );
      }).toList();
    });

    // Save to storage
    await _saveNotifications();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi sudah dibaca')),
      );
    }
  }

  Future<void> _markAsRead(String id) async {
    setState(() {
      notifications = notifications.map((notif) {
        if (notif.id == id) {
          return NotificationItem(
            id: notif.id,
            title: notif.title,
            message: notif.message,
            timestamp: notif.timestamp,
            isRead: true,
            type: notif.type,
          );
        }
        return notif;
      }).toList();
    });

    // Save to storage
    await _saveNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            color: const Color(0xFF00A8C5),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00A8C5)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (notifications.any((notif) => !notif.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark All Read',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF00A8C5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : _buildNotificationsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            'No Notifications',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You\'re all caught up!',
            style: GoogleFonts.poppins(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.welcome:
        iconData = Icons.waving_hand;
        iconColor = Colors.purple;
        break;
      case NotificationType.analysisComplete:
        iconData = Icons.analytics;
        iconColor = Colors.blue;
        break;
      case NotificationType.dataLoaded:
        iconData = Icons.cloud_done;
        iconColor = Colors.green;
        break;
      case NotificationType.reminder:
        iconData = Icons.access_time;
        iconColor = Colors.orange;
        break;
      case NotificationType.warning:
        iconData = Icons.warning;
        iconColor = Colors.red;
        break;
      case NotificationType.info:
        iconData = Icons.info_outline;
        iconColor = Colors.blue;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            notification.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey.withOpacity(0.2)
              : Colors.blue.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
        },
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.poppins(
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getTimeAgo(notification.timestamp),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: !notification.isRead
            ? Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
