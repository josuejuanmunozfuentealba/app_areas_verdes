import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;

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
          .toLowerCase()
          .replaceAll('á', 'a')
          .replaceAll('é', 'e')
          .replaceAll('í', 'i')
          .replaceAll('ó', 'o')
          .replaceAll('ú', 'u')
          .replaceAll('ñ', 'n')
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');

      final pdfFileName = 'catastro_${plazaLimpio}_${plazaId}_$timestamp.pdf';
      final wordFileName = 'catastro_${plazaLimpio}_${plazaId}_$timestamp.docx';

      // Convertir List<int> a Uint8List
      final pdfUint8 = Uint8List.fromList(pdfBytes);
      final wordUint8 = Uint8List.fromList(wordBytes);

      // 1. Subir PDF
      await _supabase.storage
          .from('reportes-catastro')
          .uploadBinary(pdfFileName, pdfUint8);

      // 2. Subir Word
      await _supabase.storage
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

  /// ========================================================
  /// NUEVA ESTRATEGIA: Guardar catastro con DOCX convertido
  /// ========================================================

  /// Guarda un catastro completo usando la estrategia PDF→DOCX
  ///
  /// Este método:
  /// 1. Sube el PDF al bucket
  /// 2. Sube el DOCX (convertido desde PDF) al bucket
  /// 3. Inserta el registro en la tabla con las URLs públicas
  ///
  /// Parámetros:
  ///   - pdfBytes: Bytes del PDF generado por CatastroExportService.generarPDF()
  ///   - docxBytes: Bytes del DOCX convertido desde el PDF vía CloudConvert
  ///   - otros: Mismos parámetros que guardarCatastroCompleto()
  ///
  /// Retorna:
  ///   - Map con success, message, id, pdf_url, word_url
  Future<Map<String, dynamic>> guardarCatastroConDocxConvertido({
    required String plazaId,
    required String nombrePlaza,
    required String inspector,
    required DateTime fechaHora,
    required Map<String, String?> evaluaciones,
    required Map<String, String> observaciones,
    required Uint8List pdfBytes,
    Uint8List? docxBytes, // ← AHORA ES OPCIONAL
  }) async {
    try {
      // Generar nombres únicos para los archivos
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(fechaHora);
      final plazaLimpio = _sanitizarNombreArchivo(nombrePlaza);

      final pdfFileName = 'catastro_${plazaLimpio}_${plazaId}_$timestamp.pdf';

      debugPrint(
        '[Supabase] Subiendo PDF: $pdfFileName (${(pdfBytes.length / 1024).toStringAsFixed(1)} KB)',
      );

      // 1. Subir PDF al bucket
      await _supabase.storage
          .from('reportes-catastro')
          .uploadBinary(pdfFileName, pdfBytes);

      debugPrint('[Supabase] ✅ PDF subido exitosamente');

      // 2. Subir DOCX al bucket (solo si está disponible)
      String? wordUrl;
      if (docxBytes != null) {
        final docxFileName =
            'catastro_${plazaLimpio}_${plazaId}_$timestamp.docx';
        debugPrint(
          '[Supabase] Subiendo DOCX: $docxFileName (${(docxBytes.length / 1024).toStringAsFixed(1)} KB)',
        );

        await _supabase.storage
            .from('reportes-catastro')
            .uploadBinary(docxFileName, docxBytes);

        debugPrint('[Supabase] ✅ DOCX subido exitosamente');

        wordUrl = _supabase.storage
            .from('reportes-catastro')
            .getPublicUrl(docxFileName);

        debugPrint('[Supabase] DOCX URL: $wordUrl');
      } else {
        debugPrint('[Supabase] ⚠️ DOCX no disponible, guardando solo PDF');
      }

      // 3. Obtener URL pública del PDF
      final pdfUrl = _supabase.storage
          .from('reportes-catastro')
          .getPublicUrl(pdfFileName);

      debugPrint('[Supabase] PDF URL: $pdfUrl');

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

      debugPrint('[Supabase] ✅ Registro insertado con ID: ${response['id']}');

      return {
        'success': true,
        'message': 'Catastro guardado exitosamente (PDF + DOCX convertido)',
        'id': response['id'],
        'pdf_url': pdfUrl,
        'word_url': wordUrl,
      };
    } catch (e, stackTrace) {
      debugPrint('[Supabase] ❌ Error al guardar catastro: $e');
      debugPrint('[Supabase] StackTrace: $stackTrace');
      return {
        'success': false,
        'message': 'Error al guardar en Supabase: ${e.toString()}',
      };
    }
  }

  /// Sanitiza el nombre de un archivo eliminando tildes y caracteres especiales
  String _sanitizarNombreArchivo(String nombre) {
    return nombre
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');
  }

  /// Obtiene el historial de catastros de una plaza específica
  Future<List<Map<String, dynamic>>> obtenerHistorial(String plazaId) async {
    try {
      debugPrint('[Supabase] 🔍 Buscando historial para plaza_id: "$plazaId"');

      // Asegurar que plaza_id sea String (no int)
      final plazaIdStr = plazaId.toString();

      final response = await _supabase
          .from('catastros_inmuebles')
          .select()
          .eq('plaza_id', plazaIdStr)
          .order('fecha_hora_registro', ascending: false);

      debugPrint(
        '[Supabase] ✅ Historial obtenido: ${response.length} registros',
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[Supabase] ❌ Error al obtener historial: $e');
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

      // Extraer nombres de archivo de las URLs (manejo seguro de null)
      final pdfUrl = registro['pdf_url'] as String?;
      final wordUrl = registro['word_url'] as String?;

      final archivosAEliminar = <String>[];

      if (pdfUrl != null && pdfUrl.isNotEmpty) {
        final pdfFileName = pdfUrl.split('/').last;
        archivosAEliminar.add(pdfFileName);
      }

      if (wordUrl != null && wordUrl.isNotEmpty) {
        final wordFileName = wordUrl.split('/').last;
        archivosAEliminar.add(wordFileName);
      }

      // Eliminar archivos del bucket (solo si hay archivos)
      if (archivosAEliminar.isNotEmpty) {
        await _supabase.storage
            .from('reportes-catastro')
            .remove(archivosAEliminar);
      }

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
