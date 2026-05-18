// lib/services/admin_service.dart

import 'api_service.dart';
import '../config/api_config.dart';

class AdminService {
  // ── Dashboard ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getStats() async {
    final res = await ApiService.get(ApiConfig.adminDashboard);
    return res.data;
  }

  // ── Photographers ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getPhotographers({String? status}) async {
    final res = await ApiService.get(ApiConfig.adminPhotographers,
        params: status != null ? {'status': status} : null);
    return res.data;
  }

  static Future<Map<String, dynamic>> updatePhotographerStatus(
      int id, String status) async {
    final res = await ApiService.patch(
        '${ApiConfig.adminPhotographers}/$id/status',
        data: {'status': status});
    return res.data;
  }

  static Future<Map<String, dynamic>> manageSubscription(
      int id, String action) async {
    final res = await ApiService.post(
        '${ApiConfig.adminPhotographers}/$id/subscription',
        data: {'action': action});
    return res.data;
  }

  static Future<Map<String, dynamic>> approvePhotographer(int id) =>
      manageSubscription(id, 'reactivate');
  static Future<Map<String, dynamic>> suspendPhotographer(int id) =>
      updatePhotographerStatus(id, 'suspended');

  // ── Users ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getUsers({String? role}) async {
    final res = await ApiService.get(ApiConfig.adminUsers,
        params: role != null ? {'role': role} : null);
    return res.data;
  }

  static Future<Map<String, dynamic>> toggleUserActive(int id) async {
    final res = await ApiService.patch(
        '${ApiConfig.adminUsers}/$id/toggle-active');
    return res.data;
  }

  // ── Reports ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getReports({String? status}) async {
    final res = await ApiService.get(ApiConfig.adminReports,
        params: status != null ? {'status': status} : null);
    return res.data;
  }

  static Future<Map<String, dynamic>> resolveReport(int id) async {
    final res = await ApiService.patch('${ApiConfig.adminReports}/$id/resolve');
    return res.data;
  }

  static Future<Map<String, dynamic>> dismissReport(int id) async {
    final res = await ApiService.patch('${ApiConfig.adminReports}/$id/dismiss');
    return res.data;
  }

  // ── Ratings ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getRatings({int? stars}) async {
    final res = await ApiService.get(ApiConfig.adminRatings,
        params: stars != null ? {'stars': stars.toString()} : null);
    return res.data;
  }

  static Future<Map<String, dynamic>> deleteRating(int id) async {
    final res = await ApiService.delete('${ApiConfig.adminRatings}/$id');
    return res.data;
  }

  // ── Subscriptions ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getSubscriptions(
      {Map<String, dynamic>? params}) async {
    final res = await ApiService.get(ApiConfig.adminSubscriptions,
        params: params);
    return res.data;
  }

  // ── Bookings ───────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getBookings(
      {Map<String, dynamic>? params}) async {
    final res = await ApiService.get(ApiConfig.adminBookings, params: params);
    return res.data;
  }

  // ── Locations ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getLocations() async {
    final res = await ApiService.get(ApiConfig.adminLocations);
    return res.data;
  }

  // POST /admin/locations  { name, region }
  static Future<void> createLocation({
    required String name,
    String? region,
  }) async {
    final data = {
      'name': name,
      if (region != null && region.trim().isNotEmpty) 'region': region.trim(),
    };
    final res = await ApiService.post(ApiConfig.adminLocations, data: data);
    return res.data;
  }

  // PUT /admin/locations/{id}
  static Future<Map<String, dynamic>> updateLocation(
      int id, Map<String, dynamic> data) async {
    final res = await ApiService.put(
        '${ApiConfig.adminLocations}/$id', data: data);
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

  // POST /admin/categories  { name }
  static Future<Map<String, dynamic>> createCategory(
      Map<String, dynamic> data) async {
    final res = await ApiService.post(ApiConfig.adminCategories, data: data);
    return res.data;
  }

  // PUT /admin/categories/{id}
  static Future<Map<String, dynamic>> updateCategory(
      int id, Map<String, dynamic> data) async {
    final res = await ApiService.put(
        '${ApiConfig.adminCategories}/$id', data: data);
    return res.data;
  }

  static Future<Map<String, dynamic>> deleteCategory(int id) async {
    final res = await ApiService.delete('${ApiConfig.adminCategories}/$id');
    return res.data;
  }
}