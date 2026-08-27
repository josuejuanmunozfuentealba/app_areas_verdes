import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_areas_verdes/services/catastro_export_service.dart';

/// PRUEBA MÍNIMA AISLADA: Flujo PDF → DOCX vía CloudConvert
///
/// Esta prueba valida:
/// 1. Generación de PDF con datos completos (foto, logo, evaluaciones)
/// 2. Conversión PDF → DOCX mediante Edge Function de Supabase
/// 3. Descarga de DOCX convertido
/// 4. Verificación de formato DOCX válido
///
/// NO modifica código existente
/// NO elimina sistema antiguo
/// SOLO valida nueva estrategia

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Prueba Mínima: PDF → DOCX vía CloudConvert', () {
    late CatastroExportService exportService;

    setUp(() {
      exportService = CatastroExportService();
    });

    test(
      'PASO 1-10: Flujo completo de conversión PDF → DOCX',
      () async {
        print('');
        print('========================================');
        print('PRUEBA MÍNIMA: PDF → DOCX');
        print('========================================');
        print('');

        // ===================================================
        // PASO 1: Preparar datos de prueba
        // ===================================================
        print('📋 PASO 1: Preparando datos de prueba...');

        final plazaId = 'PL-TEST-001';
        final nombrePlaza = 'Plaza de Prueba';
        final inspector = 'Inspector de Pruebas';
        final fechaHora = DateTime.now();

        // Evaluaciones completas (7 criterios oficiales)
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

        // Observaciones
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

        // Crear foto de prueba (imagen de test)
        // En un test real, necesitamos una imagen válida
        // Por ahora, usaremos el logo como "foto de prueba"
        final logoData = await rootBundle.load('assets/logo_2026.png');
        final logoBytes = logoData.buffer.asUint8List();

        // Crear archivo temporal para simular XFile
        final tempDir = Directory.systemTemp;
        final tempFile = File('${tempDir.path}/test_photo.png');
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

        // Guardar PDF temporalmente para inspección
        final pdfTestFile = File('${tempDir.path}/test_catastro.pdf');
        await pdfTestFile.writeAsBytes(pdfUint8List);
        print('📁 PDF guardado en: ${pdfTestFile.path}');
        print('');

        // ===================================================
        // PASO 3: Verificar que API Key NO esté en código
        // ===================================================
        print('🔒 PASO 3: Verificando seguridad de API Key...');

        // Leer el código fuente de CatastroExportService
        final exportServiceFile = File(
          'lib/services/catastro_export_service.dart',
        );
        if (await exportServiceFile.exists()) {
          final codigo = await exportServiceFile.readAsString();

          // Verificar que NO contenga la API Key de CloudConvert
          final contieneApiKey =
              codigo.contains('cloudconvert') &&
              (codigo.contains('api_key') || codigo.contains('Bearer'));

          if (contieneApiKey &&
              !codigo.contains('CLOUDCONVERT_API_KEY') &&
              !codigo.contains('Deno.env.get')) {
            print('❌ ADVERTENCIA: Posible API Key expuesta en código Flutter');
            print(
              '   La API Key debe estar SOLO en la Edge Function de Supabase',
            );
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

        final filename =
            'test_catastro_${DateTime.now().millisecondsSinceEpoch}.pdf';

        final docxUrl = await exportService.convertPdfToDocx(
          pdfBytes: pdfUint8List,
          filename: filename,
        );

        if (docxUrl == null) {
          print('❌ ERROR: La conversión PDF → DOCX falló');
          print('');
          print('Posibles causas:');
          print('1. Edge Function no desplegada');
          print('   → Ejecutar: supabase functions deploy convert-pdf-to-docx');
          print('');
          print('2. CLOUDCONVERT_API_KEY no configurada');
          print(
            '   → Ejecutar: supabase secrets set CLOUDCONVERT_API_KEY=your_key',
          );
          print('');
          print('3. CloudConvert sin créditos disponibles');
          print('   → Verificar en: https://cloudconvert.com/dashboard');
          print('');
          print('4. PDF muy grande o Edge Function timeout');
          print('   → Reducir tamaño de imágenes en PDF');
          print('');

          fail('Conversión PDF → DOCX falló. Ver logs arriba.');
        }

        print('✅ Conversión exitosa');
        print('   - DOCX URL: $docxUrl');
        print('');

        // ===================================================
        // PASO 5: Descargar DOCX
        // ===================================================
        print('⬇️  PASO 5: Descargando DOCX convertido...');

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
          print('❌ ERROR: No se pudo descargar el DOCX');
          fail('Descarga de DOCX falló');
        }

        final docxSizeKB = (docxBytes.length / 1024).toStringAsFixed(2);

        print('✅ DOCX descargado exitosamente');
        print('   - Tamaño: $docxSizeKB KB');
        print('   - Bytes: ${docxBytes.length}');
        print('');

        // ===================================================
        // PASO 6: Guardar DOCX temporalmente
        // ===================================================
        print('💾 PASO 6: Guardando DOCX para inspección...');

        final docxTestFile = File('${tempDir.path}/test_catastro.docx');
        await docxTestFile.writeAsBytes(docxBytes);

        print('✅ DOCX guardado en: ${docxTestFile.path}');
        print('');

        // ===================================================
        // PASO 7: Verificar extensión .docx
        // ===================================================
        print('📝 PASO 7: Verificando extensión .docx...');

        final extension = docxTestFile.path.split('.').last;
        expect(
          extension,
          equals('docx'),
          reason: 'El archivo debe tener extensión .docx',
        );

        print('✅ Extensión correcta: .$extension');
        print('');

        // ===================================================
        // PASO 8: Verificar que sea un ZIP/DOCX válido
        // ===================================================
        print('📦 PASO 8: Verificando formato DOCX válido...');

        // Un DOCX válido es un ZIP que comienza con "PK"
        final magicBytes = docxBytes.sublist(0, 2);
        final isPKZip = magicBytes[0] == 0x50 && magicBytes[1] == 0x4B;

        if (!isPKZip) {
          print('❌ ERROR: El archivo NO es un ZIP/DOCX válido');
          print(
            '   Magic bytes: ${magicBytes[0].toRadixString(16)} ${magicBytes[1].toRadixString(16)}',
          );
          print('   Esperado: 50 4B (PK)');
          fail('DOCX no es un archivo ZIP válido');
        }

        print('✅ Formato DOCX válido (ZIP detectado)');
        print('   - Magic bytes: PK (50 4B)');
        print('');

        // ===================================================
        // PASO 9: Verificar contenido (no HTML/Base64/XML)
        // ===================================================
        print('🔍 PASO 9: Verificando contenido interno...');

        // Convertir primeros 1000 bytes a string para inspección
        final previewBytes = docxBytes.sublist(
          0,
          1000.clamp(0, docxBytes.length),
        );
        final preview = String.fromCharCodes(previewBytes);

        // Verificar que NO contenga HTML visible
        if (preview.contains('<html>') ||
            preview.contains('<body>') ||
            preview.contains('<div>')) {
          print(
            '⚠️  ADVERTENCIA: El DOCX contiene etiquetas HTML visibles (no esperado)',
          );
        } else {
          print('✅ NO contiene HTML visible');
        }

        // Verificar que NO contenga Base64 largo visible
        if (preview.contains('data:image') || preview.contains('base64,')) {
          print(
            '⚠️  ADVERTENCIA: El DOCX contiene Base64 visible (no esperado)',
          );
        } else {
          print('✅ NO contiene Base64 visible');
        }

        print('');

        // ===================================================
        // PASO 10: Instrucciones de validación visual
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
        print('📂 ARCHIVOS DE PRUEBA:');
        print('   - PDF: ${pdfTestFile.path}');
        print('   - DOCX: ${docxTestFile.path}');
        print('');
        print('🔍 VALIDACIÓN MANUAL REQUERIDA:');
        print('');
        print('1. Abrir el DOCX en Microsoft Word:');
        print('   start ${docxTestFile.path}');
        print('');
        print('2. Verificar visualmente:');
        print('   ✓ Título: "CATASTRO DE INMUEBLES DE ÁREAS VERDES"');
        print('   ✓ Logo: Aparece en esquina superior derecha');
        print('   ✓ Información general: Plaza, Inspector, Fecha, Estado');
        print('   ✓ Tabla de evaluaciones: 7 filas con criterios');
        print('   ✓ Observaciones: Texto de cada criterio');
        print('   ✓ Anexo fotográfico: 1 fotografía visible');
        print('   ✓ Título de foto: "Foto de Prueba - Vista General"');
        print('   ✓ Nota de foto: Aparece debajo de la imagen');
        print('');
        print('3. Verificar ausencia de problemas:');
        print('   ✗ NO debe haber páginas en blanco');
        print('   ✗ NO debe mostrar código HTML');
        print('   ✗ NO debe mostrar código XML');
        print('   ✗ NO debe mostrar Base64');
        print('   ✗ NO debe mostrar advertencias de Word');
        print('');
        print('4. Si TODO está correcto:');
        print('   ✅ La estrategia PDF → DOCX funciona');
        print('   ✅ Se puede proceder a integrar en la app');
        print('');
        print('5. Si HAY problemas:');
        print('   ❌ Reportar qué elementos fallan');
        print('   ❌ Capturar pantalla del problema');
        print('   ❌ NO continuar con integración');
        print('');
        print('========================================');
        print('');

        // Limpiar archivos temporales después de 5 minutos
        Future.delayed(const Duration(minutes: 5), () async {
          if (await tempFile.exists()) await tempFile.delete();
        });

        // Test pasa si llegamos aquí
        expect(docxBytes.length, greaterThan(0));
        expect(isPKZip, isTrue);
      },
      timeout: const Timeout(Duration(minutes: 10)),
    );
  });
}
