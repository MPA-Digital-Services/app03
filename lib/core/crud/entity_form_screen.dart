import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../network/api_exception.dart';
import '../utils/formatters.dart';
import '../widgets/app_scope.dart';
import 'crud_repository.dart';
import 'entity_spec.dart';
import 'field_spec.dart';

/// Formulario genérico de alta/edición para una [EntitySpec].
/// Si [item] es null se crea un registro nuevo; en caso contrario se edita.
class EntityFormScreen extends StatefulWidget {
  const EntityFormScreen({super.key, required this.spec, this.item});

  final EntitySpec spec;
  final Map<String, dynamic>? item;

  @override
  State<EntityFormScreen> createState() => _EntityFormScreenState();
}

class _EntityFormScreenState extends State<EntityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final CrudRepository _repository;
  late final List<FieldSpec> _fields;
  late final bool _isCreate;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _bools = {};
  final Map<String, dynamic> _dropdownValues = {};
  final Map<String, DateTime?> _dates = {};
  final Map<String, List<DropdownOption>> _options = {};
  final Set<String> _loadingOptions = {};

  bool _saving = false;

  EntitySpec get _spec => widget.spec;

  @override
  void initState() {
    super.initState();
    _isCreate = widget.item == null;
    _repository = CrudRepository(
      AppScope.of(context, listen: false).api,
      _spec.route,
    );
    _fields = _computeFields();
    _initializeValues();
    _loadOptions();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// En creación incluye la clave solo si la provee el cliente; en edición
  /// la clave nunca se envía (los DTO de actualización la excluyen).
  List<FieldSpec> _computeFields() {
    final list = <FieldSpec>[];
    if (_isCreate && _spec.idEditableOnCreate) {
      final idField = _spec.field(_spec.idField);
      if (idField != null) list.add(idField);
    }
    for (final f in _spec.formFields) {
      if (f.key == _spec.idField) continue;
      list.add(f);
    }
    return list;
  }

  void _initializeValues() {
    final item = widget.item ?? const {};
    for (final field in _fields) {
      final value = item[field.key];
      switch (field.type) {
        case FieldType.boolean:
          _bools[field.key] = value == true;
          break;
        case FieldType.date:
          final parsed = Fmt.parseDate(value);
          _dates[field.key] = parsed;
          _controllers[field.key] =
              TextEditingController(text: parsed == null ? '' : Fmt.date(parsed));
          break;
        case FieldType.dropdown:
          _dropdownValues[field.key] = value;
          if (field.options.isNotEmpty) {
            _options[field.key] = field.options;
          }
          break;
        case FieldType.text:
        case FieldType.multiline:
        case FieldType.integer:
        case FieldType.decimal:
          _controllers[field.key] =
              TextEditingController(text: value?.toString() ?? '');
          break;
      }
    }
  }

  Future<void> _loadOptions() async {
    final api = AppScope.of(context, listen: false).api;
    for (final field in _fields) {
      if (field.type != FieldType.dropdown) continue;
      if (field.options.isNotEmpty) {
        _options[field.key] = field.options;
        continue;
      }
      final loader = field.optionsLoader;
      if (loader == null) continue;

      setState(() => _loadingOptions.add(field.key));
      try {
        final loaded = await loader(api);
        if (!mounted) return;
        setState(() {
          _options[field.key] = loaded;
          _loadingOptions.remove(field.key);
          _sanitizeDropdown(field.key);
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _loadingOptions.remove(field.key));
      }
    }
  }

  /// Evita valores seleccionados que ya no existen entre las opciones.
  void _sanitizeDropdown(String key) {
    final value = _dropdownValues[key];
    if (value == null) return;
    final options = _options[key] ?? const [];
    final exists = options.any((o) => o.value.toString() == value.toString());
    if (!exists) _dropdownValues[key] = null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final body = _buildBody();
      if (_isCreate) {
        await _repository.create(body);
      } else {
        final id = widget.item![_spec.idField];
        await _repository.update(id!, body);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showError('No se pudo guardar: $e');
    }
  }

  Map<String, dynamic> _buildBody() {
    final body = <String, dynamic>{};
    for (final field in _fields) {
      switch (field.type) {
        case FieldType.boolean:
          body[field.key] = _bools[field.key] ?? false;
          break;
        case FieldType.date:
          body[field.key] = _dates[field.key]?.toIso8601String();
          break;
        case FieldType.dropdown:
          body[field.key] = _dropdownValues[field.key];
          break;
        case FieldType.integer:
          final text = _controllers[field.key]!.text.trim();
          body[field.key] = text.isEmpty ? null : int.tryParse(text);
          break;
        case FieldType.decimal:
          final text = _controllers[field.key]!.text.trim();
          body[field.key] =
              text.isEmpty ? null : num.tryParse(text)?.toDouble();
          break;
        case FieldType.text:
        case FieldType.multiline:
          final text = _controllers[field.key]!.text.trim();
          body[field.key] = text.isEmpty ? null : text;
          break;
      }
    }
    return body;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isCreate
        ? 'Nuevo ${_spec.singular ?? _spec.title}'
        : 'Editar ${_spec.singular ?? _spec.title}';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Guardar'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!_isCreate)
              _readOnlyIdBanner(),
            for (final field in _fields) ...[
              _buildField(field),
              const SizedBox(height: 14),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _readOnlyIdBanner() {
    final id = widget.item?[_spec.idField];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(Icons.badge_outlined,
              size: 18, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 8),
          Text(
            '${_spec.field(_spec.idField)?.label ?? 'ID'}: $id',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildField(FieldSpec field) {
    switch (field.type) {
      case FieldType.boolean:
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(field.label),
          value: _bools[field.key] ?? false,
          onChanged: field.editable
              ? (v) => setState(() => _bools[field.key] = v)
              : null,
        );
      case FieldType.date:
        return _buildDateField(field);
      case FieldType.dropdown:
        return _buildDropdownField(field);
      case FieldType.text:
      case FieldType.multiline:
      case FieldType.integer:
      case FieldType.decimal:
        return _buildTextFormField(field);
    }
  }

  Widget _buildTextFormField(FieldSpec field) {
    final isNumeric = field.isNumeric;
    final isDecimal = field.type == FieldType.decimal;
    return TextFormField(
      controller: _controllers[field.key],
      readOnly: !field.editable,
      maxLength: field.maxLength,
      maxLines: field.type == FieldType.multiline ? 4 : 1,
      keyboardType: isDecimal
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : isNumeric
              ? const TextInputType.numberWithOptions(signed: true)
              : TextInputType.text,
      inputFormatters: isDecimal
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,-]'))]
          : isNumeric
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9-]'))]
              : null,
      decoration: InputDecoration(
        labelText: field.label + (field.required ? ' *' : ''),
        helperText: field.helper,
        hintText: field.hint,
        counterText: '',
      ),
      validator: (value) => _validate(field, value),
    );
  }

  String? _validate(FieldSpec field, String? value) {
    final text = value?.trim() ?? '';
    if (field.required && text.isEmpty) {
      return 'Este campo es obligatorio.';
    }
    if (text.isEmpty) return null;
    if (field.type == FieldType.integer && int.tryParse(text) == null) {
      return 'Ingresa un número entero válido.';
    }
    if (field.type == FieldType.decimal && num.tryParse(text) == null) {
      return 'Ingresa un número válido.';
    }
    return null;
  }

  Widget _buildDateField(FieldSpec field) {
    return InkWell(
      onTap: field.editable ? () => _pickDate(field) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: field.label + (field.required ? ' *' : ''),
          helperText: field.helper,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_dates[field.key] != null && field.editable)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => setState(() {
                    _dates[field.key] = null;
                    _controllers[field.key]!.text = '';
                  }),
                ),
              const Icon(Icons.calendar_today, size: 18),
              const SizedBox(width: 8),
            ],
          ),
        ),
        child: Text(
          _dates[field.key] == null ? 'Sin fecha' : Fmt.date(_dates[field.key]),
          style: _dates[field.key] == null
              ? TextStyle(color: Theme.of(context).colorScheme.outline)
              : null,
        ),
      ),
    );
  }

  Future<void> _pickDate(FieldSpec field) async {
    final initial = _dates[field.key] ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _dates[field.key] = picked;
      _controllers[field.key] =
          TextEditingController(text: Fmt.date(picked));
    });
  }

  Widget _buildDropdownField(FieldSpec field) {
    if (_loadingOptions.contains(field.key)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: LinearProgressIndicator(),
      );
    }
    final options = _options[field.key] ?? field.options;
    final current = _dropdownValues[field.key];
    final hasCurrent =
        current == null || options.any((o) => o.value.toString() == current.toString());

    return DropdownButtonFormField<dynamic>(
      initialValue: hasCurrent ? current : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: field.label + (field.required ? ' *' : ''),
        helperText: field.helper,
      ),
      items: [
        if (!field.required)
          const DropdownMenuItem<dynamic>(value: null, child: Text('—')),
        for (final option in options)
          DropdownMenuItem<dynamic>(
            value: option.value,
            child: Text(option.label, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: field.editable
          ? (value) => setState(() => _dropdownValues[field.key] = value)
          : null,
      validator: (value) {
        if (field.required && value == null) {
          return 'Selecciona una opción.';
        }
        return null;
      },
    );
  }
}
