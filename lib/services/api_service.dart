// lib/services/api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept':       'application/json',
      },
    ),
  );

  static void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          debugPrint('┌── API REQUEST ──────────────────────────');
          debugPrint('│ ${options.method} ${options.baseUrl}${options.path}');
          if (options.data != null) debugPrint('│ Body: ${options.data}');
          debugPrint('└─────────────────────────────────────────');

          return handler.next(options);
        },

        onResponse: (response, handler) {
          debugPrint('┌── API RESPONSE ─────────────────────────');
          debugPrint('│ Status: ${response.statusCode}');
          debugPrint('│ URL: ${response.requestOptions.path}');
          final body = response.data.toString();
          debugPrint('│ Data: ${body.substring(0, body.length > 300 ? 300 : body.length)}...');
          debugPrint('└─────────────────────────────────────────');
          return handler.next(response);
        },

        onError: (error, handler) async {
          debugPrint('┌── API ERROR ────────────────────────────');
          debugPrint('│ URL: ${error.requestOptions.path}');
          debugPrint('│ Status: ${error.response?.statusCode}');
          debugPrint('│ Message: ${error.message}');
          debugPrint('│ Response: ${error.response?.data}');
          debugPrint('└─────────────────────────────────────────');

          if (error.response?.statusCode == 401) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auth_token');
            await prefs.remove('user_data');
          }
          return handler.next(error);
        },
      ),
    );
  }

  static Future<Response> get(String endpoint,
          {Map<String, dynamic>? params}) =>
      _dio.get(endpoint, queryParameters: params);

  static Future<Response> post(String endpoint, {dynamic data}) =>
      _dio.post(endpoint, data: data);

  static Future<Response> put(String endpoint, {dynamic data}) =>
      _dio.put(endpoint, data: data);

  static Future<Response> patch(String endpoint, {dynamic data}) =>
      _dio.patch(endpoint, data: data);

  static Future<Response> delete(String endpoint) =>
      _dio.delete(endpoint);

  static Future<Response> upload(String endpoint, FormData formData) =>
      _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );
}