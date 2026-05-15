// lib/models/report.dart

import 'user.dart';

class Report {
  final int id;
  final int reporterId;
  final int? reportedUserId;
  final int? bookingId;
  final String reason;
  final String? description;
  final String status; // 'open' | 'resolved' | 'dismissed'
  final String createdAt;
  final User? reporter;
  final User? reportedUser;

  Report({
    required this.id,
    required this.reporterId,
    this.reportedUserId,
    this.bookingId,
    required this.reason,
    this.description,
    required this.status,
    required this.createdAt,
    this.reporter,
    this.reportedUser,
  });

  bool get isOpen      => status == 'open';
  bool get isResolved  => status == 'resolved';
  bool get isDismissed => status == 'dismissed';

  factory Report.fromJson(Map<String, dynamic> j) => Report(
        id:             j['id'] is String ? int.parse(j['id']) : j['id'],
        reporterId:     j['reporter_id'] ?? 0,
        reportedUserId: j['reported_user_id'],
        bookingId:      j['booking_id'],
        reason:         j['reason'] ?? '',
        description:    j['description'],
        status:         j['status'] ?? 'open',
        createdAt:      j['created_at'] ?? '',
        reporter:       j['reporter'] != null ? User.fromJson(j['reporter']) : null,
        reportedUser:   j['reported_user'] != null
            ? User.fromJson(j['reported_user'])
            : null,
      );
}