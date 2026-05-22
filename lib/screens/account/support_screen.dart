import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/url_launch.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/premium_screen_body.dart';
import 'package:serve_cafe_mobile/widgets/pull_to_refresh.dart';

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
    (
      'How do I check my wallet balance?',
      'Your purchase wallet balance is on the Home screen and Wallet tab. Cash wallet balance is on the Wallet tab for paid members.',
    ),
    (
      'How do I upgrade to a paid member?',
      'Contact your branch administrator or head office to upgrade your membership.',
    ),
    (
      'What are your business hours?',
      'Reach us by phone or email during standard business hours. We will respond as soon as we can.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final body = await context.read<ApiClient>().get(ApiEndpoints.support);
      if (mounted) {
        setState(() => _data = body['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _email => (_data?['support_email'] as String?)?.trim() ?? '';
  String get _phone => (_data?['support_phone'] as String?)?.trim() ?? '';
  String get _address => (_data?['support_address'] as String?)?.trim() ?? '';

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _emailSupport() async {
    if (_email.isEmpty) {
      _toast('Support email is not configured yet.');
      return;
    }
    final ok = await openEmail(
      to: _email,
      subject: 'Serve Cafe Support',
      body: 'Hello Serve Cafe support team,\n\n',
    );
    if (!ok && mounted) {
      _toast('Could not open your email app. Email: $_email');
    }
  }

  Future<void> _callSupport() async {
    if (_phone.isEmpty) {
      _toast('Support phone number is not configured yet.');
      return;
    }
    final ok = await openPhone(_phone);
    if (!ok && mounted) {
      _toast('Could not open the phone dialer. Number: $_phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Support', showBack: true),
      body: PremiumScreenBody(
        child: _loading
            ? const LoadingOverlay(message: 'Loading support info...')
            : _error != null
                ? ErrorState(message: _error!, onRetry: _load)
                : PullToRefresh.list(
                    onRefresh: _load,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      _heroCard(),
                      const SizedBox(height: 20),
                      const Text(
                        'Get in touch',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _actionTile(
                        icon: Icons.email_outlined,
                        iconBg: AppColors.accent.withValues(alpha: 0.12),
                        iconColor: AppColors.accent,
                        title: 'Email Support',
                        subtitle: _email.isNotEmpty
                            ? _email
                            : 'Not available',
                        enabled: _email.isNotEmpty,
                        onTap: _emailSupport,
                      ),
                      const SizedBox(height: 10),
                      _actionTile(
                        icon: Icons.phone_in_talk_outlined,
                        iconBg: Colors.green.withValues(alpha: 0.12),
                        iconColor: Colors.green.shade700,
                        title: 'Call Us',
                        subtitle:
                            _phone.isNotEmpty ? _phone : 'Not available',
                        enabled: _phone.isNotEmpty,
                        onTap: _callSupport,
                      ),
                      const SizedBox(height: 16),
                      _infoCard(
                        icon: Icons.location_on_outlined,
                        iconBg: AppColors.primary.withValues(alpha: 0.1),
                        iconColor: AppColors.primary,
                        title: 'Office address',
                        body: _address.isNotEmpty
                            ? _address
                            : 'Address not configured.',
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'FAQ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._faqs.map(_faqTile),
                    ],
                  ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.gradientVertical,
        borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              size: 36,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'How can we help you?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap email or call to reach our team',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: Ink(
          decoration: AppDecorations.premiumCard(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: enabled
                            ? AppColors.textMuted
                            : AppColors.textMuted.withValues(alpha: 0.7),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: enabled ? AppColors.accent : AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.premiumCard(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqTile((String, String) faq) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: AppDecorations.premiumCard(),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: AppColors.accent,
          collapsedIconColor: AppColors.textMuted,
          title: Text(
            faq.$1,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                faq.$2,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
