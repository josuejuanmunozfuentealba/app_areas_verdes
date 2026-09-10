import 'package:flutter/material.dart';
import '../models/modo_inspeccion.dart';
import '../main.dart' show PantallaMapa;

class ModoSeleccionScreen extends StatelessWidget {
  const ModoSeleccionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  const Icon(Icons.park, size: 80, color: Colors.white),
                  const SizedBox(height: 16),

                  // Título
                  const Text(
                    'Áreas Verdes Doñihue',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Selecciona el tipo de inspección',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),

                  const SizedBox(height: 60),

                  // Botón 1: Áreas Verdes
                  _buildModoButton(
                    context: context,
                    icon: Icons.nature,
                    modo: ModoInspeccion.areasVerdes,
                    color: const Color(0xFF2E7D32),
                  ),

                  const SizedBox(height: 20),

                  // Botón 2: Catastro de Inmuebles
                  _buildModoButton(
                    context: context,
                    icon: Icons.chair_outlined,
                    modo: ModoInspeccion.inmuebles,
                    color: const Color(0xFF1565C0),
                  ),

                  const SizedBox(height: 20),

                  // Botón 3: Inspección de Urgencia
                  _buildModoButton(
                    context: context,
                    icon: Icons.warning_amber,
                    modo: ModoInspeccion.urgencias,
                    color: const Color(0xFFD32F2F),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModoButton({
    required BuildContext context,
    required IconData icon,
    required ModoInspeccion modo,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        debugPrint('🔘 [ModoSeleccion] Botón presionado: ${modo.nombre}');
        debugPrint(
          '🔘 [ModoSeleccion] Navegando directo con MaterialPageRoute',
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaMapa(modoInicial: modo),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    modo.nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    modo.descripcion,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9E9E9E),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
