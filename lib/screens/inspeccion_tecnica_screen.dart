import 'package:flutter/material.dart';

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
                _buildSeccionTemporal('ASEO'),
                _buildSeccionTemporal('CÉSPED'),
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
      child: Column(
        children: [
          // Encabezado con logos
          Row(
            children: [
              // Logo izquierdo (placeholder)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance,
                  size: 30,
                  color: Color(0xFF1565C0),
                ),
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
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Logo derecho (placeholder)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.park,
                  size: 30,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
    );
  }

  // Widget auxiliar para construir filas de la tabla
  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
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
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
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
