import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

/// Shared visual tokens for a polished, premium UI.
class AppDecorations {
  AppDecorations._();

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 18;
  static const double radiusXl = 22;

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static BoxDecoration premiumCard({Color? color, Border? border}) => BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(radiusMd),
        border: border,
        boxShadow: cardShadow,
      );

  static BoxDecoration tintedCard(Color tint) => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, tint.withValues(alpha: 0.35)],
        ),
        borderRadius: BorderRadius.circular(radiusMd),
        border: Border.all(color: tint.withValues(alpha: 0.25)),
        boxShadow: softShadow,
      );

  static const pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFAF8F7), Color(0xFFF3F0EE), Color(0xFFEDEAE8)],
    stops: [0.0, 0.35, 1.0],
  );

  static TextStyle sectionTitle(BuildContext context) => Theme.of(context).textTheme.titleMedium!.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      );

  static TextStyle sectionSubtitle(BuildContext context) => Theme.of(context).textTheme.bodySmall!.copyWith(
        color: AppColors.textMuted,
        height: 1.4,
      );
}
