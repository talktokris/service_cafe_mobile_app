import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/api_parsing.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/utils/transaction_helpers.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/pull_to_refresh.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});
  final int orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? _order;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final body = await context.read<ApiClient>().get(ApiEndpoints.order(widget.orderId));
      if (mounted) setState(() => _order = body['data'] as Map<String, dynamic>);
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  double _num(dynamic v) => parseApiDouble(v);

  @override
  Widget build(BuildContext context) {
    final o = _order;
    final payment = o?['paymentType']?.toString() ?? o?['payment_type']?.toString();
    final items = (o?['order_items'] ?? o?['orderItems'] ?? []) as List;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Order Detail', showBack: true),
      body: _loading
          ? const LoadingOverlay()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : PullToRefresh.list(
                  onRefresh: _load,
                  padding: const EdgeInsets.all(16),
                  children: [
                      Text(o?['orderShortName']?.toString() ?? 'Order #${o?['id']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(formatDateTime(o?['created_at']?.toString()), style: const TextStyle(color: AppColors.textMuted)),
                      const SizedBox(height: 12),
                      _section('Location', orderLocation(o!)),
                      const SizedBox(height: 12),
                      _section('Payment', null, child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: paymentTypeBg(payment),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  (payment ?? 'UNKNOWN').toUpperCase(),
                                  style: TextStyle(fontWeight: FontWeight.w600, color: paymentTypeColor(payment)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('Status: ${o['paymentStatus'] ?? o['payment_status'] ?? '-'}'),
                            ],
                          ),
                          if (o['paymentReference'] != null || o['payment_reference'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text('Ref: ${o['paymentReference'] ?? o['payment_reference']}'),
                            ),
                        ],
                      )),
                      const SizedBox(height: 12),
                      const Text('Line Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      ...items.map((item) {
                        final m = item as Map<String, dynamic>;
                        final qty = parseApiInt(m['quantity'], 1);
                        final unit = m['sellingPrice'] ?? m['price'] ?? m['amount'] ?? 0;
                        final sub = m['subTotalAmount'] ?? m['sub_total_amount'] ?? (qty * _num(unit));
                        final name = orderItemName(m);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 6),
                          child: ListTile(
                            title: Text(name),
                            subtitle: Text('Qty: $qty × ${formatNrs(unit)}'),
                            trailing: Text(formatNrs(sub), style: const TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      _section('Summary', null, child: Column(
                        children: [
                          _totalRow('Subtotal', _num(o['buyingPrice'] ?? o['buying_price'])),
                          _totalRow('Discount', _num(o['discountAmount'] ?? o['discount_amount'])),
                          _totalRow('Tax', _num(o['taxAmount'] ?? o['tax_amount'])),
                          _totalRow('Commission', _num(o['userCommissionAmount'] ?? o['user_commission_amount'])),
                          const Divider(),
                          _totalRow('Total', _num(o['sellingPrice'] ?? o['selling_price']), bold: true),
                        ],
                      )),
                      if (o['notes'] != null && o['notes'].toString().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _section('Notes', o['notes'].toString()),
                      ],
                    ],
                ),
    );
  }

  Widget _section(String title, String? text, {Widget? child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
            const SizedBox(height: 8),
            ...? (text == null ? null : [Text(text)]),
            ?child,
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(formatNrs(value), style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}
