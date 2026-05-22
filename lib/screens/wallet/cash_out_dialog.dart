import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/widgets/payout_icon.dart';

class _CashOutMethod {
  const _CashOutMethod(this.value, this.label, this.iconAsset);
  final String value;
  final String label;
  final String iconAsset;
}

const _methods = [
  _CashOutMethod('bank_transfer', 'Bank Transfer', PayoutAssets.bank),
  _CashOutMethod('esewa', 'eSewa Wallet', PayoutAssets.esewa),
  _CashOutMethod('khalti', 'Khalti Wallet', PayoutAssets.khalti),
];

class CashOutDialog extends StatefulWidget {
  const CashOutDialog({
    super.key,
    required this.currentBalance,
    required this.maxWithdrawAmount,
    this.dailyRemaining = 20000,
    this.dailyCashOutLimit = 20000,
  });

  final double currentBalance;
  final double maxWithdrawAmount;
  final double dailyRemaining;
  final double dailyCashOutLimit;

  @override
  State<CashOutDialog> createState() => _CashOutDialogState();
}

class _CashOutDialogState extends State<CashOutDialog> {
  final _amount = TextEditingController();
  bool _loading = false;
  bool _loadingSetup = true;
  String? _error;
  String _method = 'bank_transfer';
  Map<String, dynamic>? _setup;

  double get _maxAmount => widget.maxWithdrawAmount.clamp(0, double.infinity);

  _CashOutMethod? get _selectedMeta {
    for (final m in _methods) {
      if (m.value == _method) return m;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadSetup();
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _loadSetup() async {
    try {
      final body =
          await context.read<ApiClient>().get(ApiEndpoints.profileBankEwallet);
      final data = body['data'] as Map<String, dynamic>? ?? {};
      if (mounted) {
        setState(() {
          _setup = data;
          _method = _firstAvailableMethod(data);
          _loadingSetup = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _setup = {};
          _loadingSetup = false;
          _error = ApiClient.friendlyError(e);
        });
      }
    }
  }

  String _firstAvailableMethod(Map<String, dynamic> setup) {
    for (final m in _methods) {
      if (_hasSetup(setup, m.value)) return m.value;
    }
    return 'bank_transfer';
  }

  bool _hasSetup(Map<String, dynamic>? setup, String method) {
    if (setup == null) return false;
    switch (method) {
      case 'bank_transfer':
        return _filled(setup['bank_account_name']) &&
            _filled(setup['account_holder_name']) &&
            _filled(setup['account_number']);
      case 'esewa':
        return _filled(setup['esewa_wallet']);
      case 'khalti':
        return _filled(setup['khalti_wallet']);
      default:
        return false;
    }
  }

  bool _filled(dynamic v) => v != null && v.toString().trim().isNotEmpty;

  String _formatAccountType(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) return '';
    if (raw == 'saving') return 'Saving';
    if (raw == 'current') return 'Current';
    return raw[0].toUpperCase() + raw.substring(1);
  }

  bool get _setupReady => _hasSetup(_setup, _method);

  Future<void> _submit() async {
    final value = double.tryParse(_amount.text);
    if (value == null || value <= 0) {
      setState(() => _error = 'Please enter a valid amount');
      return;
    }
    if (value > widget.currentBalance) {
      setState(() => _error = 'Amount exceeds your cash wallet balance');
      return;
    }
    if (value > _maxAmount) {
      setState(() => _error =
          'Amount exceeds max ${formatNrs(_maxAmount)} for this request');
      return;
    }
    if (!_setupReady) {
      setState(() => _error = 'Complete Bank & eWallet Setup for this method');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<ApiClient>().post(
        ApiEndpoints.cashWalletCashOut,
        data: {'amount': value, 'cash_out_method': _method},
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _methodTile(_CashOutMethod m) {
    final selected = _method == m.value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _loading || _loadingSetup
            ? null
            : () => setState(() => _method = m.value),
        borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
            border: Border.all(
              color: selected ? AppColors.accent : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
            color: selected
                ? AppColors.accent.withValues(alpha: 0.06)
                : Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 20,
                color: selected ? AppColors.accent : AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              PayoutIcon(asset: m.iconAsset, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  m.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current cash wallet balance',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.green.shade900.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatNrs(widget.currentBalance),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.green.shade800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          _limitChip('Max per request', formatNrs(_maxAmount)),
          const SizedBox(height: 6),
          _limitChip('24-hour limit', formatNrs(widget.dailyCashOutLimit)),
          const SizedBox(height: 6),
          _limitChip('Remaining today', formatNrs(widget.dailyRemaining)),
        ],
      ),
    );
  }

  Widget _limitChip(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _detailsPanel() {
    if (_loadingSetup) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
        ),
      );
    }

    if (!_setupReady) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payout details for this method are not set up yet.',
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/account/bank-ewallet-setup');
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Open Bank & eWallet Setup',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    final s = _setup!;
    final meta = _selectedMeta;
    final children = <Widget>[];

    if (_method == 'bank_transfer') {
      children.addAll([
        _detailRow('Bank', s['bank_account_name']?.toString() ?? ''),
        if (_filled(s['account_type']))
          _detailRow('Account type', _formatAccountType(s['account_type'])),
        _detailRow('Account holder', s['account_holder_name']?.toString() ?? ''),
        _detailRow('Account number', s['account_number']?.toString() ?? '',
            mono: true),
      ]);
    } else if (_method == 'esewa') {
      children.add(
        _detailRow('eSewa number', s['esewa_wallet']?.toString() ?? '',
            mono: true),
      );
    } else {
      children.add(
        _detailRow('Khalti number', s['khalti_wallet']?.toString() ?? '',
            mono: true),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meta != null)
            Row(
              children: [
                PayoutIcon(asset: meta.iconAsset, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Payout details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          if (meta != null) const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: mono ? 'monospace' : null,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxH = MediaQuery.sizeOf(context).height * 0.88;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Cash Out',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _balanceCard(),
                    const SizedBox(height: 16),
                    const Text(
                      'Cash out method',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._methods.map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _methodTile(m),
                      ),
                    ),
                    _detailsPanel(),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _amount,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      enabled: _setupReady && !_loading,
                      decoration: InputDecoration(
                        labelText: 'Cash out amount (NRS)',
                        hintText: 'Max ${formatNrs(_maxAmount)}',
                        prefixIcon: const Icon(Icons.payments_outlined),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(AppDecorations.radiusSm),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _loading || !_setupReady || _maxAmount <= 0
                          ? null
                          : _submit,
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
