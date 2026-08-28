// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

// Importar el servicio real
import 'package:app_areas_verdes/services/catastro_export_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  print('========================================');
  print('PRUEBA REAL: _descargarWord()');
  print('Simulando flujo exacto de la app');
  print('========================================\n');

  final exportService = CatastroExportService();

  try {
    // Datos de prueba (mismos que en la app)
    final plazaId = 'PL001';
    final nombrePlaza = 'Plaza de Armas';
    final inspector = 'Juan Pérez';
    final fechaHora = DateTime.now();
    final evaluaciones = {
      'Estado estructural de bancas': 'Bueno',
      'Estado pintura bancas': 'Regular',
      'Estado estructural juegos infantiles': 'Bueno',
      'Estado de pintura de juegos infantiles': 'Malo',
      'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)':
          'Bueno',
      'Estado estructural basureros': 'Bueno',
      'Estado pintura de basureros': 'Regular',
    };
    final observaciones = {
      'Estado estructural de bancas': 'Sin observaciones',
      'Estado pintura bancas': 'Necesita repintado',
      'Estado estructural juegos infantiles': 'En buen estado',
      'Estado de pintura de juegos infantiles': 'Pintura deteriorada',
      'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)':
          'Funcionando correctamente',
      'Estado estructural basureros': 'Sin daños',
      'Estado pintura de basureros': 'Requiere mantenimiento',
    };

    print('📋 Llamando a exportService.generarWord()...');
    print('   (Este método debe redirigir a ConvertAPI)\n');

    final wordBytes = await exportService.generarWord(
      plazaId: plazaId,
      nombrePlaza: nombrePlaza,
      inspector: inspector,
      fechaHora: fechaHora,
      evaluaciones: evaluaciones,
      observaciones: observaciones,
      fotos: [], // Sin fotos para simplificar
    );

    print('\n✅ generarWord() retornó bytes');
    print('   Tamaño: ${(wordBytes.length / 1024).toStringAsFixed(2)} KB\n');

    // Guardar archivo
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nombreArchivo = 'test_descargar_word_$timestamp.docx';
    final file = File(nombreArchivo);
    await file.writeAsBytes(wordBytes);

    print('💾 Archivo guardado: $nombreArchivo');
    print('   Ruta completa: ${file.absolute.path}\n');

    // Verificar que es un DOCX válido
    final bytes = await file.readAsBytes();
    final isPK = bytes.length >= 2 && bytes[0] == 0x50 && bytes[1] == 0x4B;

    print('🔍 Verificación:');
    print('   Magic bytes (PK): ${isPK ? "✅" : "❌"}');

    if (isPK) {
      print('\n========================================');
      print('✅ PRUEBA EXITOSA');
      print('========================================');
      print('El flujo generarWord() → ConvertAPI funciona correctamente.');
      print('\n📝 Siguiente paso:');
      print('   Abrir archivo en Word: $nombreArchivo');
      print('   Verificar contenido visualmente.');
    } else {
      print('\n========================================');
      print('❌ PRUEBA FALLIDA');
      print('========================================');
      print('El archivo NO es un DOCX válido.');
      print('Posiblemente sigue usando base.docx.');
    }
  } catch (e, stackTrace) {
    print('\n========================================');
    print('❌ ERROR EN PRUEBA');
    print('========================================');
    print('Error: $e');
    print('\nStackTrace:');
    print(stackTrace);

    print('\n🔍 DIAGNÓSTICO:');
    if (e.toString().contains('Edge Function')) {
      print('   → Edge Function no desplegada o sin conectividad');
    } else if (e.toString().contains('base.docx')) {
      print('   → Código sigue cargando base.docx');
    } else {
      print('   → Error desconocido');
    }
  }
}
