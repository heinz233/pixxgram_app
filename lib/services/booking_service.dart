// lib/services/booking_service.dart

import 'api_service.dart';
import '../config/api_config.dart';

class BookingService {
  // ── GET /api/bookings ─────────────────────────────────────────────
  // Role-aware: clients get their bookings, photographers get theirs
  // Returns a plain JSON array (not paginated for client/photographer)
  static Future<List<dynamic>> getAll() async {
    final res = await ApiService.get(ApiConfig.bookings);
    final data = res.data;
    // Admin gets paginated, client/photographer gets plain array
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  // ── GET /api/bookings/{id} ────────────────────────────────────────
  static Future<Map<String, dynamic>> getOne(int id) async {
    final res = await ApiService.get('${ApiConfig.bookings}/$id');
    return res.data;
  }

  // ── POST /api/bookings ────────────────────────────────────────────
  // Required: photographer_id, booking_date (ISO8601, must be >1hr from now)
  // Optional: notes
  // Returns: { message, booking }
  static Future<Map<String, dynamic>> create({
    required int    photographerId,
    required String bookingDate,
    String?         notes,
  }) async {
    final res = await ApiService.post(ApiConfig.bookings, data: {
      'photographer_id': photographerId,
      'booking_date':    bookingDate,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return res.data;
  }

  // ── PATCH /api/bookings/{id}/status ──────────────────────────────
  // Valid statuses: pending | confirmed | completed | cancelled
  // Client: can only set 'cancelled' (and only on pending bookings)
  // Photographer: confirmed → completed (requires payment first)
  static Future<Map<String, dynamic>> updateStatus(
      int id, String status) async {
    final res = await ApiService.patch(
      '${ApiConfig.bookings}/$id/status',
      data: {'status': status},
    );
    return res.data;
  }

  // ── Shorthand cancellation ────────────────────────────────────────
  static Future<Map<String, dynamic>> cancel(int id) =>
      updateStatus(id, 'cancelled');

  // ── POST /api/bookings/{id}/pay ───────────────────────────────────
  // Initiates M-Pesa STK push for a confirmed booking
  // Required: phone (Safaricom), amount
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

  // ── GET /api/bookings/{id}/payment-status ────────────────────────
  // Returns: { payment_status, payout_status, mpesa_receipt,
  //            amount, platform_commission, photographer_payout, paid_at }
  static Future<Map<String, dynamic>> pollPaymentStatus(int bookingId) async {
    final res =
        await ApiService.get('${ApiConfig.bookings}/$bookingId/payment-status');
    return res.data;
  }
}