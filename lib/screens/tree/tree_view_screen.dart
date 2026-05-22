import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serve_cafe_mobile/core/api/api_client.dart';
import 'package:serve_cafe_mobile/core/api/api_endpoints.dart';
import 'package:serve_cafe_mobile/core/theme/app_theme.dart';
import 'package:serve_cafe_mobile/widgets/error_state.dart';
import 'package:serve_cafe_mobile/widgets/gradient_app_bar.dart';
import 'package:serve_cafe_mobile/widgets/loading_overlay.dart';
import 'package:serve_cafe_mobile/widgets/referral_tree/referral_tree_constants.dart';
import 'package:serve_cafe_mobile/widgets/referral_tree/referral_tree_legend.dart';
import 'package:serve_cafe_mobile/widgets/referral_tree/referral_tree_widget.dart';
import 'package:serve_cafe_mobile/widgets/pull_to_refresh.dart';

class TreeViewScreen extends StatefulWidget {
  const TreeViewScreen({super.key});

  @override
  State<TreeViewScreen> createState() => _TreeViewScreenState();
}

class _TreeViewScreenState extends State<TreeViewScreen> {
  Map<String, dynamic>? _tree;
  Map<String, dynamic>? _parentInfo;
  int? _rootId;
  int? _loggedInUserId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int? startUserId}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final body = await context.read<ApiClient>().get(
            ApiEndpoints.treeView,
            query: startUserId != null ? {'start_user_id': startUserId} : null,
          );
      final data = body['data'] as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _tree = data['tree'] as Map<String, dynamic>?;
          _rootId = data['current_root_user_id'] as int?;
          _parentInfo = data['parent_info'] as Map<String, dynamic>?;
          _loggedInUserId = data['logged_in_user_id'] as int?;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = ApiClient.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToMyTree() => _load();

  @override
  Widget build(BuildContext context) {
    final viewingOwnTree = _rootId != null && _loggedInUserId != null && _rootId == _loggedInUserId;
    final showNavBar = _parentInfo != null || !viewingOwnTree;

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Tree View',
        showBack: true,
        actions: [
          if (!viewingOwnTree && !_loading)
            TextButton.icon(
              onPressed: _goToMyTree,
              icon: const Icon(Icons.home, color: Colors.white, size: 20),
              label: const Text('My Tree', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: _loading
          ? const LoadingOverlay()
          : _error != null
              ? ErrorState(message: _error!, onRetry: () => _load(startUserId: _rootId))
              : PullToRefresh.list(
                  onRefresh: () => _load(startUserId: _rootId),
                  padding: const EdgeInsets.all(12),
                  children: [
                      if (showNavBar) _NavigationBar(
                        parentInfo: _parentInfo,
                        viewingOwnTree: viewingOwnTree,
                        rootId: _rootId,
                        onGoUp: () => _load(startUserId: _parentInfo!['id'] as int),
                        onMyTree: _goToMyTree,
                      ),
                      ReferralTreeWidget(
                        key: ValueKey(_rootId),
                        treeData: _tree,
                        currentRootUserId: _rootId ?? 0,
                        onNavigateToUser: (id) => _load(startUserId: id),
                      ),
                      const SizedBox(height: 16),
                      const ReferralTreeLegend(),
                    ],
                ),
    );
  }
}

class _NavigationBar extends StatelessWidget {
  const _NavigationBar({
    required this.parentInfo,
    required this.viewingOwnTree,
    required this.rootId,
    required this.onGoUp,
    required this.onMyTree,
  });

  final Map<String, dynamic>? parentInfo;
  final bool viewingOwnTree;
  final int? rootId;
  final VoidCallback onGoUp;
  final VoidCallback onMyTree;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (parentInfo != null)
                  ElevatedButton.icon(
                    onPressed: onGoUp,
                    icon: const Icon(Icons.arrow_upward, size: 18),
                    label: Text('Go Up to ${parentInfo!['name']}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ReferralTreeStyle.goUpBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                if (!viewingOwnTree)
                  ElevatedButton.icon(
                    onPressed: onMyTree,
                    icon: const Icon(Icons.home, size: 18),
                    label: const Text('My Tree'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ReferralTreeStyle.myTreeGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              viewingOwnTree
                  ? 'Viewing your tree'
                  : 'Viewing downline from User ID: $rootId',
              style: TextStyle(
                fontSize: 13,
                color: viewingOwnTree ? ReferralTreeStyle.myTreeGreen : AppColors.textMuted,
                fontWeight: viewingOwnTree ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
