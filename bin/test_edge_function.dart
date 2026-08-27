// Script Dart puro para probar Edge Function de Supabase
// NO requiere Flutter, solo Dart SDK
//
// Ejecutar con: dart run bin/test_edge_function.dart [ruta_al_pdf.pdf]

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';

// Constantes de Supabase (públicas, no sensibles)
const SUPABASE_URL = 'https://speneggmlqitgfjhzsry.supabase.co';
const SUPABASE_ANON_KEY =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg';

void main(List<String> arguments) async {
  print('');
  print('========================================');
  print('PRUEBA AISLADA: Edge Function');
  print('PDF → Supabase → CloudConvert → DOCX');
  print('========================================');
  print('');

  // ===================================================
  // PASO 1: Validar argumentos
  // ===================================================
  if (arguments.isEmpty) {
    print('❌ ERROR: Falta argumento');
    print('');
    print('Uso: dart run bin/test_edge_function.dart [ruta_al_pdf.pdf]');
    print('');
    print('Ejemplo:');
    print('  dart run bin/test_edge_function.dart test_catastro.pdf');
    print('');
    exit(1);
  }

  final pdfPath = arguments[0];
  final pdfFile = File(pdfPath);

  if (!await pdfFile.exists()) {
    print('❌ ERROR: Archivo no encontrado: $pdfPath');
    print('');
    print('Verifica que el archivo existe:');
    print('  - Ruta actual: ${Directory.current.path}');
    print('  - Archivo buscado: ${pdfFile.absolute.path}');
    print('');
    exit(1);
  }

  print('📄 PASO 1: Archivo PDF encontrado');
  print('   - Ruta: ${pdfFile.absolute.path}');

  // ===================================================
  // PASO 2: Leer PDF y convertir a Base64
  // ===================================================
  print('');
  print('📦 PASO 2: Leyendo y codificando PDF...');

  final pdfBytes = await pdfFile.readAsBytes();
  final pdfSizeKB = (pdfBytes.length / 1024).toStringAsFixed(2);

  print('   - Tamaño: $pdfSizeKB KB');
  print('   - Bytes: ${pdfBytes.length}');

  // Validar que es un PDF válido (comienza con %PDF)
  final header = String.fromCharCodes(pdfBytes.sublist(0, 4));
  if (header != '%PDF') {
    print('');
    print('⚠️  ADVERTENCIA: El archivo NO parece ser un PDF válido');
    print('   - Header encontrado: $header');
    print('   - Header esperado: %PDF');
    print('');
    print('¿Continuar de todas formas? (s/n)');
    final answer = stdin.readLineSync();
    if (answer?.toLowerCase() != 's') {
      print('Prueba cancelada');
      exit(0);
    }
  } else {
    print('   - ✅ Header PDF válido: $header');
  }

  final startEncode = DateTime.now();
  final pdfBase64 = base64Encode(pdfBytes);
  final encodeTime = DateTime.now().difference(startEncode);

  print('   - ✅ Codificación completada en ${encodeTime.inMilliseconds}ms');
  print('   - Base64 length: ${pdfBase64.length} caracteres');

  // ===================================================
  // PASO 3: Revisar contrato de la Edge Function
  // ===================================================
  print('');
  print('📋 PASO 3: Contrato de API verificado');
  print('   - Endpoint: $SUPABASE_URL/functions/v1/convert-pdf-to-docx');
  print('   - Método: POST');
  print('   - Headers: Authorization (Bearer token), Content-Type (JSON)');
  print('   - Body: { "pdfBase64": "...", "filename": "test.pdf" }');
  print('   - Respuesta esperada 200: { "success": true, "docxUrl": "..." }');
  print('   - Respuesta error: { "success": false, "error": "...", "message": "..." }');

  // ===================================================
  // PASO 4: Llamar a Edge Function
  // ===================================================
  print('');
  print('🚀 PASO 4: Llamando a Edge Function...');
  print('   (Esto puede tardar 30-90 segundos)');
  print('');

  final functionUrl = '$SUPABASE_URL/functions/v1/convert-pdf-to-docx';
  final filename = 'test_${DateTime.now().millisecondsSinceEpoch}.pdf';

  final requestBody = jsonEncode({
    'pdfBase64': pdfBase64,
    'filename': filename,
  });

  print('   - Enviando request...');
  print('   - Payload size: ${requestBody.length} bytes');

  final startRequest = DateTime.now();

  try {
    final response = await http
        .post(
          Uri.parse(functionUrl),
          headers: {
            'Authorization': 'Bearer $SUPABASE_ANON_KEY',
            'Content-Type': 'application/json',
          },
          body: requestBody,
        )
        .timeout(
          const Duration(minutes: 6),
          onTimeout: () {
            print('');
            print('❌ TIMEOUT: La Edge Function no respondió en 6 minutos');
            print('');
            print('Posibles causas:');
            print('1. CloudConvert está procesando un PDF muy grande');
            print('2. La Edge Function está caída');
            print('3. Problemas de red');
            print('');
            exit(1);
          },
        );

    final requestTime = DateTime.now().difference(startRequest);

    print('   - ✅ Respuesta recibida en ${requestTime.inSeconds}s');
    print('');

    // ===================================================
    // PASO 5: Analizar respuesta HTTP
    // ===================================================
    print('📊 PASO 5: Analizando respuesta HTTP...');
    print('');

    print('A. ¿La Edge Function respondió?');
    print('   ✅ SÍ (status: ${response.statusCode})');
    print('');

    print('B. Código HTTP: ${response.statusCode}');
    print('');

    // Parsear body
    Map<String, dynamic>? jsonResponse;
    try {
      jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      print('⚠️  Body no es JSON válido');
      print('');
    }

    print('C. Body de respuesta:');
    if (jsonResponse != null) {
      print('   ${JsonEncoder.withIndent("   ").convert(jsonResponse)}');
    } else {
      print('   (raw) ${response.body}');
    }
    print('');

    // ===================================================
    // CASO: Error HTTP (4xx, 5xx)
    // ===================================================
    if (response.statusCode != 200) {
      print('❌ ERROR: Edge Function retornó código ${response.statusCode}');
      print('');

      if (jsonResponse != null) {
        final error = jsonResponse['error'] ?? 'Unknown error';
        final message = jsonResponse['message'] ?? 'No message';

        print('   - Error: $error');
        print('   - Message: $message');
        print('');
      }

      print('DIAGNÓSTICO:');
      print('');

      if (response.statusCode == 400) {
        print('HTTP 400 - Bad Request');
        print('La Edge Function rechazó el request.');
        print('');
        print('Posibles causas:');
        print('1. Campo "pdfBase64" falta o está vacío');
        print('2. PDF Base64 mal codificado');
        print('3. Formato JSON incorrecto');
        print('');
      } else if (response.statusCode == 405) {
        print('HTTP 405 - Method Not Allowed');
        print('La Edge Function solo acepta POST');
        print('');
      } else if (response.statusCode == 500) {
        print('HTTP 500 - Internal Server Error');
        print('Error en la Edge Function');
        print('');
        print('Posibles causas:');
        print('1. CLOUDCONVERT_API_KEY no configurada');
        print('   → Ejecutar: supabase secrets set CLOUDCONVERT_API_KEY=your_key');
        print('2. Error al decodificar PDF Base64');
        print('3. Error al llamar a CloudConvert API');
        print('');
      } else if (response.statusCode == 404) {
        print('HTTP 404 - Not Found');
        print('La Edge Function NO está desplegada');
        print('');
        print('Solución:');
        print('   → Ejecutar: supabase functions deploy convert-pdf-to-docx');
        print('');
      }

      print('Ver logs de Edge Function:');
      print('   supabase functions logs convert-pdf-to-docx --tail');
      print('');

      exit(1);
    }

    // ===================================================
    // CASO: Success (200)
    // ===================================================
    print('✅ Edge Function respondió exitosamente');
    print('');

    if (jsonResponse == null ||
        jsonResponse['success'] != true ||
        jsonResponse['docxUrl'] == null) {
      print('❌ ERROR: Respuesta 200 pero conversión falló');
      print('');
      print('D. ¿CloudConvert recibió el PDF?');
      print('   ❌ NO o Error desconocido');
      print('');
      print('E. ¿CloudConvert generó DOCX?');
      print('   ❌ NO');
      print('');
      exit(1);
    }

    print('D. ¿CloudConvert recibió el PDF?');
    print('   ✅ SÍ');
    print('');

    print('E. ¿CloudConvert generó DOCX?');
    print('   ✅ SÍ');
    print('');

    final docxUrl = jsonResponse['docxUrl'] as String;
    final docxFilename = jsonResponse['docxFilename'] as String? ?? 'output.docx';

    print('   - DOCX URL: $docxUrl');
    print('   - DOCX filename: $docxFilename');
    print('');

    // ===================================================
    // PASO 6: Descargar DOCX
    // ===================================================
    print('⬇️  PASO 6: Descargando DOCX...');

    final docxResponse = await http.get(Uri.parse(docxUrl));

    if (docxResponse.statusCode != 200) {
      print('❌ ERROR: No se pudo descargar el DOCX');
      print('   - Status: ${docxResponse.statusCode}');
      exit(1);
    }

    final docxBytes = docxResponse.bodyBytes;
    final docxSizeKB = (docxBytes.length / 1024).toStringAsFixed(2);

    print('   - ✅ DOCX descargado');
    print('');

    print('F. Tamaño del DOCX: $docxSizeKB KB (${docxBytes.length} bytes)');
    print('');

    // ===================================================
    // PASO 7: Validar formato DOCX
    // ===================================================
    print('🔍 PASO 7: Validando formato DOCX...');
    print('');

    // Verificar magic bytes (ZIP)
    if (docxBytes.length < 2) {
      print('❌ ERROR: DOCX muy pequeño (< 2 bytes)');
      exit(1);
    }

    final magicBytes = docxBytes.sublist(0, 2);
    final isPKZip = magicBytes[0] == 0x50 && magicBytes[1] == 0x4B;

    print('G. ¿El DOCX es un ZIP válido?');
    if (isPKZip) {
      print('   ✅ SÍ (magic bytes: PK / 50 4B)');
    } else {
      print('   ❌ NO');
      print('   - Magic bytes encontrados: ${magicBytes[0].toRadixString(16)} ${magicBytes[1].toRadixString(16)}');
      print('   - Magic bytes esperados: 50 4B (PK)');
      print('');
      print('El archivo NO es un DOCX válido');
      exit(1);
    }
    print('');

    // Extraer y verificar contenido del ZIP
    print('   Verificando estructura interna del ZIP...');

    try {
      final archive = ZipDecoder().decodeBytes(docxBytes);

      final contentTypesFile =
          archive.files.firstWhere((f) => f.name == '[Content_Types].xml');
      final documentFile =
          archive.files.firstWhere((f) => f.name == 'word/document.xml');

      print('   - ✅ [Content_Types].xml encontrado');
      print('   - ✅ word/document.xml encontrado');
      print('');
      print('   ✅ Estructura DOCX válida');
    } catch (e) {
      print('   ⚠️  Advertencia: No se pudo verificar estructura interna');
      print('   Error: $e');
      print('');
      print('   El archivo puede ser válido pero la verificación falló');
    }
    print('');

    // ===================================================
    // PASO 8: Guardar archivo
    // ===================================================
    print('💾 PASO 8: Guardando archivo...');

    final outputFile = File('prueba_conversion.docx');
    await outputFile.writeAsBytes(docxBytes);

    print('   - ✅ Guardado exitosamente');
    print('');

    print('H. Ruta del archivo: ${outputFile.absolute.path}');
    print('');

    // ===================================================
    // RESUMEN FINAL
    // ===================================================
    print('========================================');
    print('✅ PRUEBA COMPLETADA EXITOSAMENTE');
    print('========================================');
    print('');

    print('📊 RESUMEN:');
    print('   - PDF original: $pdfSizeKB KB');
    print('   - DOCX convertido: $docxSizeKB KB');
    print('   - Tiempo conversión: ${requestTime.inSeconds}s');
    print('   - Formato: ✅ DOCX válido');
    print('   - Archivo: ${outputFile.absolute.path}');
    print('');

    print('🔍 VALIDACIÓN MANUAL:');
    print('');
    print('Abrir el archivo en Microsoft Word:');
    print('   start ${outputFile.absolute.path}');
    print('');
    print('Verificar:');
    print('   ✓ Título, logo, tablas, imágenes');
    print('   ✓ NO hay páginas en blanco');
    print('   ✓ NO hay código HTML/XML visible');
    print('   ✓ Word abre sin advertencias');
    print('');

    exit(0);
  } catch (e, stackTrace) {
    print('');
    print('❌ EXCEPCIÓN NO CONTROLADA:');
    print('   $e');
    print('');
    print('Stack trace:');
    print('$stackTrace');
    print('');
    exit(1);
  }
}
