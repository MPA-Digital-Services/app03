import 'dart:async';

import 'package:flutter/material.dart';

import '../models/paged_result.dart';
import '../network/api_exception.dart';
import '../widgets/app_scope.dart';
import '../widgets/async_view.dart';
import 'crud_repository.dart';
import 'entity_form_screen.dart';
import 'entity_spec.dart';
import 'field_value.dart';

/// Pantalla genérica de listado CRUD para una [EntitySpec]: búsqueda,
/// paginación, alta, edición y borrado.
class EntityListScreen extends StatefulWidget {
  const EntityListScreen({super.key, required this.spec});

  final EntitySpec spec;

  @override
  State<EntityListScreen> createState() => _EntityListScreenState();
}

class _EntityListScreenState extends State<EntityListScreen> {
  late final CrudRepository _repository;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  int _page = 1;
  static const int _pageSize = 20;
  String _search = '';
  late Future<PagedResult<CrudItem>> _future;

  EntitySpec get _spec => widget.spec;

  @override
  void initState() {
    super.initState();
    _repository = CrudRepository(
      AppScope.of(context, listen: false).api,
      _spec.route,
    );
    _future = _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<PagedResult<CrudItem>> _load() {
    return _repository.list(
      page: _page,
      pageSize: _pageSize,
      search: _search,
      searchParam: _spec.searchParam,
      sort: _spec.sortParam,
      order: _spec.sortDir,
    );
  }

  Future<void> _reload({int? page}) async {
    setState(() {
      if (page != null) _page = page;
      _future = _load();
    });
    await _future;
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search = value;
      _reload(page: 1);
    });
  }

  Future<void> _openForm({Map<String, dynamic>? item}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EntityFormScreen(spec: _spec, item: item),
      ),
    );
    if (changed == true) {
      await _reload();
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> item) async {
    final id = item[_spec.idField];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text(
          '¿Deseas eliminar "${_title(item)}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _repository.delete(id!);
      if (!mounted) return;
      _showMessage('Registro eliminado.');
      await _reload();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showMessage(e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showMessage('No se pudo eliminar: $e', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? scheme.errorContainer : null,
      ),
    );
  }

  String _title(Map<String, dynamic> item) {
    final field = _spec.field(_spec.primaryField);
    if (field == null) return item[_spec.idField]?.toString() ?? '—';
    return displayValue(field, item[field.key]);
  }

  String _subtitle(Map<String, dynamic> item) {
    final parts = <String>[];
    for (final key in _spec.subtitleFields) {
      final field = _spec.field(key);
      if (field == null) continue;
      final value = displayValue(field, item[key]);
      if (value != '—') parts.add(value);
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_spec.title),
        actions: [
          IconButton(
            onPressed: () => _reload(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
          if (_spec.canCreate)
            IconButton(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add),
              tooltip: 'Agregar',
            ),
        ],
      ),
      body: Column(
        children: [
          if (_spec.searchParam != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: _spec.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _search = '';
                            _reload(page: 1);
                          },
                        ),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
          Expanded(
            child: AsyncView<PagedResult<CrudItem>>(
              future: _future,
              onRetry: () => _reload(),
              onData: (context, result) => _buildList(result),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(PagedResult<CrudItem> result) {
    if (result.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _reload(),
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: EmptyView(
                message: _search.isEmpty
                    ? 'No hay ${_spec.title.toLowerCase()}.'
                    : 'Sin resultados para "$_search".',
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _reload(),
            child: ListView.separated(
              itemCount: result.items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _buildTile(result.items[index]),
            ),
          ),
        ),
        _buildPager(result),
      ],
    );
  }

  Widget _buildTile(Map<String, dynamic> item) {
    final subtitle = _subtitle(item);
    final hasDetail = _spec.detailBuilder != null;
    return ListTile(
      title: Text(
        _title(item),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle.isEmpty
          ? null
          : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: hasDetail ? () => _openDetail(item) : () => _openForm(item: item),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'detail':
              _openDetail(item);
              break;
            case 'edit':
              _openForm(item: item);
              break;
            case 'delete':
              _confirmDelete(item);
              break;
          }
        },
        itemBuilder: (context) => [
          if (hasDetail)
            const PopupMenuItem(value: 'detail', child: Text('Ver detalle')),
          const PopupMenuItem(value: 'edit', child: Text('Editar')),
          if (_spec.canDelete)
            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
        ],
      ),
    );
  }

  void _openDetail(Map<String, dynamic> item) {
    final builder = _spec.detailBuilder!;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => builder(ctx, item)),
    );
  }

  Widget _buildPager(PagedResult<CrudItem> result) {
    final canPrev = result.hasPrevious;
    final canNext = result.hasNext;
    return Material(
      elevation: 3,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                onPressed: canPrev ? () => _reload(page: _page - 1) : null,
                icon: const Icon(Icons.chevron_left),
                tooltip: 'Anterior',
              ),
              Expanded(
                child: Text(
                  'Página ${result.page} de ${result.totalPages == 0 ? 1 : result.totalPages}'
                  ' · ${result.totalCount} registros',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              IconButton(
                onPressed: canNext ? () => _reload(page: _page + 1) : null,
                icon: const Icon(Icons.chevron_right),
                tooltip: 'Siguiente',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
