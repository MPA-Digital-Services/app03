import 'package:flutter/material.dart';

import '../../../core/models/paged_result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_scope.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/section_card.dart';
import '../../catalog/reference_loaders.dart';
import '../../../core/crud/field_spec.dart';
import '../data/order_details_api.dart';
import '../models/order_detail.dart';

/// Líneas de un pedido (`/api/orders/{id}/details`), con alta/edición/borrado.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late final ApiClient _api;
  late final OrderDetailsApi _detailsApi;
  late Future<PagedResult<OrderDetail>> _future;
  List<DropdownOption> _productOptions = const [];

  int get _orderId => (widget.order['orderId'] as num).toInt();

  @override
  void initState() {
    super.initState();
    _api = AppScope.of(context, listen: false).api;
    _detailsApi = OrderDetailsApi(_api);
    _future = _detailsApi.list(_orderId);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final options = await loadProducts(_api);
      if (!mounted) return;
      setState(() => _productOptions = options);
    } catch (_) {
      // Si falla, el desplegable de productos seguirá vacío.
    }
  }

  Future<void> _reload() async {
    setState(() => _future = _detailsApi.list(_orderId));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #$_orderId'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openLineDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Línea'),
      ),
      body: AsyncView<PagedResult<OrderDetail>>(
        future: _future,
        onRetry: _reload,
        onData: (context, result) => RefreshIndicator(
          onRefresh: _reload,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              _header(),
              if (result.isEmpty)
                const SizedBox(
                  height: 220,
                  child: EmptyView(message: 'Este pedido no tiene líneas.'),
                )
              else
                SectionCard(
                  title: 'Líneas',
                  subtitle: '${result.totalCount} registros',
                  child: Column(
                    children: [
                      for (final line in result.items) _lineTile(line),
                      const Divider(),
                      _totalRow(result.items),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    final order = widget.order;
    String value(String key) => order[key]?.toString() ?? '—';
    return SectionCard(
      title: 'Detalle del pedido',
      child: Column(
        children: [
          _infoRow('Cliente', value('customerId')),
          _infoRow('Fecha', Fmt.date(Fmt.parseDate(order['orderDate']))),
          _infoRow('Fecha requerida', Fmt.date(Fmt.parseDate(order['requiredDate']))),
          _infoRow('Fecha de envío', Fmt.date(Fmt.parseDate(order['shippedDate']))),
          _infoRow('Enviar a', value('shipName')),
          _infoRow('Ciudad', value('shipCity')),
          _infoRow('País', value('shipCountry')),
          _infoRow('Flete', Fmt.money(order['freight'] as num?)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _lineTile(OrderDetail line) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(_productLabel(line.productId)),
      subtitle: Text(
        '${line.quantity} × ${Fmt.money(line.unitPrice)}'
        ' · desc. ${Fmt.percent(line.discount)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Fmt.money(line.lineTotal),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') _openLineDialog(line: line);
              if (value == 'delete') _confirmDelete(line);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Editar')),
              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
            ],
          ),
        ],
      ),
    );
  }

  String _productLabel(int productId) {
    for (final option in _productOptions) {
      if (option.value.toString() == productId.toString()) return option.label;
    }
    return 'Producto #$productId';
  }

  Widget _totalRow(List<OrderDetail> lines) {
    final total = lines.fold<double>(0, (sum, l) => sum + l.lineTotal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(
            Fmt.money(total),
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Future<void> _openLineDialog({OrderDetail? line}) async {
    final isEdit = line != null;
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _LineDialog(
        productOptions: _productOptions,
        initial: line,
      ),
    );
    if (result == null) return;

    try {
      if (isEdit) {
        await _detailsApi.updateLine(_orderId, line.productId, result);
      } else {
        await _detailsApi.createLine(_orderId, result);
      }
      await _reload();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      _showError('No se pudo guardar la línea: $e');
    }
  }

  Future<void> _confirmDelete(OrderDetail line) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar línea'),
        content: Text('¿Eliminar ${_productLabel(line.productId)} del pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _detailsApi.deleteLine(_orderId, line.productId);
      await _reload();
    } on ApiException catch (e) {
      if (!mounted) return;
      _showError(e.message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
      ),
    );
  }
}

class _LineDialog extends StatefulWidget {
  const _LineDialog({required this.productOptions, this.initial});

  final List<DropdownOption> productOptions;
  final OrderDetail? initial;

  @override
  State<_LineDialog> createState() => _LineDialogState();
}

class _LineDialogState extends State<_LineDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _price;
  late final TextEditingController _quantity;
  late final TextEditingController _discount;
  int? _productId;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _productId = initial?.productId;
    _price = TextEditingController(
        text: initial == null ? '' : initial.unitPrice.toString());
    _quantity = TextEditingController(
        text: initial == null ? '' : initial.quantity.toString());
    _discount = TextEditingController(
        text: initial == null ? '0' : initial.discount.toString());
  }

  @override
  void dispose() {
    _price.dispose();
    _quantity.dispose();
    _discount.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final body = <String, dynamic>{
      'unitPrice': num.tryParse(_price.text.replaceAll(',', '.'))?.toDouble(),
      'quantity': int.tryParse(_quantity.text),
      'discount': num.tryParse(_discount.text.replaceAll(',', '.'))?.toDouble(),
    };
    if (widget.initial == null) {
      body['productId'] = _productId;
    }
    Navigator.of(context).pop(body);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initial != null;
    return AlertDialog(
      title: Text(isEdit ? 'Editar línea' : 'Nueva línea'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: widget.productOptions
                        .any((o) => o.value == _productId)
                    ? _productId
                    : null,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: isEdit ? 'Producto (fijo)' : 'Producto *',
                ),
                items: [
                  for (final option in widget.productOptions)
                    DropdownMenuItem<int>(
                      value: option.value as int,
                      child: Text(option.label, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged:
                    isEdit ? null : (v) => setState(() => _productId = v),
                validator: (v) {
                  if (!isEdit && v == null) return 'Selecciona un producto.';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Precio unitario *'),
                validator: (v) =>
                    num.tryParse((v ?? '').replaceAll(',', '.')) == null
                        ? 'Número inválido.'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantity,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cantidad *'),
                validator: (v) =>
                    (int.tryParse(v ?? '') ?? 0) <= 0 ? 'Cantidad inválida.' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _discount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Descuento (0 a 1) *',
                  helperText: 'Ej.: 0.15 equivale a 15%',
                ),
                validator: (v) {
                  final d = num.tryParse((v ?? '').replaceAll(',', '.'));
                  if (d == null || d < 0 || d > 1) return 'Valor entre 0 y 1.';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Guardar')),
      ],
    );
  }
}
