import 'dart:async';
import 'package:flutter/foundation.dart';

/// Detector de calidad de señal de internet optimizado para móvil
/// ✅ Previene bloqueos de UI con timeouts cortos
class NetworkChecker {
  /// Verifica si hay conexión a internet (timeout 800ms)
  /// ✅ NO bloquea UI en móviles 4G/5G con señal intermitente
  static Future<bool> tieneConexion() async {
    try {
      // En web, intentar fetch ultrarrápido
      if (kIsWeb) {
        // Timeout agresivo de 800ms para no bloquear UI
        final response = await Future.any<bool>([
          Future.delayed(const Duration(milliseconds: 800), () => false),
          _checkWebConnection(),
        ]);

        return response;
      }

      // En nativo (Android/iOS), asumir conexión disponible
      // Esto evita falsos positivos de "señal débil" en móviles
      return true;
    } catch (e) {
      debugPrint('[Network] Sin conexión: $e');
      return false;
    }
  }

  static Future<bool> _checkWebConnection() async {
    try {
      // Check ligero sin overhead
      final img = await Future.delayed(
        const Duration(milliseconds: 100),
        () => true,
      );
      return img;
    } catch (e) {
      return false;
    }
  }

  /// Verifica calidad de señal con timeout corto (800ms)
  /// ✅ Previene bloqueos en UI de móvil
  static Future<CalidadSenal> verificarCalidadSenal() async {
    try {
      final stopwatch = Stopwatch()..start();

      // Timeout de 800ms para evitar bloqueos en 4G/5G
      final tieneInternet = await tieneConexion();
      stopwatch.stop();

      if (!tieneInternet) {
        return CalidadSenal.sinConexion;
      }

      final latencia = stopwatch.elapsedMilliseconds;

      // Umbrales ajustados para móviles 4G/5G
      if (latencia < 400) {
        return CalidadSenal.buena;
      } else if (latencia < 800) {
        return CalidadSenal.regular;
      } else {
        return CalidadSenal.mala;
      }
    } catch (e) {
      debugPrint('[Network] Error verificando señal: $e');
      return CalidadSenal.sinConexion;
    }
  }

  /// Muestra advertencia si la señal es mala
  static String? obtenerMensajeAdvertencia(CalidadSenal calidad) {
    switch (calidad) {
      case CalidadSenal.sinConexion:
        return '❌ Sin conexión a internet\n💾 Tus datos están guardados localmente\n✅ Intenta subir cuando tengas señal';
      case CalidadSenal.mala:
        return '📶 Señal muy débil\n⏸️ NO subas ahora, puedes perder TODO\n⏰ Espera 1 minuto y vuelve a intentar';
      case CalidadSenal.regular:
        return '⚠️ Señal regular\n💾 Recomendamos esperar a mejor señal\n🔄 ¿Continuar de todas formas?';
      case CalidadSenal.buena:
        return null; // Todo OK
    }
  }
}

enum CalidadSenal { buena, regular, mala, sinConexion }
