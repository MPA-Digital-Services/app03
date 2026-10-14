import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:northwind_mobile/core/network/api_exception.dart';

void main() {
  group('ApiException.fromResponse', () {
    test('extrae detail de ProblemDetails', () {
      final body = utf8.encode(jsonEncode({
        'title': 'Error de validación',
        'detail': 'CategoryName es obligatorio.',
        'status': 400,
      }));

      final exception = ApiException.fromResponse(400, body);

      expect(exception.statusCode, 400);
      expect(exception.message, 'CategoryName es obligatorio.');
      expect(exception.isValidation, isTrue);
    });

    test('recoge errores por campo', () {
      final body = utf8.encode(jsonEncode({
        'title': 'Validación',
        'errors': {
          'categoryName': ['Requerido'],
        },
      }));

      final exception = ApiException.fromResponse(400, body);

      expect(exception.fieldErrors['categoryName'], ['Requerido']);
    });

    test('usa mensaje por defecto con cuerpo vacío', () {
      final exception = ApiException.fromResponse(404, const []);

      expect(exception.isNotFound, isTrue);
      expect(exception.message, contains('404'));
    });

    test('ApiException.network no tiene código', () {
      final exception = ApiException.network('sin conexión');
      expect(exception.isNetwork, isTrue);
      expect(exception.statusCode, isNull);
    });
  });
}
