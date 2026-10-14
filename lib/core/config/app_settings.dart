import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import 'app_config.dart';

/// Preferencias de la aplicación (por ahora, la URL base del backend),
/// persistidas con [SharedPreferences].
class AppSettings extends ChangeNotifier {
  AppSettings({String? initialBaseUrl})
      : _baseUrl = (initialBaseUrl != null && initialBaseUrl.isNotEmpty)
            ? ApiClient.normalizeBaseUrl(initialBaseUrl)
            : AppConfig.defaultBaseUrl;

  static const String _prefsKey = 'api_base_url';

  String _baseUrl;
  String get baseUrl => _baseUrl;

  bool get isDefault => _baseUrl == AppConfig.defaultBaseUrl;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      if (stored != null && stored.trim().isNotEmpty) {
        _baseUrl = ApiClient.normalizeBaseUrl(stored);
        notifyListeners();
      }
    } catch (_) {
      // Si no hay persistencia disponible, se mantiene el valor por defecto.
    }
  }

  Future<void> setBaseUrl(String value) async {
    final normalized = ApiClient.normalizeBaseUrl(value);
    final effective = normalized.isEmpty ? AppConfig.defaultBaseUrl : normalized;
    if (effective == _baseUrl) return;
    _baseUrl = effective;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, effective);
    } catch (_) {
      // Se ignora el error de persistencia.
    }
  }

  Future<void> resetBaseUrl() async {
    _baseUrl = AppConfig.defaultBaseUrl;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {
      // Se ignora el error de persistencia.
    }
  }
}
