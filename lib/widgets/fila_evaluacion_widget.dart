import 'package:flutter/material.dart';

/// Widget reutilizable para una fila de evaluación técnica
///
/// Muestra un criterio de evaluación con tres opciones de radio button:
/// BUENO, REGULAR, MALO, y un campo de texto para observaciones
class FilaEvaluacionWidget extends StatelessWidget {
  /// Texto del criterio a evaluar
  final String textoCriterio;

  /// Valor actualmente seleccionado ('Bueno', 'Regular', 'Malo' o null)
  final String? valorSeleccionado;

  /// Callback que se ejecuta cuando se selecciona una opción
  final Function(String?) onChanged;

  /// Controller para el campo de observaciones (opcional)
  final TextEditingController? controllerObs;

  const FilaEvaluacionWidget({
    super.key,
    required this.textoCriterio,
    required this.valorSeleccionado,
    required this.onChanged,
    this.controllerObs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Columna del criterio (texto)
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                textoCriterio,
                style: const TextStyle(fontSize: 14, color: Color(0xFF424242)),
              ),
            ),
          ),

          // Columna BUENO
          SizedBox(
            width: 100,
            child: Center(
              child: Radio<String>(
                value: 'Bueno',
                groupValue: valorSeleccionado,
                onChanged: onChanged,
                activeColor: const Color(0xFF2E7D32),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

          // Columna REGULAR
          SizedBox(
            width: 100,
            child: Center(
              child: Radio<String>(
                value: 'Regular',
                groupValue: valorSeleccionado,
                onChanged: onChanged,
                activeColor: const Color(0xFFF57C00),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

          // Columna MALO
          SizedBox(
            width: 100,
            child: Center(
              child: Radio<String>(
                value: 'Malo',
                groupValue: valorSeleccionado,
                onChanged: onChanged,
                activeColor: const Color(0xFFC62828),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),

          // Espacio antes del campo de observaciones
          const SizedBox(width: 20),

          // Campo de observaciones
          SizedBox(
            width: 280,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: TextField(
                controller: controllerObs,
                decoration: InputDecoration(
                  hintText: 'Observaciones...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
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
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 13, color: Color(0xFF424242)),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
