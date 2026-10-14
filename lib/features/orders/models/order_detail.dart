/// Línea de pedido (`OrderDetails`), con clave compuesta (OrderId, ProductId).
class OrderDetail {
  const OrderDetail({
    required this.orderId,
    required this.productId,
    required this.unitPrice,
    required this.quantity,
    required this.discount,
  });

  final int orderId;
  final int productId;
  final double unitPrice;
  final int quantity;
  final double discount;

  /// Importe de la línea: UnitPrice * Quantity * (1 - Discount).
  double get lineTotal => unitPrice * quantity * (1 - discount);

  factory OrderDetail.fromJson(Map<String, dynamic> j) => OrderDetail(
        orderId: (j['orderId'] as num).toInt(),
        productId: (j['productId'] as num).toInt(),
        unitPrice: (j['unitPrice'] as num).toDouble(),
        quantity: (j['quantity'] as num).toInt(),
        discount: (j['discount'] as num).toDouble(),
      );
}
