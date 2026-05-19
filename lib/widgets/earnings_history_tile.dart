import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/utils/transaction_helpers.dart';
import 'package:serve_cafe_mobile/widgets/debit_credit_chip.dart';

class EarningsHistoryTile extends StatelessWidget {
  const EarningsHistoryTile({super.key, required this.earning});

  final Map<String, dynamic> earning;

  @override
  Widget build(BuildContext context) {
    final dc = (earning['debit_credit'] as num?)?.toInt() ?? 0;
    final type = (earning['transation_type'] as num?)?.toInt();
    final status = (earning['status'] as num?)?.toInt() ?? 0;
    final amount = earning['ammout'] ?? 0;
    final accent = earningTypeColor(type);
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
                              color: earningTypeBg(type),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              earningTypeLabel(type),
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: accent),
                            ),
                          ),
                          const Spacer(),
                          DebitCreditChip(debitCredit: dc, compact: true),
                          const SizedBox(width: 6),
                          Icon(
                            status == 1 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            size: 16,
                            color: status == 1 ? AppColors.success : AppColors.danger,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        earning['earning_name']?.toString() ?? 'Earning',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (earning['earning_description'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          earning['earning_description'].toString(),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 12, color: AppColors.textMuted.withValues(alpha: 0.8)),
                          const SizedBox(width: 4),
                          Text(
                            formatDate(earning['created_at']?.toString()),
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          const Spacer(),
                          Text(
                            '${isCredit ? '+' : '−'}${formatNrs(amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: debitCreditAmountColor(dc),
                            ),
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
