// lib/services/payment_service.dart

import 'api_service.dart';
import '../config/api_config.dart';

class PaymentService {
  // ── Initiate M-Pesa STK push ───────────────────────────────────────
  static Future<Map<String, dynamic>> initiateMpesa({
    required String phone,
    required double amount,
    required String reference,
  }) async {
    final res = await ApiService.post(ApiConfig.paymentsInitiate, data: {
      'phone':     phone,
      'amount':    amount,
      'reference': reference,
    });
    return res.data;
  }

  // ── Poll M-Pesa payment status ─────────────────────────────────────
  static Future<Map<String, dynamic>> pollMpesaStatus(
      String checkoutRequestId) async {
    final res = await ApiService.get(
        '${ApiConfig.payments}/mpesa/status/$checkoutRequestId');
    return res.data;
  }

  // ── Get payment history for authenticated user ─────────────────────
  static Future<Map<String, dynamic>> getHistory() async {
    final res = await ApiService.get(ApiConfig.payments);
    return res.data;
  }

  // ── Get single payment ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getOne(int id) async {
    final res = await ApiService.get('${ApiConfig.payments}/$id');
    return res.data;
  }
}