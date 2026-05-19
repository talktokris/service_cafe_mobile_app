import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';

/// Elevated list row card used on earnings, wallet, orders, etc.
class PremiumListCard extends StatelessWidget {
  const PremiumListCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: AppDecorations.premiumCard(),
      child: child,
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: content,
      ),
    );
  }
}
