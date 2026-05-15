// lib/models/booking.dart

import 'user.dart';

class Booking {
  final int     id;
  final int     clientId;
  final int     photographerId;
  final String  bookingDate;
  final String? notes;
  final String  status;
  final double? amount;
  final String? paymentStatus;
  final String? commissionStatus;
  final double? commissionAmount;
  final String? createdAt;
  final User?   client;
  final User?   photographer;

  const Booking({
    required this.id,
    required this.clientId,
    required this.photographerId,
    required this.bookingDate,
    this.notes,
    required this.status,
    this.amount,
    this.paymentStatus,
    this.commissionStatus,
    this.commissionAmount,
    this.createdAt,
    this.client,
    this.photographer,
  });

  // ── Status helpers ────────────────────────────────────────────────────────
  bool get isPending    => status == 'pending';
  bool get isConfirmed  => status == 'confirmed';
  bool get isCancelled  => status == 'cancelled';
  bool get isCompleted  => status == 'completed';
  bool get isPaid       => paymentStatus == 'paid';
  bool get isUpcoming   =>
      (isConfirmed || isPending) &&
      DateTime.tryParse(bookingDate)?.isAfter(DateTime.now()) == true;

  // ── Formatted date ────────────────────────────────────────────────────────
  String get formattedDate {
    final dt = DateTime.tryParse(bookingDate);
    if (dt == null) return bookingDate;
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String get formattedTime {
    final dt = DateTime.tryParse(bookingDate);
    if (dt == null) return '';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get clientName       => client?.name ?? 'Client';
  String get photographerName => photographer?.name ?? 'Photographer';

  // ── Serialisation ─────────────────────────────────────────────────────────
  factory Booking.fromJson(Map<String, dynamic> j) => Booking(
        id:               _parseInt(j['id']),
        clientId:         _parseInt(j['client_id']),
        photographerId:   _parseInt(j['photographer_id']),
        bookingDate:      j['booking_date'] ?? '',
        notes:            j['notes'],
        status:           j['status'] ?? 'pending',
        amount:           _parseDouble(j['amount']),
        paymentStatus:    j['payment_status'],
        commissionStatus: j['commission_status'],
        commissionAmount: _parseDouble(j['commission_amount']),
        createdAt:        j['created_at'],
        client:           j['client'] != null
                              ? User.fromJson(j['client']) : null,
        photographer:     j['photographer'] != null
                              ? User.fromJson(j['photographer']) : null,
      );

  Map<String, dynamic> toJson() => {
        'id':             id,
        'client_id':      clientId,
        'photographer_id':photographerId,
        'booking_date':   bookingDate,
        'notes':          notes,
        'status':         status,
        'amount':         amount,
        'payment_status': paymentStatus,
        'created_at':     createdAt,
      };

  Booking copyWith({String? status, String? paymentStatus}) => Booking(
        id:               id,
        clientId:         clientId,
        photographerId:   photographerId,
        bookingDate:      bookingDate,
        notes:            notes,
        status:           status           ?? this.status,
        amount:           amount,
        paymentStatus:    paymentStatus    ?? this.paymentStatus,
        commissionStatus: commissionStatus,
        commissionAmount: commissionAmount,
        createdAt:        createdAt,
        client:           client,
        photographer:     photographer,
      );

  @override
  bool operator ==(Object other) => other is Booking && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

int     _parseInt(dynamic v)  => v is String ? int.parse(v)    : (v ?? 0) as int;
double? _parseDouble(dynamic v) =>
    v == null ? null : double.tryParse(v.toString());