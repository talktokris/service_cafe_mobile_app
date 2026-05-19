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

    final cardBody = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCurrentRoot ? null : onCardTap,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isActive ? null : Colors.grey.shade50,
              gradient: isActive
                  ? const LinearGradient(
                      colors: [ReferralTreeStyle.teal50, ReferralTreeStyle.cyan50],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                  : null,
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4, color: accentColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: avatarColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              avatarInitial,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      node['name']?.toString() ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isPaid ? ReferralTreeStyle.teal50 : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isPaid ? 'Paid' : 'Free',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isPaid ? ReferralTreeStyle.teal700 : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    if (badge != null)
                                      Text(
                                        badge['name']?.toString() ?? '',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                _InfoRow(
                                  icon: Icons.email_outlined,
                                  text: node['email']?.toString().isNotEmpty == true ? node['email'].toString() : 'No email',
                                ),
                                const SizedBox(height: 2),
                                _InfoRow(
                                  icon: Icons.phone_outlined,
                                  text: node['phone']?.toString().isNotEmpty == true ? node['phone'].toString() : 'No phone',
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              if (hasChildren)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Text(
                                    '${children.length} ref${children.length == 1 ? '' : 's'}',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  ),
                                ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasMoreLevels)
                                    _CircleActionButton(
                                      color: const Color(0xFFFACC15),
                                      onTap: onViewDownline,
                                      child: const Icon(Icons.arrow_downward, size: 14, color: Colors.white),
                                    ),
                                  if (hasChildren) ...[
                                    if (hasMoreLevels) const SizedBox(width: 6),
                                    _CircleActionButton(
                                      color: Colors.white,
                                      borderColor: Colors.grey.shade300,
                                      onTap: onToggleExpand,
                                      child: Text(
                                        isExpanded ? '−' : '+',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade700,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
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
    );

    if (!isCurrentRoot) return cardBody;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ReferralTreeStyle.teal500, width: 2),
      ),
      padding: const EdgeInsets.all(2),
      child: cardBody,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({
    required this.child,
    required this.onTap,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
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
