// lib/models/payment.dart

class Payment {
  final int id;
  final int bookingId;
  final int userId;
  final double amount;
  final String method;       // 'mpesa' | 'card' | 'cash'
  final String status;       // 'pending' | 'completed' | 'failed' | 'refunded'
  final String? reference;   // M-Pesa transaction code
  final String? phone;       // payer's phone
  final String createdAt;

  Payment({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    this.reference,
    this.phone,
    required this.createdAt,
  });

  bool get isCompleted => status == 'completed';
  bool get isPending   => status == 'pending';
  bool get isFailed    => status == 'failed';

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
        id:        j['id'] is String ? int.parse(j['id']) : j['id'],
        bookingId: j['booking_id'] ?? 0,
        userId:    j['user_id'] ?? 0,
        amount:    double.tryParse(j['amount']?.toString() ?? '0') ?? 0,
        method:    j['method'] ?? j['payment_method'] ?? 'mpesa',
        status:    j['status'] ?? 'pending',
        reference: j['reference'] ?? j['mpesa_code'] ?? j['transaction_id'],
        phone:     j['phone'] ?? j['phone_number'],
        createdAt: j['created_at'] ?? '',
      );
}