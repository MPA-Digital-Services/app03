import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/stat_card.dart';
import '../data/dashboard_api.dart';
import '../models/dashboard_models.dart';

class _DashboardBundle {
  const _DashboardBundle({
    required this.summary,
    required this.byMonth,
    required this.topProducts,
    required this.topCustomers,
    required this.statuses,
    required this.recentOrders,
  });

  final DashboardSummary summary;
  final List<SalesByMonth> byMonth;
  final List<TopProduct> topProducts;
  final List<TopCustomer> topCustomers;
  final List<OrderStatusCount> statuses;
  final List<RecentOrder> recentOrders;
}

/// Panel principal con métricas de ventas y rankings.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardApi _api;
  late Future<_DashboardBundle> _future;

  @override
  void initState() {
    super.initState();
    _api = DashboardApi(AppScope.of(context, listen: false).api);
    _future = _load();
  }

  Future<_DashboardBundle> _load() async {
    final results = await Future.wait([
      _api.summary(),
      _api.salesByMonth(),
      _api.topProducts(),
      _api.topCustomers(),
      _api.orderStatus(),
      _api.recentOrders(),
    ]);

    return _DashboardBundle(
      summary: results[0] as DashboardSummary,
      byMonth: results[1] as List<SalesByMonth>,
      topProducts: results[2] as List<TopProduct>,
      topCustomers: results[3] as List<TopCustomer>,
      statuses: results[4] as List<OrderStatusCount>,
      recentOrders: results[5] as List<RecentOrder>,
    );
  }

  Future<void> _reload() async {
    setState(() => _future = _load());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: AsyncView<_DashboardBundle>(
        future: _future,
        onRetry: _reload,
        onData: (context, data) => RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _summaryGrid(data.summary),
              _salesChart(data.byMonth),
              _statusCard(data.statuses),
              _topProducts(data.topProducts),
              _topCustomers(data.topCustomers),
              _recentOrders(data.recentOrders),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryGrid(DashboardSummary s) {
    final cards = <Widget>[
      StatCard(
        label: 'Ventas totales',
        value: Fmt.money(s.totalSales),
        icon: Icons.attach_money,
      ),
      StatCard(
        label: 'Pedidos',
        value: Fmt.number(s.totalOrders),
        icon: Icons.receipt_long,
        color: Colors.teal,
      ),
      StatCard(
        label: 'Ticket promedio',
        value: Fmt.money(s.averageOrderValue),
        icon: Icons.trending_up,
        color: Colors.deepOrange,
      ),
      StatCard(
        label: 'Clientes',
        value: Fmt.number(s.totalCustomers),
        icon: Icons.people_alt,
        color: Colors.indigo,
      ),
      StatCard(
        label: 'Productos',
        value: Fmt.number(s.totalProducts),
        icon: Icons.inventory_2,
        color: Colors.brown,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 520 ? 3 : 2;
          return GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: cards,
          );
        },
      ),
    );
  }

  Widget _salesChart(List<SalesByMonth> months) {
    final recent = months.length > 12
        ? months.sublist(months.length - 12)
        : months;
    final data = recent
        .map((m) => BarDatum(
              m.monthName.isNotEmpty
                  ? m.monthName.substring(0, m.monthName.length >= 3 ? 3 : m.monthName.length)
                  : m.month.toString(),
              m.sales,
            ))
        .toList();

    return SectionCard(
      title: 'Ventas por mes',
      subtitle: 'Últimos ${data.length} meses con actividad',
      child: SimpleBarChart(
        data: data,
        height: 180,
        barColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _statusCard(List<OrderStatusCount> statuses) {
    final total =
        statuses.fold<int>(0, (sum, s) => sum + s.count);
    return SectionCard(
      title: 'Estado de pedidos',
      subtitle: 'Distribución derivada por fechas',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: statuses.map((s) {
          final fraction = total == 0 ? 0.0 : s.count / total;
          return Chip(
            avatar: CircleAvatar(
              backgroundColor: _statusColor(s.status),
              radius: 8,
            ),
            label: Text('${s.status}: ${s.count} (${Fmt.percent(fraction)})'),
          );
        }).toList(),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'enviado':
        return Colors.green;
      case 'vencido':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget _topProducts(List<TopProduct> products) {
    if (products.isEmpty) {
      return const SectionCard(
        title: 'Productos más vendidos',
        child: Text('Sin datos.'),
      );
    }
    final max = products.map((p) => p.sales).reduce((a, b) => a > b ? a : b);
    return SectionCard(
      title: 'Productos más vendidos',
      subtitle: 'Por importe de ventas',
      child: Column(
        children: products
            .map((p) => RankBar(
                  label: p.productName,
                  value: p.sales,
                  fraction: max <= 0 ? 0 : p.sales / max,
                  valueLabel: Fmt.money(p.sales),
                ))
            .toList(),
      ),
    );
  }

  Widget _topCustomers(List<TopCustomer> customers) {
    if (customers.isEmpty) {
      return const SectionCard(
        title: 'Mejores clientes',
        child: Text('Sin datos.'),
      );
    }
    final max = customers.map((c) => c.sales).reduce((a, b) => a > b ? a : b);
    return SectionCard(
      title: 'Mejores clientes',
      subtitle: 'Por importe de ventas',
      child: Column(
        children: customers
            .map((c) => RankBar(
                  label: c.companyName,
                  value: c.sales,
                  fraction: max <= 0 ? 0 : c.sales / max,
                  valueLabel: Fmt.money(c.sales),
                ))
            .toList(),
      ),
    );
  }

  Widget _recentOrders(List<RecentOrder> orders) {
    return SectionCard(
      title: 'Pedidos recientes',
      child: Column(
        children: orders
            .map((o) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    child: Text('#${o.orderId}',
                        style: const TextStyle(fontSize: 10)),
                  ),
                  title: Text(o.companyName ?? o.customerId ?? '—'),
                  subtitle: Text(
                      '${Fmt.date(o.orderDate)} · ${o.status}'),
                  trailing: Text(
                    Fmt.money(o.total),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
