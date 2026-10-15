import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';

/// Servicio para generar Excel de Inspecciones Técnicas COMPLETAS
/// Incluye TODAS las secciones: Aseo, Césped, Arbolado, Flores, Caminos, Infraestructura, Catastro Inmuebles
class InspeccionesTecnicasExcelService {
  static final _supabase = Supabase.instance.client;

  /// TODOS los criterios de inspección técnica (7 secciones)
  static const Map<String, List<String>> _todosLosCriterios = {
    'ASEO': [
      'Basura por tiempo indebido pero con recolección.',
      'Residuos acumulados de días anteriores.',
      'Presencia de escombros o desechos.',
      'Aseo externo o interior en áreas específicas (ciclovías), no realizado o realizado parcialmente.',
      'Basureros sucios o en mal estado.',
      'Aseo sin realizar espacio abiertamente sucio (aplicable en ciclovías).',
      'No hay residuos sólidos.',
    ],
    'CÉSPED': [
      'Presencia de césped seco o amarillento.',
      'Zonas con baja densidad de césped.',
      'Pasto cortado sin retirar.',
      'Gran cantidad de malezas.',
    ],
    'ARBOLADO': [
      'Árboles y arbustos con enfermedad y/o mala conformación.',
      'Ramas menores secas, en mal estado, zonas defoliadas.',
      'Ejemplares sin tutores requiriéndolos no más de 10%.',
      'Tazas faltantes o en mal estado no más de 10%.',
      'Necesidad de podas.',
      'Faltan tutores.',
      'Falta de tazas sobre 10%.',
      'Gran cantidad de ejemplares requiriendo podas (30%).',
      'Falta protector de PVC.',
    ],
    'FLORES': [
      'Ejemplares mal cuidados, flores, ramas o ramillas secas.',
      'Se observa basura.',
      'Terreno se escarba con dificultad, mal aspecto.',
      'Densidad menor a las exigencias de las bases.',
      'Ejemplares perdidos y descuidados, pérdida de macizo no delimitado.',
      'Terreno sucio.',
      'Terreno compacto.',
      'Densidad inferior al 30% de las exigencias de las bases.',
      'Presencia de malezas.',
    ],
    'CAMINOS': [
      'Observación de malezas, incluye CICLOVÍA.',
      'Material árido disparejo.',
      'Sin árido en zonas extensas se observa suelo compacto.',
      'Malezas en gran parte de la superficie.',
      'Material de mala calidad.',
    ],
    'INFRAESTRUCTURA': [
      'Estructuras que requieren mantención.',
      'Necesidad de pintura en estructuras.',
      'Pérdidas de agua en el sistema de riego.',
      'Se requiere hacer mantención de más del 30% de la infraestructura.',
      'Se requiere pintar más del 30% de la infraestructura.',
      'Falta de candado o cierre de acceso al agua.',
      'Se requiere reparación de alguna estructura (ej: falta tapa de nicho).',
    ],
    'CATASTRO DE INMUEBLE DE AREAS VERDES': [
      'Estado estructural de bancas',
      'Estado pintura bancas',
      'Estado estructural juegos infantiles',
      'Estado de pintura de juegos infantiles',
      'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)',
      'Estado estructural basureros',
      'Estado pintura de basureros',
    ],
  };

  /// Total de ítems evaluables en toda la inspección técnica
  static int get totalItemsEvaluables {
    return _todosLosCriterios.values
        .map((criterios) => criterios.length)
        .reduce((a, b) => a + b);
  }

  /// Obtiene datos de inspecciones técnicas COMPLETAS para Excel
  static Future<Map<String, dynamic>> obtenerDatosInspeccionesTecnicas() async {
    try {
      debugPrint('📊 [Inspecciones Técnicas] Obteniendo inspecciones técnicas...');
      debugPrint('📊 Total ítems evaluables: $totalItemsEvaluables');

      // Obtener todas las inspecciones técnicas con evaluaciones
      final response = await _supabase
          .from('inspecciones_tecnicas')
          .select(
            'id, plaza_id, nombre_plaza, inspector, fecha_legible, estado_general, evaluaciones, observaciones, fecha_hora_registro',
          )
          .order('fecha_hora_registro', ascending: false);

      debugPrint('✅ [Inspecciones Técnicas] ${response.length} inspecciones encontradas');

      // Obtener información de las plazas para coordenadas y dirección
      final plazasResponse = await _supabase
          .from('plazas')
          .select('id, nombre, comuna, latitud, longitud, direccion');

      final plazasMap = <String, Map<String, dynamic>>{};
      for (var plaza in plazasResponse) {
        final plazaId = plaza['id'].toString();
        plazasMap[plazaId] = plaza;
      }

      // Procesar datos para el Excel
      final List<Map<String, dynamic>> datosExcel = [];
      final Map<String, int> estadisticasItems = {};
      final Map<String, Map<String, int>> estadosPorItem = {};
      final Map<String, int> estadisticasPorSeccion = {};

      int inspeccionesCompletas = 0;
      int inspeccionesIncompletas = 0;

      for (var inspeccion in response) {
        final evaluaciones = inspeccion['evaluaciones'] as Map<String, dynamic>?;
        final observaciones = inspeccion['observaciones'] as Map<String, dynamic>?;
        final plazaId = inspeccion['plaza_id']?.toString();
        final plazaInfo = plazasMap[plazaId];

        if (evaluaciones != null) {
          // Contar ítems por sección
          final Map<String, int> itemsPorSeccion = {};
          final Map<String, int> estadosPorSeccion = {
            'excelentes': 0,
            'buenos': 0, 
            'regulares': 0,
            'malos': 0
          };

          int totalItemsEvaluados = 0;
          int totalExcelentes = 0, totalBuenos = 0, totalRegulares = 0, totalMalos = 0;

          // Procesar cada sección
          for (String seccion in _todosLosCriterios.keys) {
            final criteriosSeccion = _todosLosCriterios[seccion]!;
            int itemsEvaladosSeccion = 0;

            for (String criterio in criteriosSeccion) {
              if (evaluaciones.containsKey(criterio)) {
                itemsEvaladosSeccion++;
                totalItemsEvaluados++;

                // Estadísticas generales por ítem
                estadisticasItems[criterio] = (estadisticasItems[criterio] ?? 0) + 1;

                // Estados por ítem
                if (!estadosPorItem.containsKey(criterio)) {
                  estadosPorItem[criterio] = {'Excelente': 0, 'Bueno': 0, 'Regular': 0, 'Malo': 0};
                }

                final estado = evaluaciones[criterio]?.toString() ?? '';
                final estadoLower = estado.toLowerCase();

                switch (estadoLower) {
                  case 'excelente':
                    totalExcelentes++;
                    estadosPorSeccion['excelentes'] = estadosPorSeccion['excelentes']! + 1;
                    estadosPorItem[criterio]!['Excelente'] = estadosPorItem[criterio]!['Excelente']! + 1;
                    break;
                  case 'bueno':
                    totalBuenos++;
                    estadosPorSeccion['buenos'] = estadosPorSeccion['buenos']! + 1;
                    estadosPorItem[criterio]!['Bueno'] = estadosPorItem[criterio]!['Bueno']! + 1;
                    break;
                  case 'regular':
                    totalRegulares++;
                    estadosPorSeccion['regulares'] = estadosPorSeccion['regulares']! + 1;
                    estadosPorItem[criterio]!['Regular'] = estadosPorItem[criterio]!['Regular']! + 1;
                    break;
                  case 'malo':
                  case 'crítico':
                  case 'critico':
                    totalMalos++;
                    estadosPorSeccion['malos'] = estadosPorSeccion['malos']! + 1;
                    estadosPorItem[criterio]!['Malo'] = estadosPorItem[criterio]!['Malo']! + 1;
                    break;
                }
              }
            }

            itemsPorSeccion[seccion] = itemsEvaladosSeccion;
            estadisticasPorSeccion[seccion] = (estadisticasPorSeccion[seccion] ?? 0) + itemsEvaladosSeccion;
          }

          final esCompleta = totalItemsEvaluados == totalItemsEvaluables;
          if (esCompleta) {
            inspeccionesCompletas++;
          } else {
            inspeccionesIncompletas++;
          }

          // Crear lista de ítems evaluados y faltantes
          final List<String> itemsEvaluados = evaluaciones.keys.toList();
          final List<String> itemsFaltantes = [];
          
          for (String seccion in _todosLosCriterios.keys) {
            for (String criterio in _todosLosCriterios[seccion]!) {
              if (!evaluaciones.containsKey(criterio)) {
                itemsFaltantes.add(criterio);
              }
            }
          }

          datosExcel.add({
            'inspeccion_id': inspeccion['id'],
            'plaza_id': plazaId ?? '',
            'nombre_plaza': inspeccion['nombre_plaza'] ?? 'Sin nombre',
            'inspector': inspeccion['inspector'] ?? 'Sin inspector',
            'fecha': inspeccion['fecha_legible'] ?? 'Sin fecha',
            'estado_general': inspeccion['estado_general'] ?? 'Sin evaluar',
            'comuna': plazaInfo?['comuna'] ?? 'Sin comuna',
            'direccion': plazaInfo?['direccion'] ?? 'Sin dirección',
            'gps_lat': plazaInfo?['latitud']?.toString() ?? 'N/A',
            'gps_lng': plazaInfo?['longitud']?.toString() ?? 'N/A',
            'total_items_evaluados': totalItemsEvaluados,
            'total_items_posibles': totalItemsEvaluables,
            'items_faltantes_count': itemsFaltantes.length,
            'items_faltantes': itemsFaltantes.join('; '),
            'es_inspeccion_completa': esCompleta ? 'SÍ' : 'NO',
            'porcentaje_completitud': totalItemsEvaluables > 0 
                ? ((totalItemsEvaluados * 100) / totalItemsEvaluables).toStringAsFixed(1)
                : '0.0',
            'excelentes': totalExcelentes,
            'buenos': totalBuenos,
            'regulares': totalRegulares,
            'malos': totalMalos,
            // Por sección
            'aseo_evaluados': itemsPorSeccion['ASEO'] ?? 0,
            'aseo_total': _todosLosCriterios['ASEO']!.length,
            'cesped_evaluados': itemsPorSeccion['CÉSPED'] ?? 0,
            'cesped_total': _todosLosCriterios['CÉSPED']!.length,
            'arbolado_evaluados': itemsPorSeccion['ARBOLADO'] ?? 0,
            'arbolado_total': _todosLosCriterios['ARBOLADO']!.length,
            'flores_evaluados': itemsPorSeccion['FLORES'] ?? 0,
            'flores_total': _todosLosCriterios['FLORES']!.length,
            'caminos_evaluados': itemsPorSeccion['CAMINOS'] ?? 0,
            'caminos_total': _todosLosCriterios['CAMINOS']!.length,
            'infraestructura_evaluados': itemsPorSeccion['INFRAESTRUCTURA'] ?? 0,
            'infraestructura_total': _todosLosCriterios['INFRAESTRUCTURA']!.length,
            'catastro_evaluados': itemsPorSeccion['CATASTRO DE INMUEBLE DE AREAS VERDES'] ?? 0,
            'catastro_total': _todosLosCriterios['CATASTRO DE INMUEBLE DE AREAS VERDES']!.length,
            'items_evaluados_detalle': itemsEvaluados.join('; '),
            'evaluaciones_completas': evaluaciones.entries
                .map((e) => '${e.key}: ${e.value}')
                .join(' | '),
          });
        }
      }

      return {
        'datos_excel': datosExcel,
        'total_inspecciones': response.length,
        'total_items_posibles': totalItemsEvaluables,
        'inspecciones_completas': inspeccionesCompletas,
        'inspecciones_incompletas': inspeccionesIncompletas,
        'estadisticas_items': estadisticasItems,
        'estados_por_item': estadosPorItem,
        'estadisticas_por_seccion': estadisticasPorSeccion,
        'item_mas_evaluado': estadisticasItems.isNotEmpty
            ? estadisticasItems.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key
            : null,
      };
    } catch (e, stackTrace) {
      debugPrint('❌ [Inspecciones Técnicas] Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'datos_excel': <Map<String, dynamic>>[],
        'total_inspecciones': 0,
        'error': e.toString(),
      };
    }
  }

  /// Genera CSV completo para Excel con TODAS las secciones de inspecciones técnicas
  static String generarCSVInspeccionesTecnicas(List<Map<String, dynamic>> datos) {
    final buffer = StringBuffer();

    // BOM UTF-8 para acentos correctos en Excel
    buffer.write('\uFEFF');

    // Encabezados (usando ; para Excel en español)
    buffer.writeln([
      'ID Inspección',
      'ID Plaza',
      'Nombre Plaza',
      'Inspector',
      'Fecha Inspección',
      'Estado General',
      'Comuna',
      'Dirección',
      'GPS Latitud',
      'GPS Longitud',
      'Total Ítems Evaluados',
      'Total Ítems Posibles',
      'Porcentaje Completitud',
      'Ítems Faltantes (Cantidad)',
      'Inspección Completa',
      'Estados: Excelente',
      'Estados: Bueno',
      'Estados: Regular',
      'Estados: Malo',
      'Aseo: Evaluados/Total',
      'Césped: Evaluados/Total',
      'Arbolado: Evaluados/Total',
      'Flores: Evaluados/Total', 
      'Caminos: Evaluados/Total',
      'Infraestructura: Evaluados/Total',
      'Catastro: Evaluados/Total',
      'Ítems Evaluados (Detalle)',
      'Ítems Faltantes (Detalle)',
      'Evaluaciones Completas',
    ].join(';'));

    // Datos
    for (var dato in datos) {
      final fila = [
        dato['inspeccion_id']?.toString() ?? '',
        dato['plaza_id']?.toString() ?? '',
        _escaparCSV(dato['nombre_plaza']?.toString() ?? ''),
        _escaparCSV(dato['inspector']?.toString() ?? ''),
        dato['fecha']?.toString() ?? '',
        dato['estado_general']?.toString() ?? '',
        _escaparCSV(dato['comuna']?.toString() ?? ''),
        _escaparCSV(dato['direccion']?.toString() ?? ''),
        dato['gps_lat']?.toString() ?? '',
        dato['gps_lng']?.toString() ?? '',
        dato['total_items_evaluados']?.toString() ?? '0',
        dato['total_items_posibles']?.toString() ?? '0',
        '${dato['porcentaje_completitud']?.toString() ?? '0.0'}%',
        dato['items_faltantes_count']?.toString() ?? '0',
        dato['es_inspeccion_completa']?.toString() ?? 'NO',
        dato['excelentes']?.toString() ?? '0',
        dato['buenos']?.toString() ?? '0',
        dato['regulares']?.toString() ?? '0',
        dato['malos']?.toString() ?? '0',
        '${dato['aseo_evaluados'] ?? 0}/${dato['aseo_total'] ?? 0}',
        '${dato['cesped_evaluados'] ?? 0}/${dato['cesped_total'] ?? 0}',
        '${dato['arbolado_evaluados'] ?? 0}/${dato['arbolado_total'] ?? 0}',
        '${dato['flores_evaluados'] ?? 0}/${dato['flores_total'] ?? 0}',
        '${dato['caminos_evaluados'] ?? 0}/${dato['caminos_total'] ?? 0}',
        '${dato['infraestructura_evaluados'] ?? 0}/${dato['infraestructura_total'] ?? 0}',
        '${dato['catastro_evaluados'] ?? 0}/${dato['catastro_total'] ?? 0}',
        _escaparCSV(dato['items_evaluados_detalle']?.toString() ?? ''),
        _escaparCSV(dato['items_faltantes']?.toString() ?? ''),
        _escaparCSV(dato['evaluaciones_completas']?.toString() ?? ''),
      ];

      buffer.writeln(fila.join(';'));
    }

    return buffer.toString();
  }

  /// Escapar texto para CSV (punto y coma como separador)
  static String _escaparCSV(String texto) {
    if (texto.isEmpty) return texto;
    
    // Reemplazar punto y coma por coma (para evitar conflictos)
    String textoLimpio = texto.replaceAll(';', ',');

    // Si contiene comas, saltos de línea o comillas, envolver en comillas
    if (textoLimpio.contains(',') ||
        textoLimpio.contains('\n') ||
        textoLimpio.contains('"')) {
      return '"${textoLimpio.replaceAll('"', '""')}"';
    }
    return textoLimpio;
  }

  /// Genera resumen ejecutivo con todas las estadísticas
  static String generarResumenEstadisticas(Map<String, dynamic> datos) {
    final buffer = StringBuffer();
    
    buffer.writeln('=== RESUMEN INSPECCIONES TÉCNICAS COMPLETAS ===');
    buffer.writeln('Fecha generación: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}');
    buffer.writeln('');
    
    buffer.writeln('📊 ESTADÍSTICAS GENERALES:');
    buffer.writeln('• Total inspecciones: ${datos['total_inspecciones']}');
    buffer.writeln('• Total ítems evaluables: ${datos['total_items_posibles']} ítems');
    buffer.writeln('• Inspecciones completas: ${datos['inspecciones_completas']}');
    buffer.writeln('• Inspecciones incompletas: ${datos['inspecciones_incompletas']}');
    
    if (datos['total_inspecciones'] > 0) {
      final porcentajeCompletas = (datos['inspecciones_completas'] * 100.0 / datos['total_inspecciones']).toStringAsFixed(1);
      buffer.writeln('• Porcentaje completitud: $porcentajeCompletas%');
    }
    
    buffer.writeln('');
    
    if (datos['item_mas_evaluado'] != null) {
      buffer.writeln('🏆 ÍTEM MÁS EVALUADO:');
      buffer.writeln('• ${datos['item_mas_evaluado']}');
      buffer.writeln('');
    }
    
    buffer.writeln('📋 SECCIONES DE INSPECCIÓN TÉCNICA:');
    for (String seccion in _todosLosCriterios.keys) {
      final criterios = _todosLosCriterios[seccion]!;
      buffer.writeln('${seccion}: ${criterios.length} ítems');
    }
    buffer.writeln('');
    buffer.writeln('📈 TOTAL GENERAL: $totalItemsEvaluables ítems evaluables');
    
    return buffer.toString();
  }
}