// lib/services/message_service.dart

import 'api_service.dart';
import '../config/api_config.dart';

class MessageService {
  // GET /messages/conversations
  static Future<List<dynamic>> getConversations() async {
    final res  = await ApiService.get(ApiConfig.conversations);
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  // GET /messages/conversations/{userId}
  static Future<List<dynamic>> getConversation(int userId) async {
    final res  = await ApiService.get('${ApiConfig.conversations}/$userId');
    final data = res.data;
    if (data is List) return data;
    return [];
  }

  // POST /messages/send  { receiver_id, message }
  static Future<Map<String, dynamic>> send({
    required int    receiverId,
    required String message,
  }) async {
    final res = await ApiService.post(ApiConfig.sendMessage, data: {
      'receiver_id': receiverId,
      'message':     message,
    });
    return res.data;
  }

  // GET /messages/unread  → { unread_count }
  static Future<int> getUnreadCount() async {
    final res = await ApiService.get(ApiConfig.unreadCount);
    return res.data['unread_count'] ?? 0;
  }

  // PATCH /messages/{id}/read
  static Future<void> markRead(int messageId) async {
    await ApiService.patch('/messages/$messageId/read');
  }

  // DELETE /messages/{id}
  static Future<void> deleteMessage(int messageId) async {
    await ApiService.delete('/messages/$messageId');
  }
}