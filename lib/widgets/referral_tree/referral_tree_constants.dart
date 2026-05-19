import 'package:flutter/material.dart';

class ReferralTreeStyle {
  static const lineColor = Color(0xFF64748B);
  static const panelBg = Color(0xFFFAFAFA);
  static const lineWidth = 2.0;

  /// Width reserved for connector gutter (left of cards).
  static const gutterW = 28.0;
  /// X position of vertical spine within the branch stack.
  static const spineX = 13.0;
  static const parentStubH = 14.0;
  /// Indent per tree level for nested branches.
  static const levelIndent = 28.0;
  /// Vertical space between sibling cards in the same branch.
  static const cardSpacing = 14.0;

  static const teal500 = Color(0xFF14B8A6);
  static const teal600 = Color(0xFF0D9488);
  static const teal700 = Color(0xFF0F766E);
  static const cyan50 = Color(0xFFECFEFF);
  static const teal50 = Color(0xFFF0FDFA);

  static const myTreeGreen = Color(0xFF22C55E);
  static const goUpBlue = Color(0xFF3B82F6);
}

class BadgeRankStyle {
  const BadgeRankStyle(this.initial, this.name, this.colors);

  final String initial;
  final String name;
  final List<Color> colors;

  static const ranks = [
    BadgeRankStyle('E', 'Mount Everest', [Color(0xFF6366F1), Color(0xFF4338CA)]),
    BadgeRankStyle('K', 'Kanchenjunga', [Color(0xFFEF4444), Color(0xFFB91C1C)]),
    BadgeRankStyle('M', 'Makalu', [Color(0xFFA855F7), Color(0xFF7E22CE)]),
    BadgeRankStyle('D', 'Dhaulagiri', [Color(0xFFEAB308), Color(0xFFA16207)]),
    BadgeRankStyle('M', 'Manaslu', [Color(0xFF22C55E), Color(0xFF15803D)]),
    BadgeRankStyle('A', 'Annapurna', [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
  ];

  static List<Color> colorsForBadge(Map<String, dynamic>? badge, {required bool isActive}) {
    if (badge == null) {
      return isActive
          ? [ReferralTreeStyle.teal500, ReferralTreeStyle.teal600]
          : [Color(0xFFD1D5DB), Color(0xFF9CA3AF)];
    }
    final name = badge['name']?.toString() ?? '';
    for (final r in ranks) {
      if (r.name == name) return r.colors;
    }
    return [ReferralTreeStyle.teal500, ReferralTreeStyle.teal600];
  }
}
