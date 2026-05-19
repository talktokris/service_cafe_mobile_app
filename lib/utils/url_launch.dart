import 'package:url_launcher/url_launcher.dart';

Future<bool> openUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
  return false;
}

Future<bool> openEmail({required String to, required String subject, required String body}) {
  return openUrl('mailto:$to?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
}

Future<bool> openPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  return openUrl('tel:$digits');
}

Future<bool> openWhatsAppShare({required String phone, required String message}) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  return openUrl('https://wa.me/$digits?text=${Uri.encodeComponent(message)}');
}

Future<bool> openViberShare({required String phone, required String message}) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  return openUrl('viber://chat?number=$digits&text=${Uri.encodeComponent(message)}');
}

Future<bool> openMapsSearch(String address) {
  return openUrl('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
}
