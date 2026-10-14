import 'package:flutter/widgets.dart';

import '../config/app_settings.dart';
import '../network/api_client.dart';

/// Inyecta las dependencias de la aplicación ([ApiClient] y [AppSettings])
/// por el árbol de widgets.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.api,
    required this.settings,
    required super.child,
  });

  final ApiClient api;
  final AppSettings settings;

  /// Obtiene el ámbito. Con `listen: false` no registra dependencia y por tanto
  /// puede usarse dentro de `initState`.
  static AppScope of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<AppScope>()
        : context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope no encontrado en el árbol de widgets.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      oldWidget.api != api || oldWidget.settings != settings;
}
