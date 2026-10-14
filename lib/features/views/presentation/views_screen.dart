import 'package:flutter/material.dart';

import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/async_view.dart';
import '../data/views_api.dart';
import '../models/view_info.dart';
import 'view_data_screen.dart';

/// Catálogo de las vistas de solo lectura.
class ViewsScreen extends StatefulWidget {
  const ViewsScreen({super.key});

  @override
  State<ViewsScreen> createState() => _ViewsScreenState();
}

class _ViewsScreenState extends State<ViewsScreen> {
  late final ViewsApi _api;
  late Future<List<ViewInfo>> _future;

  @override
  void initState() {
    super.initState();
    _api = ViewsApi(AppScope.of(context, listen: false).api);
    _future = _api.catalog();
  }

  Future<void> _reload() async {
    setState(() => _future = _api.catalog());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return AsyncView<List<ViewInfo>>(
      future: _future,
      onRetry: _reload,
      onData: (context, views) => RefreshIndicator(
        onRefresh: _reload,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 12),
          itemCount: views.length,
          itemBuilder: (context, index) {
            final view = views[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.grid_on_outlined),
                title: Text(view.viewName),
                subtitle: Text(
                  view.description.isEmpty
                      ? '${view.columns.length} columnas'
                      : '${view.description}\n${view.columns.length} columnas',
                ),
                isThreeLine: view.description.isNotEmpty,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ViewDataScreen(view: view),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
