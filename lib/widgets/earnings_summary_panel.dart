import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/widgets/mini_stat_card.dart';

/// Earnings dashboard header: balance hero + compact stat row.
class EarningsSummaryPanel extends StatelessWidget {
  const EarningsSummaryPanel({
    super.key,
    required this.summary,
    required this.onWithdraw,
  });

  final Map<String, dynamic> summary;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    final balance = summary['earning_balance'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BalanceHero(balance: balance, onWithdraw: onWithdraw),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: MiniStatCard(
                  label: 'Total Earnings',
                  value: formatNrs(summary['total_earnings'] ?? 0),
                  hint: 'Month ${formatNrs(summary['month_earnings'] ?? 0)}',
                  accent: AppColors.success,
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: MiniStatCard(
                  label: 'Withdrawals',
                  value: formatNrs(summary['total_withdrawals'] ?? 0),
                  hint: 'Month ${formatNrs(summary['month_withdrawals'] ?? 0)}',
                  accent: AppColors.danger,
                  icon: Icons.north_east_rounded,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: MiniStatCard(
                  label: 'Redistributions',
                  value: formatNrs(summary['total_redistributions'] ?? 0),
                  hint: 'Month ${formatNrs(summary['month_redistributions'] ?? 0)}',
                  accent: AppColors.info,
                  icon: Icons.sync_rounded,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({required this.balance, required this.onWithdraw});

  final dynamic balance;
  final VoidCallback onWithdraw;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
        gradient: AppColors.gradientVertical,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.savings_rounded, size: 100, color: Colors.white.withValues(alpha: 0.06)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Balance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        formatNrs(balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ready to withdraw',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: onWithdraw,
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.payments_rounded, size: 16, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          'Withdraw',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
