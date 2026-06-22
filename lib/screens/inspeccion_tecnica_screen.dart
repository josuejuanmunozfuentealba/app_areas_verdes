import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../widgets/widgets.dart';

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

  // Controller para correo del supervisor
  final TextEditingController _correoJefeController = TextEditingController();

  // Mapas de estado para cada sección
  final Map<String, String?> _evaluacionesAseo = {};
  final Map<String, String?> _evaluacionesCesped = {};
  final Map<String, String?> _evaluacionesArbolado = {};
  final Map<String, String?> _evaluacionesFlores = {};
  final Map<String, String?> _evaluacionesCaminos = {};
  final Map<String, String?> _evaluacionesInfraestructura = {};

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
              correoJefeController: _correoJefeController,
              onGuardarHistorial: _guardarEnHistorial,
              onVerHistorial: _verHistorial,
              onExportarPDF: _exportarPDF,
              onExportarWord: _exportarWord,
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
          child: ListView.builder(
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
          child: ListView.builder(
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
          child: ListView.builder(
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
          child: ListView.builder(
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
          child: ListView.builder(
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
          child: ListView.builder(
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

  /// 3. Exportar a PDF
  /// Genera un documento PDF formal con todas las evaluaciones
  Future<void> _exportarPDF() async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Encabezado
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'REPORTE DE INSPECCIÓN TÉCNICA',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),

              // Información general
              pw.SizedBox(height: 20),
              _buildPdfInfoTable(),

              // Secciones de evaluación
              pw.SizedBox(height: 20),
              _buildPdfSeccion('ASEO', _evaluacionesAseo, _criteriosAseo),
              pw.SizedBox(height: 15),
              _buildPdfSeccion('CÉSPED', _evaluacionesCesped, _criteriosCesped),
              pw.SizedBox(height: 15),
              _buildPdfSeccion(
                'ARBOLADO',
                _evaluacionesArbolado,
                _criteriosArbolado,
              ),
              pw.SizedBox(height: 15),
              _buildPdfSeccion('FLORES', _evaluacionesFlores, _criteriosFlores),
              pw.SizedBox(height: 15),
              _buildPdfSeccion(
                'CAMINOS',
                _evaluacionesCaminos,
                _criteriosCaminos,
              ),
              pw.SizedBox(height: 15),
              _buildPdfSeccion(
                'INFRAESTRUCTURA',
                _evaluacionesInfraestructura,
                _criteriosInfraestructura,
              ),

              // Resumen
              pw.SizedBox(height: 20),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(),
                  color: PdfColors.grey300,
                ),
                child: pw.Text(
                  'Estado General: ${_calcularEstadoGeneral()}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // Mostrar el PDF para vista previa e impresión
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            'Inspeccion_${widget.plazaId}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ PDF generado exitosamente'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 4. Exportar a Word
  /// Genera un documento .docx con resumen de ítems en Malo/Regular
  Future<void> _exportarWord() async {
    try {
      // Obtener items problemáticos (Regular o Malo)
      final itemsProblematicos = _obtenerItemsProblematicosTexto();

      if (itemsProblematicos.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No hay ítems en estado Regular o Malo'),
              backgroundColor: Color(0xFFF57C00),
            ),
          );
        }
        return;
      }

      // Crear archivo TXT con formato estructurado
      // docx_template requiere plantilla existente, usamos TXT simple
      await _exportarTXT();
    } catch (e) {
      // Si hay error, crear archivo de texto simple
      await _exportarTXT();
    }
  }

  /// 5. Enviar al Jefe (Supervisor)
  /// Abre la app de correo con el reporte
  Future<void> _enviarAlJefe() async {
    final correo = _correoJefeController.text.trim();

    if (correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠ Ingrese el correo del supervisor'),
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
      // Construir resumen
      final resumen = _generarResumenTexto();
      final estadoGeneral = _calcularEstadoGeneral();

      // Crear URI de correo
      final String asunto = Uri.encodeComponent(
        'Reporte Terreno: ${widget.nombrePlaza} - $estadoGeneral',
      );
      final String cuerpo = Uri.encodeComponent(resumen);

      final Uri emailUri = Uri.parse(
        'mailto:$correo?subject=$asunto&body=$cuerpo',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Abriendo aplicación de correo...'),
              backgroundColor: Color(0xFF2E7D32),
            ),
          );
        }
      } else {
        throw Exception('No se puede abrir la aplicación de correo');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir correo: $e'),
            backgroundColor: Colors.red,
          ),
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
