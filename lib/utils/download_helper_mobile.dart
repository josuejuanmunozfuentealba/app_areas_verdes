import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Guarda un archivo en móvil usando path_provider
Future<void> downloadFile(Uint8List bytes, String filename) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(bytes);
}
