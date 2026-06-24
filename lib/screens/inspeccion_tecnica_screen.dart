import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../widgets/widgets.dart';
import '../models/inspection_data.dart';
import '../services/pdf_export_service.dart';
import '../services/email_service.dart';
import '../utils/word_export.dart' as word_export;
import '../utils/download_helper.dart';

class InspeccionTecnicaScreen extends StatefulWidget {
  final String plazaId;
  final String nombrePlaza;

  const InspeccionTecnicaScreen({
    super.key,
    required this.plazaId,
    required this.nombrePlaza,
  });

  @override
  State<InspeccionTecnicaScreen> createState() =>
      _InspeccionTecnicaScreenState();
}

class _InspeccionTecnicaScreenState extends State<InspeccionTecnicaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controller para correo del supervisor y nombre
  final TextEditingController _correoJefeController = TextEditingController();
  final TextEditingController _nombreSupervisorController =
      TextEditingController();

  // Mapas de estado para cada sección
  final Map<String, String?> _evaluacionesAseo = {};
  final Map<String, String?> _evaluacionesCesped = {};
  final Map<String, String?> _evaluacionesArbolado = {};
  final Map<String, String?> _evaluacionesFlores = {};
  final Map<String, String?> _evaluacionesCaminos = {};
  final Map<String, String?> _evaluacionesInfraestructura = {};

  // Mapa para almacenar imágenes por sección
  final Map<String, List<XFile>> _imagenesPorSeccion = {
    'ASEO': [],
    'CÉSPED': [],
    'ARBOLADO': [],
    'FLORES': [],
    'CAMINOS': [],
    'INFRAESTRUCTURA': [],
  };

  // Listas de criterios
  final List<String> _criteriosAseo = [
    'Basura por tiempo indebido pero con recolección.',
    'Residuos acumulados de días anteriores.',
    'Presencia de escombros o desechos.',
    'Aseo externo o interior en áreas específicas (ciclovías), no realizado o realizado parcialmente.',
    'Basureros sucios o en mal estado.',
    'Aseo sin realizar espacio abiertamente sucio (aplicable en ciclovías).',
    'No hay residuos sólidos.',
  ];

  final List<String> _criteriosCesped = [
    'Presencia de césped seco o amarillento.',
    'Zonas con baja densidad de césped.',
    'Pasto cortado sin retirar.',
    'Gran cantidad de malezas.',
  ];

  final List<String> _criteriosArbolado = [
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

  final List<String> _criteriosFlores = [
    'Ejemplares mal cuidados, flores, ramas o ramillas secas.',
    'Se observa basura.',
    'Terreno se escarba con dificultad, mal aspecto.',
    'Densidad menor a las exigencias de las bases.',
    'Ejemplares perdidos y descuidados, pérdida de macizo no delimitado.',
    'Terreno sucio.',
    'Terreno compacto.',
    'Densidad inferior al 30% de las exigencias de las bases.',
    'Presencia de malezas.',
  ];

  final List<String> _criteriosCaminos = [
    'Observación de malezas, incluye CICLOVÍA.',
    'Material árido disparejo.',
    'Sin árido en zonas extensas se observa suelo compacto.',
    'Malezas en gran parte de la superficie.',
    'Material de mala calidad.',
  ];

  final List<String> _criteriosInfraestructura = [
    'Estructuras que requieren mantención.',
    'Necesidad de pintura en estructuras.',
    'Pérdidas de agua en el sistema de riego.',
    'Se requiere hacer mantención de más del 30% de la infraestructura.',
    'Se requiere pintar más del 30% de la infraestructura.',
    'Falta de candado o cierre de acceso al agua.',
    'Se requiere reparación de alguna estructura (ej: falta tapa de nicho).',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _correoJefeController.dispose();
    _nombreSupervisorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Información del Área Verde',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tabla estática superior
            _buildTablaInformacion(),

            // Navegación por pestañas
            Container(
              color: const Color(0xFFF5F5F5),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: const Color(0xFF1565C0),
                unselectedLabelColor: const Color(0xFF757575),
                indicatorColor: const Color(0xFF1565C0),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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

            // Contenido de las pestañas con altura fija
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSeccionAseo(),
                  _buildSeccionCesped(),
                  _buildSeccionArbolado(),
                  _buildSeccionFlores(),
                  _buildSeccionCaminos(),
                  _buildSeccionInfraestructura(),
                ],
              ),
            ),

            // Panel de acciones finales
            PanelAccionesFinales(
              nombreSupervisorController: _nombreSupervisorController,
              correoSupervisorController: _correoJefeController,
              onGuardarHistorial: _guardarEnHistorial,
              onVerHistorial: _verHistorial,
              onExportarPDF: _exportarReportePDF,
              onExportarWord: _exportarReporteWord,
              onEnviarReporte: _enviarAlJefe,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget para la tabla estática de información
  Widget _buildTablaInformacion() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado con logos
            Row(
              children: [
                // Logo izquierdo (placeholder)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_balance,
                    size: 24,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(width: 12),
                // Título central
                const Expanded(
                  child: Text(
                    'INFORMACIÓN DEL ÁREA VERDE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Logo derecho (placeholder)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.park,
                    size: 24,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tabla de información
            Table(
              border: TableBorder.all(color: Colors.grey.shade400, width: 1),
              columnWidths: const {
                0: FlexColumnWidth(1.5),
                1: FlexColumnWidth(3),
              },
              children: [
                _buildTableRow('ID av', widget.plazaId),
                _buildTableRow('DESCRIPCIÓN', widget.nombrePlaza),
                _buildTableRow('LATITUD', '-33.4489'),
                _buildTableRow('LONGITUD', '-70.6693'),
                _buildTableRow('TIPO DE PARQUE', 'Plaza'),
                _buildTableRow('SUPERFICIE', '1500 m²'),
                _buildTableRow('POBLACIÓN', 'Centro'),
                _buildTableRow('SECTOR', 'Sector 1'),
                _buildTableRow('EVALUACIÓN GENERAL', 'Por evaluar'),
                _buildTableRow('ÚLTIMA EVALUACIÓN', 'N/A'),
                _buildTableRow(
                  'FECHA/HORA',
                  DateTime.now().toString().substring(0, 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir filas de la tabla
  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: const Color(0xFFE0E0E0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFF212121),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.white,
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Color(0xFF424242)),
          ),
        ),
      ],
    );
  }

  // Sección ASEO
  Widget _buildSeccionAseo() {
    return Column(
      children: [
        // Encabezado de la tabla
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'ASEO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'BUENO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'REGULAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'MALO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de criterios
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _criteriosAseo.length,
                  itemBuilder: (context, index) {
                    final criterio = _criteriosAseo[index];
                    return FilaEvaluacionWidget(
                      textoCriterio: criterio,
                      valorSeleccionado: _evaluacionesAseo[criterio],
                      onChanged: (nuevoValor) {
                        setState(() {
                          _evaluacionesAseo[criterio] = nuevoValor;
                        });
                      },
                    );
                  },
                ),
                // Evidencia fotográfica
                _construirEvidenciaFotografica('ASEO'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Sección CÉSPED
  Widget _buildSeccionCesped() {
    return Column(
      children: [
        // Encabezado de la tabla
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'CÉSPED',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'BUENO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'REGULAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'MALO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de criterios
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _criteriosCesped.length,
                  itemBuilder: (context, index) {
                    final criterio = _criteriosCesped[index];
                    return FilaEvaluacionWidget(
                      textoCriterio: criterio,
                      valorSeleccionado: _evaluacionesCesped[criterio],
                      onChanged: (nuevoValor) {
                        setState(() {
                          _evaluacionesCesped[criterio] = nuevoValor;
                        });
                      },
                    );
                  },
                ),
                // Evidencia fotográfica
                _construirEvidenciaFotografica('CÉSPED'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Sección ARBOLADO
  Widget _buildSeccionArbolado() {
    return Column(
      children: [
        // Encabezado de la tabla
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'ARBOLADO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'BUENO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'REGULAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'MALO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de criterios
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _criteriosArbolado.length,
                  itemBuilder: (context, index) {
                    final criterio = _criteriosArbolado[index];
                    return FilaEvaluacionWidget(
                      textoCriterio: criterio,
                      valorSeleccionado: _evaluacionesArbolado[criterio],
                      onChanged: (nuevoValor) {
                        setState(() {
                          _evaluacionesArbolado[criterio] = nuevoValor;
                        });
                      },
                    );
                  },
                ),
                // Evidencia fotográfica
                _construirEvidenciaFotografica('ARBOLADO'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Sección FLORES
  Widget _buildSeccionFlores() {
    return Column(
      children: [
        // Encabezado de la tabla
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'FLORES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'BUENO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'REGULAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'MALO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de criterios
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _criteriosFlores.length,
                  itemBuilder: (context, index) {
                    final criterio = _criteriosFlores[index];
                    return FilaEvaluacionWidget(
                      textoCriterio: criterio,
                      valorSeleccionado: _evaluacionesFlores[criterio],
                      onChanged: (nuevoValor) {
                        setState(() {
                          _evaluacionesFlores[criterio] = nuevoValor;
                        });
                      },
                    );
                  },
                ),
                // Evidencia fotográfica
                _construirEvidenciaFotografica('FLORES'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Sección CAMINOS
  Widget _buildSeccionCaminos() {
    return Column(
      children: [
        // Encabezado de la tabla
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'CAMINOS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'BUENO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'REGULAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'MALO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de criterios
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _criteriosCaminos.length,
                  itemBuilder: (context, index) {
                    final criterio = _criteriosCaminos[index];
                    return FilaEvaluacionWidget(
                      textoCriterio: criterio,
                      valorSeleccionado: _evaluacionesCaminos[criterio],
                      onChanged: (nuevoValor) {
                        setState(() {
                          _evaluacionesCaminos[criterio] = nuevoValor;
                        });
                      },
                    );
                  },
                ),
                // Evidencia fotográfica
                _construirEvidenciaFotografica('CAMINOS'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Sección INFRAESTRUCTURA
  Widget _buildSeccionInfraestructura() {
    return Column(
      children: [
        // Encabezado de la tabla
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            border: Border.all(color: Colors.grey.shade400, width: 1),
          ),
          child: Row(
            children: [
              const Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'INFRAESTRUCTURA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'BUENO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'REGULAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: Center(
                  child: Text(
                    'MALO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Lista de criterios
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _criteriosInfraestructura.length,
                  itemBuilder: (context, index) {
                    final criterio = _criteriosInfraestructura[index];
                    return FilaEvaluacionWidget(
                      textoCriterio: criterio,
                      valorSeleccionado: _evaluacionesInfraestructura[criterio],
                      onChanged: (nuevoValor) {
                        setState(() {
                          _evaluacionesInfraestructura[criterio] = nuevoValor;
                        });
                      },
                    );
                  },
                ),
                // Evidencia fotográfica
                _construirEvidenciaFotografica('INFRAESTRUCTURA'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // FUNCIONES DE LÓGICA PARA LOS BOTONES DEL PANEL DE ACCIONES
  // ============================================================================

  /// 1. Guardar en Historial
  /// Consolida todos los mapas de evaluación en un JSON y lo guarda en SharedPreferences
  Future<void> _guardarEnHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Consolidar todas las evaluaciones en un mapa
      final Map<String, dynamic> inspeccionCompleta = {
        'fecha': DateTime.now().toIso8601String(),
        'plazaId': widget.plazaId,
        'nombrePlaza': widget.nombrePlaza,
        'correoSupervisor': _correoJefeController.text,
        'evaluaciones': {
          'aseo': _evaluacionesAseo,
          'cesped': _evaluacionesCesped,
          'arbolado': _evaluacionesArbolado,
          'flores': _evaluacionesFlores,
          'caminos': _evaluacionesCaminos,
          'infraestructura': _evaluacionesInfraestructura,
        },
        'estadoGeneral': _calcularEstadoGeneral(),
      };

      // Obtener historial existente para esta plaza
      final String key = 'historial_${widget.plazaId}';
      final String? historialJson = prefs.getString(key);

      List<dynamic> historial = [];
      if (historialJson != null) {
        historial = jsonDecode(historialJson);
      }

      // Agregar nueva inspección
      historial.add(inspeccionCompleta);

      // Guardar historial actualizado
      await prefs.setString(key, jsonEncode(historial));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Inspección guardada en el historial'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 2. Ver Historial
  /// Muestra un diálogo con el historial de inspecciones de esta plaza
  Future<void> _verHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String key = 'historial_${widget.plazaId}';
      final String? historialJson = prefs.getString(key);

      if (historialJson == null || historialJson.isEmpty) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Historial Vacío'),
              content: const Text(
                'No hay inspecciones previas registradas para esta plaza.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final List<dynamic> historial = jsonDecode(historialJson);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.history, color: Color(0xFF1565C0)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Historial: ${widget.nombrePlaza}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: ListView.builder(
                itemCount: historial.length,
                itemBuilder: (context, index) {
                  final inspeccion = historial[index];
                  final fecha = DateTime.parse(inspeccion['fecha']);
                  final estadoGeneral = inspeccion['estadoGeneral'] ?? 'N/A';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getColorEstado(estadoGeneral),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        'Inspección #${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fecha: ${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}',
                          ),
                          Text('Estado: $estadoGeneral'),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        _verDetalleInspeccion(inspeccion);
                      },
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
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

  /// 3. Exportar a PDF usando el nuevo servicio
  /// Genera un documento PDF profesional con todas las evaluaciones de las 6 secciones
  /// Incluye anexo fotográfico si hay imágenes adjuntas
  Future<void> _exportarReportePDF() async {
    try {
      // 1. Compilar todos los datos de inspección
      final datos = _compilarDatosInspeccion();

      // 2. Crear instancia del servicio PDF
      final pdfService = PDFExportService();

      // 3. Generar documento PDF con todas las secciones e imágenes
      final pdfDoc = await pdfService.generateInspectionPDF(
        plazaId: datos.plazaId,
        nombrePlaza: datos.nombrePlaza,
        correoSupervisor: datos.correoSupervisor,
        fechaHora: datos.fechaHoraFormatted,
        allEvaluations: {
          'ASEO': _evaluacionesAseo,
          'CÉSPED': _evaluacionesCesped,
          'ARBOLADO': _evaluacionesArbolado,
          'FLORES': _evaluacionesFlores,
          'CAMINOS': _evaluacionesCaminos,
          'INFRAESTRUCTURA': _evaluacionesInfraestructura,
        },
        allCriteria: {
          'ASEO': _criteriosAseo,
          'CÉSPED': _criteriosCesped,
          'ARBOLADO': _criteriosArbolado,
          'FLORES': _criteriosFlores,
          'CAMINOS': _criteriosCaminos,
          'INFRAESTRUCTURA': _criteriosInfraestructura,
        },
        estadoGeneral: datos.estadoGeneral,
        imagesBySection: datos.images,
      );

      // 4. Generar nombre de archivo con nombre de área, ID y fecha
      final now = DateTime.now();
      final fechaFormato =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      // Limpiar el nombre de la plaza para usarlo en el archivo
      final nombrePlazaLimpio = widget.nombrePlaza
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_')
          .substring(
            0,
            widget.nombrePlaza.length > 30 ? 30 : widget.nombrePlaza.length,
          );
      final filename =
          'Inspeccion_${nombrePlazaLimpio}_ID${widget.plazaId}_$fechaFormato.pdf';

      // 5. Abrir diálogo nativo para guardar PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfDoc.save(),
        name: filename,
      );

      // 6. Mostrar mensaje de éxito
      if (mounted) {
        final imageCount = datos.totalImageCount;
        final message = imageCount > 0
            ? '✓ PDF generado con $imageCount foto(s)'
            : '✓ PDF generado exitosamente';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Manejo de errores
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 4. Exportar a Word
  /// Genera un documento .docx con resumen de ítems en Malo/Regular
  /// 4. Exportar a Word (DOCX) usando el nuevo servicio
  /// Genera un documento Word editable con todas las evaluaciones
  /// Solo disponible en Flutter web
  Future<void> _exportarReporteWord() async {
    try {
      // 1. Verificar que estamos en plataforma web
      if (!kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '⚠ La exportación a Word solo está disponible en la versión web',
              ),
              backgroundColor: Color(0xFFF57C00),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // El resto del código solo se ejecuta en web
      await _exportarReporteWordWeb();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar documento Word: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Función específica para web que usa dart:html
  Future<void> _exportarReporteWordWeb() async {
    // 2. Obtener datos
    final estadoGeneral = _calcularEstadoGeneral();
    final nombreInspector = _nombreSupervisorController.text.trim();
    final fechaHora = DateTime.now();
    final fechaFormateada =
        '${fechaHora.day}/${fechaHora.month}/${fechaHora.year} ${fechaHora.hour}:${fechaHora.minute.toString().padLeft(2, '0')}';

    // 3. Generar HTML formateado como documento Word
    final htmlContent =
        '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>Reporte de Inspección Técnica</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 40px;
      color: #333;
    }
    .header-container {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      border-bottom: 3px solid #1565C0;
      padding-bottom: 10px;
    }
    .header-container h1 {
      color: #1565C0;
      margin: 0;
      flex: 1;
    }
    .header-container img {
      max-width: 200px;
      height: auto;
    }
    h1 {
      color: #1565C0;
      text-align: center;
      border-bottom: 3px solid #1565C0;
      padding-bottom: 10px;
    }
    h2 {
      color: #2E7D32;
      margin-top: 25px;
      border-bottom: 2px solid #E0E0E0;
      padding-bottom: 5px;
    }
    .encargado-section {
      background-color: #E3F2FD;
      padding: 15px;
      border-radius: 8px;
      margin: 20px 0;
      border-left: 4px solid #1565C0;
    }
    .info-section {
      background-color: #F5F5F5;
      padding: 15px;
      border-radius: 8px;
      margin: 20px 0;
    }
    .info-row {
      margin: 8px 0;
    }
    .label {
      font-weight: bold;
      color: #555;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin: 15px 0;
    }
    th {
      background-color: #1565C0;
      color: white;
      padding: 12px;
      text-align: left;
      border: 1px solid #0D47A1;
    }
    td {
      padding: 10px;
      border: 1px solid #E0E0E0;
    }
    tr:nth-child(even) {
      background-color: #F5F5F5;
    }
    .estado-bueno {
      color: #2E7D32;
      font-weight: bold;
    }
    .estado-regular {
      color: #F57C00;
      font-weight: bold;
    }
    .estado-malo {
      color: #D32F2F;
      font-weight: bold;
    }
    .footer {
      margin-top: 40px;
      text-align: center;
      font-size: 12px;
      color: #757575;
      border-top: 1px solid #E0E0E0;
      padding-top: 15px;
    }
  </style>
</head>
<body>
  <div class="header-container">
    <h1>REPORTE DE INSPECCIÓN TÉCNICA</h1>
    <img src="data:image/png;base64,LOGO_BASE64_AQUI" alt="Municipalidad de Doñihue" />
  </div>
  
  <div class="encargado-section">
    <div class="info-row"><span class="label">Encargado:</span> Felipe Lagos Bastias</div>
    <div class="info-row"><span class="label">Cargo:</span> Ingeniero Agrónomo</div>
  </div>
  
  <div class="info-section">
    <div class="info-row"><span class="label">Plaza:</span> ${widget.nombrePlaza}</div>
    <div class="info-row"><span class="label">ID de Plaza:</span> ${widget.plazaId}</div>
    <div class="info-row"><span class="label">Inspector:</span> ${nombreInspector.isNotEmpty ? nombreInspector : 'No especificado'}</div>
    <div class="info-row"><span class="label">Fecha de Inspección:</span> $fechaFormateada</div>
    <div class="info-row"><span class="label">Estado General:</span> <span class="${_getEstadoClass(estadoGeneral)}">$estadoGeneral</span></div>
  </div>

${_generarSeccionHTML('ASEO', _evaluacionesAseo, _criteriosAseo)}
${_generarSeccionHTML('CÉSPED', _evaluacionesCesped, _criteriosCesped)}
${_generarSeccionHTML('ARBOLADO', _evaluacionesArbolado, _criteriosArbolado)}
${_generarSeccionHTML('FLORES', _evaluacionesFlores, _criteriosFlores)}
${_generarSeccionHTML('CAMINOS', _evaluacionesCaminos, _criteriosCaminos)}
${_generarSeccionHTML('INFRAESTRUCTURA', _evaluacionesInfraestructura, _criteriosInfraestructura)}

  <div class="footer">
    <p>Documento generado automáticamente por el Sistema de Inspección de Áreas Verdes</p>
    <p>Encargado: Felipe Lagos Bastias - Ingeniero Agrónomo</p>
    <p>Fecha de generación: $fechaFormateada</p>
  </div>
</body>
</html>
''';

    // 4. Convertir HTML a bytes
    final bytes = utf8.encode(htmlContent);

    // 5. Generar nombre de archivo con nombre de área, ID y fecha
    final nombrePlazaLimpio = widget.nombrePlaza
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_')
        .substring(
          0,
          widget.nombrePlaza.length > 30 ? 30 : widget.nombrePlaza.length,
        );
    final fechaFormato =
        '${fechaHora.day.toString().padLeft(2, '0')}-${fechaHora.month.toString().padLeft(2, '0')}-${fechaHora.year}';
    final filename =
        'Reporte_${nombrePlazaLimpio}_ID${widget.plazaId}_$fechaFormato.doc';

    // 6. Descargar usando AnchorElement (solo Web)
    if (kIsWeb) {
      word_export.downloadWordFile(htmlContent, filename);
    }

    // 7. Mostrar mensaje de éxito
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Documento Word descargado exitosamente'),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Genera una sección HTML con tabla para el documento Word
  String _generarSeccionHTML(
    String titulo,
    Map<String, String?> evaluaciones,
    List<String> criterios,
  ) {
    final buffer = StringBuffer();
    buffer.writeln('  <h2>$titulo</h2>');
    buffer.writeln('  <table>');
    buffer.writeln('    <thead>');
    buffer.writeln('      <tr>');
    buffer.writeln('        <th style="width: 70%;">Criterio</th>');
    buffer.writeln('        <th style="width: 30%;">Evaluación</th>');
    buffer.writeln('      </tr>');
    buffer.writeln('    </thead>');
    buffer.writeln('    <tbody>');

    for (var criterio in criterios) {
      final evaluacion = evaluaciones[criterio] ?? 'No evaluado';
      final claseEstado = _getEstadoClass(evaluacion);
      buffer.writeln('      <tr>');
      buffer.writeln('        <td>$criterio</td>');
      buffer.writeln('        <td class="$claseEstado">$evaluacion</td>');
      buffer.writeln('      </tr>');
    }

    buffer.writeln('    </tbody>');
    buffer.writeln('  </table>');
    return buffer.toString();
  }

  /// Retorna la clase CSS según el estado
  String _getEstadoClass(String estado) {
    switch (estado.toLowerCase()) {
      case 'bueno':
        return 'estado-bueno';
      case 'regular':
        return 'estado-regular';
      case 'malo':
        return 'estado-malo';
      default:
        return '';
    }
  }

  /// 5. Enviar al Jefe (Supervisor)
  /// Intenta enviar el correo con PDF adjunto usando el servidor backend
  /// Si falla, ofrece alternativas de Gmail/Outlook web
  Future<void> _enviarAlJefe() async {
    final correo = _correoJefeController.text.trim();
    final nombreInspector = _nombreSupervisorController.text.trim();

    if (correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠ Ingrese el correo del inspector'),
          backgroundColor: Color(0xFFF57C00),
        ),
      );
      return;
    }

    // Validar formato de correo básico
    if (!correo.contains('@') || !correo.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠ Ingrese un correo válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final estadoGeneral = _calcularEstadoGeneral();
      final now = DateTime.now();
      final fechaFormato =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

      // Construir resumen de problemas
      final problemasLista = <String>[];

      void agregarProblemas(String seccion, Map<String, String?> evaluaciones) {
        evaluaciones.forEach((criterio, valor) {
          if (valor == 'Regular' || valor == 'Malo') {
            problemasLista.add('• $seccion: $criterio ($valor)');
          }
        });
      }

      agregarProblemas('ASEO', _evaluacionesAseo);
      agregarProblemas('CESPED', _evaluacionesCesped);
      agregarProblemas('ARBOLADO', _evaluacionesArbolado);
      agregarProblemas('FLORES', _evaluacionesFlores);
      agregarProblemas('CAMINOS', _evaluacionesCaminos);
      agregarProblemas('INFRAESTRUCTURA', _evaluacionesInfraestructura);

      final resumenProblemas = problemasLista.isNotEmpty
          ? 'Items reprobados:\n${problemasLista.join('\n')}'
          : 'No hay items reprobados.';

      if (!mounted) return;

      // Mostrar diálogo de opciones de envío
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.send, color: Color(0xFF1565C0)),
                SizedBox(width: 8),
                Text('Enviar Reporte'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seleccione cómo desea enviar el reporte:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  '📧 Envío Automático: Envía el correo con el PDF adjunto automáticamente (requiere servidor backend activo).',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                const Text(
                  '🌐 Gmail/Outlook Web: Abre el correo prellenado en el navegador (debes adjuntar el PDF manualmente).',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            actions: [
              // Opción 1: Envío automático con PDF
              TextButton.icon(
                icon: const Icon(Icons.email, color: Color(0xFF2E7D32)),
                label: const Text('Envío Automático'),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await _enviarCorreoAutomatico(
                    correo,
                    widget.nombrePlaza,
                    widget.plazaId,
                    fechaFormato,
                    estadoGeneral,
                    resumenProblemas,
                  );
                },
              ),
              // Opción 2: Gmail Web
              TextButton.icon(
                icon: const Icon(Icons.mail, color: Colors.red),
                label: const Text('Gmail'),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await _abrirGmail(
                    correo,
                    widget.nombrePlaza,
                    widget.plazaId,
                    fechaFormato,
                    estadoGeneral,
                    resumenProblemas,
                  );
                },
              ),
              // Opción 3: Outlook Web
              TextButton.icon(
                icon: const Icon(Icons.mail_outline, color: Colors.blue),
                label: const Text('Outlook'),
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  await _abrirOutlook(
                    correo,
                    widget.nombrePlaza,
                    widget.plazaId,
                    fechaFormato,
                    estadoGeneral,
                    resumenProblemas,
                  );
                },
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Envía el correo automáticamente con el PDF adjunto usando el servidor backend
  Future<void> _enviarCorreoAutomatico(
    String destinatario,
    String nombrePlaza,
    String plazaId,
    String fecha,
    String estadoGeneral,
    String resumenProblemas,
  ) async {
    if (!mounted) return;

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generando PDF y enviando correo...'),
                  SizedBox(height: 8),
                  Text(
                    'Por favor espere',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // 1. Verificar que el servidor esté disponible
      final servidorDisponible = await EmailService.verificarServidor();

      if (!servidorDisponible) {
        if (mounted) Navigator.of(context).pop();
        throw Exception(
          'El servidor de correos no está disponible.\n\n'
          'Asegúrate de que el servidor backend esté corriendo en http://localhost:3000\n\n'
          'Usa las alternativas de Gmail/Outlook web en su lugar.',
        );
      }

      // 2. Generar el PDF
      final datos = _compilarDatosInspeccion();
      final pdfService = PDFExportService();
      final pdfDoc = await pdfService.generateInspectionPDF(
        plazaId: datos.plazaId,
        nombrePlaza: datos.nombrePlaza,
        correoSupervisor: datos.correoSupervisor,
        fechaHora: datos.fechaHoraFormatted,
        allEvaluations: {
          'ASEO': _evaluacionesAseo,
          'CÉSPED': _evaluacionesCesped,
          'ARBOLADO': _evaluacionesArbolado,
          'FLORES': _evaluacionesFlores,
          'CAMINOS': _evaluacionesCaminos,
          'INFRAESTRUCTURA': _evaluacionesInfraestructura,
        },
        allCriteria: {
          'ASEO': _criteriosAseo,
          'CÉSPED': _criteriosCesped,
          'ARBOLADO': _criteriosArbolado,
          'FLORES': _criteriosFlores,
          'CAMINOS': _criteriosCaminos,
          'INFRAESTRUCTURA': _criteriosInfraestructura,
        },
        estadoGeneral: datos.estadoGeneral,
        imagesBySection: datos.images,
      );

      final pdfBytes = await pdfDoc.save();

      // 3. Obtener nombre del inspector
      final nombreInspector = _nombreSupervisorController.text.trim();

      // 4. Generar el documento Word (HTML)
      final now = DateTime.now();
      final htmlContent =
          '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Reporte de Inspección Técnica</title>
</head>
<body>
  <h1>REPORTE DE INSPECCIÓN TÉCNICA</h1>
  <p><strong>Encargado:</strong> Felipe Lagos Bastias - Ingeniero Agrónomo</p>
  <p><strong>Plaza:</strong> $nombrePlaza</p>
  <p><strong>ID:</strong> $plazaId</p>
  <p><strong>Fecha:</strong> $fecha</p>
  <p><strong>Estado General:</strong> $estadoGeneral</p>
  <p><strong>Inspector:</strong> ${nombreInspector.isNotEmpty ? nombreInspector : 'No especificado'}</p>
  <h2>Resumen</h2>
  <pre>$resumenProblemas</pre>
</body>
</html>
''';

      final wordBytes = utf8.encode(htmlContent);

      // 5. Preparar nombres de archivos
      final nombrePlazaLimpio = nombrePlaza
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_')
          .substring(0, nombrePlaza.length > 30 ? 30 : nombrePlaza.length);
      final pdfFilename =
          'Inspeccion_${nombrePlazaLimpio}_ID${plazaId}_$fecha.pdf';
      final wordFilename =
          'Reporte_${nombrePlazaLimpio}_ID${plazaId}_$fecha.doc';

      // 6. Preparar cuerpo del correo (breve, tipo FICHA)
      final cuerpo =
          '''FICHA DE INSPECCIÓN

Plaza: $nombrePlaza
ID: $plazaId
Fecha: $fecha
Estado: $estadoGeneral

Encargado: Felipe Lagos Bastias - Ingeniero Agrónomo
Inspector: ${nombreInspector.isNotEmpty ? nombreInspector : 'No especificado'}

Documentos adjuntos: PDF y Word

Saludos cordiales,
${nombreInspector.isNotEmpty ? nombreInspector : 'Inspector'}
Sistema de Inspección de Áreas Verdes''';

      final asunto = 'Inspección: $nombrePlaza - ID$plazaId - $fecha';

      // 7. Preparar adjuntos (PDF y Word)
      final adjuntos = [
        {
          'nombre': pdfFilename,
          'base64': base64Encode(pdfBytes),
          'tipo': 'application/pdf',
        },
        {
          'nombre': wordFilename,
          'base64': base64Encode(wordBytes),
          'tipo': 'application/msword',
        },
      ];

      // 8. Enviar correo con ambos adjuntos
      final enviado = await EmailService.enviarCorreoConAdjuntos(
        destinatario: destinatario,
        asunto: asunto,
        cuerpo: cuerpo,
        adjuntos: adjuntos,
      );

      // Cerrar indicador de carga
      if (mounted) Navigator.of(context).pop();

      if (enviado) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('✓ Correo enviado con PDF y Word adjuntos'),
                  ),
                ],
              ),
              backgroundColor: Color(0xFF2E7D32),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar indicador de carga si está abierto
      if (mounted) Navigator.of(context).pop();

      // Mostrar error
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Error al Enviar'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'No se pudo enviar el correo automáticamente:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(e.toString(), style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 16),
                  const Text(
                    'Sugerencia:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Usa las opciones de Gmail o Outlook web y adjunta el PDF manualmente.',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Entendido'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Abre Gmail web con el correo prellenado
  /// Abre Gmail web con el correo prellenado y descarga PDF + Word
  Future<void> _abrirGmail(
    String destinatario,
    String nombrePlaza,
    String plazaId,
    String fecha,
    String estadoGeneral,
    String resumenProblemas,
  ) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generando PDF y Word...'),
                ],
              ),
            ),
          ),
        ),
      );

      // 1. Generar PDF
      final datos = _compilarDatosInspeccion();
      final pdfService = PDFExportService();
      final pdfDoc = await pdfService.generateInspectionPDF(
        plazaId: datos.plazaId,
        nombrePlaza: datos.nombrePlaza,
        correoSupervisor: datos.correoSupervisor,
        fechaHora: datos.fechaHoraFormatted,
        allEvaluations: {
          'ASEO': _evaluacionesAseo,
          'CÉSPED': _evaluacionesCesped,
          'ARBOLADO': _evaluacionesArbolado,
          'FLORES': _evaluacionesFlores,
          'CAMINOS': _evaluacionesCaminos,
          'INFRAESTRUCTURA': _evaluacionesInfraestructura,
        },
        allCriteria: {
          'ASEO': _criteriosAseo,
          'CÉSPED': _criteriosCesped,
          'ARBOLADO': _criteriosArbolado,
          'FLORES': _criteriosFlores,
          'CAMINOS': _criteriosCaminos,
          'INFRAESTRUCTURA': _criteriosInfraestructura,
        },
        estadoGeneral: datos.estadoGeneral,
        imagesBySection: datos.images,
      );

      final pdfBytes = await pdfDoc.save();

      // 2. Generar Word
      final nombreInspector = _nombreSupervisorController.text.trim();
      final htmlContent =
          '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Reporte de Inspección Técnica</title>
</head>
<body>
  <h1>REPORTE DE INSPECCIÓN TÉCNICA</h1>
  <p><strong>Encargado:</strong> Felipe Lagos Bastias - Ingeniero Agrónomo</p>
  <p><strong>Plaza:</strong> $nombrePlaza</p>
  <p><strong>ID:</strong> $plazaId</p>
  <p><strong>Fecha:</strong> $fecha</p>
  <p><strong>Estado General:</strong> $estadoGeneral</p>
  <p><strong>Inspector:</strong> ${nombreInspector.isNotEmpty ? nombreInspector : 'No especificado'}</p>
  <h2>Resumen</h2>
  <pre>$resumenProblemas</pre>
</body>
</html>
''';

      final wordBytes = utf8.encode(htmlContent);

      // 3. Preparar nombres de archivos
      final nombrePlazaLimpio = nombrePlaza
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_')
          .substring(0, nombrePlaza.length > 30 ? 30 : nombrePlaza.length);
      final pdfFilename =
          'Inspeccion_${nombrePlazaLimpio}_ID${plazaId}_$fecha.pdf';
      final wordFilename =
          'Reporte_${nombrePlazaLimpio}_ID${plazaId}_$fecha.doc';

      // 4. Descargar archivos
      await Printing.sharePdf(bytes: pdfBytes, filename: pdfFilename);

      // Descargar Word usando helper multiplataforma
      await downloadFile(wordBytes, wordFilename);

      // Cerrar indicador
      if (mounted) Navigator.of(context).pop();

      // 5. Abrir Gmail
      final asunto = Uri.encodeComponent(
        'Inspección: $nombrePlaza - ID$plazaId - $fecha',
      );

      final cuerpo = Uri.encodeComponent('''FICHA DE INSPECCIÓN

Plaza: $nombrePlaza
ID: $plazaId
Fecha: $fecha
Estado: $estadoGeneral

Encargado: Felipe Lagos Bastias - Ingeniero Agrónomo
Inspector: ${nombreInspector.isNotEmpty ? nombreInspector : 'No especificado'}

Por favor adjunta los archivos PDF y Word descargados.

Saludos cordiales,
${nombreInspector.isNotEmpty ? nombreInspector : 'Inspector'}
Sistema de Inspección de Áreas Verdes''');

      final gmailUrl =
          'https://mail.google.com/mail/?view=cm&to=$destinatario&su=$asunto&body=$cuerpo';

      final uri = Uri.parse(gmailUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✓ Archivos descargados. Abriendo Gmail...\nAdjunta manualmente los archivos PDF y Word',
              ),
              backgroundColor: Color(0xFF2E7D32),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        throw Exception('No se puede abrir Gmail');
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

  /// Abre Outlook web con el correo prellenado y descarga PDF + Word
  Future<void> _abrirOutlook(
    String destinatario,
    String nombrePlaza,
    String plazaId,
    String fecha,
    String estadoGeneral,
    String resumenProblemas,
  ) async {
    try {
      // Mostrar indicador de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generando PDF y Word...'),
                ],
              ),
            ),
          ),
        ),
      );

      // 1. Generar PDF
      final datos = _compilarDatosInspeccion();
      final pdfService = PDFExportService();
      final pdfDoc = await pdfService.generateInspectionPDF(
        plazaId: datos.plazaId,
        nombrePlaza: datos.nombrePlaza,
        correoSupervisor: datos.correoSupervisor,
        fechaHora: datos.fechaHoraFormatted,
        allEvaluations: {
          'ASEO': _evaluacionesAseo,
          'CÉSPED': _evaluacionesCesped,
          'ARBOLADO': _evaluacionesArbolado,
          'FLORES': _evaluacionesFlores,
          'CAMINOS': _evaluacionesCaminos,
          'INFRAESTRUCTURA': _evaluacionesInfraestructura,
        },
        allCriteria: {
          'ASEO': _criteriosAseo,
          'CÉSPED': _criteriosCesped,
          'ARBOLADO': _criteriosArbolado,
          'FLORES': _criteriosFlores,
          'CAMINOS': _criteriosCaminos,
          'INFRAESTRUCTURA': _criteriosInfraestructura,
        },
        estadoGeneral: datos.estadoGeneral,
        imagesBySection: datos.images,
      );

      final pdfBytes = await pdfDoc.save();

      // 2. Generar Word
      final nombreInspector = _nombreSupervisorController.text.trim();
      final htmlContent =
          '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Reporte de Inspección Técnica</title>
</head>
<body>
  <h1>REPORTE DE INSPECCIÓN TÉCNICA</h1>
  <p><strong>Encargado:</strong> Felipe Lagos Bastias - Ingeniero Agrónomo</p>
  <p><strong>Plaza:</strong> $nombrePlaza</p>
  <p><strong>ID:</strong> $plazaId</p>
  <p><strong>Fecha:</strong> $fecha</p>
  <p><strong>Estado General:</strong> $estadoGeneral</p>
  <p><strong>Inspector:</strong> ${nombreInspector.isNotEmpty ? nombreInspector : 'No especificado'}</p>
  <h2>Resumen</h2>
  <pre>$resumenProblemas</pre>
</body>
</html>
''';

      final wordBytes = utf8.encode(htmlContent);

      // 3. Preparar nombres de archivos
      final nombrePlazaLimpio = nombrePlaza
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_')
          .substring(0, nombrePlaza.length > 30 ? 30 : nombrePlaza.length);
      final pdfFilename =
          'Inspeccion_${nombrePlazaLimpio}_ID${plazaId}_$fecha.pdf';
      final wordFilename =
          'Reporte_${nombrePlazaLimpio}_ID${plazaId}_$fecha.doc';

      // 4. Descargar archivos
      await Printing.sharePdf(bytes: pdfBytes, filename: pdfFilename);

      // Descargar Word usando helper multiplataforma
      await downloadFile(wordBytes, wordFilename);

      // Cerrar indicador
      if (mounted) Navigator.of(context).pop();

      // 5. Abrir Outlook
      final asunto = Uri.encodeComponent(
        'Inspección: $nombrePlaza - ID$plazaId - $fecha',
      );

      final cuerpo = Uri.encodeComponent('''FICHA DE INSPECCIÓN

Plaza: $nombrePlaza
ID: $plazaId
Fecha: $fecha
Estado: $estadoGeneral

Encargado: Felipe Lagos Bastias - Ingeniero Agrónomo
Inspector: ${nombreInspector.isNotEmpty ? nombreInspector : 'No especificado'}

Por favor adjunta los archivos PDF y Word descargados.

Saludos cordiales,
${nombreInspector.isNotEmpty ? nombreInspector : 'Inspector'}
Sistema de Inspección de Áreas Verdes''');

      final outlookUrl =
          'https://outlook.office.com/mail/deeplink/compose?to=$destinatario&subject=$asunto&body=$cuerpo';

      final uri = Uri.parse(outlookUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                '✓ Archivos descargados. Abriendo Outlook...\nAdjunta manualmente los archivos PDF y Word',
              ),
              backgroundColor: Color(0xFF2E7D32),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        throw Exception('No se puede abrir Outlook');
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

  // ============================================================================
  // FUNCIONES AUXILIARES
  // ============================================================================

  /// Calcula el estado general de la inspección
  String _calcularEstadoGeneral() {
    int totalMalos = 0;
    int totalRegulares = 0;

    void contarEstados(Map<String, String?> evaluaciones) {
      for (var valor in evaluaciones.values) {
        if (valor == 'Malo') totalMalos++;
        if (valor == 'Regular') totalRegulares++;
      }
    }

    contarEstados(_evaluacionesAseo);
    contarEstados(_evaluacionesCesped);
    contarEstados(_evaluacionesArbolado);
    contarEstados(_evaluacionesFlores);
    contarEstados(_evaluacionesCaminos);
    contarEstados(_evaluacionesInfraestructura);

    if (totalMalos > 5) return 'Malo';
    if (totalMalos > 0 || totalRegulares > 10) return 'Regular';
    return 'Bueno';
  }

  /// Selecciona múltiples fotos para una sección específica
  /// Compatible con Flutter web usando image_picker
  Future<void> _seleccionarFoto(String seccion) async {
    try {
      final ImagePicker picker = ImagePicker();

      // Permitir selección múltiple de imágenes
      final List<XFile> imagenes = await picker.pickMultiImage(
        imageQuality: 85, // Compresión para optimizar tamaño
      );

      if (imagenes.isNotEmpty) {
        setState(() {
          _imagenesPorSeccion[seccion]?.addAll(imagenes);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✓ ${imagenes.length} foto(s) agregada(s) a $seccion',
              ),
              backgroundColor: const Color(0xFF2E7D32),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar fotos: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Elimina una foto específica de una sección
  void _eliminarFoto(String seccion, int index) {
    setState(() {
      _imagenesPorSeccion[seccion]?.removeAt(index);
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Foto eliminada'),
          backgroundColor: Color(0x0fff57c0),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  /// Widget para evidencia fotográfica por sección
  /// Muestra botón para agregar fotos y ListView horizontal con miniaturas
  Widget _construirEvidenciaFotografica(String seccion) {
    final fotos = _imagenesPorSeccion[seccion] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con botón de agregar fotos
          Row(
            children: [
              const Icon(Icons.camera_alt, color: Color(0xFF1565C0), size: 20),
              const SizedBox(width: 8),
              Text(
                'Evidencia Fotográfica',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF212121),
                ),
              ),
              const Spacer(),
              // Contador de fotos
              if (fotos.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${fotos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              // Botón agregar fotos
              ElevatedButton.icon(
                onPressed: () => _seleccionarFoto(seccion),
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: const Text('Agregar Fotos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),

          // Lista horizontal de miniaturas
          if (fotos.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fotos.length,
                itemBuilder: (context, index) {
                  final foto = fotos[index];
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 100,
                    height: 100,
                    child: Stack(
                      children: [
                        // Miniatura de imagen
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.network(
                                  foto.path,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image),
                                    );
                                  },
                                )
                              : Image.file(
                                  File(foto.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.broken_image),
                                    );
                                  },
                                ),
                        ),
                        // Botón X para eliminar
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _eliminarFoto(seccion, index),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
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
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Compila todos los datos de inspección en una estructura InspectionData
  ///
  /// Recopila datos de las 6 secciones de evaluación (ASEO, CÉSPED, ARBOLADO,
  /// FLORES, CAMINOS, INFRAESTRUCTURA) y crea un objeto InspectionData con
  /// toda la información necesaria para exportar reportes.
  ///
  /// Returns: InspectionData con todos los datos compilados
  InspectionData _compilarDatosInspeccion() {
    // Crear las 6 secciones en el orden correcto
    final sections = <String, EvaluationSection>{
      'ASEO': EvaluationSection(
        title: 'ASEO',
        criteria: _criteriosAseo,
        evaluations: _evaluacionesAseo,
      ),
      'CÉSPED': EvaluationSection(
        title: 'CÉSPED',
        criteria: _criteriosCesped,
        evaluations: _evaluacionesCesped,
      ),
      'ARBOLADO': EvaluationSection(
        title: 'ARBOLADO',
        criteria: _criteriosArbolado,
        evaluations: _evaluacionesArbolado,
      ),
      'FLORES': EvaluationSection(
        title: 'FLORES',
        criteria: _criteriosFlores,
        evaluations: _evaluacionesFlores,
      ),
      'CAMINOS': EvaluationSection(
        title: 'CAMINOS',
        criteria: _criteriosCaminos,
        evaluations: _evaluacionesCaminos,
      ),
      'INFRAESTRUCTURA': EvaluationSection(
        title: 'INFRAESTRUCTURA',
        criteria: _criteriosInfraestructura,
        evaluations: _evaluacionesInfraestructura,
      ),
    };

    // Crear y retornar la instancia de InspectionData con imágenes
    return InspectionData(
      plazaId: widget.plazaId,
      nombrePlaza: widget.nombrePlaza,
      correoSupervisor: _correoJefeController.text.isNotEmpty
          ? _correoJefeController.text
          : 'N/A',
      fechaHora: DateTime.now(),
      estadoGeneral: _calcularEstadoGeneral(),
      sections: sections,
      images: _imagenesPorSeccion,
    );
  }

  /// Obtiene el color según el estado
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

  /// Muestra el detalle de una inspección del historial
  void _verDetalleInspeccion(Map<String, dynamic> inspeccion) {
    final fecha = DateTime.parse(inspeccion['fecha']);
    final evaluaciones = inspeccion['evaluaciones'] as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Inspección del ${fecha.day}/${fecha.month}/${fecha.year}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Estado: ${inspeccion['estadoGeneral']}'),
              Text('Supervisor: ${inspeccion['correoSupervisor'] ?? 'N/A'}'),
              const Divider(),
              const Text(
                'Evaluaciones:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Aseo: ${evaluaciones['aseo']?.length ?? 0} ítems'),
              Text('Césped: ${evaluaciones['cesped']?.length ?? 0} ítems'),
              Text('Arbolado: ${evaluaciones['arbolado']?.length ?? 0} ítems'),
              Text('Flores: ${evaluaciones['flores']?.length ?? 0} ítems'),
              Text('Caminos: ${evaluaciones['caminos']?.length ?? 0} ítems'),
              Text(
                'Infraestructura: ${evaluaciones['infraestructura']?.length ?? 0} ítems',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Construye tabla de información para PDF
  pw.Widget _buildPdfInfoTable() {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
      },
      children: [
        _buildPdfTableRow('ID Plaza', widget.plazaId),
        _buildPdfTableRow('Nombre', widget.nombrePlaza),
        _buildPdfTableRow(
          'Fecha/Hora',
          DateTime.now().toString().substring(0, 16),
        ),
        _buildPdfTableRow(
          'Inspector',
          _correoJefeController.text.isNotEmpty
              ? _correoJefeController.text
              : 'N/A',
        ),
      ],
    );
  }

  /// Construye fila de tabla para PDF
  pw.TableRow _buildPdfTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          color: PdfColors.grey300,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  /// Construye sección de evaluación para PDF
  pw.Widget _buildPdfSeccion(
    String titulo,
    Map<String, String?> evaluaciones,
    List<String> criterios,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          color: PdfColors.grey300,
          child: pw.Text(
            titulo,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(1),
          },
          children: criterios.map((criterio) {
            final valor = evaluaciones[criterio] ?? 'N/A';
            return pw.TableRow(
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    criterio,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(
                    valor,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Obtiene items problemáticos (Regular o Malo)
  /// Obtiene items problemáticos (Regular o Malo) como texto
  String _obtenerItemsProblematicosTexto() {
    final buffer = StringBuffer();
    bool hayProblemas = false;

    void agregarItems(String seccion, Map<String, String?> evaluaciones) {
      evaluaciones.forEach((criterio, valor) {
        if (valor == 'Regular' || valor == 'Malo') {
          if (!hayProblemas) {
            hayProblemas = true;
          }
          buffer.writeln('[$seccion] $criterio: $valor');
        }
      });
    }

    agregarItems('ASEO', _evaluacionesAseo);
    agregarItems('CÉSPED', _evaluacionesCesped);
    agregarItems('ARBOLADO', _evaluacionesArbolado);
    agregarItems('FLORES', _evaluacionesFlores);
    agregarItems('CAMINOS', _evaluacionesCaminos);
    agregarItems('INFRAESTRUCTURA', _evaluacionesInfraestructura);

    return buffer.toString();
  }

  /// Genera resumen de texto para correo
  String _generarResumenTexto() {
    final buffer = StringBuffer();
    buffer.writeln('REPORTE DE INSPECCIÓN TÉCNICA');
    buffer.writeln('=' * 40);
    buffer.writeln('');
    buffer.writeln('Plaza: ${widget.nombrePlaza}');
    buffer.writeln('ID: ${widget.plazaId}');
    buffer.writeln('Fecha: ${DateTime.now().toString().substring(0, 16)}');
    buffer.writeln('Estado General: ${_calcularEstadoGeneral()}');
    buffer.writeln('');
    buffer.writeln('=' * 40);
    buffer.writeln('ÍTEMS PROBLEMÁTICOS (Regular/Malo):');
    buffer.writeln('=' * 40);
    buffer.writeln('');

    void agregarProblemas(String seccion, Map<String, String?> evaluaciones) {
      bool tieneProblemas = false;
      evaluaciones.forEach((criterio, valor) {
        if (valor == 'Regular' || valor == 'Malo') {
          if (!tieneProblemas) {
            buffer.writeln('[$seccion]');
            tieneProblemas = true;
          }
          buffer.writeln('  • $criterio: $valor');
        }
      });
      if (tieneProblemas) buffer.writeln('');
    }

    agregarProblemas('ASEO', _evaluacionesAseo);
    agregarProblemas('CÉSPED', _evaluacionesCesped);
    agregarProblemas('ARBOLADO', _evaluacionesArbolado);
    agregarProblemas('FLORES', _evaluacionesFlores);
    agregarProblemas('CAMINOS', _evaluacionesCaminos);
    agregarProblemas('INFRAESTRUCTURA', _evaluacionesInfraestructura);

    buffer.writeln('');
    buffer.writeln('=' * 40);
    buffer.writeln('Fin del reporte');

    return buffer.toString();
  }

  /// Exporta como archivo de texto simple (fallback)
  Future<void> _exportarTXT() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/Inspeccion_${widget.plazaId}_${DateTime.now().millisecondsSinceEpoch}.txt',
      );

      final contenido = _generarResumenTexto();
      await file.writeAsString(contenido);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Reporte guardado en: ${file.path}'),
            backgroundColor: const Color(0xFF2E7D32),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar archivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
