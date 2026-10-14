import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scope.dart';
import '../data/procedures_api.dart';
import '../models/procedures_catalog.dart';

/// Catálogo de procedimientos almacenados.
class ProceduresScreen extends StatelessWidget {
  const ProceduresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      children: [
        for (final spec in ProceduresCatalog.all)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.tertiaryContainer,
                child: Icon(
                  Icons.play_circle_outline,
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
              title: Text(spec.title),
              subtitle: Text(spec.description),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProcedureRunnerScreen(spec: spec),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Formulario de parámetros y resultados de un procedimiento.
class ProcedureRunnerScreen extends StatefulWidget {
  const ProcedureRunnerScreen({super.key, required this.spec});

  final ProcSpec spec;

  @override
  State<ProcedureRunnerScreen> createState() => _ProcedureRunnerScreenState();
}

class _ProcedureRunnerScreenState extends State<ProcedureRunnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, DateTime?> _dates = {};
  late final ProceduresApi _api;

  List<Map<String, dynamic>>? _results;
  bool _loading = false;
  String? _error;

  ProcSpec get _spec => widget.spec;

  @override
  void initState() {
    super.initState();
    _api = ProceduresApi(AppScope.of(context, listen: false).api);
    for (final param in _spec.params) {
      if (param.type == ProcParamType.date) {
        _dates[param.name] = null;
      } else {
        _controllers[param.name] =
            TextEditingController(text: param.defaultValue ?? '');
      }
    }
    if (_spec.params.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _run());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _run() async {
    if (!_formKey.currentState!.validate()) return;

    final values = <String, String>{};
    for (final param in _spec.params) {
      if (param.type == ProcParamType.date) {
        final date = _dates[param.name];
        if (date != null) values[param.name] = date.toIso8601String();
      } else {
        values[param.name] = _controllers[param.name]!.text.trim();
      }
    }

    setState(() {
      _loading = true;
      _error = null;
      _results = null;
    });

    try {
      final data = await _api.invoke(_spec.buildPath(values));
      if (!mounted) return;
      setState(() {
        _results = data;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo ejecutar: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_spec.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_spec.description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                for (final param in _spec.params) ...[
                  _buildParam(param),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _loading ? null : _run,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_arrow),
            label: Text(_loading ? 'Ejecutando...' : 'Ejecutar'),
          ),
          const SizedBox(height: 20),
          if (_error != null) _errorBox(_error!),
          if (_results != null) _resultsSection(_results!),
        ],
      ),
    );
  }

  Widget _buildParam(ProcParam param) {
    if (param.type == ProcParamType.date) {
      final date = _dates[param.name];
      return InkWell(
        onTap: () => _pickDate(param),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: param.displayLabel + (param.required ? ' *' : ''),
            helperText: param.helper,
            suffixIcon: const Icon(Icons.calendar_today, size: 18),
          ),
          child: Text(
            date == null ? 'Seleccionar fecha' : Fmt.date(date),
            style: date == null
                ? TextStyle(color: Theme.of(context).colorScheme.outline)
                : null,
          ),
        ),
      );
    }

    return TextFormField(
      controller: _controllers[param.name],
      keyboardType: param.type == ProcParamType.integer
          ? TextInputType.number
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: param.displayLabel + (param.required ? ' *' : ''),
        helperText: param.helper,
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (param.required && text.isEmpty) return 'Campo obligatorio.';
        if (param.type == ProcParamType.integer &&
            text.isNotEmpty &&
            int.tryParse(text) == null) {
          return 'Número entero inválido.';
        }
        return null;
      },
    );
  }

  Future<void> _pickDate(ProcParam param) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dates[param.name] ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _dates[param.name] = picked);
  }

  Widget _errorBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message),
    );
  }

  Widget _resultsSection(List<Map<String, dynamic>> rows) {
    if (rows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('El procedimiento no devolvió filas.')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Resultados (${rows.length})',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (var i = 0; i < rows.length; i++) _resultCard(i, rows[i]),
      ],
    );
  }

  Widget _resultCard(int index, Map<String, dynamic> row) {
    final columns =
        _spec.columns.isNotEmpty ? _spec.columns : row.keys.toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#${index + 1}',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 6),
            for (final column in columns)
              if (row.containsKey(column)) _kv(_humanize(column), _format(row[column])),
          ],
        ),
      ),
    );
  }

  Widget _kv(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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

  String _format(dynamic value) {
    if (value == null) return '—';
    if (value is bool) return value ? 'Sí' : 'No';
    if (value is num) return Fmt.number(value);
    final text = value.toString();
    final date = DateTime.tryParse(text);
    if (date != null && text.contains('-')) return Fmt.date(date);
    return text.isEmpty ? '—' : text;
  }

  String _humanize(String key) {
    final buffer = StringBuffer();
    for (var i = 0; i < key.length; i++) {
      final char = key[i];
      if (i > 0 && char == char.toUpperCase() && char != char.toLowerCase()) {
        buffer.write(' ');
      }
      buffer.write(i == 0 ? char.toUpperCase() : char);
    }
    return buffer.toString();
  }
}
