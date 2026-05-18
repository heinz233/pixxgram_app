// lib/services/booking_service.dart

import 'api_service.dart';
import '../config/api_config.dart';

class BookingService {
  // GET /bookings  → plain array (role-aware)
  static Future<List<dynamic>> getAll() async {
    final res  = await ApiService.get(ApiConfig.bookings);
    final data = res.data;
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  // GET /bookings/{id}
  static Future<Map<String, dynamic>> getOne(int id) async {
    final res = await ApiService.get('${ApiConfig.bookings}/$id');
    return res.data;
  }

  // POST /bookings  { photographer_id, booking_date, notes }
  // IMPORTANT: booking_date must be ISO8601 and >1 hour from now
  // 409 = duplicate pending booking on same day
  // 403 = not a client
  static Future<Map<String, dynamic>> create({
    required int    photographerId,
    required String bookingDate,   // ISO8601 e.g. "2026-06-01T10:00"
    String?         notes,
  }) async {
    final res = await ApiService.post(ApiConfig.bookings, data: {
      'photographer_id': photographerId,
      'booking_date':    bookingDate,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return res.data;
  }

  // PATCH /bookings/{id}/status  { status }
  // Valid: pending | confirmed | completed | cancelled
  static Future<Map<String, dynamic>> updateStatus(int id, String status) async {
    final res = await ApiService.patch(
      '${ApiConfig.bookings}/$id/status',
      data: {'status': status},
    );
    return res.data;
  }

  static Future<Map<String, dynamic>> cancel(int id) =>
      updateStatus(id, 'cancelled');

  // POST /bookings/{id}/pay  { phone, amount }
  // Initiates M-Pesa STK push
  // Returns: { message, checkout_request_id, amount_breakdown }
  static Future<Map<String, dynamic>> initiatePayment({
    required int    bookingId,
    required String phone,
    required double amount,
  }) async {
    final res = await ApiService.post(
      '${ApiConfig.bookings}/$bookingId/pay',
      data: {'phone': phone, 'amount': amount},
    );
    return res.data;
  }

  // GET /bookings/{id}/payment-status
  // Returns: { payment_status, payout_status, mpesa_receipt,
  //            amount, platform_commission, photographer_payout, paid_at }
  static Future<Map<String, dynamic>> pollPaymentStatus(int bookingId) async {
    final res = await ApiService.get(
        '${ApiConfig.bookings}/$bookingId/payment-status');
    return res.data;
  }
}