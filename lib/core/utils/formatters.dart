/// Utilidades de formato (fechas y números) sin dependencias externas.
class Fmt {
  Fmt._();

  static String _two(int value) => value.toString().padLeft(2, '0');

  /// Agrupa la parte entera con separadores de miles (p. ej. 12345 -> 12,345).
  static String _group(String intPart) {
    final negative = intPart.startsWith('-');
    final digits = negative ? intPart.substring(1) : intPart;
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return '${negative ? '-' : ''}$buffer';
  }

  static String date(DateTime? value) {
    if (value == null) return '—';
    final d = value.toLocal();
    return '${_two(d.day)}/${_two(d.month)}/${d.year}';
  }

  static String dateTime(DateTime? value) {
    if (value == null) return '—';
    final d = value.toLocal();
    return '${_two(d.day)}/${_two(d.month)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';
  }

  static String number(num? value) {
    if (value == null) return '—';
    final negative = value < 0;
    final s = value.abs().round().toString();
    return '${negative ? '-' : ''}${_group(s)}';
  }

  static String money(num? value, {String symbol = '\$'}) {
    if (value == null) return '—';
    final negative = value < 0;
    final fixed = value.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    return '${negative ? '-' : ''}$symbol${_group(parts[0])}.${parts[1]}';
  }

  static String percent(double? value, {int decimals = 0}) {
    if (value == null) return '—';
    return '${(value * 100).toStringAsFixed(decimals)}%';
  }

  /// Intenta interpretar un valor dinámico (JSON) como fecha.
  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static String any(dynamic value) {
    if (value == null) return '—';
    if (value is bool) return value ? 'Sí' : 'No';
    if (value is num) return _group(value.abs().round().toString());
    final s = value.toString();
    return s.isEmpty ? '—' : s;
  }
}
