import 'package:flutter/services.dart';

/// Allowed referral code characters: letters, digits, hyphen, underscore.
final RegExp referralCodePattern = RegExp(r'^[a-zA-Z0-9_-]{3,60}$');

final List<TextInputFormatter> referralCodeInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_-]')),
];

String? validateReferralCodeField(String? value) {
  final code = value?.trim() ?? '';
  if (code.isEmpty) return 'Referral code required';
  if (!referralCodePattern.hasMatch(code)) {
    return 'Use letters, numbers, hyphens (-) or underscores (_) only';
  }
  return null;
}

String encodeReferralCodeForPath(String code) => Uri.encodeComponent(code.trim());
