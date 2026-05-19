import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/widgets/mini_stat_card.dart';

class WalletSummaryPanel extends StatelessWidget {
  const WalletSummaryPanel({
    super.key,
    required this.summary,
    required this.onCashOut,
    required this.onTransfer,
  });

  final Map<String, dynamic> summary;
  final VoidCallback onCashOut;
  final VoidCallback onTransfer;

  @override
  Widget build(BuildContext context) {
    final balance = summary['total_balance'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _BalanceHero(
          balance: balance,
          onCashOut: onCashOut,
          onTransfer: onTransfer,
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: MiniStatCard(
                  label: 'Cash In',
                  value: formatNrs(summary['total_cash_in'] ?? 0),
                  accent: AppColors.success,
                  icon: Icons.south_west_rounded,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: MiniStatCard(
                  label: 'Cash Out',
                  value: formatNrs(summary['total_cash_out'] ?? 0),
                  accent: AppColors.danger,
                  icon: Icons.north_east_rounded,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: MiniStatCard(
                  label: 'Transfer',
                  value: formatNrs(summary['total_transfer'] ?? 0),
                  accent: AppColors.info,
                  icon: Icons.swap_horiz_rounded,
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
  const _BalanceHero({
    required this.balance,
    required this.onCashOut,
    required this.onTransfer,
  });

  final dynamic balance;
  final VoidCallback onCashOut;
  final VoidCallback onTransfer;

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
            right: -16,
            top: -16,
            child: Icon(Icons.account_balance_wallet_rounded, size: 96, color: Colors.white.withValues(alpha: 0.06)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cash Wallet Balance',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12, fontWeight: FontWeight.w500),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _HeroButton(label: 'Cash Out', icon: Icons.money_off_rounded, onTap: onCashOut)),
                  const SizedBox(width: 8),
                  Expanded(child: _HeroButton(label: 'Transfer', icon: Icons.swap_horiz_rounded, onTap: onTransfer, outlined: true)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outlined ? Colors.white.withValues(alpha: 0.15) : Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: outlined ? Colors.white : AppColors.accent),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: outlined ? Colors.white : AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
