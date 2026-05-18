// lib/services/report_service.dart

import 'api_service.dart';
import '../config/api_config.dart';

class ReportService {
  // Exact reason values from Vue ReportDialog.vue
  static const List<Map<String, String>> reasons = [
    {'label': '🚫 Inappropriate behavior', 'value': 'inappropriate_behavior'},
    {'label': '💸 Scam or fraud',           'value': 'scam_or_fraud'},
    {'label': "🚶 No-show / didn't arrive", 'value': 'no_show'},
    {'label': '📷 Poor quality work',       'value': 'poor_quality'},
    {'label': '😡 Harassment',              'value': 'harassment'},
    {'label': '🎭 Fake profile',            'value': 'fake_profile'},
    {'label': '❓ Other',                   'value': 'other'},
  ];

  // POST /photographers/{id}/report
  // { reason, description? }
  // 409 = already have a pending report against this photographer
  // 403 = only clients can report
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

  // GET /my-reports
  static Future<List<dynamic>> getMyReports() async {
    final res  = await ApiService.get(ApiConfig.myReports);
    final data = res.data;
    if (data is List) return data;
    return [];
  }
}