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
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 22,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título del panel
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: Color(0xFF1565C0),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Acciones Finales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
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
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF1565C0),
                    width: 1.8,
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
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF1565C0),
                    width: 1.8,
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
      width: 112,
      height: 104,
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
