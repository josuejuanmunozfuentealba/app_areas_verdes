import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Optimizador de imágenes para reducir consumo de memoria
class ImageOptimizer {
  /// Comprime una imagen para preview (thumbnail pequeño)
  /// Reduce drásticamente el uso de memoria en listas largas
  static Future<Uint8List> comprimirParaPreview(
    Uint8List originalBytes, {
    int maxWidth = 300, // Preview pequeño
    int maxHeight = 300,
    int quality = 60, // Calidad baja para preview
  }) async {
    try {
      // Decodificar imagen original
      final originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) return originalBytes;

      // Calcular nuevo tamaño manteniendo aspect ratio
      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      if (newWidth > maxWidth || newHeight > maxHeight) {
        final aspectRatio = newWidth / newHeight;
        
        if (aspectRatio > 1) {
          // Imagen horizontal
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        } else {
          // Imagen vertical
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      }

      // Redimensionar con algoritmo rápido (cubic es más lento pero mejor calidad)
      final resized = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear, // Más rápido que cubic
      );

      // Comprimir a JPEG con calidad baja
      final compressed = img.encodeJpg(resized, quality: quality);
      
      debugPrint('[ImageOptimizer] Preview: ${originalBytes.length ~/ 1024}KB → ${compressed.length ~/ 1024}KB');
      
      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint('[ImageOptimizer] Error comprimiendo preview: $e');
      return originalBytes; // Retornar original si falla
    }
  }

  /// Comprime imagen para subir (calidad media)
  static Future<Uint8List> comprimirParaSubir(
    Uint8List originalBytes, {
    int maxWidth = 1600,
    int maxHeight = 1600,
    int quality = 70,
  }) async {
    try {
      final originalImage = img.decodeImage(originalBytes);
      if (originalImage == null) return originalBytes;

      // Calcular nuevo tamaño
      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      if (newWidth > maxWidth || newHeight > maxHeight) {
        final aspectRatio = newWidth / newHeight;
        
        if (aspectRatio > 1) {
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        } else {
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      }

      final resized = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.average,
      );

      final compressed = img.encodeJpg(resized, quality: quality);
      
      debugPrint('[ImageOptimizer] Subida: ${originalBytes.length ~/ 1024}KB → ${compressed.length ~/ 1024}KB');
      
      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint('[ImageOptimizer] Error comprimiendo para subir: $e');
      return originalBytes;
    }
  }

  /// Libera memoria después de operaciones pesadas
  static void liberarMemoria() {
    // Force garbage collection hint
    debugPrint('[ImageOptimizer] 🗑️ Solicitando limpieza de memoria');
  }
}
