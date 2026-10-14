/// Tipos de parámetro soportados por los procedimientos almacenados.
enum ProcParamType { text, integer, date }

/// Parámetro de entrada de un procedimiento.
class ProcParam {
  const ProcParam(
    this.name, {
    required this.type,
    this.required = false,
    this.label,
    this.defaultValue,
    this.helper,
  });

  final String name;
  final ProcParamType type;
  final bool required;
  final String? label;
  final String? defaultValue;
  final String? helper;

  String get displayLabel => label ?? name;
}

/// Descripción de un procedimiento ejecutable desde la app.
class ProcSpec {
  const ProcSpec({
    required this.title,
    required this.description,
    required this.params,
    required this.buildPath,
    this.columns = const [],
  });

  final String title;
  final String description;
  final List<ProcParam> params;

  /// Construye la ruta (con query o segmentos) a partir de los valores crudos.
  final String Function(Map<String, String> values) buildPath;

  /// Nombres de columna preferidos para mostrar (si están vacíos se usa el map).
  final List<String> columns;
}

/// Catálogo curado de los 7 procedimientos de Northwind.
class ProceduresCatalog {
  ProceduresCatalog._();

  static String _date(String value) =>
      DateTime.parse(value).toIso8601String();

  static final List<ProcSpec> all = [
    const ProcSpec(
      title: 'Productos más caros',
      description: 'dbo.[Ten Most Expensive Products] — 10 productos de mayor precio.',
      params: [],
      buildPath: _tenMostExpensive,
      columns: ['tenMostExpensiveProducts', 'unitPrice'],
    ),
    ProcSpec(
      title: 'Ventas por empleado y país',
      description: 'dbo.[Employee Sales by Country] — ventas por país en un rango de fechas.',
      params: const [
        ProcParam('beginningDate', type: ProcParamType.date, required: true, label: 'Desde'),
        ProcParam('endingDate', type: ProcParamType.date, required: true, label: 'Hasta'),
      ],
      buildPath: _employeeSales,
      columns: ['country', 'lastName', 'firstName', 'shippedDate', 'orderId', 'saleAmount'],
    ),
    ProcSpec(
      title: 'Ventas por año',
      description: 'dbo.[Sales by Year] — subtotales por pedido en un rango de fechas.',
      params: const [
        ProcParam('beginningDate', type: ProcParamType.date, required: true, label: 'Desde'),
        ProcParam('endingDate', type: ProcParamType.date, required: true, label: 'Hasta'),
      ],
      buildPath: _salesByYear,
      columns: ['shippedDate', 'orderId', 'subtotal', 'year'],
    ),
    ProcSpec(
      title: 'Detalle de pedido de cliente',
      description: 'dbo.CustOrdersDetail — líneas de un pedido concreto.',
      params: const [
        ProcParam('orderId', type: ProcParamType.integer, required: true, label: 'Pedido'),
      ],
      buildPath: _customerOrderDetail,
      columns: ['productName', 'unitPrice', 'quantity', 'discount', 'extendedPrice'],
    ),
    ProcSpec(
      title: 'Pedidos de un cliente',
      description: 'dbo.CustOrdersOrders — pedidos de un cliente.',
      params: const [
        ProcParam('customerId', type: ProcParamType.text, required: true, label: 'Cliente'),
      ],
      buildPath: _customerOrders,
      columns: ['orderId', 'orderDate', 'requiredDate', 'shippedDate'],
    ),
    ProcSpec(
      title: 'Historial de un cliente',
      description: 'dbo.CustOrderHist — cantidades compradas por producto.',
      params: const [
        ProcParam('customerId', type: ProcParamType.text, required: true, label: 'Cliente'),
      ],
      buildPath: _customerOrderHistory,
      columns: ['productName', 'total'],
    ),
    ProcSpec(
      title: 'Ventas por categoría',
      description: 'dbo.SalesByCategory — ventas por producto de una categoría.',
      params: const [
        ProcParam('categoryName', type: ProcParamType.text, required: true, label: 'Categoría'),
        ProcParam('ordYear', type: ProcParamType.text, label: 'Año', defaultValue: '1998'),
      ],
      buildPath: _salesByCategoryProc,
      columns: ['productName', 'totalPurchase'],
    ),
  ];

  static String _tenMostExpensive(Map<String, String> _) =>
      '/api/stored-procedures/ten-most-expensive-products';

  static String _employeeSales(Map<String, String> v) =>
      '/api/stored-procedures/employee-sales-by-country'
      '?beginningDate=${_date(v['beginningDate']!)}'
      '&endingDate=${_date(v['endingDate']!)}';

  static String _salesByYear(Map<String, String> v) =>
      '/api/stored-procedures/sales-by-year'
      '?beginningDate=${_date(v['beginningDate']!)}'
      '&endingDate=${_date(v['endingDate']!)}';

  static String _customerOrderDetail(Map<String, String> v) =>
      '/api/stored-procedures/customer-order-detail/${v['orderId']}';

  static String _customerOrders(Map<String, String> v) =>
      '/api/stored-procedures/customer-orders/'
      '${Uri.encodeComponent(v['customerId']!)}';

  static String _customerOrderHistory(Map<String, String> v) =>
      '/api/stored-procedures/customer-order-history/'
      '${Uri.encodeComponent(v['customerId']!)}';

  static String _salesByCategoryProc(Map<String, String> v) =>
      '/api/stored-procedures/sales-by-category'
      '?categoryName=${Uri.encodeComponent(v['categoryName']!)}'
      '&ordYear=${Uri.encodeComponent(v['ordYear']?.isNotEmpty == true ? v['ordYear']! : '1998')}';
}
