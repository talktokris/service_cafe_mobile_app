import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/widgets/referral_tree/referral_tree_constants.dart';
import 'package:serve_cafe_mobile/widgets/referral_tree/referral_tree_member_card.dart';

/// Hierarchical referral tree with connector lines (web parity).
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

/// Root node: card only, then children branch (no horizontal connector on root).
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
        if (showChildren)
          _ChildrenBranch(
            children: children,
            currentRootUserId: currentRootUserId,
            expandedNodes: expandedNodes,
            onToggle: onToggle,
            onNavigate: onNavigate,
          ),
      ],
    );
  }
}

/// One child inside a branch: horizontal connector on card only; nested branch is a sibling below.
class _BranchChildEntry extends StatelessWidget {
  const _BranchChildEntry({
    required this.node,
    required this.isLastSibling,
    required this.currentRootUserId,
    required this.expandedNodes,
    required this.onToggle,
    required this.onNavigate,
  });

  final Map<String, dynamic> node;
  final bool isLastSibling;
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

    // Mask spine only on this card row when last sibling with no expanded downline here.
    final maskSpineOnCard = isLastSibling && !showChildren;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HorizontalConnectorRow(
          maskSpineBelowCard: maskSpineOnCard,
          child: _MemberCard(
            node: node,
            currentRootUserId: currentRootUserId,
            isExpanded: isExpanded,
            onToggle: onToggle,
            onNavigate: onNavigate,
          ),
        ),
        if (showChildren)
          _ChildrenBranch(
            children: children,
            currentRootUserId: currentRootUserId,
            expandedNodes: expandedNodes,
            onToggle: onToggle,
            onNavigate: onNavigate,
          ),
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

/// Continuous left spine + horizontal branch per child (matches web CSS tree).
class _ChildrenBranch extends StatelessWidget {
  const _ChildrenBranch({
    required this.children,
    required this.currentRootUserId,
    required this.expandedNodes,
    required this.onToggle,
    required this.onNavigate,
  });

  final List<dynamic> children;
  final int currentRootUserId;
  final Set<int> expandedNodes;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: ReferralTreeStyle.spineX,
          top: -ReferralTreeStyle.parentStubH,
          child: const _VerticalLineSegment(height: ReferralTreeStyle.parentStubH),
        ),
        Transform.translate(
          offset: const Offset(0, -2),
          child: Padding(
            padding: const EdgeInsets.only(left: ReferralTreeStyle.spineX),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: ReferralTreeStyle.lineColor,
                    width: ReferralTreeStyle.lineWidth,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: ReferralTreeStyle.branchW),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < children.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: _BranchChildEntry(
                          node: children[i] as Map<String, dynamic>,
                          isLastSibling: i == children.length - 1,
                          currentRootUserId: currentRootUserId,
                          expandedNodes: expandedNodes,
                          onToggle: onToggle,
                          onNavigate: onNavigate,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Horizontal branch to card; optional mask stops parent spine at last leaf card only.
class _HorizontalConnectorRow extends StatelessWidget {
  const _HorizontalConnectorRow({
    required this.child,
    this.maskSpineBelowCard = false,
  });

  final Widget child;
  final bool maskSpineBelowCard;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -ReferralTreeStyle.branchW,
            width: ReferralTreeStyle.branchW,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: ReferralTreeStyle.branchW,
                height: ReferralTreeStyle.lineWidth,
                color: ReferralTreeStyle.lineColor,
              ),
            ),
          ),
          if (maskSpineBelowCard)
            Positioned(
              left: -(ReferralTreeStyle.branchW + ReferralTreeStyle.lineWidth),
              top: 0,
              bottom: 0,
              width: ReferralTreeStyle.lineWidth + 2,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  if (!h.isFinite || h <= 0) return const SizedBox.shrink();
                  return Column(
                    children: [
                      SizedBox(height: h / 2),
                      Expanded(
                        child: const ColoredBox(color: ReferralTreeStyle.panelBg),
                      ),
                    ],
                  );
                },
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _VerticalLineSegment extends StatelessWidget {
  const _VerticalLineSegment({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ReferralTreeStyle.lineWidth,
      height: height,
      child: const ColoredBox(color: ReferralTreeStyle.lineColor),
    );
  }
}
