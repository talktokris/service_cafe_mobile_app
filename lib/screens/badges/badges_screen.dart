import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/auth/auth_provider.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/utils/transaction_helpers.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/locked_feature_banner.dart';
import 'package:serve_cafe_mobile/widgets/pull_to_refresh.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  Map<String, bool> _unlocked = {};
  Map<String, dynamic>? _memberRank;
  bool _loading = true;
  String? _error;

  /// API keys mapped to display names (web parity).
  static const _badgeMeta = [
    _BadgeMeta('annapurna', 'Annapurna', 'A', 'Active Paid Member — become an active paid member', Colors.blue),
    _BadgeMeta('manaslu', 'Manaslu', 'M', 'Leadership Achievement — build your leadership network', Colors.green),
    _BadgeMeta('dhaulagiri', 'Dhaulagiri', 'D', 'Advanced Achievement — reach advanced rank milestones', Colors.amber),
    _BadgeMeta('cho_oyu', 'Makalu', 'M', 'Expert Achievement — qualify as a Seven Star leader', Colors.purple),
    _BadgeMeta('makalu', 'Kanchenjunga', 'K', 'Master Achievement — achieve Mega Star status', Colors.red),
    _BadgeMeta('kanchenjunga', 'Mount Everest', 'E', 'Elite Achievement — reach Giga Star rank', Colors.indigo),
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
        final levels = data['levels'] as List<dynamic>? ?? [];
        final map = <String, bool>{};
        for (final l in levels) {
          final m = l as Map<String, dynamic>;
          map[m['key']?.toString() ?? ''] = m['unlocked'] == true;
        }
        setState(() {
          _unlocked = map;
          _memberRank = data['member_rank'] as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _unlockedCount => _badgeMeta.where((m) => _unlocked[m.apiKey] == true).length;

  @override
  Widget build(BuildContext context) {
    final isFree = context.watch<AuthProvider>().user?.isFree ?? true;

    if (isFree) {
      return Scaffold(
        appBar: const GradientAppBar(title: 'Badges', showBack: true),
        body: PullToRefresh.wrap(
          onRefresh: () async {
            await context.read<AuthProvider>().fetchMe();
          },
          child: const LockedFeatureBanner(),
        ),
      );
    }

    return Scaffold(
      appBar: const GradientAppBar(title: 'Badges', showBack: true),
      body: _loading
          ? const LoadingOverlay()
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : PullToRefresh.list(
                  onRefresh: _load,
                  padding: const EdgeInsets.all(16),
                  children: [
                      _progressCard(),
                      const SizedBox(height: 20),
                      const Text('Your Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: _badgeMeta.length,
                        itemBuilder: (_, i) => _badgeCard(_badgeMeta[i]),
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

  Widget _badgeCard(_BadgeMeta meta) {
    final unlocked = _unlocked[meta.apiKey] == true;
    final color = meta.color;
    return Card(
      elevation: unlocked ? 3 : 0,
      color: unlocked ? color.shade50 : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: unlocked ? color.shade700 : Colors.grey,
              child: Text(meta.initial, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            const SizedBox(height: 8),
            Text(meta.displayName, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: unlocked ? color.shade900 : Colors.grey)),
            const SizedBox(height: 4),
            Text(
              meta.requirement,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(unlocked ? '✓ Unlocked' : '🔒 Locked', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: unlocked ? Colors.green.shade700 : Colors.grey)),
          ],
        ),
      ),
    );
  }

  String _userName(Map<String, dynamic>? user) {
    if (user == null) return 'Not Available';
    final first = user['first_name']?.toString() ?? '';
    final last = user['last_name']?.toString() ?? '';
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;
    return user['name']?.toString() ?? 'Not Available';
  }

  List<Widget> _uplineTiles() {
    const ranks = [
      ('Annapurna', 'referral_user'),
      ('Manaslu', 'three_star_user'),
      ('Dhaulagiri', 'five_star_user'),
      ('Makalu', 'seven_star_user'),
      ('Kanchenjunga', 'mega_star_user'),
      ('Mount Everest', 'giga_star_user'),
    ];
    return ranks.map((r) {
      final user = _memberRank![r.$2] as Map<String, dynamic>?;
      final name = _userName(user);
      final initials = name == 'Not Available' ? '?' : initialsFromName(name);
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(initials, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          title: Text(r.$1),
          subtitle: Text(name),
        ),
      );
    }).toList();
  }
}

class _BadgeMeta {
  const _BadgeMeta(this.apiKey, this.displayName, this.initial, this.requirement, this.color);

  final String apiKey;
  final String displayName;
  final String initial;
  final String requirement;
  final MaterialColor color;
}
