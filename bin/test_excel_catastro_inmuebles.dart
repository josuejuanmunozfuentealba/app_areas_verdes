import 'dart:io';
import 'dart:typed_data';
import '../lib/services/catastro_inmuebles_excel_service.dart';

void main() async {
  print('🧪 PRUEBA: Excel Catastro de Inmuebles');
  print('========================================');
  print('');

  try {
    // Simular datos de prueba (ya que no tenemos Supabase aquí)
    final datosSimulados = [
      {
        'inspeccion_id': 'INSP_001',
        'plaza_id': '1',
        'nombre_plaza': 'Plaza de Armas Donihue',
        'inspector': 'Juan Pérez',
        'fecha': '14/10/2026 15:30',
        'estado_general': 'Regular',
        'comuna': 'Donihue',
        'direccion': 'Delfín Carvallo con Subteniente Valenzuela',
        'gps_lat': '-34.226023',
        'gps_lng': '-70.964876',
        'total_items_evaluados': 5,
        'items_faltantes_count': 2,
        'items_faltantes': 'Estado estructural juegos infantiles; Estado de pintura de juegos infantiles',
        'es_inspeccion_completa': 'NO',
        'excelentes': 1,
        'buenos': 2,
        'regulares': 2,
        'malos': 0,
        'items_evaluados_detalle': 'Estado estructural de bancas; Estado pintura bancas; Estado llaves de paso/arranque de agua; Estado estructural basureros; Estado pintura de basureros',
        'evaluaciones_completas': 'Estado estructural de bancas: Bueno | Estado pintura bancas: Regular | Estado llaves de paso/arranque de agua: Excelente | Estado estructural basureros: Bueno | Estado pintura de basureros: Regular',
      },
      {
        'inspeccion_id': 'INSP_002',
        'plaza_id': '2',
        'nombre_plaza': 'Portal Letras Turísticas',
        'inspector': 'María González',
        'fecha': '13/10/2026 10:15',
        'estado_general': 'Bueno',
        'comuna': 'Donihue',
        'direccion': 'Letras Turísticas Donihue en H-10 con H-286',
        'gps_lat': '-34.225574',
        'gps_lng': '-70.946515',
        'total_items_evaluados': 7,
        'items_faltantes_count': 0,
        'items_faltantes': '',
        'es_inspeccion_completa': 'SÍ',
        'excelentes': 3,
        'buenos': 4,
        'regulares': 0,
        'malos': 0,
        'items_evaluados_detalle': 'Estado estructural de bancas; Estado pintura bancas; Estado estructural juegos infantiles; Estado de pintura de juegos infantiles; Estado llaves de paso/arranque de agua; Estado estructural basureros; Estado pintura de basureros',
        'evaluaciones_completas': 'Estado estructural de bancas: Excelente | Estado pintura bancas: Bueno | Estado estructural juegos infantiles: Excelente | Estado de pintura de juegos infantiles: Bueno | Estado llaves de paso/arranque de agua: Excelente | Estado estructural basureros: Bueno | Estado pintura de basureros: Bueno',
      }
    ];

    print('📊 Generando CSV de prueba...');
    final csvContent = CatastroInmueblesExcelService.generarCSVCatastroInmuebles(datosSimulados);

    print('✅ CSV generado exitosamente');
    print('📏 Tamaño: ${csvContent.length} caracteres');
    print('');

    // Guardar en archivo de prueba
    final file = File('test_catastro_inmuebles.csv');
    await file.writeAsString(csvContent);

    print('💾 Archivo guardado: ${file.absolute.path}');
    print('');

    // Mostrar las primeras líneas
    final lines = csvContent.split('\n');
    print('📋 CONTENIDO GENERADO (primeras 5 líneas):');
    for (int i = 0; i < (lines.length > 5 ? 5 : lines.length); i++) {
      print('${i + 1}: ${lines[i]}');
    }
    print('...');
    print('');

    // Verificar estructura
    print('🔍 VERIFICACIÓN:');
    print('• Total filas: ${lines.length - 1} (sin encabezado)');
    print('• Encabezados: ${lines[0].split(';').length} columnas');
    print('• Primer registro: ${lines[1].split(';').length} columnas');
    print('');

    // Generar resumen estadístico
    final datosReporte = {
      'total_inspecciones': datosSimulados.length,
      'inspecciones_completas': datosSimulados.where((d) => d['es_inspeccion_completa'] == 'SÍ').length,
      'inspecciones_incompletas': datosSimulados.where((d) => d['es_inspeccion_completa'] == 'NO').length,
      'item_mas_evaluado': 'Estado estructural de bancas',
    };

    final resumen = CatastroInmueblesExcelService.generarResumenEstadisticas(datosReporte);
    print('📈 RESUMEN ESTADÍSTICO:');
    print(resumen);

    print('========================================');
    print('✅ PRUEBA COMPLETADA EXITOSAMENTE');
    print('');
    print('📝 PRÓXIMOS PASOS:');
    print('1. Abrir archivo: test_catastro_inmuebles.csv');
    print('2. Verificar formato en Excel/LibreOffice');
    print('3. Probar desde la app móvil');

  } catch (e, stackTrace) {
    print('❌ ERROR EN LA PRUEBA:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }
}