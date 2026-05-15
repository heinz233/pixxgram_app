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
  bool    get isAdmin         => _user?.isAdmin        ?? false;
  bool    get isPhotographer  => _user?.isPhotographer ?? false;
  bool    get isClient        => _user?.isClient       ?? false;

  AuthProvider() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs    = await SharedPreferences.getInstance();
    _token         = prefs.getString('auth_token');
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try { _user = User.fromJson(jsonDecode(userData)); } catch (_) {}
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final data = await AuthService.login(email, password);
      await _setSession(data['token'], data['user']);
      return true;
    } catch (e) {
      _error = _parseError(e); return false;
    } finally { _loading = false; notifyListeners(); }
  }

  // Takes a plain Map — no FormData dependency in the provider layer
  Future<bool> register(Map<String, dynamic> formData) async {
    _loading = true; _error = null; notifyListeners();
    try {
      await AuthService.register(formData);
      return true;
    } catch (e) {
      _error = _parseError(e); return false;
    } finally { _loading = false; notifyListeners(); }
  }

  Future<void> logout() async {
    try { await AuthService.logout(); } catch (_) {}
    await _clearSession();
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final data = await AuthService.getUser();
      _user = User.fromJson(data['user'] ?? data);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', jsonEncode(data['user'] ?? data));
      notifyListeners();
    } catch (_) {}
  }

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
      if (e == null) return 'Something went wrong. Please try again.';
      // Directly check fields safely without redundant runtime type-casting assertions
      return e.response?.data?['message']?.toString() ??
             e.response?.data?['error']?.toString()   ??
             e.toString();
    } catch (_) { return 'Something went wrong. Please try again.'; }
  }
}
