import 'url_launcher_helper_mobile.dart'
    if (dart.library.html) 'url_launcher_helper_web.dart';

class UrlLauncherHelper {
  static void launchExternalUrl(String url) {
    openUrl(url);
  }
}
