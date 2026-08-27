import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'lib/services/catastro_export_service.dart';

/// Test completo para validar CatastroExportService con generarWord() delegando a DOCX real
void main() async {
  print('═══════════════════════════════════════════════════════════');
  print('TEST: CATASTRO_EXPORT_SERVICE - GENERADOR WORD CONSOLIDADO');
  print('═══════════════════════════════════════════════════════════\n');

  final service = CatastroExportService();

  // Datos de prueba
  final plazaId = 'PLAZA001';
  final nombrePlaza = 'Plaza Arturo Prat';
  final inspector = 'Juan Pérez';
  final fechaHora = DateTime.now();

  final evaluaciones = {
    'Estado estructural de bancas': 'Bueno',
    'Estado pintura bancas': 'Regular',
    'Estado estructural juegos infantiles': 'Bueno',
    'Estado de pintura de juegos infantiles': 'Malo',
    'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)': 'Bueno',
    'Estado estructural basureros': 'Regular',
    'Estado pintura de basureros': 'Bueno',
  };

  final observaciones = {
    'Estado estructural de bancas': 'Estructura sólida',
    'Estado pintura bancas': 'Necesita repintado',
    'Estado estructural juegos infantiles': 'Sin daños',
    'Estado de pintura de juegos infantiles': 'Pintura muy deteriorada',
    'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)': 'Llave de 3/4"',
    'Estado estructural basureros': 'Base oxidada',
    'Estado pintura de basureros': 'Pintado recientemente',
  };

  // ========================================================================
  // TEST 1: generarWord() con 1 foto (debe delegar a generarWordDocx())
  // ========================================================================
  print('─────────────────────────────────────────────────────────');
  print('TEST 1: generarWord() con 1 fotografía');
  print('─────────────────────────────────────────────────────────\n');

  try {
    // Crear imagen de prueba de 400x300 píxeles
    final imageFile = File('test_foto_1.jpg');
    if (!imageFile.existsSync()) {
      print('⚠️  Creando imagen de prueba: test_foto_1.jpg');
      // Crear una imagen simple (cuadrado rojo)
      final imageBytes = _crearImagenPrueba(400, 300);
      await imageFile.writeAsBytes(imageBytes);
    }

    final fotos = [
      {
        'archivo': XFile(imageFile.path),
        'nota': 'Vista general de la plaza',
      },
    ];

    print('Ejecutando: generarWord() con 1 foto...');
    final startTime = DateTime.now();

    final wordBytes = await service.generarWord(
      plazaId: plazaId,
      nombrePlaza: nombrePlaza,
      inspector: inspector,
      fechaHora: fechaHora,
      evaluaciones: evaluaciones,
      observaciones: observaciones,
      fotos: fotos,
    );

    final duration = DateTime.now().difference(startTime);

    // Guardar archivo
    final outputFile = File('output_test1_con_1_foto.docx');
    await outputFile.writeAsBytes(wordBytes);

    print('✅ generarWord() ejecutado en ${duration.inMilliseconds}ms');
    print('✅ Tamaño: ${(wordBytes.length / 1024).toStringAsFixed(1)} KB');
    print('✅ Guardado: ${outputFile.path}');
    print('✅ Fotografías procesadas: 1');
  } catch (e) {
    print('❌ ERROR en TEST 1: $e');
  }

  print('\n');

  // ========================================================================
  // TEST 2: generarWord() sin fotos
  // ========================================================================
  print('─────────────────────────────────────────────────────────');
  print('TEST 2: generarWord() SIN fotografías');
  print('─────────────────────────────────────────────────────────\n');

  try {
    print('Ejecutando: generarWord() sin fotos...');
    final startTime = DateTime.now();

    final wordBytes = await service.generarWord(
      plazaId: plazaId,
      nombrePlaza: nombrePlaza,
      inspector: inspector,
      fechaHora: fechaHora,
      evaluaciones: evaluaciones,
      observaciones: observaciones,
      fotos: [],
    );

    final duration = DateTime.now().difference(startTime);

    // Guardar archivo
    final outputFile = File('output_test2_sin_fotos.docx');
    await outputFile.writeAsBytes(wordBytes);

    print('✅ generarWord() ejecutado en ${duration.inMilliseconds}ms');
    print('✅ Tamaño: ${(wordBytes.length / 1024).toStringAsFixed(1)} KB');
    print('✅ Guardado: ${outputFile.path}');
    print('✅ Sin fotografías: correcto');
  } catch (e) {
    print('❌ ERROR en TEST 2: $e');
  }

  print('\n');

  // ========================================================================
  // TEST 3: generarWord() con 3 fotos
  // ========================================================================
  print('─────────────────────────────────────────────────────────');
  print('TEST 3: generarWord() con 3 fotografías');
  print('─────────────────────────────────────────────────────────\n');

  try {
    // Crear 3 imágenes de prueba
    final fotos = <Map<String, dynamic>>[];

    for (int i = 1; i <= 3; i++) {
      final imageFile = File('test_foto_$i.jpg');
      if (!imageFile.existsSync()) {
        print('⚠️  Creando imagen de prueba: test_foto_$i.jpg');
        final imageBytes = _crearImagenPrueba(400 + (i * 50), 300 + (i * 50));
        await imageFile.writeAsBytes(imageBytes);
      }

      fotos.add({
        'archivo': XFile(imageFile.path),
        'nota': 'Fotografía número $i - Área específica ${i * 10}',
      });
    }

    print('Ejecutando: generarWord() con 3 fotos...');
    final startTime = DateTime.now();

    final wordBytes = await service.generarWord(
      plazaId: plazaId,
      nombrePlaza: nombrePlaza,
      inspector: inspector,
      fechaHora: fechaHora,
      evaluaciones: evaluaciones,
      observaciones: observaciones,
      fotos: fotos,
    );

    final duration = DateTime.now().difference(startTime);

    // Guardar archivo
    final outputFile = File('output_test3_con_3_fotos.docx');
    await outputFile.writeAsBytes(wordBytes);

    print('✅ generarWord() ejecutado en ${duration.inMilliseconds}ms');
    print('✅ Tamaño: ${(wordBytes.length / 1024).toStringAsFixed(1)} KB');
    print('✅ Guardado: ${outputFile.path}');
    print('✅ Fotografías procesadas: 3');
  } catch (e) {
    print('❌ ERROR en TEST 3: $e');
  }

  print('\n');

  // ========================================================================
  // TEST 4: generarWordDocx() directamente
  // ========================================================================
  print('─────────────────────────────────────────────────────────');
  print('TEST 4: generarWordDocx() directo con 1 foto');
  print('─────────────────────────────────────────────────────────\n');

  try {
    final imageFile = File('test_foto_1.jpg');
    final fotos = [
      {
        'archivo': XFile(imageFile.path),
        'nota': 'Vista general de la plaza',
      },
    ];

    print('Ejecutando: generarWordDocx() directo...');
    final startTime = DateTime.now();

    final wordBytes = await service.generarWordDocx(
      plazaId: plazaId,
      nombrePlaza: nombrePlaza,
      inspector: inspector,
      fechaHora: fechaHora,
      evaluaciones: evaluaciones,
      observaciones: observaciones,
      fotos: fotos,
    );

    final duration = DateTime.now().difference(startTime);

    // Guardar archivo
    final outputFile = File('output_test4_docx_directo.docx');
    await outputFile.writeAsBytes(wordBytes);

    print('✅ generarWordDocx() ejecutado en ${duration.inMilliseconds}ms');
    print('✅ Tamaño: ${(wordBytes.length / 1024).toStringAsFixed(1)} KB');
    print('✅ Guardado: ${outputFile.path}');
  } catch (e) {
    print('❌ ERROR en TEST 4: $e');
  }

  print('\n═══════════════════════════════════════════════════════════');
  print('RESUMEN DE TESTS');
  print('═══════════════════════════════════════════════════════════\n');

  print('Archivos generados:');
  print('  1. output_test1_con_1_foto.docx');
  print('  2. output_test2_sin_fotos.docx');
  print('  3. output_test3_con_3_fotos.docx');
  print('  4. output_test4_docx_directo.docx');
  print('\nValidación manual requerida:');
  print('  ✓ Abrir cada archivo en Microsoft Word');
  print('  ✓ Verificar que no aparezcan advertencias');
  print('  ✓ Verificar que aparezca logo');
  print('  ✓ Verificar datos de plaza, inspector, fecha');
  print('  ✓ Verificar 7 criterios de evaluación');
  print('  ✓ Verificar fotografías (cuando aplique)');
  print('  ✓ Verificar notas de fotografías');
  print('  ✓ NO debe aparecer HTML ni Base64 visible');
  print('  ✓ NO debe aparecer {{placeholders}} visibles');
  print('\n═══════════════════════════════════════════════════════════');
}

/// Crea una imagen JPEG simple para pruebas
List<int> _crearImagenPrueba(int width, int height) {
  // Crear un archivo JPEG mínimo válido
  // Este es un JPEG de 1x1 píxel rojo válido
  return [
    0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, //
    0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
    0x00, 0x03, 0x02, 0x02, 0x02, 0x02, 0x02, 0x03, 0x02, 0x02, 0x02, 0x03,
    0x03, 0x03, 0x03, 0x04, 0x06, 0x04, 0x04, 0x04, 0x04, 0x04, 0x08, 0x06,
    0x06, 0x05, 0x06, 0x09, 0x08, 0x0A, 0x0A, 0x09, 0x08, 0x09, 0x09, 0x0A,
    0x0C, 0x0F, 0x0C, 0x0A, 0x0B, 0x0E, 0x0B, 0x09, 0x09, 0x0D, 0x11, 0x0D,
    0x0E, 0x0F, 0x10, 0x10, 0x11, 0x10, 0x0A, 0x0C, 0x12, 0x13, 0x12, 0x10,
    0x13, 0x0F, 0x10, 0x10, 0x10, 0xFF, 0xC9, 0x00, 0x0B, 0x08, 0x00, 0x01,
    0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xCC, 0x00, 0x06, 0x00, 0x10,
    0x10, 0x05, 0xFF, 0xDA, 0x00, 0x08, 0x01, 0x01, 0x00, 0x00, 0x3F, 0x00,
    0xD2, 0xCF, 0x20, 0xFF, 0xD9,
  ];
}
