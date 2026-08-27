import 'package:flutter/material.dart';

/// Widget responsivo para las filas de evaluación
/// En móviles (<650px): Card con SegmentedButton táctil
/// En escritorio (>=650px): Formato de tabla horizontal clásica
class FilaEvaluacionResponsiva extends StatelessWidget {
  final String criterio;
  final String? evaluacionActual;
  final Function(String?) onEvaluacionChanged;
  final TextEditingController observacionController;

  const FilaEvaluacionResponsiva({
    super.key,
    required this.criterio,
    required this.evaluacionActual,
    required this.onEvaluacionChanged,
    required this.observacionController,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 650;

    return isMobile ? _buildMobileLayout() : _buildDesktopLayout();
  }

  // ============================================================================
  // DISEÑO MÓVIL: Card con SegmentedButton
  // ============================================================================
  Widget _buildMobileLayout() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del criterio
            Text(
              criterio,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 12),

            // SegmentedButton para evaluación
            SizedBox(
              width: double.infinity,
              height: 44, // Altura táctil mínima accesible
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment<String>(
                    value: 'Bueno',
                    label: Text('Bueno', style: TextStyle(fontSize: 13)),
                    icon: Icon(Icons.check_circle, size: 18),
                  ),
                  ButtonSegment<String>(
                    value: 'Regular',
                    label: Text('Regular', style: TextStyle(fontSize: 13)),
                    icon: Icon(Icons.warning, size: 18),
                  ),
                  ButtonSegment<String>(
                    value: 'Malo',
                    label: Text('Malo', style: TextStyle(fontSize: 13)),
                    icon: Icon(Icons.cancel, size: 18),
                  ),
                ],
                selected: evaluacionActual != null
                    ? {evaluacionActual!}
                    : <String>{},
                onSelectionChanged: (Set<String> newSelection) {
                  if (newSelection.isNotEmpty) {
                    onEvaluacionChanged(newSelection.first);
                  }
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Campo de observaciones
            TextField(
              controller: observacionController,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
                hintText: 'Añade detalles si es necesario...',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.all(10),
              ),
              maxLines: 2,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // DISEÑO ESCRITORIO: Tabla horizontal
  // ============================================================================
  Widget _buildDesktopLayout() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Criterio (flex: 5)
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                color: Colors.grey.shade50,
              ),
              child: Text(
                criterio,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Bueno (flex: 1)
          Expanded(
            flex: 1,
            child: _buildRadioCell('Bueno', const Color(0xFF2E7D32)),
          ),

          // Regular (flex: 1)
          Expanded(
            flex: 1,
            child: _buildRadioCell('Regular', const Color(0xFFF57C00)),
          ),

          // Malo (flex: 1)
          Expanded(
            flex: 1,
            child: _buildRadioCell('Malo', const Color(0xFFD32F2F)),
          ),

          // Observaciones (flex: 4)
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: observacionController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: 'Observaciones...',
                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: 1,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioCell(String valor, Color color) {
    final isSelected = evaluacionActual == valor;

    return GestureDetector(
      onTap: () => onEvaluacionChanged(valor),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
        ),
        child: Center(
          child: Radio<String>(
            value: valor,
            groupValue: evaluacionActual,
            onChanged: onEvaluacionChanged,
            activeColor: color,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
        ),
      ),
    );
  }
}
