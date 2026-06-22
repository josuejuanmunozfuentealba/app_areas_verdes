import 'dart:typed_data';

/// Stub implementation for non-web platforms
///
/// This implementation is used when the app runs on mobile or desktop platforms.
/// It throws an UnsupportedError since web downloads are only available on web.
void downloadFileImpl({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) {
  throw UnsupportedError(
    'Web download is only supported on Flutter web platform',
  );
}
