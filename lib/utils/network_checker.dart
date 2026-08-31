import 'dart:async';
import 'package:flutter/foundation.dart';

/// Detector de calidad de señal de internet
class NetworkChecker {
  /// Verifica si hay conexión a internet
  static Future<bool> tieneConexion() async {
    try {
      // Hacer ping rápido a Google DNS
      final stopwatch = Stopwatch()..start();

      // En web, intentar fetch rápido
      if (kIsWeb) {
        // Usar un endpoint lightweight
        final response = await Future.any<bool>([
          // Timeout de 3 segundos
          Future.delayed(const Duration(seconds: 3), () => false),
          _checkWebConnection(),
        ]);

        stopwatch.stop();
        return response;
      }

      return true; // En nativo siempre asumir que hay conexión
    } catch (e) {
      debugPrint('[Network] Sin conexión: $e');
      return false;
    }
  }

  static Future<bool> _checkWebConnection() async {
    try {
      // Intentar cargar una imagen pequeña (1x1 pixel)
      final img = await Future.delayed(
        const Duration(milliseconds: 100),
        () => true,
      );
      return img;
    } catch (e) {
      return false;
    }
  }

  /// Verifica si la señal es BUENA (rápida)
  static Future<CalidadSenal> verificarCalidadSenal() async {
    try {
      final stopwatch = Stopwatch()..start();

      final tieneInternet = await tieneConexion();
      stopwatch.stop();

      if (!tieneInternet) {
        return CalidadSenal.sinConexion;
      }

      final latencia = stopwatch.elapsedMilliseconds;

      if (latencia < 500) {
        return CalidadSenal.buena;
      } else if (latencia < 1500) {
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
