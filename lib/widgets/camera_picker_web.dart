import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Widget personalizado que fuerza la cámara en web móvil
class CameraPickerWeb {
  /// Abre selector de cámara usando HTML nativo con capture="environment"
  static Future<XFile?> pickImageFromCamera() async {
    if (!kIsWeb) {
      // En nativo, usar image_picker normal
      return await ImagePicker().pickImage(source: ImageSource.camera);
    }

    // En web, crear input HTML con capture para forzar cámara
    final completer = Completer<XFile?>();
    
    final input = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..setAttribute('capture', 'environment'); // Fuerza cámara trasera

    input.onChange.listen((event) async {
      final files = input.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        
        reader.onLoadEnd.listen((event) async {
          final bytes = reader.result as List<int>;
          
          // Crear XFile desde bytes
          final xFile = XFile.fromData(
            Uint8List.fromList(bytes),
            name: file.name,
            mimeType: file.type,
          );
          
          completer.complete(xFile);
        });
        
        reader.readAsArrayBuffer(file);
      } else {
        completer.complete(null);
      }
    });

    input.click();
    return completer.future;
  }

  /// Abre selector de galería normal
  static Future<List<XFile>> pickMultipleImages() async {
    return await ImagePicker().pickMultiImage(imageQuality: 70);
  }
}
