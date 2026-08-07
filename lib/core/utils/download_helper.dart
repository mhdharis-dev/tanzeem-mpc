import 'download_stub.dart'
    if (dart.library.html) 'download_web.dart';

void downloadFile(String htmlContent, String filename) {
  downloadFileWeb(htmlContent, filename);
}
