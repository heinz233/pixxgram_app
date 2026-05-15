// lib/services/auth_service.dart

import 'api_service.dart';
import '../config/api_config.dart';

class AuthService {
  // ── POST /api/register ────────────────────────────────────────────
  // Laravel returns: { message, user }
  // NOTE: does NOT return a token — user must verify email first then login
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> data) async {
    final res = await ApiService.post(ApiConfig.register, data: data);
    return res.data;
  }

  // ── POST /api/login ───────────────────────────────────────────────
  // Laravel returns: { message, user (with role + photographerProfile), token }
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await ApiService.post(ApiConfig.login, data: {
      'email':    email,
      'password': password,
    });
    return res.data;
  }

  // ── POST /api/logout ──────────────────────────────────────────────
  static Future<void> logout() async {
    await ApiService.post(ApiConfig.logout);
  }

  // ── GET /api/user ─────────────────────────────────────────────────
  // Laravel returns: { user (with role + photographerProfile) }
  static Future<Map<String, dynamic>> getUser() async {
    final res = await ApiService.get(ApiConfig.user);
    return res.data;
  }
}