import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class SummaryStatRow extends StatelessWidget {
  const SummaryStatRow({super.key, required this.stats});

  final List<SummaryStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _StatCard(stat: stats[i])),
        ],
      ],
    );
  }
}

class SummaryStat {
  const SummaryStat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final SummaryStat stat;

  @override
  Widget build(BuildContext context) {
    final accent = stat.color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: AppDecorations.tintedCard(accent.withValues(alpha: 0.08)),
      child: Column(
        children: [
          Text(
            stat.label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: accent.withValues(alpha: 0.85)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            stat.value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: accent, letterSpacing: -0.2),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
