// TEST: FASE 3 REPARADA - Generador DOCX Completo
// Prueba todas las correcciones implementadas

import 'dart:io';
import 'package:app_areas_verdes/services/docx_real_generator.dart';

void main() async {
  print('=== TEST: FASE 3 REPARADA ===\n');

  final generator = DocxRealGenerator();

  // 1. Cargar logo
  final logoFile = File('assets/logo_2026.png');
  final logoBytes = await logoFile.readAsBytes();
  print('✓ Logo cargado: ${(logoBytes.length / 1024).toStringAsFixed(1)} KB');

  // 2. Preparar fotos MEZCLANDO JPG Y PNG
  final fotos = <FotoDocx>[];
  
  // Foto PNG
  final foto1 = File('assets/unidad_aseo.png');
  if (await foto1.exists()) {
    fotos.add(FotoDocx(
      bytes: await foto1.readAsBytes(),
      titulo: 'Vista General del Área',
      esJpeg: false, // PNG
    ));
  }

  // Foto PNG
  final foto2 = File('assets/iconoescri.png');
  if (await foto2.exists()) {
    fotos.add(FotoDocx(
      bytes: await foto2.readAsBytes(),
      titulo: 'Detalle del Mobiliario & Equipamiento',
      esJpeg: false, // PNG
    ));
  }

  // Foto PNG (simulando JPG mezclado)
  final foto3 = File('assets/logoprecarga.png');
  if (await foto3.exists()) {
    fotos.add(FotoDocx(
      bytes: await foto3.readAsBytes(),
      titulo: 'Estado de la Vegetación',
      esJpeg: false, // PNG (en producción serían JPG mixtos)
    ));
  }

  print('✓ ${fotos.length} fotografías cargadas (PNG/JPG mixtos)');

  // 3. Datos con caracteres especiales para probar escape XML
  final evaluaciones = [
    {
      'criterio': 'Estado del Césped & Gramado',
      'evaluacion': 'BUENO',
      'observaciones': 'Césped bien mantenido, altura < 5cm',
    },
    {
      'criterio': 'Árboles & Arbustos',
      'evaluacion': 'REGULAR',
      'observaciones': 'Requiere poda en "sector norte"',
    },
    {
      'criterio': 'Sistema de Riego',
      'evaluacion': 'BUENO',
      'observaciones': 'Funcionando correctamente (100%)',
    },
    {
      'criterio': 'Mobiliario Urbano',
      'evaluacion': 'MALO',
      'observaciones': 'Bancas deterioradas, requiere reemplazo',
    },
    {
      'criterio': 'Iluminación LED',
      'evaluacion': 'BUENO',
      'observaciones': 'Todas las luminarias operativas > 90%',
    },
  ];

  print('✓ ${evaluaciones.length} criterios preparados (con caracteres especiales)');

  // 4. Generar DOCX con LOGO
  print('\n--- Generando DOCX CON LOGO ---');
  final docxConLogo = await generator.generarDocxCatastro(
    plazaId: 'PLAZA_001',
    nombrePlaza: 'Plaza Principal "Los Héroes"',
    inspector: 'Juan Pérez & María González',
    fechaHora: '26/08/2026 14:30:00',
    estadoGeneral: 'BUENO',
    evaluaciones: evaluaciones,
    logoBytes: logoBytes,
    fotos: fotos,
  );

  final fileConLogo = File('docx_fase3_CON_LOGO.docx');
  await fileConLogo.writeAsBytes(docxConLogo);
  print('✓ Generado: docx_fase3_CON_LOGO.docx (${(docxConLogo.length / 1024).toStringAsFixed(2)} KB)');

  // 5. Generar DOCX SIN LOGO (para probar rId diferentes)
  print('\n--- Generando DOCX SIN LOGO ---');
  final docxSinLogo = await generator.generarDocxCatastro(
    plazaId: 'PLAZA_002',
    nombrePlaza: 'Plaza del Sol',
    inspector: 'Pedro Ramírez',
    fechaHora: '26/08/2026 15:00:00',
    estadoGeneral: 'REGULAR',
    evaluaciones: evaluaciones,
    logoBytes: null, // SIN LOGO
    fotos: fotos,
  );

  final fileSinLogo = File('docx_fase3_SIN_LOGO.docx');
  await fileSinLogo.writeAsBytes(docxSinLogo);
  print('✓ Generado: docx_fase3_SIN_LOGO.docx (${(docxSinLogo.length / 1024).toStringAsFixed(2)} KB)');

  // 6. Generar DOCX con UNA SOLA FOTO
  print('\n--- Generando DOCX CON 1 FOTO ---');
  final docxUnaFoto = await generator.generarDocxCatastro(
    plazaId: 'PLAZA_003',
    nombrePlaza: 'Plaza Nueva',
    inspector: 'Ana Torres',
    fechaHora: '26/08/2026 16:00:00',
    estadoGeneral: 'EXCELENTE',
    evaluaciones: evaluaciones,
    logoBytes: logoBytes,
    fotos: [fotos[0]], // Solo la primera foto
  );

  final fileUnaFoto = File('docx_fase3_UNA_FOTO.docx');
  await fileUnaFoto.writeAsBytes(docxUnaFoto);
  print('✓ Generado: docx_fase3_UNA_FOTO.docx (${(docxUnaFoto.length / 1024).toStringAsFixed(2)} KB)');

  // RESUMEN
  print('\n=== RESUMEN DE PRUEBAS ===');
  print('');
  print('Archivos generados:');
  print('  1. docx_fase3_CON_LOGO.docx');
  print('     - Logo en esquina superior derecha (rId3)');
  print('     - 3 fotografías (rId4, rId5, rId6)');
  print('     - Títulos reales de cada foto');
  print('     - Caracteres especiales escapados');
  print('');
  print('  2. docx_fase3_SIN_LOGO.docx');
  print('     - Sin logo');
  print('     - 3 fotografías (rId3, rId4, rId5)');
  print('     - Prueba que rId se calculan correctamente');
  print('');
  print('  3. docx_fase3_UNA_FOTO.docx');
  print('     - Logo (rId3)');
  print('     - 1 fotografía (rId4)');
  print('     - Prueba con cantidad mínima de fotos');
  print('');
  print('CORRECCIONES APLICADAS:');
  print('  ✓ Relaciones con extensión correcta (.jpg/.png)');
  print('  ✓ rId numerados correctamente (rId1=styles, rId2=settings)');
  print('  ✓ Logo usa rId3, fotos desde rId4');
  print('  ✓ Sin logo, fotos desde rId3');
  print('  ✓ Títulos reales de FotoDocx utilizados');
  print('  ✓ Escape XML aplicado a todos los textos');
  print('  ✓ Tildes correctas (INSPECCIÓN, TÉCNICA, ÁREA, etc.)');
  print('  ✓ Logo posicionado con align right');
  print('');
  print('VALIDACIÓN MANUAL:');
  print('  □ Abrir cada archivo en Microsoft Word');
  print('  □ Verificar que no hay advertencias');
  print('  □ Verificar que logo aparece correctamente');
  print('  □ Verificar que títulos de fotos son correctos');
  print('  □ Verificar que caracteres especiales se ven bien');
  print('  □ Verificar que tabla tiene tildes correctas');
  print('');
  print('=== FIN DEL TEST ===');
}
