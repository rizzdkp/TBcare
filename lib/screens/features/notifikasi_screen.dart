// lib/screens/features/notifikasi_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/record_storage_service.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  _NotifikasiScreenState createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    RecordStorageService.addListener(_onNotificationsChanged);
    
    // Mark all notifications as read when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markAllAsRead();
    });
  }

  void _markAllAsRead() {
    final unreadNotifications = RecordStorageService.getAllNotifications()
        .where((notif) => !notif.isRead)
        .toList();
    
    print('🔴 Marking ${unreadNotifications.length} notifications as read');
    
    for (final notif in unreadNotifications) {
      RecordStorageService.markNotificationAsRead(notif.id);
    }
    
    if (unreadNotifications.isNotEmpty) {
      print('✅ All notifications marked as read');
    }
  }

  @override
  void dispose() {
    RecordStorageService.removeListener(_onNotificationsChanged);
    super.dispose();
  }

  void _loadNotifications() {
    if (mounted) {
      setState(() {
        notifications = RecordStorageService.getAllNotifications();
      });
    }
  }

  void _onNotificationsChanged() {
    _loadNotifications();
  }

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
      body: notifications.isEmpty
          ? _buildEmptyState()
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildNotificationSections(),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 100, color: Colors.grey[300]),
          SizedBox(height: 20),
          Text(
            'Tidak ada notifikasi',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Notifikasi akan muncul di sini ketika ada aktivitas baru',
            style: GoogleFonts.poppins(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNotificationSections() {
    if (notifications.isEmpty) return [];

    final now = DateTime.now();
    final today = <NotificationItem>[];
    final yesterday = <NotificationItem>[];
    final older = <NotificationItem>[];

    for (final notification in notifications) {
      if (notification.time.contains('M') || notification.time.contains('H') || notification.time == 'Baru saja') {
        today.add(notification);
      } else if (notification.time == '1 D') {
        yesterday.add(notification);
      } else {
        older.add(notification);
      }
    }

    final sections = <Widget>[];

    if (today.isNotEmpty) {
      sections.add(_buildDateSection('Today'));
      sections.add(SizedBox(height: 16));
      today.forEach((notification) {
        sections.add(_buildNotificationItem(notification));
        sections.add(SizedBox(height: 12));
      });
      sections.add(SizedBox(height: 12));
    }

    if (yesterday.isNotEmpty) {
      sections.add(_buildDateSection('Yesterday'));
      sections.add(SizedBox(height: 16));
      yesterday.forEach((notification) {
        sections.add(_buildNotificationItem(notification));
        sections.add(SizedBox(height: 12));
      });
      sections.add(SizedBox(height: 12));
    }

    if (older.isNotEmpty) {
      sections.add(_buildDateSection('Earlier'));
      sections.add(SizedBox(height: 16));
      older.forEach((notification) {
        sections.add(_buildNotificationItem(notification));
        sections.add(SizedBox(height: 12));
      });
    }

    return sections;
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

  Widget _buildNotificationItem(NotificationItem notification) {
    Color titleColor;
    IconData iconData;

    switch (notification.type) {
      case NotificationType.recordSaved:
        titleColor = Color(0xFF4CAF50);
        iconData = Icons.save_alt;
        break;
      case NotificationType.recordDeleted:
        titleColor = Colors.red;
        iconData = Icons.delete_outline;
        break;
      default:
        titleColor = Color(0xFFF39C12);
        iconData = Icons.medical_services;
    }

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
              color: Color(0xFF00A8C5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                    ),
                    Text(
                      notification.time,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  notification.description,
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
