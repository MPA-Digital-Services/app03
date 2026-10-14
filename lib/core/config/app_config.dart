import 'package:flutter/foundation.dart';

/// Configuración estática de la aplicación.
///
/// La URL base del backend se puede sobreescribir en tiempo de compilación con
/// `--dart-define=API_BASE_URL=http://mi-servidor:5297`. Si no se especifica, se
/// detecta un valor por defecto útil para desarrollo:
/// - Android (emulador): `http://10.0.2.2:5297` (alias del host).
/// - Resto (web/escritorio/iOS simulador): `http://localhost:5297`.
class AppConfig {
  AppConfig._();

  static const String _dartDefineBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const int defaultPort = 5297;

  static String get defaultBaseUrl {
    if (_dartDefineBaseUrl.isNotEmpty) return _dartDefineBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$defaultPort';
    }
    return 'http://localhost:$defaultPort';
  }

  static const String appName = 'Northwind Móvil';
}
