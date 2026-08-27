import 'dart:io';
import 'package:docx_template/docx_template.dart';

Future<void> main() async {
  print('🧪 PRUEBA: Generando DOCX con base02.docx');
  print('');

  try {
    // Cargar plantilla base02.docx
    final templateFile = File('assets/base02.docx');

    if (!templateFile.existsSync()) {
      print('❌ ERROR: assets/base02.docx no existe');
      print('   Ejecuta primero: dart run crear_base02_docx.dart');
      return;
    }

    final templateBytes = await templateFile.readAsBytes();
    final docx = await DocxTemplate.fromBytes(templateBytes);

    print('✅ Plantilla cargada: ${templateBytes.length} bytes');
    print('');

    // Datos de prueba
    final content = Content();

    // Información general
    content
      ..add(TextContent('plaza_id', 'PL-001'))
      ..add(TextContent('nombre_plaza', 'Plaza de Armas'))
      ..add(TextContent('inspector', 'Juan Pérez'))
      ..add(TextContent('fecha_hora', '26/08/2026 14:30'))
      ..add(TextContent('estado_general', 'BUENO'));

    // Logo (placeholder - en producción sería imagen real)
    content.add(TextContent('logo', '[LOGO]'));

    // Evaluaciones (3 filas de prueba)
    content.add(
      TableContent('evaluaciones', [
        RowContent()
          ..add(TextContent('criterio', 'Limpieza'))
          ..add(TextContent('evaluacion', 'BUENO'))
          ..add(TextContent('observaciones', 'Área bien mantenida')),
        RowContent()
          ..add(TextContent('criterio', 'Infraestructura'))
          ..add(TextContent('evaluacion', 'REGULAR'))
          ..add(TextContent('observaciones', 'Requiere reparación de bancas')),
        RowContent()
          ..add(TextContent('criterio', 'Vegetación'))
          ..add(TextContent('evaluacion', 'BUENO'))
          ..add(TextContent('observaciones', 'Árboles saludables')),
        RowContent()
          ..add(TextContent('criterio', 'Iluminación'))
          ..add(TextContent('evaluacion', 'MALO'))
          ..add(
            TextContent('observaciones', 'Varias luminarias sin funcionar'),
          ),
        RowContent()
          ..add(TextContent('criterio', 'Accesibilidad'))
          ..add(TextContent('evaluacion', 'BUENO'))
          ..add(TextContent('observaciones', 'Rampas en buen estado')),
      ]),
    );

    // Fotos (2 fotos de prueba sin imágenes reales)
    content.add(
      TableContent('fotos', [
        RowContent()
          ..add(TextContent('numero', 'Foto 1: Vista General'))
          ..add(TextContent('imagen', '[IMAGEN 1]'))
          ..add(TextContent('nota', 'Vista frontal de la plaza')),
        RowContent()
          ..add(TextContent('numero', 'Foto 2: Área de Juegos'))
          ..add(TextContent('imagen', '[IMAGEN 2]'))
          ..add(TextContent('nota', 'Juegos infantiles en buen estado')),
      ]),
    );

    print('📋 Datos de prueba agregados:');
    print('   - Información general: 5 campos');
    print('   - Evaluaciones: 5 criterios');
    print('   - Fotografías: 2 fotos (sin imágenes)');
    print('');

    // Generar documento
    print('⚙️  Generando documento...');
    final generatedBytes = await docx.generate(content);

    if (generatedBytes == null) {
      print('❌ ERROR: No se pudo generar el documento');
      return;
    }

    // Guardar archivo
    final outputFile = File('test_output_base02.docx');
    await outputFile.writeAsBytes(generatedBytes);

    print('✅ Documento generado exitosamente');
    print('📄 Archivo: ${outputFile.path}');
    print('📊 Tamaño: ${generatedBytes.length} bytes');
    print('');
    print('🔍 VERIFICAR EN WORD:');
    print('   1. Abrir test_output_base02.docx');
    print(
      '   2. Verificar que la tabla de evaluaciones sea UNA sola tabla con 5 filas',
    );
    print('   3. Verificar que NO haya páginas en blanco');
    print('   4. Verificar que el espaciado sea uniforme');
    print(
      '   5. Verificar que el encabezado de la tabla tenga fondo verde claro',
    );
    print('');
    print('✅ COMPARACIÓN:');
    print(
      '   - base.docx (original): múltiples tablas separadas → páginas en blanco',
    );
    print(
      '   - base02.docx (mejorado): UNA tabla con filas → sin páginas en blanco',
    );
    print('');
  } catch (e, stackTrace) {
    print('❌ ERROR: $e');
    print('Stack trace:');
    print(stackTrace);
  }
}
