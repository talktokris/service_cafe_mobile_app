import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class LockedFeatureBanner extends StatelessWidget {
  const LockedFeatureBanner({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (child != null)
          Opacity(opacity: 0.35, child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), child: child)),
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Icon(Icons.lock_outline, color: Colors.white, size: 48),
              SizedBox(height: 12),
              Text(
                'Paid Members Only',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This feature is available for Paid Members. Contact admin to upgrade.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
