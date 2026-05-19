import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_decorations.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/premium_quick_action.dart';
import 'package:serve_cafe_mobile/widgets/premium_screen_body.dart';
import 'package:serve_cafe_mobile/widgets/section_header.dart';
import 'package:serve_cafe_mobile/widgets/home_overview_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _data;
  double? _earningBalance;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = context.read<ApiClient>();
      final isPaid = context.read<AuthProvider>().user?.isPaid ?? false;
      final body = await api.get(ApiEndpoints.dashboard);
      double? earningBal;
      if (isPaid) {
        try {
          final earnBody = await api.get(ApiEndpoints.earnings, query: {'per_page': 1});
          final earnData = earnBody['data'] as Map<String, dynamic>?;
          final summary = earnData?['summary'] as Map<String, dynamic>?;
          earningBal = (summary?['earning_balance'] as num?)?.toDouble();
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _data = body['data'] as Map<String, dynamic>;
          _earningBalance = earningBal;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final stats = _data?['stats'] as Map<String, dynamic>?;
    final isPaid = user?.isPaid == true;
    final firstName = (user?.name ?? '').split(' ').first;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Home'),
      body: PremiumScreenBody(
        child: _loading
            ? const LoadingOverlay(message: 'Loading dashboard...')
            : _error != null
                ? ErrorState(message: _error!, onRetry: _load)
                : RefreshIndicator(
                    color: AppColors.accent,
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      children: [
                        _welcomeHero(firstName, user?.referralCode),
                        const SizedBox(height: 20),
                        const SectionHeader(title: 'Overview', subtitle: 'Your activity at a glance'),
                        HomeOverviewGrid(
                          items: [
                            HomeOverviewItem(
                              label: 'Referrals',
                              value: '${stats?['total_referrals'] ?? 0}',
                              icon: Icons.people_alt_rounded,
                              accent: AppColors.info,
                              onTap: () => context.push('/account/tree-view'),
                            ),
                            HomeOverviewItem(
                              label: 'Orders',
                              value: '${stats?['total_orders'] ?? 0}',
                              icon: Icons.receipt_long_rounded,
                              accent: AppColors.warning,
                              onTap: () => context.go('/orders'),
                            ),
                            HomeOverviewItem(
                              label: 'This Month',
                              value: '${stats?['month_orders'] ?? 0}',
                              icon: Icons.calendar_month_rounded,
                              accent: AppColors.primary,
                              onTap: () => context.go('/orders'),
                            ),
                            HomeOverviewItem(
                              label: isPaid && _earningBalance != null ? 'Earnings' : 'Wallet',
                              value: isPaid && _earningBalance != null
                                  ? formatNrs(_earningBalance!)
                                  : formatNrs(stats?['wallet_balance'] ?? 0),
                              icon: isPaid && _earningBalance != null
                                  ? Icons.savings_rounded
                                  : Icons.account_balance_wallet_rounded,
                              accent: AppColors.success,
                              onTap: () => context.go(isPaid && _earningBalance != null ? '/earnings' : '/wallet'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const SectionHeader(title: 'Quick Actions', subtitle: 'Shortcuts to your most-used tools'),
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.92,
                          children: [
                            PremiumQuickAction(
                              label: 'Share Referral',
                              icon: Icons.ios_share_rounded,
                              onTap: () => context.push('/account/share-referral'),
                            ),
                            PremiumQuickAction(
                              label: 'Tree View',
                              icon: Icons.account_tree_rounded,
                              onTap: () => context.push('/account/tree-view'),
                            ),
                            PremiumQuickAction(
                              label: 'Orders',
                              icon: Icons.list_alt_rounded,
                              onTap: () => context.go('/orders'),
                            ),
                            if (isPaid) ...[
                              PremiumQuickAction(
                                label: 'Earnings',
                                icon: Icons.trending_up_rounded,
                                onTap: () => context.go('/earnings'),
                              ),
                              PremiumQuickAction(
                                label: 'Cash Wallet',
                                icon: Icons.account_balance_wallet_rounded,
                                onTap: () => context.go('/wallet'),
                              ),
                              PremiumQuickAction(
                                label: 'Badges',
                                icon: Icons.military_tech_rounded,
                                onTap: () => context.push('/account/badges'),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        const SectionHeader(title: 'Recent Activity'),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: AppDecorations.premiumCard(),
                          child: Column(
                            children: [
                              _activityRow(
                                Icons.waving_hand_rounded,
                                AppColors.info,
                                'Welcome to Serve Cafe! Start by exploring the menu.',
                              ),
                              Divider(height: 1, color: AppColors.border.withValues(alpha: 0.6)),
                              _activityRow(
                                Icons.card_giftcard_rounded,
                                AppColors.success,
                                'Your referral code is ready: ${user?.referralCode ?? 'N/A'}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _welcomeHero(String firstName, String? referralCode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientVertical,
        borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstName.isNotEmpty ? 'Hello, $firstName' : 'Hello',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your member dashboard',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
          ),
          if (referralCode != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tag_rounded, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    referralCode,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _activityRow(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
