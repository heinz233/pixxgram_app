// lib/providers/photographer_provider.dart

import 'package:flutter/material.dart';
import '../services/photographer_service.dart';

class PhotographerProvider extends ChangeNotifier {
  List<dynamic> _photographers = [];
  Map<String, dynamic>? _selected;
  bool    _loading = false;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────────
  List<dynamic>         get photographers => _photographers;
  Map<String, dynamic>? get selected      => _selected;
  bool                  get loading       => _loading;
  String?               get error         => _error;

  // ── Fetch all photographers (with optional filters) ───────────────
  Future<void> fetchAll({Map<String, dynamic>? filters}) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final data = await PhotographerService.getAll(filters: filters);
      // handle both { photographers: { data: [] } } and { data: [] }
      _photographers =
          data['photographers']?['data'] ??
          data['photographers']          ??
          data['data']                   ??
          [];
    } catch (e) {
      _error = _parseError(e);
    } finally {
      _loading = false; notifyListeners();
    }
  }

  // ── Fetch single photographer ─────────────────────────────────────
  Future<void> fetchOne(int id) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final data = await PhotographerService.getById(id);
      _selected = data['photographer'] ?? data['data'] ?? data;
    } catch (e) {
      _error = _parseError(e);
    } finally {
      _loading = false; notifyListeners();
    }
  }

  void clearSelected() {
    _selected = null;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    try {
      return e.response?.data?['message'] ??
             e.response?.data?['error']   ??
             'Failed to load photographers.';
    } catch (_) {
      return 'Failed to load photographers.';
    }
  }
}