import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class UrgenciaSupabaseService {
  final _supabase = Supabase.instance.client;

  /// Guarda inspección de urgencia en Supabase
  Future<Map<String, dynamic>> guardarInspeccion({
    required String plazaId,
    required String nombrePlaza,
    required String titulo,
    required String inspector,
    required DateTime fechaHora,
    required Map<String, String> campos,
    required List<String> observaciones,
    required Uint8List pdfBytes,
    Uint8List? docxBytes,
  }) async {
    try {
      debugPrint('[Urgencia Supabase] Guardando inspección...');

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // 1. Subir PDF
      final pdfFileName = 'urgencia_${plazaId}_$timestamp.pdf';
      await _supabase.storage
          .from('reportes-urgencia')
          .uploadBinary(pdfFileName, pdfBytes);

      final pdfUrl = _supabase.storage
          .from('reportes-urgencia')
          .getPublicUrl(pdfFileName);

      debugPrint('[Urgencia Supabase] ✅ PDF subido: $pdfUrl');

      // 2. Subir Word (si existe)
      String? wordUrl;
      if (docxBytes != null) {
        final wordFileName = 'urgencia_${plazaId}_$timestamp.docx';
        await _supabase.storage
            .from('reportes-urgencia')
            .uploadBinary(wordFileName, docxBytes);

        wordUrl = _supabase.storage
            .from('reportes-urgencia')
            .getPublicUrl(wordFileName);

        debugPrint('[Urgencia Supabase] ✅ Word subido: $wordUrl');
      }

      // 3. Insertar en base de datos
      final datos = {
        'plaza_id': plazaId,
        'nombre_plaza': nombrePlaza,
        'titulo': titulo,
        'inspector': inspector,
        'fecha_hora_registro': fechaHora.toIso8601String(),
        'campos': campos,
        'observaciones': observaciones,
        'pdf_url': pdfUrl,
        'word_url': wordUrl,
        'fecha_legible': _formatearFechaLegible(fechaHora),
      };

      await _supabase.from('inspecciones_urgencia').insert(datos);

      debugPrint('[Urgencia Supabase] ✅ Registro insertado');

      // 🔥 ACTUALIZAR el campo 'estado_urgencias' en la tabla 'plazas'
      // Calcular estado basado en la cantidad de campos críticos
      final estadoGeneral = _calcularEstadoGeneral(campos);

      try {
        await _supabase
            .from('plazas')
            .update({'estado_urgencias': estadoGeneral})
            .eq('id', plazaId);
        debugPrint(
          '[Urgencia Supabase] ✅ estado_urgencias actualizado: $estadoGeneral',
        );
      } catch (e) {
        debugPrint(
          '[Urgencia Supabase] ⚠️ Error al actualizar estado_urgencias: $e',
        );
      }

      return {
        'success': true,
        'message': 'Inspección guardada exitosamente',
        'pdf_url': pdfUrl,
        'word_url': wordUrl,
      };
    } catch (e) {
      debugPrint('[Urgencia Supabase] ❌ Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Calcula el estado general basado en la severidad de las urgencias
  String _calcularEstadoGeneral(Map<String, String> campos) {
    int totalMalos = 0;
    int totalRegulares = 0;

    campos.forEach((key, value) {
      final valorLower = value.toLowerCase();
      // Si contiene palabras críticas, cuenta como Malo
      if (valorLower.contains('crítico') ||
          valorLower.contains('critico') ||
          valorLower.contains('urgente') ||
          valorLower.contains('grave')) {
        totalMalos++;
      } else if (valorLower.contains('regular') ||
          valorLower.contains('moderado') ||
          valorLower.contains('atención')) {
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

  /// Obtiene historial de inspecciones de urgencia
  Future<List<Map<String, dynamic>>> obtenerHistorial(String plazaId) async {
    try {
      final response = await _supabase
          .from('inspecciones_urgencia')
          .select()
          .eq('plaza_id', plazaId)
          .order('fecha_hora_registro', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[Urgencia Supabase] Error obteniendo historial: $e');
      return [];
    }
  }

  String _formatearFechaLegible(DateTime fecha) {
    final meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];

    return '${fecha.day} de ${meses[fecha.month - 1]} ${fecha.year} - '
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}
