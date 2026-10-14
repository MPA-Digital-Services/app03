import 'package:flutter/material.dart';

import 'field_spec.dart';

/// Descripción completa de un recurso CRUD: ruta, clave y campos, además de los
/// parámetros de filtro/orden soportados por la API.
class EntitySpec {
  const EntitySpec({
    required this.title,
    required this.route,
    required this.idField,
    required this.fields,
    required this.primaryField,
    this.singular,
    this.subtitleFields = const [],
    this.icon = Icons.table_rows_outlined,
    this.searchParam,
    this.searchHint = 'Buscar',
    this.filterParams = const [],
    this.sortParam,
    this.sortDir,
    this.idEditableOnCreate = false,
    this.canCreate = true,
    this.canEdit = true,
    this.canDelete = true,
    this.detailBuilder,
  });

  /// Título plural mostrado en la lista.
  final String title;

  /// Nombre en singular (para botones y mensajes).
  final String? singular;

  /// Ruta base relativa, p. ej. `/api/products`.
  final String route;

  /// Clave del campo que actúa como identificador.
  final String idField;

  /// Campo mostrado como título principal de cada elemento de la lista.
  final String primaryField;

  /// Campos adicionales mostrados como subtítulo en la lista.
  final List<String> subtitleFields;

  final IconData icon;

  /// Todos los campos, en el orden de presentación.
  final List<FieldSpec> fields;

  /// Parámetro de búsqueda de texto libre soportado por el filtro de la API
  /// (p. ej. `productName`). Si es null no se muestra el buscador.
  final String? searchParam;
  final String searchHint;

  /// Parámetros de filtro adicionales expuestos por la API (nombre del query).
  final List<String> filterParams;

  /// Campo de orden por defecto (clave de la lista blanca del servidor).
  final String? sortParam;

  /// Dirección de orden por defecto (`asc`/`desc`).
  final String? sortDir;

  /// Si la clave la provee el cliente al crear (p. ej. Region, Customer).
  final bool idEditableOnCreate;

  final bool canCreate;
  final bool canEdit;
  final bool canDelete;

  /// Si se define, al tocar un elemento se abre esta vista de detalle en lugar
  /// del formulario de edición (p. ej. las líneas de un pedido).
  final Widget Function(BuildContext context, Map<String, dynamic> item)?
      detailBuilder;

  String get keyType =>
      field(idField)?.type == FieldType.integer ? 'int' : 'string';

  FieldSpec? field(String key) {
    for (final f in fields) {
      if (f.key == key) return f;
    }
    return null;
  }

  List<FieldSpec> get listFields =>
      fields.where((f) => f.inList).toList(growable: false);

  List<FieldSpec> get formFields =>
      fields.where((f) => f.inForm).toList(growable: false);
}
