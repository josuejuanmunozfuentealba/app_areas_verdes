// ============================================================================
// SERVICIO: SUBIDA OPTIMIZADA A LA NUBE
// Estrategia: Subir fotos 1 a 1, luego PDF liviano
// Recomendado por: Google AI Studio
// ============================================================================

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class SubidaNubeOptimizada {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ========== 1. SUBIR FOTOS INDIVIDUALMENTE CON PROGRESO ==========
  /// Sube fotos una por una a Supabase Storage
  /// 
  /// Parámetros:
  ///   - plazaId: ID de la plaza
  ///   - fotos: Lista de fotos con archivo XFile
  ///   - onProgreso: Callback con progreso (actual, total)
  /// 
  /// Retorna:
  ///   - Lista de URLs públicas de las fotos subidas
  Future<List<String>> subirFotosIndividuales({
    required String plazaId,
    required List<Map<String, dynamic>> fotos,
    required Function(int actual, int total) onProgreso,
  }) async {
    final List<String> urlsSubidas = [];
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    debugPrint('[SubidaNube] 📷 Iniciando subida de ${fotos.length} foto(s)');

    for (int i = 0; i < fotos.length; i++) {
      try {
        // Notificar progreso
        onProgreso(i + 1, fotos.length);
        
        final archivo = fotos[i]['archivo'] as XFile;
        final rawBytes = await archivo.readAsBytes();
        
        final sizeKB = (rawBytes.length / 1024).toStringAsFixed(0);
        debugPrint('[SubidaNube] 📷 Subiendo foto ${i + 1}/${fotos.length} ($sizeKB KB)');
        
        // Generar nombre único
        final fileName = 'plaza_${plazaId}_${timestamp}_foto_$i.jpg';
        final filePath = 'evidencias/$fileName';

        // Subir a Storage bucket 'reportes-catastro'
        await _supabase.storage
            .from('reportes-catastro')
            .uploadBinary(
              filePath,
              rawBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: true, // Sobrescribir si existe
              ),
            );

        // Obtener URL pública
        final url = _supabase.storage
            .from('reportes-catastro')
            .getPublicUrl(filePath);
        
        urlsSubidas.add(url);
        debugPrint('[SubidaNube] ✅ Foto ${i + 1} subida: ${url.substring(0, 50)}...');
        
      } catch (e) {
        debugPrint('[SubidaNube] ⚠️ Error subiendo foto $i: $e');
        // Continuar con las demás fotos aunque una falle
      }
    }

    debugPrint('[SubidaNube] ✅ Total: ${urlsSubidas.length}/${fotos.length} fotos subidas');
    return urlsSubidas;
  }

  // ========== 2. GUARDAR CATASTRO CON PDF LIVIANO ==========
  /// Guarda el catastro en Supabase con PDF liviano (sin fotos embebidas)
  /// 
  /// Parámetros:
  ///   - pdfBytes: PDF generado (debe ser liviano, <200 KB)
  ///   - docxBytes: Word convertido (opcional)
  ///   - fotosUrls: URLs de fotos ya subidas
  ///   - Otros campos del catastro
  /// 
  /// Retorna:
  ///   - Map con success, message, data
  Future<Map<String, dynamic>> guardarCatastroConPDFLiviano({
    required String plazaId,
    required String nombrePlaza,
    required String inspector,
    required DateTime fechaHora,
    required Map<String, String?> evaluaciones,
    required Map<String, String> observaciones,
    required Uint8List pdfBytes,
    Uint8List? docxBytes,
    required List<String> fotosUrls, // ← URLs ya subidas
  }) async {
    try {
      final timestamp = fechaHora.millisecondsSinceEpoch;
      
      debugPrint('[SubidaNube] 📄 PDF: ${(pdfBytes.length / 1024).toStringAsFixed(0)} KB');
      
      // ===== PASO 1: SUBIR PDF LIVIANO =====
      final pdfFileName = 'catastros/catastro_${plazaId}_$timestamp.pdf';
      
      await _supabase.storage
          .from('reportes-catastro')
          .uploadBinary(
            pdfFileName,
            pdfBytes,
            fileOptions: const FileOptions(
              contentType: 'application/pdf',
              upsert: true,
            ),
          );

      final pdfUrl = _supabase.storage
          .from('reportes-catastro')
          .getPublicUrl(pdfFileName);

      debugPrint('[SubidaNube] ✅ PDF subido: ${pdfUrl.substring(0, 50)}...');

      // ===== PASO 2: SUBIR DOCX (OPCIONAL) =====
      String wordUrl = '';
      if (docxBytes != null) {
        final docxFileName = 'catastros/catastro_${plazaId}_$timestamp.docx';
        
        debugPrint('[SubidaNube] 📄 DOCX: ${(docxBytes.length / 1024).toStringAsFixed(0)} KB');
        
        await _supabase.storage
            .from('reportes-catastro')
            .uploadBinary(
              docxFileName,
              docxBytes,
              fileOptions: const FileOptions(
                contentType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                upsert: true,
              ),
            );

        wordUrl = _supabase.storage
            .from('reportes-catastro')
            .getPublicUrl(docxFileName);
        
        debugPrint('[SubidaNube] ✅ DOCX subido');
      } else {
        debugPrint('[SubidaNube] ⚠️ DOCX no disponible');
      }

      // ===== PASO 3: CALCULAR ESTADO GENERAL =====
      final estadoGeneral = _calcularEstadoGeneral(evaluaciones);
      
      // Formatear fecha
      final fechaLegible = '${fechaHora.day.toString().padLeft(2, '0')}/${fechaHora.month.toString().padLeft(2, '0')}/${fechaHora.year} ${fechaHora.hour.toString().padLeft(2, '0')}:${fechaHora.minute.toString().padLeft(2, '0')}:${fechaHora.second.toString().padLeft(2, '0')}';

      // ===== PASO 4: INSERTAR EN BASE DE DATOS POSTGRESQL =====
      final payload = {
        'plaza_id': plazaId,
        'nombre_plaza': nombrePlaza,
        'inspector': inspector,
        'fecha_hora_registro': fechaHora.toIso8601String(),
        'fecha_legible': fechaLegible,
        'estado_general': estadoGeneral,
        'evaluaciones': evaluaciones,
        'observaciones': observaciones,
        'pdf_url': pdfUrl,
        'word_url': wordUrl.isEmpty ? null : wordUrl,
        'fotos_urls': fotosUrls, // ← NUEVO campo (JSON array)
        'correo_enviado': false,
        'fecha_envio_correo': null,
      };

      debugPrint('[SubidaNube] 💾 Insertando registro en PostgreSQL...');

      final response = await _supabase
          .from('catastros_inmuebles')
          .insert(payload)
          .select()
          .single();

      debugPrint('[SubidaNube] ✅ Registro guardado con ID: ${response['id']}');

      return {
        'success': true,
        'message': 'Catastro guardado exitosamente',
        'data': response,
        'pdf_url': pdfUrl,
        'word_url': wordUrl,
        'fotos_count': fotosUrls.length,
      };
      
    } catch (e, stackTrace) {
      debugPrint('[SubidaNube] ❌ Error al guardar: $e');
      debugPrint('[SubidaNube] StackTrace: $stackTrace');
      
      return {
        'success': false,
        'message': 'Error al guardar en Supabase: ${e.toString()}',
      };
    }
  }

  // ========== 3. CALCULAR ESTADO GENERAL ==========
  String _calcularEstadoGeneral(Map<String, String?> evaluaciones) {
    // Si hay algún "Malo", el estado general es Malo
    if (evaluaciones.values.contains('Malo')) return 'Malo';
    
    // Si hay algún "Regular", el estado general es Regular
    if (evaluaciones.values.contains('Regular')) return 'Regular';
    
    // Si todo es "Bueno" o null, el estado es Bueno
    return 'Bueno';
  }

  // ========== 4. PROCESO COMPLETO: FOTOS + PDF + GUARDAR ==========
  /// Proceso completo optimizado:
  /// 1. Sube fotos una por una
  /// 2. Guarda catastro con PDF liviano
  /// 
  /// Parámetros:
  ///   - fotos: Lista de fotos a subir
  ///   - pdfBytes: PDF liviano (generado SIN fotos embebidas)
  ///   - onProgresoFotos: Callback de progreso de fotos
  ///   - Otros parámetros del catastro
  /// 
  /// Retorna:
  ///   - Map con success, message, fotos_subidas, data
  Future<Map<String, dynamic>> subirCatastroCompleto({
    required String plazaId,
    required String nombrePlaza,
    required String inspector,
    required DateTime fechaHora,
    required Map<String, String?> evaluaciones,
    required Map<String, String> observaciones,
    required List<Map<String, dynamic>> fotos,
    required Uint8List pdfBytes,
    Uint8List? docxBytes,
    required Function(int actual, int total) onProgresoFotos,
  }) async {
    try {
      debugPrint('[SubidaNube] 🚀 Iniciando proceso completo optimizado');
      
      // ===== PASO 1: SUBIR FOTOS =====
      List<String> fotosUrls = [];
      
      if (fotos.isNotEmpty) {
        debugPrint('[SubidaNube] 📷 Subiendo ${fotos.length} foto(s)...');
        
        fotosUrls = await subirFotosIndividuales(
          plazaId: plazaId,
          fotos: fotos,
          onProgreso: onProgresoFotos,
        );
        
        if (fotosUrls.isEmpty && fotos.isNotEmpty) {
          return {
            'success': false,
            'message': 'No se pudo subir ninguna foto',
            'fotos_subidas': 0,
          };
        }
        
        debugPrint('[SubidaNube] ✅ ${fotosUrls.length} foto(s) subidas');
      } else {
        debugPrint('[SubidaNube] ℹ️ No hay fotos para subir');
      }
      
      // ===== PASO 2: GUARDAR CATASTRO =====
      debugPrint('[SubidaNube] 💾 Guardando catastro...');
      
      final resultado = await guardarCatastroConPDFLiviano(
        plazaId: plazaId,
        nombrePlaza: nombrePlaza,
        inspector: inspector,
        fechaHora: fechaHora,
        evaluaciones: evaluaciones,
        observaciones: observaciones,
        pdfBytes: pdfBytes,
        docxBytes: docxBytes,
        fotosUrls: fotosUrls,
      );
      
      if (resultado['success'] == true) {
        debugPrint('[SubidaNube] 🎉 PROCESO COMPLETO EXITOSO');
        return {
          ...resultado,
          'fotos_subidas': fotosUrls.length,
        };
      } else {
        return resultado;
      }
      
    } catch (e) {
      debugPrint('[SubidaNube] ❌ Error en proceso completo: $e');
      return {
        'success': false,
        'message': 'Error inesperado: ${e.toString()}',
      };
    }
  }
}
