import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.accent;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.premiumCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.15), accent.withValues(alpha: 0.05)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
