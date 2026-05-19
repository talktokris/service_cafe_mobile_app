import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';

class LegalSection {
  const LegalSection(this.title, this.body);

  final String title;
  final String body;

  Widget build() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(height: 1.5, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
