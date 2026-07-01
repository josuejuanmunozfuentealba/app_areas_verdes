import 'package:flutter/material.dart';

/// Widget reutilizable para una fila de evaluación técnica
///
/// Diseño adaptativo: VERTICAL en móvil (<600px), HORIZONTAL en web/tablet
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Detectar si es móvil (< 600px) o web/tablet (>= 600px)
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          // ============================================================
          // DISEÑO VERTICAL PARA MÓVIL (APK)
          // ============================================================
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ARRIBA: Texto del criterio
                  Text(
                    textoCriterio,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                      height: 1.3,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),

                  const SizedBox(height: 12),

                  // CENTRO: Radio Buttons espaciados
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // BUENO
                      Expanded(
                        child: InkWell(
                          onTap: () => onChanged('Bueno'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: valorSeleccionado == 'Bueno'
                                  ? const Color(
                                      0xFF2E7D32,
                                    ).withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: valorSeleccionado == 'Bueno'
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey.shade300,
                                width: valorSeleccionado == 'Bueno' ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Radio<String>(
                                  value: 'Bueno',
                                  groupValue: valorSeleccionado,
                                  onChanged: onChanged,
                                  activeColor: const Color(0xFF2E7D32),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const Text(
                                  'Bueno',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // REGULAR
                      Expanded(
                        child: InkWell(
                          onTap: () => onChanged('Regular'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: valorSeleccionado == 'Regular'
                                  ? const Color(
                                      0xFFF57C00,
                                    ).withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: valorSeleccionado == 'Regular'
                                    ? const Color(0xFFF57C00)
                                    : Colors.grey.shade300,
                                width: valorSeleccionado == 'Regular' ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Radio<String>(
                                  value: 'Regular',
                                  groupValue: valorSeleccionado,
                                  onChanged: onChanged,
                                  activeColor: const Color(0xFFF57C00),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const Text(
                                  'Regular',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF57C00),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // MALO
                      Expanded(
                        child: InkWell(
                          onTap: () => onChanged('Malo'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: valorSeleccionado == 'Malo'
                                  ? const Color(
                                      0xFFC62828,
                                    ).withValues(alpha: 0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: valorSeleccionado == 'Malo'
                                    ? const Color(0xFFC62828)
                                    : Colors.grey.shade300,
                                width: valorSeleccionado == 'Malo' ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Radio<String>(
                                  value: 'Malo',
                                  groupValue: valorSeleccionado,
                                  onChanged: onChanged,
                                  activeColor: const Color(0xFFC62828),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const Text(
                                  'Malo',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFC62828),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ABAJO: Campo de observaciones
                  TextField(
                    controller: controllerObs,
                    decoration: InputDecoration(
                      labelText: 'Observaciones',
                      hintText: 'Escribe aquí tus observaciones...',
                      hintStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1565C0),
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
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF424242),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        } else {
          // ============================================================
          // DISEÑO HORIZONTAL PARA WEB/TABLET
          // ============================================================
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
                // Columna del criterio (texto)
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

                // Radio BUENO
                Expanded(
                  flex: 1,
                  child: Radio<String>(
                    value: 'Bueno',
                    groupValue: valorSeleccionado,
                    onChanged: onChanged,
                    activeColor: const Color(0xFF2E7D32),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                  ),
                ),

                // Radio REGULAR
                Expanded(
                  flex: 1,
                  child: Radio<String>(
                    value: 'Regular',
                    groupValue: valorSeleccionado,
                    onChanged: onChanged,
                    activeColor: const Color(0xFFF57C00),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                  ),
                ),

                // Radio MALO
                Expanded(
                  flex: 1,
                  child: Radio<String>(
                    value: 'Malo',
                    groupValue: valorSeleccionado,
                    onChanged: onChanged,
                    activeColor: const Color(0xFFC62828),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                  ),
                ),

                // Campo de observaciones
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
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF424242),
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
