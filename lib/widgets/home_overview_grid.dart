import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class HomeOverviewItem {
  const HomeOverviewItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;
}

/// 2×2 overview stats for the home dashboard.
class HomeOverviewGrid extends StatelessWidget {
  const HomeOverviewGrid({super.key, required this.items});

  final List<HomeOverviewItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.72,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _OverviewTile(item: items[i]),
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({required this.item});

  final HomeOverviewItem item;

  @override
  Widget build(BuildContext context) {
    final accent = item.accent;
    final child = Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
        boxShadow: AppDecorations.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [accent.withValues(alpha: 0.18), accent.withValues(alpha: 0.06)],
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(item.icon, size: 20, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: accent.withValues(alpha: 0.95),
                    height: 1.15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    item.value,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.textPrimary,
                      height: 1.05,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );

    if (item.onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(14),
        child: child,
      ),
    );
  }
}
