import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import '../services/catastro_export_service.dart';
import '../services/catastro_supabase_service.dart';
import '../services/email_service.dart';
import '../utils/download_helper.dart';
import '../utils/spell_checker.dart';
import '../widgets/camera_picker_web.dart';

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

  // 🔥 Cache de thumbnails para reducir uso de memoria
  final Map<String, Uint8List> _thumbnailCache = {};

  // Historial
  List<Map<String, dynamic>> _historial = [];
  bool _cargandoHistorial = false;

  // Autoguardado condicional (solo si hubo cambios)
  Timer? _autoguardadoTimer;
  bool _huboCambios = false; // ✅ Rastrea si hubo cambios para ahorrar batería

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

    // Recuperar datos guardados (si existen)
    _recuperarDatosGuardados();

    // ✅ AUTOGUARDADO INTELIGENTE: Solo guarda si hubo cambios (ahorra batería)
    _autoguardadoTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && _huboCambios) {
        _guardarDatosLocalmente();
        _huboCambios = false; // Reset flag después de guardar
      }
    });

    // ✅ Listener para detectar cambios en el inspector
    _inspectorController.addListener(() {
      _huboCambios = true;
    });

    // ✅ Listener para detectar cambios en observaciones
    for (var controller in _observaciones.values) {
      controller.addListener(() {
        _huboCambios = true;
      });
    }
  }

  @override
  void dispose() {
    _autoguardadoTimer?.cancel();
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
            // Activar autocorrector
            autocorrect: true,
            enableSuggestions: true,
            keyboardType: TextInputType.name,
            textCapitalization:
                TextCapitalization.words, // Capitalizar cada palabra
          ),
          const SizedBox(height: 20),

          // Aviso sobre ortografía
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '⚠️ Revisa bien la ortografía antes de generar el documento',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

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

            // SegmentedButton con emptySelectionAllowed para evitar crash
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                emptySelectionAllowed:
                    true, // ✅ FIX: permite iniciar sin selección
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
                      _huboCambios = true; // ✅ Marcar cambio para autoguardado
                    });
                  }
                },
                style: ButtonStyle(visualDensity: VisualDensity.compact),
              ),
            ),
            const SizedBox(height: 12),

            // Campo de observaciones con contador visible
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _observaciones[criterio],
                  decoration: const InputDecoration(
                    labelText: 'Observaciones (opcional)',
                    hintText: 'Añade detalles si es necesario...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: null, // Permite múltiples líneas dinámicas
                  minLines: 3, // Mínimo 3 líneas visibles
                  maxLength: 500, // Límite de 500 caracteres
                  keyboardType: TextInputType.multiline, // Habilita Enter
                  textInputAction:
                      TextInputAction.newline, // Botón Enter en teclado
                  style: const TextStyle(fontSize: 12),
                  onChanged: (_) => setState(() {}), // Actualizar contador
                  // Activar autocorrector
                  autocorrect: true,
                  enableSuggestions: true,
                  textCapitalization: TextCapitalization.sentences,
                ),
                // Contador de caracteres
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: ValueListenableBuilder(
                    valueListenable: _observaciones[criterio]!,
                    builder: (context, value, child) {
                      final length = value.text.length;
                      final color = length > 450
                          ? Colors.red
                          : (length > 400 ? Colors.orange : Colors.grey);
                      return Text(
                        '$length/500 caracteres',
                        style: TextStyle(
                          fontSize: 11,
                          color: color,
                          fontWeight: length > 400
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ),
              ],
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
                // En web móvil, mostrar 2 botones separados
                if (kIsWeb)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _tomarFotoConCamara,
                        icon: const Icon(Icons.camera_alt, size: 16),
                        label: const Text(
                          'Cámara',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _agregarFotos,
                        icon: const Icon(Icons.photo_library, size: 16),
                        label: const Text(
                          'Galería',
                          style: TextStyle(fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  // En app nativa, un solo botón que abre modal
                  ElevatedButton.icon(
                    onPressed: _agregarFotos,
                    icon: const Icon(Icons.add_photo_alternate, size: 16),
                    label: const Text(
                      'Agregar',
                      style: TextStyle(fontSize: 13),
                    ),
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
                                    child: FutureBuilder<Uint8List>(
                                      future: _obtenerThumbnail(archivo),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Image.memory(
                                            snapshot.data!,
                                            width: 160,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          );
                                        }

                                        // Mientras carga, mostrar placeholder
                                        return Container(
                                          width: 160,
                                          height: 100,
                                          color: Colors.grey[300],
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _eliminarFoto(index),
                                      child: Container(
                                        // ✅ Tamaño táctil mínimo 44px para móviles
                                        width: 44,
                                        height: 44,
                                        alignment: Alignment.center,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              // Campo de observación con contador de caracteres
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      initialValue: notaActual,
                                      style: const TextStyle(fontSize: 11),
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Nota de la foto (máx. 300 caracteres)...',
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                        counterText:
                                            '', // Ocultar contador por defecto
                                      ),
                                      maxLines:
                                          null, // Permite múltiples líneas dinámicas
                                      minLines: 2, // Mínimo 2 líneas
                                      maxLength:
                                          300, // Límite de 300 caracteres
                                      keyboardType: TextInputType
                                          .multiline, // Habilita Enter
                                      textInputAction: TextInputAction.newline,
                                      onChanged: (value) {
                                        _fotos[index]['nota'] = value;
                                      },
                                      // Activar autocorrector
                                      autocorrect: true,
                                      enableSuggestions: true,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                    ),
                                    // Indicador visual simple
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 2,
                                        left: 2,
                                      ),
                                      child: Text(
                                        '${notaActual.length}/300',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: notaActual.length > 270
                                              ? Colors.red
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
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
        // Botón revisar ortografía (NUEVO)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _revisarOrtografia,
            icon: const Icon(Icons.spellcheck, size: 20),
            label: const Text('🔍 Revisar Ortografía'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange.shade700,
              side: BorderSide(color: Colors.orange.shade300, width: 2),
              padding: const EdgeInsets.all(14),
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ),
        const SizedBox(height: 12),

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _cargarHistorial,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recargar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _subirPdfManual,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Subir PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
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
          // 🔥 CASTING MUY DEFENSIVO: Usa ?.toString() para prevenir cualquier error
          final fechaLegible =
              catastro['fecha_legible']?.toString() ?? 'Sin fecha';
          final estadoGeneral =
              catastro['estado_general']?.toString() ?? 'Sin evaluar';
          final inspector =
              catastro['inspector']?.toString() ?? 'Sin inspector';
          final pdfUrl = catastro['pdf_url']?.toString() ?? '';
          final wordUrl = catastro['word_url']?.toString() ?? '';
          final correoEnviado = catastro['correo_enviado'] as bool? ?? false;
          final registroId = catastro['id']?.toString() ?? '';

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
                          onPressed: () => _descargarWordDesdeHistorial(
                            catastro: catastro,
                            wordUrl: wordUrl,
                            pdfUrl: pdfUrl,
                          ),
                          icon: const Icon(Icons.description, size: 16),
                          label: Text(
                            wordUrl != null && wordUrl.isNotEmpty
                                ? 'Word'
                                : 'Convertir',
                            style: const TextStyle(fontSize: 12),
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

  Future<void> _tomarFotoConCamara() async {
    try {
      // Usar HTML nativo para forzar cámara en web
      final XFile? foto = await CameraPickerWeb.pickImageFromCamera();

      if (foto != null) {
        setState(() {
          _fotos.add({'archivo': foto, 'nota': ''});
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Foto capturada'),
              backgroundColor: Color(0xFF2E7D32),
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
      debugPrint('[Cámara] Error: $e');
    }
  }

  // ============================================================================
  // GESTIÓN DE IMÁGENES OPTIMIZADA (reduce memoria)
  // ============================================================================

  /// Obtiene un thumbnail optimizado de la imagen (cachea para no procesar múltiples veces)
  Future<Uint8List> _obtenerThumbnail(XFile archivo) async {
    // 🔥 FIX: Usar hash único en vez de path para evitar colisiones
    // Problema: XFile.fromData() puede tener paths genéricos idénticos
    final bytesOriginales = await archivo.readAsBytes();
    final uniqueKey =
        '${archivo.name}_${bytesOriginales.length}_${bytesOriginales.hashCode}';

    // Si ya está en caché, retornar inmediatamente
    if (_thumbnailCache.containsKey(uniqueKey)) {
      return _thumbnailCache[uniqueKey]!;
    }

    // ✅ SIMPLE: Usar bytes directamente (sin comprimir, ImagePicker ya lo hizo)
    // Guardar en caché
    _thumbnailCache[uniqueKey] = bytesOriginales;

    return bytesOriginales;
  }

  /// Limpia el caché de thumbnails (libera memoria)
  void _limpiarCacheThumbnails() {
    _thumbnailCache.clear();
    debugPrint('[Memoria] 🗑️ Caché de thumbnails limpiado');
  }

  // ============================================================================
  // GESTIÓN DE FOTOS
  // ============================================================================

  // ============================================================================
  // SPINNER DE PROGRESO PARA CARGA DE FOTOS
  // ============================================================================

  Future<void> _mostrarProgresoCarga(
    List<XFile> imagenes,
    String fuente,
  ) async {
    if (imagenes.isEmpty) return;

    // Mostrar diálogo de progreso
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Preparando fotos...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '0%',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '0 de ${imagenes.length}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    // 🔥 PROCESAR FOTOS CON PRECARGA REAL EN MEMORIA
    int procesadas = 0;
    for (var imagen in imagenes) {
      try {
        debugPrint(
          '[Carga Fotos] 📷 Procesando foto ${procesadas + 1}/${imagenes.length}...',
        );

        // ✅ PASO 1: Leer bytes de la imagen
        final Uint8List bytes = await imagen.readAsBytes();
        final sizeKB = (bytes.length / 1024).round();
        debugPrint('[Carga Fotos] 📦 Tamaño: $sizeKB KB');

        // ✅ PASO 2: Agregar al listado INMEDIATAMENTE (sin decodificar para evitar crash)
        setState(() {
          _fotos.add({'archivo': imagen, 'nota': ''});
        });

        procesadas++;
        final porcentaje = ((procesadas / imagenes.length) * 100).round();

        // ✅ PASO 3: Actualizar progreso en el diálogo
        if (mounted) {
          Navigator.of(context).pop();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dialogContext) {
              return WillPopScope(
                onWillPop: () async => false,
                child: AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: procesadas / imagenes.length,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Cargando fotos...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$porcentaje%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$procesadas de ${imagenes.length}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        // ✅ PASO 4: Pausa breve (300ms por foto) para dar tiempo al sistema
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        debugPrint('[Carga Fotos] ❌ Error procesando imagen: $e');
        // Continuar con la siguiente aunque falle
      }
    }

    // Cerrar diálogo de progreso
    if (mounted) {
      Navigator.of(context).pop();

      // Marcar cambios y mostrar confirmación
      setState(() {
        _huboCambios = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${imagenes.length} foto(s) listas para usar'),
          backgroundColor: const Color(0xFF2E7D32),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    debugPrint(
      '[Carga Fotos] ✅ $procesadas foto(s) procesadas y listas desde $fuente',
    );
  }

  // ============================================================================
  // AGREGAR FOTOS CON SPINNER DE PROGRESO
  // ============================================================================

  Future<void> _agregarFotos() async {
    try {
      final ImagePicker picker = ImagePicker();

      // En móviles, mostrar opciones: Cámara o Galería
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        final opcion = await showModalBottomSheet<String>(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFF2E7D32),
                  ),
                  title: const Text('Tomar foto con cámara'),
                  onTap: () => Navigator.pop(context, 'camera'),
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: Color(0xFF1565C0),
                  ),
                  title: const Text('Seleccionar de galería'),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                ListTile(
                  leading: const Icon(Icons.cancel, color: Colors.grey),
                  title: const Text('Cancelar'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );

        if (opcion == null) return;

        if (opcion == 'camera') {
          // ✅ Tomar foto con la cámara (MUY COMPRIMIDO para evitar crash)
          final XFile? foto = await picker.pickImage(
            source: ImageSource.camera,
            preferredCameraDevice: CameraDevice.rear,
            imageQuality: 45, // 🔥 MÁS BAJO para no crashear móvil
            maxWidth: 800, // 🔥 REDUCIDO para menos RAM
            maxHeight: 800,
          );

          if (foto != null) {
            // Procesar con spinner (aunque es 1 sola foto)
            await _mostrarProgresoCarga([foto], 'cámara');
          }
        } else if (opcion == 'gallery') {
          // ✅ Seleccionar múltiples de galería (MUY COMPRIMIDO)
          final List<XFile> imagenes = await picker.pickMultiImage(
            imageQuality: 45, // 🔥 MÁS BAJO para no crashear
            maxWidth: 800, // 🔥 REDUCIDO para menos RAM
            maxHeight: 800,
          );

          if (imagenes.isNotEmpty) {
            // ✅ Procesar con spinner y porcentaje
            await _mostrarProgresoCarga(imagenes, 'galería');
          }
        }
      } else {
        // En web, usar el selector estándar con calidad moderada
        final List<XFile> imagenes = await picker.pickMultiImage(
          imageQuality: 60, // Web: calidad moderada (reducido de 65)
        );

        if (imagenes.isNotEmpty) {
          // ✅ Procesar con spinner y porcentaje
          await _mostrarProgresoCarga(imagenes, 'web');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al agregar fotos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('[Agregar Fotos] Error: $e');
    }
  }

  // ============================================================================
  // REVISIÓN ORTOGRÁFICA
  // ============================================================================

  Future<void> _revisarOrtografia() async {
    // Revisar todos los campos
    final resultados = SpellChecker.revisarFormulario(
      observaciones: _observaciones.map((k, v) => MapEntry(k, v.text)),
      fotos: _fotos,
    );

    if (resultados.isEmpty) {
      // No hay palabras sospechosas
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 28),
                SizedBox(width: 12),
                Text('✅ Todo bien'),
              ],
            ),
            content: const Text(
              'No se detectaron palabras sospechosas.\n\nEl texto parece estar correcto.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    } else {
      // Mostrar palabras sospechosas
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(child: Text('⚠️ Palabras sospechosas')),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Revisa estas palabras antes de generar el documento:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  ...resultados.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: entry.value.map((palabra) {
                              final sugerencia = SpellChecker.sugerirCorreccion(
                                palabra,
                              );
                              return Chip(
                                label: Text(
                                  sugerencia != null
                                      ? '$palabra → $sugerencia?'
                                      : palabra,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.orange.shade100,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Revisar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ignorar y continuar'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _eliminarFoto(int index) {
    setState(() {
      _fotos.removeAt(index);
      _huboCambios = true; // ✅ Marcar cambio para autoguardado
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

    // 🔥 PASO 1: GUARDAR LOCALMENTE PRIMERO (seguridad)
    await _guardarDatosLocalmente();
    debugPrint('[Guardar] ✅ Backup local creado');

    // 🔥 PASO 2: CONTINUAR CON LA SUBIDA (timeouts agresivos en cada paso)
    try {
      // Mensaje de inicio con feedback detallado
      _mostrarProgreso('Generando PDF...');

      final fechaHora = DateTime.now();

      // PASO 1: Generar PDF (documento maestro) - timeout 30s
      final pdfBytes = await _exportService
          .generarPDF(
            plazaId: widget.plazaId,
            nombrePlaza: widget.nombrePlaza,
            inspector: _inspectorController.text,
            fechaHora: fechaHora,
            evaluaciones: _evaluaciones,
            observaciones: _observaciones.map((k, v) => MapEntry(k, v.text)),
            fotos: _fotos,
          )
          .timeout(
            const Duration(seconds: 120),
            onTimeout: () => throw Exception('Timeout generando PDF (120s)'),
          );

      if (mounted) Navigator.of(context).pop();

      // PASO 2: Convertir PDF a DOCX con reintentos
      _mostrarProgreso('Convirtiendo a Word...');

      Uint8List? docxBytes;
      int intentosWord = 0;
      const maxIntentosWord = 2;

      while (intentosWord < maxIntentosWord && docxBytes == null) {
        intentosWord++;
        debugPrint('[Guardar] 🔄 Intento Word $intentosWord/$maxIntentosWord');

        try {
          docxBytes = await _exportService
              .generarWordDesdeConversion(
                plazaId: widget.plazaId,
                nombrePlaza: widget.nombrePlaza,
                inspector: _inspectorController.text,
                fechaHora: fechaHora,
                evaluaciones: _evaluaciones,
                observaciones: _observaciones.map(
                  (k, v) => MapEntry(k, v.text),
                ),
                fotos: _fotos,
              )
              .timeout(
                const Duration(seconds: 90), // Timeout generoso para móvil
                onTimeout: () {
                  debugPrint(
                    '[Guardar] ⏱️ Timeout Word (90s) intento $intentosWord',
                  );
                  return null;
                },
              );

          if (docxBytes != null) {
            debugPrint('[Guardar] ✅ Word generado en intento $intentosWord');
          }
        } catch (e) {
          debugPrint('[Guardar] ❌ Error Word intento $intentosWord: $e');
          if (intentosWord < maxIntentosWord) {
            await Future.delayed(const Duration(seconds: 3));
          }
        }
      }

      if (docxBytes == null) {
        debugPrint(
          '[Guardar] ⚠️ Word no disponible después de $maxIntentosWord intentos',
        );
      }

      if (mounted) Navigator.of(context).pop();

      // PASO 3: Subir archivos a Supabase con reintentos
      _mostrarProgreso('Subiendo a la nube...');

      Map<String, dynamic>? result;
      int intentosSubida = 0;
      const maxIntentosSubida = 3;

      while (intentosSubida < maxIntentosSubida &&
          (result == null || result['success'] != true)) {
        intentosSubida++;
        debugPrint(
          '[Guardar] 🔄 Intento subida $intentosSubida/$maxIntentosSubida',
        );

        try {
          result = await _supabaseService
              .guardarCatastroConDocxConvertido(
                plazaId: widget.plazaId,
                nombrePlaza: widget.nombrePlaza,
                inspector: _inspectorController.text,
                fechaHora: fechaHora,
                evaluaciones: _evaluaciones,
                observaciones: _observaciones.map(
                  (k, v) => MapEntry(k, v.text),
                ),
                pdfBytes: Uint8List.fromList(pdfBytes),
                docxBytes: docxBytes,
              )
              .timeout(
                const Duration(seconds: 60), // Timeout generoso
                onTimeout: () {
                  debugPrint(
                    '[Guardar] ⏱️ Timeout subida (60s) intento $intentosSubida',
                  );
                  return {
                    'success': false,
                    'message':
                        'Timeout subiendo a nube (intento $intentosSubida)',
                  };
                },
              );

          if (result['success'] == true) {
            debugPrint('[Guardar] ✅ Subida exitosa en intento $intentosSubida');
          } else {
            debugPrint(
              '[Guardar] ❌ Fallo en intento $intentosSubida: ${result['message']}',
            );
            if (intentosSubida < maxIntentosSubida) {
              await Future.delayed(
                Duration(seconds: intentosSubida * 2),
              ); // Delay progresivo
            }
          }
        } catch (e) {
          debugPrint('[Guardar] ❌ Error subiendo intento $intentosSubida: $e');
          result = {'success': false, 'message': e.toString()};
          if (intentosSubida < maxIntentosSubida) {
            await Future.delayed(Duration(seconds: intentosSubida * 2));
          }
        }
      }

      if (mounted) Navigator.of(context).pop();

      if (result != null && result['success'] == true) {
        // 🔥 BORRAR AUTOGUARDADO SOLO SI SUBIDA FUE EXITOSA
        await _limpiarDatosGuardados();
        debugPrint(
          '[Guardar] ✅ Autoguardado eliminado después de subida exitosa',
        );

        // 🔥 LIBERAR MEMORIA después de subir exitosamente
        _limpiarCacheThumbnails();
        debugPrint('[Memoria] 🗑️ Memoria liberada después de guardar');

        if (mounted) {
          // Mensaje diferente según si el Word está disponible o no
          final mensaje = docxBytes == null
              ? '✓ Guardado exitosamente (solo PDF)\n⚠️ Word no disponible'
              : '✓ ${result['message'] ?? "Guardado exitosamente"}';

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
        }

        // ✅ SOLO LIMPIAR SI GUARDÓ EXITOSAMENTE
        _limpiarFormulario();
        await _cargarHistorial();

        if (mounted) {
          // Cambiar a la pestaña de historial
          _tabController.animateTo(1);
        }
      } else {
        // ❌ ERROR: NO LIMPIAR FORMULARIO
        debugPrint(
          '[Guardar] ❌ Error al guardar: ${result?['message'] ?? 'Sin mensaje'}',
        );
        throw Exception(result?['message'] ?? 'Error desconocido al guardar');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      // ❌ ERROR: NO LIMPIAR FORMULARIO (mantener datos guardados)
      debugPrint('[Guardar] ❌ Error al subir: $e');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: const [
                Icon(Icons.warning_amber, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Text('No se pudo subir'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚠️ Fallo en la subida a la nube',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade300, width: 2),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 48),
                      SizedBox(height: 8),
                      Text(
                        '💾 TUS DATOS ESTÁN SEGUROS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'El formulario, fotos y observaciones están guardados localmente. NO se perdió nada.',
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  '🔄 Intenta subir de nuevo cuando:\n'
                  '  • Tengas mejor señal\n'
                  '  • Te conectes a WiFi\n'
                  '  • Estés en una zona sin interferencias\n\n'
                  '⚠️ Si cierras la app, los datos seguirán guardados.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    'Error técnico: ${e.toString().length > 60 ? "${e.toString().substring(0, 60)}..." : e.toString()}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _guardarEnNube(); // Reintentar
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
              ),
            ],
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
      debugPrint(
        '[Historial] 📋 Cargando historial para plaza: ${widget.plazaId}',
      );

      final historial = await _supabaseService.obtenerHistorial(widget.plazaId);

      debugPrint('[Historial] ✅ Recibidos ${historial.length} registros');

      // 🔥 MANEJO DEFENSIVO: Proteger contra valores null
      try {
        final inspectores = historial
            .map((h) => (h['inspector'] ?? 'Sin nombre').toString())
            .join(", ");
        debugPrint('[Historial] Datos: $inspectores');
      } catch (e) {
        debugPrint('[Historial] ⚠️ Error al formatear datos: $e');
      }

      setState(() {
        _historial = historial;
        _cargandoHistorial = false;
      });

      debugPrint(
        '[Historial] 🎨 UI actualizada, _historial.length = ${_historial.length}',
      );
    } catch (e) {
      debugPrint('[Historial] ❌ Error: $e');

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

    // ✅ DINÁMICO: usar length de criterios oficiales
    final totalCriterios = CatastroExportService.criteriosOficiales.length;

    if (evaluacionesCompletas < totalCriterios) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠ Complete todas las evaluaciones ($totalCriterios criterios)',
          ),
          backgroundColor: const Color(0xFFF57C00),
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

    // 🔥 LIBERAR MEMORIA: Limpiar caché de thumbnails
    _limpiarCacheThumbnails();

    // ✅ NO BORRAR AUTOGUARDADO AQUÍ - Solo cuando suba exitosamente
    // _limpiarDatosGuardados(); // ← COMENTADO
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

  // ============================================================================
  // AUTOGUARDADO LOCAL (prevenir pérdida de datos)
  // ============================================================================

  Future<void> _guardarDatosLocalmente() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'catastro_draft_${widget.plazaId}';

      // 🔥 CONVERTIR FOTOS A BASE64 COMPRIMIDAS (para web)
      final fotosSerializadas = <Map<String, String>>[];
      int fotosProcesadas = 0;

      for (final foto in _fotos) {
        try {
          final archivo = foto['archivo'] as XFile;
          final bytesOriginales = await archivo.readAsBytes();

          // ✅ COMPRIMIR A 50% para que quepa en SharedPreferences
          final bytesComprimidos = bytesOriginales;

          // Limitar a 300 KB por foto (reducido de 500KB)
          if (bytesComprimidos.length > 300 * 1024) {
            debugPrint(
              '[Autoguardado] ⚠️ Foto muy grande (${(bytesComprimidos.length / 1024).toStringAsFixed(0)} KB), omitiendo',
            );
            continue; // Saltar foto muy grande
          }

          final base64String = base64Encode(bytesComprimidos);

          fotosSerializadas.add({
            'base64': base64String,
            'nota': foto['nota'] as String? ?? '',
            'nombre': archivo.name,
          });

          fotosProcesadas++;
          debugPrint(
            '[Autoguardado] 📷 Foto $fotosProcesadas: ${(bytesComprimidos.length / 1024).toStringAsFixed(0)} KB',
          );
        } catch (e) {
          debugPrint('[Autoguardado] ⚠️ Error guardando foto: $e');
        }
      }

      debugPrint(
        '[Autoguardado] Total fotos a guardar: ${fotosSerializadas.length} de ${_fotos.length}',
      );

      // Log del tamaño total
      final tamanioTotal = fotosSerializadas.fold<int>(
        0,
        (sum, foto) => sum + (foto['base64']?.length ?? 0),
      );
      final tamanioKB = (tamanioTotal / 1024).toStringAsFixed(1);
      debugPrint(
        '[Autoguardado] 📦 Tamaño total: $tamanioKB KB (${fotosSerializadas.length} fotos)',
      );

      // Advertir si es muy grande (>2 MB es peligroso para SharedPreferences)
      if (tamanioTotal > 2 * 1024 * 1024) {
        debugPrint(
          '[Autoguardado] ⚠️ ADVERTENCIA: Tamaño muy grande, puede fallar al guardar',
        );
      }

      // Preparar datos para guardar
      final Map<String, dynamic> draft = {
        'inspector': _inspectorController.text,
        'evaluaciones': _evaluaciones,
        'observaciones': _observaciones.map((k, v) => MapEntry(k, v.text)),
        'timestamp': DateTime.now().toIso8601String(),
        'fotos': fotosSerializadas,
      };

      await prefs.setString(key, jsonEncode(draft));
      debugPrint('[Autoguardado] ✅ Datos guardados exitosamente');
      debugPrint('[Autoguardado] Inspector: "${_inspectorController.text}"');
      debugPrint('[Autoguardado] Fotos guardadas: ${fotosSerializadas.length}');
      debugPrint('[Autoguardado] Evaluaciones: ${_evaluaciones.length}');
    } catch (e) {
      debugPrint('[Autoguardado] ❌ Error: $e');
    }
  }

  Future<void> _recuperarDatosGuardados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'catastro_draft_${widget.plazaId}';
      final draftJson = prefs.getString(key);

      if (draftJson == null || draftJson.isEmpty) {
        debugPrint('[Autoguardado] No hay datos guardados');
        return;
      }

      final draft = jsonDecode(draftJson) as Map<String, dynamic>;
      final timestampStr = draft['timestamp'] as String?;

      if (timestampStr != null) {
        final timestamp = DateTime.parse(timestampStr);
        final diferencia = DateTime.now().difference(timestamp);

        // Si los datos son muy antiguos (>7 días), no recuperar
        if (diferencia.inDays > 7) {
          await prefs.remove(key);
          debugPrint('[Autoguardado] Datos antiguos eliminados');
          return;
        }

        // Preguntar al usuario si quiere recuperar
        if (mounted) {
          final recuperar = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('📋 Datos guardados'),
              content: Text(
                'Se encontraron datos guardados de hace ${_formatearTiempo(diferencia)}.\n\n¿Deseas recuperarlos?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Descartar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Recuperar'),
                ),
              ],
            ),
          );

          if (recuperar == true) {
            // 🔥 DEBUG: Ver qué datos hay ANTES de recuperar
            debugPrint('[Autoguardado] ===== RECUPERANDO DATOS =====');
            debugPrint('[Autoguardado] JSON completo: $draftJson');
            debugPrint('[Autoguardado] Keys: ${draft.keys.join(", ")}');
            debugPrint('[Autoguardado] Inspector: "${draft['inspector']}"');
            debugPrint(
              '[Autoguardado] Evaluaciones count: ${(draft['evaluaciones'] as Map?)?.length}',
            );
            debugPrint(
              '[Autoguardado] Observaciones count: ${(draft['observaciones'] as Map?)?.length}',
            );
            debugPrint(
              '[Autoguardado] Fotos count: ${(draft['fotos'] as List?)?.length}',
            );

            setState(() {
              _inspectorController.text = draft['inspector'] as String? ?? '';
              _evaluaciones.clear();
              _evaluaciones.addAll(
                Map<String, String?>.from(draft['evaluaciones'] ?? {}),
              );

              final observaciones = Map<String, dynamic>.from(
                draft['observaciones'] ?? {},
              );
              for (final entry in observaciones.entries) {
                if (_observaciones.containsKey(entry.key)) {
                  _observaciones[entry.key]!.text = entry.value.toString();
                }
              }

              // 🔥 RECUPERAR FOTOS desde Base64
              _fotos.clear();
              final fotosGuardadas = draft['fotos'] as List<dynamic>?;
              if (fotosGuardadas != null) {
                for (final foto in fotosGuardadas) {
                  try {
                    final fotoMap = foto as Map<String, dynamic>;
                    final base64String = fotoMap['base64'] as String?;
                    final nota = fotoMap['nota'] as String? ?? '';
                    final nombre = fotoMap['nombre'] as String? ?? 'foto.jpg';

                    if (base64String != null && base64String.isNotEmpty) {
                      // Decodificar Base64 a bytes
                      final bytes = base64Decode(base64String);

                      // Crear XFile temporal desde bytes
                      final xfile = XFile.fromData(
                        bytes,
                        name: nombre,
                        mimeType: 'image/jpeg',
                      );

                      _fotos.add({'archivo': xfile, 'nota': nota});
                    }
                  } catch (e) {
                    debugPrint('[Autoguardado] ⚠️ Error recuperando foto: $e');
                  }
                }
                debugPrint(
                  '[Autoguardado] ✅ ${_fotos.length} foto(s) recuperadas',
                );
              }
            });

            debugPrint('[Autoguardado] ===== FIN RECUPERACIÓN =====');

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '📊 DEBUG RECUPERACIÓN:\n'
                    'Inspector: ${draft['inspector']?.toString().isEmpty ?? true ? "VACÍO" : draft['inspector'].toString().substring(0, (draft['inspector'].toString().length > 15 ? 15 : draft['inspector'].toString().length))}\n'
                    'Evaluaciones: ${(draft['evaluaciones'] as Map?)?.length ?? 0}\n'
                    'Observaciones: ${(draft['observaciones'] as Map?)?.length ?? 0}\n'
                    'Fotos guardadas: ${(draft['fotos'] as List?)?.length ?? 0}\n'
                    'Fotos recuperadas: ${_fotos.length}',
                  ),
                  backgroundColor: Colors.blue.shade700,
                  duration: const Duration(seconds: 12),
                ),
              );
            }

            debugPrint('[Autoguardado] ✅ Datos recuperados');
          } else {
            // Usuario eligió descartar
            await prefs.remove(key);
            debugPrint('[Autoguardado] Datos descartados por el usuario');
          }
        }
      }
    } catch (e) {
      debugPrint('[Autoguardado] ❌ Error al recuperar: $e');
    }
  }

  String _formatearTiempo(Duration duracion) {
    if (duracion.inMinutes < 60) {
      return '${duracion.inMinutes} minutos';
    } else if (duracion.inHours < 24) {
      return '${duracion.inHours} horas';
    } else {
      return '${duracion.inDays} días';
    }
  }

  Future<void> _limpiarDatosGuardados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'catastro_draft_${widget.plazaId}';
      await prefs.remove(key);
      debugPrint('[Autoguardado] ✅ Borrador eliminado');
    } catch (e) {
      debugPrint('[Autoguardado] ❌ Error al limpiar: $e');
    }
  }

  /// Descargar Word desde historial (convierte si no existe)
  Future<void> _descargarWordDesdeHistorial({
    required Map<String, dynamic> catastro,
    required String? wordUrl,
    required String? pdfUrl,
  }) async {
    try {
      // Si ya existe Word URL, descargar directo
      if (wordUrl != null && wordUrl.isNotEmpty) {
        await _descargarDesdeUrl(wordUrl, 'Word');
        return;
      }

      // Si no existe Word, convertir PDF a Word
      if (pdfUrl == null || pdfUrl.isEmpty) {
        throw Exception('No hay PDF disponible para convertir');
      }

      _mostrarProgreso(
        'Convirtiendo PDF a Word...\n(Puede tardar 60-90 segundos)',
      );

      // Descargar PDF desde URL
      final pdfResponse = await http
          .get(Uri.parse(pdfUrl))
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Timeout descargando PDF'),
          );

      if (pdfResponse.statusCode != 200) {
        throw Exception('Error descargando PDF: ${pdfResponse.statusCode}');
      }

      final pdfBytes = pdfResponse.bodyBytes;

      // Convertir PDF a Word usando ConvertAPI
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'catastro_${catastro['plaza_id']}_$timestamp.pdf';

      final docxUrl = await _exportService.convertPdfToWordILovePDF(
        pdfBytes: pdfBytes,
        filename: filename,
      );

      if (mounted) Navigator.of(context).pop();

      if (docxUrl == null) {
        throw Exception('No se pudo convertir el PDF a Word');
      }

      // Descargar Word generado
      await _descargarDesdeUrl(docxUrl, 'Word');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Word generado y descargado'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// Subir PDF manualmente para recuperar catastros perdidos
  Future<void> _subirPdfManual() async {
    try {
      // 1. Seleccionar PDF
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        return; // Usuario canceló
      }

      final pdfFile = result.files.first;

      if (pdfFile.bytes == null) {
        throw Exception('No se pudo leer el archivo PDF');
      }

      // 2. Solicitar datos del catastro
      String? inspector;
      DateTime fechaHora = DateTime.now();

      await showDialog(
        context: context,
        builder: (dialogContext) {
          final inspectorController = TextEditingController(
            text: 'Josué Muñoz Fuentealba',
          );
          DateTime selectedDate = DateTime.now();

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Datos del Catastro'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Archivo: ${pdfFile.name}'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: inspectorController,
                      decoration: const InputDecoration(
                        labelText: 'Inspector',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Fecha:'),
                      subtitle: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              selectedDate.hour,
                              selectedDate.minute,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      inspector = inspectorController.text;
                      fechaHora = selectedDate;
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Subir'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (inspector == null || inspector!.isEmpty) {
        return; // Usuario canceló
      }

      // 3. Subir a Supabase
      _mostrarProgreso('Subiendo PDF a la nube...');

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final result2 = await _supabaseService.guardarCatastroConDocxConvertido(
        plazaId: widget.plazaId,
        nombrePlaza: widget.nombrePlaza,
        inspector: inspector!,
        fechaHora: fechaHora,
        evaluaciones: {},
        observaciones: {},
        pdfBytes: pdfFile.bytes!,
        docxBytes: null,
      );

      if (mounted) Navigator.of(context).pop();

      if (result2['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ PDF subido exitosamente'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }

        // Recargar historial
        await _cargarHistorial();
      } else {
        throw Exception(result2['message'] ?? 'Error al subir PDF');
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
