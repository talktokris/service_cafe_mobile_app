import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/screens/earnings/withdraw_dialog.dart';
import 'package:serve_cafe_mobile/utils/api_parsing.dart';
import 'package:serve_cafe_mobile/utils/transaction_helpers.dart';
import 'package:serve_cafe_mobile/widgets/date_filter_bar.dart';
import 'package:serve_cafe_mobile/widgets/earnings_history_tile.dart';
import 'package:serve_cafe_mobile/widgets/earnings_summary_panel.dart';
import 'package:serve_cafe_mobile/widgets/empty_state.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/locked_feature_banner.dart';
import 'package:serve_cafe_mobile/widgets/premium_screen_body.dart';
import 'package:serve_cafe_mobile/widgets/pull_to_refresh.dart';

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
  DateTime? _from;
  DateTime? _to;
  String _type = '';
  int _totalRecords = 0;

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
    final user = context.read<AuthProvider>().user;
    if (user?.isFree == true) {
      setState(() { _loading = false; });
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final query = <String, dynamic>{'per_page': 50};
      if (_from != null) query['from_date'] = DateFormat('yyyy-MM-dd').format(_from!);
      if (_to != null) query['to_date'] = DateFormat('yyyy-MM-dd').format(_to!);
      if (_type.isNotEmpty) query['type'] = _type;

      final body = await context.read<ApiClient>().get(ApiEndpoints.earnings, query: query);
      final data = body['data'] as Map<String, dynamic>;
      if (mounted) {
        final earningsRaw = data['earnings'];
        setState(() {
          _summary = data['summary'] as Map<String, dynamic>?;
          _items = parseApiList(earningsRaw);
          _totalRecords = parseApiTotal(earningsRaw);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
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
        body: PullToRefresh.wrap(
          onRefresh: () async {
            await context.read<AuthProvider>().fetchMe();
          },
          child: const LockedFeatureBanner(child: SizedBox(height: 200)),
        ),
      );
    }

    final s = _summary;
    final count = _totalRecords > 0 ? _totalRecords : _items.length;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Earnings',
        actions: [IconButton(icon: const Icon(Icons.payments_outlined), onPressed: _withdraw)],
      ),
      body: PremiumScreenBody(
        child: _loading && _items.isEmpty && s == null
            ? const LoadingOverlay()
            : _error != null && _items.isEmpty && s == null
                ? ErrorState(message: _error!, onRetry: _load)
                : PullToRefresh.list(
                    onRefresh: _load,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                    children: [
                        if (s != null) EarningsSummaryPanel(summary: s, onWithdraw: _withdraw),
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
                          dropdownLabel: 'Transaction Type',
                          dropdownOptions: const [
                            FilterDropdownOption(value: '', label: 'All Types'),
                            FilterDropdownOption(value: '1', label: 'Earning'),
                            FilterDropdownOption(value: '2', label: 'Withdrawal'),
                            FilterDropdownOption(value: '3', label: 'Redistribution'),
                          ],
                          onDropdownChanged: (v) => setState(() => _type = v ?? ''),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Text(
                              'Earnings History',
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
                                '$count',
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
                        if (!_loading && _items.isEmpty)
                          const EmptyState(
                            message: 'No earnings in this period.\nWiden the date range and tap Search.',
                            icon: Icons.receipt_long_rounded,
                          )
                        else
                          ..._items.map((e) => EarningsHistoryTile(earning: e as Map<String, dynamic>)),
                      ],
                  ),
      ),
    );
  }
}
