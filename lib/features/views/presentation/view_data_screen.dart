import 'package:flutter/material.dart';

import '../../../core/models/paged_result.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/async_view.dart';
import '../data/views_api.dart';
import '../models/view_info.dart';

/// Muestra las filas de una vista como tarjetas columna/valor, con paginación.
class ViewDataScreen extends StatefulWidget {
  const ViewDataScreen({super.key, required this.view});

  final ViewInfo view;

  @override
  State<ViewDataScreen> createState() => _ViewDataScreenState();
}

class _ViewDataScreenState extends State<ViewDataScreen> {
  late final ViewsApi _api;
  late Future<PagedResult<Map<String, dynamic>>> _future;
  int _page = 1;
  static const int _pageSize = 25;

  @override
  void initState() {
    super.initState();
    _api = ViewsApi(AppScope.of(context, listen: false).api);
    _future = _load();
  }

  Future<PagedResult<Map<String, dynamic>>> _load() =>
      _api.rows('/api/views/${widget.view.route}',
          page: _page, pageSize: _pageSize);

  Future<void> _reload({int? page}) async {
    setState(() {
      if (page != null) _page = page;
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.view.viewName),
        actions: [
          IconButton(
            onPressed: () => _reload(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AsyncView<PagedResult<Map<String, dynamic>>>(
        future: _future,
        onRetry: () => _reload(),
        onData: (context, result) {
          if (result.isEmpty) {
            return const EmptyView(message: 'La vista no devolvió filas.');
          }
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _reload(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: result.items.length,
                    itemBuilder: (context, index) =>
                        _rowCard(index, result.items[index]),
                  ),
                ),
              ),
              _pager(result),
            ],
          );
        },
      ),
    );
  }

  Widget _rowCard(int index, Map<String, dynamic> row) {
    // Las columnas del catálogo usan PascalCase; el JSON llega en camelCase.
    final lookup = {
      for (final entry in row.entries) entry.key.toLowerCase(): entry.key,
    };
    final expected = widget.view.columns;
    final orderedKeys = <String>[
      for (final column in expected)
        if (lookup[column.toLowerCase()] != null) lookup[column.toLowerCase()]!,
      for (final key in row.keys)
        if (!expected.any((c) => c.toLowerCase() == key.toLowerCase())) key,
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Registro ${(_page - 1) * _pageSize + index + 1}',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            for (final key in orderedKeys)
              _kv(_humanize(key), _format(row[key])),
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
            width: 150,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _format(dynamic value) {
    if (value == null) return '—';
    if (value is bool) return value ? 'Sí' : 'No';
    if (value is num) return Fmt.number(value);
    final date = DateTime.tryParse(value.toString());
    if (date != null && value.toString().contains('-')) {
      return Fmt.date(date);
    }
    final text = value.toString();
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

  Widget _pager(PagedResult<Map<String, dynamic>> result) {
    return Material(
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                onPressed:
                    result.hasPrevious ? () => _reload(page: _page - 1) : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  'Página ${result.page} de ${result.totalPages == 0 ? 1 : result.totalPages}'
                  ' · ${result.totalCount} filas',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              IconButton(
                onPressed: result.hasNext ? () => _reload(page: _page + 1) : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
