// lib/models/review.dart

import 'user.dart';

class Review {
  final int id;
  final int bookingId;
  final int photographerId;
  final int clientId;
  final int stars;
  final String? comment;
  final String createdAt;
  final User? client;

  Review({
    required this.id,
    required this.bookingId,
    required this.photographerId,
    required this.clientId,
    required this.stars,
    this.comment,
    required this.createdAt,
    this.client,
  });

  factory Review.fromJson(Map<String, dynamic> j) => Review(
        id:             j['id'] is String ? int.parse(j['id']) : j['id'],
        bookingId:      j['booking_id'] ?? 0,
        photographerId: j['photographer_id'] ?? 0,
        clientId:       j['client_id'] ?? 0,
        stars:          j['stars'] ?? j['rating'] ?? 0,
        comment:        j['comment'],
        createdAt:      j['created_at'] ?? '',
        client:         j['client'] != null ? User.fromJson(j['client']) : null,
      );
}