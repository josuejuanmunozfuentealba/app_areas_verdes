import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class InspeccionTecnicaSupabaseService {
  final _supabase = Supabase.instance.client;

  /// Guarda inspección técnica en Supabase
  Future<Map<String, dynamic>> guardarInspeccion({
    required String plazaId,
    required String nombrePlaza,
    required String inspector,
    required String correoSupervisor,
    required DateTime fechaHora,
    required String estadoGeneral,
    required Map<String, dynamic> evaluaciones,
    required Map<String, dynamic> observaciones,
    required Uint8List pdfBytes,
    Uint8List? docxBytes,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final inspeccionId = 'inspeccion_${plazaId}_$timestamp';

      // 1. Subir PDF
      debugPrint('[Supabase] Subiendo PDF...');
      final pdfPath = '$inspeccionId.pdf';
      await _supabase.storage
          .from('reportes-inspecciones')
          .uploadBinary(pdfPath, pdfBytes, fileOptions: const FileOptions(upsert: true));

      final pdfUrl = _supabase.storage.from('reportes-inspecciones').getPublicUrl(pdfPath);

      // 2. Subir Word (si existe)
      String? wordUrl;
      if (docxBytes != null) {
        debugPrint('[Supabase] Subiendo Word...');
        final wordPath = '$inspeccionId.docx';
        await _supabase.storage
            .from('reportes-inspecciones')
            .uploadBinary(wordPath, docxBytes, fileOptions: const FileOptions(upsert: true));

        wordUrl = _supabase.storage.from('reportes-inspecciones').getPublicUrl(wordPath);
      }

      // 3. Guardar en base de datos
      debugPrint('[Supabase] Guardando en BD...');
      final fechaLegible = '${fechaHora.day}/${fechaHora.month}/${fechaHora.year} ${fechaHora.hour}:${fechaHora.minute}';

      await _supabase.from('inspecciones_tecnicas').insert({
        'id': inspeccionId,
        'plaza_id': plazaId,
        'nombre_plaza': nombrePlaza,
        'inspector': inspector,
        'correo_supervisor': correoSupervisor,
        'fecha_hora_registro': fechaHora.toIso8601String(),
        'fecha_legible': fechaLegible,
        'estado_general': estadoGeneral,
        'evaluaciones': evaluaciones,
        'observaciones': observaciones,
        'pdf_url': pdfUrl,
        'word_url': wordUrl,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      debugPrint('[Supabase] ✓ Inspección guardada: $inspeccionId');

      return {
        'success': true,
        'id': inspeccionId,
        'pdf_url': pdfUrl,
        'word_url': wordUrl,
      };
    } catch (e) {
      debugPrint('[Supabase] ✗ Error: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  /// Obtiene historial de inspecciones técnicas
  Future<List<Map<String, dynamic>>> obtenerHistorial(String plazaId) async {
    try {
      final response = await _supabase
          .from('inspecciones_tecnicas')
          .select()
          .eq('plaza_id', plazaId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[Supabase] Error cargando historial: $e');
      return [];
    }
  }

  /// Elimina inspección técnica
  Future<void> eliminarInspeccion(String id) async {
    await _supabase.from('inspecciones_tecnicas').delete().eq('id', id);
  }
}
