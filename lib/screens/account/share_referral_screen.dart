import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/url_launch.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';

class ShareReferralScreen extends StatefulWidget {
  const ShareReferralScreen({super.key});

  @override
  State<ShareReferralScreen> createState() => _ShareReferralScreenState();
}

class _ShareReferralScreenState extends State<ShareReferralScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  static const _benefits = [
    ('Earn Together', 'Build your network and grow earnings with referrals.'),
    ('Easy Sharing', 'Share your unique link via WhatsApp, Viber, or email.'),
    ('Lifetime Value', 'Help others join Serve Cafe Forever Earning Program.'),
    ('Track Growth', 'See how many members joined using your code.'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final body = await context.read<ApiClient>().get(ApiEndpoints.referral);
      if (mounted) setState(() => _data = body['data'] as Map<String, dynamic>);
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final hasCode = _data?['has_referral_code'] == true;
    final link = _data?['referral_link']?.toString() ?? '';
    final message = _data?['share_message']?.toString() ?? '';

    return Scaffold(
      appBar: const GradientAppBar(title: 'Share Referral', showBack: true),
      body: _loading
          ? const LoadingOverlay()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (!hasCode) ...[
                        Card(
                          color: Colors.orange.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text('Set your referral address first to share your link.'),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => context.push('/account/change-referral'),
                                  child: const Text('Set Referral Address'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        _headerCard(),
                        const SizedBox(height: 16),
                        Text('Code: ${_data?['referral_code']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        Text('Referrals: ${_data?['referral_count'] ?? 0}', style: const TextStyle(color: AppColors.textMuted)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                          child: SelectableText(link, style: const TextStyle(fontSize: 13)),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _actionBtn(Icons.copy, 'Copy', () {
                              Clipboard.setData(ClipboardData(text: link));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied')));
                            }),
                            if (user?.phone != null && user!.phone!.isNotEmpty) ...[
                              _actionBtn(Icons.chat, 'WhatsApp', () => openWhatsAppShare(phone: user.phone!, message: message)),
                              _actionBtn(Icons.phone_in_talk, 'Viber', () => openViberShare(phone: user.phone!, message: message)),
                            ],
                            _actionBtn(Icons.email_outlined, 'Email', () {
                              openEmail(subject: 'Join Serve Cafe Forever Earning Program', body: message, to: '');
                            }),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Text('Why Share?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 12),
                      ..._benefits.map((b) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(Icons.star, color: AppColors.accent),
                              title: Text(b.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(b.$2),
                            ),
                          )),
                    ],
                  ),
                ),
    );
  }

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: AppColors.gradient, borderRadius: BorderRadius.circular(14)),
      child: const Column(
        children: [
          Icon(Icons.share, color: Colors.white, size: 40),
          SizedBox(height: 8),
          Text('Share Serve Cafe', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('Invite others to join the Forever Earning Program', style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(onPressed: onTap, icon: Icon(icon, size: 18), label: Text(label));
  }
}
