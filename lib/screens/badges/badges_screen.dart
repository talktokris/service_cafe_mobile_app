import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/locked_feature_banner.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<dynamic> _levels = [];
  Map<String, dynamic>? _memberRank;
  bool _loading = true;
  String? _error;

  static const _badgeMeta = [
    ('annapurna', 'Annapurna', 'Active Paid Member', Colors.blue),
    ('manaslu', 'Manaslu', 'Leadership Achievement', Colors.green),
    ('dhaulagiri', 'Dhaulagiri', 'Advanced Achievement', Colors.amber),
    ('cho_oyu', 'Makalu', 'Expert Achievement', Colors.purple),
    ('makalu', 'Kanchenjunga', 'Master Achievement', Colors.red),
    ('kanchenjunga', 'Mount Everest', 'Elite Achievement', Colors.indigo),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (context.read<AuthProvider>().user?.isFree == true) {
      setState(() => _loading = false);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final body = await context.read<ApiClient>().get(ApiEndpoints.badges);
      final data = body['data'] as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _levels = data['levels'] as List<dynamic>? ?? [];
          _memberRank = data['member_rank'] as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isUnlocked(String key) {
    for (final l in _levels) {
      final m = l as Map<String, dynamic>;
      if (m['key'] == key) return m['unlocked'] == true;
    }
    return false;
  }

  int get _unlockedCount => _badgeMeta.where((m) => _isUnlocked(m.$1)).length;

  @override
  Widget build(BuildContext context) {
    final isFree = context.watch<AuthProvider>().user?.isFree ?? true;

    if (isFree) {
      return const Scaffold(
        appBar: GradientAppBar(title: 'Badges', showBack: true),
        body: LockedFeatureBanner(),
      );
    }

    return Scaffold(
      appBar: const GradientAppBar(title: 'Badges', showBack: true),
      body: _loading
          ? const LoadingOverlay()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _progressCard(),
                      const SizedBox(height: 20),
                      const Text('Your Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.85),
                        itemCount: _badgeMeta.length,
                        itemBuilder: (_, i) {
                          final meta = _badgeMeta[i];
                          final unlocked = _isUnlocked(meta.$1);
                          return _badgeCard(meta.$2, meta.$3, unlocked, meta.$4);
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text('Upline Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 12),
                      if (_memberRank == null)
                        const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('No upline rank data available yet.')))
                      else
                        ..._uplineTiles(),
                    ],
                  ),
                ),
    );
  }

  Widget _progressCard() {
    final pct = (_unlockedCount / 6 * 100).round();
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$_unlockedCount / 6 Unlocked', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('$pct% achievement', style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badgeCard(String name, String desc, bool unlocked, MaterialColor color) {
    return Card(
      elevation: unlocked ? 3 : 0,
      color: unlocked ? color.shade50 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(unlocked ? Icons.emoji_events : Icons.lock, size: 36, color: unlocked ? color.shade700 : Colors.grey),
            const SizedBox(height: 8),
            Text(name, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: unlocked ? color.shade900 : Colors.grey)),
            Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  List<Widget> _uplineTiles() {
    final ranks = [
      ('Annapurna', 'referral_user'),
      ('Manaslu', 'three_star_user'),
      ('Dhaulagiri', 'five_star_user'),
      ('Makalu', 'seven_star_user'),
      ('Kanchenjunga', 'mega_star_user'),
      ('Mount Everest', 'giga_star_user'),
    ];
    return ranks.map((r) {
      final user = _memberRank![r.$2] as Map<String, dynamic>?;
      final name = user != null ? (user['name'] ?? '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim()) : 'Not Available';
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: 0.1), child: Text(r.$1[0], style: const TextStyle(color: AppColors.primary))),
          title: Text(r.$1),
          subtitle: Text(name.toString().isEmpty ? 'Not Available' : name.toString()),
        ),
      );
    }).toList();
  }
}
