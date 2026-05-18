// lib/services/photographer_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../config/api_config.dart';

// Base URL without /api suffix — for building storage URLs
const String _storageBase = 'http://192.168.100.8:8000';

/// Builds a full URL from any path format Laravel might return.
/// Handles: full URLs, /storage/... paths, storage/... paths, bare paths.
String buildStorageUrl(String? path) {
  if (path == null || path.trim().isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  if (path.startsWith('/storage/')) return '$_storageBase$path';
  if (path.startsWith('storage/'))  return '$_storageBase/$path';
  return '$_storageBase/storage/$path';
}

class PhotographerService {
  // ── GET /photographers  (public) ──────────────────────────────────
  static Future<Map<String, dynamic>> getAll({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final res  = await ApiService.get(ApiConfig.photographers, params: filters);
      final data = res.data;
      if (data is Map) {
        // paginated: { data: [...] }
        if (data['data'] is List) return {'photographers': data['data'], 'meta': data};
        // wrapped: { photographers: [...] }
        if (data['photographers'] is List) return Map<String, dynamic>.from(data);
        if (data['photographers'] is Map && data['photographers']['data'] is List) {
          return {'photographers': data['photographers']['data']};
        }
      }
      return data is Map ? Map<String, dynamic>.from(data) : {};
    } on DioException catch (e) {
      debugPrint('getAll error ${e.response?.statusCode}: ${e.response?.data}');
      rethrow;
    }
  }

  // ── GET /photographers/{id}  (public) ────────────────────────────
  // Vue reads: data.photographer_profile, data.portfolios, data.ratings_received
  // Flutter normalises to: { photographer, portfolio, reviews }
  static Future<Map<String, dynamic>> getById(int id) async {
    try {
      final res  = await ApiService.get('${ApiConfig.photographers}/$id');
      final data = res.data as Map<String, dynamic>;

      // The response IS the photographer object directly
      final portfolios      = data['portfolios']       as List? ?? [];
      final ratingsReceived = data['ratings_received'] as List? ?? [];

      // Normalise ratings — add flat client_name for easy display
      final reviews = ratingsReceived.map((r) {
        return <String, dynamic>{
          ...Map<String, dynamic>.from(r),
          'client_name': r['client']?['name'] ?? 'Anonymous',
        };
      }).toList();

      return {
        'photographer': data,
        'portfolio':    portfolios,
        'reviews':      reviews,
      };
    } on DioException catch (e) {
      debugPrint('getById($id) error ${e.response?.statusCode}: ${e.response?.data}');
      rethrow;
    }
  }

  // ── GET /photographer/dashboard  (auth) ───────────────────────────
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final res = await ApiService.get(ApiConfig.dashboard);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('getDashboard error: ${e.message}');
      rethrow;
    }
  }

  // ── PUT /photographer/profile  (auth) ────────────────────────────
  // Vue uses PUT with JSON; multipart handled by upload()
  static Future<Map<String, dynamic>> updateProfile(FormData data) async {
    try {
      final res = await ApiService.upload(ApiConfig.profile, data);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('updateProfile error: ${e.message}');
      rethrow;
    }
  }

  // ── POST /photographer/portfolio  (auth, multipart) ───────────────
  static Future<Map<String, dynamic>> uploadPortfolio(FormData data) async {
    try {
      final res = await ApiService.upload(ApiConfig.portfolio, data);
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('uploadPortfolio error: ${e.message}');
      rethrow;
    }
  }

  // ── DELETE /photographer/portfolio/{id}  (auth) ───────────────────
  static Future<void> deletePortfolioItem(int id) async {
    try {
      await ApiService.delete('${ApiConfig.portfolio}/$id');
    } on DioException catch (e) {
      debugPrint('deletePortfolioItem error: ${e.message}');
      rethrow;
    }
  }

  // ── POST /photographers/{id}/rate  (auth, client only) ────────────
  static Future<Map<String, dynamic>> rate(
      int photographerId, int stars, {String? comment}) async {
    try {
      final res = await ApiService.post(
        '${ApiConfig.photographers}/$photographerId/rate',
        data: {
          'stars': stars,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('rate error: ${e.message}');
      rethrow;
    }
  }

  // ── GET /photographers/{id}/ratings  (public) ─────────────────────
  static Future<List<dynamic>> getRatings(int photographerId) async {
    try {
      final res  = await ApiService.get(
          '${ApiConfig.photographers}/$photographerId/ratings');
      final data = res.data;
      if (data is List) return data;
      return [];
    } on DioException catch (e) {
      debugPrint('getRatings error: ${e.message}');
      rethrow;
    }
  }
}