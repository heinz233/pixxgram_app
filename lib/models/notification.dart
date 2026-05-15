// lib/models/notification.dart

class AppNotification {
  final int id;
  final int userId;
  final String title;
  final String body;
  final String type; // 'booking' | 'payment' | 'message' | 'system'
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic>? data; // extra payload e.g. booking_id

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id:        j['id'] is String ? int.parse(j['id']) : j['id'],
        userId:    j['user_id'] ?? 0,
        title:     j['title'] ?? '',
        body:      j['body'] ?? j['message'] ?? '',
        type:      j['type'] ?? 'system',
        isRead:    j['is_read'] == true || j['is_read'] == 1,
        createdAt: j['created_at'] ?? '',
        data:      j['data'] is Map ? Map<String, dynamic>.from(j['data']) : null,
      );
}