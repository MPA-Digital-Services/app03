import 'package:flutter/material.dart';

import 'app/home_shell.dart';
import 'core/config/app_config.dart';
import 'core/config/app_settings.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = AppSettings();
  await settings.load();

  final api = ApiClient(baseUrl: settings.baseUrl);
  settings.addListener(() => api.baseUrl = settings.baseUrl);

  runApp(NorthwindApp(api: api, settings: settings));
}

class NorthwindApp extends StatelessWidget {
  const NorthwindApp({
    super.key,
    required this.api,
    required this.settings,
  });

  final ApiClient api;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      api: api,
      settings: settings,
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const HomeShell(),
      ),
    );
  }
}
