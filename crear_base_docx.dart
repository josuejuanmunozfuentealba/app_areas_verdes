// Script para crear base.docx válido para docx_template
// Ejecutar con: dart run crear_base_docx.dart

import 'dart:io';
import 'package:archive/archive.dart';

void main() {
  print('=== CREANDO BASE.DOCX VÁLIDO ===\n');

  // Crear estructura ZIP del DOCX
  final archive = Archive();

  // 1. [Content_Types].xml
  final contentTypes = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="jpeg" ContentType="image/jpeg"/>
  <Default Extension="jpg" ContentType="image/jpeg"/>
  <Default Extension="png" ContentType="image/png"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>
</Types>''';
  archive.addFile(ArchiveFile('[Content_Types].xml', contentTypes.length, contentTypes.codeUnits));

  // 2. _rels/.rels
  final rels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';
  archive.addFile(ArchiveFile('_rels/.rels', rels.length, rels.codeUnits));

  // 3. word/_rels/document.xml.rels
  final docRels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>
</Relationships>''';
  archive.addFile(ArchiveFile('word/_rels/document.xml.rels', docRels.length, docRels.codeUnits));

  // 4. word/document.xml con placeholders
  final document = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
            xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml"
            xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing">
  <w:body>
    
    <!-- Logo (placeholder para docx_template) -->
    <w:p>
      <w:pPr>
        <w:jc w:val="right"/>
      </w:pPr>
      <w:r>
        <w:t>{%logo%}</w:t>
      </w:r>
    </w:p>
    
    <!-- Título -->
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="32"/>
          <w:color w:val="2E7D32"/>
        </w:rPr>
        <w:t>CATASTRO DE INMUEBLES DE ÁREAS VERDES</w:t>
      </w:r>
    </w:p>
    
    <!-- Municipalidad -->
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:sz w:val="20"/>
          <w:color w:val="666666"/>
        </w:rPr>
        <w:t>Municipalidad de Doñihue</w:t>
      </w:r>
    </w:p>
    
    <w:p/>
    
    <!-- Información General -->
    <w:p>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="24"/>
        </w:rPr>
        <w:t>INFORMACIÓN GENERAL</w:t>
      </w:r>
    </w:p>
    
    <!-- Tabla de información -->
    <w:tbl>
      <w:tblPr>
        <w:tblW w:w="5000" w:type="pct"/>
        <w:tblBorders>
          <w:top w:val="single" w:sz="4" w:color="CCCCCC"/>
          <w:left w:val="single" w:sz="4" w:color="CCCCCC"/>
          <w:bottom w:val="single" w:sz="4" w:color="CCCCCC"/>
          <w:right w:val="single" w:sz="4" w:color="CCCCCC"/>
          <w:insideH w:val="single" w:sz="4" w:color="CCCCCC"/>
          <w:insideV w:val="single" w:sz="4" w:color="CCCCCC"/>
        </w:tblBorders>
      </w:tblPr>
      
      <w:tr>
        <w:tc>
          <w:p>
            <w:r>
              <w:rPr><w:b/></w:rPr>
              <w:t>Plaza:</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:p>
            <w:r>
              <w:t>{nombre_plaza}</w:t>
            </w:r>
          </w:p>
        </w:tc>
      </w:tr>
      
      <w:tr>
        <w:tc>
          <w:p>
            <w:r>
              <w:rPr><w:b/></w:rPr>
              <w:t>ID:</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:p>
            <w:r>
              <w:t>{plaza_id}</w:t>
            </w:r>
          </w:p>
        </w:tc>
      </w:tr>
      
      <w:tr>
        <w:tc>
          <w:p>
            <w:r>
              <w:rPr><w:b/></w:rPr>
              <w:t>Inspector:</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:p>
            <w:r>
              <w:t>{inspector}</w:t>
            </w:r>
          </w:p>
        </w:tc>
      </w:tr>
      
      <w:tr>
        <w:tc>
          <w:p>
            <w:r>
              <w:rPr><w:b/></w:rPr>
              <w:t>Fecha/Hora:</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:p>
            <w:r>
              <w:t>{fecha_hora}</w:t>
            </w:r>
          </w:p>
        </w:tc>
      </w:tr>
      
      <w:tr>
        <w:tc>
          <w:p>
            <w:r>
              <w:rPr><w:b/></w:rPr>
              <w:t>Estado General:</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:p>
            <w:r>
              <w:t>{estado_general}</w:t>
            </w:r>
          </w:p>
        </w:tc>
      </w:tr>
    </w:tbl>
    
    <w:p/>
    
    <!-- Evaluaciones -->
    <w:p>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="24"/>
        </w:rPr>
        <w:t>EVALUACIÓN DE CRITERIOS</w:t>
      </w:r>
    </w:p>
    
    <!-- Tabla de evaluaciones (loop) -->
    {#evaluaciones}
    <w:tbl>
      <w:tblPr>
        <w:tblW w:w="5000" w:type="pct"/>
        <w:tblBorders>
          <w:top w:val="single" w:sz="4" w:color="CCCCCC"/>
          <w:left w:val="single" w:sz="4" w:color="CCCCCC"/>
          <w:bottom w:val="single" w:sz="4" w:color="CCCCCC"/>
          <w:right w:val="single" w:sz="4" w:color="CCCCCC"/>
          <w:insideH w:val="single" w:sz="4" w:color="CCCCCC"/>
          <w:insideV w:val="single" w:sz="4" w:color="CCCCCC"/>
        </w:tblBorders>
      </w:tblPr>
      <w:tr>
        <w:tc>
          <w:p>
            <w:r>
              <w:t>{criterio}</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:p>
            <w:r>
              <w:t>{evaluacion}</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:p>
            <w:r>
              <w:t>{observaciones}</w:t>
            </w:r>
          </w:p>
        </w:tc>
      </w:tr>
    </w:tbl>
    {/evaluaciones}
    
    <w:p/>
    
    <!-- Anexo Fotográfico -->
    <w:p>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="24"/>
        </w:rPr>
        <w:t>ANEXO FOTOGRÁFICO</w:t>
      </w:r>
    </w:p>
    
    <!-- Fotos (loop) -->
    {#fotos}
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
        </w:rPr>
        <w:t>{numero}</w:t>
      </w:r>
    </w:p>
    
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
      </w:pPr>
      <w:r>
        <w:t>{%imagen%}</w:t>
      </w:r>
    </w:p>
    
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
      </w:pPr>
      <w:r>
        <w:t>Nota: {nota}</w:t>
      </w:r>
    </w:p>
    
    <w:p/>
    {/fotos}
    
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/>
    </w:sectPr>
  </w:body>
</w:document>''';
  archive.addFile(ArchiveFile('word/document.xml', document.length, document.codeUnits));

  // 5. word/styles.xml
  final styles = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>
        <w:sz w:val="22"/>
      </w:rPr>
    </w:rPrDefault>
  </w:docDefaults>
</w:styles>''';
  archive.addFile(ArchiveFile('word/styles.xml', styles.length, styles.codeUnits));

  // 6. word/settings.xml
  final settings = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>''';
  archive.addFile(ArchiveFile('word/settings.xml', settings.length, settings.codeUnits));

  // Codificar a ZIP
  final zipData = ZipEncoder().encode(archive);
  
  // Guardar
  final file = File('assets/base.docx');
  file.writeAsBytesSync(zipData!);
  
  print('✅ base.docx creado exitosamente en: ${file.absolute.path}');
  print('   Tamaño: ${(zipData.length / 1024).toStringAsFixed(1)} KB');
  print('\nPlaceholders incluidos:');
  print('  - {nombre_plaza}');
  print('  - {plaza_id}');
  print('  - {inspector}');
  print('  - {fecha_hora}');
  print('  - {estado_general}');
  print('  - {%logo%} (imagen)');
  print('  - {#evaluaciones}...{/evaluaciones} (loop)');
  print('  - {#fotos}...{/fotos} (loop)');
  print('  - {%imagen%} (imagen en loop)');
}
