// FASE 2: Generar DOCX con UNA imagen real incrustada
// Este script crea manualmente la estructura ZIP de un DOCX válido

import 'dart:io';
import 'package:archive/archive.dart';

void main() async {
  print('=== FASE 2: Generación de DOCX con imagen incrustada ===\n');

  // 1. Leer la imagen real desde assets
  final imageFile = File('assets/logo_2026.png');
  if (!await imageFile.exists()) {
    print('ERROR: No se encuentra assets/logo_2026.png');
    exit(1);
  }

  final imageBytes = await imageFile.readAsBytes();
  print('✓ Imagen cargada: ${imageBytes.length} bytes');

  // 2. Crear el archivo ZIP (DOCX)
  final archive = Archive();

  // 3. Agregar [Content_Types].xml
  final contentTypes = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Default Extension="jpeg" ContentType="image/jpeg"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>''';
  archive.addFile(ArchiveFile('[Content_Types].xml', contentTypes.length, contentTypes.codeUnits));

  // 4. Agregar _rels/.rels
  final mainRels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';
  archive.addFile(ArchiveFile('_rels/.rels', mainRels.length, mainRels.codeUnits));

  // 5. Agregar word/_rels/document.xml.rels con la relación de la imagen
  final docRels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image1.png"/>
</Relationships>''';
  archive.addFile(ArchiveFile('word/_rels/document.xml.rels', docRels.length, docRels.codeUnits));

  // 6. Calcular dimensiones en EMU (English Metric Units)
  // 1 inch = 914400 EMU
  // Ancho disponible en A4 con márgenes: ~16.5 cm = ~6.5 inches
  const maxWidthInches = 6.0; // Ancho seguro dentro de márgenes
  const emuPerInch = 914400;
  
  // Asumimos que la imagen es ~200x200 px, ajustamos proporcionalmente
  // Para este ejemplo, usaremos dimensiones fijas proporcionales
  final widthEmu = (4.0 * emuPerInch).toInt(); // 4 inches de ancho
  final heightEmu = (widthEmu * 0.75).toInt(); // Proporción 4:3

  print('Dimensiones EMU: $widthEmu x $heightEmu');

  // 7. Agregar word/document.xml con contenido de Fase 1 + DrawingML para la imagen
  final documentXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document 
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
  
  <w:body>
    <!-- Título centrado (contenido Fase 1) -->
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:before="240" w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="32"/>
          <w:color w:val="2E7D32"/>
        </w:rPr>
        <w:t>FICHA DE INSPECCIÓN TÉCNICA</w:t>
      </w:r>
    </w:p>

    <!-- Subtítulo (contenido Fase 1) -->
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:after="360"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:sz w:val="24"/>
          <w:color w:val="555555"/>
        </w:rPr>
        <w:t>Área Verde Municipal</w:t>
      </w:r>
    </w:p>

    <!-- Información básica (contenido Fase 1) -->
    <w:p>
      <w:pPr>
        <w:spacing w:before="120" w:after="120"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
        </w:rPr>
        <w:t>Plaza ID: </w:t>
      </w:r>
      <w:r>
        <w:t>PLAZA_001</w:t>
      </w:r>
    </w:p>

    <w:p>
      <w:pPr>
        <w:spacing w:before="120" w:after="120"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
        </w:rPr>
        <w:t>Nombre: </w:t>
      </w:r>
      <w:r>
        <w:t>Plaza Principal</w:t>
      </w:r>
    </w:p>

    <w:p>
      <w:pPr>
        <w:spacing w:before="120" w:after="480"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
        </w:rPr>
        <w:t>Fecha: </w:t>
      </w:r>
      <w:r>
        <w:t>26/08/2026 14:30:00</w:t>
      </w:r>
    </w:p>

    <!-- IMAGEN INCRUSTADA con DrawingML -->
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:before="240" w:after="240"/>
      </w:pPr>
      <w:r>
        <w:drawing>
          <wp:inline distT="0" distB="0" distL="0" distR="0">
            <wp:extent cx="$widthEmu" cy="$heightEmu"/>
            <wp:effectExtent l="0" t="0" r="0" b="0"/>
            <wp:docPr id="1" name="Imagen 1" descr="Logo Municipalidad"/>
            <wp:cNvGraphicFramePr>
              <a:graphicFrameLocks xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" noChangeAspect="1"/>
            </wp:cNvGraphicFramePr>
            <a:graphic xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main">
              <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                <pic:pic xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
                  <pic:nvPicPr>
                    <pic:cNvPr id="1" name="image1.png"/>
                    <pic:cNvPicPr/>
                  </pic:nvPicPr>
                  <pic:blipFill>
                    <a:blip r:embed="rId1"/>
                    <a:stretch>
                      <a:fillRect/>
                    </a:stretch>
                  </pic:blipFill>
                  <pic:spPr>
                    <a:xfrm>
                      <a:off x="0" y="0"/>
                      <a:ext cx="$widthEmu" cy="$heightEmu"/>
                    </a:xfrm>
                    <a:prstGeom prst="rect">
                      <a:avLst/>
                    </a:prstGeom>
                  </pic:spPr>
                </pic:pic>
              </a:graphicData>
            </a:graphic>
          </wp:inline>
        </w:drawing>
      </w:r>
    </w:p>

    <!-- Texto después de la imagen -->
    <w:p>
      <w:pPr>
        <w:spacing w:before="360" w:after="120"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="24"/>
        </w:rPr>
        <w:t>Estado General: BUENO</w:t>
      </w:r>
    </w:p>

    <!-- Configuración de sección con márgenes A4 -->
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
      <w:cols w:space="720"/>
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
  </w:body>
</w:document>''';

  archive.addFile(ArchiveFile('word/document.xml', documentXml.length, documentXml.codeUnits));

  // 8. Agregar la imagen física en word/media/image1.png
  archive.addFile(ArchiveFile.noCompress('word/media/image1.png', imageBytes.length, imageBytes));
  print('✓ Imagen agregada a word/media/image1.png');

  // 9. Codificar el archivo ZIP
  final zipEncoder = ZipEncoder();
  final zipBytes = zipEncoder.encode(archive);

  if (zipBytes == null) {
    print('ERROR: No se pudo codificar el archivo ZIP');
    exit(1);
  }

  // 10. Guardar el archivo DOCX
  final outputFile = File('docx_prueba_fase2.docx');
  await outputFile.writeAsBytes(zipBytes);

  final fileSize = (zipBytes.length / 1024).toStringAsFixed(2);
  print('✓ Archivo generado: ${outputFile.path}');
  print('✓ Tamaño: $fileSize KB');

  // 11. Resumen
  print('\n=== RESUMEN DE FASE 2 ===');
  print('Archivos modificados: test_docx_fase2.dart (nuevo)');
  print('Imagen insertada: assets/logo_2026.png');
  print('rId utilizado: rId1');
  print('Ubicación imagen: word/media/image1.png');
  print('Dimensiones EMU: $widthEmu x $heightEmu (${widthEmu ~/ emuPerInch}"x${heightEmu ~/ emuPerInch}")');
  print('Tamaño imagen: ${(imageBytes.length / 1024).toStringAsFixed(2)} KB');
  print('Tamaño DOCX: $fileSize KB');
  print('\nEstructura del DOCX:');
  print('  ✓ [Content_Types].xml');
  print('  ✓ _rels/.rels');
  print('  ✓ word/document.xml');
  print('  ✓ word/_rels/document.xml.rels (con rId1 → media/image1.png)');
  print('  ✓ word/media/image1.png (imagen física incrustada)');
  print('\nPRUEBA EN MICROSOFT WORD:');
  print('Abrir: docx_prueba_fase2.docx');
  print('Verificar:');
  print('  □ Abre sin advertencias');
  print('  □ No solicita reparación');
  print('  □ Aparece la imagen centrada');
  print('  □ Imagen mantiene proporción');
  print('  □ Texto de Fase 1 intacto');
  print('  □ Márgenes A4 correctos');
}
