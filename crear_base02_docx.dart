import 'dart:io';
import 'package:archive/archive.dart';

void main() {
  print('🔧 Generando base02.docx mejorado...');

  // Crear el documento XML con CORRECCIONES:
  // 1. Tabla única de evaluaciones (no múltiples tablas)
  // 2. Sin párrafos vacíos innecesarios
  // 3. Estructura optimizada para evitar páginas en blanco
  final documentXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
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
    
    <!-- Separador -->
    <w:p>
      <w:pPr>
        <w:spacing w:after="200"/>
      </w:pPr>
    </w:p>
    
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
          <w:tcPr>
            <w:tcW w:w="2000" w:type="pct"/>
          </w:tcPr>
          <w:p>
            <w:r>
              <w:rPr><w:b/></w:rPr>
              <w:t>Plaza:</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="3000" w:type="pct"/>
          </w:tcPr>
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
    
    <!-- Separador -->
    <w:p>
      <w:pPr>
        <w:spacing w:after="200"/>
      </w:pPr>
    </w:p>
    
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
    
    <!-- ✅ CORRECCIÓN: UNA TABLA con múltiples filas, NO múltiples tablas -->
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
      
      <!-- Encabezado de tabla -->
      <w:tr>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="2000" w:type="pct"/>
            <w:shd w:fill="E8F5E9"/>
          </w:tcPr>
          <w:p>
            <w:r>
              <w:rPr><w:b/></w:rPr>
              <w:t>Criterio</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="1500" w:type="pct"/>
            <w:shd w:fill="E8F5E9"/>
          </w:tcPr>
          <w:p>
            <w:r>
              <w:rPr><w:b/></w:rPr>
              <w:t>Evaluación</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:tcPr>
            <w:tcW w:w="1500" w:type="pct"/>
            <w:shd w:fill="E8F5E9"/>
          </w:tcPr>
          <w:p>
            <w:r>
              <w:rPr><w:b/></w:rPr>
              <w:t>Observaciones</w:t>
            </w:r>
          </w:p>
        </w:tc>
      </w:tr>
      
      <!-- Loop de evaluaciones DENTRO de la tabla -->
      {#evaluaciones}
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
      {/evaluaciones}
    </w:tbl>
    
    <!-- Separador -->
    <w:p>
      <w:pPr>
        <w:spacing w:after="200"/>
      </w:pPr>
    </w:p>
    
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
        <w:spacing w:before="100" w:after="100"/>
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
        <w:spacing w:after="100"/>
      </w:pPr>
      <w:r>
        <w:t>{%imagen%}</w:t>
      </w:r>
    </w:p>
    
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:after="200"/>
      </w:pPr>
      <w:r>
        <w:t>Nota: {nota}</w:t>
      </w:r>
    </w:p>
    {/fotos}
    
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/>
    </w:sectPr>
  </w:body>
</w:document>''';

  // Content Types
  final contentTypesXml =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Default Extension="jpeg" ContentType="image/jpeg"/>
  <Default Extension="jpg" ContentType="image/jpeg"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>
</Types>''';

  // Document relationships
  final documentRels =
      '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>
</Relationships>''';

  // Package relationships
  final packageRels = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';

  // Styles
  final stylesXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
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

  // Settings
  final settingsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:defaultTabStop w:val="720"/>
</w:settings>''';

  // Crear el archivo ZIP (DOCX)
  final archive = Archive();

  // Agregar archivos al ZIP
  archive.addFile(
    ArchiveFile(
      '[Content_Types].xml',
      contentTypesXml.length,
      contentTypesXml.codeUnits,
    ),
  );
  archive.addFile(
    ArchiveFile('_rels/.rels', packageRels.length, packageRels.codeUnits),
  );
  archive.addFile(
    ArchiveFile('word/document.xml', documentXml.length, documentXml.codeUnits),
  );
  archive.addFile(
    ArchiveFile('word/styles.xml', stylesXml.length, stylesXml.codeUnits),
  );
  archive.addFile(
    ArchiveFile('word/settings.xml', settingsXml.length, settingsXml.codeUnits),
  );
  archive.addFile(
    ArchiveFile(
      'word/_rels/document.xml.rels',
      documentRels.length,
      documentRels.codeUnits,
    ),
  );

  // Codificar como ZIP
  final zipEncoder = ZipEncoder();
  final zipData = zipEncoder.encode(archive);

  // Guardar archivo
  final file = File('assets/base02.docx');
  file.writeAsBytesSync(zipData!);

  print('✅ base02.docx generado exitosamente en assets/');
  print('📊 Tamaño: ${file.lengthSync()} bytes');
  print('');
  print('🔧 CORRECCIONES APLICADAS:');
  print('   1. ✅ Tabla única de evaluaciones (no múltiples tablas)');
  print('   2. ✅ Sin párrafos vacíos <w:p/>');
  print('   3. ✅ Espaciado controlado con <w:spacing>');
  print('   4. ✅ Encabezado de tabla con fondo verde claro');
  print('   5. ✅ Anchos de columna proporcionales');
  print('');
  print('📝 PLACEHOLDERS VÁLIDOS:');
  print(
    '   Texto: {plaza_id}, {nombre_plaza}, {inspector}, {fecha_hora}, {estado_general}',
  );
  print('   Imagen: {%logo%}');
  print('   Loops: {#evaluaciones} {#fotos}');
  print('   Loop evaluaciones: {criterio}, {evaluacion}, {observaciones}');
  print('   Loop fotos: {numero}, {%imagen%}, {nota}');
  print('');
  print(
    '⚠️  IMPORTANTE: Actualizar catastro_export_service.dart para usar base02.docx',
  );
}
