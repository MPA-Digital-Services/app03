import '../../../core/models/paged_result.dart';
import '../../../core/network/api_client.dart';
import '../models/order_detail.dart';

/// Acceso a las líneas de pedido como subrecurso `/api/orders/{id}/details`.
class OrderDetailsApi {
  OrderDetailsApi(this._api);

  final ApiClient _api;

  String _base(int orderId) => '/api/orders/$orderId/details';

  Future<PagedResult<OrderDetail>> list(int orderId,
      {int page = 1, int pageSize = 100}) async {
    final data = await _api.getJson(_base(orderId),
        query: {'page': page, 'pageSize': pageSize});
    return PagedResult.fromJson(
      data,
      (map) => OrderDetail.fromJson(map),
    );
  }

  Future<void> createLine(
    int orderId,
    Map<String, dynamic> body,
  ) async {
    await _api.postJson(_base(orderId), body);
  }

  Future<void> updateLine(
    int orderId,
    int productId,
    Map<String, dynamic> body,
  ) async {
    await _api.putJson('${_base(orderId)}/$productId', body);
  }

  Future<void> deleteLine(int orderId, int productId) async {
    await _api.delete('${_base(orderId)}/$productId');
  }
}
