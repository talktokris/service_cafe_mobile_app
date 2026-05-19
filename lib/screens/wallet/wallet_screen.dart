import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/screens/wallet/cash_out_dialog.dart';
import 'package:serve_cafe_mobile/screens/wallet/transfer_dialog.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/locked_feature_banner.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Map<String, dynamic>? _summary;
  List<dynamic> _cashItems = [];
  List<dynamic> _purchaseItems = [];
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
      final api = context.read<ApiClient>();
      final isPaid = context.read<AuthProvider>().user?.isPaid ?? false;
      if (isPaid) {
        final body = await api.get(ApiEndpoints.cashWallet);
        final data = body['data'] as Map<String, dynamic>;
        _summary = data['summary'] as Map<String, dynamic>?;
        final paginated = data['transactions'] as Map<String, dynamic>?;
        _cashItems = paginated?['data'] as List<dynamic>? ?? [];
      }
      final txBody = await api.get(ApiEndpoints.transactions);
      final txData = txBody['data'] as Map<String, dynamic>;
      _purchaseItems = txData['transactions'] as List<dynamic>? ?? [];
    } catch (e) {
      _error = ApiClient.friendlyError(e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = context.watch<AuthProvider>().user?.isPaid ?? false;
    final balance = (_summary?['total_balance'] as num?)?.toDouble() ?? 0;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Wallet'),
      body: _loading
          ? const LoadingOverlay()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (!isPaid) const LockedFeatureBanner(),
                      if (isPaid) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cash Wallet: ${formatNrs(balance)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(child: ElevatedButton(onPressed: () async {
                                      final ok = await showDialog<bool>(context: context, builder: (_) => CashOutDialog(maxAmount: balance));
                                      if (ok == true) _load();
                                    }, child: const Text('Cash Out'))),
                                    const SizedBox(width: 8),
                                    Expanded(child: ElevatedButton(onPressed: () async {
                                      final ok = await showDialog<bool>(context: context, builder: (_) => TransferDialog(maxAmount: balance));
                                      if (ok == true) _load();
                                    }, child: const Text('Transfer'))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Text('Cash Wallet Ledger', style: TextStyle(fontWeight: FontWeight.w600)),
                        ..._cashItems.map((e) {
                          final m = e as Map<String, dynamic>;
                          return ListTile(title: Text(m['name']?.toString() ?? ''), trailing: Text(formatNrs(m['amount'] ?? 0)));
                        }),
                        const Divider(height: 32),
                      ],
                      const Text('Purchase Transactions', style: TextStyle(fontWeight: FontWeight.w600)),
                      ..._purchaseItems.map((e) {
                        final m = e as Map<String, dynamic>;
                        return ListTile(
                          title: Text(m['transaction_type']?.toString() ?? 'Transaction'),
                          subtitle: Text(formatDate(m['created_at']?.toString())),
                          trailing: Text(formatNrs(m['amount'] ?? 0)),
                        );
                      }),
                    ],
                  ),
                ),
    );
  }
}
