import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';

/// Generador de DOCX REAL (Office Open XML)
///
/// Este generador crea archivos .docx nativos como archivos ZIP
/// que contienen XML según el estándar Office Open XML.
///
/// NO genera HTML disfrazado de Word.
/// Las imágenes se insertan como archivos binarios dentro del ZIP.
class DocxRealGenerator {
  /// Genera un documento DOCX mínimo de prueba
  ///
  /// Este método es la FASE 1 de implementación.
  /// Genera un documento básico con:
  /// - Título
  /// - Párrafo
  /// - Tamaño A4
  /// - Márgenes estándar
  Future<List<int>> generarDocxMinimo() async {
    // Crear archivo ZIP (estructura DOCX)
    final archive = Archive();

    // Agregar archivos XML requeridos
    _agregarContentTypes(archive);
    _agregarRelsRaiz(archive);
    _agregarDocumentXml(archive);
    _agregarDocumentRels(archive);
    _agregarStyles(archive);
    _agregarSettings(archive);

    // Comprimir como ZIP (esto ES un DOCX)
    final zipBytes = ZipEncoder().encode(archive);

    return zipBytes!;
  }

  /// FASE 2: Genera un documento DOCX con UNA imagen
  ///
  /// La imagen se inserta como:
  /// - Archivo binario en word/media/image1.jpeg
  /// - Relación en word/_rels/document.xml.rels
  /// - Referencia DrawingML en word/document.xml
  Future<List<int>> generarDocxConImagen({
    required Uint8List imagenBytes,
  }) async {
    // Crear archivo ZIP (estructura DOCX)
    final archive = Archive();

    // Agregar archivos XML requeridos (con imagen)
    _agregarContentTypesConImagen(archive);
    _agregarRelsRaiz(archive);
    _agregarDocumentXmlConImagen(archive);
    _agregarDocumentRelsConImagen(archive);
    _agregarStyles(archive);
    _agregarSettings(archive);

    // Agregar imagen como archivo binario
    _agregarImagenBinaria(archive, 'word/media/image1.jpeg', imagenBytes);

    // Comprimir como ZIP (esto ES un DOCX)
    final zipBytes = ZipEncoder().encode(archive);

    return zipBytes!;
  }

  /// [Content_Types].xml - Define tipos MIME de cada parte del documento
  void _agregarContentTypes(Archive archive) {
    final xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>
</Types>''';

    _agregarArchivoXml(archive, '[Content_Types].xml', xml);
  }

  /// Helper para agregar archivos XML con encoding UTF-8 correcto
  void _agregarArchivoXml(Archive archive, String path, String xmlContent) {
    final bytes = utf8.encode(xmlContent);
    final file = ArchiveFile(path, bytes.length, bytes);
    file.compress = true;
    archive.addFile(file);
  }

  /// _rels/.rels - Relaciones raíz del paquete
  void _agregarRelsRaiz(Archive archive) {
    final xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';

    _agregarArchivoXml(archive, '_rels/.rels', xml);
  }

  /// word/document.xml - Contenido principal del documento
  void _agregarDocumentXml(Archive archive) {
    final xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <w:body>
    <!-- Título centrado -->
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:after="240"/>
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

    <!-- Subtítulo centrado -->
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:after="480"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:sz w:val="24"/>
          <w:color w:val="666666"/>
        </w:rPr>
        <w:t>Municipalidad de Doñihue</w:t>
      </w:r>
    </w:p>

    <!-- Párrafo de prueba -->
    <w:p>
      <w:pPr>
        <w:spacing w:after="200"/>
      </w:pPr>
      <w:r>
        <w:t>Este es un documento DOCX real generado desde Dart/Flutter.</w:t>
      </w:r>
    </w:p>

    <w:p>
      <w:r>
        <w:t>El archivo contiene la estructura Office Open XML completa:</w:t>
      </w:r>
    </w:p>

    <!-- Lista simple -->
    <w:p>
      <w:pPr>
        <w:ind w:left="720"/>
      </w:pPr>
      <w:r>
        <w:t>• [Content_Types].xml</w:t>
      </w:r>
    </w:p>

    <w:p>
      <w:pPr>
        <w:ind w:left="720"/>
      </w:pPr>
      <w:r>
        <w:t>• _rels/.rels</w:t>
      </w:r>
    </w:p>

    <w:p>
      <w:pPr>
        <w:ind w:left="720"/>
      </w:pPr>
      <w:r>
        <w:t>• word/document.xml</w:t>
      </w:r>
    </w:p>

    <w:p>
      <w:pPr>
        <w:ind w:left="720"/>
      </w:pPr>
      <w:r>
        <w:t>• word/styles.xml</w:t>
      </w:r>
    </w:p>

    <w:p>
      <w:pPr>
        <w:ind w:left="720"/>
        <w:spacing w:after="400"/>
      </w:pPr>
      <w:r>
        <w:t>• word/settings.xml</w:t>
      </w:r>
    </w:p>

    <w:p>
      <w:r>
        <w:rPr>
          <w:b/>
        </w:rPr>
        <w:t>Si Microsoft Word abre este archivo sin advertencias, la FASE 1 está completa.</w:t>
      </w:r>
    </w:p>

    <!-- Configuración de sección (A4, márgenes) -->
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
      <w:cols w:space="720"/>
    </w:sectPr>
  </w:body>
</w:document>''';

    _agregarArchivoXml(archive, 'word/document.xml', xml);
  }

  /// word/_rels/document.xml.rels - Relaciones del documento
  void _agregarDocumentRels(Archive archive) {
    final xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>
</Relationships>''';

    _agregarArchivoXml(archive, 'word/_rels/document.xml.rels', xml);
  }

  /// word/styles.xml - Estilos del documento
  void _agregarStyles(Archive archive) {
    final xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:docDefaults>
    <w:rPrDefault>
      <w:rPr>
        <w:rFonts w:ascii="Calibri" w:hAnsi="Calibri" w:cs="Calibri"/>
        <w:sz w:val="22"/>
      </w:rPr>
    </w:rPrDefault>
    <w:pPrDefault>
      <w:pPr>
        <w:spacing w:after="0" w:line="276" w:lineRule="auto"/>
      </w:pPr>
    </w:pPrDefault>
  </w:docDefaults>
  
  <w:style w:type="paragraph" w:styleId="Normal">
    <w:name w:val="Normal"/>
    <w:qFormat/>
    <w:pPr>
      <w:spacing w:after="200"/>
    </w:pPr>
  </w:style>
</w:styles>''';

    _agregarArchivoXml(archive, 'word/styles.xml', xml);
  }

  /// word/settings.xml - Configuración del documento
  void _agregarSettings(Archive archive) {
    final xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:settings xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:zoom w:percent="100"/>
  <w:defaultTabStop w:val="720"/>
  <w:characterSpacingControl w:val="doNotCompress"/>
</w:settings>''';

    _agregarArchivoXml(archive, 'word/settings.xml', xml);
  }

  // ==========================================================================
  // MÉTODOS PARA FASE 2: DOCX CON IMAGEN
  // ==========================================================================

  /// [Content_Types].xml con soporte para imágenes JPEG
  void _agregarContentTypesConImagen(Archive archive) {
    final xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="jpeg" ContentType="image/jpeg"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>
</Types>''';

    _agregarArchivoXml(archive, '[Content_Types].xml', xml);
  }

  /// word/document.xml con una imagen insertada
  void _agregarDocumentXmlConImagen(Archive archive) {
    final xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
            xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
            xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
            xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
            xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
  <w:body>
    <!-- Título centrado -->
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="32"/>
          <w:color w:val="2E7D32"/>
        </w:rPr>
        <w:t>FASE 2: DOCX CON IMAGEN</w:t>
      </w:r>
    </w:p>

    <!-- Subtítulo -->
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:after="480"/>
      </w:pPr>
      <w:r>
        <w:sz w:val="24"/>
        <w:t>Documento DOCX con imagen binaria incrustada</w:t>
      </w:r>
    </w:p>

    <!-- Párrafo de introducción -->
    <w:p>
      <w:pPr>
        <w:spacing w:after="400"/>
      </w:pPr>
      <w:r>
        <w:t>La siguiente imagen está físicamente almacenada dentro del archivo DOCX en word/media/image1.jpeg</w:t>
      </w:r>
    </w:p>

    <!-- IMAGEN INSERTADA -->
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:after="400"/>
      </w:pPr>
      <w:r>
        <w:drawing>
          <wp:inline distT="0" distB="0" distL="0" distR="0">
            <wp:extent cx="3048000" cy="2286000"/>
            <wp:effectExtent l="0" t="0" r="0" b="0"/>
            <wp:docPr id="1" name="Imagen 1" descr="Imagen de prueba"/>
            <wp:cNvGraphicFramePr>
              <a:graphicFrameLocks noChangeAspect="1"/>
            </wp:cNvGraphicFramePr>
            <a:graphic>
              <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                <pic:pic>
                  <pic:nvPicPr>
                    <pic:cNvPr id="1" name="Imagen 1"/>
                    <pic:cNvPicPr/>
                  </pic:nvPicPr>
                  <pic:blipFill>
                    <a:blip r:embed="rId3"/>
                    <a:stretch>
                      <a:fillRect/>
                    </a:stretch>
                  </pic:blipFill>
                  <pic:spPr>
                    <a:xfrm>
                      <a:off x="0" y="0"/>
                      <a:ext cx="3048000" cy="2286000"/>
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
        <w:spacing w:after="200"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
        </w:rPr>
        <w:t>Si la imagen aparece correctamente en Microsoft Word, la FASE 2 está completa.</w:t>
      </w:r>
    </w:p>

    <!-- Verificaciones -->
    <w:p>
      <w:r>
        <w:t>Verificar que:</w:t>
      </w:r>
    </w:p>

    <w:p>
      <w:pPr>
        <w:ind w:left="720"/>
      </w:pPr>
      <w:r>
        <w:t>• La imagen aparece</w:t>
      </w:r>
    </w:p>

    <w:p>
      <w:pPr>
        <w:ind w:left="720"/>
      </w:pPr>
      <w:r>
        <w:t>• La imagen mantiene proporción</w:t>
      </w:r>
    </w:p>

    <w:p>
      <w:pPr>
        <w:ind w:left="720"/>
      </w:pPr>
      <w:r>
        <w:t>• La imagen está centrada</w:t>
      </w:r>
    </w:p>

    <w:p>
      <w:pPr>
        <w:ind w:left="720"/>
      </w:pPr>
      <w:r>
        <w:t>• La imagen está dentro de los márgenes</w:t>
      </w:r>
    </w:p>

    <!-- Configuración de sección (A4, márgenes) -->
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
      <w:cols w:space="720"/>
    </w:sectPr>
  </w:body>
</w:document>''';

    _agregarArchivoXml(archive, 'word/document.xml', xml);
  }

  /// word/_rels/document.xml.rels con relación a la imagen
  void _agregarDocumentRelsConImagen(Archive archive) {
    final xml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image1.jpeg"/>
</Relationships>''';

    _agregarArchivoXml(archive, 'word/_rels/document.xml.rels', xml);
  }

  /// Agrega una imagen como archivo binario al ZIP
  void _agregarImagenBinaria(
    Archive archive,
    String path,
    Uint8List imageBytes,
  ) {
    final file = ArchiveFile(path, imageBytes.length, imageBytes);
    file.compress = true;
    archive.addFile(file);
  }

  // ==========================================================================
  // FASE 3: DOCX COMPLETO CON CATASTRO
  // ==========================================================================

  /// Genera un documento DOCX completo del catastro
  ///
  /// Incluye:
  /// - Logo en esquina superior derecha
  /// - Título y datos básicos
  /// - Tabla de evaluación
  /// - Anexo fotográfico con múltiples imágenes
  Future<List<int>> generarDocxCatastro({
    required String plazaId,
    required String nombrePlaza,
    required String inspector,
    required String fechaHora,
    required String estadoGeneral,
    required List<Map<String, String>> evaluaciones,
    required Uint8List? logoBytes,
    required List<FotoDocx> fotos,
  }) async {
    final archive = Archive();

    // 1. Content Types (incluye PNG y JPEG)
    _agregarContentTypesCatastro(archive);

    // 2. Relaciones raíz
    _agregarRelsRaiz(archive);

    // 3. Document XML principal con contenido completo
    _agregarDocumentXmlCatastro(
      archive,
      plazaId: plazaId,
      nombrePlaza: nombrePlaza,
      inspector: inspector,
      fechaHora: fechaHora,
      estadoGeneral: estadoGeneral,
      evaluaciones: evaluaciones,
      tieneLogo: logoBytes != null,
      fotos: fotos,
    );

    // 4. Relaciones del documento (logo + fotos)
    _agregarDocumentRelsCatastro(
      archive,
      tieneLogo: logoBytes != null,
      fotos: fotos,
    );

    // 5. Estilos y configuración
    _agregarStyles(archive);
    _agregarSettings(archive);

    // 6. Agregar logo si existe
    if (logoBytes != null) {
      _agregarImagenBinaria(archive, 'word/media/logo.png', logoBytes);
    }

    // 7. Agregar todas las fotos
    for (var i = 0; i < fotos.length; i++) {
      final foto = fotos[i];
      final extension = foto.esJpeg ? 'jpg' : 'png';
      _agregarImagenBinaria(
        archive,
        'word/media/image${i + 1}.$extension',
        foto.bytes,
      );
    }

    // 8. Comprimir como ZIP
    final zipBytes = ZipEncoder().encode(archive);
    return zipBytes!;
  }

  /// Content Types para catastro (PNG + JPEG)
  void _agregarContentTypesCatastro(Archive archive) {
    final xml = '''<?xml version="1.0" encoding="UTF-8"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Default Extension="png" ContentType="image/png"/>
  <Default Extension="jpg" ContentType="image/jpeg"/>
  <Default Extension="jpeg" ContentType="image/jpeg"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
  <Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>
  <Override PartName="/word/settings.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml"/>
</Types>''';

    _agregarArchivoXml(archive, '[Content_Types].xml', xml);
  }

  /// Genera el document.xml completo del catastro
  void _agregarDocumentXmlCatastro(
    Archive archive, {
    required String plazaId,
    required String nombrePlaza,
    required String inspector,
    required String fechaHora,
    required String estadoGeneral,
    required List<Map<String, String>> evaluaciones,
    required bool tieneLogo,
    required List<FotoDocx> fotos,
  }) {
    final StringBuffer xml = StringBuffer();

    // Escapar todos los datos de entrada
    final plazaIdEscapado = _escaparXml(plazaId);
    final nombreEscapado = _escaparXml(nombrePlaza);
    final inspectorEscapado = _escaparXml(inspector);
    final fechaHoraEscapado = _escaparXml(fechaHora);
    final estadoGeneralEscapado = _escaparXml(estadoGeneral);

    // Encabezado XML y namespaces
    xml.write('''<?xml version="1.0" encoding="UTF-8"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing" xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture">
  <w:body>
''');

    // Logo flotante en esquina superior derecha (si existe)
    if (tieneLogo) {
      xml.write('''
    <w:p>
      <w:pPr>
        <w:spacing w:before="0" w:after="0"/>
      </w:pPr>
      <w:r>
        <w:drawing>
          <wp:anchor distT="0" distB="0" distL="114300" distR="114300" simplePos="0" relativeHeight="251658240" behindDoc="0" locked="0" layoutInCell="1" allowOverlap="1">
            <wp:simplePos x="0" y="0"/>
            <wp:positionH relativeFrom="margin">
              <wp:align>right</wp:align>
            </wp:positionH>
            <wp:positionV relativeFrom="margin">
              <wp:posOffset>0</wp:posOffset>
            </wp:positionV>
            <wp:extent cx="1371600" cy="1028700"/>
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
                    <pic:cNvPr id="0" name="logo.png"/>
                    <pic:cNvPicPr/>
                  </pic:nvPicPr>
                  <pic:blipFill>
                    <a:blip r:embed="rId3"/>
                    <a:stretch>
                      <a:fillRect/>
                    </a:stretch>
                  </pic:blipFill>
                  <pic:spPr>
                    <a:xfrm>
                      <a:off x="0" y="0"/>
                      <a:ext cx="1371600" cy="1028700"/>
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
''');
    }

    // Título centrado
    xml.write('''
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
''');

    // Subtítulo
    xml.write('''
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
''');

    // Datos básicos
    xml.write(_generarParrafoDato('Plaza ID', plazaIdEscapado));
    xml.write(_generarParrafoDato('Nombre', nombreEscapado));
    xml.write(_generarParrafoDato('Inspector', inspectorEscapado));
    xml.write(_generarParrafoDato('Fecha', fechaHoraEscapado));

    // Estado General
    xml.write('''
    <w:p>
      <w:pPr>
        <w:spacing w:before="360" w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="24"/>
        </w:rPr>
        <w:t>Estado General: $estadoGeneralEscapado</w:t>
      </w:r>
    </w:p>
''');

    // Tabla de evaluación
    if (evaluaciones.isNotEmpty) {
      xml.write(_generarTablaEvaluacion(evaluaciones));
    }

    // Anexo fotográfico
    if (fotos.isNotEmpty) {
      xml.write('''
    <w:p>
      <w:pPr>
        <w:spacing w:before="480" w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="28"/>
          <w:color w:val="2E7D32"/>
        </w:rPr>
        <w:t>ANEXO FOTOGRÁFICO</w:t>
      </w:r>
    </w:p>
''');

      // Calcular el primer rId para fotos
      // rId1 = styles, rId2 = settings
      // Si hay logo: rId3 = logo, fotos empiezan en rId4
      // Si no hay logo: fotos empiezan en rId3
      final int primerRidFoto = tieneLogo ? 4 : 3;

      // Insertar cada foto con su título real
      for (var i = 0; i < fotos.length; i++) {
        final foto = fotos[i];
        final rId = primerRidFoto + i;
        final tituloEscapado = _escaparXml(foto.titulo);

        xml.write(
          _generarImagenInline(
            titulo: 'Fotografía ${i + 1} — $tituloEscapado',
            rId: 'rId$rId',
            docPrId: i + 10,
          ),
        );
      }
    }

    // Sección (A4, márgenes)
    xml.write('''
    <w:sectPr>
      <w:pgSz w:w="11906" w:h="16838"/>
      <w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440" w:header="720" w:footer="720" w:gutter="0"/>
    </w:sectPr>
  </w:body>
</w:document>''');

    _agregarArchivoXml(archive, 'word/document.xml', xml.toString());
  }

  /// Genera un párrafo con dato (negrita: valor)
  String _generarParrafoDato(String label, String valor) {
    return '''
    <w:p>
      <w:pPr>
        <w:spacing w:before="120" w:after="120"/>
      </w:pPr>
      <w:r>
        <w:rPr><w:b/></w:rPr>
        <w:t>$label: </w:t>
      </w:r>
      <w:r>
        <w:t>$valor</w:t>
      </w:r>
    </w:p>
''';
  }

  /// Genera una tabla de evaluación
  String _generarTablaEvaluacion(List<Map<String, String>> evaluaciones) {
    final StringBuffer tabla = StringBuffer();

    tabla.write('''
    <w:p>
      <w:pPr>
        <w:spacing w:before="360" w:after="120"/>
      </w:pPr>
      <w:r>
        <w:rPr>
          <w:b/>
          <w:sz w:val="24"/>
        </w:rPr>
        <w:t>EVALUACIÓN DE CRITERIOS</w:t>
      </w:r>
    </w:p>
    <w:tbl>
      <w:tblPr>
        <w:tblW w:w="9000" w:type="dxa"/>
        <w:tblBorders>
          <w:top w:val="single" w:sz="4" w:space="0" w:color="000000"/>
          <w:left w:val="single" w:sz="4" w:space="0" w:color="000000"/>
          <w:bottom w:val="single" w:sz="4" w:space="0" w:color="000000"/>
          <w:right w:val="single" w:sz="4" w:space="0" w:color="000000"/>
          <w:insideH w:val="single" w:sz="4" w:space="0" w:color="000000"/>
          <w:insideV w:val="single" w:sz="4" w:space="0" w:color="000000"/>
        </w:tblBorders>
      </w:tblPr>
      <w:tblGrid>
        <w:gridCol w:w="3000"/>
        <w:gridCol w:w="2000"/>
        <w:gridCol w:w="4000"/>
      </w:tblGrid>
''');

    // Encabezado de tabla
    tabla.write('''
      <w:tr>
        <w:tc>
          <w:tcPr>
            <w:shd w:val="clear" w:color="auto" w:fill="2E7D32"/>
          </w:tcPr>
          <w:p>
            <w:pPr><w:jc w:val="center"/></w:pPr>
            <w:r>
              <w:rPr><w:b/><w:color w:val="FFFFFF"/></w:rPr>
              <w:t>Criterio</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:tcPr>
            <w:shd w:val="clear" w:color="auto" w:fill="2E7D32"/>
          </w:tcPr>
          <w:p>
            <w:pPr><w:jc w:val="center"/></w:pPr>
            <w:r>
              <w:rPr><w:b/><w:color w:val="FFFFFF"/></w:rPr>
              <w:t>Evaluación</w:t>
            </w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:tcPr>
            <w:shd w:val="clear" w:color="auto" w:fill="2E7D32"/>
          </w:tcPr>
          <w:p>
            <w:pPr><w:jc w:val="center"/></w:pPr>
            <w:r>
              <w:rPr><w:b/><w:color w:val="FFFFFF"/></w:rPr>
              <w:t>Observaciones</w:t>
            </w:r>
          </w:p>
        </w:tc>
      </w:tr>
''');

    // Filas de datos
    for (var evaluacion in evaluaciones) {
      final criterio = _escaparXml(evaluacion['criterio'] ?? '');
      final eval = _escaparXml(evaluacion['evaluacion'] ?? 'N/A');
      final obs = _escaparXml(evaluacion['observaciones'] ?? '-');

      tabla.write('''
      <w:tr>
        <w:tc>
          <w:p>
            <w:r><w:t>$criterio</w:t></w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:p>
            <w:pPr><w:jc w:val="center"/></w:pPr>
            <w:r><w:t>$eval</w:t></w:r>
          </w:p>
        </w:tc>
        <w:tc>
          <w:p>
            <w:r><w:t>$obs</w:t></w:r>
          </w:p>
        </w:tc>
      </w:tr>
''');
    }

    tabla.write('    </w:tbl>\n');
    return tabla.toString();
  }

  /// Genera una imagen inline centrada con título
  String _generarImagenInline({
    required String titulo,
    required String rId,
    required int docPrId,
  }) {
    // Dimensiones más pequeñas: 3 inches x 2.25 inches (en vez de 4" x 3")
    const int imgWidthEmu = 2743200; // 3 inches
    const int imgHeightEmu = 2057400; // 2.25 inches

    return '''
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:before="360" w:after="240"/>
      </w:pPr>
      <w:r>
        <w:rPr><w:b/></w:rPr>
        <w:t>$titulo</w:t>
      </w:r>
    </w:p>
    <w:p>
      <w:pPr>
        <w:jc w:val="center"/>
        <w:spacing w:before="0" w:after="480"/>
      </w:pPr>
      <w:r>
        <w:drawing>
          <wp:inline distT="0" distB="0" distL="0" distR="0">
            <wp:extent cx="$imgWidthEmu" cy="$imgHeightEmu"/>
            <wp:effectExtent l="0" t="0" r="0" b="0"/>
            <wp:docPr id="$docPrId" name="Foto"/>
            <wp:cNvGraphicFramePr>
              <a:graphicFrameLocks noChangeAspect="1"/>
            </wp:cNvGraphicFramePr>
            <a:graphic>
              <a:graphicData uri="http://schemas.openxmlformats.org/drawingml/2006/picture">
                <pic:pic>
                  <pic:nvPicPr>
                    <pic:cNvPr id="0" name="Foto"/>
                    <pic:cNvPicPr/>
                  </pic:nvPicPr>
                  <pic:blipFill>
                    <a:blip r:embed="$rId"/>
                    <a:stretch>
                      <a:fillRect/>
                    </a:stretch>
                  </pic:blipFill>
                  <pic:spPr>
                    <a:xfrm>
                      <a:off x="0" y="0"/>
                      <a:ext cx="$imgWidthEmu" cy="$imgHeightEmu"/>
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
''';
  }

  /// Genera las relaciones del documento para catastro
  void _agregarDocumentRelsCatastro(
    Archive archive, {
    required bool tieneLogo,
    required List<FotoDocx> fotos,
  }) {
    final StringBuffer xml = StringBuffer();

    xml.write('''<?xml version="1.0" encoding="UTF-8"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
''');

    // rId1 = styles.xml
    xml.write(
      '  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>\n',
    );

    // rId2 = settings.xml
    xml.write(
      '  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings" Target="settings.xml"/>\n',
    );

    int rIdCounter = 3;

    // Logo (si existe) = rId3
    if (tieneLogo) {
      xml.write(
        '  <Relationship Id="rId$rIdCounter" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/logo.png"/>\n',
      );
      rIdCounter++;
    }

    // Fotos empiezan en rId4 (si hay logo) o rId3 (si no hay logo)
    for (var i = 0; i < fotos.length; i++) {
      final foto = fotos[i];
      final extension = foto.esJpeg ? 'jpg' : 'png';
      xml.write(
        '  <Relationship Id="rId$rIdCounter" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/image" Target="media/image${i + 1}.$extension"/>\n',
      );
      rIdCounter++;
    }

    xml.write('</Relationships>');

    _agregarArchivoXml(archive, 'word/_rels/document.xml.rels', xml.toString());
  }

  /// Escapa caracteres especiales XML
  String _escaparXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

/// Clase auxiliar para fotos en DOCX
class FotoDocx {
  final Uint8List bytes;
  final String titulo;
  final bool esJpeg;

  FotoDocx({required this.bytes, required this.titulo, this.esJpeg = true});
}
