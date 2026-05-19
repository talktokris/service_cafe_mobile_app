import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/widgets/referral_tree/referral_tree_constants.dart';
import 'package:serve_cafe_mobile/widgets/referral_tree/referral_tree_member_card.dart';
import 'package:serve_cafe_mobile/widgets/referral_tree/referral_tree_org_painter.dart';

/// Hierarchical referral tree with measured org-chart connector lines.
class ReferralTreeWidget extends StatefulWidget {
  const ReferralTreeWidget({
    super.key,
    required this.treeData,
    required this.currentRootUserId,
    required this.onNavigateToUser,
  });

  final Map<String, dynamic>? treeData;
  final int currentRootUserId;
  final ValueChanged<int> onNavigateToUser;

  @override
  State<ReferralTreeWidget> createState() => _ReferralTreeWidgetState();
}

class _ReferralTreeWidgetState extends State<ReferralTreeWidget> {
  final Set<int> _expandedNodes = {};

  @override
  void initState() {
    super.initState();
    _expandRootIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ReferralTreeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.treeData?['id'] != widget.treeData?['id']) {
      _expandedNodes.clear();
      _expandRootIfNeeded();
    }
  }

  void _expandRootIfNeeded() {
    final id = widget.treeData?['id'];
    if (id is int) _expandedNodes.add(id);
  }

  void _toggleNode(int nodeId) {
    setState(() {
      if (_expandedNodes.contains(nodeId)) {
        _expandedNodes.remove(nodeId);
      } else {
        _expandedNodes.add(nodeId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.treeData == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No referral data available', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ReferralTreeStyle.panelBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _TreeRootNode(
          node: widget.treeData!,
          currentRootUserId: widget.currentRootUserId,
          expandedNodes: _expandedNodes,
          onToggle: _toggleNode,
          onNavigate: widget.onNavigateToUser,
        ),
      ),
    );
  }
}

class _TreeRootNode extends StatelessWidget {
  const _TreeRootNode({
    required this.node,
    required this.currentRootUserId,
    required this.expandedNodes,
    required this.onToggle,
    required this.onNavigate,
  });

  final Map<String, dynamic> node;
  final int currentRootUserId;
  final Set<int> expandedNodes;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final nodeId = node['id'] as int;
    final children = (node['children'] as List<dynamic>?) ?? [];
    final hasChildren = children.isNotEmpty;
    final isExpanded = expandedNodes.contains(nodeId);
    final showChildren = hasChildren && isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MemberCard(
          node: node,
          currentRootUserId: currentRootUserId,
          isExpanded: isExpanded,
          onToggle: onToggle,
          onNavigate: onNavigate,
        ),
        if (showChildren) ...[
          const SizedBox(height: ReferralTreeStyle.cardSpacing),
          OrgChartBranch(
            children: children,
            drawParentStub: true,
            currentRootUserId: currentRootUserId,
            expandedNodes: expandedNodes,
            onToggle: onToggle,
            onNavigate: onNavigate,
          ),
        ],
      ],
    );
  }
}

/// One child row: card (measured) + optional nested branch.
class _BranchChildEntry extends StatelessWidget {
  const _BranchChildEntry({
    required this.cardKey,
    required this.node,
    required this.currentRootUserId,
    required this.expandedNodes,
    required this.onToggle,
    required this.onNavigate,
  });

  final GlobalKey cardKey;
  final Map<String, dynamic> node;
  final int currentRootUserId;
  final Set<int> expandedNodes;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final nodeId = node['id'] as int;
    final children = (node['children'] as List<dynamic>?) ?? [];
    final hasChildren = children.isNotEmpty;
    final isExpanded = expandedNodes.contains(nodeId);
    final showChildren = hasChildren && isExpanded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: ReferralTreeStyle.cardSpacing),
          child: KeyedSubtree(
            key: cardKey,
            child: _MemberCard(
              node: node,
              currentRootUserId: currentRootUserId,
              isExpanded: isExpanded,
              onToggle: onToggle,
              onNavigate: onNavigate,
            ),
          ),
        ),
        if (showChildren) ...[
          Padding(
            padding: const EdgeInsets.only(left: ReferralTreeStyle.levelIndent),
            child: OrgChartBranch(
              children: children,
              drawParentStub: true,
              currentRootUserId: currentRootUserId,
              expandedNodes: expandedNodes,
              onToggle: onToggle,
              onNavigate: onNavigate,
            ),
          ),
        ],
      ],
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({
    required this.node,
    required this.currentRootUserId,
    required this.isExpanded,
    required this.onToggle,
    required this.onNavigate,
  });

  final Map<String, dynamic> node;
  final int currentRootUserId;
  final bool isExpanded;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final nodeId = node['id'] as int;
    final children = (node['children'] as List<dynamic>?) ?? [];
    final hasChildren = children.isNotEmpty;

    return ReferralTreeMemberCard(
      node: node,
      isCurrentRoot: nodeId == currentRootUserId,
      isExpanded: isExpanded,
      onCardTap: () {
        if (nodeId != currentRootUserId) onNavigate(nodeId);
      },
      onToggleExpand: hasChildren ? () => onToggle(nodeId) : null,
      onViewDownline: node['has_more_levels'] == true ? () => onNavigate(nodeId) : null,
    );
  }
}

/// Branch of siblings with lines painted from measured card positions.
class OrgChartBranch extends StatefulWidget {
  const OrgChartBranch({
    super.key,
    required this.children,
    required this.drawParentStub,
    required this.currentRootUserId,
    required this.expandedNodes,
    required this.onToggle,
    required this.onNavigate,
  });

  final List<dynamic> children;
  final bool drawParentStub;
  final int currentRootUserId;
  final Set<int> expandedNodes;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onNavigate;

  @override
  State<OrgChartBranch> createState() => _OrgChartBranchState();
}

class _OrgChartBranchState extends State<OrgChartBranch> {
  final GlobalKey _stackKey = GlobalKey();
  late List<GlobalKey> _cardKeys;
  late List<GlobalKey> _entryKeys;

  @override
  void initState() {
    super.initState();
    _syncKeys();
    WidgetsBinding.instance.addPostFrameCallback(_repaint);
  }

  @override
  void didUpdateWidget(covariant OrgChartBranch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _syncKeys();
    }
    WidgetsBinding.instance.addPostFrameCallback(_repaint);
  }

  void _syncKeys() {
    final n = widget.children.length;
    _cardKeys = List.generate(n, (_) => GlobalKey());
    _entryKeys = List.generate(n, (_) => GlobalKey());
  }

  void _repaint(_) {
    if (mounted) setState(() {});
  }

  List<OrgNodeAnchor> _measureAnchors() {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null) return [];

    final anchors = <OrgNodeAnchor>[];
    for (var i = 0; i < widget.children.length; i++) {
      final cardBox = _cardKeys[i].currentContext?.findRenderObject() as RenderBox?;
      final entryBox = _entryKeys[i].currentContext?.findRenderObject() as RenderBox?;
      if (cardBox == null || entryBox == null) continue;

      final cardOrigin = stackBox.globalToLocal(cardBox.localToGlobal(Offset.zero));
      final entryBottomLocal = stackBox.globalToLocal(
        entryBox.localToGlobal(Offset(0, entryBox.size.height)),
      );

      final node = widget.children[i] as Map<String, dynamic>;
      final nodeId = node['id'] as int;
      final childList = (node['children'] as List<dynamic>?) ?? [];
      final hasChildren = childList.isNotEmpty;
      final isExpanded = widget.expandedNodes.contains(nodeId);

      anchors.add(OrgNodeAnchor(
        centerY: cardOrigin.dy + cardBox.size.height / 2,
        cardLeftX: cardOrigin.dx,
        entryBottomY: entryBottomLocal.dy,
        isLast: i == widget.children.length - 1,
        hasExpandedChildren: hasChildren && isExpanded,
      ));
    }
    return anchors;
  }

  @override
  Widget build(BuildContext context) {
    final anchors = _measureAnchors();

    return Stack(
      key: _stackKey,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: OrgChartBranchPainter(
              anchors: anchors,
              drawParentStub: widget.drawParentStub,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: ReferralTreeStyle.gutterW),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < widget.children.length; i++)
                KeyedSubtree(
                  key: _entryKeys[i],
                  child: _BranchChildEntry(
                    cardKey: _cardKeys[i],
                    node: widget.children[i] as Map<String, dynamic>,
                    currentRootUserId: widget.currentRootUserId,
                    expandedNodes: widget.expandedNodes,
                    onToggle: widget.onToggle,
                    onNavigate: widget.onNavigate,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
