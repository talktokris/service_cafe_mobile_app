import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/url_launch.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  static const _faqs = [
    ('How do I check my wallet balance?', 'Your purchase wallet balance is shown on the Home screen and Wallet tab.'),
    ('How do I upgrade to a paid member?', 'Contact your branch administrator or head office to upgrade your membership.'),
    ('What are your business hours?', 'Visit our office during standard business hours or call us for assistance.'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final body = await context.read<ApiClient>().get(ApiEndpoints.support);
      if (mounted) setState(() => _data = body['data'] as Map<String, dynamic>);
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _data?['support_email']?.toString() ?? '';
    final phone = _data?['support_phone']?.toString() ?? '';
    final address = _data?['support_address']?.toString() ?? '';

    return Scaffold(
      appBar: const GradientAppBar(title: 'Support', showBack: true),
      body: _loading
          ? const LoadingOverlay()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(Icons.support_agent, size: 48, color: AppColors.accent),
                            const SizedBox(height: 12),
                            const Text('How Can We Help You?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            const Text('Reach out to our support team', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _contactBtn(Icons.email, 'Email Support', AppColors.accent, () => openEmail(to: email, subject: 'Serve Cafe Support', body: '')),
                    const SizedBox(height: 8),
                    _contactBtn(Icons.phone, 'Call Us', Colors.green, () => openPhone(phone)),
                    const SizedBox(height: 8),
                    _contactBtn(Icons.location_on, 'Visit Office', AppColors.primary, () => openMapsSearch(address)),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Contact Details', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('Email: $email'),
                            Text('Phone: $phone'),
                            Text('Address: $address'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('FAQ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ..._faqs.map((f) => Card(
                          margin: const EdgeInsets.only(top: 8),
                          child: ExpansionTile(title: Text(f.$1, style: const TextStyle(fontWeight: FontWeight.w500)), children: [
                            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Text(f.$2)),
                          ]),
                        )),
                  ],
                ),
    );
  }

  Widget _contactBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14)),
      ),
    );
  }
}
