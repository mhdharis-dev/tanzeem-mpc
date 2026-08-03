import 'package:url_launcher/url_launcher.dart';

void openUrl(String url) {
  final Uri uri = Uri.parse(url);
  launchUrl(uri, mode: LaunchMode.externalApplication);
}
