import 'package:intl/intl.dart';
import 'package:serve_cafe_mobile/utils/api_parsing.dart';

String formatNrs(dynamic value) =>
    'NRS ${NumberFormat('#,##0.00').format(parseApiNum(value))}';

String formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  try {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
  } catch (_) {
    return iso;
  }
}

String formatDateTime(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  try {
    return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(iso));
  } catch (_) {
    return iso;
  }
}
