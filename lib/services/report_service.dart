// lib/services/report_service.dart

import 'api_service.dart';
import '../config/api_config.dart';

class ReportService {
  // Valid reasons as defined in ReportController
  static const List<String> validReasons = [
    'inappropriate_behavior',
    'scam_or_fraud',
    'no_show',
    'poor_quality',
    'harassment',
    'fake_profile',
    'other',
  ];

  // ── POST /api/photographers/{id}/report ──────────────────────────
  // Only clients (role_id = 3) can report
  // Required: reason (one of validReasons)
  // Optional: description (max 1000 chars)
  static Future<Map<String, dynamic>> submit({
    required int    photographerId,
    required String reason,
    String?         description,
  }) async {
    final res = await ApiService.post(
      '${ApiConfig.photographers}/$photographerId/report',
      data: {
        'reason': reason,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    return res.data;
  }

  // ── GET /api/my-reports ───────────────────────────────────────────
  // Returns client's own submitted reports with photographer info
  static Future<List<dynamic>> getMyReports() async {
    final res  = await ApiService.get(ApiConfig.myReports);
    final data = res.data;
    if (data is List) return data;
    return [];
  }
}