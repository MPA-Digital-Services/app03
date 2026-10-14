import '../../core/crud/field_spec.dart';
import '../../core/network/api_client.dart';

/// Carga opciones de desplegable desde endpoints CRUD paginados.
Future<List<DropdownOption>> _load(
  ApiClient api,
  String route,
  String idKey,
  String Function(Map<String, dynamic> item) label,
  {Map<String, dynamic>? query}
) async {
  final data = await api.getJson(route, query: {
    'page': 1,
    'pageSize': 100,
    ...?query,
  });
  final map = data as Map<String, dynamic>;
  final items = (map['items'] as List?) ?? const [];
  return items.map((raw) {
    final item = (raw as Map).cast<String, dynamic>();
    return DropdownOption(item[idKey], label(item));
  }).toList();
}

Future<List<DropdownOption>> loadCategories(ApiClient api) => _load(
      api,
      '/api/Categories',
      'categoryId',
      (i) => i['categoryName']?.toString() ?? '',
    );

Future<List<DropdownOption>> loadSuppliers(ApiClient api) => _load(
      api,
      '/api/Suppliers',
      'supplierId',
      (i) => i['companyName']?.toString() ?? '',
    );

Future<List<DropdownOption>> loadShippers(ApiClient api) => _load(
      api,
      '/api/Shippers',
      'shipperId',
      (i) => i['companyName']?.toString() ?? '',
    );

Future<List<DropdownOption>> loadEmployees(ApiClient api) => _load(
      api,
      '/api/Employees',
      'employeeId',
      (i) => '${i['lastName']}, ${i['firstName']}',
    );

Future<List<DropdownOption>> loadCustomers(ApiClient api) => _load(
      api,
      '/api/Customers',
      'customerId',
      (i) => '${i['customerId']} · ${i['companyName']}',
    );

Future<List<DropdownOption>> loadRegions(ApiClient api) => _load(
      api,
      '/api/Regions',
      'regionId',
      (i) => i['regionDescription']?.toString() ?? '',
    );

Future<List<DropdownOption>> loadProducts(ApiClient api) => _load(
      api,
      '/api/Products',
      'productId',
      (i) => i['productName']?.toString() ?? '',
    );
