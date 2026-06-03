import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class InspeccionTecnicaScreen extends StatefulWidget {
  final Map<String, dynamic> plaza;

  const InspeccionTecnicaScreen({super.key, required this.plaza});

  @override
  State<InspeccionTecnicaScreen> createState() =>
      _InspeccionTecnicaScreenState();
}

class _InspeccionTecnicaScreenState extends State<InspeccionTecnicaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

  // Controladores para campos editables del encabezado
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _tipoParqueController = TextEditingController();
  final TextEditingController _superficieController = TextEditingController();
  final TextEditingController _poblacionController = TextEditingController();
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _evaluacionGeneralController =
      TextEditingController();
  final TextEditingController _ultimaEvaluacionController =
      TextEditingController();

  // Fecha y hora de apertura
  late String _fechaHoraApertura;

  // Datos de las 6 categorías
  final Map<String, Map<String, String?>> _evaluaciones = {
    'aseo': {},
    'cesped': {},
    'arbolado': {},
    'flores': {},
    'caminos': {},
    'infraestructura': {},
  };

  // Observaciones por categoría
  final Map<String, TextEditingController> _observacionesControllers = {
    'aseo': TextEditingController(),
    'cesped': TextEditingController(),
    'arbolado': TextEditingController(),
    'flores': TextEditingController(),
    'caminos': TextEditingController(),
    'infraestructura': TextEditingController(),
  };

  // Fotos por categoría
  final Map<String, List<XFile>> _fotos = {
    'aseo': [],
    'cesped': [],
    'arbolado': [],
    'flores': [],
    'caminos': [],
    'infraestructura': [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _fechaHoraApertura = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Pre-llenar campos con datos de la plaza
    _descripcionController.text = widget.plaza['nombre'] ?? '';
    _tipoParqueController.text = widget.plaza['tipo'] ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _descripcionController.dispose();
    _tipoParqueController.dispose();
    _superficieController.dispose();
    _poblacionController.dispose();
    _sectorController.dispose();
    _evaluacionGeneralController.dispose();
    _ultimaEvaluacionController.dispose();
    for (var controller in _observacionesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ficha de Inspección Técnica',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Encabezado institucional
          _buildEncabezado(),

          // Pestañas de categorías
          Container(
            color: const Color(0xFFF5F5F5),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF1565C0),
              unselectedLabelColor: const Color(0xFF757575),
              indicatorColor: const Color(0xFF1565C0),
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'ASEO'),
                Tab(text: 'CÉSPED'),
                Tab(text: 'ARBOLADO'),
                Tab(text: 'FLORES'),
                Tab(text: 'CAMINOS'),
                Tab(text: 'INFRAESTRUCTURA'),
              ],
            ),
          ),

          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCategoriaTab('aseo', _getAseoItems()),
                _buildCategoriaTab('cesped', _getCespedItems()),
                _buildCategoriaTab('arbolado', _getArboladoItems()),
                _buildCategoriaTab('flores', _getFloresItems()),
                _buildCategoriaTab('caminos', _getCaminosItems()),
                _buildCategoriaTab(
                  'infraestructura',
                  _getInfraestructuraItems(),
                ),
              ],
            ),
          ),

          // Botones de acción
          _buildBotonesAccion(),
        ],
      ),
    );
  }

  Widget _buildEncabezado() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Fila con logos y título
          Row(
            children: [
              // Logo municipal izquierdo
              Image.asset(
                'assets/logowebactualizado.png',
                height: 60,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              // Título central
              const Expanded(
                child: Text(
                  'INFORMACIÓN DEL ÁREA VERDE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Logo unidad de aseo derecho
              Image.asset(
                'assets/unidad_aseo.png',
                height: 60,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tabla de información
          Table(
            border: TableBorder.all(color: Colors.grey.shade400, width: 1),
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(3)},
            children: [
              _buildTableRow('ID av', widget.plaza['id'] ?? '', false),
              _buildTableRowEditable('DESCRIPCIÓN', _descripcionController),
              _buildTableRow(
                'LATITUD',
                widget.plaza['coordenadas']?.latitude.toStringAsFixed(6) ?? '',
                false,
              ),
              _buildTableRow(
                'LONGITUD',
                widget.plaza['coordenadas']?.longitude.toStringAsFixed(6) ?? '',
                false,
              ),
              _buildTableRowEditable('TIPO DE PARQUE', _tipoParqueController),
              _buildTableRowEditable('SUPERFICIE', _superficieController),
              _buildTableRowEditable('POBLACIÓN', _poblacionController),
              _buildTableRowEditable('SECTOR', _sectorController),
              _buildTableRowEditable(
                'EVALUACIÓN GENERAL',
                _evaluacionGeneralController,
              ),
              _buildTableRowEditable(
                'ÚLTIMA EVALUACIÓN',
                _ultimaEvaluacionController,
              ),
              _buildTableRow('FECHA/HORA', _fechaHoraApertura, false),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value, bool editable) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0E0E0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF212121),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
          ),
        ),
      ],
    );
  }

  TableRow _buildTableRowEditable(
    String label,
    TextEditingController controller,
  ) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0E0E0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF212121),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Colors.white,
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriaTab(String categoria, List<String> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tabla de evaluación
          Table(
            border: TableBorder.all(color: Colors.grey.shade400, width: 1),
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              // Encabezado
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFE0E0E0)),
                children: [
                  _buildHeaderCell(_getCategoriaTitle(categoria)),
                  _buildHeaderCell('BUENO'),
                  _buildHeaderCell('REGULAR'),
                  _buildHeaderCell('MALO'),
                ],
              ),
              // Items de evaluación
              ...items.map((item) => _buildEvaluacionRow(categoria, item)),
            ],
          ),
          const SizedBox(height: 24),

          // Botón para adjuntar foto
          ElevatedButton.icon(
            onPressed: () => _adjuntarFoto(categoria),
            icon: const Icon(Icons.camera_alt),
            label: Text('Adjuntar Foto (${_fotos[categoria]!.length})'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          // Mostrar fotos adjuntas
          if (_fotos[categoria]!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _fotos[categoria]!.asMap().entries.map((entry) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(entry.value.path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _fotos[categoria]!.removeAt(entry.key);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),

          // Campo de observaciones
          const Text(
            'Observaciones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _observacionesControllers[categoria],
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Ingrese observaciones para esta categoría...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: Color(0xFF212121),
        ),
      ),
    );
  }

  TableRow _buildEvaluacionRow(String categoria, String item) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Text(item, style: const TextStyle(fontSize: 12)),
        ),
        _buildRadioCell(categoria, item, 'BUENO'),
        _buildRadioCell(categoria, item, 'REGULAR'),
        _buildRadioCell(categoria, item, 'MALO'),
      ],
    );
  }

  Widget _buildRadioCell(String categoria, String item, String value) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Radio<String>(
        value: value,
        groupValue: _evaluaciones[categoria]![item],
        onChanged: (String? newValue) {
          setState(() {
            _evaluaciones[categoria]![item] = newValue;
          });
        },
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildBotonesAccion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _generarInformePDF,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar Informe PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _enviarAJefatura,
              icon: const Icon(Icons.email),
              label: const Text('Enviar a Jefatura'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _adjuntarFoto(String categoria) async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (foto != null) {
        setState(() {
          _fotos[categoria]!.add(foto);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto adjuntada correctamente'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al capturar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generarInformePDF() async {
    try {
      // Mostrar indicador de carga
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      final pdf = pw.Document();

      // Cargar logo
      final logoData = await rootBundle.load('assets/logowebactualizado.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      // Página 1: Encabezado e información
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Encabezado con logo
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(logoImage, width: 80, height: 80),
                    pw.Text(
                      'INFORMACIÓN DEL ÁREA VERDE',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Tabla de información
                pw.Table.fromTextArray(
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  data: [
                    ['ID av', widget.plaza['id'] ?? ''],
                    ['DESCRIPCIÓN', _descripcionController.text],
                    [
                      'LATITUD',
                      widget.plaza['coordenadas']?.latitude.toStringAsFixed(
                            6,
                          ) ??
                          '',
                    ],
                    [
                      'LONGITUD',
                      widget.plaza['coordenadas']?.longitude.toStringAsFixed(
                            6,
                          ) ??
                          '',
                    ],
                    ['TIPO DE PARQUE', _tipoParqueController.text],
                    ['SUPERFICIE', _superficieController.text],
                    ['POBLACIÓN', _poblacionController.text],
                    ['SECTOR', _sectorController.text],
                    ['EVALUACIÓN GENERAL', _evaluacionGeneralController.text],
                    ['ÚLTIMA EVALUACIÓN', _ultimaEvaluacionController.text],
                    ['FECHA/HORA', _fechaHoraApertura],
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Páginas para cada categoría
      await _agregarPaginaCategoria(pdf, 'aseo', 'ASEO', _getAseoItems());
      await _agregarPaginaCategoria(
        pdf,
        'cesped',
        'MANEJO DE CÉSPED',
        _getCespedItems(),
      );
      await _agregarPaginaCategoria(
        pdf,
        'arbolado',
        'MANEJO DE ARBOLADO Y ARBUSTOS',
        _getArboladoItems(),
      );
      await _agregarPaginaCategoria(
        pdf,
        'flores',
        'MANEJO DE FLORES DE TEMPORADA, MACIZOS Y CUBRESUELOS',
        _getFloresItems(),
      );
      await _agregarPaginaCategoria(
        pdf,
        'caminos',
        'MANTENCIÓN DE CAMINOS PEATONALES Y ESTARES',
        _getCaminosItems(),
      );
      await _agregarPaginaCategoria(
        pdf,
        'infraestructura',
        'MANTENCIÓN DE INFRAESTRUCTURA',
        _getInfraestructuraItems(),
      );

      // Cerrar diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Mostrar vista previa y opciones de guardado
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _agregarPaginaCategoria(
    pw.Document pdf,
    String categoriaKey,
    String categoriaTitulo,
    List<String> items,
  ) async {
    // Cargar fotos antes de construir la página
    final List<pw.Widget> fotosWidgets = [];
    for (final foto in _fotos[categoriaKey]!.take(4)) {
      final bytes = await File(foto.path).readAsBytes();
      fotosWidgets.add(
        pw.Container(
          width: 120,
          height: 120,
          child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.cover),
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Título de la categoría
              pw.Text(
                categoriaTitulo,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              // Tabla de evaluación
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellStyle: const pw.TextStyle(fontSize: 9),
                headers: [categoriaTitulo, 'BUENO', 'REGULAR', 'MALO'],
                data: items.map((item) {
                  final eval = _evaluaciones[categoriaKey]![item] ?? '';
                  return [
                    item,
                    eval == 'BUENO' ? 'X' : '',
                    eval == 'REGULAR' ? 'X' : '',
                    eval == 'MALO' ? 'X' : '',
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 15),

              // Observaciones
              pw.Text(
                'Observaciones:',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                _observacionesControllers[categoriaKey]!.text.isEmpty
                    ? 'Sin observaciones'
                    : _observacionesControllers[categoriaKey]!.text,
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 15),

              // Fotos
              if (fotosWidgets.isNotEmpty) ...[
                pw.Text(
                  'Fotos adjuntas: ${_fotos[categoriaKey]!.length}',
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Wrap(spacing: 10, runSpacing: 10, children: fotosWidgets),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _enviarAJefatura() async {
    try {
      // Mostrar indicador de carga
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      // Generar PDF primero
      final pdf = pw.Document();

      // Cargar logo
      final logoData = await rootBundle.load('assets/logowebactualizado.png');
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      // Agregar páginas (mismo código que _generarInformePDF)
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(logoImage, width: 80, height: 80),
                    pw.Text(
                      'INFORMACIÓN DEL ÁREA VERDE',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  border: pw.TableBorder.all(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  data: [
                    ['ID av', widget.plaza['id'] ?? ''],
                    ['DESCRIPCIÓN', _descripcionController.text],
                    [
                      'LATITUD',
                      widget.plaza['coordenadas']?.latitude.toStringAsFixed(
                            6,
                          ) ??
                          '',
                    ],
                    [
                      'LONGITUD',
                      widget.plaza['coordenadas']?.longitude.toStringAsFixed(
                            6,
                          ) ??
                          '',
                    ],
                    ['TIPO DE PARQUE', _tipoParqueController.text],
                    ['SUPERFICIE', _superficieController.text],
                    ['POBLACIÓN', _poblacionController.text],
                    ['SECTOR', _sectorController.text],
                    ['EVALUACIÓN GENERAL', _evaluacionGeneralController.text],
                    ['ÚLTIMA EVALUACIÓN', _ultimaEvaluacionController.text],
                    ['FECHA/HORA', _fechaHoraApertura],
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Agregar páginas de categorías
      await _agregarPaginaCategoria(pdf, 'aseo', 'ASEO', _getAseoItems());
      await _agregarPaginaCategoria(
        pdf,
        'cesped',
        'MANEJO DE CÉSPED',
        _getCespedItems(),
      );
      await _agregarPaginaCategoria(
        pdf,
        'arbolado',
        'MANEJO DE ARBOLADO Y ARBUSTOS',
        _getArboladoItems(),
      );
      await _agregarPaginaCategoria(
        pdf,
        'flores',
        'MANEJO DE FLORES DE TEMPORADA, MACIZOS Y CUBRESUELOS',
        _getFloresItems(),
      );
      await _agregarPaginaCategoria(
        pdf,
        'caminos',
        'MANTENCIÓN DE CAMINOS PEATONALES Y ESTARES',
        _getCaminosItems(),
      );
      await _agregarPaginaCategoria(
        pdf,
        'infraestructura',
        'MANTENCIÓN DE INFRAESTRUCTURA',
        _getInfraestructuraItems(),
      );

      // Guardar PDF temporalmente
      final output = await getTemporaryDirectory();
      final fechaActual = DateFormat('dd-MM-yyyy_HH-mm').format(DateTime.now());
      final nombreArchivo = 'Inspeccion_${widget.plaza['id']}_$fechaActual.pdf';
      final file = File('${output.path}/$nombreArchivo');
      await file.writeAsBytes(await pdf.save());

      // Cerrar indicador de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Configurar correo con formato específico
      final fechaHoraActual = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(DateTime.now());
      final asunto = Uri.encodeComponent(
        'Informe de Inspección - ${widget.plaza['id']} - $fechaHoraActual',
      );
      final cuerpo = Uri.encodeComponent(
        'Estimado,\n\n'
        'Adjunto el informe de inspección técnica realizado en terreno para su revisión.\n\n'
        'Saludos.',
      );

      // Abrir cliente de correo con configuración específica
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: 'josuejuan2019@gmail.com',
        query: 'subject=$asunto&body=$cuerpo',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✓ PDF generado correctamente',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Archivo: $nombreArchivo'),
                  const SizedBox(height: 4),
                  Text('Ubicación: ${file.path}'),
                  const SizedBox(height: 8),
                  const Text(
                    'Se ha abierto tu cliente de correo.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const Text(
                    'Por favor, adjunta manualmente el PDF desde la ubicación indicada.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 8),
            ),
          );
        }
      } else {
        throw 'No se pudo abrir el cliente de correo';
      }
    } catch (e) {
      // Cerrar indicador de carga si está abierto
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getCategoriaTitle(String categoria) {
    switch (categoria) {
      case 'aseo':
        return 'ASEO';
      case 'cesped':
        return 'MANEJO DE CÉSPED';
      case 'arbolado':
        return 'MANEJO DE ARBOLADO Y ARBUSTOS';
      case 'flores':
        return 'MANEJO DE FLORES DE TEMPORADA, MACIZOS Y CUBRESUELOS';
      case 'caminos':
        return 'MANTENCIÓN DE CAMINOS PEATONALES Y ESTARES';
      case 'infraestructura':
        return 'MANTENCIÓN DE INFRAESTRUCTURA';
      default:
        return '';
    }
  }

  List<String> _getAseoItems() {
    return [
      'Basura por tiempo indebido pero con recolección.',
      'Residuos acumulados de días anteriores.',
      'Presencia de escombros o desechos.',
      'Aseo externo o interior en áreas específicas (ciclovías), no realizado o realizado parcialmente',
      'Basureros sucios o en mal estado.',
      'Aseo sin realizar espacio abiertamente sucio (aplicable en ciclovías)',
      'No hay residuos sólidos.',
    ];
  }

  List<String> _getCespedItems() {
    return [
      'Presencia de césped seco o amarillento.',
      'Zonas con baja densidad de césped.',
      'Pasto cortado sin retirar.',
      'Zonas con densidad disminuida más de 5% y hasta 30%.',
      'Muchas zonas ralas más de 30% o de baja densidad en superficie evaluada.',
      'Zonas con césped seco en forma importante.',
      'Gran cantidad de malezas.',
      'Estructuras peligrosas en medio de césped.',
      'Fuera de rango exigido en las bases técnicas.',
    ];
  }

  List<String> _getArboladoItems() {
    return [
      'Árboles y arbustos con enfermedad y/o mala conformación.',
      'Ramas menores secas, en mal estado, zonas defoliadas.',
      'Ejemplares sin tutores requiriéndolos no más de 10%.',
      'Tazas faltantes o en mal estado no más de 10%.',
      'Necesidad de podas.',
      'Faltan tutores.',
      'Falta de tazas sobre 10%.',
      'Gran cantidad de ejemplares requiriendo podas (30%).',
      'Falta protector de PVC.',
    ];
  }

  List<String> _getFloresItems() {
    return [
      'Ejemplares mal cuidados, flores, ramas o ramillas secas.',
      'Se observa basura.',
      'Terreno se escarba con dificultad, mal aspecto.',
      'Densidad menor a las exigencias de las bases.',
      'Ejemplares perdidos y descuidados, pérdida de macizo no delimitado.',
      'Terreno sucio.',
      'Terreno compacto.',
      'Densidad inferior al 30% de las exigencias de las bases.',
      'Precencia de malezas.',
    ];
  }

  List<String> _getCaminosItems() {
    return [
      'Observación de malezas, incluye CICLOVÍA.',
      'Material árido disparejo.',
      'Sin árido en zonas extensas se observa suelo compacto.',
      'Malezas en gran parte de la superficie.',
      'Material de mala calidad.',
    ];
  }

  List<String> _getInfraestructuraItems() {
    return [
      'Estructuras que requieren mantención.',
      'Necesidad de pintura en estructuras.',
      'Pérdidas de agua en el sistema de riego.',
      'Se requiere hacer mantención de más del 30% de la infraestructura.',
      'Se requiere pintar más del 30% de la infraestructura.',
      'Falta de candado o cierre de acceso al agua.',
      'Se requiere reparación de alguna estructura (ej: falta tapa de nicho).',
    ];
  }
}
