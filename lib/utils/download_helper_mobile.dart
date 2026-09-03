import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Guarda un archivo en móvil y lo comparte para que el usuario pueda abrirlo/guardarlo
Future<void> downloadFile(Uint8List bytes, String filename) async {
  // 1. Guardar archivo temporalmente
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(bytes);

  // 2. Compartir archivo usando share_plus (abre menú de compartir)
  // El usuario puede elegir "Guardar en archivos", "Abrir con Word", etc.
  await Share.shareXFiles([
    XFile(file.path),
  ], text: 'Catastro generado - $filename');
}
