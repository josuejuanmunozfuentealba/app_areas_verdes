import 'dart:convert';
import 'dart:typed_data';
import 'package:printing/printing.dart';

/// Implementación para plataformas móviles (Android/iOS)
/// Usa Printing.sharePdf para compartir el archivo Word como documento
Future<void> downloadWordFile(String htmlContent, String filename) async {
  // Convertir el HTML a bytes UTF-8
  final List<int> bytesWord = utf8.encode(htmlContent);
  final Uint8List datosContenido = Uint8List.fromList(bytesWord);

  // Compartir el documento usando el sistema de compartir nativo
  await Printing.sharePdf(bytes: datosContenido, filename: filename);
}
