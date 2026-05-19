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

    final card = Material(
      elevation: isCurrentRoot ? 3 : 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
      color: Colors.white,
      child: InkWell(
        onTap: isCurrentRoot ? null : onCardTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCurrentRoot ? ReferralTreeStyle.teal500 : Colors.grey.shade200,
              width: isCurrentRoot ? 1.5 : 1,
            ),
            gradient: isActive
                ? const LinearGradient(
                    colors: [Colors.white, ReferralTreeStyle.teal50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive ? null : const Color(0xFFF9FAFB),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: avatarColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: avatarColors.first.withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            avatarInitial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      node['name']?.toString() ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Color(0xFF111827),
                                        height: 1.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (hasChildren)
                                    Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Text(
                                        '${children.length} ref${children.length == 1 ? '' : 's'}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  _StatusChip(label: isPaid ? 'Paid' : 'Free', isPaid: isPaid),
                                  if (badge != null) _RankChip(name: badge['name']?.toString() ?? ''),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _ContactBlock(
                                email: node['email']?.toString().isNotEmpty == true
                                    ? node['email'].toString()
                                    : 'No email',
                                phone: node['phone']?.toString().isNotEmpty == true
                                    ? node['phone'].toString()
                                    : 'No phone',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Column(
                          children: [
                            if (hasMoreLevels)
                              _CircleActionButton(
                                color: const Color(0xFFFACC15),
                                onTap: onViewDownline,
                                child: const Icon(Icons.arrow_downward, size: 14, color: Colors.white),
                              ),
                            if (hasChildren) ...[
                              if (hasMoreLevels) const SizedBox(height: 6),
                              _CircleActionButton(
                                color: Colors.white,
                                borderColor: Colors.grey.shade300,
                                onTap: onToggleExpand,
                                child: Icon(
                                  isExpanded ? Icons.remove : Icons.add,
                                  size: 18,
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
    );

    if (!isCurrentRoot) return card;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ReferralTreeStyle.teal500.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: card,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isPaid ? ReferralTreeStyle.teal50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPaid ? ReferralTreeStyle.teal500.withValues(alpha: 0.35) : Colors.grey.shade300,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isPaid ? ReferralTreeStyle.teal700 : Colors.grey.shade700,
        ),
      ),
    );
  }
}

class _RankChip extends StatelessWidget {
  const _RankChip({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.landscape_outlined, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class _ContactBlock extends StatelessWidget {
  const _ContactBlock({required this.email, required this.phone});

  final String email;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _InfoRow(icon: Icons.email_outlined, text: email),
          const SizedBox(height: 4),
          _InfoRow(icon: Icons.phone_outlined, text: phone),
        ],
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
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.25),
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
      elevation: 0.5,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
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
