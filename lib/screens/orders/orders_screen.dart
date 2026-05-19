import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/utils/transaction_helpers.dart';
import 'package:serve_cafe_mobile/widgets/date_filter_bar.dart';
import 'package:serve_cafe_mobile/widgets/empty_state.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/premium_list_card.dart';
import 'package:serve_cafe_mobile/widgets/premium_screen_body.dart';
import 'package:serve_cafe_mobile/widgets/section_header.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _orderIdCtrl = TextEditingController();
  final List<dynamic> _orders = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = monthStart(now);
    _to = monthEnd(now);
    _load(refresh: true);
  }

  @override
  void dispose() {
    _orderIdCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _queryParams() {
    final q = <String, dynamic>{'page': _page, 'per_page': 20};
    if (_orderIdCtrl.text.isNotEmpty) q['order_id'] = _orderIdCtrl.text;
    if (_from != null) q['from_date'] = DateFormat('yyyy-MM-dd').format(_from!);
    if (_to != null) q['to_date'] = DateFormat('yyyy-MM-dd').format(_to!);
    return q;
  }

  Future<void> _load({bool refresh = false}) async {
    if (refresh) {
      setState(() { _loading = true; _error = null; _page = 1; _hasMore = true; _orders.clear(); });
    } else {
      if (!_hasMore || _loadingMore) return;
      setState(() => _loadingMore = true);
    }
    try {
      final api = context.read<ApiClient>();
      final body = await api.get(ApiEndpoints.orders, query: _queryParams());
      final data = body['data'] as Map<String, dynamic>;
      final list = data['data'] as List<dynamic>? ?? [];
      final lastPage = data['last_page'] as int? ?? 1;
      if (mounted) {
        setState(() {
          _orders.addAll(list);
          _hasMore = _page < lastPage;
          _page++;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() { _loading = false; _loadingMore = false; });
    }
  }

  void _reset() {
    final now = DateTime.now();
    _orderIdCtrl.clear();
    setState(() {
      _from = monthStart(now);
      _to = monthEnd(now);
    });
    _load(refresh: true);
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isFrom ? _from : _to) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => isFrom ? _from = picked : _to = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Orders'),
      body: PremiumScreenBody(
        child: _loading && _orders.isEmpty
            ? const LoadingOverlay()
            : _error != null && _orders.isEmpty
                ? ErrorState(message: _error!, onRetry: () => _load(refresh: true))
                : RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: () => _load(refresh: true),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: _orders.length + 2 + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return DateFilterBar(
                          textField: _orderIdCtrl,
                          textFieldLabel: 'Order ID',
                          from: _from,
                          to: _to,
                          onPickFrom: () => _pickDate(true),
                          onPickTo: () => _pickDate(false),
                          onSearch: () => _load(refresh: true),
                          onReset: _reset,
                        );
                      }
                      if (index == 1) {
                        if (_orders.isEmpty) {
                          return const EmptyState(message: 'No orders found.', icon: Icons.receipt_long_outlined);
                        }
                        return SectionHeader(
                          title: 'Order History',
                          subtitle: 'Showing ${_orders.length} orders',
                        );
                      }
                      final orderIndex = index - 2;
                      if (orderIndex == _orders.length) {
                        if (_hasMore) _load();
                        return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                      }
                      final o = _orders[orderIndex] as Map<String, dynamic>;
                      return _orderCard(context, o);
                    },
                  ),
                ),
      ),
    );
  }

  Widget _orderCard(BuildContext context, Map<String, dynamic> o) {
    final payment = o['paymentType']?.toString() ?? o['payment_type']?.toString();
    return PremiumListCard(
      onTap: () => context.push('/orders/${o['id']}'),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      o['orderShortName']?.toString() ?? 'Order #${o['id']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: paymentTypeBg(payment),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (payment ?? 'UNKNOWN').toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: paymentTypeColor(payment)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(formatDateTime(o['created_at']?.toString()), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 6),
              Text('Location: ${orderLocation(o)}', style: const TextStyle(fontSize: 13)),
              Text('Cashier: ${orderCashier(o)}', style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  formatNrs(o['sellingPrice'] ?? o['totalAmount'] ?? o['total_amount'] ?? 0),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
    );
  }
}
