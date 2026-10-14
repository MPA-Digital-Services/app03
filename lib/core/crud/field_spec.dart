import '../../../core/network/api_client.dart';

/// Tipo de control que representa un campo en el formulario.
enum FieldType { text, multiline, integer, decimal, boolean, date, dropdown }

/// Opción de un campo [FieldType.dropdown].
class DropdownOption {
  const DropdownOption(this.value, this.label);

  /// Valor enviado a la API (int para ids numéricos, String para ids de texto).
  final Object value;
  final String label;
}

/// Carga perezosa de opciones para un desplegable dependiente de datos.
typedef OptionsLoader = Future<List<DropdownOption>> Function(ApiClient api);

/// Descripción declarativa de un campo de una entidad. Permite renderizar tanto
/// la lista como el formulario sin código específico por entidad.
class FieldSpec {
  const FieldSpec({
    required this.key,
    required this.label,
    this.type = FieldType.text,
    this.required = false,
    this.editable = true,
    this.inList = true,
    this.inForm = true,
    this.money = false,
    this.maxLength,
    this.helper,
    this.hint,
    this.options = const [],
    this.optionsLoader,
  });

  final String key;
  final String label;
  final FieldType type;

  /// Si el valor es obligatorio (no puede ser nulo o vacío).
  final bool required;

  /// Si es false, el campo se muestra como solo lectura en el formulario.
  final bool editable;

  /// Si aparece en la pantalla de lista.
  final bool inList;

  /// Si aparece en el formulario de alta/edición.
  final bool inForm;

  /// Formatea el valor como importe monetario en la lista.
  final bool money;

  final int? maxLength;
  final String? helper;
  final String? hint;
  final List<DropdownOption> options;
  final OptionsLoader? optionsLoader;

  bool get isNumeric =>
      type == FieldType.integer || type == FieldType.decimal;
}
