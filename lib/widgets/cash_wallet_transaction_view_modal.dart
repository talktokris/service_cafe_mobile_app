import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/utils/transaction_helpers.dart';
import 'package:serve_cafe_mobile/widgets/payout_icon.dart';

String _cashOutMethodLabel(String? method) {
  switch (method) {
    case 'bank_transfer':
      return 'Bank Transfer';
    case 'esewa':
      return 'eSewa Wallet';
    case 'khalti':
      return 'Khalti Wallet';
    default:
      return method ?? '—';
  }
}

String _formatAccountType(dynamic value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return '—';
  if (raw == 'saving') return 'Saving';
  if (raw == 'current') return 'Current';
  return raw[0].toUpperCase() + raw.substring(1);
}

bool _filled(dynamic v) => v != null && v.toString().trim().isNotEmpty;

/// Full-screen style dialog matching web [CashOutTransactionViewModal].
void showCashWalletTransactionViewModal(
  BuildContext context,
  Map<String, dynamic> transaction, {
  String title = 'Transaction Details',
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => _CashWalletTransactionViewDialog(
      transaction: transaction,
      title: title,
    ),
  );
}

class _CashWalletTransactionViewDialog extends StatelessWidget {
  const _CashWalletTransactionViewDialog({
    required this.transaction,
    required this.title,
  });

  final Map<String, dynamic> transaction;
  final String title;

  @override
  Widget build(BuildContext context) {
    final type = (transaction['transaction_type'] as num?)?.toInt();
    final isWithdrawal = type == 3;
    final cashOutStatus = (transaction['cash_out_status'] as num?)?.toInt();
    final isPaid = cashOutStatus == 1;
    final dc = (transaction['debit_credit'] as num?)?.toInt() ?? 0;
    final runBal = transaction['calculated_balance'];
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
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
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
                    _section(
                      title: 'Transaction',
                      child: Column(
                        children: [
                          _detailRow(
                            'Transaction ID',
                            '#${transaction['id']}',
                          ),
                          _detailRow(
                            'Type',
                            cashWalletTypeLabel(type),
                          ),
                          _detailRow(
                            'Description',
                            transaction['name']?.toString() ??
                                transaction['type']?.toString() ??
                                '—',
                          ),
                          _detailRow(
                            'Amount',
                            formatNrs(transaction['amount']),
                            valueColor: debitCreditAmountColor(dc),
                          ),
                          _detailRow(
                            'Debit / Credit',
                            dc == 1 ? 'Debit' : 'Credit',
                          ),
                          _detailRow(
                            'Request date & time',
                            formatDateTime(
                              transaction['transaction_date']?.toString() ??
                                  transaction['created_at']?.toString(),
                            ),
                          ),
                          if (runBal != null)
                            _detailRow(
                              'Balance after',
                              formatNrs(runBal),
                            ),
                          if (isWithdrawal)
                            _detailRow(
                              'Payout status',
                              isPaid ? 'Paid' : 'Pending',
                              valueColor:
                                  isPaid ? Colors.green.shade700 : Colors.orange.shade800,
                            ),
                        ],
                      ),
                    ),
                    if (isWithdrawal) ...[
                      const SizedBox(height: 12),
                      _section(
                        title: 'Payout method',
                        child: _payoutDetails(transaction),
                      ),
                      const SizedBox(height: 12),
                      _section(
                        title: 'Payment processing',
                        child: Column(
                          children: [
                            _detailRow(
                              'Reference number',
                              _filled(transaction['cash_out_reference_no'])
                                  ? transaction['cash_out_reference_no']
                                      .toString()
                                  : (isPaid ? '—' : 'Not paid yet'),
                              mono: true,
                            ),
                            _detailRow(
                              'Payment description',
                              _filled(transaction['cash_out_description'])
                                  ? transaction['cash_out_description']
                                      .toString()
                                  : (isPaid ? '—' : 'Not paid yet'),
                            ),
                            _detailRow(
                              'Paid date & time',
                              isPaid
                                  ? formatDateTime(
                                      transaction['cash_out_date']?.toString(),
                                    )
                                  : 'Not paid yet',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value, {
    bool mono = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: mono ? 'monospace' : null,
                color: valueColor ?? AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _payoutDetails(Map<String, dynamic> tx) {
    final method = tx['cash_out_method']?.toString();
    if (!_filled(method)) {
      return const Text(
        'No payout method recorded for this request.',
        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
      );
    }

    final iconAsset = switch (method) {
      'esewa' => PayoutAssets.esewa,
      'khalti' => PayoutAssets.khalti,
      _ => PayoutAssets.bank,
    };

    final children = <Widget>[
      Row(
        children: [
          PayoutIcon(asset: iconAsset, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _cashOutMethodLabel(method),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
    ];

    if (method == 'bank_transfer') {
      if (_filled(tx['cash_out_bank_name'])) {
        children.add(_detailRow('Bank', tx['cash_out_bank_name'].toString()));
      }
      if (_filled(tx['cash_out_account_type'])) {
        children.add(_detailRow(
          'Account type',
          _formatAccountType(tx['cash_out_account_type']),
        ));
      }
      if (_filled(tx['cash_out_account_holder_name'])) {
        children.add(_detailRow(
          'Holder',
          tx['cash_out_account_holder_name'].toString(),
        ));
      }
      if (_filled(tx['cash_out_account_number'])) {
        children.add(_detailRow(
          'Account number',
          tx['cash_out_account_number'].toString(),
          mono: true,
        ));
      }
    } else if (method == 'esewa' && _filled(tx['cash_out_esewa_wallet'])) {
      children.add(_detailRow(
        'eSewa number',
        tx['cash_out_esewa_wallet'].toString(),
        mono: true,
      ));
    } else if (method == 'khalti' && _filled(tx['cash_out_khalti_wallet'])) {
      children.add(_detailRow(
        'Khalti number',
        tx['cash_out_khalti_wallet'].toString(),
        mono: true,
      ));
    }

    return Column(children: children);
  }
}
