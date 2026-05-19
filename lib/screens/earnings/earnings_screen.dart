import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/screens/earnings/withdraw_dialog.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/locked_feature_banner.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  Map<String, dynamic>? _summary;
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    if (user?.isFree == true) {
      setState(() { _loading = false; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final body = await context.read<ApiClient>().get(ApiEndpoints.earnings);
      final data = body['data'] as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _summary = data['summary'] as Map<String, dynamic>?;
          final paginated = data['earnings'] as Map<String, dynamic>?;
          _items = paginated?['data'] as List<dynamic>? ?? [];
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _withdraw() async {
    final balance = (_summary?['earning_balance'] as num?)?.toDouble() ?? 0;
    final min = (_summary?['min_withdrawal'] as num?)?.toDouble() ?? 1000;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => WithdrawDialog(maxAmount: balance, minAmount: min),
    );
    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final isFree = context.watch<AuthProvider>().user?.isFree ?? true;

    if (isFree) {
      return Scaffold(
        appBar: const GradientAppBar(title: 'Earnings'),
        body: const LockedFeatureBanner(child: SizedBox(height: 200)),
      );
    }

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Earnings',
        actions: [
          IconButton(icon: const Icon(Icons.payments), onPressed: _withdraw),
        ],
      ),
      body: _loading
          ? const LoadingOverlay()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Balance: ${formatNrs(_summary?['earning_balance'] ?? 0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              const SizedBox(height: 8),
                              ElevatedButton(onPressed: _withdraw, child: const Text('Withdraw')),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._items.map((e) {
                        final m = e as Map<String, dynamic>;
                        return ListTile(
                          title: Text(m['earning_name']?.toString() ?? 'Earning'),
                          subtitle: Text(formatDate(m['created_at']?.toString())),
                          trailing: Text(formatNrs(m['ammout'] ?? 0)),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
