import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:intl/intl.dart';

/// Servicio para generar Excel de Inspecciones Técnicas COMPLETAS
/// Incluye TODAS las secciones: Aseo, Césped, Arbolado, Flores, Caminos, Infraestructura, Catastro Inmuebles
class CatastroInmueblesExcelService {
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

  /// Obtiene datos de catastro de inmuebles para Excel
  static Future<Map<String, dynamic>> obtenerDatosCatastroInmuebles() async {
    try {
      debugPrint('📊 [Catastro Inmuebles] Obteniendo inspecciones técnicas...');

      // Obtener todas las inspecciones técnicas con evaluaciones
      final response = await _supabase
          .from('inspecciones_tecnicas')
          .select(
            'id, plaza_id, nombre_plaza, inspector, fecha_legible, estado_general, evaluaciones, observaciones, fecha_hora_registro',
          )
          .order('fecha_hora_registro', ascending: false);

      debugPrint(
        '✅ [Catastro Inmuebles] ${response.length} inspecciones encontradas',
      );

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

      int inspeccionesCompletas = 0;
      int inspeccionesIncompletas = 0;

      for (var inspeccion in response) {
        final evaluaciones =
            inspeccion['evaluaciones'] as Map<String, dynamic>?;
        final observaciones =
            inspeccion['observaciones'] as Map<String, dynamic>?;
        final plazaId = inspeccion['plaza_id']?.toString();
        final plazaInfo = plazasMap[plazaId];

        if (evaluaciones != null) {
          final itemsEvaluados = evaluaciones.keys.toList();
          final totalItems = itemsEvaluados.length;
          final esCompleta = totalItems == _itemsCompletos.length;

          if (esCompleta) {
            inspeccionesCompletas++;
          } else {
            inspeccionesIncompletas++;
          }

          // Contar estados por ítem
          int excelentes = 0, buenos = 0, regulares = 0, malos = 0;
          evaluaciones.forEach((item, estado) {
            final estadoLower = estado.toString().toLowerCase();

            // Estadísticas generales por ítem
            estadisticasItems[item] = (estadisticasItems[item] ?? 0) + 1;

            // Estados por ítem
            if (!estadosPorItem.containsKey(item)) {
              estadosPorItem[item] = {
                'Excelente': 0,
                'Bueno': 0,
                'Regular': 0,
                'Malo': 0,
              };
            }

            switch (estadoLower) {
              case 'excelente':
                excelentes++;
                estadosPorItem[item]!['Excelente'] =
                    estadosPorItem[item]!['Excelente']! + 1;
                break;
              case 'bueno':
                buenos++;
                estadosPorItem[item]!['Bueno'] =
                    estadosPorItem[item]!['Bueno']! + 1;
                break;
              case 'regular':
                regulares++;
                estadosPorItem[item]!['Regular'] =
                    estadosPorItem[item]!['Regular']! + 1;
                break;
              case 'malo':
              case 'crítico':
              case 'critico':
                malos++;
                estadosPorItem[item]!['Malo'] =
                    estadosPorItem[item]!['Malo']! + 1;
                break;
            }
          });

          // Crear lista de ítems faltantes
          final itemsFaltantes = _itemsCompletos
              .where((item) => !itemsEvaluados.contains(item))
              .toList();

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
            'total_items_evaluados': totalItems,
            'items_faltantes_count': itemsFaltantes.length,
            'items_faltantes': itemsFaltantes.join('; '),
            'es_inspeccion_completa': esCompleta ? 'SÍ' : 'NO',
            'excelentes': excelentes,
            'buenos': buenos,
            'regulares': regulares,
            'malos': malos,
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
        'inspecciones_completas': inspeccionesCompletas,
        'inspecciones_incompletas': inspeccionesIncompletas,
        'estadisticas_items': estadisticasItems,
        'estados_por_item': estadosPorItem,
        'item_mas_evaluado': estadisticasItems.isNotEmpty
            ? estadisticasItems.entries
                  .reduce((a, b) => a.value > b.value ? a : b)
                  .key
            : null,
      };
    } catch (e, stackTrace) {
      debugPrint('❌ [Catastro Inmuebles] Error: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'datos_excel': <Map<String, dynamic>>[],
        'total_inspecciones': 0,
        'error': e.toString(),
      };
    }
  }

  /// Genera CSV para Excel con información de catastro de inmuebles
  static String generarCSVCatastroInmuebles(List<Map<String, dynamic>> datos) {
    final buffer = StringBuffer();

    // BOM UTF-8 para acentos correctos en Excel
    buffer.write('\uFEFF');

    // Encabezados (usando ; para Excel en español)
    buffer.writeln(
      [
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
        'Ítems Faltantes (Cantidad)',
        'Inspección Completa (7/7)',
        'Estados: Excelente',
        'Estados: Bueno',
        'Estados: Regular',
        'Estados: Malo',
        'Ítems Evaluados',
        'Ítems Faltantes (Detalle)',
        'Evaluaciones Completas',
      ].join(';'),
    );

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
        dato['items_faltantes_count']?.toString() ?? '0',
        dato['es_inspeccion_completa']?.toString() ?? 'NO',
        dato['excelentes']?.toString() ?? '0',
        dato['buenos']?.toString() ?? '0',
        dato['regulares']?.toString() ?? '0',
        dato['malos']?.toString() ?? '0',
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

  /// Genera estadísticas adicionales en formato de texto
  static String generarResumenEstadisticas(Map<String, dynamic> datos) {
    final buffer = StringBuffer();

    buffer.writeln('=== RESUMEN CATASTRO DE INMUEBLES ===');
    buffer.writeln(
      'Fecha generación: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
    );
    buffer.writeln('');

    buffer.writeln('📊 ESTADÍSTICAS GENERALES:');
    buffer.writeln('• Total inspecciones: ${datos['total_inspecciones']}');
    buffer.writeln(
      '• Inspecciones completas (7/7): ${datos['inspecciones_completas']}',
    );
    buffer.writeln(
      '• Inspecciones incompletas: ${datos['inspecciones_incompletas']}',
    );

    if (datos['total_inspecciones'] > 0) {
      final porcentajeCompletas =
          (datos['inspecciones_completas'] *
                  100.0 /
                  datos['total_inspecciones'])
              .toStringAsFixed(1);
      buffer.writeln('• Porcentaje completitud: $porcentajeCompletas%');
    }

    buffer.writeln('');

    if (datos['item_mas_evaluado'] != null) {
      buffer.writeln('🏆 ÍTEM MÁS EVALUADO:');
      buffer.writeln('• ${datos['item_mas_evaluado']}');
      buffer.writeln('');
    }

    buffer.writeln('📋 ÍTEMS EVALUABLES (7 total):');
    for (int i = 0; i < _itemsCompletos.length; i++) {
      buffer.writeln('${i + 1}. ${_itemsCompletos[i]}');
    }

    return buffer.toString();
  }
}
