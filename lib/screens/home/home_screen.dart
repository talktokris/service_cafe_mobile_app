import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/format.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _data;
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
      final body = await api.get(ApiEndpoints.dashboard);
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
    final stats = _data?['stats'] as Map<String, dynamic>?;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Home'),
      body: _loading
          ? const LoadingOverlay(message: 'Loading dashboard...')
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text('Hello, ${user?.name ?? ''}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      if (user?.referralCode != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Referral: ${user!.referralCode}', style: const TextStyle(color: AppColors.textMuted)),
                        ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.3,
                        children: [
                          StatCard(label: 'Referrals', value: '${stats?['total_referrals'] ?? 0}', icon: Icons.people),
                          StatCard(label: 'Orders', value: '${stats?['total_orders'] ?? 0}', icon: Icons.receipt),
                          StatCard(label: 'This Month', value: '${stats?['month_orders'] ?? 0}', icon: Icons.calendar_month),
                          StatCard(label: 'Wallet', value: formatNrs(stats?['wallet_balance'] ?? 0), icon: Icons.wallet),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _actionChip(context, 'Share Referral', Icons.share, () => context.push('/account/share-referral')),
                          _actionChip(context, 'Tree View', Icons.account_tree, () => context.push('/account/tree-view')),
                          _actionChip(context, 'Orders', Icons.list, () => context.go('/orders')),
                          if (user?.isPaid == true)
                            _actionChip(context, 'Badges', Icons.military_tech, () => context.push('/account/badges')),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _actionChip(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: AppColors.accent),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: AppColors.surface,
    );
  }
}
