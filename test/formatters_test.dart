import 'package:flutter_test/flutter_test.dart';

import 'package:northwind_mobile/core/utils/formatters.dart';

void main() {
  group('Fmt.money', () {
    test('formatea importes con dos decimales y separador de miles', () {
      expect(Fmt.money(1234.5), r'$1,234.50');
      expect(Fmt.money(0), r'$0.00');
    });

    test('maneja valores nulos', () {
      expect(Fmt.money(null), '—');
    });
  });

  group('Fmt.number', () {
    test('agrupa miles', () {
      expect(Fmt.number(1234567), '1,234,567');
    });
  });

  group('Fmt.date', () {
    test('formatea como dd/MM/yyyy', () {
      expect(Fmt.date(DateTime(2024, 3, 7)), '07/03/2024');
      expect(Fmt.date(null), '—');
    });
  });

  group('Fmt.percent', () {
    test('convierte fracción a porcentaje', () {
      expect(Fmt.percent(0.15), '15%');
    });
  });

  group('Fmt.parseDate', () {
    test('interpreta cadenas ISO', () {
      final parsed = Fmt.parseDate('2024-03-07T00:00:00');
      expect(parsed, isNotNull);
      expect(parsed!.year, 2024);
      expect(parsed.month, 3);
      expect(parsed.day, 7);
    });

    test('devuelve null para valores no válidos', () {
      expect(Fmt.parseDate('n/d'), isNull);
      expect(Fmt.parseDate(null), isNull);
    });
  });
}
