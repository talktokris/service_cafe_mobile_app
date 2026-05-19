import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class SummaryCardData {
  const SummaryCardData({
    required this.label,
    required this.value,
    this.subtitle,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.icon,
  });

  final String label;
  final String value;
  final String? subtitle;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? icon;
}

class SummaryCardsGrid extends StatelessWidget {
  const SummaryCardsGrid({
    super.key,
    required this.cards,
    this.compact = true,
  });

  final List<SummaryCardData> cards;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: compact ? 6 : 12,
      crossAxisSpacing: compact ? 6 : 12,
      childAspectRatio: compact ? 2.35 : 1.28,
      children: cards.map((c) => _SummaryCard(data: c, compact: compact)).toList(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.data, required this.compact});

  final SummaryCardData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final accent = data.color ?? AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 14, vertical: compact ? 8 : 14),
      decoration: AppDecorations.tintedCard(data.backgroundColor ?? accent.withValues(alpha: 0.08)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data.icon != null) ...[
            Container(
              width: compact ? 26 : 32,
              height: compact ? 26 : 32,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(compact ? 6 : 8),
              ),
              child: Icon(data.icon, size: compact ? 13 : 16, color: accent),
            ),
            SizedBox(width: compact ? 6 : 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.label,
                  style: TextStyle(
                    fontSize: compact ? 9 : 11,
                    fontWeight: FontWeight.w600,
                    color: accent.withValues(alpha: 0.9),
                    height: 1.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 2 : 4),
                Text(
                  data.value,
                  style: TextStyle(
                    fontSize: compact ? 12 : 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: accent,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (data.subtitle != null) ...[
                  SizedBox(height: compact ? 1 : 4),
                  Text(
                    data.subtitle!,
                    style: TextStyle(
                      fontSize: compact ? 8 : 10,
                      color: AppColors.textMuted,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 3,
            height: compact ? 36 : 28,
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
