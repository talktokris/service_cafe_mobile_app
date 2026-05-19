import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/widgets/referral_tree/referral_tree_constants.dart';

class ReferralTreeLegend extends StatelessWidget {
  const ReferralTreeLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Legend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const _LegendStatusRow(active: true),
            const SizedBox(height: 8),
            const _LegendStatusRow(active: false),
            const Divider(height: 24),
            const Text('Badge Ranks (Highest to Lowest):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                for (final rank in BadgeRankStyle.ranks) _BadgeLegendItem(rank: rank),
              ],
            ),
            const Divider(height: 24),
            const _LegendHint(
              icon: Icons.arrow_downward,
              iconBg: Color(0xFFFACC15),
              text: 'Tap ↓ to view this member\'s downline (5 levels from that user)',
            ),
            const SizedBox(height: 8),
            const _LegendHint(
              iconWidget: Text('+', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              text: 'Tap + / − to expand or collapse children in the current view',
            ),
            const SizedBox(height: 8),
            const _LegendHint(
              iconWidget: Icon(Icons.touch_app_outlined, size: 16),
              text: 'Tap a member card to center the tree on that member',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(width: 32, height: 2, color: ReferralTreeStyle.lineColor),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Connector lines show referral relationships', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendStatusRow extends StatelessWidget {
  const _LegendStatusRow({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 32,
            height: 16,
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(colors: [ReferralTreeStyle.teal50, ReferralTreeStyle.cyan50])
                  : null,
              color: active ? null : Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  color: active ? ReferralTreeStyle.teal500 : Colors.grey.shade400,
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(active ? 'Active Member' : 'Inactive Member', style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class _BadgeLegendItem extends StatelessWidget {
  const _BadgeLegendItem({required this.rank});

  final BadgeRankStyle rank;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: rank.colors),
            border: Border.all(color: Colors.white),
          ),
          alignment: Alignment.center,
          child: Text(rank.initial, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 6),
        Text(rank.name, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _LegendHint extends StatelessWidget {
  const _LegendHint({
    required this.text,
    this.icon,
    this.iconBg,
    this.iconWidget,
  });

  final String text;
  final IconData? icon;
  final Color? iconBg;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: iconBg ?? Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          alignment: Alignment.center,
          child: iconWidget ?? Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
