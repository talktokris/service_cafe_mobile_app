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
import 'package:serve_cafe_mobile/widgets/debit_credit_chip.dart';
import 'package:serve_cafe_mobile/widgets/empty_state.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/summary_stat_row.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _txId = TextEditingController();
  List<dynamic> _allItems = [];
  List<dynamic> _items = [];
  Map<String, dynamic>? _summary;
  double _walletBalance = 0;
  bool _loading = true;
  String? _error;
  DateTime? _from;
  DateTime? _to;
  String _natureFilter = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = monthStart(now);
    _to = monthEnd(now);
    _load();
  }

  @override
  void dispose() {
    _txId.dispose();
    super.dispose();
  }

  void _applyNatureFilter() {
    if (_natureFilter.isEmpty) {
      _items = List.from(_allItems);
    } else {
      _items = _allItems.where((e) {
        final m = e as Map<String, dynamic>;
        final nature = m['transaction_nature']?.toString() ?? '';
        final type = m['transaction_type']?.toString() ?? '';
        return nature == _natureFilter || type == _natureFilter;
      }).toList();
    }
  }

  List<FilterDropdownOption> _natureOptions() {
    final set = <String>{};
    for (final e in _allItems) {
      final m = e as Map<String, dynamic>;
      final nature = m['transaction_nature']?.toString();
      if (nature != null && nature.isNotEmpty) set.add(nature);
    }
    return [
      const FilterDropdownOption(value: '', label: 'All Types'),
      ...set.map((n) => FilterDropdownOption(value: n, label: n)),
    ];
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final query = <String, dynamic>{};
      if (_txId.text.isNotEmpty) query['transaction_id'] = _txId.text;
      if (_from != null) query['from_date'] = DateFormat('yyyy-MM-dd').format(_from!);
      if (_to != null) query['to_date'] = DateFormat('yyyy-MM-dd').format(_to!);

      final body = await context.read<ApiClient>().get(ApiEndpoints.transactions, query: query);
      final data = body['data'] as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _allItems = data['transactions'] as List<dynamic>? ?? [];
          _summary = data['summary'] as Map<String, dynamic>?;
          _walletBalance = (data['wallet_balance'] as num?)?.toDouble() ?? 0;
          _applyNatureFilter();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _reset() {
    final now = DateTime.now();
    _txId.clear();
    _from = monthStart(now);
    _to = monthEnd(now);
    setState(() => _natureFilter = '');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Transactions', showBack: true),
      body: _loading && _items.isEmpty
          ? const LoadingOverlay()
          : _error != null && _items.isEmpty
              ? ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Wallet: ${formatNrs(_walletBalance)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 12),
                      if (_summary != null)
                        SummaryStatRow(stats: [
                          SummaryStat(label: 'Debits', value: formatNrs(_summary!['total_debits'] ?? 0), color: Colors.red.shade700),
                          SummaryStat(label: 'Credits', value: formatNrs(_summary!['total_credits'] ?? 0), color: Colors.green.shade700),
                          SummaryStat(label: 'Balance', value: formatNrs(_summary!['balance'] ?? 0)),
                        ]),
                      const SizedBox(height: 16),
                      DateFilterBar(
                        textField: _txId,
                        textFieldLabel: 'Transaction ID',
                        from: _from,
                        to: _to,
                        onPickFrom: () => _pickDate(true),
                        onPickTo: () => _pickDate(false),
                        onSearch: _load,
                        onReset: _reset,
                        dropdownValue: _natureFilter,
                        dropdownLabel: 'Type / Nature',
                        dropdownOptions: _natureOptions(),
                        onDropdownChanged: (v) {
                          setState(() {
                            _natureFilter = v ?? '';
                            _applyNatureFilter();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_items.isEmpty)
                        const EmptyState(message: 'No transactions found for this period. Try adjusting your filters.')
                      else
                        ..._items.map((e) {
                          final m = e as Map<String, dynamic>;
                          final dc = (m['debit_credit'] as num?)?.toInt() ?? 0;
                          final orderId = m['order_id'];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      DebitCreditChip(debitCredit: dc),
                                      const Spacer(),
                                      Text(
                                        formatNrs(m['amount'] ?? 0),
                                        style: TextStyle(fontWeight: FontWeight.bold, color: debitCreditAmountColor(dc)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text('${m['transaction_nature'] ?? ''} · ${m['transaction_type'] ?? ''}', style: const TextStyle(fontSize: 13)),
                                  Text('ID #${m['id']} · ${formatDate(m['created_at']?.toString())}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                                  if (orderId != null)
                                    InkWell(
                                      onTap: () => context.push('/orders/$orderId'),
                                      child: Text(
                                        'Order #$orderId',
                                        style: const TextStyle(fontSize: 12, color: AppColors.accent, decoration: TextDecoration.underline),
                                      ),
                                    ),
                                  if (m['balance'] != null)
                                    Text('Balance: ${formatNrs(m['balance'])}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}
