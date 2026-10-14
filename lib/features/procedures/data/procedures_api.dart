import '../../../core/network/api_client.dart';

/// Invoca procedimientos almacenados (respuestas no paginadas).
class ProceduresApi {
  ProceduresApi(this._api);

  final ApiClient _api;

  Future<List<Map<String, dynamic>>> invoke(String path) async {
    final data = await _api.getJsonList(path);
    return data
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
  }
}
