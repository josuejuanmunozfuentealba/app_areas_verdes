import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';

/// Servicio para generar Excel DETALLADO de Catastros por Componente
/// Muestra cada componente (bancas, juegos, basureros, arranques) por área verde
class CatastroDetalladoExcelService {
  static final _supabase = Supabase.instance.client;

  /// Campo específico para arranques de agua
  static const String campoArranques =
      'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)';

  /// Obtiene datos detallados de catastros por componente
  static Future<Map<String, dynamic>> obtenerDatosCatastroDetallado() async {
    try {
      debugPrint(
        '📊 [Catastro Detallado] Obteniendo todas las áreas verdes...',
      );

      // 1. Obtener TODAS las plazas (incluyendo no catastradas)
      final plazasResponse = await _supabase
          .from('plazas')
          .select('id, nombre, comuna, direccion, latitud, longitud')
          .order('id', ascending: true);

      debugPrint(
        '✅ [Catastro Detallado] ${plazasResponse.length} áreas verdes encontradas',
      );

      // 2. Obtener TODOS los catastros
      final catastrosResponse = await _supabase
          .from('catastros_inmuebles')
          .select('plaza_id, evaluaciones, observaciones, created_at')
          .order('created_at', ascending: false);

      debugPrint(
        '✅ [Catastro Detallado] ${catastrosResponse.length} catastros encontrados',
      );

      // Crear mapa de catastros más recientes por plaza
      final Map<String, Map<String, dynamic>> catastrosPorPlaza = {};
      for (var catastro in catastrosResponse) {
        final plazaId = catastro['plaza_id']?.toString();
        if (plazaId != null && !catastrosPorPlaza.containsKey(plazaId)) {
          catastrosPorPlaza[plazaId] = catastro;
        }
      }

      // Procesar datos para Excel detallado
      final List<Map<String, dynamic>> datosExcel = [];

      // Contadores globales
      int totalBancas = 0;
      int totalJuegos = 0;
      int totalBasureros = 0;
      int totalArranques = 0;
      int areasConBancas = 0;
      int areasConJuegos = 0;
      int areasConBasureros = 0;
      int areasConArranques = 0;

      // Estados por componente
      final Map<String, Map<String, int>> estadosPorComponente = {
        'bancas_estructural': {
          'Excelente': 0,
          'Bueno': 0,
          'Regular': 0,
          'Malo': 0,
          'N/A': 0,
        },
        'bancas_pintura': {
          'Excelente': 0,
          'Bueno': 0,
          'Regular': 0,
          'Malo': 0,
          'N/A': 0,
        },
        'juegos_estructural': {
          'Excelente': 0,
          'Bueno': 0,
          'Regular': 0,
          'Malo': 0,
          'N/A': 0,
        },
        'juegos_pintura': {
          'Excelente': 0,
          'Bueno': 0,
          'Regular': 0,
          'Malo': 0,
          'N/A': 0,
        },
        'basureros_estructural': {
          'Excelente': 0,
          'Bueno': 0,
          'Regular': 0,
          'Malo': 0,
          'N/A': 0,
        },
        'basureros_pintura': {
          'Excelente': 0,
          'Bueno': 0,
          'Regular': 0,
          'Malo': 0,
          'N/A': 0,
        },
        'arranques': {
          'Excelente': 0,
          'Bueno': 0,
          'Regular': 0,
          'Malo': 0,
          'N/A': 0,
        },
      };

      for (var plaza in plazasResponse) {
        final plazaId = plaza['id']?.toString() ?? '';
        final nombre = plaza['nombre'] ?? 'Sin nombre';
        final comuna = plaza['comuna'] ?? 'Sin comuna';
        final direccion = plaza['direccion'] ?? 'Sin dirección';
        final gpsLat = plaza['latitud']?.toString() ?? 'N/A';
        final gpsLng = plaza['longitud']?.toString() ?? 'N/A';

        final catastro = catastrosPorPlaza[plazaId];

        // DEBUG: Log plazas 5, 15, 16
        if (plazaId == '5' || plazaId == '15' || plazaId == '16') {
          debugPrint('🔍 [DEBUG] Plaza $plazaId ($nombre):');
          debugPrint('   Tiene catastro: ${catastro != null}');
          if (catastro != null) {
            debugPrint('   Evaluaciones: ${catastro['evaluaciones']}');
            debugPrint('   Observaciones: ${catastro['observaciones']}');
          }
        }

        // Extraer evaluaciones y observaciones
        Map<String, dynamic>? evaluaciones;
        Map<String, dynamic>? observaciones;

        if (catastro != null) {
          evaluaciones = catastro['evaluaciones'] as Map<String, dynamic>?;
          observaciones = catastro['observaciones'] as Map<String, dynamic>?;
        }

        // Verificar si realmente tiene datos evaluados (no solo un registro vacío)
        final tieneDatosReales =
            evaluaciones != null &&
            evaluaciones.isNotEmpty &&
            evaluaciones.values.any(
              (valor) =>
                  valor != null &&
                  valor.toString().isNotEmpty &&
                  valor.toString() != 'null',
            );

        final tieneCatastro = catastro != null && tieneDatosReales;

        // Bancas
        final bancasEstructural =
            evaluaciones?['Estado estructural de bancas']?.toString() ?? 'N/A';
        final bancasPintura =
            evaluaciones?['Estado pintura bancas']?.toString() ?? 'N/A';
        final bancasObservacion =
            observaciones?['Estado estructural de bancas']?.toString() ?? '';
        final bancasPinturaObs =
            observaciones?['Estado pintura bancas']?.toString() ?? '';

        final tieneBancas =
            bancasEstructural != 'N/A' || bancasPintura != 'N/A';
        if (tieneBancas) {
          areasConBancas++;
          // Extraer cantidad de bancas de la observación
          int cantidadBancas = 1; // Por defecto 1
          final observacionCompleta = '$bancasObservacion $bancasPinturaObs';
          if (observacionCompleta.isNotEmpty) {
            final regex = RegExp(
              r'(\d+)\s*(banca|banco)',
              caseSensitive: false,
            );
            final match = regex.firstMatch(observacionCompleta);
            if (match != null) {
              cantidadBancas = int.tryParse(match.group(1) ?? '1') ?? 1;
            }
          }
          totalBancas += cantidadBancas;
        }

        // Juegos Infantiles
        final juegosEstructural =
            evaluaciones?['Estado estructural juegos infantiles']?.toString() ??
            'N/A';
        final juegosPintura =
            evaluaciones?['Estado de pintura de juegos infantiles']
                ?.toString() ??
            'N/A';
        final juegosObservacion =
            observaciones?['Estado estructural juegos infantiles']
                ?.toString() ??
            '';
        final juegosPinturaObs =
            observaciones?['Estado de pintura de juegos infantiles']
                ?.toString() ??
            '';

        final tieneJuegos =
            juegosEstructural != 'N/A' || juegosPintura != 'N/A';
        if (tieneJuegos) {
          areasConJuegos++;
          // Extraer cantidad de juegos de la observación
          int cantidadJuegos = 1; // Por defecto 1
          final observacionCompleta = '$juegosObservacion $juegosPinturaObs';
          if (observacionCompleta.isNotEmpty) {
            final regex = RegExp(
              r'(\d+)\s*(juego|módulo|elemento)',
              caseSensitive: false,
            );
            final match = regex.firstMatch(observacionCompleta);
            if (match != null) {
              cantidadJuegos = int.tryParse(match.group(1) ?? '1') ?? 1;
            }
          }
          totalJuegos += cantidadJuegos;
        }

        // Basureros
        final basurerosEstructural =
            evaluaciones?['Estado estructural basureros']?.toString() ?? 'N/A';
        final basurerosPintura =
            evaluaciones?['Estado pintura de basureros']?.toString() ?? 'N/A';
        final basurerosObservacion =
            observaciones?['Estado estructural basureros']?.toString() ?? '';
        final basurerosPinturaObs =
            observaciones?['Estado pintura de basureros']?.toString() ?? '';

        final tieneBasureros =
            basurerosEstructural != 'N/A' || basurerosPintura != 'N/A';
        if (tieneBasureros) {
          areasConBasureros++;
          // Extraer cantidad de basureros de la observación
          int cantidadBasureros = 1; // Por defecto 1
          final observacionCompleta =
              '$basurerosObservacion $basurerosPinturaObs';
          if (observacionCompleta.isNotEmpty) {
            final regex = RegExp(
              r'(\d+)\s*(basurero|contenedor|papelera)',
              caseSensitive: false,
            );
            final match = regex.firstMatch(observacionCompleta);
            if (match != null) {
              cantidadBasureros = int.tryParse(match.group(1) ?? '1') ?? 1;
            }
          }
          totalBasureros += cantidadBasureros;
        }

        // Arranques de Agua
        final arranquesEstado =
            evaluaciones?[campoArranques]?.toString() ?? 'N/A';
        final arranquesObservacion =
            observaciones?[campoArranques]?.toString() ?? '';

        final tieneArranques = arranquesEstado != 'N/A';
        if (tieneArranques) {
          areasConArranques++;

          // Intentar extraer cantidad de arranques de la observación
          int cantidadArranques = 1; // Por defecto 1
          if (arranquesObservacion.isNotEmpty) {
            final regex = RegExp(
              r'(\d+)\s*(arranque|llave)',
              caseSensitive: false,
            );
            final match = regex.firstMatch(arranquesObservacion);
            if (match != null) {
              cantidadArranques = int.tryParse(match.group(1) ?? '1') ?? 1;
            }
          }
          totalArranques += cantidadArranques;
        }

        // Actualizar contadores de estados
        _actualizarEstados(
          estadosPorComponente['bancas_estructural']!,
          bancasEstructural,
        );
        _actualizarEstados(
          estadosPorComponente['bancas_pintura']!,
          bancasPintura,
        );
        _actualizarEstados(
          estadosPorComponente['juegos_estructural']!,
          juegosEstructural,
        );
        _actualizarEstados(
          estadosPorComponente['juegos_pintura']!,
          juegosPintura,
        );
        _actualizarEstados(
          estadosPorComponente['basureros_estructural']!,
          basurerosEstructural,
        );
        _actualizarEstados(
          estadosPorComponente['basureros_pintura']!,
          basurerosPintura,
        );
        _actualizarEstados(estadosPorComponente['arranques']!, arranquesEstado);

        // Agregar fila al Excel
        datosExcel.add({
          'plaza_id': plazaId,
          'nombre_plaza': nombre,
          'comuna': comuna,
          'direccion': direccion,
          'gps_lat': gpsLat,
          'gps_lng': gpsLng,
          'tiene_catastro': tieneCatastro ? 'SÍ' : 'NO',

          // Bancas
          'bancas_estructural': bancasEstructural,
          'bancas_pintura': bancasPintura,
          'bancas_observacion': bancasObservacion.isNotEmpty
              ? bancasObservacion
              : bancasPinturaObs,

          // Juegos
          'juegos_estructural': juegosEstructural,
          'juegos_pintura': juegosPintura,
          'juegos_observacion': juegosObservacion.isNotEmpty
              ? juegosObservacion
              : juegosPinturaObs,

          // Basureros
          'basureros_estructural': basurerosEstructural,
          'basureros_pintura': basurerosPintura,
          'basureros_observacion': basurerosObservacion.isNotEmpty
              ? basurerosObservacion
              : basurerosPinturaObs,

          // Arranques
          'arranques_estado': arranquesEstado,
          'arranques_observacion': arranquesObservacion,

          // Resumen por área
          'componentes_evaluados': [
            tieneBancas ? 'Bancas' : '',
            tieneJuegos ? 'Juegos' : '',
            tieneBasureros ? 'Basureros' : '',
            tieneArranques ? 'Arranques' : '',
          ].where((c) => c.isNotEmpty).join(', '),
        });
      }

      return {
        'datos_excel': datosExcel,
        'total_areas': plazasResponse.length,
        'areas_catastradas': catastrosPorPlaza.length,
        'areas_sin_catastro': plazasResponse.length - catastrosPorPlaza.length,

        // Totales por componente
        'total_bancas': totalBancas,
        'total_juegos': totalJuegos,
        'total_basureros': totalBasureros,
        'total_arranques': totalArranques,

        // Áreas con componentes
        'areas_con_bancas': areasConBancas,
        'areas_con_juegos': areasConJuegos,
        'areas_con_basureros': areasConBasureros,
        'areas_con_arranques': areasConArranques,

        // Estados por componente
        'estados_por_componente': estadosPorComponente,

        // NUEVO: Estadísticas generales con porcentajes
        'estadisticas_generales': _calcularEstadisticasGenerales(
          datosExcel,
          plazasResponse.length,
        ),

        // NUEVO: Análisis de daños por componente con porcentajes
        'analisis_danos': _calcularAnalisisDanos(estadosPorComponente),
      };
    } catch (e, stackTrace) {
      debugPrint('❌ [Catastro Detallado] Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'datos_excel': <Map<String, dynamic>>[],
        'total_areas': 0,
        'error': e.toString(),
      };
    }
  }

  /// Actualiza contadores de estados
  static void _actualizarEstados(Map<String, int> contador, String estado) {
    if (contador.containsKey(estado)) {
      contador[estado] = contador[estado]! + 1;
    } else {
      contador['N/A'] = contador['N/A']! + 1;
    }
  }

  /// Calcula análisis de daños por componente con porcentajes
  static Map<String, dynamic> _calcularAnalisisDanos(
    Map<String, Map<String, int>> estadosPorComponente,
  ) {
    final analisis = <String, Map<String, dynamic>>{};

    for (var entry in estadosPorComponente.entries) {
      final componente = entry.key;
      final estados = entry.value;

      // Calcular totales
      final excelente = estados['Excelente'] ?? 0;
      final bueno = estados['Bueno'] ?? 0;
      final regular = estados['Regular'] ?? 0;
      final malo = estados['Malo'] ?? 0;
      final na = estados['N/A'] ?? 0;

      final totalEvaluados = excelente + bueno + regular + malo;
      final totalConDanos = regular + malo;
      final totalBuenEstado = excelente + bueno;

      // Calcular porcentajes
      final porcentajeExcelente = totalEvaluados > 0
          ? (excelente * 100.0 / totalEvaluados)
          : 0.0;
      final porcentajeBueno = totalEvaluados > 0
          ? (bueno * 100.0 / totalEvaluados)
          : 0.0;
      final porcentajeRegular = totalEvaluados > 0
          ? (regular * 100.0 / totalEvaluados)
          : 0.0;
      final porcentajeMalo = totalEvaluados > 0
          ? (malo * 100.0 / totalEvaluados)
          : 0.0;
      final porcentajeBuenEstado = totalEvaluados > 0
          ? (totalBuenEstado * 100.0 / totalEvaluados)
          : 0.0;
      final porcentajeDanos = totalEvaluados > 0
          ? (totalConDanos * 100.0 / totalEvaluados)
          : 0.0;

      analisis[componente] = {
        'excelente': excelente,
        'bueno': bueno,
        'regular': regular,
        'malo': malo,
        'n_a': na,
        'total_evaluados': totalEvaluados,
        'total_buen_estado': totalBuenEstado,
        'total_con_danos': totalConDanos,
        'porcentaje_excelente': porcentajeExcelente,
        'porcentaje_bueno': porcentajeBueno,
        'porcentaje_regular': porcentajeRegular,
        'porcentaje_malo': porcentajeMalo,
        'porcentaje_buen_estado': porcentajeBuenEstado,
        'porcentaje_danos': porcentajeDanos,
      };
    }

    return analisis;
  }

  /// Calcula estadísticas generales con porcentajes para áreas verdes
  static Map<String, dynamic> _calcularEstadisticasGenerales(
    List<Map<String, dynamic>> datosExcel,
    int totalAreas,
  ) {
    // Contar estados generales por cada componente
    final Map<String, int> estadosGenerales = {
      'Excelente': 0,
      'Bueno': 0,
      'Regular': 0,
      'Malo': 0,
      'Sin Evaluar': 0,
    };

    for (var area in datosExcel) {
      // Determinar estado general del área basado en el peor estado de sus componentes
      final List<String> estadosArea = [
        area['bancas_estructural']?.toString() ?? 'N/A',
        area['bancas_pintura']?.toString() ?? 'N/A',
        area['juegos_estructural']?.toString() ?? 'N/A',
        area['juegos_pintura']?.toString() ?? 'N/A',
        area['basureros_estructural']?.toString() ?? 'N/A',
        area['basureros_pintura']?.toString() ?? 'N/A',
        area['arranques_estado']?.toString() ?? 'N/A',
      ];

      // Filtrar solo estados válidos (no N/A)
      final estadosValidos = estadosArea.where((e) => e != 'N/A').toList();

      String estadoGeneral;
      if (estadosValidos.isEmpty) {
        estadoGeneral = 'Sin Evaluar';
      } else if (estadosValidos.contains('Malo')) {
        estadoGeneral = 'Malo';
      } else if (estadosValidos.contains('Regular')) {
        estadoGeneral = 'Regular';
      } else if (estadosValidos.contains('Bueno')) {
        estadoGeneral = 'Bueno';
      } else if (estadosValidos.contains('Excelente')) {
        estadoGeneral = 'Excelente';
      } else {
        estadoGeneral = 'Sin Evaluar';
      }

      estadosGenerales[estadoGeneral] = estadosGenerales[estadoGeneral]! + 1;
    }

    // Calcular porcentajes
    final Map<String, double> porcentajes = {};
    for (var entry in estadosGenerales.entries) {
      final porcentaje = totalAreas > 0
          ? (entry.value * 100.0 / totalAreas)
          : 0.0;
      porcentajes[entry.key] = porcentaje;
    }

    return {
      'contadores': estadosGenerales,
      'porcentajes': porcentajes,
      'total_areas': totalAreas,
    };
  }

  /// Genera CSV detallado por componentes
  static String generarCSVCatastroDetallado(List<Map<String, dynamic>> datos) {
    final buffer = StringBuffer();

    // BOM UTF-8 para acentos correctos en Excel
    buffer.write('\uFEFF');

    // Encabezados
    buffer.writeln(
      [
        'ID Plaza',
        'Nombre Área Verde',
        'Comuna',
        'Dirección',
        'GPS Latitud',
        'GPS Longitud',
        'Tiene Catastro',
        'Bancas: Estado Estructural',
        'Bancas: Estado Pintura',
        'Bancas: Observaciones',
        'Juegos: Estado Estructural',
        'Juegos: Estado Pintura',
        'Juegos: Observaciones',
        'Basureros: Estado Estructural',
        'Basureros: Estado Pintura',
        'Basureros: Observaciones',
        'Arranques: Estado',
        'Arranques: Observaciones',
        'Componentes Evaluados',
      ].join(';'),
    );

    // Datos
    for (var dato in datos) {
      final fila = [
        dato['plaza_id']?.toString() ?? '',
        _escaparCSV(dato['nombre_plaza']?.toString() ?? ''),
        _escaparCSV(dato['comuna']?.toString() ?? ''),
        _escaparCSV(dato['direccion']?.toString() ?? ''),
        dato['gps_lat']?.toString() ?? '',
        dato['gps_lng']?.toString() ?? '',
        dato['tiene_catastro']?.toString() ?? '',
        dato['bancas_estructural']?.toString() ?? '',
        dato['bancas_pintura']?.toString() ?? '',
        _escaparCSV(dato['bancas_observacion']?.toString() ?? ''),
        dato['juegos_estructural']?.toString() ?? '',
        dato['juegos_pintura']?.toString() ?? '',
        _escaparCSV(dato['juegos_observacion']?.toString() ?? ''),
        dato['basureros_estructural']?.toString() ?? '',
        dato['basureros_pintura']?.toString() ?? '',
        _escaparCSV(dato['basureros_observacion']?.toString() ?? ''),
        dato['arranques_estado']?.toString() ?? '',
        _escaparCSV(dato['arranques_observacion']?.toString() ?? ''),
        _escaparCSV(dato['componentes_evaluados']?.toString() ?? ''),
      ];

      buffer.writeln(fila.join(';'));
    }

    return buffer.toString();
  }

  /// Genera CSV detallado con análisis de daños
  static String generarCSVCatastroDetalladoConAnalisis(
    List<Map<String, dynamic>> datos,
    Map<String, dynamic> analisisDanos,
    int totalBancas,
    int totalJuegos,
    int totalBasureros,
    int totalArranques,
  ) {
    final buffer = StringBuffer();

    // BOM UTF-8 para acentos correctos en Excel
    buffer.write('\uFEFF');

    // ==========================================
    // HOJA 1: DATOS DETALLADOS POR ÁREA
    // ==========================================
    buffer.writeln('=== CATASTRO DETALLADO POR COMPONENTES ===');
    buffer.writeln('');

    // Encabezados
    buffer.writeln(
      [
        'ID Plaza',
        'Nombre Área Verde',
        'Comuna',
        'Dirección',
        'GPS Latitud',
        'GPS Longitud',
        'Tiene Catastro',
        'Bancas: Estado Estructural',
        'Bancas: Estado Pintura',
        'Bancas: Observaciones',
        'Juegos: Estado Estructural',
        'Juegos: Estado Pintura',
        'Juegos: Observaciones',
        'Basureros: Estado Estructural',
        'Basureros: Estado Pintura',
        'Basureros: Observaciones',
        'Arranques: Estado',
        'Arranques: Observaciones',
        'Componentes Evaluados',
      ].join(';'),
    );

    // Datos
    for (var dato in datos) {
      final fila = [
        dato['plaza_id']?.toString() ?? '',
        _escaparCSV(dato['nombre_plaza']?.toString() ?? ''),
        _escaparCSV(dato['comuna']?.toString() ?? ''),
        _escaparCSV(dato['direccion']?.toString() ?? ''),
        dato['gps_lat']?.toString() ?? '',
        dato['gps_lng']?.toString() ?? '',
        dato['tiene_catastro']?.toString() ?? '',
        dato['bancas_estructural']?.toString() ?? '',
        dato['bancas_pintura']?.toString() ?? '',
        _escaparCSV(dato['bancas_observacion']?.toString() ?? ''),
        dato['juegos_estructural']?.toString() ?? '',
        dato['juegos_pintura']?.toString() ?? '',
        _escaparCSV(dato['juegos_observacion']?.toString() ?? ''),
        dato['basureros_estructural']?.toString() ?? '',
        dato['basureros_pintura']?.toString() ?? '',
        _escaparCSV(dato['basureros_observacion']?.toString() ?? ''),
        dato['arranques_estado']?.toString() ?? '',
        _escaparCSV(dato['arranques_observacion']?.toString() ?? ''),
        _escaparCSV(dato['componentes_evaluados']?.toString() ?? ''),
      ];

      buffer.writeln(fila.join(';'));
    }

    // ==========================================
    // HOJA 2: ANÁLISIS DE DAÑOS Y PORCENTAJES
    // ==========================================
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('=== ANÁLISIS DE DAÑOS POR COMPONENTE ===');
    buffer.writeln('');

    // Resumen de cantidades totales
    buffer.writeln('CANTIDADES TOTALES:');
    buffer.writeln('Componente;Cantidad Total');
    buffer.writeln('Bancas;$totalBancas');
    buffer.writeln('Juegos Infantiles;$totalJuegos');
    buffer.writeln('Basureros;$totalBasureros');
    buffer.writeln('Arranques de Agua;$totalArranques');
    buffer.writeln('');

    // Análisis por componente
    final componentes = {
      'bancas_estructural': 'BANCAS - Estado Estructural',
      'bancas_pintura': 'BANCAS - Estado Pintura',
      'juegos_estructural': 'JUEGOS INFANTILES - Estado Estructural',
      'juegos_pintura': 'JUEGOS INFANTILES - Estado Pintura',
      'basureros_estructural': 'BASUREROS - Estado Estructural',
      'basureros_pintura': 'BASUREROS - Estado Pintura',
      'arranques': 'ARRANQUES DE AGUA - Estado',
    };

    for (var entry in componentes.entries) {
      final key = entry.key;
      final nombre = entry.value;
      final analisis = analisisDanos[key] as Map<String, dynamic>?;

      if (analisis != null) {
        buffer.writeln('');
        buffer.writeln(nombre);
        buffer.writeln('Estado;Cantidad;Porcentaje');
        buffer.writeln(
          'Excelente;${analisis['excelente']};${analisis['porcentaje_excelente'].toStringAsFixed(1)}%',
        );
        buffer.writeln(
          'Bueno;${analisis['bueno']};${analisis['porcentaje_bueno'].toStringAsFixed(1)}%',
        );
        buffer.writeln(
          'Regular;${analisis['regular']};${analisis['porcentaje_regular'].toStringAsFixed(1)}%',
        );
        buffer.writeln(
          'Malo;${analisis['malo']};${analisis['porcentaje_malo'].toStringAsFixed(1)}%',
        );
        buffer.writeln('N/A;${analisis['n_a']};-');
        buffer.writeln('TOTAL EVALUADOS;${analisis['total_evaluados']};100.0%');
        buffer.writeln('');
        buffer.writeln('RESUMEN:');
        buffer.writeln(
          'Buen Estado (Exc+Bueno);${analisis['total_buen_estado']};${analisis['porcentaje_buen_estado'].toStringAsFixed(1)}%',
        );
        buffer.writeln(
          'Con Daños (Reg+Malo);${analisis['total_con_danos']};${analisis['porcentaje_danos'].toStringAsFixed(1)}%',
        );
      }
    }

    return buffer.toString();
  }

  /// Genera resumen detallado con totales
  static String generarResumenDetallado(Map<String, dynamic> datos) {
    final buffer = StringBuffer();

    buffer.writeln('=== CATASTRO DETALLADO POR COMPONENTES ===');
    buffer.writeln(
      'Fecha generación: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
    );
    buffer.writeln('');

    buffer.writeln('📊 RESUMEN GENERAL:');
    buffer.writeln('• Total áreas verdes: ${datos['total_areas']}');
    buffer.writeln('• Áreas catastradas: ${datos['areas_catastradas']}');
    buffer.writeln('• Áreas SIN catastro: ${datos['areas_sin_catastro']}');
    buffer.writeln('');

    buffer.writeln('🏗️ TOTALES POR COMPONENTE:');
    buffer.writeln(
      '• Total Bancas: ${datos['total_bancas']} (en ${datos['areas_con_bancas']} áreas)',
    );
    buffer.writeln(
      '• Total Juegos Infantiles: ${datos['total_juegos']} (en ${datos['areas_con_juegos']} áreas)',
    );
    buffer.writeln(
      '• Total Basureros: ${datos['total_basureros']} (en ${datos['areas_con_basureros']} áreas)',
    );
    buffer.writeln(
      '• Total Arranques de Agua: ${datos['total_arranques']} (en ${datos['areas_con_arranques']} áreas)',
    );
    buffer.writeln('');

    final estadosPorComponente =
        datos['estados_por_componente'] as Map<String, Map<String, int>>;

    buffer.writeln('📋 ESTADOS POR COMPONENTE:');
    buffer.writeln('');

    buffer.writeln('🪑 BANCAS:');
    buffer.writeln(
      '   Estructural: ${_formatearEstados(estadosPorComponente['bancas_estructural']!)}',
    );
    buffer.writeln(
      '   Pintura: ${_formatearEstados(estadosPorComponente['bancas_pintura']!)}',
    );
    buffer.writeln('');

    buffer.writeln('🎠 JUEGOS INFANTILES:');
    buffer.writeln(
      '   Estructural: ${_formatearEstados(estadosPorComponente['juegos_estructural']!)}',
    );
    buffer.writeln(
      '   Pintura: ${_formatearEstados(estadosPorComponente['juegos_pintura']!)}',
    );
    buffer.writeln('');

    buffer.writeln('🗑️ BASUREROS:');
    buffer.writeln(
      '   Estructural: ${_formatearEstados(estadosPorComponente['basureros_estructural']!)}',
    );
    buffer.writeln(
      '   Pintura: ${_formatearEstados(estadosPorComponente['basureros_pintura']!)}',
    );
    buffer.writeln('');

    buffer.writeln('💧 ARRANQUES DE AGUA:');
    buffer.writeln(
      '   Estado: ${_formatearEstados(estadosPorComponente['arranques']!)}',
    );

    return buffer.toString();
  }

  /// Formatea estados para el resumen
  static String _formatearEstados(Map<String, int> estados) {
    return estados.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
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
