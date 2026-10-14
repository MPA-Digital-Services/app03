import 'package:flutter_test/flutter_test.dart';

import 'package:northwind_mobile/core/models/paged_result.dart';

void main() {
  group('PagedResult.fromJson', () {
    test('mapea la envoltura paginada de la API', () {
      final result = PagedResult<int>.fromJson(
        {
          'items': [1, 2, 3],
          'page': 2,
          'pageSize': 3,
          'totalCount': 9,
          'totalPages': 3,
          'hasNext': true,
          'hasPrevious': true,
        },
        (map) => map['x'] as int? ?? 0,
      );

      expect(result.page, 2);
      expect(result.pageSize, 3);
      expect(result.totalCount, 9);
      expect(result.totalPages, 3);
      expect(result.hasNext, isTrue);
      expect(result.hasPrevious, isTrue);
    });

    test('tolera banderas ausentes calculándolas', () {
      final result = PagedResult<String>.fromJson(
        {
          'items': ['a'],
          'page': 1,
          'pageSize': 1,
          'totalCount': 1,
        },
        (map) => map.values.first.toString(),
      );

      expect(result.totalPages, 1);
      expect(result.hasNext, isFalse);
      expect(result.hasPrevious, isFalse);
    });

    test('PagedResult.empty no tiene elementos', () {
      final empty = PagedResult.empty<dynamic>();
      expect(empty.isEmpty, isTrue);
      expect(empty.totalCount, 0);
    });
  });
}
