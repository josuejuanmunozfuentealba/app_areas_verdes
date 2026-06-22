import 'dart:typed_data';
// Conditional import for web platform
import 'web_download_helper_stub.dart'
    if (dart.library.html) 'web_download_helper_web.dart';

/// Helper class for handling file downloads in Flutter web
///
/// This class provides a unified interface for triggering file downloads
/// in web browsers using the download attribute of anchor elements.
class WebDownloadHelper {
  /// Triggers a file download in the browser
  ///
  /// Parameters:
  /// - [bytes]: The file content as byte array
  /// - [fileName]: The name to save the file with
  /// - [mimeType]: The MIME type of the file
  ///
  /// Note: This only works on Flutter web. On other platforms, this will throw
  /// an UnsupportedError.
  static void downloadFile({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) {
    downloadFileImpl(bytes: bytes, fileName: fileName, mimeType: mimeType);
  }
}
