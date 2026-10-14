// Modelos del dashboard (`/api/dashboard/*`).

double? _toDouble(dynamic v) => v == null ? null : (v as num).toDouble();
int _toInt(dynamic v) => v == null ? 0 : (v as num).toInt();
DateTime? _toDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString());

String _str(dynamic v) => v?.toString() ?? '';

class DashboardSummary {
  const DashboardSummary({
    this.from,
    this.to,
    required this.totalOrders,
    required this.totalSales,
    required this.averageOrderValue,
    required this.totalCustomers,
    required this.totalProducts,
  });

  final DateTime? from;
  final DateTime? to;
  final int totalOrders;
  final double totalSales;
  final double averageOrderValue;
  final int totalCustomers;
  final int totalProducts;

  factory DashboardSummary.fromJson(Map<String, dynamic> j) => DashboardSummary(
        from: _toDate(j['from']),
        to: _toDate(j['to']),
        totalOrders: _toInt(j['totalOrders']),
        totalSales: _toDouble(j['totalSales']) ?? 0,
        averageOrderValue: _toDouble(j['averageOrderValue']) ?? 0,
        totalCustomers: _toInt(j['totalCustomers']),
        totalProducts: _toInt(j['totalProducts']),
      );
}

class SalesByMonth {
  const SalesByMonth({
    required this.year,
    required this.month,
    required this.monthName,
    required this.orderCount,
    required this.sales,
  });

  final int year;
  final int month;
  final String monthName;
  final int orderCount;
  final double sales;

  factory SalesByMonth.fromJson(Map<String, dynamic> j) => SalesByMonth(
        year: _toInt(j['year']),
        month: _toInt(j['month']),
        monthName: _str(j['monthName']),
        orderCount: _toInt(j['orderCount']),
        sales: _toDouble(j['sales']) ?? 0,
      );
}

class SalesByQuarter {
  const SalesByQuarter({
    required this.year,
    required this.quarter,
    required this.orderCount,
    required this.sales,
  });

  final int year;
  final int quarter;
  final int orderCount;
  final double sales;

  factory SalesByQuarter.fromJson(Map<String, dynamic> j) => SalesByQuarter(
        year: _toInt(j['year']),
        quarter: _toInt(j['quarter']),
        orderCount: _toInt(j['orderCount']),
        sales: _toDouble(j['sales']) ?? 0,
      );
}

class SalesByYear {
  const SalesByYear({
    required this.year,
    required this.orderCount,
    required this.sales,
  });

  final int year;
  final int orderCount;
  final double sales;

  factory SalesByYear.fromJson(Map<String, dynamic> j) => SalesByYear(
        year: _toInt(j['year']),
        orderCount: _toInt(j['orderCount']),
        sales: _toDouble(j['sales']) ?? 0,
      );
}

class TopProduct {
  const TopProduct({
    required this.productId,
    required this.productName,
    required this.categoryName,
    required this.unitsSold,
    required this.sales,
  });

  final int productId;
  final String productName;
  final String categoryName;
  final int unitsSold;
  final double sales;

  factory TopProduct.fromJson(Map<String, dynamic> j) => TopProduct(
        productId: _toInt(j['productId']),
        productName: _str(j['productName']),
        categoryName: _str(j['categoryName']),
        unitsSold: _toInt(j['unitsSold']),
        sales: _toDouble(j['sales']) ?? 0,
      );
}

class TopCategory {
  const TopCategory({
    required this.categoryId,
    required this.categoryName,
    required this.unitsSold,
    required this.sales,
  });

  final int categoryId;
  final String categoryName;
  final int unitsSold;
  final double sales;

  factory TopCategory.fromJson(Map<String, dynamic> j) => TopCategory(
        categoryId: _toInt(j['categoryId']),
        categoryName: _str(j['categoryName']),
        unitsSold: _toInt(j['unitsSold']),
        sales: _toDouble(j['sales']) ?? 0,
      );
}

class TopCustomer {
  const TopCustomer({
    required this.customerId,
    required this.companyName,
    required this.orderCount,
    required this.sales,
  });

  final String customerId;
  final String companyName;
  final int orderCount;
  final double sales;

  factory TopCustomer.fromJson(Map<String, dynamic> j) => TopCustomer(
        customerId: _str(j['customerId']),
        companyName: _str(j['companyName']),
        orderCount: _toInt(j['orderCount']),
        sales: _toDouble(j['sales']) ?? 0,
      );
}

class RecentOrder {
  const RecentOrder({
    required this.orderId,
    this.customerId,
    this.companyName,
    this.orderDate,
    this.shippedDate,
    required this.total,
    required this.status,
  });

  final int orderId;
  final String? customerId;
  final String? companyName;
  final DateTime? orderDate;
  final DateTime? shippedDate;
  final double total;
  final String status;

  factory RecentOrder.fromJson(Map<String, dynamic> j) => RecentOrder(
        orderId: _toInt(j['orderId']),
        customerId: j['customerId'] as String?,
        companyName: j['companyName'] as String?,
        orderDate: _toDate(j['orderDate']),
        shippedDate: _toDate(j['shippedDate']),
        total: _toDouble(j['total']) ?? 0,
        status: _str(j['status']),
      );
}

class OrderStatusCount {
  const OrderStatusCount({required this.status, required this.count});

  final String status;
  final int count;

  factory OrderStatusCount.fromJson(Map<String, dynamic> j) =>
      OrderStatusCount(status: _str(j['status']), count: _toInt(j['count']));
}
