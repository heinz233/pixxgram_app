// lib/services/rating_service.dart

import 'api_service.dart';
import '../config/api_config.dart';

class RatingService {
  // ── POST /api/photographers/{id}/rate ────────────────────────────
  // Required: stars (1-5)
  // Optional: comment (max 500 chars)
  // Uses updateOrCreate — one rating per client per photographer
  static Future<Map<String, dynamic>> submit(
    int photographerId,
    int stars, {
    String? comment,
  }) async {
    final res = await ApiService.post(
      '${ApiConfig.photographers}/$photographerId/rate',
      data: {
        'stars':   stars,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
    return res.data;
  }

  // ── GET /api/photographers/{id}/ratings ──────────────────────────
  // Returns list of ratings with client name + user_image
  static Future<List<dynamic>> getForPhotographer(int photographerId) async {
    final res = await ApiService.get(
        '${ApiConfig.photographers}/$photographerId/ratings');
    final data = res.data;
    if (data is List) return data;
    return [];
  }
}