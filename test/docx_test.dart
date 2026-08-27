import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:app_areas_verdes/services/docx_real_generator.dart';

/// Test de generación de DOCX real - FASE 1
///
/// Este test genera un archivo docx_prueba_fase1.docx en la raíz del proyecto.
///
/// VALIDACIÓN MANUAL REQUERIDA:
/// 1. Abrir el archivo docx_prueba_fase1.docx en Microsoft Word
/// 2. Verificar que NO solicite reparar el documento
/// 3. Verificar que NO aparezca "contenido ilegible"
/// 4. Verificar que el título aparezca centrado y en verde
/// 5. Verificar que el texto sea legible
/// 6. Verificar que el tamaño de página sea A4
///
/// Si Word abre el archivo sin problemas, la FASE 1 está completa.
void main() {
  test('FASE 1: Generar DOCX mínimo válido', () async {
    // Crear generador
    final generator = DocxRealGenerator();

    // Generar DOCX mínimo
    final docxBytes = await generator.generarDocxMinimo();

    // Guardar archivo en la raíz del proyecto
    final file = File('docx_prueba_fase1.docx');
    await file.writeAsBytes(docxBytes);

    print('');
    print('=' * 70);
    print('FASE 1: DOCX MÍNIMO GENERADO');
    print('=' * 70);
    print('Archivo: ${file.absolute.path}');
    print('Tamaño: ${(docxBytes.length / 1024).toStringAsFixed(1)} KB');
    print('');
    print('VALIDACIÓN MANUAL REQUERIDA:');
    print('1. Abrir docx_prueba_fase1.docx en Microsoft Word');
    print('2. Verificar que NO solicite reparar');
    print('3. Verificar que NO aparezca "contenido ilegible"');
    print('4. Verificar título centrado en verde');
    print('5. Verificar texto legible');
    print('6. Verificar tamaño A4');
    print('');
    print('Si Word abre el archivo correctamente:');
    print('✅ FASE 1 COMPLETA - Continuar con FASE 2');
    print('');
    print('Si Word muestra errores:');
    print('❌ FASE 1 FALLIDA - Corregir antes de continuar');
    print('=' * 70);
    print('');

    // Verificar que se generaron bytes
    expect(docxBytes.isNotEmpty, true);
    expect(
      docxBytes.length,
      greaterThan(1000),
    ); // Un DOCX básico debe tener al menos 1KB
  });

  test('FASE 1: Verificar estructura ZIP del DOCX', () async {
    final generator = DocxRealGenerator();
    final docxBytes = await generator.generarDocxMinimo();

    // El DOCX es un ZIP, debe comenzar con signature ZIP (PK)
    expect(docxBytes[0], 0x50); // 'P'
    expect(docxBytes[1], 0x4B); // 'K'

    print('');
    print('✅ Estructura ZIP válida (comienza con PK)');
    print('');
  });

  // ==========================================================================
  // FASE 2: DOCX CON UNA IMAGEN
  // ==========================================================================

  test('FASE 2: Generar DOCX con UNA imagen', () async {
    // Crear generador
    final generator = DocxRealGenerator();

    // Cargar imagen de prueba (logo del proyecto)
    final imageData = await rootBundle.load('assets/logo_2026.png');
    final imageBytes = imageData.buffer.asUint8List();

    // Generar DOCX con imagen
    final docxBytes = await generator.generarDocxConImagen(
      imagenBytes: imageBytes,
    );

    // Guardar archivo en la raíz del proyecto
    final file = File('docx_prueba_fase2.docx');
    await file.writeAsBytes(docxBytes);

    print('');
    print('=' * 70);
    print('FASE 2: DOCX CON UNA IMAGEN GENERADO');
    print('=' * 70);
    print('Archivo: ${file.absolute.path}');
    print('Tamaño: ${(docxBytes.length / 1024).toStringAsFixed(1)} KB');
    print(
      'Imagen: logo_2026.png (${(imageBytes.length / 1024).toStringAsFixed(1)} KB)',
    );
    print('');
    print('VALIDACIÓN MANUAL REQUERIDA:');
    print('1. Abrir docx_prueba_fase2.docx en Microsoft Word');
    print('2. Verificar que NO solicite reparar');
    print('3. Verificar que la imagen APARECE');
    print('4. Verificar que la imagen mantiene proporción');
    print('5. Verificar que la imagen está CENTRADA');
    print('6. Verificar que la imagen está DENTRO de los márgenes');
    print('');
    print('Si Word muestra la imagen correctamente:');
    print('✅ FASE 2 COMPLETA - Continuar con FASE 3');
    print('');
    print('Si la imagen NO aparece o hay errores:');
    print('❌ FASE 2 FALLIDA - Corregir antes de continuar');
    print('=' * 70);
    print('');

    // Verificar que se generaron bytes
    expect(docxBytes.isNotEmpty, true);
    expect(
      docxBytes.length,
      greaterThan(imageBytes.length),
    ); // Debe ser más grande que solo la imagen
  });
}
