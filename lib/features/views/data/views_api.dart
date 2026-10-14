import '../../../core/models/paged_result.dart';
import '../../../core/network/api_client.dart';
import '../models/view_info.dart';

/// Acceso a las vistas de solo lectura de Northwind.
class ViewsApi {
  ViewsApi(this._api);

  final ApiClient _api;

  Future<List<ViewInfo>> catalog() async {
    final data = await _api.getJsonList('/api/views');
    return data
        .map((e) => ViewInfo.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<PagedResult<Map<String, dynamic>>> rows(
    String route, {
    int page = 1,
    int pageSize = 25,
  }) async {
    final data = await _api.getJson(route, query: {
      'page': page,
      'pageSize': pageSize,
    });
    return PagedResult.fromJson(data, (map) => map);
  }
}
