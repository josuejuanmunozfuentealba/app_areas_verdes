import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/urgencia_export_service.dart';
import '../services/urgencia_supabase_service.dart';
import '../utils/download_helper.dart';

class InspeccionUrgenciaScreen extends StatefulWidget {
  final String plazaId;
  final String nombrePlaza;

  const InspeccionUrgenciaScreen({
    Key? key,
    required this.plazaId,
    required this.nombrePlaza,
  }) : super(key: key);

  @override
  State<InspeccionUrgenciaScreen> createState() =>
      _InspeccionUrgenciaScreenState();
}

class _InspeccionUrgenciaScreenState extends State<InspeccionUrgenciaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _exportService = UrgenciaExportService();
  final _supabaseService = UrgenciaSupabaseService();

  // Controladores
  final _tituloController = TextEditingController();
  final _inspectorController = TextEditingController();

  // Campos dinámicos
  final List<TextEditingController> _camposControllers = [];
  final List<String> _camposNombres = [];

  // Observaciones dinámicas
  final List<TextEditingController> _observacionesControllers = [];

  // Fotos
  final List<Map<String, dynamic>> _fotos = [];
  final ImagePicker _picker = ImagePicker();

  // Estado
  bool _cargando = false;
  List<Map<String, dynamic>> _historial = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Inicializar con campos por defecto
    _agregarCampo('Tipo de Urgencia');
    _agregarCampo('Ubicación Específica');
    _agregarCampo('Hora de Detección');

    // Inicializar con 1 observación
    _agregarObservacion();

    _cargarHistorial();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tituloController.dispose();
    _inspectorController.dispose();
    for (var controller in _camposControllers) {
      controller.dispose();
    }
    for (var controller in _observacionesControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _agregarCampo([String nombre = 'Nuevo Campo']) {
    setState(() {
      _camposNombres.add(nombre);
      _camposControllers.add(TextEditingController());
    });
  }

  void _eliminarCampo(int index) {
    setState(() {
      _camposNombres.removeAt(index);
      _camposControllers[index].dispose();
      _camposControllers.removeAt(index);
    });
  }

  void _agregarObservacion() {
    setState(() {
      _observacionesControllers.add(TextEditingController());
    });
  }

  void _eliminarObservacion(int index) {
    setState(() {
      _observacionesControllers[index].dispose();
      _observacionesControllers.removeAt(index);
    });
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        imageQuality: 45,
      );

      if (foto != null) {
        final bytes = await foto.readAsBytes();
        setState(() {
          _fotos.add({
            'path': foto.path,
            'bytes': bytes,
            'nombre': 'Foto ${_fotos.length + 1}',
          });
        });
      }
    } catch (e) {
      _mostrarError('Error al tomar foto: $e');
    }
  }

  Future<void> _seleccionarFoto() async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 60,
      );

      if (foto != null) {
        final bytes = await foto.readAsBytes();
        setState(() {
          _fotos.add({
            'path': foto.path,
            'bytes': bytes,
            'nombre': 'Foto ${_fotos.length + 1}',
          });
        });
      }
    } catch (e) {
      _mostrarError('Error al seleccionar foto: $e');
    }
  }

  void _eliminarFoto(int index) {
    setState(() {
      _fotos.removeAt(index);
    });
  }

  bool _validar() {
    if (_tituloController.text.trim().isEmpty) {
      _mostrarError('Ingresa un título para la inspección');
      return false;
    }
    if (_inspectorController.text.trim().isEmpty) {
      _mostrarError('Ingresa el nombre del inspector');
      return false;
    }
    return true;
  }

  Future<void> _guardarEnNube() async {
    if (!_validar()) return;

    setState(() => _cargando = true);

    try {
      _mostrarProgreso('Generando PDF...');

      // Preparar datos
      final campos = <String, String>{};
      for (int i = 0; i < _camposNombres.length; i++) {
        campos[_camposNombres[i]] = _camposControllers[i].text;
      }

      final observaciones = _observacionesControllers
          .map((c) => c.text)
          .where((text) => text.trim().isNotEmpty)
          .toList();

      // Generar PDF
      final pdfBytes = await _exportService.generarPDF(
        plazaId: widget.plazaId,
        nombrePlaza: widget.nombrePlaza,
        titulo: _tituloController.text,
        inspector: _inspectorController.text,
        fechaHora: DateTime.now(),
        campos: campos,
        observaciones: observaciones,
        fotos: _fotos,
      );

      if (mounted) Navigator.of(context).pop();

      // Convertir a Word
      _mostrarProgreso('Convirtiendo a Word...');

      final docxBytes = await _exportService.generarWord(
        plazaId: widget.plazaId,
        nombrePlaza: widget.nombrePlaza,
        titulo: _tituloController.text,
        inspector: _inspectorController.text,
        fechaHora: DateTime.now(),
        campos: campos,
        observaciones: observaciones,
        fotos: _fotos,
      );

      if (mounted) Navigator.of(context).pop();

      // Subir a Supabase
      _mostrarProgreso('Subiendo a la nube...');

      final result = await _supabaseService.guardarInspeccion(
        plazaId: widget.plazaId,
        nombrePlaza: widget.nombrePlaza,
        titulo: _tituloController.text,
        inspector: _inspectorController.text,
        fechaHora: DateTime.now(),
        campos: campos,
        observaciones: observaciones,
        pdfBytes: Uint8List.fromList(pdfBytes),
        docxBytes: docxBytes != null ? Uint8List.fromList(docxBytes) : null,
      );

      if (mounted) Navigator.of(context).pop();

      if (result['success'] == true) {
        _mostrarExito('✓ Inspección guardada exitosamente');
        _limpiarFormulario();
        await _cargarHistorial();
        _tabController.animateTo(1);
      } else {
        throw Exception(result['message'] ?? 'Error al guardar');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _mostrarError('Error: $e');
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _limpiarFormulario() {
    _tituloController.clear();
    _inspectorController.clear();
    for (var controller in _camposControllers) {
      controller.clear();
    }
    for (var controller in _observacionesControllers) {
      controller.clear();
    }
    setState(() {
      _fotos.clear();
    });
  }

  Future<void> _cargarHistorial() async {
    try {
      final historial = await _supabaseService.obtenerHistorial(widget.plazaId);
      setState(() {
        _historial = historial;
      });
    } catch (e) {
      debugPrint('Error cargando historial: $e');
    }
  }

  void _mostrarProgreso(String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(mensaje),
          ],
        ),
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspección de Urgencia'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.warning), text: 'Nueva Inspección'),
            Tab(icon: Icon(Icons.history), text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFormulario(), _buildHistorial()],
      ),
    );
  }

  Widget _buildFormulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de la plaza
          Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.red.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.nombrePlaza,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Título
          TextField(
            controller: _tituloController,
            decoration: const InputDecoration(
              labelText: 'Título de la Urgencia *',
              hintText: 'Ej: Caída de árbol en área verde',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // Inspector
          TextField(
            controller: _inspectorController,
            decoration: const InputDecoration(
              labelText: 'Inspector *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 24),

          // Campos dinámicos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Campos de Información',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => _agregarCampo(),
                icon: const Icon(Icons.add_circle),
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._buildCamposDinamicos(),
          const SizedBox(height: 24),

          // Observaciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Observaciones',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: _agregarObservacion,
                icon: const Icon(Icons.add_circle),
                color: Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._buildObservaciones(),
          const SizedBox(height: 24),

          // Fotos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fotos (${_fotos.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _tomarFoto,
                    icon: const Icon(Icons.camera_alt),
                    color: Colors.blue,
                  ),
                  IconButton(
                    onPressed: _seleccionarFoto,
                    icon: const Icon(Icons.photo_library),
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_fotos.isNotEmpty) ..._buildFotos(),
          const SizedBox(height: 32),

          // Botón guardar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _cargando ? null : _guardarEnNube,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Guardar en la Nube'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCamposDinamicos() {
    return List.generate(_camposNombres.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: InputDecoration(
                  labelText: _camposNombres[index],
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) {
                  // Actualizar nombre del campo si es el label
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TextField(
                controller: _camposControllers[index],
                decoration: const InputDecoration(
                  hintText: 'Valor',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _eliminarCampo(index),
              icon: const Icon(Icons.remove_circle),
              color: Colors.red,
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildObservaciones() {
    return List.generate(_observacionesControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _observacionesControllers[index],
                decoration: InputDecoration(
                  labelText: 'Observación ${index + 1}',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),
            IconButton(
              onPressed: () => _eliminarObservacion(index),
              icon: const Icon(Icons.remove_circle),
              color: Colors.red,
            ),
          ],
        ),
      );
    });
  }

  List<Widget> _buildFotos() {
    return [
      SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _fotos.length,
          itemBuilder: (context, index) {
            final foto = _fotos[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      foto['bytes'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      onPressed: () => _eliminarFoto(index),
                      icon: const Icon(Icons.cancel),
                      color: Colors.red,
                      iconSize: 24,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ];
  }

  Widget _buildHistorial() {
    if (_historial.isEmpty) {
      return const Center(
        child: Text('No hay inspecciones de urgencia registradas'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historial.length,
      itemBuilder: (context, index) {
        final inspeccion = _historial[index];
        final pdfUrl = inspeccion['pdf_url'] as String?;
        final wordUrl = inspeccion['word_url'] as String?;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            inspeccion['titulo'] ?? 'Sin título',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${inspeccion['fecha_legible'] ?? 'Sin fecha'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Inspector: ${inspeccion['inspector'] ?? 'Sin inspector'}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 16),
                // Botones de acción
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Botón PDF
                    ElevatedButton.icon(
                      onPressed: pdfUrl != null
                          ? () => _descargarArchivo(
                              pdfUrl,
                              'urgencia_${inspeccion['id']}.pdf',
                            )
                          : null,
                      icon: const Icon(Icons.picture_as_pdf, size: 18),
                      label: const Text('PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 36),
                      ),
                    ),
                    // Botón Word
                    ElevatedButton.icon(
                      onPressed: wordUrl != null
                          ? () => _descargarArchivo(
                              wordUrl,
                              'urgencia_${inspeccion['id']}.docx',
                            )
                          : null,
                      icon: const Icon(Icons.description, size: 18),
                      label: const Text('Word'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 36),
                      ),
                    ),
                    // Botón Enviar Correo
                    ElevatedButton.icon(
                      onPressed: pdfUrl != null
                          ? () => _enviarCorreo(inspeccion)
                          : null,
                      icon: const Icon(Icons.email, size: 18),
                      label: const Text('Correo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 36),
                      ),
                    ),
                    // Botón Eliminar
                    ElevatedButton.icon(
                      onPressed: () => _confirmarEliminar(inspeccion),
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade700,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 36),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _descargarArchivo(String url, String nombreArchivo) async {
    try {
      _mostrarProgreso('Descargando...');

      await DownloadHelper.descargarArchivo(
        url: url,
        nombreArchivo: nombreArchivo,
      );

      if (mounted) Navigator.of(context).pop();
      _mostrarExito('✓ Archivo descargado');
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _mostrarError('Error al descargar: $e');
    }
  }

  Future<void> _enviarCorreo(Map<String, dynamic> inspeccion) async {
    try {
      final titulo = inspeccion['titulo'] ?? 'Sin título';
      final fecha = inspeccion['fecha_legible'] ?? 'Sin fecha';
      final inspector = inspeccion['inspector'] ?? 'Sin inspector';
      final pdfUrl = inspeccion['pdf_url'] as String?;
      final wordUrl = inspeccion['word_url'] as String?;

      final subject = Uri.encodeComponent('Inspección de Urgencia - $titulo');
      final body = Uri.encodeComponent(
        'INSPECCIÓN DE URGENCIA\n\n'
        'Plaza: ${widget.nombrePlaza}\n'
        'Título: $titulo\n'
        'Fecha: $fecha\n'
        'Inspector: $inspector\n\n'
        '📎 Archivos adjuntos:\n'
        '${pdfUrl != null ? 'PDF: $pdfUrl\n' : ''}'
        '${wordUrl != null ? 'Word: $wordUrl\n' : ''}\n\n'
        'Documento generado automáticamente por el Sistema de Gestión de Áreas Verdes.',
      );

      final emailUrl = 'mailto:?subject=$subject&body=$body';

      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
      } else {
        throw Exception('No se pudo abrir el cliente de correo');
      }
    } catch (e) {
      _mostrarError('Error al abrir correo: $e');
    }
  }

  Future<void> _confirmarEliminar(Map<String, dynamic> inspeccion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Eliminar la inspección "${inspeccion['titulo']}"?\n\n'
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await _eliminarInspeccion(inspeccion);
    }
  }

  Future<void> _eliminarInspeccion(Map<String, dynamic> inspeccion) async {
    try {
      _mostrarProgreso('Eliminando...');

      final id = inspeccion['id'] as String;
      final pdfUrl = inspeccion['pdf_url'] as String?;
      final wordUrl = inspeccion['word_url'] as String?;

      // Eliminar archivos del storage
      if (pdfUrl != null) {
        try {
          final pdfPath = _extraerPathDeUrl(pdfUrl);
          await Supabase.instance.client.storage
              .from('reportes-urgencia')
              .remove([pdfPath]);
        } catch (e) {
          debugPrint('Error eliminando PDF: $e');
        }
      }

      if (wordUrl != null) {
        try {
          final wordPath = _extraerPathDeUrl(wordUrl);
          await Supabase.instance.client.storage
              .from('reportes-urgencia')
              .remove([wordPath]);
        } catch (e) {
          debugPrint('Error eliminando Word: $e');
        }
      }

      // Eliminar registro de base de datos
      await Supabase.instance.client
          .from('inspecciones_urgencia')
          .delete()
          .eq('id', id);

      if (mounted) Navigator.of(context).pop();

      _mostrarExito('✓ Inspección eliminada');
      await _cargarHistorial();
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _mostrarError('Error al eliminar: $e');
    }
  }

  String _extraerPathDeUrl(String url) {
    // Extraer path del archivo desde URL pública de Supabase
    // Ejemplo: https://xxx.supabase.co/storage/v1/object/public/reportes-urgencia/urgencia_123.pdf
    // Retorna: urgencia_123.pdf
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    if (segments.length >= 5) {
      return segments.sublist(5).join('/');
    }
    return url.split('/').last;
  }
}
