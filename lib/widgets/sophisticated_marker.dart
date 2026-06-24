import 'package:flutter/material.dart';

/// Marcador sofisticado con diseño premium para mapas
///
/// Características:
/// - Diseño circular flotante con sombra difuminada
/// - Efecto de glow/radar en la base
/// - Flecha inferior que apunta al mapa
/// - Personalizable con icono y color de acento
/// - Estado seleccionado con escala y sombra pronunciada
class SophisticatedMarker extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final double size;
  final bool isSelected;

  const SophisticatedMarker({
    super.key,
    required this.icon,
    this.accentColor = const Color(0xFF2F855A),
    this.size = 56.0,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // Escala y color más intenso cuando está seleccionado
    final scale = isSelected ? 1.2 : 1.0;
    final effectiveColor = isSelected
        ? Color.fromRGBO(
            ((accentColor.r * 255.0).round().clamp(0, 255) * 0.8).round(),
            ((accentColor.g * 255.0).round().clamp(0, 255) * 0.8).round(),
            ((accentColor.b * 255.0).round().clamp(0, 255) * 0.8).round(),
            1,
          )
        : accentColor;

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: SizedBox(
        width: size,
        height: size + 12, // +12 para la flecha
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Efecto de glow/radar en la base
            Positioned(
              bottom: 0,
              child: Container(
                width: size * 0.6,
                height: size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      effectiveColor.withValues(alpha: 0.3),
                      effectiveColor.withValues(alpha: 0.1),
                      effectiveColor.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Marcador principal con flecha
            Positioned(
              top: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Círculo principal con sombra pronunciada
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? effectiveColor
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 3 : 2,
                      ),
                      boxShadow: [
                        // Sombra pronunciada para efecto de profundidad
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isSelected ? 0.25 : 0.08,
                          ),
                          blurRadius: isSelected ? 24 : 16,
                          spreadRadius: 0,
                          offset: Offset(0, isSelected ? 8 : 4),
                        ),
                        BoxShadow(
                          color: effectiveColor.withValues(
                            alpha: isSelected ? 0.35 : 0.15,
                          ),
                          blurRadius: isSelected ? 32 : 24,
                          spreadRadius: isSelected ? 0 : -4,
                          offset: Offset(0, isSelected ? 12 : 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: effectiveColor,
                        size: size * 0.5,
                      ),
                    ),
                  ),

                  // Flecha inferior (triángulo)
                  CustomPaint(
                    size: Size(size * 0.3, 12),
                    painter: _ArrowPainter(
                      color: Colors.white,
                      borderColor: isSelected
                          ? effectiveColor
                          : const Color(0xFFE2E8F0),
                      borderWidth: isSelected ? 3 : 2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter para dibujar la flecha inferior del marcador
class _ArrowPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  _ArrowPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = Path()
      ..moveTo(size.width * 0.2, 0) // Punto superior izquierdo
      ..lineTo(size.width * 0.5, size.height) // Punto inferior (punta)
      ..lineTo(size.width * 0.8, 0) // Punto superior derecho
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
