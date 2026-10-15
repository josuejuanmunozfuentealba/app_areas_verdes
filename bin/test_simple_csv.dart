import 'dart:io';

// Función simple para generar CSV sin dependencias de Flutter
String generarCSVSimple() {
  final buffer = StringBuffer();

  // BOM UTF-8 para acentos correctos en Excel
  buffer.write('\uFEFF');

  // Encabezados
  buffer.writeln([
    'ID Inspección',
    'ID Plaza',  
    'Nombre Plaza',
    'Inspector',
    'Fecha Inspección',
    'Estado General',
    'Comuna',
    'Dirección',
    'GPS Latitud',
    'GPS Longitud',
    'Total Ítems Evaluados',
    'Ítems Faltantes (Cantidad)',
    'Inspección Completa (7/7)',
    'Estados: Excelente',
    'Estados: Bueno', 
    'Estados: Regular',
    'Estados: Malo',
    'Ítems Evaluados',
    'Ítems Faltantes (Detalle)',
    'Evaluaciones Completas',
  ].join(';'));

  // Datos de prueba
  final datos = [
    [
      'INSP_001',
      '1',
      'Plaza de Armas Donihue',
      'Juan Pérez',
      '14/10/2026 15:30',
      'Regular',
      'Donihue',
      'Delfín Carvallo con Subteniente Valenzuela',
      '-34.226023',
      '-70.964876',
      '5',
      '2',
      'NO',
      '1',
      '2', 
      '2',
      '0',
      'Estado estructural de bancas; Estado pintura bancas; Estado llaves de paso/arranque de agua; Estado estructural basureros; Estado pintura de basureros',
      'Estado estructural juegos infantiles; Estado de pintura de juegos infantiles',
      'Estado estructural de bancas: Bueno | Estado pintura bancas: Regular | Estado llaves de paso/arranque de agua: Excelente | Estado estructural basureros: Bueno | Estado pintura de basureros: Regular',
    ],
    [
      'INSP_002',
      '2',
      'Portal Letras Turísticas',
      'María González', 
      '13/10/2026 10:15',
      'Bueno',
      'Donihue',
      'Letras Turísticas Donihue en H-10 con H-286',
      '-34.225574',
      '-70.946515',
      '7',
      '0',
      'SÍ',
      '3',
      '4',
      '0', 
      '0',
      'Estado estructural de bancas; Estado pintura bancas; Estado estructural juegos infantiles; Estado de pintura de juegos infantiles; Estado llaves de paso/arranque de agua; Estado estructural basureros; Estado pintura de basureros',
      '',
      'Estado estructural de bancas: Excelente | Estado pintura bancas: Bueno | Estado estructural juegos infantiles: Excelente | Estado de pintura de juegos infantiles: Bueno | Estado llaves de paso/arranque de agua: Excelente | Estado estructural basureros: Bueno | Estado pintura de basureros: Bueno',
    ]
  ];

  for (var fila in datos) {
    buffer.writeln(fila.join(';'));
  }

  return buffer.toString();
}

void main() async {
  print('🧪 PRUEBA SIMPLE: CSV Catastro de Inmuebles');
  print('=========================================');
  print('');

  try {
    final csvContent = generarCSVSimple();
    
    print('✅ CSV generado exitosamente');
    print('📏 Tamaño: ${csvContent.length} caracteres');
    print('');

    // Guardar archivo
    final file = File('test_catastro_inmuebles_simple.csv');
    await file.writeAsString(csvContent);

    print('💾 Archivo guardado: ${file.absolute.path}');
    print('');

    // Mostrar las primeras líneas
    final lines = csvContent.split('\n');
    print('📋 CONTENIDO GENERADO:');
    print('');
    for (int i = 0; i < lines.length && i < 5; i++) {
      if (lines[i].isNotEmpty) {
        print('Línea ${i + 1}: ${lines[i]}');
        print('');
      }
    }

    print('🔍 VERIFICACIÓN:');
    print('• Total filas de datos: ${lines.length - 2} (sin encabezado y línea vacía)');
    print('• Columnas esperadas: 20');
    print('• Columnas en encabezado: ${lines[0].split(';').length}');
    print('• Columnas en primera fila: ${lines[1].split(';').length}');
    print('');

    print('✅ PRUEBA COMPLETADA');
    print('');
    print('📝 PRÓXIMOS PASOS:');
    print('1. Abrir: test_catastro_inmuebles_simple.csv');
    print('2. Verificar que se abra correctamente en Excel');
    print('3. Comprobar que los acentos se muestren bien');

  } catch (e) {
    print('❌ ERROR: $e');
  }
}