/// Envoltura estándar de resultados paginados devuelta por la API.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  bool get isEmpty => items.isEmpty;

  static PagedResult<T> empty<T>() => PagedResult<T>(
        items: const [],
        page: 1,
        pageSize: 20,
        totalCount: 0,
        totalPages: 0,
        hasNext: false,
        hasPrevious: false,
      );

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFactory,
  ) {
    final rawItems = (json['items'] as List?) ?? const [];
    final page = (json['page'] as num?)?.toInt() ?? 1;
    final pageSize = (json['pageSize'] as num?)?.toInt() ?? 20;
    final totalCount =
        (json['totalCount'] as num?)?.toInt() ?? rawItems.length;
    final totalPages = (json['totalPages'] as num?)?.toInt() ??
        (pageSize <= 0 ? 0 : (totalCount / pageSize).ceil());

    return PagedResult<T>(
      items: rawItems
          .whereType<Map>()
          .map((e) => itemFactory(e.cast<String, dynamic>()))
          .toList(),
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
      totalPages: totalPages,
      hasNext: (json['hasNext'] as bool?) ?? page < totalPages,
      hasPrevious: (json['hasPrevious'] as bool?) ?? page > 1,
    );
  }
}
