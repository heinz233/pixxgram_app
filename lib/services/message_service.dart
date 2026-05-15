// lib/services/message_service.dart

import 'api_service.dart';
import '../config/api_config.dart';

class MessageService {
  // ── GET /api/messages/conversations ──────────────────────────────
  // Returns latest message per unique conversation partner
  static Future<List<dynamic>> getConversations() async {
    final res = await ApiService.get(ApiConfig.conversations);
    final data = res.data;
    if (data is List) return data;
    return [];
  }

  // ── GET /api/messages/conversations/{userId} ──────────────────────
  // Returns all messages in a thread, also marks incoming as read
  static Future<List<dynamic>> getConversation(int userId) async {
    final res = await ApiService.get('${ApiConfig.conversations}/$userId');
    final data = res.data;
    if (data is List) return data;
    return [];
  }

  // ── POST /api/messages/send ───────────────────────────────────────
  // Required: receiver_id, message
  // Returns: { message, data (with sender + receiver) }
  static Future<Map<String, dynamic>> send({
    required dynamic receiverId,
    required String message,
  }) async {
    int parsedId;
    if (receiverId is int) {
      parsedId = receiverId;
    } else {
      parsedId = int.parse(receiverId.toString());
    }

    final res = await ApiService.post(ApiConfig.sendMessage, data: {
      'receiver_id': parsedId,
      'message':     message,
    });
    return res.data;
  }

  // Alias method mapping named signatures explicitly requested by UI layers
  static Future<Map<String, dynamic>> sendMessage({
    required dynamic receiverId,
    required String message,
  }) async {
    return send(receiverId: receiverId, message: message);
  }

  // ── GET /api/messages/unread ──────────────────────────────────────
  // Returns: { unread_count }
  static Future<int> getUnreadCount() async {
    final res  = await ApiService.get(ApiConfig.unreadCount);
    return res.data['unread_count'] ?? 0;
  }

  // ── PATCH /api/messages/{id}/read ────────────────────────────────
  static Future<void> markAsRead(int messageId) async {
    await ApiService.patch('/messages/$messageId/read');
  }

  // ── DELETE /api/messages/{id} ────────────────────────────────────
  static Future<void> deleteMessage(int messageId) async {
    await ApiService.delete('/messages/$messageId');
  }
}
