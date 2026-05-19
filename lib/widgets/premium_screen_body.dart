import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';

/// Wraps tab screen content with a subtle premium page background.
class PremiumScreenBody extends StatelessWidget {
  const PremiumScreenBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppDecorations.pageGradient),
      child: child,
    );
  }
}
