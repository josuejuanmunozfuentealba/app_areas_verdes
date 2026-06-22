import 'dart:html' as html;
import 'dart:typed_data';

/// Web-specific implementation for file downloads
///
/// This implementation uses dart:html to create a Blob and trigger
/// a download using an anchor element with the download attribute.
void downloadFileImpl({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) {
  // Create a Blob from the bytes
  final blob = html.Blob([bytes], mimeType);

  // Create a URL for the Blob
  final url = html.Url.createObjectUrlFromBlob(blob);

  // Create an anchor element and trigger download
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();

  // Clean up the URL to prevent memory leaks
  html.Url.revokeObjectUrl(url);
}
