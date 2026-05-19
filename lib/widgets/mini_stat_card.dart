import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

/// Compact stat tile used in earnings/wallet summary rows.
class MiniStatCard extends StatelessWidget {
  const MiniStatCard({
    super.key,
    required this.label,
    required this.value,
    this.hint,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String value;
  final String? hint;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
        boxShadow: AppDecorations.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: accent),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accent.withValues(alpha: 0.95),
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: accent,
                letterSpacing: -0.3,
                height: 1.1,
              ),
            ),
          ),
          if (hint != null && hint!.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              hint!,
              style: const TextStyle(fontSize: 9, color: AppColors.textMuted, height: 1.15),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
