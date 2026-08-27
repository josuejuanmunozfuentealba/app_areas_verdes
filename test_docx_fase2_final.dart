// FASE 2 FINAL: Logo en esquina superior derecha
// Usando wp:anchor para posicionamiento absoluto

import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';

void main() async {
  print('=== FASE 2 FINAL: Logo en esquina superior derecha ===\n');

  // 1. Leer imagen
  final imageFile = File('assets/logo_2026.png');
  if (!await imageFile.exists()) {
    print('ERROR: No se encuentra assets/logo_2026.png');
    exit(1);
  }

  final imageBytes = await imageFile.readAsBytes();
  print('✓ Imagen cargada: ${imageBytes.length} bytes');

  // 2. Crear archivo ZIP
  final archive = Archive();

  void addXmlFile(String path, String content) {
    final bytes = utf8.encode(content);
    archive.addFile(ArchiveFile(path, bytes.length, bytes));
  }

  // 3. [Content_Types].xml
  addXmlFile('[Content_Types].xml', '''<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>''');

  // 4. _rels/.rels
  addXmlFile('_rels/.rels', '''<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''');

  // 5. word/_rels/document.xml.rels
  addXmlFile(
    'word/_rels/document.xml.rels',
    '''<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image1.png"/>
</Relationships>''',
  );

  // 6. Dimensiones logo (más pequeño para esquina - 1.5" x 1.125")
  const int widthEmu = 1371600; // 1.5 inches
  const int heightEmu = 1028700; // 1.125 inches

  // 7. word/document.xml con logo posicionado en esquina superior derecha
  addXmlFile('word/document.xml', '''<?xml version="1.0" encoding="UTF-8"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:wp14="http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
  <w:body>
    <w:p>
      <w:pPr>
        <w:spacing w:before="0" w:after="0"/>
      </w:pPr>
      <w:r>
        <w:drawing>
          <wp:anchor distT="0" distB="0" distL="114300" distR="114300" simplePos="0" relativeHeight="251658240" behindDoc="0" locked="0" layoutInCell="1" allowOverlap="1">
            <wp:simplePos x="0" y="0"/>
            <wp:positionH relativeFrom="page">
              <wp:align>right</wp:align>
            </wp:positionH>
            <wp:positionV relativeFrom="page">
              <wp:align>top</wp:align>
            </wp:positionV>
            <wp:extent cx="$widthEmu" cy="$heightEmu"/>
            <wp:effectExtent l="0" t="0" r="0" b="0"/>
            <wp:wrapNone/>
            <wp:docPr id="1" name="Logo"/>
            <wp:cNvGraphicFramePr>
              <a:graphicFrameLocks noChangeAspect="1"/>
            </wp:cNvGraphicFramePr>
            <a:graphic>
              <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                <pic:pic>
                  <pic:nvPicPr>
                    <pic:cNvPr id="0" name="image1.png"/>
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
          </wp:anchor>
        </w:drawing>
      </w:r>
    </w:p>
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
        <w:rPr><w:b/></w:rPr>
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
        <w:rPr><w:b/></w:rPr>
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
        <w:rPr><w:b/></w:rPr>
        <w:t>Fecha: </w:t>
      </w:r>
      <w:r>
        <w:t>26/08/2026 14:30:00</w:t>
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
    </w:sectPr>
  </w:body>
</w:document>''');

  // 8. Agregar imagen física
  archive.addFile(
    ArchiveFile.noCompress(
      'word/media/image1.png',
      imageBytes.length,
      imageBytes,
    ),
  );

  // 9. Codificar ZIP
  final zipEncoder = ZipEncoder();
  final zipBytes = zipEncoder.encode(archive);

  if (zipBytes == null) {
    print('ERROR: No se pudo codificar ZIP');
    exit(1);
  }

  // 10. Guardar archivo
  final outputFile = File('docx_prueba_fase2_final.docx');
  await outputFile.writeAsBytes(zipBytes);

  final fileSize = (zipBytes.length / 1024).toStringAsFixed(2);

  print('✓ Archivo generado: docx_prueba_fase2_final.docx');
  print('✓ Tamaño: $fileSize KB');
  print('✓ Logo posicionado: esquina superior derecha');
  print('✓ Dimensiones: 1.5" x 1.125"');
  print('\n=== ABRIENDO EN WORD ===');
}
