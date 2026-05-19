import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final List<dynamic> _orders = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _load(refresh: true);
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
      final body = await api.get(ApiEndpoints.orders, query: {'page': _page, 'per_page': 20});
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Orders'),
      body: _loading && _orders.isEmpty
          ? const LoadingOverlay()
          : _error != null && _orders.isEmpty
              ? ErrorState(message: _error!, onRetry: () => _load(refresh: true))
              : RefreshIndicator(
                  onRefresh: () => _load(refresh: true),
                  child: ListView.builder(
                    itemCount: _orders.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _orders.length) {
                        _load();
                        return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                      }
                      final o = _orders[index] as Map<String, dynamic>;
                      return ListTile(
                        title: Text(o['orderShortName']?.toString() ?? 'Order #${o['id']}'),
                        subtitle: Text(formatDate(o['created_at']?.toString())),
                        trailing: Text(formatNrs(o['totalAmount'] ?? o['total_amount'] ?? 0)),
                        onTap: () => context.push('/orders/${o['id']}'),
                      );
                    },
                  ),
                ),
    );
  }
}
