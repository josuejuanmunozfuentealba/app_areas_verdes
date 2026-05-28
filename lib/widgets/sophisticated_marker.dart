import 'package:flutter/material.dart';

/// Marcador sofisticado con diseño premium para mapas
///
/// Características:
/// - Diseño circular flotante con sombra difuminada
/// - Efecto de glow/radar en la base
/// - Flecha inferior que apunta al mapa
/// - Personalizable con icono y color de acento
class SophisticatedMarker extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final double size;

  const SophisticatedMarker({
    super.key,
    required this.icon,
    this.accentColor = const Color(0xFF2F855A),
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                    accentColor.withOpacity(0.3),
                    accentColor.withOpacity(0.1),
                    accentColor.withOpacity(0.0),
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
                // Círculo principal con sombra
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: accentColor.withOpacity(0.15),
                        blurRadius: 24,
                        spreadRadius: -4,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: accentColor, size: size * 0.5),
                  ),
                ),

                // Flecha inferior (triángulo)
                CustomPaint(
                  size: Size(size * 0.3, 12),
                  painter: _ArrowPainter(
                    color: Colors.white,
                    borderColor: const Color(0xFFE2E8F0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter para dibujar la flecha inferior del marcador
class _ArrowPainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _ArrowPainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

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
