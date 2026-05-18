// lib/providers/auth_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/services.dart';

class AuthProvider extends ChangeNotifier {
  User?   _user;
  String? _token;
  bool    _loading = false;
  String? _error;

  User?   get user            => _user;
  String? get token           => _token;
  bool    get loading         => _loading;
  String? get error           => _error;
  bool    get isAuthenticated => _token != null && _user != null;

  // ── Role checks ───────────────────────────────────────────────────
  // Vue checks user.role.name; Laravel returns role_id on the user object.
  // Both are supported here.
  bool get isAdmin        => _user?.isAdmin        ?? false;
  bool get isPhotographer => _user?.isPhotographer ?? false;
  bool get isClient       => _user?.isClient       ?? false;

  AuthProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs    = await SharedPreferences.getInstance();
    _token         = prefs.getString('auth_token');
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        _user = User.fromJson(jsonDecode(userData));
      } catch (_) {}
    }
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────────────
  // Laravel returns: { message, user (with photographer_profile), token }
  Future<bool> login(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final data = await AuthService.login(email, password);
      if (data['token'] == null) {
        _error = 'No token returned. Check your credentials.';
        return false;
      }
      await _setSession(data['token'], data['user']);
      return true;
    } catch (e) {
      _error = _parseError(e);
      return false;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  // ── Register ──────────────────────────────────────────────────────
  // Laravel does NOT return a token on register — email verification required.
  // Vue redirects to /verify-email after register.
  Future<bool> register(Map<String, dynamic> formData) async {
    _loading = true; _error = null; notifyListeners();
    try {
      await AuthService.register(formData);
      return true;
    } catch (e) {
      _error = _parseError(e);
      return false;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  // ── Logout ────────────────────────────────────────────────────────
  Future<void> logout() async {
    try { await AuthService.logout(); } catch (_) {}
    await _clearSession();
    notifyListeners();
  }

  // ── Refresh user from API ─────────────────────────────────────────
  // Matches Vue's fetchMe() → GET /user → { user }
  Future<void> refreshUser() async {
    try {
      final data = await AuthService.getUser();
      final userData = data['user'] ?? data;
      _user = User.fromJson(userData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(userData));
      notifyListeners();
    } catch (_) {}
  }

  // ── Helpers ───────────────────────────────────────────────────────
  Future<void> _setSession(String token, Map<String, dynamic> userData) async {
    _token = token;
    _user  = User.fromJson(userData);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(userData));
  }

  Future<void> _clearSession() async {
    _token = null; _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  String _parseError(dynamic e) {
    try {
      return e.response?.data?['message'] ??
             e.response?.data?['error']   ??
             'Something went wrong. Please try again.';
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }
}