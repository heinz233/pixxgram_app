// lib/services/subscription_service.dart

import 'api_service.dart';
import '../config/api_config.dart';

class SubscriptionService {
  // ── GET /api/subscriptions/plans  (public) ────────────────────────
  // Returns: { plans: { monthly: { price, duration_days, label }, ... } }
  static Future<Map<String, dynamic>> getPlans() async {
    final res = await ApiService.get(ApiConfig.subscriptionPlans);
    return res.data;
  }

  // ── GET /api/subscriptions/current ───────────────────────────────
  // Returns: { subscription (or null), days_remaining }
  // Handles synthetic response when activated manually via admin
  static Future<Map<String, dynamic>> getCurrent() async {
    final res = await ApiService.get(ApiConfig.subscriptionCurrent);
    return res.data;
  }

  // ── GET /api/subscriptions/history ───────────────────────────────
  // Returns: { subscriptions: [...] }
  static Future<List<dynamic>> getHistory() async {
    final res  = await ApiService.get(ApiConfig.subscriptionHistory);
    final data = res.data;
    if (data is Map && data['subscriptions'] is List) {
      return data['subscriptions'];
    }
    return [];
  }

  // ── POST /api/subscriptions/subscribe ────────────────────────────
  // Required: plan (monthly|quarterly|annual), payment_method (mpesa|card|paypal)
  // Required if mpesa: phone
  // Returns for mpesa: { message, subscription_id, checkout_request_id }
  static Future<Map<String, dynamic>> subscribe({
    required String plan,
    required String paymentMethod,
    String?         phone,
  }) async {
    final res = await ApiService.post(
      ApiConfig.subscriptionSubscribe,
      data: {
        'plan':           plan,
        'payment_method': paymentMethod,
        if (phone != null) 'phone': phone,
      },
    );
    return res.data;
  }

  // ── POST /api/subscriptions/{id}/cancel ──────────────────────────
  // Returns: { message }
  static Future<Map<String, dynamic>> cancel(int id) async {
    final res = await ApiService.post('${ApiConfig.subscriptions}/$id/cancel');
    return res.data;
  }

  // ── GET /api/subscriptions/mpesa/status/{checkoutRequestId} ──────
  // Polls Safaricom directly if still pending
  // Returns: { status, mpesa_receipt, paid_at }
  static Future<Map<String, dynamic>> pollMpesaStatus(
      String checkoutRequestId) async {
    final res = await ApiService.get(
        '${ApiConfig.subscriptions}/mpesa/status/$checkoutRequestId');
    return res.data;
  }
}