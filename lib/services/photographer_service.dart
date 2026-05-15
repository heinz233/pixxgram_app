// lib/services/photographer_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class PhotographerService {
  // ── Public: list all active photographers ────────────────────────────────
  static Future<Map<String, dynamic>> getAll({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final res = await ApiService.get(
        ApiConfig.photographers,
        params: filters,
      );
      final data = res.data;
      if (data is Map) {
        if (data['photographers'] is Map &&
            data['photographers']['data'] != null) {
          return Map<String, dynamic>.from(data)
            ..['photographers'] = data['photographers']['data'];
        }
        if (data['photographers'] is List) {
          return Map<String, dynamic>.from(data)
            ..['photographers'] = data['photographers'];
        }
        if (data['data'] is List) {
          return {'photographers': data};
        }
      }
      return data;
    } on DioException catch (e) {
      debugPrint('PhotographerService.getAll error: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      rethrow;
    }
  }

  // ── Public: single photographer profile + portfolio + reviews ────────────
  static Future<Map<String, dynamic>> getById(int id) async {
    try {
      debugPrint('Fetching photographer ID: $id');
      final res = await ApiService.get('${ApiConfig.photographers}/$id');
      final data = res.data as Map<String, dynamic>;
      debugPrint('Photographer response keys: ${data.keys.toList()}');

      Map<String, dynamic> photographer;
      if (data['photographer'] != null) {
        photographer = data['photographer'] as Map<String, dynamic>;
      } else if (data['data'] != null) {
        photographer = data['data'] as Map<String, dynamic>;
      } else {
        photographer = data;
      }

      final portfolio = data['portfolio'] as List? ?? [];
      final reviews   = data['reviews']   as List? ?? [];

      return {
        'photographer': photographer,
        'portfolio':    portfolio,
        'reviews':      reviews,
      };
    } on DioException catch (e) {
      debugPrint('PhotographerService.getById($id) error: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      debugPrint('Response: ${e.response?.data}');
      rethrow;
    }
  }

  // ── Authenticated: own dashboard stats ───────────────────────────────────
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final res = await ApiService.get(ApiConfig.dashboard);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('PhotographerService.getDashboard error: ${e.message}');
      debugPrint('Status: ${e.response?.statusCode}');
      rethrow;
    }
  }

  // ── Authenticated: update own profile ────────────────────────────────────
  static Future<Map<String, dynamic>> updateProfile(FormData data) async {
    try {
      final res = await ApiService.upload(ApiConfig.profile, data);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('PhotographerService.updateProfile error: ${e.message}');
      rethrow;
    }
  }

  // ── Authenticated: upload portfolio images ───────────────────────────────
  static Future<Map<String, dynamic>> uploadPortfolio(FormData data) async {
    try {
      final res = await ApiService.upload(ApiConfig.portfolio, data);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('PhotographerService.uploadPortfolio error: ${e.message}');
      rethrow;
    }
  }

  // ── Authenticated: delete a portfolio item ───────────────────────────────
  static Future<void> deletePortfolioItem(int id) async {
    try {
      await ApiService.delete('${ApiConfig.portfolio}/$id');
    } on DioException catch (e) {
      debugPrint('PhotographerService.deletePortfolioItem error: ${e.message}');
      rethrow;
    }
  }

  // ── Authenticated: get own portfolio ─────────────────────────────────────
  static Future<List<dynamic>> getOwnPortfolio() async {
    try {
      final data = await getDashboard();
      return data['portfolio_analysis'] as List? ?? [];
    } catch (_) {
      return [];
    }
  }
}