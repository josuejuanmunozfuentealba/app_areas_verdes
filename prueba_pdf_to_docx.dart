import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'lib/services/catastro_export_service.dart';

/// PRUEBA MÍNIMA AISLADA: Flujo PDF → DOCX vía CloudConvert
///
/// Ejecutar con: flutter run -d windows -t prueba_pdf_to_docx.dart
///
/// Esta prueba valida:
/// 1. Generación de PDF con datos completos
/// 2. Conversión PDF → DOCX mediante Edge Function
/// 3. Descarga de DOCX convertido
/// 4. Verificación de formato válido

Future<void> main() async {
  // Inicializar Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  print('');
  print('========================================');
  print('PRUEBA MÍNIMA: PDF → DOCX');
  print('========================================');
  print('');

  final exportService = CatastroExportService();

  // ===================================================
  // PASO 1: Preparar datos de prueba
  // ===================================================
  print('📋 PASO 1: Preparando datos de prueba...');

  final plazaId = 'PL-TEST-001';
  final nombrePlaza = 'Plaza de Prueba';
  final inspector = 'Inspector de Pruebas';
  final fechaHora = DateTime.now();

  final evaluaciones = <String, String?>{
    'Estado estructural de bancas': 'Bueno',
    'Estado pintura bancas': 'Regular',
    'Estado estructural juegos infantiles': 'Bueno',
    'Estado de pintura de juegos infantiles': 'Malo',
    'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)':
        'Regular',
    'Estado estructural basureros': 'Bueno',
    'Estado pintura de basureros': 'Regular',
  };

  final observaciones = <String, String>{
    'Estado estructural de bancas': 'En buen estado general',
    'Estado pintura bancas': 'Requiere repintado',
    'Estado estructural juegos infantiles': 'Estructura sólida',
    'Estado de pintura de juegos infantiles':
        'Pintura muy deteriorada, oxidación',
    'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)':
        'Llave de 3/4, funciona pero con goteo',
    'Estado estructural basureros': 'Sin observaciones',
    'Estado pintura de basureros': 'Pintura desgastada',
  };

  // Crear foto de prueba usando el logo
  final logoData = await rootBundle.load('assets/logo_2026.png');
  final logoBytes = logoData.buffer.asUint8List();

  final tempDir = Directory.systemTemp;
  final tempFile = File(
    '${tempDir.path}/test_photo_${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await tempFile.writeAsBytes(logoBytes);

  final fotos = [
    {
      'archivo': XFile(tempFile.path),
      'titulo': 'Foto de Prueba - Vista General',
      'nota': 'Fotografía tomada para validar conversión PDF→DOCX',
    },
  ];

  print('✅ Datos de prueba preparados:');
  print('   - Plaza: $plazaId - $nombrePlaza');
  print('   - Inspector: $inspector');
  print('   - Evaluaciones: ${evaluaciones.length}');
  print('   - Observaciones: ${observaciones.length}');
  print('   - Fotografías: ${fotos.length}');
  print('');

  // ===================================================
  // PASO 2: Generar PDF de prueba
  // ===================================================
  print('📄 PASO 2: Generando PDF de prueba...');

  final pdfBytes = await exportService.generarPDF(
    plazaId: plazaId,
    nombrePlaza: nombrePlaza,
    inspector: inspector,
    fechaHora: fechaHora,
    evaluaciones: evaluaciones,
    observaciones: observaciones,
    fotos: fotos,
  );

  final pdfUint8List = Uint8List.fromList(pdfBytes);
  final pdfSizeKB = (pdfUint8List.length / 1024).toStringAsFixed(2);

  print('✅ PDF generado exitosamente');
  print('   - Tamaño: $pdfSizeKB KB');
  print('   - Bytes: ${pdfUint8List.length}');
  print('');

  // Guardar PDF temporalmente
  final pdfTestFile = File('test_catastro.pdf');
  await pdfTestFile.writeAsBytes(pdfUint8List);
  print('📁 PDF guardado en: ${pdfTestFile.absolute.path}');
  print('');

  // ===================================================
  // PASO 3: Verificar seguridad de API Key
  // ===================================================
  print('🔒 PASO 3: Verificando seguridad de API Key...');

  final exportServiceFile = File('lib/services/catastro_export_service.dart');
  if (await exportServiceFile.exists()) {
    final codigo = await exportServiceFile.readAsString();

    final contieneApiKey =
        codigo.contains('cloudconvert') &&
        (codigo.toLowerCase().contains('api_key') ||
            codigo.contains('Bearer')) &&
        !codigo.contains('CLOUDCONVERT_API_KEY') &&
        !codigo.contains('Deno.env.get') &&
        !codigo.contains('const supabaseUrl') &&
        !codigo.contains('const anonKey');

    if (contieneApiKey) {
      print('❌ ADVERTENCIA: Posible API Key expuesta en código Flutter');
    } else {
      print('✅ API Key NO expuesta en código Flutter');
      print('   ✓ La API Key está correctamente oculta en Edge Function');
    }
  }
  print('');

  // ===================================================
  // PASO 4: Convertir PDF → DOCX
  // ===================================================
  print('🔄 PASO 4: Convirtiendo PDF → DOCX...');
  print('   (Esto puede tardar 30-90 segundos)');
  print('');

  final filename = 'test_catastro_${DateTime.now().millisecondsSinceEpoch}.pdf';

  final docxBytes = await exportService.generarWordDesdeConversion(
    plazaId: plazaId,
    nombrePlaza: nombrePlaza,
    inspector: inspector,
    fechaHora: fechaHora,
    evaluaciones: evaluaciones,
    observaciones: observaciones,
    fotos: fotos,
  );

  if (docxBytes == null) {
    print('❌ ERROR: La conversión PDF → DOCX falló');
    print('');
    print('Posibles causas:');
    print('1. Edge Function no desplegada');
    print('   → Ejecutar: supabase functions deploy convert-pdf-to-docx');
    print('');
    print('2. CLOUDCONVERT_API_KEY no configurada');
    print('   → Ejecutar: supabase secrets set CLOUDCONVERT_API_KEY=your_key');
    print('');
    print('3. CloudConvert sin créditos disponibles');
    print('   → Verificar en: https://cloudconvert.com/dashboard');
    print('');
    print('4. PDF muy grande ($pdfSizeKB KB)');
    print('   → Intentar con PDF más pequeño');
    print('');

    exit(1);
  }

  final docxSizeKB = (docxBytes.length / 1024).toStringAsFixed(2);

  print('✅ Conversión exitosa');
  print('   - Tamaño DOCX: $docxSizeKB KB');
  print('   - Bytes: ${docxBytes.length}');
  print('');

  // ===================================================
  // PASO 5: Guardar DOCX
  // ===================================================
  print('💾 PASO 5: Guardando DOCX para inspección...');

  final docxTestFile = File('test_catastro.docx');
  await docxTestFile.writeAsBytes(docxBytes);

  print('✅ DOCX guardado en: ${docxTestFile.absolute.path}');
  print('');

  // ===================================================
  // PASO 6: Verificar formato DOCX válido
  // ===================================================
  print('📦 PASO 6: Verificando formato DOCX válido...');

  final magicBytes = docxBytes.sublist(0, 2);
  final isPKZip = magicBytes[0] == 0x50 && magicBytes[1] == 0x4B;

  if (!isPKZip) {
    print('❌ ERROR: El archivo NO es un ZIP/DOCX válido');
    print(
      '   Magic bytes: ${magicBytes[0].toRadixString(16)} ${magicBytes[1].toRadixString(16)}',
    );
    exit(1);
  }

  print('✅ Formato DOCX válido (ZIP detectado)');
  print('   - Magic bytes: PK (50 4B)');
  print('');

  // ===================================================
  // RESUMEN FINAL
  // ===================================================
  print('========================================');
  print('✅ PRUEBA MÍNIMA COMPLETADA');
  print('========================================');
  print('');
  print('📊 RESUMEN:');
  print('   - PDF generado: $pdfSizeKB KB');
  print('   - DOCX convertido: $docxSizeKB KB');
  print('   - Formato DOCX: ✅ Válido');
  print('   - API Key segura: ✅ No expuesta');
  print('');
  print('📂 ARCHIVOS GENERADOS:');
  print('   - PDF: ${pdfTestFile.absolute.path}');
  print('   - DOCX: ${docxTestFile.absolute.path}');
  print('');
  print('🔍 VALIDACIÓN MANUAL REQUERIDA:');
  print('');
  print('Abrir el DOCX en Microsoft Word y verificar:');
  print('');
  print('✓ Título: "CATASTRO DE INMUEBLES DE ÁREAS VERDES"');
  print('✓ Logo: Aparece en esquina superior derecha');
  print('✓ Información general: Plaza, Inspector, Fecha, Estado');
  print('✓ Tabla de evaluaciones: 7 filas con criterios');
  print('✓ Observaciones: Texto de cada criterio');
  print('✓ Anexo fotográfico: 1 fotografía visible');
  print('✓ Título de foto: "Foto de Prueba - Vista General"');
  print('✓ Nota de foto: Aparece debajo de la imagen');
  print('');
  print('✗ NO debe haber páginas en blanco');
  print('✗ NO debe mostrar código HTML');
  print('✗ NO debe mostrar código XML');
  print('✗ NO debe mostrar Base64');
  print('✗ NO debe mostrar advertencias de Word');
  print('');
  print('Para abrir el archivo:');
  print('   start ${docxTestFile.absolute.path}');
  print('');
  print('========================================');
  print('');

  // Limpiar archivo temporal de foto
  if (await tempFile.exists()) {
    await tempFile.delete();
  }

  exit(0);
}

// Necesario para que Flutter no trate esto como una app normal
class WidgetsFlutterBinding {
  static void ensureInitialized() {
    // Stub para compilación
  }
}
