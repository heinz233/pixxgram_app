// lib/services/admin_service.dart

import 'api_service.dart';
import '../config/api_config.dart';

class AdminService {
  // ── GET /api/admin/dashboard ──────────────────────────────────────
  // Returns: { total_photographers, active_photographers, total_clients,
  //            pending_reports, total_revenue, monthly_revenue,
  //            total_bookings, completed_bookings }
  static Future<Map<String, dynamic>> getStats() async {
    final res = await ApiService.get(ApiConfig.adminDashboard);
    return res.data;
  }

  // ── GET /api/admin/photographers ──────────────────────────────────
  // Optional filter: ?status=active|suspended|banned
  // Returns paginated: { data: [...], total, per_page, ... }
  static Future<Map<String, dynamic>> getPhotographers({
    String? status,
  }) async {
    final res = await ApiService.get(
      ApiConfig.adminPhotographers,
      params: status != null ? {'status': status} : null,
    );
    return res.data;
  }

  // ── PATCH /api/admin/photographers/{id}/status ───────────────────
  // Required: status (active|suspended|banned)
  static Future<Map<String, dynamic>> updatePhotographerStatus(
      int id, String status) async {
    final res = await ApiService.patch(
      '${ApiConfig.adminPhotographers}/$id/status',
      data: {'status': status},
    );
    return res.data;
  }

  // ── POST /api/admin/photographers/{id}/subscription ───────────────
  // Required: action (force_delete|reactivate)
  static Future<Map<String, dynamic>> manageSubscription(
      int id, String action) async {
    final res = await ApiService.post(
      '${ApiConfig.adminPhotographers}/$id/subscription',
      data: {'action': action},
    );
    return res.data;
  }

  // Convenience shorthands
  static Future<Map<String, dynamic>> approvePhotographer(int id) =>
      manageSubscription(id, 'reactivate');
  static Future<Map<String, dynamic>> suspendPhotographer(int id) =>
      updatePhotographerStatus(id, 'suspended');

  // ── GET /api/admin/users ──────────────────────────────────────────
  // Optional: ?role=admin|photographer|client
  static Future<Map<String, dynamic>> getUsers({String? role}) async {
    final res = await ApiService.get(
      ApiConfig.adminUsers,
      params: role != null ? {'role': role} : null,
    );
    return res.data;
  }

  // ── PATCH /api/admin/users/{id}/toggle-active ─────────────────────
  static Future<Map<String, dynamic>> toggleUserActive(int id) async {
    final res = await ApiService.patch('${ApiConfig.adminUsers}/$id/toggle-active');
    return res.data;
  }

  // ── GET /api/admin/reports ────────────────────────────────────────
  // Optional: ?status=pending|resolved|dismissed
  static Future<Map<String, dynamic>> getReports({String? status}) async {
    final res = await ApiService.get(
      ApiConfig.adminReports,
      params: status != null ? {'status': status} : null,
    );
    return res.data;
  }

  // ── PATCH /api/admin/reports/{id}/resolve ─────────────────────────
  static Future<Map<String, dynamic>> resolveReport(int id) async {
    final res = await ApiService.patch('${ApiConfig.adminReports}/$id/resolve');
    return res.data;
  }

  // ── PATCH /api/admin/reports/{id}/dismiss ─────────────────────────
  static Future<Map<String, dynamic>> dismissReport(int id) async {
    final res = await ApiService.patch('${ApiConfig.adminReports}/$id/dismiss');
    return res.data;
  }

  // ── GET /api/admin/ratings ────────────────────────────────────────
  static Future<Map<String, dynamic>> getRatings({int? stars}) async {
    final res = await ApiService.get(
      ApiConfig.adminRatings,
      params: stars != null ? {'stars': stars.toString()} : null,
    );
    return res.data;
  }

  // ── DELETE /api/admin/ratings/{id} ───────────────────────────────
  static Future<Map<String, dynamic>> deleteRating(int id) async {
    final res = await ApiService.delete('${ApiConfig.adminRatings}/$id');
    return res.data;
  }

  // ── GET /api/admin/subscriptions ─────────────────────────────────
  static Future<Map<String, dynamic>> getSubscriptions() async {
    final res = await ApiService.get(ApiConfig.adminSubscriptions);
    return res.data;
  }

  // ── GET /api/admin/bookings ───────────────────────────────────────
  static Future<Map<String, dynamic>> getBookings() async {
    final res = await ApiService.get(ApiConfig.adminBookings);
    return res.data;
  }

  // ── Locations ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getLocations() async {
    final res = await ApiService.get(ApiConfig.adminLocations);
    return res.data;
  }

  static Future<Map<String, dynamic>> addLocation(
      String name, String region) async {
    final res = await ApiService.post(ApiConfig.adminLocations,
        data: {'name': name, 'region': region});
    return res.data;
  }

  // Alias for addLocation to resolve compile errors
  static Future<Map<String, dynamic>> createLocation({
    required String name,
    required String region,
  }) async {
    return addLocation(name, region);
  }

  static Future<Map<String, dynamic>> updateLocation(
      int id, Map<String, dynamic> data) async {
    final res = await ApiService.put(
      '${ApiConfig.adminLocations}/$id',
      data: data,
    );
    return res.data;
  }

  static Future<Map<String, dynamic>> deleteLocation(int id) async {
    final res = await ApiService.delete('${ApiConfig.adminLocations}/$id');
    return res.data;
  }

  // ── Categories ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getCategories() async {
    final res = await ApiService.get(ApiConfig.adminCategories);
    return res.data;
  }

  static Future<Map<String, dynamic>> addCategory(String name) async {
    final res = await ApiService.post(ApiConfig.adminCategories,
        data: {'name': name});
    return res.data;
  }

  static Future<Map<String, dynamic>> deleteCategory(int id) async {
    final res = await ApiService.delete('${ApiConfig.adminCategories}/$id');
    return res.data;
  }
}
