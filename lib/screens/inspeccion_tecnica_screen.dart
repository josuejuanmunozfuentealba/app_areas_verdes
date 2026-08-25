import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, ByteData;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../widgets/widgets.dart';
import '../widgets/fila_evaluacion_responsiva.dart';
import '../models/inspection_data.dart';
import '../services/pdf_export_service.dart';
import '../services/email_service.dart';
import 'logica_botones_helper_web.dart';

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
  final Map<String, String?> _evaluacionesCatastroInmuebles = {};

  // Mapas para observaciones de cada sección
  final Map<String, TextEditingController> _observacionesAseo = {};
  final Map<String, TextEditingController> _observacionesCesped = {};
  final Map<String, TextEditingController> _observacionesArbolado = {};
  final Map<String, TextEditingController> _observacionesFlores = {};
  final Map<String, TextEditingController> _observacionesCaminos = {};
  final Map<String, TextEditingController> _observacionesInfraestructura = {};
  final Map<String, TextEditingController> _observacionesCatastroInmuebles = {};

  // Mapa para almacenar imágenes por sección con títulos editables
  final Map<String, List<Map<String, dynamic>>> _imagenesPorSeccion = {
    'ASEO': [],
    'CÉSPED': [],
    'ARBOLADO': [],
    'FLORES': [],
    'CAMINOS': [],
    'INFRAESTRUCTURA': [],
    'CATASTRO DE INMUEBLE DE AREAS VERDES': [],
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

  final List<String> _criteriosCatastroInmuebles = [
    'Estado estructural de bancas',
    'Estado pintura bancas',
    'Estado estructural juegos infantiles',
    'Estado de pintura de juegos infantiles',
    'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)',
    'Estado estructural basureros',
    'Estado pintura de basureros',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _correoJefeController.dispose();
    _nombreSupervisorController.dispose();

    for (var c in _observacionesAseo.values) {
      c.dispose();
    }
    for (var c in _observacionesCesped.values) {
      c.dispose();
    }
    for (var c in _observacionesArbolado.values) {
      c.dispose();
    }
    for (var c in _observacionesFlores.values) {
      c.dispose();
    }
    for (var c in _observacionesCaminos.values) {
      c.dispose();
    }
    for (var c in _observacionesInfraestructura.values) {
      c.dispose();
    }
    for (var c in _observacionesCatastroInmuebles.values) {
      c.dispose();
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
              _buildTablaInformacion(),
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
                    Tab(text: 'CATASTRO DE INMUEBLE DE AREAS VERDES'),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSeccionAseo(),
                    _buildSeccionCesped(),
                    _buildSeccionArbolado(),
                    _buildSeccionFlores(),
                    _buildSeccionCaminos(),
                    _buildSeccionInfraestructura(),
                    _buildSeccionCatastroInmuebles(),
                  ],
                ),
              ),
              PanelAccionesFinales(
                nombreSupervisorController: _nombreSupervisorController,
                correoSupervisorController: _correoJefeController,
                onGuardarHistorial: _guardarEnHistorial,
                onVerHistorial: _verHistorial,
                onExportarPDF: () => LogicaBotonesHelper.generarPDF(
                  context: context,
                  datos: _prepararDatosInspeccion(),
                ),
                onExportarWord: () => LogicaBotonesHelper.generarWord(
                  context: context,
                  datos: _prepararDatosInspeccion(),
                ),
                onEnviarReporte: () => LogicaBotonesHelper.enviarReporte(
                  context: context,
                  datos: _prepararDatosInspeccion(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTablaInformacion() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width < 650 ? 8 : 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
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
                _buildTableRow('EVALUACIÓN GENERAL', _calcularEstadoGeneral()),
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

  Widget _buildEncabezadoTabla(String titulo) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF212121),
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'B',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Color(0xFF212121),
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'R',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Color(0xFF212121),
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'M',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Color(0xFF212121),
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 3,
            child: Center(
              child: Text(
                'OBS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Color(0xFF212121),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionAseo() {
    return Column(
      children: [
        _buildEncabezadoTabla('ASEO'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 650 ? 8 : 16,
              vertical: 12,
            ),
            child: Column(
              children: [
                ..._criteriosAseo.map((criterio) {
                  _observacionesAseo.putIfAbsent(
                    criterio,
                    () => TextEditingController(),
                  );
                  return FilaEvaluacionResponsiva(
                    criterio: criterio,
                    evaluacionActual: _evaluacionesAseo[criterio],
                    onEvaluacionChanged: (nuevoValor) {
                      setState(() {
                        _evaluacionesAseo[criterio] = nuevoValor;
                      });
                    },
                    observacionController: _observacionesAseo[criterio]!,
                  );
                }),
                const SizedBox(height: 16),
                _construirEvidenciaFotografica('ASEO'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionCesped() {
    return Column(
      children: [
        _buildEncabezadoTabla('CÉSPED'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 650 ? 8 : 16,
              vertical: 12,
            ),
            child: Column(
              children: [
                ..._criteriosCesped.map((criterio) {
                  _observacionesCesped.putIfAbsent(
                    criterio,
                    () => TextEditingController(),
                  );
                  return FilaEvaluacionResponsiva(
                    criterio: criterio,
                    evaluacionActual: _evaluacionesCesped[criterio],
                    onEvaluacionChanged: (nuevoValor) {
                      setState(() {
                        _evaluacionesCesped[criterio] = nuevoValor;
                      });
                    },
                    observacionController: _observacionesCesped[criterio]!,
                  );
                }),
                const SizedBox(height: 16),
                _construirEvidenciaFotografica('CÉSPED'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionArbolado() {
    return Column(
      children: [
        _buildEncabezadoTabla('ARBOLADO'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 650 ? 8 : 16,
              vertical: 12,
            ),
            child: Column(
              children: [
                ..._criteriosArbolado.map((criterio) {
                  _observacionesArbolado.putIfAbsent(
                    criterio,
                    () => TextEditingController(),
                  );
                  return FilaEvaluacionResponsiva(
                    criterio: criterio,
                    evaluacionActual: _evaluacionesArbolado[criterio],
                    onEvaluacionChanged: (nuevoValor) {
                      setState(() {
                        _evaluacionesArbolado[criterio] = nuevoValor;
                      });
                    },
                    observacionController: _observacionesArbolado[criterio]!,
                  );
                }),
                const SizedBox(height: 16),
                _construirEvidenciaFotografica('ARBOLADO'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionFlores() {
    return Column(
      children: [
        _buildEncabezadoTabla('FLORES'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 650 ? 8 : 16,
              vertical: 12,
            ),
            child: Column(
              children: [
                ..._criteriosFlores.map((criterio) {
                  _observacionesFlores.putIfAbsent(
                    criterio,
                    () => TextEditingController(),
                  );
                  return FilaEvaluacionResponsiva(
                    criterio: criterio,
                    evaluacionActual: _evaluacionesFlores[criterio],
                    onEvaluacionChanged: (nuevoValor) {
                      setState(() {
                        _evaluacionesFlores[criterio] = nuevoValor;
                      });
                    },
                    observacionController: _observacionesFlores[criterio]!,
                  );
                }),
                const SizedBox(height: 16),
                _construirEvidenciaFotografica('FLORES'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionCaminos() {
    return Column(
      children: [
        _buildEncabezadoTabla('CAMINOS'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 650 ? 8 : 16,
              vertical: 12,
            ),
            child: Column(
              children: [
                ..._criteriosCaminos.map((criterio) {
                  _observacionesCaminos.putIfAbsent(
                    criterio,
                    () => TextEditingController(),
                  );
                  return FilaEvaluacionResponsiva(
                    criterio: criterio,
                    evaluacionActual: _evaluacionesCaminos[criterio],
                    onEvaluacionChanged: (nuevoValor) {
                      setState(() {
                        _evaluacionesCaminos[criterio] = nuevoValor;
                      });
                    },
                    observacionController: _observacionesCaminos[criterio]!,
                  );
                }),
                const SizedBox(height: 16),
                _construirEvidenciaFotografica('CAMINOS'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionInfraestructura() {
    return Column(
      children: [
        _buildEncabezadoTabla('INFRAESTRUCTURA'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width < 650 ? 8 : 16,
              vertical: 12,
            ),
            child: Column(
              children: [
                ..._criteriosInfraestructura.map((criterio) {
                  _observacionesInfraestructura.putIfAbsent(
                    criterio,
                    () => TextEditingController(),
                  );
                  return FilaEvaluacionResponsiva(
                    criterio: criterio,
                    evaluacionActual: _evaluacionesInfraestructura[criterio],
                    onEvaluacionChanged: (nuevoValor) {
                      setState(() {
                        _evaluacionesInfraestructura[criterio] = nuevoValor;
                      });
                    },
                    observacionController:
                        _observacionesInfraestructura[criterio]!,
                  );
                }),
                const SizedBox(height: 16),
                _construirEvidenciaFotografica('INFRAESTRUCTURA'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionCatastroInmuebles() {
    return Column(
      children: [
        _buildEncabezadoTabla('CATASTRO DE INMUEBLE DE AREAS VERDES'),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _criteriosCatastroInmuebles.length,
                  itemBuilder: (context, index) {
                    final criterio = _criteriosCatastroInmuebles[index];
                    _observacionesCatastroInmuebles.putIfAbsent(
                      criterio,
                      () => TextEditingController(),
                    );
                    return FilaEvaluacionWidget(
                      textoCriterio: criterio,
                      valorSeleccionado:
                          _evaluacionesCatastroInmuebles[criterio],
                      onChanged: (nuevoValor) {
                        setState(() {
                          _evaluacionesCatastroInmuebles[criterio] = nuevoValor;
                        });
                      },
                      controllerObs: _observacionesCatastroInmuebles[criterio],
                    );
                  },
                ),
                _construirEvidenciaFotografica(
                  'CATASTRO DE INMUEBLE DE AREAS VERDES',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // FUNCIONES DE LÓGICA
  // ============================================================================

  Future<void> _guardarEnHistorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();

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
          'catastroInmuebles': _evaluacionesCatastroInmuebles,
        },
        'observaciones': {
          'aseo': _observacionesAseo.map((k, v) => MapEntry(k, v.text)),
          'cesped': _observacionesCesped.map((k, v) => MapEntry(k, v.text)),
          'arbolado': _observacionesArbolado.map((k, v) => MapEntry(k, v.text)),
          'flores': _observacionesFlores.map((k, v) => MapEntry(k, v.text)),
          'caminos': _observacionesCaminos.map((k, v) => MapEntry(k, v.text)),
          'infraestructura': _observacionesInfraestructura.map(
            (k, v) => MapEntry(k, v.text),
          ),
          'catastroInmuebles': _observacionesCatastroInmuebles.map(
            (k, v) => MapEntry(k, v.text),
          ),
        },
        'estadoGeneral': _calcularEstadoGeneral(),
      };

      final String key = 'historial_${widget.plazaId}';
      final String? historialJson = prefs.getString(key);

      List<dynamic> historial = [];
      if (historialJson != null) {
        historial = jsonDecode(historialJson);
      }

      historial.add(inspeccionCompleta);
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

  Future<void> _enviarAlJefe() async {
    final correo = _correoJefeController.text.trim();

    if (correo.isEmpty || !correo.contains('@') || !correo.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠ Ingrese un correo de supervisor válido'),
          backgroundColor: Color(0xFFF57C00),
        ),
      );
      return;
    }

    try {
      final estadoGeneral = _calcularEstadoGeneral();
      final now = DateTime.now();
      final fechaFormato =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

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
      agregarProblemas(
        'CATASTRO DE INMUEBLE DE AREAS VERDES',
        _evaluacionesCatastroInmuebles,
      );

      final resumenProblemas = problemasLista.isNotEmpty
          ? 'Items reprobados:\n${problemasLista.join('\n')}'
          : 'No hay items reprobados.';

      if (!mounted) return;

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
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Seleccione cómo desea enviar el reporte:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  '📧 Envío Automático: Despacha con PDF y Word adjuntos (requiere servidor backend activo).',
                  style: TextStyle(fontSize: 13),
                ),
                SizedBox(height: 12),
                Text(
                  '🌐 Gmail/Outlook Web: Abre correo prellenado para adjuntar archivos manualmente.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            actions: [
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

  Future<void> _enviarCorreoAutomatico(
    String destinatario,
    String nombrePlaza,
    String plazaId,
    String fecha,
    String estadoGeneral,
    String resumenProblemas,
  ) async {
    if (!mounted) return;

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
                  Text('Generando documentos y enviando correo...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final servidorDisponible = await EmailService.verificarServidor();

      if (!servidorDisponible) {
        if (mounted) Navigator.of(context).pop();
        throw Exception(
          'El servidor de correos no está disponible en http://localhost:3000.\n'
          'Use las opciones de Gmail/Outlook Web como alternativa.',
        );
      }

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
          'CATASTRO DE INMUEBLE DE AREAS VERDES':
              _evaluacionesCatastroInmuebles,
        },
        allCriteria: {
          'ASEO': _criteriosAseo,
          'CÉSPED': _criteriosCesped,
          'ARBOLADO': _criteriosArbolado,
          'FLORES': _criteriosFlores,
          'CAMINOS': _criteriosCaminos,
          'INFRAESTRUCTURA': _criteriosInfraestructura,
          'CATASTRO DE INMUEBLE DE AREAS VERDES': _criteriosCatastroInmuebles,
        },
        estadoGeneral: datos.estadoGeneral,
        imagesBySection: datos.images,
      );

      final pdfBytes = await pdfDoc.save();
      final nombreInspector = _nombreSupervisorController.text.trim();

      final htmlContent = await _generarHtmlWord(
        nombrePlaza,
        plazaId,
        fecha,
        estadoGeneral,
        resumenProblemas,
      );
      final wordBytes = utf8.encode(htmlContent);

      final nombrePlazaLimpio = nombrePlaza
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_')
          .substring(0, nombrePlaza.length > 30 ? 30 : nombrePlaza.length);
      final pdfFilename =
          'Inspeccion_${nombrePlazaLimpio}_ID${plazaId}_$fecha.pdf';
      final wordFilename =
          'Reporte_${nombrePlazaLimpio}_ID${plazaId}_$fecha.doc';

      final cuerpo =
          '''FICHA DE INSPECCIÓN TÉCNICA

Plaza: $nombrePlaza
ID: $plazaId
Fecha: $fecha
Estado: $estadoGeneral

Encargado: Felipe Lagos Bastias - Ingeniero Agrónomo
Inspector: ${nombreInspector.isNotEmpty ? nombreInspector : 'No especificado'}

Se adjuntan los reportes en formatos PDF y Word editable.

Saludos cordiales,
Sistema de Inspección de Áreas Verdes - Municipalidad de Doñihue''';

      final asunto = 'Inspección: $nombrePlaza - ID$plazaId - $fecha';

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

      final enviado = await EmailService.enviarCorreoConAdjuntos(
        destinatario: destinatario,
        asunto: asunto,
        cuerpo: cuerpo,
        adjuntos: adjuntos,
      );

      if (mounted) Navigator.of(context).pop();

      if (enviado && mounted) {
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
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Error al Enviar'),
              ],
            ),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<String> _generarHtmlWord(
    String nombrePlaza,
    String plazaId,
    String fecha,
    String estadoGeneral,
    String resumenProblemas,
  ) async {
    String logoBase64 = '';
    try {
      final logoData = await rootBundle.load('assets/logo_2026.png');
      final logoBytes = logoData.buffer.asUint8List();
      logoBase64 = base64Encode(logoBytes);
    } catch (_) {}

    final nombreInspector = _nombreSupervisorController.text.trim();

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Reporte de Inspección Técnica - $nombrePlaza</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; color: #333; }
    .header { display: flex; justify-content: space-between; align-items: center; border-bottom: 3px solid #2E7D32; padding-bottom: 20px; }
    .header h1 { color: #2E7D32; margin: 0; font-size: 20px; }
    .info-section { background-color: #f5f5f5; border-left: 4px solid #2E7D32; padding: 15px; margin: 20px 0; }
    table { width: 100%; border-collapse: collapse; margin: 20px 0; }
    th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
    th { background-color: #2E7D32; color: white; }
  </style>
</head>
<body>
  <div class="header">
    <h1>REPORTE DE INSPECCIÓN TÉCNICA DE ÁREAS VERDES</h1>
    ${logoBase64.isNotEmpty ? '<img src="data:image/png;base64,$logoBase64" width="80" height="80" alt="Logo">' : ''}
  </div>
  <div class="info-section">
    <p><b>Plaza:</b> $nombrePlaza (ID: $plazaId)</p>
    <p><b>Fecha:</b> $fecha</p>
    <p><b>Estado General:</b> $estadoGeneral</p>
    <p><b>Inspector:</b> ${nombreInspector.isNotEmpty ? nombreInspector : 'No especificado'}</p>
    <p><b>Encargado:</b> Felipe Lagos Bastias - Ingeniero Agrónomo</p>
  </div>
  <h3>Resumen de Observaciones</h3>
  <pre>$resumenProblemas</pre>
  <h3>Secciones Evaluadas</h3>
  <table>
    <tr><th>Sección</th><th>Criterios Evaluados</th></tr>
    <tr><td>ASEO</td><td>${_criteriosAseo.length}</td></tr>
    <tr><td>CÉSPED</td><td>${_criteriosCesped.length}</td></tr>
    <tr><td>ARBOLADO</td><td>${_criteriosArbolado.length}</td></tr>
    <tr><td>FLORES</td><td>${_criteriosFlores.length}</td></tr>
    <tr><td>CAMINOS</td><td>${_criteriosCaminos.length}</td></tr>
    <tr><td>INFRAESTRUCTURA</td><td>${_criteriosInfraestructura.length}</td></tr>
    <tr><td>CATASTRO DE INMUEBLE DE AREAS VERDES</td><td>${_criteriosCatastroInmuebles.length}</td></tr>
  </table>
</body>
</html>
''';
  }

  Future<void> _abrirGmail(
    String destinatario,
    String nombrePlaza,
    String plazaId,
    String fecha,
    String estadoGeneral,
    String resumenProblemas,
  ) async {
    try {
      final nombreInspector = _nombreSupervisorController.text.trim();
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
Sistema de Inspección de Áreas Verdes''');

      final gmailUrl =
          'https://mail.google.com/mail/?view=cm&to=$destinatario&su=$asunto&body=$cuerpo';
      final uri = Uri.parse(gmailUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('No se pudo abrir Gmail en el navegador');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _abrirOutlook(
    String destinatario,
    String nombrePlaza,
    String plazaId,
    String fecha,
    String estadoGeneral,
    String resumenProblemas,
  ) async {
    try {
      final nombreInspector = _nombreSupervisorController.text.trim();
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
Sistema de Inspección de Áreas Verdes''');

      final outlookUrl =
          'https://outlook.office.com/mail/deeplink/compose?to=$destinatario&subject=$asunto&body=$cuerpo';
      final uri = Uri.parse(outlookUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('No se pudo abrir Outlook en el navegador');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
    contarEstados(_evaluacionesCatastroInmuebles);

    if (totalMalos > 5) return 'Malo';
    if (totalMalos > 0 || totalRegulares > 10) return 'Regular';
    return 'Bueno';
  }

  Future<void> _seleccionarFoto(String seccion) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> imagenes = await picker.pickMultiImage(
        imageQuality: 85,
      );

      if (imagenes.isNotEmpty) {
        setState(() {
          for (var imagen in imagenes) {
            _imagenesPorSeccion[seccion]?.add({
              'archivo': imagen,
              'titulo': '',
            });
          }
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

  void _eliminarFoto(String seccion, int index) {
    setState(() {
      _imagenesPorSeccion[seccion]?.removeAt(index);
    });
  }

  void _actualizarTituloFoto(String seccion, int index, String nuevoTitulo) {
    setState(() {
      if (_imagenesPorSeccion[seccion] != null &&
          index < _imagenesPorSeccion[seccion]!.length) {
        _imagenesPorSeccion[seccion]![index]['titulo'] = nuevoTitulo;
      }
    });
  }

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
          Row(
            children: [
              const Icon(Icons.camera_alt, color: Color(0xFF1565C0), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Evidencia Fotográfica',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF212121),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _seleccionarFoto(seccion),
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: const Text('Agregar Fotos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          if (fotos.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fotos.length,
                itemBuilder: (context, index) {
                  final fotoData = fotos[index];
                  final XFile archivo = fotoData['archivo'] as XFile;
                  final String tituloActual =
                      fotoData['titulo'] as String? ?? '';

                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 140,
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
                                      width: 140,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(archivo.path),
                                      width: 140,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _eliminarFoto(seccion, index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          initialValue: tituloActual,
                          style: const TextStyle(fontSize: 11),
                          decoration: const InputDecoration(
                            hintText: 'Nota foto...',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) =>
                              _actualizarTituloFoto(seccion, index, value),
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

  Map<String, String> _extraerTexto(
    Map<String, TextEditingController> controladores,
  ) {
    return controladores.map(
      (key, controller) => MapEntry(key, controller.text),
    );
  }

  Map<String, dynamic> _prepararDatosInspeccion() {
    return {
      'plazaId': widget.plazaId,
      'nombrePlaza': widget.nombrePlaza,
      'correoSupervisor': _correoJefeController.text,
      'fechaHora': DateTime.now().toIso8601String(),
      'allEvaluations': {
        'ASEO': _evaluacionesAseo,
        'CÉSPED': _evaluacionesCesped,
        'ARBOLADO': _evaluacionesArbolado,
        'FLORES': _evaluacionesFlores,
        'CAMINOS': _evaluacionesCaminos,
        'INFRAESTRUCTURA': _evaluacionesInfraestructura,
        'CATASTRO DE INMUEBLE DE AREAS VERDES': _evaluacionesCatastroInmuebles,
      },
      'allCriteria': {
        'ASEO': _criteriosAseo,
        'CÉSPED': _criteriosCesped,
        'ARBOLADO': _criteriosArbolado,
        'FLORES': _criteriosFlores,
        'CAMINOS': _criteriosCaminos,
        'INFRAESTRUCTURA': _criteriosInfraestructura,
        'CATASTRO DE INMUEBLE DE AREAS VERDES': _criteriosCatastroInmuebles,
      },
      'allObservations': {
        'ASEO': _extraerTexto(_observacionesAseo),
        'CÉSPED': _extraerTexto(_observacionesCesped),
        'ARBOLADO': _extraerTexto(_observacionesArbolado),
        'FLORES': _extraerTexto(_observacionesFlores),
        'CAMINOS': _extraerTexto(_observacionesCaminos),
        'INFRAESTRUCTURA': _extraerTexto(_observacionesInfraestructura),
        'CATASTRO DE INMUEBLE DE AREAS VERDES': _extraerTexto(
          _observacionesCatastroInmuebles,
        ),
      },
    };
  }

  InspectionData _compilarDatosInspeccion() {
    final sections = <String, EvaluationSection>{
      'ASEO': EvaluationSection(
        title: 'ASEO',
        criteria: _criteriosAseo,
        evaluations: _evaluacionesAseo,
        observations: _observacionesAseo.map((k, v) => MapEntry(k, v.text)),
      ),
      'CÉSPED': EvaluationSection(
        title: 'CÉSPED',
        criteria: _criteriosCesped,
        evaluations: _evaluacionesCesped,
        observations: _observacionesCesped.map((k, v) => MapEntry(k, v.text)),
      ),
      'ARBOLADO': EvaluationSection(
        title: 'ARBOLADO',
        criteria: _criteriosArbolado,
        evaluations: _evaluacionesArbolado,
        observations: _observacionesArbolado.map((k, v) => MapEntry(k, v.text)),
      ),
      'FLORES': EvaluationSection(
        title: 'FLORES',
        criteria: _criteriosFlores,
        evaluations: _evaluacionesFlores,
        observations: _observacionesFlores.map((k, v) => MapEntry(k, v.text)),
      ),
      'CAMINOS': EvaluationSection(
        title: 'CAMINOS',
        criteria: _criteriosCaminos,
        evaluations: _evaluacionesCaminos,
        observations: _observacionesCaminos.map((k, v) => MapEntry(k, v.text)),
      ),
      'INFRAESTRUCTURA': EvaluationSection(
        title: 'INFRAESTRUCTURA',
        criteria: _criteriosInfraestructura,
        evaluations: _evaluacionesInfraestructura,
        observations: _observacionesInfraestructura.map(
          (k, v) => MapEntry(k, v.text),
        ),
      ),
      'CATASTRO DE INMUEBLE DE AREAS VERDES': EvaluationSection(
        title: 'CATASTRO DE INMUEBLE DE AREAS VERDES',
        criteria: _criteriosCatastroInmuebles,
        evaluations: _evaluacionesCatastroInmuebles,
        observations: _observacionesCatastroInmuebles.map(
          (k, v) => MapEntry(k, v.text),
        ),
      ),
    };

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
              Text(
                'Catastro Inmuebles: ${evaluaciones['catastroInmuebles']?.length ?? 0} ítems',
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
}
