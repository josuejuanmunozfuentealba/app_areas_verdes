import 'package:flutter/material.dart';
import '../widgets/fila_evaluacion_widget.dart';

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

  // Mapas de estado para cada sección
  final Map<String, String?> _evaluacionesAseo = {};
  final Map<String, String?> _evaluacionesCesped = {};

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      body: Column(
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

          // Contenido de las pestañas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSeccionAseo(),
                _buildSeccionCesped(),
                _buildSeccionTemporal('ARBOLADO'),
                _buildSeccionTemporal('FLORES'),
                _buildSeccionTemporal('CAMINOS'),
                _buildSeccionTemporal('INFRAESTRUCTURA'),
              ],
            ),
          ),
        ],
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
            color: Colors.black.withValues(alpha: 0.05),
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

  // Widget temporal para cada sección mientras está en desarrollo
  Widget _buildSeccionTemporal(String nombreSeccion) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.construction, size: 64, color: Colors.orange.shade400),
              const SizedBox(height: 16),
              Text(
                'Sección $nombreSeccion en desarrollo',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Esta pestaña estará disponible próximamente',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
