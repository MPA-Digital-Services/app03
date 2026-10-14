import 'package:flutter/material.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/section_card.dart';

/// Ajustes de la aplicación: dirección del backend y prueba de conexión.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _controller = TextEditingController();
  bool _testing = false;
  String? _testResult;
  bool _testOk = false;

  @override
  void initState() {
    super.initState();
    _controller.text = AppScope.of(context, listen: false).settings.baseUrl;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final settings = AppScope.of(context, listen: false).settings;
    await settings.setBaseUrl(_controller.text);
    if (!mounted) return;
    setState(() => _controller.text = settings.baseUrl);
    _showMessage('Dirección guardada: ${settings.baseUrl}');
  }

  Future<void> _reset() async {
    final settings = AppScope.of(context, listen: false).settings;
    await settings.resetBaseUrl();
    if (!mounted) return;
    setState(() => _controller.text = settings.baseUrl);
    _showMessage('Dirección restablecida.');
  }

  Future<void> _testConnection() async {
    final api = AppScope.of(context, listen: false).api;
    setState(() {
      _testing = true;
      _testResult = null;
    });
    try {
      final data = await api.getJson('/health');
      if (!mounted) return;
      setState(() {
        _testOk = true;
        _testing = false;
        _testResult = 'Conexión correcta. Respuesta: $data';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _testOk = false;
        _testing = false;
        _testResult = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testOk = false;
        _testing = false;
        _testResult = 'Error: $e';
      });
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SectionCard(
            title: 'Servidor backend',
            subtitle: 'Dirección base de NorthwindApi',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'URL base',
                    hintText: 'http://localhost:5297',
                    prefixIcon: Icon(Icons.dns_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _testing ? null : _testConnection,
                      icon: _testing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.wifi_tethering),
                      label: const Text('Probar conexión'),
                    ),
                    TextButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.restore),
                      label: const Text('Restablecer'),
                    ),
                  ],
                ),
                if (_testResult != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _testOk
                          ? scheme.primaryContainer
                          : scheme.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_testResult!),
                  ),
                ],
              ],
            ),
          ),
          SectionCard(
            title: 'Sugerencias de dirección',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _Hint('Emulador Android', 'http://10.0.2.2:5297'),
                _Hint('Web / escritorio / iOS', 'http://localhost:5297'),
                _Hint('Dispositivo físico', 'http://IP-DE-TU-PC:5297'),
              ],
            ),
          ),
          SectionCard(
            title: 'Acerca de',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow('Aplicación', AppConfig.appName),
                _InfoRow('Puerto por defecto', '${AppConfig.defaultPort}'),
                _InfoRow('API', 'NorthwindApi (ASP.NET Core)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}
