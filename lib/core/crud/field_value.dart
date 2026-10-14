import '../utils/formatters.dart';
import 'field_spec.dart';

/// Devuelve el texto a mostrar para el valor de un campo en la lista,
/// resolviendo etiquetas de desplegables y formatos de fecha/importe.
String displayValue(FieldSpec field, dynamic value) {
  if (value == null) return '—';

  switch (field.type) {
    case FieldType.boolean:
      return value == true ? 'Sí' : 'No';
    case FieldType.date:
      return Fmt.date(Fmt.parseDate(value));
    case FieldType.integer:
      return Fmt.any(value);
    case FieldType.decimal:
      final num? n = value is num ? value : num.tryParse(value.toString());
      return field.money ? Fmt.money(n) : Fmt.any(n);
    case FieldType.dropdown:
      for (final option in field.options) {
        if (option.value.toString() == value.toString()) return option.label;
      }
      return Fmt.any(value);
    case FieldType.text:
    case FieldType.multiline:
      final text = value.toString();
      return text.isEmpty ? '—' : text;
  }
}
