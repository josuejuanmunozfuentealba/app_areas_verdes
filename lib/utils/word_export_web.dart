// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:convert';

/// Descarga un archivo Word en la plataforma web
void downloadWordFile(String htmlContent, String filename) {
  final bytes = utf8.encode(htmlContent);
  final blob = html.Blob([bytes], 'application/msword');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);
}
