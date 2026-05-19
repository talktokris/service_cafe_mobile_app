import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/screens/wallet/cash_out_dialog.dart';
import 'package:serve_cafe_mobile/screens/wallet/transfer_dialog.dart';
import 'package:serve_cafe_mobile/utils/api_parsing.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/utils/transaction_helpers.dart';
import 'package:serve_cafe_mobile/widgets/cash_wallet_history_tile.dart';
import 'package:serve_cafe_mobile/widgets/date_filter_bar.dart';
import 'package:serve_cafe_mobile/widgets/empty_state.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/locked_feature_banner.dart';
import 'package:serve_cafe_mobile/widgets/premium_list_card.dart';
import 'package:serve_cafe_mobile/widgets/premium_screen_body.dart';
import 'package:serve_cafe_mobile/widgets/wallet_summary_panel.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _cashItems = [];
  List<dynamic> _purchaseItems = [];
  bool _loading = true;
  String? _error;
  DateTime? _from;
  DateTime? _to;
  String _type = '';

  @override
  void initState() {
    super.initState();
    _applyDefaultDates();
    _load();
  }

  void _applyDefaultDates() {
    final now = DateTime.now();
    _from = defaultHistoryFrom(now);
    _to = defaultHistoryTo(now);
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = context.read<ApiClient>();
      final isPaid = context.read<AuthProvider>().user?.isPaid ?? false;

      if (isPaid) {
        final query = <String, dynamic>{'per_page': 200};
        if (_from != null) query['from_date'] = DateFormat('yyyy-MM-dd').format(_from!);
        if (_to != null) query['to_date'] = DateFormat('yyyy-MM-dd').format(_to!);
        if (_type.isNotEmpty) query['type'] = _type;

        final body = await api.get(ApiEndpoints.cashWallet, query: query);
        final data = body['data'] as Map<String, dynamic>;
        _summary = data['summary'] as Map<String, dynamic>?;
        final raw = parseApiList(data['transactions']);
        final totalBal = (_summary?['total_balance'] as num?)?.toDouble() ?? 0;
        _cashItems = withRunningBalances(raw, totalBal);
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

  void _reset() {
    setState(() {
      _applyDefaultDates();
      _type = '';
    });
    _load();
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

  Future<void> _cashOut(double balance) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => CashOutDialog(maxAmount: balance),
    );
    if (ok == true) _load();
  }

  Future<void> _transfer(double balance) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => TransferDialog(maxAmount: balance),
    );
    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = context.watch<AuthProvider>().user?.isPaid ?? false;
    final balance = (_summary?['total_balance'] as num?)?.toDouble() ?? 0;
    final s = _summary;
    final ledgerCount = _cashItems.length;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Wallet'),
      body: PremiumScreenBody(
        child: _loading && _cashItems.isEmpty && _purchaseItems.isEmpty
            ? const LoadingOverlay()
            : _error != null && _cashItems.isEmpty && _purchaseItems.isEmpty
                ? ErrorState(message: _error!, onRetry: _load)
                : RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                      children: [
                        if (!isPaid) const LockedFeatureBanner(),
                        if (isPaid && s != null)
                          WalletSummaryPanel(
                            summary: s,
                            onCashOut: () => _cashOut(balance),
                            onTransfer: () => _transfer(balance),
                          ),
                        if (isPaid) ...[
                          const SizedBox(height: 10),
                          DateFilterBar(
                            compact: true,
                            from: _from,
                            to: _to,
                            onPickFrom: () => _pickDate(true),
                            onPickTo: () => _pickDate(false),
                            onSearch: _load,
                            onReset: _reset,
                            dropdownValue: _type,
                            dropdownLabel: 'Type',
                            dropdownOptions: const [
                              FilterDropdownOption(value: '', label: 'All Types'),
                              FilterDropdownOption(value: '1', label: 'Cash In'),
                              FilterDropdownOption(value: '2', label: 'Tax'),
                              FilterDropdownOption(value: '3', label: 'Withdrawal'),
                              FilterDropdownOption(value: '4', label: 'Transfer'),
                            ],
                            onDropdownChanged: (v) => setState(() => _type = v ?? ''),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              const Text(
                                'Cash Wallet Ledger',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$ledgerCount',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                                ),
                              ),
                              const Spacer(),
                              if (_loading)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (!_loading && _cashItems.isEmpty)
                            const EmptyState(
                              message: 'No transactions in this period.\nWiden the date range and tap Search.',
                              icon: Icons.account_balance_wallet_outlined,
                            )
                          else
                            ..._cashItems.map((m) => CashWalletHistoryTile(transaction: m)),
                          const Divider(height: 28),
                        ],
                        const Text(
                          'Purchase Transactions',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                        ),
                        const SizedBox(height: 10),
                        if (_purchaseItems.isEmpty)
                          const EmptyState(message: 'No purchase transactions.', icon: Icons.receipt_long_outlined)
                        else
                          ..._purchaseItems.map((e) {
                            final m = e as Map<String, dynamic>;
                            return PremiumListCard(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m['transaction_type']?.toString() ?? 'Transaction',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        Text(
                                          formatDate(m['created_at']?.toString()),
                                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(formatNrs(m['amount'] ?? 0), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
      ),
    );
  }
}
