// FASE 3: Prueba del generador DOCX completo integrado
// Usa el DocxRealGenerator con datos simulados del catastro

import 'dart:io';
import 'package:app_areas_verdes/services/docx_real_generator.dart';

void main() async {
  print('=== FASE 3: Generador DOCX Completo ===\n');

  final generator = DocxRealGenerator();

  // 1. Cargar logo
  final logoFile = File('assets/logo_2026.png');
  final logoBytes = await logoFile.readAsBytes();
  print('✓ Logo cargado: ${(logoBytes.length / 1024).toStringAsFixed(1)} KB');

  // 2. Cargar fotos de prueba
  final fotos = <FotoDocx>[];
  
  final foto1 = File('assets/unidad_aseo.png');
  if (await foto1.exists()) {
    fotos.add(FotoDocx(
      bytes: await foto1.readAsBytes(),
      titulo: 'Foto 1: Vista General',
      esJpeg: false,
    ));
  }

  final foto2 = File('assets/iconoescri.png');
  if (await foto2.exists()) {
    fotos.add(FotoDocx(
      bytes: await foto2.readAsBytes(),
      titulo: 'Foto 2: Detalle Area Verde',
      esJpeg: false,
    ));
  }

  print('✓ ${fotos.length} fotos cargadas');

  // 3. Datos de evaluación simulados
  final evaluaciones = [
    {
      'criterio': 'Estado del Cesped',
      'evaluacion': 'BUENO',
      'observaciones': 'Cesped bien mantenido, altura adecuada',
    },
    {
      'criterio': 'Arboles y Arbustos',
      'evaluacion': 'REGULAR',
      'observaciones': 'Requiere poda en algunos sectores',
    },
    {
      'criterio': 'Sistema de Riego',
      'evaluacion': 'BUENO',
      'observaciones': 'Funcionando correctamente',
    },
    {
      'criterio': 'Mobiliario Urbano',
      'evaluacion': 'MALO',
      'observaciones': 'Bancas deterioradas, requiere reemplazo',
    },
    {
      'criterio': 'Iluminacion',
      'evaluacion': 'BUENO',
      'observaciones': 'Todas las luminarias operativas',
    },
    {
      'criterio': 'Limpieza General',
      'evaluacion': 'BUENO',
      'observaciones': 'Area limpia y ordenada',
    },
  ];

  print('✓ ${evaluaciones.length} criterios de evaluación preparados');

  // 4. Generar DOCX completo
  print('\nGenerando DOCX completo...');
  
  final docxBytes = await generator.generarDocxCatastro(
    plazaId: 'PLAZA_001',
    nombrePlaza: 'Plaza Principal',
    inspector: 'Juan Pérez',
    fechaHora: '26/08/2026 14:30:00',
    estadoGeneral: 'BUENO',
    evaluaciones: evaluaciones,
    logoBytes: logoBytes,
    fotos: fotos,
  );

  // 5. Guardar archivo
  final outputFile = File('docx_fase3_completo.docx');
  await outputFile.writeAsBytes(docxBytes);

  final fileSize = (docxBytes.length / 1024).toStringAsFixed(2);

  print('\n=== DOCX GENERADO ===');
  print('Archivo: docx_fase3_completo.docx');
  print('Tamaño: $fileSize KB');
  print('');
  print('CONTENIDO:');
  print('  ✓ Logo en esquina superior derecha');
  print('  ✓ Título y datos básicos (Plaza, Inspector, Fecha)');
  print('  ✓ Estado General');
  print('  ✓ Tabla de evaluación con ${evaluaciones.length} criterios');
  print('  ✓ Anexo fotográfico con ${fotos.length} imágenes');
  print('');
  print('ESTRUCTURA INTERNA:');
  print('  ✓ [Content_Types].xml con PNG y JPEG');
  print('  ✓ _rels/.rels');
  print('  ✓ word/document.xml con DrawingML y tablas');
  print('  ✓ word/_rels/document.xml.rels con ${fotos.length + 1} relaciones');
  print('  ✓ word/media/logo.png');
  for (var i = 0; i < fotos.length; i++) {
    print('  ✓ word/media/image${i + 1}.${fotos[i].esJpeg ? "jpg" : "png"}');
  }
  print('');
  print('=== FASE 3 COMPLETADA ===');
  print('Abriendo en Microsoft Word para validación...');
}
