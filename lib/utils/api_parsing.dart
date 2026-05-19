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
    if (total is num) return total.toInt();
    final data = raw['data'];
    if (data is List) return data.length;
  }
  if (raw is List) return raw.length;
  return 0;
}
