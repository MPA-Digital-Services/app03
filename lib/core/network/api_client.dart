import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Cliente HTTP fino sobre la API NorthwindApi.
///
/// Se encarga de: componer la URL base + ruta + query, serializar JSON,
/// deserializar respuestas y traducir errores a [ApiException].
class ApiClient {
  ApiClient({required String baseUrl, http.Client? httpClient})
      : _baseUrl = normalizeBaseUrl(baseUrl),
        _http = httpClient ?? http.Client();

  final http.Client _http;
  String _baseUrl;

  Duration timeout = const Duration(seconds: 30);

  String get baseUrl => _baseUrl;
  set baseUrl(String value) => _baseUrl = normalizeBaseUrl(value);

  static String normalizeBaseUrl(String value) {
    var s = value.trim();
    if (s.isEmpty) return s;
    if (!s.startsWith('http://') && !s.startsWith('https://')) {
      s = 'http://$s';
    }
    while (s.endsWith('/')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=utf-8',
  };

  Uri _build(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse('$_baseUrl$path');
    if (query == null || query.isEmpty) return base;

    final params = <String, String>{...base.queryParameters};
    query.forEach((key, value) {
      if (value == null) return;
      final str = value.toString();
      if (str.isEmpty) return;
      params[key] = str;
    });
    return base.replace(queryParameters: params);
  }

  Future<http.Response> _run(Future<http.Response> Function() action) async {
    try {
      return await action().timeout(timeout);
    } catch (e) {
      throw ApiException.network(
        'No se pudo conectar con la API en $_baseUrl. '
        'Verifique la dirección y que el servidor esté en ejecución.',
      );
    }
  }

  dynamic _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    final text = utf8.decode(response.bodyBytes);
    if (text.trim().isEmpty) return null;
    return jsonDecode(text);
  }

  void _ensureSuccess(http.Response response) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) return;
    throw ApiException.fromResponse(code, response.bodyBytes);
  }

  Future<dynamic> getJson(String path, {Map<String, dynamic>? query}) async {
    final response =
        await _run(() => _http.get(_build(path, query), headers: _headers));
    _ensureSuccess(response);
    return _decode(response);
  }

  Future<List<dynamic>> getJsonList(String path,
      {Map<String, dynamic>? query}) async {
    final data = await getJson(path, query: query);
    if (data is List) return data;
    return const [];
  }

  Future<dynamic> postJson(String path, Object body) async {
    final response = await _run(() => _http.post(_build(path),
        headers: _headers, body: jsonEncode(body)));
    _ensureSuccess(response);
    return _decode(response);
  }

  Future<void> putJson(String path, Object body) async {
    final response = await _run(() => _http.put(_build(path),
        headers: _headers, body: jsonEncode(body)));
    _ensureSuccess(response);
  }

  Future<void> delete(String path) async {
    final response =
        await _run(() => _http.delete(_build(path), headers: _headers));
    _ensureSuccess(response);
  }

  Future<Uint8List> getBytes(String path, {Map<String, dynamic>? query}) async {
    final response =
        await _run(() => _http.get(_build(path, query), headers: _headers));
    _ensureSuccess(response);
    return response.bodyBytes;
  }
}
