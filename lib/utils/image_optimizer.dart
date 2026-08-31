import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

/// Optimizador de imágenes para reducir consumo de memoria en móviles
class ImageOptimizer {
  /// Comprime una imagen para preview (thumbnail ultra pequeño)
  /// ✅ Optimizado para móviles con poca RAM
  static Future<Uint8List> comprimirParaPreview(
    Uint8List originalBytes, {
    int maxWidth = 300, // Thumbnail ultra pequeño
    int maxHeight = 300,
    int quality = 40, // ✅ Calidad ultra baja para thumbnail (< 30 KB)
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

      // Redimensionar con algoritmo RÁPIDO (linear es el más rápido)
      final resized = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.linear, // Más rápido, no bloquea UI
      );

      // Comprimir a JPEG con calidad ultra baja para preview
      final compressed = img.encodeJpg(resized, quality: quality);

      debugPrint(
        '[ImageOptimizer] Preview: ${originalBytes.length ~/ 1024}KB → ${compressed.length ~/ 1024}KB',
      );

      // ✅ LIBERAR MEMORIA: Limpiar caché de imágenes tras procesar
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

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

      debugPrint(
        '[ImageOptimizer] Subida: ${originalBytes.length ~/ 1024}KB → ${compressed.length ~/ 1024}KB',
      );

      // ✅ LIBERAR MEMORIA tras operación pesada
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      return Uint8List.fromList(compressed);
    } catch (e) {
      debugPrint('[ImageOptimizer] Error comprimiendo para subir: $e');
      return originalBytes;
    }
  }

  /// Libera memoria agresivamente después de operaciones pesadas
  /// ✅ Previene sobrecalentamiento y bloqueos de UI en móviles
  static void liberarMemoria() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    debugPrint(
      '[ImageOptimizer] 🗑️ Caché de imágenes limpiado (RAM liberada)',
    );
  }
}
