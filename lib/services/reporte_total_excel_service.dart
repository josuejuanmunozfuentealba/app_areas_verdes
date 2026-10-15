import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';

/// Servicio para generar Excel de REPORTE CONSOLIDADO TOTAL
/// Incluye estadísticas completas con porcentajes por estado
class ReporteTotalExcelService {
  static final _supabase = Supabase.instance.client;

  /// Obtiene reporte consolidado total con estadísticas por estado
  static Future<Map<String, dynamic>> obtenerReporteTotal() async {
    try {
      debugPrint('📊 [Reporte Total] Obteniendo datos consolidados...');

      // 1. Obtener todas las plazas
      final plazasResponse = await _supabase
          .from('plazas')
          .select('id, nombre, comuna, latitud, longitud, direccion, estado, estado_areas_verdes');

      debugPrint('✅ [Reporte Total] ${plazasResponse.length} plazas encontradas');

      // 2. Obtener catastros más recientes por plaza
      final catastrosResponse = await _supabase
          .from('catastros_inmuebles')
          .select('plaza_id, estado_general, created_at')
          .order('created_at', ascending: false);

      // 3. Obtener inspecciones técnicas más recientes por plaza
      final inspeccionesResponse = await _supabase
          .from('inspecciones_tecnicas')
          .select('plaza_id, estado_general, fecha_hora_registro')
          .order('fecha_hora_registro', ascending: false);

      // Crear mapas de estados más recientes
      final Map<String, String> estadosCatastro = {};
      final Map<String, String> estadosInspeccion = {};

      // Estados de catastro más recientes por plaza
      for (var catastro in catastrosResponse) {
        final plazaId = catastro['plaza_id']?.toString();
        if (plazaId != null && !estadosCatastro.containsKey(plazaId)) {
          estadosCatastro[plazaId] = catastro['estado_general'] ?? 'Sin evaluar';
        }
      }

      // Estados de inspección técnica más recientes por plaza
      for (var inspeccion in inspeccionesResponse) {
        final plazaId = inspeccion['plaza_id']?.toString();
        if (plazaId != null && !estadosInspeccion.containsKey(plazaId)) {
          estadosInspeccion[plazaId] = inspeccion['estado_general'] ?? 'Sin evaluar';
        }
      }

      // Procesar datos para Excel
      final List<Map<String, dynamic>> datosExcel = [];
      final Map<String, int> contadorEstadosGeneral = {
        'Excelente': 0,
        'Bueno': 0,
        'Regular': 0,
        'Malo': 0,
        'Sin evaluar': 0,
      };

      final Map<String, int> contadorEstadosCatastro = {
        'Excelente': 0,
        'Bueno': 0,
        'Regular': 0,
        'Malo': 0,
        'Sin evaluar': 0,
      };

      final Map<String, int> contadorEstadosInspeccion = {
        'Excelente': 0,
        'Bueno': 0,
        'Regular': 0,
        'Malo': 0,
        'Sin evaluar': 0,
      };

      final Map<String, int> plazasPorComuna = {};

      for (var plaza in plazasResponse) {
        final plazaId = plaza['id']?.toString() ?? '';
        final nombre = plaza['nombre'] ?? 'Sin nombre';
        final comuna = plaza['comuna'] ?? 'Sin comuna';
        final direccion = plaza['direccion'] ?? 'Sin dirección';
        final gpsLat = plaza['latitud']?.toString() ?? 'N/A';
        final gpsLng = plaza['longitud']?.toString() ?? 'N/A';
        
        // Estado general de la plaza (campo estado_areas_verdes o estado)
        final estadoGeneral = plaza['estado_areas_verdes'] ?? plaza['estado'] ?? 'Sin evaluar';
        
        // Estados específicos por tipo de evaluación
        final estadoCatastro = estadosCatastro[plazaId] ?? 'Sin evaluar';
        final estadoInspeccion = estadosInspeccion[plazaId] ?? 'Sin evaluar';

        // Contar por comuna
        plazasPorComuna[comuna] = (plazasPorComuna[comuna] ?? 0) + 1;

        // Contar estados
        contadorEstadosGeneral[estadoGeneral] = (contadorEstadosGeneral[estadoGeneral] ?? 0) + 1;
        contadorEstadosCatastro[estadoCatastro] = (contadorEstadosCatastro[estadoCatastro] ?? 0) + 1;
        contadorEstadosInspeccion[estadoInspeccion] = (contadorEstadosInspeccion[estadoInspeccion] ?? 0) + 1;

        // Determinar si tiene evaluaciones
        final tieneCatastro = estadoCatastro != 'Sin evaluar' ? 'SÍ' : 'NO';
        final tieneInspeccion = estadoInspeccion != 'Sin evaluar' ? 'SÍ' : 'NO';

        datosExcel.add({
          'plaza_id': plazaId,
          'nombre_plaza': nombre,
          'comuna': comuna,
          'direccion': direccion,
          'gps_lat': gpsLat,
          'gps_lng': gpsLng,
          'estado_general': estadoGeneral,
          'estado_catastro': estadoCatastro,
          'estado_inspeccion_tecnica': estadoInspeccion,
          'tiene_catastro': tieneCatastro,
          'tiene_inspeccion_tecnica': tieneInspeccion,
        });
      }

      final totalPlazas = plazasResponse.length;

      // Calcular porcentajes para estado general
      final Map<String, double> porcentajesGeneral = {};
      for (String estado in contadorEstadosGeneral.keys) {
        final porcentaje = totalPlazas > 0 
            ? (contadorEstadosGeneral[estado]! * 100.0 / totalPlazas)
            : 0.0;
        porcentajesGeneral[estado] = porcentaje;
      }

      // Calcular porcentajes para catastros
      final Map<String, double> porcentajesCatastro = {};
      for (String estado in contadorEstadosCatastro.keys) {
        final porcentaje = totalPlazas > 0 
            ? (contadorEstadosCatastro[estado]! * 100.0 / totalPlazas)
            : 0.0;
        porcentajesCatastro[estado] = porcentaje;
      }

      // Calcular porcentajes para inspecciones
      final Map<String, double> porcentajesInspeccion = {};
      for (String estado in contadorEstadosInspeccion.keys) {
        final porcentaje = totalPlazas > 0 
            ? (contadorEstadosInspeccion[estado]! * 100.0 / totalPlazas)
            : 0.0;
        porcentajesInspeccion[estado] = porcentaje;
      }

      return {
        'datos_excel': datosExcel,
        'total_plazas': totalPlazas,
        'plazas_por_comuna': plazasPorComuna,
        'contador_estados_general': contadorEstadosGeneral,
        'contador_estados_catastro': contadorEstadosCatastro,
        'contador_estados_inspeccion': contadorEstadosInspeccion,
        'porcentajes_general': porcentajesGeneral,
        'porcentajes_catastro': porcentajesCatastro,
        'porcentajes_inspeccion': porcentajesInspeccion,
        'total_catastros': estadosCatastro.length,
        'total_inspecciones': estadosInspeccion.length,
      };
    } catch (e, stackTrace) {
      debugPrint('❌ [Reporte Total] Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'datos_excel': <Map<String, dynamic>>[],
        'total_plazas': 0,
        'error': e.toString(),
      };
    }
  }

  /// Genera CSV del reporte consolidado total
  static String generarCSVReporteTotal(List<Map<String, dynamic>> datos) {
    final buffer = StringBuffer();

    // BOM UTF-8 para acentos correctos en Excel
    buffer.write('\uFEFF');

    // Encabezados
    buffer.writeln([
      'ID Plaza',
      'Nombre Plaza',
      'Comuna',
      'Dirección',
      'GPS Latitud',
      'GPS Longitud',
      'Estado General',
      'Estado Catastro',
      'Estado Inspección Técnica',
      'Tiene Catastro',
      'Tiene Inspección Técnica',
    ].join(';'));

    // Datos
    for (var dato in datos) {
      final fila = [
        dato['plaza_id']?.toString() ?? '',
        _escaparCSV(dato['nombre_plaza']?.toString() ?? ''),
        _escaparCSV(dato['comuna']?.toString() ?? ''),
        _escaparCSV(dato['direccion']?.toString() ?? ''),
        dato['gps_lat']?.toString() ?? '',
        dato['gps_lng']?.toString() ?? '',
        dato['estado_general']?.toString() ?? '',
        dato['estado_catastro']?.toString() ?? '',
        dato['estado_inspeccion_tecnica']?.toString() ?? '',
        dato['tiene_catastro']?.toString() ?? '',
        dato['tiene_inspeccion_tecnica']?.toString() ?? '',
      ];

      buffer.writeln(fila.join(';'));
    }

    return buffer.toString();
  }

  /// Genera resumen estadístico con porcentajes
  static String generarResumenEstadisticas(Map<String, dynamic> datos) {
    final buffer = StringBuffer();
    final totalPlazas = datos['total_plazas'] as int;
    
    buffer.writeln('=== REPORTE CONSOLIDADO TOTAL ===');
    buffer.writeln('Fecha generación: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    buffer.writeln('');
    
    buffer.writeln('📊 ESTADÍSTICAS GENERALES:');
    buffer.writeln('• Total áreas verdes: $totalPlazas');
    buffer.writeln('• Total con catastro: ${datos['total_catastros']}');
    buffer.writeln('• Total con inspección técnica: ${datos['total_inspecciones']}');
    buffer.writeln('');
    
    // Distribución por comuna
    final plazasPorComuna = datos['plazas_por_comuna'] as Map<String, int>;
    buffer.writeln('📍 DISTRIBUCIÓN POR COMUNA:');
    for (var entry in plazasPorComuna.entries) {
      final porcentaje = totalPlazas > 0 
          ? (entry.value * 100.0 / totalPlazas).toStringAsFixed(1)
          : '0.0';
      buffer.writeln('• ${entry.key}: ${entry.value} plazas ($porcentaje%)');
    }
    buffer.writeln('');
    
    // Estados generales con porcentajes
    final porcentajesGeneral = datos['porcentajes_general'] as Map<String, double>;
    final contadorGeneral = datos['contador_estados_general'] as Map<String, int>;
    
    buffer.writeln('🎯 ESTADO GENERAL DE ÁREAS VERDES:');
    for (var entry in contadorGeneral.entries) {
      if (entry.value > 0) {
        final porcentaje = porcentajesGeneral[entry.key]?.toStringAsFixed(1) ?? '0.0';
        buffer.writeln('• ${entry.key}: ${entry.value} plazas ($porcentaje%)');
      }
    }
    buffer.writeln('');
    
    // Estados por catastro
    final porcentajesCatastro = datos['porcentajes_catastro'] as Map<String, double>;
    final contadorCatastro = datos['contador_estados_catastro'] as Map<String, int>;
    
    buffer.writeln('📋 EVALUACIONES CATASTRO:');
    for (var entry in contadorCatastro.entries) {
      if (entry.value > 0) {
        final porcentaje = porcentajesCatastro[entry.key]?.toStringAsFixed(1) ?? '0.0';
        buffer.writeln('• ${entry.key}: ${entry.value} plazas ($porcentaje%)');
      }
    }
    buffer.writeln('');
    
    // Estados por inspección técnica
    final porcentajesInspeccion = datos['porcentajes_inspeccion'] as Map<String, double>;
    final contadorInspeccion = datos['contador_estados_inspeccion'] as Map<String, int>;
    
    buffer.writeln('🔧 INSPECCIONES TÉCNICAS:');
    for (var entry in contadorInspeccion.entries) {
      if (entry.value > 0) {
        final porcentaje = porcentajesInspeccion[entry.key]?.toStringAsFixed(1) ?? '0.0';
        buffer.writeln('• ${entry.key}: ${entry.value} plazas ($porcentaje%)');
      }
    }
    
    return buffer.toString();
  }

  /// Escapar texto para CSV
  static String _escaparCSV(String texto) {
    if (texto.isEmpty) return texto;
    
    String textoLimpio = texto.replaceAll(';', ',');

    if (textoLimpio.contains(',') ||
        textoLimpio.contains('\n') ||
        textoLimpio.contains('"')) {
      return '"${textoLimpio.replaceAll('"', '""')}"';
    }
    return textoLimpio;
  }
}