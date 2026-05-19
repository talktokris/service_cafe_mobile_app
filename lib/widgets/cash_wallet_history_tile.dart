import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/utils/transaction_helpers.dart';
import 'package:serve_cafe_mobile/widgets/debit_credit_chip.dart';

class CashWalletHistoryTile extends StatelessWidget {
  const CashWalletHistoryTile({super.key, required this.transaction});

  final Map<String, dynamic> transaction;

  @override
  Widget build(BuildContext context) {
    final dc = (transaction['debit_credit'] as num?)?.toInt() ?? 0;
    final type = (transaction['transaction_type'] as num?)?.toInt();
    final amount = transaction['amount'] ?? 0;
    final runBal = transaction['calculated_balance'];
    final accent = cashWalletTypeColor(type);
    final isCredit = dc == 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: cashWalletTypeBg(type),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              cashWalletTypeLabel(type),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: accent),
                            ),
                          ),
                          const Spacer(),
                          DebitCreditChip(debitCredit: dc, compact: true),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        transaction['name']?.toString() ?? 'Transaction',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${formatDateTime(transaction['transaction_date']?.toString() ?? transaction['created_at']?.toString())} · #${transaction['id']}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '${isCredit ? '+' : '−'}${formatNrs(amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: debitCreditAmountColor(dc),
                            ),
                          ),
                          const Spacer(),
                          if (runBal != null)
                            Text(
                              'Bal ${formatNrs(runBal)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
