import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Order Detail', showBack: true),
      body: _loading
          ? const LoadingOverlay()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(_order?['orderShortName']?.toString() ?? 'Order', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(formatDate(_order?['created_at']?.toString())),
                    const Divider(),
                    ...((_order?['order_items'] ?? _order?['orderItems'] ?? []) as List).map((item) {
                      final m = item as Map<String, dynamic>;
                      return ListTile(
                        title: Text(m['itemName']?.toString() ?? m['name']?.toString() ?? 'Item'),
                        trailing: Text(formatNrs(m['amount'] ?? m['price'] ?? 0)),
                      );
                    }),
                  ],
                ),
    );
  }
}
