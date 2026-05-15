import 'user.dart';


class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final bool isRead;
  final String createdAt;
  final User? sender;
  final User? receiver;
 
  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.sender,
    this.receiver,
  });
 
  factory Message.fromJson(Map<String, dynamic> j) => Message(
    id:         j['id'],
    senderId:   j['sender_id'],
    receiverId: j['receiver_id'],
    message:    j['message'] ?? '',
    isRead:     j['is_read'] == true || j['is_read'] == 1,
    createdAt:  j['created_at'] ?? '',
    sender:     j['sender'] != null ? User.fromJson(j['sender']) : null,
    receiver:   j['receiver'] != null ? User.fromJson(j['receiver']) : null,
  );
}