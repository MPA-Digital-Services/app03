import 'dart:convert';

/// Excepción de dominio para errores de la API (red, validación, conflicto, etc.).
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.fieldErrors = const {}});

  ApiException.network(String message) : this(message);

  final String message;
  final int? statusCode;
  final Map<String, List<String>> fieldErrors;

  bool get isNetwork => statusCode == null;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isValidation => statusCode == 400;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Construye la excepción a partir de una respuesta ProblemDetails (RFC 7807).
  factory ApiException.fromResponse(int statusCode, List<int> bodyBytes) {
    var message = _defaultMessage(statusCode);
    final errors = <String, List<String>>{};

    try {
      if (bodyBytes.isNotEmpty) {
        final text = utf8.decode(bodyBytes);
        if (text.trim().isNotEmpty) {
          final data = jsonDecode(text);
          if (data is Map) {
            final title = data['title'] ?? data['Title'];
            final detail = data['detail'] ?? data['Detail'];
            if (detail is String && detail.trim().isNotEmpty) {
              message = detail.trim();
            } else if (title is String && title.trim().isNotEmpty) {
              message = title.trim();
            }

            final rawErrors = data['errors'] ?? data['Errors'];
            if (rawErrors is Map) {
              rawErrors.forEach((key, value) {
                if (value is List) {
                  errors[key.toString()] =
                      value.map((e) => e.toString()).toList();
                }
              });
            }
          }
        }
      }
    } catch (_) {
      // Si el cuerpo no es JSON válido, se mantiene el mensaje por defecto.
    }

    return ApiException(message, statusCode: statusCode, fieldErrors: errors);
  }

  static String _defaultMessage(int code) {
    switch (code) {
      case 400:
        return 'Datos inválidos (400).';
      case 404:
        return 'Recurso no encontrado (404).';
      case 409:
        return 'Conflicto: el recurso ya existe o está en uso (409).';
      default:
        return code >= 500
            ? 'Error del servidor ($code). Intente más tarde.'
            : 'Error inesperado ($code).';
    }
  }

  @override
  String toString() => message;
}
