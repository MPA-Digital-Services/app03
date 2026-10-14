import '../../../core/network/api_client.dart';
import '../models/dashboard_models.dart';

/// Acceso a los endpoints del dashboard.
class DashboardApi {
  DashboardApi(this._api);

  final ApiClient _api;

  Map<String, dynamic> _map(dynamic data) => data as Map<String, dynamic>;

  Future<DashboardSummary> summary({DateTime? from, DateTime? to}) async {
    final data = await _api.getJson('/api/dashboard/summary', query: {
      'from': from?.toIso8601String(),
      'to': to?.toIso8601String(),
    });
    return DashboardSummary.fromJson(_map(data));
  }

  Future<List<SalesByMonth>> salesByMonth({DateTime? from, DateTime? to}) async {
    final data = await _api.getJsonList('/api/dashboard/sales-by-month',
        query: {'from': from?.toIso8601String(), 'to': to?.toIso8601String()});
    return data
        .map((e) => SalesByMonth.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<SalesByQuarter>> salesByQuarter(
      {DateTime? from, DateTime? to}) async {
    final data = await _api.getJsonList('/api/dashboard/sales-by-quarter',
        query: {'from': from?.toIso8601String(), 'to': to?.toIso8601String()});
    return data
        .map((e) => SalesByQuarter.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<SalesByYear>> salesByYear({DateTime? from, DateTime? to}) async {
    final data = await _api.getJsonList('/api/dashboard/sales-by-year',
        query: {'from': from?.toIso8601String(), 'to': to?.toIso8601String()});
    return data
        .map((e) => SalesByYear.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<TopProduct>> topProducts({int top = 8}) async {
    final data =
        await _api.getJsonList('/api/dashboard/top-products', query: {'top': top});
    return data
        .map((e) => TopProduct.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<TopCategory>> topCategories({int top = 8}) async {
    final data = await _api.getJsonList('/api/dashboard/top-categories',
        query: {'top': top});
    return data
        .map((e) => TopCategory.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<TopCustomer>> topCustomers({int top = 8}) async {
    final data = await _api
        .getJsonList('/api/dashboard/top-customers', query: {'top': top});
    return data
        .map((e) => TopCustomer.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<RecentOrder>> recentOrders({int top = 8}) async {
    final data = await _api
        .getJsonList('/api/dashboard/recent-orders', query: {'top': top});
    return data
        .map((e) => RecentOrder.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }

  Future<List<OrderStatusCount>> orderStatus({DateTime? from, DateTime? to}) async {
    final data = await _api.getJsonList('/api/dashboard/order-status',
        query: {'from': from?.toIso8601String(), 'to': to?.toIso8601String()});
    return data
        .map((e) => OrderStatusCount.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  }
}
