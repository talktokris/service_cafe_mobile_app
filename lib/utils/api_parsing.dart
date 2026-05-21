/// Laravel decimals and some numeric fields are serialized as strings in JSON.
num parseApiNum(dynamic value, [num defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is num) return value;
  if (value is String) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return defaultValue;
    return num.tryParse(trimmed) ?? defaultValue;
  }
  return defaultValue;
}

double parseApiDouble(dynamic value, [double defaultValue = 0]) =>
    parseApiNum(value, defaultValue).toDouble();

int parseApiInt(dynamic value, [int defaultValue = 0]) =>
    parseApiNum(value, defaultValue).toInt();

/// Extracts list items from Laravel paginated or plain array API payloads.
List<dynamic> parseApiList(dynamic raw) {
  if (raw == null) return [];
  if (raw is List) return raw;
  if (raw is Map) {
    final data = raw['data'];
    if (data is List) return data;
  }
  return [];
}

int parseApiTotal(dynamic raw) {
  if (raw is Map) {
    final total = raw['total'];
    if (total != null) return parseApiInt(total);
    final data = raw['data'];
    if (data is List) return data.length;
  }
  if (raw is List) return raw.length;
  return 0;
}
