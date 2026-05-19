import 'package:intl/intl.dart';

String formatNrs(num value) => 'NRS ${NumberFormat('#,##0.00').format(value)}';

String formatDate(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  try {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
  } catch (_) {
    return iso;
  }
}
