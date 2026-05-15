// lib/models/subscription.dart

class Subscription {
  final int id;
  final int photographerId;
  final String plan;
  final double amount;
  final String status;
  final String? paymentMethod;
  final String? startsAt;
  final String? endsAt;

  Subscription({
    required this.id,
    required this.photographerId,
    required this.plan,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.startsAt,
    this.endsAt,
  });

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
  bool get isExpired => status == 'expired';

  // Returns true if subscription expires within the next N days
  bool isExpiringSoon({int withinDays = 7}) {
    if (endsAt == null) return false;
    final end = DateTime.tryParse(endsAt!);
    if (end == null) return false;
    final now = DateTime.now();
    return end.isAfter(now) && end.isBefore(now.add(Duration(days: withinDays)));
  }

  // Days remaining until expiry (0 if already expired)
  int get daysRemaining {
    if (endsAt == null) return 0;
    final end = DateTime.tryParse(endsAt!);
    if (end == null) return 0;
    final diff = end.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  factory Subscription.fromJson(Map<String, dynamic> j) => Subscription(
        id:            j['id'] is String ? int.parse(j['id']) : (j['id'] ?? 0),
        photographerId: j['photographer_id'] is String
            ? int.parse(j['photographer_id'])
            : (j['photographer_id'] ?? 0),
        plan:          j['plan'] ?? 'monthly',
        amount:        double.tryParse(j['amount']?.toString() ?? '0') ?? 0,
        status:        j['status'] ?? 'pending',
        paymentMethod: j['payment_method'],
        startsAt:      j['starts_at'],
        endsAt:        j['ends_at'],
      );
}