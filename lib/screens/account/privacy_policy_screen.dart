import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/legal_section.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _sections = [
    LegalSection('Introduction', 'Serve Cafe respects your privacy. This policy explains how we collect, use, and protect your personal information when you use our services.'),
    LegalSection('Information We Collect', 'We collect information you provide during registration and use of our platform, including name, email, phone number, address, and transaction history.'),
    LegalSection('How We Use Your Information', 'Your information is used to provide services, process transactions, manage your membership, and communicate important updates about your account.'),
    LegalSection('Data Security', 'We implement appropriate technical and organizational measures to protect your personal data against unauthorized access, alteration, or disclosure.'),
    LegalSection('Your Rights', 'You may request access to, correction of, or deletion of your personal data by contacting our support team.'),
    LegalSection('Contact', 'For privacy-related inquiries, contact us at support@servecafe.com. Last updated: January 1, 2025.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Privacy Policy', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _sections.map((s) => s.build()).toList(),
      ),
    );
  }
}
