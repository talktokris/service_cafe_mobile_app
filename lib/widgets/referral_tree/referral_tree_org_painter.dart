import 'package:flutter/material.dart';
import 'package:serve_cafe_mobile/widgets/referral_tree/referral_tree_constants.dart';

/// Measured anchor for one node in a branch (positions relative to branch stack).
class OrgNodeAnchor {
  const OrgNodeAnchor({
    required this.centerY,
    required this.cardLeftX,
    required this.entryBottomY,
    required this.isLast,
    required this.hasExpandedChildren,
  });

  final double centerY;
  final double cardLeftX;
  final double entryBottomY;
  final bool isLast;
  final bool hasExpandedChildren;
}

/// Paints a vertical org-chart spine + horizontal branches to each card.
class OrgChartBranchPainter extends CustomPainter {
  OrgChartBranchPainter({
    required this.anchors,
    required this.drawParentStub,
  });

  final List<OrgNodeAnchor> anchors;
  final bool drawParentStub;

  @override
  void paint(Canvas canvas, Size size) {
    if (anchors.isEmpty) return;

    final paint = Paint()
      ..color = ReferralTreeStyle.lineColor
      ..strokeWidth = ReferralTreeStyle.lineWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final spineX = ReferralTreeStyle.spineX;
    final first = anchors.first;
    final last = anchors.last;

    final spineTop = drawParentStub ? -ReferralTreeStyle.parentStubH : first.centerY;
    final spineBottom = last.isLast && !last.hasExpandedChildren ? last.centerY : last.entryBottomY;

    canvas.drawLine(Offset(spineX, spineTop), Offset(spineX, spineBottom), paint);

    for (final anchor in anchors) {
      final endX = anchor.cardLeftX > spineX ? anchor.cardLeftX : spineX + 4;
      canvas.drawLine(Offset(spineX, anchor.centerY), Offset(endX, anchor.centerY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant OrgChartBranchPainter oldDelegate) {
    return oldDelegate.drawParentStub != drawParentStub ||
        oldDelegate.anchors.length != anchors.length;
  }
}
