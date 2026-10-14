/// Metadatos de una vista de solo lectura (`/api/views`).
class ViewInfo {
  const ViewInfo({
    required this.route,
    required this.viewName,
    required this.description,
    required this.columns,
  });

  final String route;
  final String viewName;
  final String description;
  final List<String> columns;

  factory ViewInfo.fromJson(Map<String, dynamic> j) => ViewInfo(
        route: j['route']?.toString() ?? '',
        viewName: j['viewName']?.toString() ?? '',
        description: j['description']?.toString() ?? '',
        columns: ((j['columns'] as List?) ?? const [])
            .map((c) => c.toString())
            .toList(),
      );
}
