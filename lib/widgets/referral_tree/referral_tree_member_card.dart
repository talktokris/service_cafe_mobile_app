import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/widgets/referral_tree/referral_tree_constants.dart';

class ReferralTreeMemberCard extends StatelessWidget {
  const ReferralTreeMemberCard({
    super.key,
    required this.node,
    required this.isCurrentRoot,
    required this.isExpanded,
    required this.onCardTap,
    required this.onToggleExpand,
    required this.onViewDownline,
  });

  final Map<String, dynamic> node;
  final bool isCurrentRoot;
  final bool isExpanded;
  final VoidCallback onCardTap;
  final VoidCallback? onToggleExpand;
  final VoidCallback? onViewDownline;

  static List<BoxShadow> get _cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 14,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get _rootCardShadow => [
        ..._cardShadow,
        BoxShadow(
          color: ReferralTreeStyle.teal500.withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 3),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final memberType = node['member_type']?.toString() ?? 'free';
    final isPaid = memberType == 'paid';
    final isActive = isPaid && (node['active_status'] as num?)?.toInt() == 1;
    final badge = node['highest_badge'] as Map<String, dynamic>?;
    final children = (node['children'] as List<dynamic>?) ?? [];
    final hasChildren = children.isNotEmpty;
    final hasMoreLevels = node['has_more_levels'] == true;
    final avatarColors = BadgeRankStyle.colorsForBadge(badge, isActive: isActive);
    final avatarInitial = badge?['initial']?.toString() ??
        (node['name']?.toString().isNotEmpty == true ? node['name'].toString()[0].toUpperCase() : '?');
    final accentColor = isActive ? ReferralTreeStyle.teal500 : Colors.grey.shade400;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: isCurrentRoot ? _rootCardShadow : _cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isCurrentRoot ? null : onCardTap,
            child: Ink(
              decoration: BoxDecoration(
                border: Border.all(
                  color: isCurrentRoot ? ReferralTreeStyle.teal500 : Colors.grey.shade200,
                  width: isCurrentRoot ? 1.5 : 1,
                ),
                gradient: isActive
                    ? const LinearGradient(
                        colors: [Colors.white, ReferralTreeStyle.teal50],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                color: isActive ? null : Colors.white,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: accentColor),
                    Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 6, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: avatarColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              avatarInitial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        node['name']?.toString() ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: Color(0xFF111827),
                                          height: 1.15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (hasChildren) ...[
                                      const SizedBox(width: 4),
                                      Text(
                                        '${children.length} ref${children.length == 1 ? '' : 's'}',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 4,
                                  runSpacing: 2,
                                  children: [
                                    _StatusChip(label: isPaid ? 'Paid' : 'Free', isPaid: isPaid),
                                    if (badge != null)
                                      Text(
                                        badge['name']?.toString() ?? '',
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                _InfoRow(
                                  icon: Icons.email_outlined,
                                  text: node['email']?.toString().isNotEmpty == true
                                      ? node['email'].toString()
                                      : 'No email',
                                ),
                                _InfoRow(
                                  icon: Icons.phone_outlined,
                                  text: node['phone']?.toString().isNotEmpty == true
                                      ? node['phone'].toString()
                                      : 'No phone',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasMoreLevels)
                                _CircleActionButton(
                                  size: 26,
                                  color: const Color(0xFFFACC15),
                                  onTap: onViewDownline,
                                  child: const Icon(Icons.arrow_downward, size: 13, color: Colors.white),
                                ),
                              if (hasChildren) ...[
                                if (hasMoreLevels) const SizedBox(height: 4),
                                _CircleActionButton(
                                  size: 26,
                                  color: Colors.white,
                                  borderColor: Colors.grey.shade300,
                                  onTap: onToggleExpand,
                                  child: Icon(
                                    isExpanded ? Icons.remove : Icons.add,
                                    size: 16,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.isPaid});

  final String label;
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isPaid ? ReferralTreeStyle.teal50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isPaid ? ReferralTreeStyle.teal500.withValues(alpha: 0.3) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isPaid ? ReferralTreeStyle.teal700 : Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: Row(
        children: [
          Icon(icon, size: 11, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600, height: 1.2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.child,
    required this.onTap,
    required this.size,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.transparent,
      shape: const CircleBorder(),
      elevation: 1,
      shadowColor: Colors.black26,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: borderColor != null ? Border.all(color: borderColor!) : null,
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
