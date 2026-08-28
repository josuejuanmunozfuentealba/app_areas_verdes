import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:typed_data';
import '../services/catastro_export_service.dart';
import '../services/catastro_supabase_service.dart';
import '../services/email_service.dart';
import '../utils/download_helper.dart';

class CatastroInmueblesScreen extends StatefulWidget {
  final String plazaId;
  final String nombrePlaza;

  const CatastroInmueblesScreen({
    super.key,
    required this.plazaId,
    required this.nombrePlaza,
  });

  @override
  State<CatastroInmueblesScreen> createState() =>
      _CatastroInmueblesScreenState();
}

class _CatastroInmueblesScreenState extends State<CatastroInmueblesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Servicios
  final _exportService = CatastroExportService();
  final _supabaseService = CatastroSupabaseService();

  // Datos del formulario
  final TextEditingController _inspectorController = TextEditingController();
  final Map<String, String?> _evaluaciones = {};
  final Map<String, TextEditingController> _observaciones = {};
  final List<Map<String, dynamic>> _fotos = [];

  // Historial
  List<Map<String, dynamic>> _historial = [];
  bool _cargandoHistorial = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Inicializar controladores de observaciones
    for (final criterio in CatastroExportService.criteriosOficiales) {
      _observaciones[criterio] = TextEditingController();
    }

    // Cargar historial al cambiar a la pestaña 2
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_cargandoHistorial) {
        _cargarHistorial();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inspectorController.dispose();
    for (var controller in _observaciones.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Catastro de Inmuebles',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Información de la plaza
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              color: const Color(0xFFF1F8E9),
              child: Row(
                children: [
                  const Icon(Icons.park, color: Color(0xFF2E7D32), size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.nombrePlaza,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ID: ${widget.plazaId}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF558B2F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Pestañas
            Container(
              color: const Color(0xFFF5F5F5),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF2E7D32),
                unselectedLabelColor: const Color(0xFF757575),
                indicatorColor: const Color(0xFF2E7D32),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.add_task), text: 'NUEVO CATASTRO'),
                  Tab(icon: Icon(Icons.history), text: 'HISTORIAL NUBE'),
                ],
              ),
            ),

            // Contenido de las pestañas
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildNuevoCatastro(), _buildHistorial()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // PESTAÑA 1: NUEVO CATASTRO
  // ============================================================================

  Widget _buildNuevoCatastro() {
    final isMobile = MediaQuery.of(context).size.width < 650;
    final padding = isMobile ? 12.0 : 16.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo Inspector
          TextField(
            controller: _inspectorController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Inspector',
              prefixIcon: Icon(Icons.person, color: Color(0xFF2E7D32)),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // Tabla de evaluación
          const Text(
            'EVALUACIÓN DE CRITERIOS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),

          ...CatastroExportService.criteriosOficiales.map((criterio) {
            return _buildFilaEvaluacion(criterio);
          }),

          const SizedBox(height: 24),

          // Sección de fotos
          _buildSeccionFotos(),

          const SizedBox(height: 24),

          // Botones de acción
          _buildBotonesAccion(),
        ],
      ),
    );
  }

  Widget _buildFilaEvaluacion(String criterio) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              criterio,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 12),

            // SegmentedButton en lugar de Radio Buttons
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'Bueno',
                    label: Text('Bueno', style: TextStyle(fontSize: 12)),
                    icon: Icon(Icons.check_circle, size: 16),
                  ),
                  ButtonSegment<String>(
                    value: 'Regular',
                    label: Text('Regular', style: TextStyle(fontSize: 12)),
                    icon: Icon(Icons.warning, size: 16),
                  ),
                  ButtonSegment<String>(
                    value: 'Malo',
                    label: Text('Malo', style: TextStyle(fontSize: 12)),
                    icon: Icon(Icons.cancel, size: 16),
                  ),
                ],
                selected: _evaluaciones[criterio] != null
                    ? {_evaluaciones[criterio]!}
                    : <String>{},
                onSelectionChanged: (Set<String> newSelection) {
                  if (newSelection.isNotEmpty) {
                    setState(() {
                      _evaluaciones[criterio] = newSelection.first;
                    });
                  }
                },
                style: ButtonStyle(visualDensity: VisualDensity.compact),
              ),
            ),
            const SizedBox(height: 12),

            // Campo de observaciones
            TextField(
              controller: _observaciones[criterio],
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                hintText: 'Añade detalles si es necesario...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionFotos() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.photo_camera,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'EVIDENCIA FOTOGRÁFICA',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _agregarFotos,
                  icon: const Icon(Icons.add_photo_alternate, size: 16),
                  label: const Text('Agregar', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_fotos.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No hay fotos agregadas',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              // Contenedor con altura dinámica para fotos
              ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 180,
                  maxHeight:
                      MediaQuery.of(context).size.height *
                      0.4, // Máximo 40% de la pantalla
                ),
                child: SingleChildScrollView(
                  child: SizedBox(
                    height:
                        220, // Altura aumentada para incluir observaciones completas
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _fotos.length,
                      itemBuilder: (context, index) {
                        final fotoData = _fotos[index];
                        final XFile archivo = fotoData['archivo'] as XFile;
                        final String notaActual =
                            fotoData['nota'] as String? ?? '';

                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 160,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: kIsWeb
                                        ? Image.network(
                                            archivo.path,
                                            width: 160,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(archivo.path),
                                            width: 160,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _eliminarFoto(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Campo de observación con scroll interno si es necesario
                              Expanded(
                                child: TextFormField(
                                  initialValue: notaActual,
                                  style: const TextStyle(fontSize: 11),
                                  decoration: const InputDecoration(
                                    hintText: 'Nota de la foto...',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3, // Aumentado a 3 líneas
                                  onChanged: (value) {
                                    _fotos[index]['nota'] = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonesAccion() {
    return Column(
      children: [
        // Botón descargar PDF
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _descargarPDF,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Descargar PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botón descargar Word
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _descargarWord,
            icon: const Icon(Icons.description),
            label: const Text('Descargar Word'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Botón guardar en la nube
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _guardarEnNube,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Guardar y Subir a la Nube'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // PESTAÑA 2: HISTORIAL
  // ============================================================================

  Widget _buildHistorial() {
    if (_cargandoHistorial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historial.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No hay catastros en la nube',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'Plaza: ${widget.nombrePlaza}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargarHistorial,
              icon: const Icon(Icons.refresh),
              label: const Text('Recargar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargarHistorial,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _historial.length,
        itemBuilder: (context, index) {
          final catastro = _historial[index];
          final fechaLegible = catastro['fecha_legible'] as String;
          final estadoGeneral = catastro['estado_general'] as String;
          final inspector = catastro['inspector'] as String;
          final pdfUrl = catastro['pdf_url'] as String;
          final wordUrl = catastro['word_url'] as String;
          final correoEnviado = catastro['correo_enviado'] as bool? ?? false;
          final registroId = catastro['id']?.toString();

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con fecha y badge de estado de correo
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getColorEstado(estadoGeneral),
                        child: const Icon(
                          Icons.assignment,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🕒 $fechaLegible',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Badge de estado de correo
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: correoEnviado
                                    ? const Color(0xFFC8E6C9)
                                    : const Color(0xFFFFE0B2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    correoEnviado
                                        ? Icons.check_circle
                                        : Icons.access_time,
                                    size: 14,
                                    color: correoEnviado
                                        ? const Color(0xFF2E7D32)
                                        : const Color(0xFFF57C00),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    correoEnviado
                                        ? 'Correo Enviado'
                                        : 'Guardado en Nube',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: correoEnviado
                                          ? const Color(0xFF2E7D32)
                                          : const Color(0xFFF57C00),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Estado: $estadoGeneral'),
                  Text('Inspector: $inspector'),
                  const SizedBox(height: 12),
                  // Botones de descarga
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _descargarDesdeUrl(pdfUrl, 'PDF'),
                          icon: const Icon(Icons.picture_as_pdf, size: 16),
                          label: const Text(
                            'PDF',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD32F2F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _descargarDesdeUrl(wordUrl, 'Word'),
                          icon: const Icon(Icons.description, size: 16),
                          label: const Text(
                            'Word',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Botones: Enviar y Eliminar
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: registroId != null
                              ? () => _enviarAlertaInmediata(
                                  registroId: registroId,
                                  catastro: catastro,
                                  pdfUrl: pdfUrl,
                                  wordUrl: wordUrl,
                                )
                              : null,
                          icon: Icon(
                            correoEnviado ? Icons.refresh : Icons.send,
                            size: 16,
                          ),
                          label: Text(
                            correoEnviado ? 'Reenviar' : 'Enviar',
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: correoEnviado
                                ? const Color(0xFFF57C00)
                                : const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: registroId != null
                            ? () => _confirmarEliminar(
                                registroId: registroId,
                                nombrePlaza: catastro['nombre_plaza'] as String,
                              )
                            : null,
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text(
                          'Eliminar',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================================
  // LÓGICA DE FUNCIONES
  // ============================================================================

  Future<void> _agregarFotos() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> imagenes = await picker.pickMultiImage(
        imageQuality: 85,
      );

      if (imagenes.isNotEmpty) {
        setState(() {
          for (var imagen in imagenes) {
            _fotos.add({'archivo': imagen, 'nota': ''});
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ ${imagenes.length} foto(s) agregada(s)'),
              backgroundColor: const Color(0xFF2E7D32),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _eliminarFoto(int index) {
    setState(() {
      _fotos.removeAt(index);
    });
  }

  Future<void> _descargarPDF() async {
    if (!_validarFormulario()) return;

    try {
      _mostrarProgreso('Generando PDF...');

      final pdfBytes = await _exportService.generarPDF(
        plazaId: widget.plazaId,
        nombrePlaza: widget.nombrePlaza,
        inspector: _inspectorController.text,
        fechaHora: DateTime.now(),
        evaluaciones: _evaluaciones,
        observaciones: _observaciones.map((k, v) => MapEntry(k, v.text)),
        fotos: _fotos,
      );

      if (mounted) Navigator.of(context).pop();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nombreArchivo = 'catastro_${widget.plazaId}_$timestamp.pdf';

      // Convertir List<int> a Uint8List
      final pdfUint8 = Uint8List.fromList(pdfBytes);
      downloadFile(pdfUint8, nombreArchivo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ PDF descargado exitosamente'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _descargarWord() async {
    if (!_validarFormulario()) return;

    try {
      _mostrarProgreso(
        'Generando Word desde PDF...\n'
        '(Conversión CloudConvert: 5-15 segundos)',
      );

      final wordBytes = await _exportService.generarWord(
        plazaId: widget.plazaId,
        nombrePlaza: widget.nombrePlaza,
        inspector: _inspectorController.text,
        fechaHora: DateTime.now(),
        evaluaciones: _evaluaciones,
        observaciones: _observaciones.map((k, v) => MapEntry(k, v.text)),
        fotos: _fotos,
      );

      if (mounted) Navigator.of(context).pop();

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nombreArchivo = 'catastro_${widget.plazaId}_$timestamp.docx';

      // Convertir List<int> a Uint8List
      final wordUint8 = Uint8List.fromList(wordBytes);
      downloadFile(wordUint8, nombreArchivo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Word descargado exitosamente'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al generar Word: $e\n\n'
              'Nota: La conversión a Word requiere conexión a internet.\n'
              'Puedes descargar el PDF que funciona sin conexión.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'Descargar PDF',
              textColor: Colors.white,
              onPressed: _descargarPDF,
            ),
          ),
        );
      }
    }
  }

  Future<void> _guardarEnNube() async {
    if (!_validarFormulario()) return;

    try {
      // Mensaje de inicio con feedback detallado
      _mostrarProgreso('Generando PDF...');

      final fechaHora = DateTime.now();

      // PASO 1: Generar PDF (documento maestro)
      final pdfBytes = await _exportService.generarPDF(
        plazaId: widget.plazaId,
        nombrePlaza: widget.nombrePlaza,
        inspector: _inspectorController.text,
        fechaHora: fechaHora,
        evaluaciones: _evaluaciones,
        observaciones: _observaciones.map((k, v) => MapEntry(k, v.text)),
        fotos: _fotos,
      );

      if (mounted) Navigator.of(context).pop();

      // PASO 2: Convertir PDF a DOCX (con timeout corto si servicio no disponible)
      _mostrarProgreso(
        'Convirtiendo PDF a Word...\n'
        '(Esto puede tardar 5-15 segundos)',
      );

      Uint8List? docxBytes;
      try {
        // Timeout de 90 segundos para PDFs grandes con muchas fotos
        docxBytes = await _exportService
            .generarWordDesdeConversion(
              plazaId: widget.plazaId,
              nombrePlaza: widget.nombrePlaza,
              inspector: _inspectorController.text,
              fechaHora: fechaHora,
              evaluaciones: _evaluaciones,
              observaciones: _observaciones.map((k, v) => MapEntry(k, v.text)),
              fotos: _fotos,
            )
            .timeout(
              const Duration(seconds: 90), // ← Aumentado de 15s a 90s
              onTimeout: () {
                debugPrint(
                  '[Guardar] ⏱️ Timeout conversión Word, continuando sin DOCX',
                );
                return null;
              },
            );
      } catch (e) {
        debugPrint(
          '[Guardar] ❌ Error conversión Word: $e, continuando sin DOCX',
        );
        docxBytes = null;
      }

      if (mounted) Navigator.of(context).pop();

      // PASO 3: Subir archivos a Supabase
      // Si conversión Word falló (docxBytes == null), solo se sube PDF
      _mostrarProgreso('Subiendo archivos a la nube...');

      final result = await _supabaseService.guardarCatastroConDocxConvertido(
        plazaId: widget.plazaId,
        nombrePlaza: widget.nombrePlaza,
        inspector: _inspectorController.text,
        fechaHora: fechaHora,
        evaluaciones: _evaluaciones,
        observaciones: _observaciones.map((k, v) => MapEntry(k, v.text)),
        pdfBytes: Uint8List.fromList(pdfBytes),
        docxBytes: docxBytes, // null si falló, Uint8List si exitoso
      );

      if (mounted) Navigator.of(context).pop();

      if (result['success'] == true) {
        _limpiarFormulario();
        await _cargarHistorial();

        if (mounted) {
          // Mensaje diferente según si el Word está disponible o no
          final mensaje = docxBytes == null
              ? '✓ Guardado exitosamente (solo PDF)\n'
                    '⚠️ Word no disponible sin conexión'
              : '✓ ${result['message']}';

          final backgroundColor = docxBytes == null
              ? Colors.orange.shade700
              : const Color(0xFF2E7D32);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(mensaje),
              backgroundColor: backgroundColor,
              duration: const Duration(seconds: 4),
            ),
          );

          // Cambiar a la pestaña de historial
          _tabController.animateTo(1);
        }
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _cargandoHistorial = true;
    });

    try {
      final historial = await _supabaseService.obtenerHistorial(widget.plazaId);
      setState(() {
        _historial = historial;
        _cargandoHistorial = false;
      });
    } catch (e) {
      setState(() {
        _cargandoHistorial = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar historial: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _descargarDesdeUrl(String url, String tipo) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('No se pudo abrir la URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar $tipo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _validarFormulario() {
    if (_inspectorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠ Ingrese el nombre del inspector'),
          backgroundColor: Color(0xFFF57C00),
        ),
      );
      return false;
    }

    final evaluacionesCompletas = _evaluaciones.values
        .where((v) => v != null && v.isNotEmpty)
        .length;

    if (evaluacionesCompletas < 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠ Complete todas las evaluaciones (7 criterios)'),
          backgroundColor: Color(0xFFF57C00),
        ),
      );
      return false;
    }

    return true;
  }

  void _limpiarFormulario() {
    _inspectorController.clear();
    _evaluaciones.clear();
    for (var controller in _observaciones.values) {
      controller.clear();
    }
    _fotos.clear();
    setState(() {});
  }

  void _mostrarProgreso(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(mensaje),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorEstado(String estado) {
    switch (estado) {
      case 'Bueno':
        return const Color(0xFF2E7D32);
      case 'Regular':
        return const Color(0xFFF57C00);
      case 'Malo':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  /// Envía alerta inmediata al jefe con los archivos adjuntos
  Future<void> _enviarAlertaInmediata({
    required String registroId,
    required Map<String, dynamic> catastro,
    required String pdfUrl,
    required String wordUrl,
  }) async {
    try {
      _mostrarProgreso('Enviando correo a Felipe Lagos Bastias...');

      // Enviar correo formal usando las URLs de Supabase directamente
      // Esto evita el error "Request Entity Too Large"
      final success = await EmailService.enviarInformeFormal(
        nombreInspector: catastro['inspector'] as String,
        nombrePlaza: catastro['nombre_plaza'] as String,
        estadoGeneral: catastro['estado_general'] as String,
        fecha: catastro['fecha_legible'] as String,
        tipoInforme: 'catastro',
        pdfUrl: pdfUrl,
        wordUrl: wordUrl,
        registroId: registroId,
      );

      if (mounted) Navigator.of(context).pop();

      if (success) {
        // Actualizar estado en Supabase
        await _supabaseService.marcarCorreoEnviado(registroId: registroId);

        // Recargar historial
        await _cargarHistorial();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Correo enviado exitosamente a Felipe Lagos'),
              backgroundColor: Color(0xFF2E7D32),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('Error al enviar el correo');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al enviar correo: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Confirma antes de eliminar un registro
  Future<void> _confirmarEliminar({
    required String registroId,
    required String nombrePlaza,
  }) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Color(0xFFD32F2F)),
            SizedBox(width: 8),
            Text('Confirmar Eliminación'),
          ],
        ),
        content: Text(
          '¿Estás seguro de eliminar el catastro de "$nombrePlaza"?\n\n'
          'Esta acción eliminará:\n'
          '• El registro de la base de datos\n'
          '• Los archivos PDF y Word\n\n'
          '⚠️ Esta acción no se puede deshacer.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _eliminarCatastro(registroId);
    }
  }

  /// Elimina un catastro de Supabase
  Future<void> _eliminarCatastro(String registroId) async {
    try {
      _mostrarProgreso('Eliminando catastro...');

      final result = await _supabaseService.eliminarCatastro(registroId);

      if (mounted) Navigator.of(context).pop();

      if (result['success'] == true) {
        // Recargar historial
        await _cargarHistorial();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✓ ${result['message']}'),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception(result['message']);
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}
