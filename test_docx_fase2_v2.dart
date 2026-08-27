// FASE 2 v2: Generar DOCX con UNA imagen real incrustada (CORREGIDO)
// Corrección: manejo adecuado de encoding UTF-8

import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';

void main() async {
  print('=== FASE 2 v2: Generación de DOCX con imagen incrustada ===\n');

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

  // Helper para agregar archivos XML con UTF-8 correcto
  void addXmlFile(String path, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  // 3. Agregar [Content_Types].xml
  final contentTypes = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Default Extension="jpeg" ContentType="image/jpeg"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>''';
  addXmlFile('[Content_Types].xml', contentTypes);

  // 4. Agregar _rels/.rels
  final mainRels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';
  addXmlFile('_rels/.rels', mainRels);

  // 5. Agregar word/_rels/document.xml.rels con la relación de la imagen
  final docRels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image1.png"/>
</Relationships>''';
  addXmlFile('word/_rels/document.xml.rels', docRels);

  // 6. Calcular dimensiones en EMU
  const emuPerInch = 914400;
  final widthEmu = (4.0 * emuPerInch).toInt();
  final heightEmu = (widthEmu * 0.75).toInt();

  print('Dimensiones EMU: $widthEmu x $heightEmu');

  // 7. Agregar word/document.xml con contenido de Fase 1 + DrawingML
  final documentXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document 
  xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
  xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
  xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
  xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
  xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
  <w:body>
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
        <w:t>FICHA DE INSPECCION TECNICA</w:t>
      </w:r>
    </w:p>
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
        <w:t>Area Verde Municipal</w:t>
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
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
      <w:cols w:space="720"/>
      <w:docGrid w:linePitch="360"/>
    </w:sectPr>
  </w:body>
</w:document>''';

  addXmlFile('word/document.xml', documentXml);

  // 8. Agregar la imagen física
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

  print('\n=== REPORTE FASE 2 ===');
  print('1. Archivos modificados:');
  print('   - test_docx_fase2_v2.dart (script generador corregido)');
  print('   - docx_prueba_fase2.docx (archivo final)');
  print('');
  print('2. Como se inserto la imagen:');
  print('   - Imagen leida desde: assets/logo_2026.png');
  print('   - Agregada fisicamente en: word/media/image1.png');
  print('   - Usando DrawingML con wp:inline');
  print('   - Centrada mediante w:jc center');
  print('');
  print('3. rId utilizado: rId1');
  print('');
  print('4. Ubicacion de la imagen: word/media/image1.png');
  print('');
  print('5. Dimensiones EMU: $widthEmu x $heightEmu');
  print('   (${widthEmu ~/ emuPerInch} inches x ${heightEmu ~/ emuPerInch} inches)');
  print('');
  print('6. Tamaño imagen: ${(imageBytes.length / 1024).toStringAsFixed(2)} KB');
  print('');
  print('7. Tamaño final DOCX: $fileSize KB');
  print('');
  print('8. PRUEBA EN MICROSOFT WORD: Ejecutar ahora...');
}
