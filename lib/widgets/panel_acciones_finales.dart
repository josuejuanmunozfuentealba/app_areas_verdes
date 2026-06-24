import 'package:flutter/material.dart';

class PanelAccionesFinales extends StatelessWidget {
  final TextEditingController nombreSupervisorController;
  final TextEditingController correoSupervisorController;
  final VoidCallback onGuardarHistorial;
  final VoidCallback onVerHistorial;
  final VoidCallback onExportarPDF;
  final VoidCallback onExportarWord;
  final VoidCallback onEnviarReporte;

  const PanelAccionesFinales({
    super.key,
    required this.nombreSupervisorController,
    required this.correoSupervisorController,
    required this.onGuardarHistorial,
    required this.onVerHistorial,
    required this.onExportarPDF,
    required this.onExportarWord,
    required this.onEnviarReporte,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título del panel
            Row(
              children: [
                Icon(Icons.settings, color: const Color(0xFF1565C0), size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Acciones Finales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF212121),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Campo de nombre del inspector
            TextField(
              controller: nombreSupervisorController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                labelText: 'Nombre del Inspector',
                labelStyle: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 14,
                ),
                hintText: 'Ej: Juan Pérez',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF1565C0),
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF1565C0),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Campo de correo para envío
            TextField(
              controller: correoSupervisorController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico del Inspector',
                labelStyle: const TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 14,
                ),
                hintText: 'ejemplo@correo.com',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF1565C0),
                  size: 20,
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFF1565C0),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Texto descriptivo
            const Text(
              'Opciones disponibles:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF424242),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 16),

            // Botones de acción en cuadrícula (Wrap)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: [
                // Botón: Guardar en Historial
                _buildBotonAccion(
                  icon: Icons.save,
                  label: 'Guardar en\nHistorial',
                  color: const Color(0xFF2E7D32), // Verde
                  onPressed: onGuardarHistorial,
                ),

                // Botón: Ver Historial
                _buildBotonAccion(
                  icon: Icons.history,
                  label: 'Ver\nHistorial',
                  color: const Color(0xFF1565C0), // Azul
                  onPressed: onVerHistorial,
                ),

                // Botón: Descargar PDF
                _buildBotonAccion(
                  icon: Icons.picture_as_pdf,
                  label: 'Descargar\nPDF',
                  color: const Color(0xFFD32F2F), // Rojo
                  onPressed: onExportarPDF,
                ),

                // Botón: Descargar Word
                _buildBotonAccion(
                  icon: Icons.description,
                  label: 'Descargar\nWord',
                  color: const Color(0xFF1976D2), // Azul Word
                  onPressed: onExportarWord,
                ),

                // Botón: Enviar Reporte
                _buildBotonAccion(
                  icon: Icons.send,
                  label: 'Enviar\nReporte',
                  color: const Color(0xFFF57C00), // Naranja
                  onPressed: onEnviarReporte,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para construir cada botón de acción
  Widget _buildBotonAccion({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 110,
      height: 100,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 8),
                // Texto
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                      height: 1.2,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
