String normalizeNepalPhone(String input) {
  var value = input.trim();
  if (!value.startsWith('+977')) {
    value = '+977${value.replaceAll(RegExp(r'[^0-9]'), '')}';
  } else {
    value = '+977${value.substring(4).replaceAll(RegExp(r'[^0-9]'), '')}';
  }
  return value;
}

bool isValidNepalPhone(String? phone) {
  if (phone == null || phone.isEmpty) return true;
  return RegExp(r'^\+977[0-9]{9,10}$').hasMatch(phone);
}
