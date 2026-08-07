// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

void downloadFileWeb(String htmlContent, String filename) {
  try {
    // 1. Direct Blob File Download (.html / .pdf preview)
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);

    // 2. Open print preview window directly
    final dataUri = Uri.dataFromString(htmlContent, mimeType: 'text/html', encoding: utf8).toString();
    html.window.open(dataUri, '_blank');
  } catch (e) {
    final dataUri = Uri.dataFromString(htmlContent, mimeType: 'text/html', encoding: utf8).toString();
    html.window.open(dataUri, '_blank');
  }
}
