import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'lib/services/catastro_export_service.dart';

/// Test final del base.docx reparado
void main() async {
  print('═══════════════════════════════════════════════════════════');
  print('TEST: BASE.DOCX REPARADO - GENERACIÓN COMPLETA');
  print('═══════════════════════════════════════════════════════════\n');

  final service = CatastroExportService();

  // Datos de prueba
  final evaluaciones = {
    'Estado estructural de bancas': 'Bueno',
    'Estado pintura bancas': 'Regular',
    'Estado estructural juegos infantiles': 'Bueno',
    'Estado de pintura de juegos infantiles': 'Malo',
    'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)':
        'Bueno',
    'Estado estructural basureros': 'Regular',
    'Estado pintura de basureros': 'Bueno',
  };

  final observaciones = {
    'Estado estructural de bancas': 'Estructura sólida',
    'Estado pintura bancas': 'Necesita repintado',
    'Estado estructural juegos infantiles': 'Sin daños',
    'Estado de pintura de juegos infantiles': 'Pintura muy deteriorada',
    'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)':
        'Llave de 3/4"',
    'Estado estructural basureros': 'Base oxidada',
    'Estado pintura de basureros': 'Pintado recientemente',
  };

  // Crear 1 foto de prueba
  final imageFile = File('test_foto_1.jpg');
  if (!imageFile.existsSync()) {
    print('⚠️  Creando imagen de prueba...');
    // JPEG 1x1 mínimo válido
    final jpegBytes = [
      0xFF,
      0xD8,
      0xFF,
      0xE0,
      0x00,
      0x10,
      0x4A,
      0x46,
      0x49,
      0x46,
      0x00,
      0x01,
      0x01,
      0x01,
      0x00,
      0x48,
      0x00,
      0x48,
      0x00,
      0x00,
      0xFF,
      0xDB,
      0x00,
      0x43,
      0x00,
      0x03,
      0x02,
      0x02,
      0x02,
      0x02,
      0x02,
      0x03,
      0x02,
      0x02,
      0x02,
      0x03,
      0x03,
      0x03,
      0x03,
      0x04,
      0x06,
      0x04,
      0x04,
      0x04,
      0x04,
      0x04,
      0x08,
      0x06,
      0x06,
      0x05,
      0x06,
      0x09,
      0x08,
      0x0A,
      0x0A,
      0x09,
      0x08,
      0x09,
      0x09,
      0x0A,
      0x0C,
      0x0F,
      0x0C,
      0x0A,
      0x0B,
      0x0E,
      0x0B,
      0x09,
      0x09,
      0x0D,
      0x11,
      0x0D,
      0x0E,
      0x0F,
      0x10,
      0x10,
      0x11,
      0x10,
      0x0A,
      0x0C,
      0x12,
      0x13,
      0x12,
      0x10,
      0x13,
      0x0F,
      0x10,
      0x10,
      0x10,
      0xFF,
      0xC9,
      0x00,
      0x0B,
      0x08,
      0x00,
      0x01,
      0x00,
      0x01,
      0x01,
      0x01,
      0x11,
      0x00,
      0xFF,
      0xCC,
      0x00,
      0x06,
      0x00,
      0x10,
      0x10,
      0x05,
      0xFF,
      0xDA,
      0x00,
      0x08,
      0x01,
      0x01,
      0x00,
      0x00,
      0x3F,
      0x00,
      0xD2,
      0xCF,
      0x20,
      0xFF,
      0xD9,
    ];
    await imageFile.writeAsBytes(jpegBytes);
  }

  final fotos = [
    {
      'archivo': XFile(imageFile.path),
      'nota': 'Vista general de la plaza - Foto de prueba',
    },
  ];

  print('Ejecutando: generarWordDocx() con base.docx reparado...\n');

  try {
    final startTime = DateTime.now();

    final wordBytes = await service.generarWordDocx(
      plazaId: 'PLAZA001',
      nombrePlaza: 'Plaza Arturo Prat',
      inspector: 'Juan Pérez',
      fechaHora: DateTime.now(),
      evaluaciones: evaluaciones,
      observaciones: observaciones,
      fotos: fotos,
    );

    final duration = DateTime.now().difference(startTime);

    // Guardar archivo
    final outputFile = File('output_base_docx_reparado.docx');
    await outputFile.writeAsBytes(wordBytes);

    print('\n═══════════════════════════════════════════════════════════');
    print('✅ GENERACIÓN EXITOSA');
    print('═══════════════════════════════════════════════════════════');
    print('Tiempo: ${duration.inMilliseconds}ms');
    print('Tamaño: ${(wordBytes.length / 1024).toStringAsFixed(1)} KB');
    print('Archivo: ${outputFile.absolute.path}');
    print('\nValidación manual:');
    print('  1. Abrir output_base_docx_reparado.docx en Microsoft Word');
    print('  2. Verificar que aparezca:');
    print('     ✓ Logo en la parte superior derecha');
    print('     ✓ Título: CATASTRO DE INMUEBLES DE ÁREAS VERDES');
    print('     ✓ Tabla con información de plaza');
    print('     ✓ Tabla con 7 criterios de evaluación');
    print('     ✓ Anexo fotográfico con 1 foto');
    print('     ✓ NO debe haber páginas en blanco extra');
    print('     ✓ NO debe haber placeholders visibles como {{}}');
  } catch (e) {
    print('\n❌ ERROR: $e');
    print('\nStackTrace:');
    print(StackTrace.current);
  }
}
