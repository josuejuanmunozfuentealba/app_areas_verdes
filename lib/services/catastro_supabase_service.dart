import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';

/// Servicio para interactuar con Supabase en el módulo de Catastro
class CatastroSupabaseService {
  final _supabase = Supabase.instance.client;

  /// Guarda un catastro completo en Supabase
  /// 1. Sube el PDF al bucket
  /// 2. Sube el Word al bucket
  /// 3. Inserta el registro en la tabla con las URLs públicas
  Future<Map<String, dynamic>> guardarCatastroCompleto({
    required String plazaId,
    required String nombrePlaza,
    required String inspector,
    required DateTime fechaHora,
    required Map<String, String?> evaluaciones,
    required Map<String, String> observaciones,
    required List<int> pdfBytes,
    required List<int> wordBytes,
  }) async {
    try {
      // Generar nombres únicos para los archivos
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(fechaHora);
      final plazaLimpio = nombrePlaza
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');

      final pdfFileName = 'catastro_${plazaLimpio}_${plazaId}_$timestamp.pdf';
      final wordFileName = 'catastro_${plazaLimpio}_${plazaId}_$timestamp.doc';

      // Convertir List<int> a Uint8List
      final pdfUint8 = Uint8List.fromList(pdfBytes);
      final wordUint8 = Uint8List.fromList(wordBytes);

      // 1. Subir PDF
      final pdfPath = await _supabase.storage
          .from('reportes-catastro')
          .uploadBinary(pdfFileName, pdfUint8);

      // 2. Subir Word
      final wordPath = await _supabase.storage
          .from('reportes-catastro')
          .uploadBinary(wordFileName, wordUint8);

      // 3. Obtener URLs públicas
      final pdfUrl = _supabase.storage
          .from('reportes-catastro')
          .getPublicUrl(pdfFileName);

      final wordUrl = _supabase.storage
          .from('reportes-catastro')
          .getPublicUrl(wordFileName);

      // Calcular estado general
      final estadoGeneral = _calcularEstadoGeneral(evaluaciones);

      // Formatear fecha legible
      final fechaLegible = DateFormat('dd/MM/yyyy HH:mm:ss').format(fechaHora);

      // 4. Insertar registro en la tabla
      final data = {
        'plaza_id': plazaId,
        'nombre_plaza': nombrePlaza,
        'inspector': inspector,
        'fecha_hora_registro': fechaHora.toIso8601String(),
        'fecha_legible': fechaLegible,
        'estado_general': estadoGeneral,
        'evaluaciones': evaluaciones,
        'observaciones': observaciones,
        'pdf_url': pdfUrl,
        'word_url': wordUrl,
        'correo_enviado': false,
        'fecha_envio_correo': null,
      };

      final response = await _supabase
          .from('catastros_inmuebles')
          .insert(data)
          .select()
          .single();

      return {
        'success': true,
        'message': 'Catastro guardado exitosamente en la nube',
        'id': response['id'],
        'pdf_url': pdfUrl,
        'word_url': wordUrl,
      };
    } catch (e) {
      return {'success': false, 'message': 'Error al guardar: ${e.toString()}'};
    }
  }

  /// Obtiene el historial de catastros de una plaza específica
  Future<List<Map<String, dynamic>>> obtenerHistorial(String plazaId) async {
    try {
      final response = await _supabase
          .from('catastros_inmuebles')
          .select()
          .eq('plaza_id', plazaId)
          .order('fecha_hora_registro', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al obtener historial: ${e.toString()}');
    }
  }

  /// Obtiene todos los catastros (sin filtro de plaza)
  Future<List<Map<String, dynamic>>> obtenerTodosLosCatastros() async {
    try {
      final response = await _supabase
          .from('catastros_inmuebles')
          .select()
          .order('fecha_hora_registro', ascending: false)
          .limit(100);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error al obtener catastros: ${e.toString()}');
    }
  }

  /// Elimina un catastro por ID (incluyendo archivos del bucket)
  Future<Map<String, dynamic>> eliminarCatastro(String id) async {
    try {
      // Primero obtener las URLs para eliminar los archivos
      final registro = await _supabase
          .from('catastros_inmuebles')
          .select('pdf_url, word_url')
          .eq('id', id)
          .single();

      // Extraer nombres de archivo de las URLs
      final pdfUrl = registro['pdf_url'] as String;
      final wordUrl = registro['word_url'] as String;

      final pdfFileName = pdfUrl.split('/').last;
      final wordFileName = wordUrl.split('/').last;

      // Eliminar archivos del bucket
      await _supabase.storage.from('reportes-catastro').remove([
        pdfFileName,
        wordFileName,
      ]);

      // Eliminar registro de la tabla
      await _supabase.from('catastros_inmuebles').delete().eq('id', id);

      return {'success': true, 'message': 'Catastro eliminado exitosamente'};
    } catch (e) {
      return {
        'success': false,
        'message': 'Error al eliminar: ${e.toString()}',
      };
    }
  }

  String _calcularEstadoGeneral(Map<String, String?> evaluaciones) {
    int totalMalos = 0;
    int totalRegulares = 0;
    int totalBuenos = 0;

    for (var valor in evaluaciones.values) {
      if (valor == 'Malo') {
        totalMalos++;
      } else if (valor == 'Regular') {
        totalRegulares++;
      } else if (valor == 'Bueno') {
        totalBuenos++;
      }
    }

    if (totalMalos >= 3) return 'Malo';
    if (totalMalos > 0 || totalRegulares >= 4) return 'Regular';
    if (totalBuenos > 0) return 'Bueno';
    return 'Sin evaluar';
  }

  /// Actualiza el estado de correo_enviado en Supabase
  Future<Map<String, dynamic>> marcarCorreoEnviado({
    required String registroId,
  }) async {
    try {
      await _supabase
          .from('catastros_inmuebles')
          .update({
            'correo_enviado': true,
            'fecha_envio_correo': DateTime.now().toIso8601String(),
          })
          .eq('id', registroId);

      return {'success': true, 'message': 'Estado actualizado'};
    } catch (e) {
      return {'success': false, 'message': 'Error: ${e.toString()}'};
    }
  }
}
