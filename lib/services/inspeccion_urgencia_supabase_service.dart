import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;

/// Servicio para interactuar con Supabase en el módulo de Inspección de Urgencia
class InspeccionUrgenciaSupabaseService {
  final _supabase = Supabase.instance.client;

  /// Guarda una inspección de urgencia completa en Supabase
  /// 1. Sube el PDF al bucket
  /// 2. Inserta el registro en la tabla
  /// 3. 🔥 Actualiza estado_urgencias en tabla plazas
  Future<Map<String, dynamic>> guardarInspeccionUrgencia({
    required String plazaId,
    required String nombrePlaza,
    required String inspector,
    required DateTime fechaHora,
    required Map<String, String?> evaluaciones,
    required Map<String, String> observaciones,
    required List<int> pdfBytes,
  }) async {
    try {
      // Generar nombre único para el archivo
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(fechaHora);
      final plazaLimpio = nombrePlaza
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ñ', 'n')
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');

      final pdfFileName =
          'inspeccion_urgencia_${plazaLimpio}_${plazaId}_$timestamp.pdf';

      // Convertir List<int> a Uint8List
      final pdfUint8 = Uint8List.fromList(pdfBytes);

      // 1. Subir PDF
      await _supabase.storage
          .from('reportes-urgencia')
          .uploadBinary(pdfFileName, pdfUint8);

      // 2. Obtener URL pública
      final pdfUrl = _supabase.storage
          .from('reportes-urgencia')
          .getPublicUrl(pdfFileName);

      // Calcular estado general basado en evaluaciones
      final estadoGeneral = _calcularEstadoGeneral(evaluaciones);

      // Formatear fecha legible
      final fechaLegible = DateFormat('dd/MM/yyyy HH:mm:ss').format(fechaHora);

      // Sanitizar evaluaciones y observaciones (eliminar nulls)
      final evaluacionesLimpias = <String, String>{};
      evaluaciones.forEach((key, value) {
        if (value != null && value.isNotEmpty) {
          evaluacionesLimpias[key] = value;
        }
      });

      final observacionesLimpias = <String, String>{};
      observaciones.forEach((key, value) {
        if (value.isNotEmpty) {
          observacionesLimpias[key] = value;
        }
      });

      // 3. Insertar registro en la tabla
      final data = {
        'plaza_id': plazaId,
        'nombre_plaza': nombrePlaza,
        'inspector': inspector,
        'fecha_hora_registro': fechaHora.toIso8601String(),
        'fecha_legible': fechaLegible,
        'estado_general': estadoGeneral,
        'evaluaciones': evaluacionesLimpias,
        'observaciones': observacionesLimpias,
        'pdf_url': pdfUrl,
        'correo_enviado': false,
        'fecha_envio_correo': null,
      };

      final response = await _supabase
          .from('inspecciones_urgencia')
          .insert(data)
          .select()
          .single();

      // 🔥 ACTUALIZAR el campo 'estado_urgencias' en la tabla 'plazas'
      try {
        await _supabase
            .from('plazas')
            .update({'estado_urgencias': estadoGeneral})
            .eq('id', plazaId);
        debugPrint('[Supabase] ✅ estado_urgencias actualizado: $estadoGeneral');
      } catch (e) {
        debugPrint('[Supabase] ⚠️ Error al actualizar estado_urgencias: $e');
      }

      return {
        'success': true,
        'message': 'Inspección de urgencia guardada exitosamente',
        'id': response['id'],
        'pdf_url': pdfUrl,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error al guardar: ${e.toString()}'};
    }
  }

  /// Calcula el estado general basado en las evaluaciones
  /// Lógica: >= 2 Malo = Rojo | 1 Malo o >= 3 Regular = Naranja | Resto = Azul
  String _calcularEstadoGeneral(Map<String, String?> evaluaciones) {
    int totalMalos = 0;
    int totalRegulares = 0;

    evaluaciones.forEach((key, value) {
      final estado = value?.toLowerCase() ?? '';
      if (estado == 'malo' || estado == 'crítico' || estado == 'critico') {
        totalMalos++;
      } else if (estado == 'regular') {
        totalRegulares++;
      }
    });

    // Lógica Moderada (Opción B)
    if (totalMalos >= 2) {
      return 'Malo';
    } else if (totalMalos == 1 || totalRegulares >= 3) {
      return 'Regular';
    } else {
      return 'Bueno';
    }
  }
}
