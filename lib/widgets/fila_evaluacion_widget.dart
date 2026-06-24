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
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Columna del criterio (texto) - Más espacio para criterios largos
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: Text(
                textoCriterio,
                style: const TextStyle(
                  fontSize: 11.0,
                  color: Color(0xFF424242),
                  height: 1.2,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ),

          // Columna BUENO
          Expanded(
            flex: 1,
            child: Radio<String>(
              value: 'Bueno',
              groupValue: valorSeleccionado,
              onChanged: onChanged,
              activeColor: const Color(0xFF2E7D32),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
          ),

          // Columna REGULAR
          Expanded(
            flex: 1,
            child: Radio<String>(
              value: 'Regular',
              groupValue: valorSeleccionado,
              onChanged: onChanged,
              activeColor: const Color(0xFFF57C00),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
          ),

          // Columna MALO
          Expanded(
            flex: 1,
            child: Radio<String>(
              value: 'Malo',
              groupValue: valorSeleccionado,
              onChanged: onChanged,
              activeColor: const Color(0xFFC62828),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
          ),

          // Campo de observaciones - Proporción flexible
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 8),
              child: TextField(
                controller: controllerObs,
                decoration: InputDecoration(
                  hintText: 'Obs...',
                  hintStyle: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFFAFAFA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 11, color: Color(0xFF424242)),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
