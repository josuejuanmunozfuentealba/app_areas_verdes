import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

/// Servicio para generar reportes consolidados de arranques de agua
/// Servicio para generar reportes consolidados completos
/// Incluye: Estados de áreas verdes, Arranques, Bancas, Juegos, Basureros
class ReporteConsolidadoService {
  // Campos del catastro
  static const campoArranques =
      'Estado llaves de paso/arranque de agua (Especificar si es de 1/2 o 3/4)';
  static const campoBancasEstructural = 'Estado estructural de bancas';
  static const campoBancasPintura = 'Estado pintura bancas';
  static const campoJuegosEstructural = 'Estado estructural juegos infantiles';
  static const campoJuegosPintura = 'Estado de pintura de juegos infantiles';
  static const campoBasurerosEstructural = 'Estado estructural basureros';
  static const campoBasurerosPintura = 'Estado pintura de basureros';

  /// Extraer la medida (1/2 o 3/4) del texto de arranques
  static String? extraerMedida(String? texto) {
    if (texto == null || texto.isEmpty) return null;

    final textoLower = texto.toLowerCase();

    // Buscar "1/2" o "1/2 pulgada" o "media pulgada"
    if (textoLower.contains('1/2') ||
        textoLower.contains('media pulgada') ||
        textoLower.contains('12.7') ||
        textoLower.contains('12,7')) {
      return '1/2"';
    }

    // Buscar "3/4" o "3/4 pulgada"
    if (textoLower.contains('3/4') ||
        textoLower.contains('19.05') ||
        textoLower.contains('19,05')) {
      return '3/4"';
    }

    // Buscar "1 pulgada" (sin fracción)
    if (textoLower.contains('1 pulgada') ||
        textoLower.contains('1"') ||
        textoLower.contains('25.4') ||
        textoLower.contains('25,4')) {
      return '1"';
    }

    return null;
  }

  /// Obtener reporte consolidado COMPLETO
  static Future<Map<String, dynamic>> obtenerReporteCompleto() async {
    try {
      print('📊 [REPORTE] Obteniendo catastros desde Supabase...');

      // Obtener todos los catastros con estado_general
      final response = await Supabase.instance.client
          .from('catastros_inmuebles')
          .select(
            'plaza_id, nombre_plaza, estado_general, evaluaciones, observaciones',
          )
          .order('created_at', ascending: false);

      print('✅ [REPORTE] ${response.length} catastros encontrados');

      // Obtener información de las plazas (coordenadas, dirección)
      final plazasResponse = await Supabase.instance.client
          .from('plazas')
          .select('id, nombre, comuna, coordenadas');

      final plazasMap = <String, Map<String, dynamic>>{};
      for (var plaza in plazasResponse) {
        plazasMap[plaza['id'].toString()] = plaza;
      }

      // ==========================================
      // SECCIÓN 1: ESTADOS DE ÁREAS VERDES
      // ==========================================
      final estadosSet = <String, String>{}; // plaza_id -> último estado
      final List<Map<String, dynamic>> detalleEstados = [];

      for (var catastro in response) {
        final plazaId = catastro['plaza_id']?.toString();
        final nombrePlaza = catastro['nombre_plaza'] ?? 'Sin nombre';
        final estadoGeneral = catastro['estado_general'] ?? 'Sin evaluar';

        if (plazaId != null && !estadosSet.containsKey(plazaId)) {
          estadosSet[plazaId] = estadoGeneral;
          detalleEstados.add({
            'plaza_id': plazaId,
            'nombre': nombrePlaza,
            'estado': estadoGeneral,
          });
        }
      }

      final totalPlazas = detalleEstados.length;
      final plazasMalo = detalleEstados
          .where((p) => p['estado'] == 'Malo')
          .length;
      final plazasRegular = detalleEstados
          .where((p) => p['estado'] == 'Regular')
          .length;
      final plazasBueno = detalleEstados
          .where((p) => p['estado'] == 'Bueno')
          .length;
      final plazasSinEvaluar = detalleEstados
          .where((p) => p['estado'] == 'Sin evaluar')
          .length;

      // ==========================================
      // SECCIÓN 2: ARRANQUES DE AGUA
      // ==========================================
      int totalArranques = 0;
      int arranques12 = 0;
      int arranques34 = 0;
      int arranques1 = 0;
      int sinEspecificar = 0;
      List<Map<String, dynamic>> detalleArranques = [];
      final arranquesSet = <String>{}; // Para evitar duplicados

      for (var catastro in response) {
        final plazaId = catastro['plaza_id']?.toString();
        final nombrePlaza = catastro['nombre_plaza'] ?? 'Sin nombre';
        final evaluaciones = catastro['evaluaciones'] as Map<String, dynamic>?;
        final observaciones =
            catastro['observaciones'] as Map<String, dynamic>?;

        if (evaluaciones == null || plazaId == null) continue;
        if (arranquesSet.contains(plazaId)) continue; // Ya procesada

        final valorArranque = evaluaciones[campoArranques] as String?;
        final observacionArranque = observaciones?[campoArranques] as String?;

        // Buscar la medida en evaluaciones O en observaciones
        String? textoCompleto;
        if (observacionArranque != null && observacionArranque.isNotEmpty) {
          textoCompleto = observacionArranque; // Priorizar observaciones
        } else if (valorArranque != null && valorArranque.isNotEmpty) {
          textoCompleto = valorArranque;
        }

        if (textoCompleto != null && textoCompleto.isNotEmpty) {
          arranquesSet.add(plazaId);

          final medida = extraerMedida(textoCompleto);

          if (medida == '1/2"') {
            arranques12++;
            totalArranques++;
          } else if (medida == '3/4"') {
            arranques34++;
            totalArranques++;
          } else if (medida == '1"') {
            arranques1++;
            totalArranques++;
          } else {
            sinEspecificar++;
          }

          detalleArranques.add({
            'plaza_id': plazaId,
            'nombre': nombrePlaza,
            'medida': medida ?? 'Sin especificar',
            'texto_original': textoCompleto,
          });
        }
      }

      // ==========================================
      // SECCIÓN 3: BANCAS
      // ==========================================
      final bancasSet = <String>{}; // Para evitar duplicados
      List<Map<String, dynamic>> detalleBancas = [];
      int bancasMalo = 0;
      int bancasRegular = 0;
      int bancasBueno = 0;

      for (var catastro in response) {
        final plazaId = catastro['plaza_id']?.toString();
        final nombrePlaza = catastro['nombre_plaza'] ?? 'Sin nombre';
        final evaluaciones = catastro['evaluaciones'] as Map<String, dynamic>?;

        if (evaluaciones == null || plazaId == null) continue;
        if (bancasSet.contains(plazaId)) continue; // Ya procesada

        final estructural = evaluaciones[campoBancasEstructural] as String?;
        final pintura = evaluaciones[campoBancasPintura] as String?;

        if (estructural != null || pintura != null) {
          bancasSet.add(plazaId);

          // Calcular peor estado
          final peorEstado = _calcularPeorEstado([estructural, pintura]);

          if (peorEstado == 'Malo') {
            bancasMalo++;
          } else if (peorEstado == 'Regular')
            bancasRegular++;
          else if (peorEstado == 'Bueno')
            bancasBueno++;

          detalleBancas.add({
            'plaza_id': plazaId,
            'nombre': nombrePlaza,
            'estado_estructural': estructural ?? 'N/A',
            'estado_pintura': pintura ?? 'N/A',
            'estado_general': peorEstado,
          });
        }
      }

      // ==========================================
      // SECCIÓN 4: JUEGOS INFANTILES
      // ==========================================
      final juegosSet = <String>{};
      List<Map<String, dynamic>> detalleJuegos = [];
      int juegosMalo = 0;
      int juegosRegular = 0;
      int juegosBueno = 0;

      for (var catastro in response) {
        final plazaId = catastro['plaza_id']?.toString();
        final nombrePlaza = catastro['nombre_plaza'] ?? 'Sin nombre';
        final evaluaciones = catastro['evaluaciones'] as Map<String, dynamic>?;

        if (evaluaciones == null || plazaId == null) continue;
        if (juegosSet.contains(plazaId)) continue;

        final estructural = evaluaciones[campoJuegosEstructural] as String?;
        final pintura = evaluaciones[campoJuegosPintura] as String?;

        if (estructural != null || pintura != null) {
          juegosSet.add(plazaId);

          final peorEstado = _calcularPeorEstado([estructural, pintura]);

          if (peorEstado == 'Malo') {
            juegosMalo++;
          } else if (peorEstado == 'Regular')
            juegosRegular++;
          else if (peorEstado == 'Bueno')
            juegosBueno++;

          detalleJuegos.add({
            'plaza_id': plazaId,
            'nombre': nombrePlaza,
            'estado_estructural': estructural ?? 'N/A',
            'estado_pintura': pintura ?? 'N/A',
            'estado_general': peorEstado,
          });
        }
      }

      // ==========================================
      // SECCIÓN 5: BASUREROS
      // ==========================================
      final basurerosSet = <String>{};
      List<Map<String, dynamic>> detalleBasureros = [];
      int basurerosMalo = 0;
      int basurerosRegular = 0;
      int basurerosBueno = 0;

      for (var catastro in response) {
        final plazaId = catastro['plaza_id']?.toString();
        final nombrePlaza = catastro['nombre_plaza'] ?? 'Sin nombre';
        final evaluaciones = catastro['evaluaciones'] as Map<String, dynamic>?;

        if (evaluaciones == null || plazaId == null) continue;
        if (basurerosSet.contains(plazaId)) continue;

        final estructural = evaluaciones[campoBasurerosEstructural] as String?;
        final pintura = evaluaciones[campoBasurerosPintura] as String?;

        if (estructural != null || pintura != null) {
          basurerosSet.add(plazaId);

          final peorEstado = _calcularPeorEstado([estructural, pintura]);

          if (peorEstado == 'Malo') {
            basurerosMalo++;
          } else if (peorEstado == 'Regular')
            basurerosRegular++;
          else if (peorEstado == 'Bueno')
            basurerosBueno++;

          detalleBasureros.add({
            'plaza_id': plazaId,
            'nombre': nombrePlaza,
            'estado_estructural': estructural ?? 'N/A',
            'estado_pintura': pintura ?? 'N/A',
            'estado_general': peorEstado,
          });
        }
      }

      print('✅ [REPORTE] Procesamiento completado');
      print(
        '   Estados: Malo=$plazasMalo, Regular=$plazasRegular, Bueno=$plazasBueno',
      );
      print(
        '   Arranques: Total=$totalArranques (1/2"=$arranques12, 3/4"=$arranques34)',
      );
      print('   Bancas: Total=${detalleBancas.length}');
      print('   Juegos: Total=${detalleJuegos.length}');
      print('   Basureros: Total=${detalleBasureros.length}');

      // ==========================================
      // SECCIÓN 6: FUGAS DE AGUA
      // ==========================================
      final fugasSet = <String>{};
      List<Map<String, dynamic>> detalleFugas = [];

      for (var catastro in response) {
        final plazaId = catastro['plaza_id']?.toString();
        final nombrePlaza = catastro['nombre_plaza'] ?? 'Sin nombre';
        final observaciones =
            catastro['observaciones'] as Map<String, dynamic>?;

        if (observaciones == null || plazaId == null) continue;
        if (fugasSet.contains(plazaId)) continue;

        final observacionArranque = observaciones[campoArranques] as String?;

        // Buscar palabras clave de fugas
        if (observacionArranque != null &&
            observacionArranque.isNotEmpty &&
            (_contieneFuga(observacionArranque))) {
          fugasSet.add(plazaId);

          final plazaInfo = plazasMap[plazaId];
          final direccion = 'Sin dirección'; // Campo no disponible en BD
          final comuna = plazaInfo?['comuna'] ?? 'Sin comuna';
          final coordenadas = plazaInfo?['coordenadas'];

          String gpsLat = 'N/A';
          String gpsLng = 'N/A';
          if (coordenadas is Map) {
            gpsLat = coordenadas['latitude']?.toString() ?? 'N/A';
            gpsLng = coordenadas['longitude']?.toString() ?? 'N/A';
          }

          detalleFugas.add({
            'plaza_id': plazaId,
            'nombre': nombrePlaza,
            'comuna': comuna,
            'gps_lat': gpsLat,
            'gps_lng': gpsLng,
            'observacion': observacionArranque,
          });
        }
      }

      print('📊 [REPORTE] Sección 6: Fugas de agua');
      print('   Fugas detectadas: ${detalleFugas.length}');

      return {
        // Sección 1: Estados
        'total_plazas': totalPlazas,
        'plazas_malo': plazasMalo,
        'plazas_regular': plazasRegular,
        'plazas_bueno': plazasBueno,
        'plazas_sin_evaluar': plazasSinEvaluar,
        'detalle_estados': detalleEstados,

        // Sección 2: Arranques
        'total_arranques': totalArranques,
        'arranques_12': arranques12,
        'arranques_34': arranques34,
        'arranques_1': arranques1,
        'sin_especificar': sinEspecificar,
        'detalle_arranques': detalleArranques,

        // Sección 3: Bancas
        'total_bancas': detalleBancas.length,
        'bancas_malo': bancasMalo,
        'bancas_regular': bancasRegular,
        'bancas_bueno': bancasBueno,
        'detalle_bancas': detalleBancas,

        // Sección 4: Juegos
        'total_juegos': detalleJuegos.length,
        'juegos_malo': juegosMalo,
        'juegos_regular': juegosRegular,
        'juegos_bueno': juegosBueno,
        'detalle_juegos': detalleJuegos,

        // Sección 5: Basureros
        'total_basureros': detalleBasureros.length,
        'basureros_malo': basurerosMalo,
        'basureros_regular': basurerosRegular,
        'basureros_bueno': basurerosBueno,
        'detalle_basureros': detalleBasureros,

        // Sección 6: Fugas de agua
        'total_fugas': detalleFugas.length,
        'detalle_fugas': detalleFugas,
      };
    } catch (e, stackTrace) {
      print('❌ [REPORTE] Error obteniendo datos: $e');
      print('❌ [REPORTE] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Calcular el peor estado entre varios (para estructural y pintura)
  static String _calcularPeorEstado(List<String?> estados) {
    if (estados.any((e) => e == 'Malo')) return 'Malo';
    if (estados.any((e) => e == 'Regular')) return 'Regular';
    if (estados.any((e) => e == 'Bueno')) return 'Bueno';
    return 'N/A';
  }

  /// Detectar si el texto contiene indicios de fuga
  static bool _contieneFuga(String texto) {
    final textoLower = texto.toLowerCase();
    return textoLower.contains('fuga') ||
        textoLower.contains('filtración') ||
        textoLower.contains('filtracion') ||
        textoLower.contains('goteo') ||
        textoLower.contains('pérdida') ||
        textoLower.contains('perdida') ||
        textoLower.contains('escape') ||
        textoLower.contains('roto') ||
        textoLower.contains('quebrado') ||
        textoLower.contains('dañado');
  }

  /// Generar CSV de fugas de agua para Excel
  static String generarCSVFugas(List<Map<String, dynamic>> fugas) {
    final buffer = StringBuffer();

    // Encabezados (sin dirección porque no está en la BD)
    buffer.writeln(
      'ID,Nombre Area Verde,Comuna,GPS Latitud,GPS Longitud,Observacion',
    );

    // Datos
    for (var fuga in fugas) {
      final id = fuga['plaza_id'] ?? '';
      final nombre = _escaparCSV(fuga['nombre'] ?? '');
      final comuna = _escaparCSV(fuga['comuna'] ?? '');
      final gpsLat = fuga['gps_lat'] ?? '';
      final gpsLng = fuga['gps_lng'] ?? '';
      final observacion = _escaparCSV(fuga['observacion'] ?? '');

      buffer.writeln('$id,$nombre,$comuna,$gpsLat,$gpsLng,$observacion');
    }

    return buffer.toString();
  }

  /// Escapar texto para CSV (envolver en comillas si tiene comas o saltos de línea)
  static String _escaparCSV(String texto) {
    if (texto.contains(',') || texto.contains('\n') || texto.contains('"')) {
      return '"${texto.replaceAll('"', '""')}"';
    }
    return texto;
  }

  /// Obtener reporte consolidado de arranques (mantener compatibilidad)
  static Future<Map<String, dynamic>> obtenerReporteArranques() async {
    final reporteCompleto = await obtenerReporteCompleto();

    // Extraer solo datos de arranques para compatibilidad
    return {
      'total_plazas': reporteCompleto['total_arranques'],
      'total_arranques': reporteCompleto['total_arranques'],
      'arranques_12': reporteCompleto['arranques_12'],
      'arranques_34': reporteCompleto['arranques_34'],
      'arranques_1': reporteCompleto['arranques_1'],
      'sin_especificar': reporteCompleto['sin_especificar'],
      'detalles': reporteCompleto['detalle_arranques'],
    };
  }

  /// Generar PDF del reporte COMPLETO con todas las secciones
  static Future<Uint8List> generarPDFReporte(
    Map<String, dynamic> reporte,
  ) async {
    final pdf = pw.Document();

    // Cargar logo
    final logoBytes = await rootBundle.load('assets/logo_2026.png');
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final fecha = DateFormat('dd/MM/yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.letter,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Header con logo
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(logo, width: 80, height: 80),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'REPORTE CONSOLIDADO COMPLETO',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'ÁREAS VERDES DOÑIHUE',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Fecha: $fecha',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 20),

          // ==========================================
          // SECCIÓN 1: ESTADOS DE ÁREAS VERDES
          // ==========================================
          pw.Text(
            '📊 SECCIÓN 1: ESTADO GENERAL DE ÁREAS VERDES',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey200,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Total de Áreas Verdes: ${reporte['total_plazas']}'),
                pw.SizedBox(height: 8),
                pw.Text(
                  '🔴 Estado Malo: ${reporte['plazas_malo']} (${_calcularPorcentaje(reporte['plazas_malo'], reporte['total_plazas'])}%)',
                ),
                pw.Text(
                  '🟠 Estado Regular: ${reporte['plazas_regular']} (${_calcularPorcentaje(reporte['plazas_regular'], reporte['total_plazas'])}%)',
                ),
                pw.Text(
                  '🔵 Estado Bueno: ${reporte['plazas_bueno']} (${_calcularPorcentaje(reporte['plazas_bueno'], reporte['total_plazas'])}%)',
                ),
                pw.Text(
                  '⚪ Sin evaluar: ${reporte['plazas_sin_evaluar']} (${_calcularPorcentaje(reporte['plazas_sin_evaluar'], reporte['total_plazas'])}%)',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // ==========================================
          // SECCIÓN 2: BANCAS
          // ==========================================
          pw.Text(
            '🪑 SECCIÓN 2: INFRAESTRUCTURA - BANCAS',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Total de Áreas con Bancas: ${reporte['total_bancas']}',
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Malo: ${reporte['bancas_malo']} (${_calcularPorcentaje(reporte['bancas_malo'], reporte['total_bancas'])}%)',
                ),
                pw.Text(
                  'Regular: ${reporte['bancas_regular']} (${_calcularPorcentaje(reporte['bancas_regular'], reporte['total_bancas'])}%)',
                ),
                pw.Text(
                  'Bueno: ${reporte['bancas_bueno']} (${_calcularPorcentaje(reporte['bancas_bueno'], reporte['total_bancas'])}%)',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Área Verde', 'Estructural', 'Pintura', 'Estado General'],
            data: (reporte['detalle_bancas'] as List<Map<String, dynamic>>)
                .map(
                  (d) => [
                    d['nombre'],
                    d['estado_estructural'],
                    d['estado_pintura'],
                    d['estado_general'],
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue100),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellPadding: const pw.EdgeInsets.all(4),
          ),
          pw.SizedBox(height: 20),

          // ==========================================
          // SECCIÓN 3: JUEGOS INFANTILES
          // ==========================================
          pw.Text(
            '🎠 SECCIÓN 3: INFRAESTRUCTURA - JUEGOS INFANTILES',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Total de Áreas con Juegos: ${reporte['total_juegos']}',
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Malo: ${reporte['juegos_malo']} (${_calcularPorcentaje(reporte['juegos_malo'], reporte['total_juegos'])}%)',
                ),
                pw.Text(
                  'Regular: ${reporte['juegos_regular']} (${_calcularPorcentaje(reporte['juegos_regular'], reporte['total_juegos'])}%)',
                ),
                pw.Text(
                  'Bueno: ${reporte['juegos_bueno']} (${_calcularPorcentaje(reporte['juegos_bueno'], reporte['total_juegos'])}%)',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Área Verde', 'Estructural', 'Pintura', 'Estado General'],
            data: (reporte['detalle_juegos'] as List<Map<String, dynamic>>)
                .map(
                  (d) => [
                    d['nombre'],
                    d['estado_estructural'],
                    d['estado_pintura'],
                    d['estado_general'],
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.green100),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellPadding: const pw.EdgeInsets.all(4),
          ),
          pw.SizedBox(height: 20),

          // ==========================================
          // SECCIÓN 4: BASUREROS
          // ==========================================
          pw.Text(
            '🗑️ SECCIÓN 4: INFRAESTRUCTURA - BASUREROS',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Total de Áreas con Basureros: ${reporte['total_basureros']}',
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Malo: ${reporte['basureros_malo']} (${_calcularPorcentaje(reporte['basureros_malo'], reporte['total_basureros'])}%)',
                ),
                pw.Text(
                  'Regular: ${reporte['basureros_regular']} (${_calcularPorcentaje(reporte['basureros_regular'], reporte['total_basureros'])}%)',
                ),
                pw.Text(
                  'Bueno: ${reporte['basureros_bueno']} (${_calcularPorcentaje(reporte['basureros_bueno'], reporte['total_basureros'])}%)',
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Área Verde', 'Estructural', 'Pintura', 'Estado General'],
            data: (reporte['detalle_basureros'] as List<Map<String, dynamic>>)
                .map(
                  (d) => [
                    d['nombre'],
                    d['estado_estructural'],
                    d['estado_pintura'],
                    d['estado_general'],
                  ],
                )
                .toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 9,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColors.orange100,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellPadding: const pw.EdgeInsets.all(4),
          ),
          pw.SizedBox(height: 20),

          // ==========================================
          // SECCIÓN 5: ARRANQUES DE AGUA
          // ==========================================
          pw.Text(
            '💧 SECCIÓN 5: ARRANQUES DE AGUA',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.cyan50,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Total de Arranques: ${reporte['total_arranques']}'),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ['Medida', 'Cantidad', 'Porcentaje'],
            data: [
              [
                '1/2 pulgada (12.7mm)',
                '${reporte['arranques_12']}',
                '${_calcularPorcentaje(reporte['arranques_12'], reporte['total_arranques'])}%',
              ],
              [
                '3/4 pulgada (19.05mm)',
                '${reporte['arranques_34']}',
                '${_calcularPorcentaje(reporte['arranques_34'], reporte['total_arranques'])}%',
              ],
              [
                '1 pulgada (25.4mm)',
                '${reporte['arranques_1']}',
                '${_calcularPorcentaje(reporte['arranques_1'], reporte['total_arranques'])}%',
              ],
            ],
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.cyan100),
            cellPadding: const pw.EdgeInsets.all(8),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generar archivo Word (DOCX) del reporte COMPLETO
  /// Convierte el PDF a Word usando iLovePDF
  static Future<Uint8List?> generarWordReporte(
    Map<String, dynamic> reporte,
  ) async {
    try {
      debugPrint('[Word Conversión] Iniciando conversión PDF→DOCX...');

      // Paso 1: Generar el PDF primero
      debugPrint('[Word Conversión] Paso 1/3: Generando PDF...');
      final pdfBytes = await generarPDFReporte(reporte);

      if (pdfBytes.isEmpty) {
        debugPrint('[Word Conversión] ❌ Error: PDF vacío');
        return null;
      }

      debugPrint('[Word Conversión] ✅ PDF generado: ${pdfBytes.length} bytes');

      // Paso 2: Convertir PDF a Word usando iLovePDF
      debugPrint('[Word Conversión] Paso 2/3: Convirtiendo PDF a DOCX...');
      final docxBytes = await _convertirPdfAWordILovePDF(pdfBytes);

      if (docxBytes == null) {
        debugPrint('[Word Conversión] ❌ Error: No se pudo convertir a DOCX');
        return null;
      }

      debugPrint(
        '[Word Conversión] ✅ DOCX generado: ${docxBytes.length} bytes',
      );
      return docxBytes;
    } catch (e, stackTrace) {
      debugPrint('[Word Conversión] ❌ Excepción: $e');
      debugPrint('[Word Conversión] StackTrace: $stackTrace');
      return null;
    }
  }

  /// Convertir PDF a Word usando iLovePDF Edge Function
  /// Retorna los bytes del DOCX o null si falla
  static Future<Uint8List?> _convertirPdfAWordILovePDF(
    Uint8List pdfBytes,
  ) async {
    try {
      // Codificar PDF a Base64
      final pdfBase64 = base64Encode(pdfBytes);
      final fecha = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'reporte_consolidado_$fecha';

      // Configuración Supabase
      const supabaseUrl = 'https://speneggmlqitgfjhzsry.supabase.co';
      const anonKey =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg';

      final functionUrl =
          '$supabaseUrl/functions/v1/convert-pdf-to-word-ilovepdf';

      debugPrint('[Word iLovePDF] Llamando a Edge Function: $functionUrl');

      // Llamar a Edge Function
      final response = await http
          .post(
            Uri.parse(functionUrl),
            headers: {
              'Authorization': 'Bearer $anonKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'pdfBase64': pdfBase64, 'filename': filename}),
          )
          .timeout(
            const Duration(seconds: 180),
            onTimeout: () {
              debugPrint('[Word iLovePDF] ⏱️ Timeout después de 180s');
              throw Exception('Timeout: La conversión tardó más de 3 minutos');
            },
          );

      if (response.statusCode != 200) {
        debugPrint('[Word iLovePDF] ❌ Error HTTP ${response.statusCode}');
        debugPrint('[Word iLovePDF] Response: ${response.body}');
        return null;
      }

      // Parsear respuesta
      final result = jsonDecode(response.body) as Map<String, dynamic>;

      if (result['success'] != true || result['docxUrl'] == null) {
        debugPrint('[Word iLovePDF] ❌ Conversión fallida');
        debugPrint('[Word iLovePDF] Error: ${result['error']}');
        debugPrint('[Word iLovePDF] Message: ${result['message']}');
        return null;
      }

      final docxUrl = result['docxUrl'] as String;
      debugPrint('[Word iLovePDF] ✅ DOCX URL: $docxUrl');

      // Paso 3: Descargar bytes del DOCX
      debugPrint('[Word iLovePDF] Descargando DOCX...');
      final docxResponse = await http
          .get(Uri.parse(docxUrl))
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              debugPrint('[Word iLovePDF] ⏱️ Timeout descargando DOCX');
              throw Exception('Timeout descargando el archivo DOCX');
            },
          );

      if (docxResponse.statusCode != 200) {
        debugPrint(
          '[Word iLovePDF] ❌ Error descargando DOCX: ${docxResponse.statusCode}',
        );
        return null;
      }

      final docxBytes = docxResponse.bodyBytes;
      debugPrint(
        '[Word iLovePDF] ✅ DOCX descargado: ${docxBytes.length} bytes',
      );

      return docxBytes;
    } catch (e, stackTrace) {
      debugPrint('[Word iLovePDF] ❌ Excepción: $e');
      debugPrint('[Word iLovePDF] StackTrace: $stackTrace');
      return null;
    }
  }

  static String _calcularPorcentaje(int parte, int total) {
    if (total == 0) return '0.0';
    return ((parte / total) * 100).toStringAsFixed(1);
  }
}
