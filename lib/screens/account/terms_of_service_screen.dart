import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/legal_section.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  static const _sections = [
    LegalSection('Agreement', 'By using Serve Cafe services, you agree to these Terms of Service. If you do not agree, please do not use our platform.'),
    LegalSection('Membership', 'Members must provide accurate information during registration. Free and paid membership tiers have different features and benefits as described on the platform.'),
    LegalSection('Earnings & Wallet', 'Earnings, withdrawals, and wallet transfers are subject to platform rules, minimum amounts, and applicable fees or taxes as configured by Serve Cafe.'),
    LegalSection('Referral Program', 'Referral codes must not be misleading or used for fraudulent purposes. Serve Cafe reserves the right to modify referral terms.'),
    LegalSection('Conduct', 'You agree not to misuse the platform, attempt unauthorized access, or engage in activities that harm other members or the business.'),
    LegalSection('Changes', 'We may update these terms at any time. Continued use of the service constitutes acceptance of updated terms. Last updated: January 1, 2025.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Terms of Service', showBack: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _sections.map((s) => s.build()).toList(),
      ),
    );
  }
}
