// lib/services/record_storage_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';

class RecordStorageService {
  static final List<AnamnesisRecord> _records = [];
  static final List<NotificationItem> _notifications = [];
  static final List<VoidCallback> _listeners = [];

  // Get all records
  static List<AnamnesisRecord> getAllRecords() {
    return List.from(_records);
  }

  // Add new record
  static void addRecord(AnamnesisRecord record) {
    _records.insert(0, record); // Insert at beginning

    // Add notification
    _notifications.insert(
        0,
        NotificationItem(
          id: record.id,
          title: 'Record Disimpan',
          description:
              'Record anamnesis baru telah disimpan dengan ID: ${record.id}',
          time: _getTimeAgo(record.recordingDate),
          type: NotificationType.recordSaved,
          isRead: false,
        ));

    _notifyListeners();
  }

  // Delete record
  static void deleteRecord(String recordId) {
    _records.removeWhere((record) => record.id == recordId);

    // Add delete notification
    _notifications.insert(
        0,
        NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Record Dihapus',
          description: 'Record dengan ID $recordId telah dihapus',
          time: 'Baru saja',
          type: NotificationType.recordDeleted,
          isRead: false,
        ));

    _notifyListeners();
  }

  // Get notifications
  static List<NotificationItem> getAllNotifications() {
    return List.from(_notifications);
  }

  // Mark notification as read
  static void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere((notif) => notif.id == notificationId);
    if (index != -1) {
      final updatedNotification = _notifications[index].copyWith(isRead: true);
      _notifications[index] = updatedNotification;
      print('🟢 Notification $notificationId marked as read');
      _notifyListeners();
    } else {
      print('❌ Notification $notificationId not found');
    }
  }

  // Add method to mark all as read at once (more efficient)
  static void markAllNotificationsAsRead() {
    bool hasChanges = false;
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }
    if (hasChanges) {
      print('🟢 All notifications marked as read');
      _notifyListeners();
    }
  }

  // Add listener for changes
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  // Remove listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  static void _notifyListeners() {
    final unreadCount = _notifications.where((notif) => !notif.isRead).length;
    print('📢 Notifying ${_listeners.length} listeners. Unread count: $unreadCount');
    
    for (final listener in _listeners) {
      try {
        listener();
      } catch (e) {
        print('Error calling listener: $e');
      }
    }
  }

  // Helper function to get time ago
  static String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} M';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} H';
    } else {
      return '${difference.inDays} D';
    }
  }

  // Add sample notifications
  static void addSampleNotifications() {
    if (_notifications.isEmpty) {
      _notifications.addAll([
        NotificationItem(
          id: '1',
          title: 'Selamat Datang!',
          description:
              'Selamat datang di aplikasi PKM. Silakan mulai dengan menambah record pertama Anda.',
          time: 'Baru saja',
          type: NotificationType.other,
          isRead: false,
        ),
        NotificationItem(
          id: '2',
          title: 'Tips Kesehatan',
          description:
              'Jangan lupa untuk rutin melakukan pemeriksaan kesehatan secara berkala.',
          time: '1 H',
          type: NotificationType.other,
          isRead: false,
        ),
      ]);
      _notifyListeners();
    }
  }
}

class AnamnesisRecord {
  final String id;
  final DateTime recordingDate;
  final Map<String, String> data;

  AnamnesisRecord({
    required this.id,
    required this.recordingDate,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordingDate': recordingDate.toIso8601String(),
      'data': data,
    };
  }

  factory AnamnesisRecord.fromJson(Map<String, dynamic> json) {
    return AnamnesisRecord(
      id: json['id'],
      recordingDate: DateTime.parse(json['recordingDate']),
      data: Map<String, String>.from(json['data']),
    );
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String time;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    required this.isRead,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    NotificationType? type,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }
}

enum NotificationType {
  recordSaved,
  recordDeleted,
  other,
}
