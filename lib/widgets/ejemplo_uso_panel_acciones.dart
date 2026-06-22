import 'package:flutter/material.dart';
import 'panel_acciones_finales.dart';

/// Este es un ejemplo de cómo usar el PanelAccionesFinales
/// en tu InspeccionTecnicaScreen
///
/// Copia este código al final de tu build() en InspeccionTecnicaScreen,
/// justo después del TabBarView dentro de la Column principal

class EjemploUsoPanelAcciones extends StatefulWidget {
  const EjemploUsoPanelAcciones({super.key});

  @override
  State<EjemploUsoPanelAcciones> createState() =>
      _EjemploUsoPanelAccionesState();
}

class _EjemploUsoPanelAccionesState extends State<EjemploUsoPanelAcciones> {
  // Declara este controller en tu State
  final TextEditingController _correoJefeController = TextEditingController();

  @override
  void dispose() {
    _correoJefeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ejemplo Panel de Acciones'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Aquí irían las pestañas y el contenido de tu formulario
            Container(
              height: 300,
              color: Colors.grey.shade200,
              child: const Center(
                child: Text(
                  'Aquí van las pestañas de evaluación\n(ASEO, CÉSPED, etc.)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),

            // Panel de acciones finales al final del formulario
            PanelAccionesFinales(correoJefeController: _correoJefeController),

            // Espacio adicional para mejor visualización
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/* 
 * INSTRUCCIONES DE INTEGRACIÓN EN InspeccionTecnicaScreen:
 * 
 * 1. Agrega el import al inicio del archivo:
 *    import '../widgets/panel_acciones_finales.dart';
 * 
 * 2. Declara el controller en tu State:
 *    final TextEditingController _correoJefeController = TextEditingController();
 * 
 * 3. No olvides hacer dispose del controller:
 *    @override
 *    void dispose() {
 *      _correoJefeController.dispose();
 *      _tabController.dispose();
 *      super.dispose();
 *    }
 * 
 * 4. Modifica tu build() para que la Column principal esté dentro de un SingleChildScrollView:
 * 
 *    body: SingleChildScrollView(
 *      child: Column(
 *        children: [
 *          _buildTablaInformacion(),
 *          
 *          // TabBar y TabBarView con height fijo
 *          Container(
 *            height: MediaQuery.of(context).size.height * 0.5, // Ajusta según necesites
 *            child: Column(
 *              children: [
 *                Container(...TabBar...),
 *                Expanded(child: TabBarView(...)),
 *              ],
 *            ),
 *          ),
 *          
 *          // Panel de acciones finales
 *          PanelAccionesFinales(
 *            correoJefeController: _correoJefeController,
 *          ),
 *        ],
 *      ),
 *    )
 */
