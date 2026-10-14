import '../models/paged_result.dart';
import '../network/api_client.dart';

/// Un elemento CRUD representado como mapa JSON dinámico.
typedef CrudItem = Map<String, dynamic>;

/// Repositorio genérico sobre los controladores CRUD de la API
/// (`/api/{entidad}`). Devuelve mapas para no exigir un tipo por entidad.
class CrudRepository {
  CrudRepository(this._api, this._route);

  final ApiClient _api;
  final String _route;

  String _seg(Object id) => Uri.encodeComponent(id.toString());

  Future<PagedResult<CrudItem>> list({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? searchParam,
    String? sort,
    String? order,
    Map<String, dynamic>? filters,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
    };

    if (search != null &&
        search.trim().isNotEmpty &&
        searchParam != null &&
        searchParam.isNotEmpty) {
      query[searchParam] = search.trim();
    }

    if (sort != null && sort.isNotEmpty) {
      query['sort'] = sort;
      query['order'] = order ?? 'asc';
    }

    filters?.forEach((key, value) {
      if (value != null) query[key] = value;
    });

    final data = await _api.getJson(_route, query: query);
    return PagedResult.fromJson(data, (map) => map);
  }

  Future<CrudItem> getById(Object id) async {
    final data = await _api.getJson('$_route/${_seg(id)}');
    return (data as Map).cast<String, dynamic>();
  }

  Future<CrudItem> create(Map<String, dynamic> body) async {
    final data = await _api.postJson(_route, body);
    return (data as Map).cast<String, dynamic>();
  }

  Future<void> update(Object id, Map<String, dynamic> body) async {
    await _api.putJson('$_route/${_seg(id)}', body);
  }

  Future<void> delete(Object id) async {
    await _api.delete('$_route/${_seg(id)}');
  }
}
