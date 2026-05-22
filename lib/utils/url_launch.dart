import 'package:url_launcher/url_launcher.dart';

Future<bool> openUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await canLaunchUrl(uri)) {
    return false;
  }
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<bool> openEmail({
  required String to,
  required String subject,
  String body = '',
}) async {
  final trimmed = to.trim();
  if (trimmed.isEmpty) return false;

  final uri = Uri(
    scheme: 'mailto',
    path: trimmed,
    queryParameters: <String, String>{
      if (subject.isNotEmpty) 'subject': subject,
      if (body.isNotEmpty) 'body': body,
    },
  );

  if (!await canLaunchUrl(uri)) {
    return false;
  }
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<bool> openPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return Future.value(false);
  return openUrl('tel:$digits');
}

Future<bool> openWhatsAppShare({
  required String phone,
  required String message,
}) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  return openUrl(
    'https://wa.me/$digits?text=${Uri.encodeComponent(message)}',
  );
}

Future<bool> openViberShare({
  required String phone,
  required String message,
}) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  return openUrl(
    'viber://chat?number=$digits&text=${Uri.encodeComponent(message)}',
  );
}
