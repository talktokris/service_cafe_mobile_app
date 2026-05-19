import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class SummaryStatRow extends StatelessWidget {
  const SummaryStatRow({super.key, required this.stats});

  final List<SummaryStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(stat.label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(
            stat.value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: stat.color ?? AppColors.primary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
