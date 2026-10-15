import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  print('🔍 VERIFICANDO TOTAL DE ÁREAS VERDES CATASTRADAS');
  print('================================================');
  print('');

  try {
    // Inicializar Supabase
    await Supabase.initialize(
      url: 'https://speneggmlqitgfjhzsry.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg',
    );

    final supabase = Supabase.instance.client;

    // 1. Contar plazas registradas
    print('📊 TABLA: plazas');
    final responsePlazas = await supabase.from('plazas').select('id, nombre, comuna');
    final totalPlazas = responsePlazas.length;
    
    print('✅ Total plazas registradas: $totalPlazas');
    print('');

    // Mostrar por comuna
    final Map<String, int> plazasPorComuna = {};
    for (var plaza in responsePlazas) {
      final comuna = plaza['comuna'] ?? 'Sin comuna';
      plazasPorComuna[comuna] = (plazasPorComuna[comuna] ?? 0) + 1;
    }
    
    print('📍 DISTRIBUCIÓN POR COMUNA:');
    for (var entry in plazasPorComuna.entries) {
      print('   ${entry.key}: ${entry.value} plazas');
    }
    print('');

    // 2. Contar inspecciones técnicas (catastros)
    print('📊 TABLA: inspecciones_tecnicas (catastros técnicos)');
    final responseInspecciones = await supabase
        .from('inspecciones_tecnicas')
        .select('plaza_id')
        .order('fecha_hora_registro', ascending: false);
    
    final plazasConInspeccion = <String>{};
    for (var insp in responseInspecciones) {
      plazasConInspeccion.add(insp['plaza_id'].toString());
    }
    
    print('✅ Total inspecciones técnicas: ${responseInspecciones.length}');
    print('✅ Plazas con inspección técnica: ${plazasConInspeccion.length}');
    print('');

    // 3. Contar catastros de inmuebles (modo normal)
    print('📊 TABLA: catastros_inmuebles (evaluaciones normales)');
    final responseCatastros = await supabase
        .from('catastros_inmuebles')
        .select('plaza_id')
        .order('created_at', ascending: false);
    
    final plazasConCatastro = <String>{};
    for (var cat in responseCatastros) {
      plazasConCatastro.add(cat['plaza_id'].toString());
    }
    
    print('✅ Total catastros inmuebles: ${responseCatastros.length}');
    print('✅ Plazas con catastro: ${plazasConCatastro.length}');
    print('');

    // 4. Análisis de cobertura
    print('🎯 ANÁLISIS DE COBERTURA:');
    print('');
    
    final plazasSinInspeccion = <String>[];
    final plazasSinCatastro = <String>[];
    
    for (var plaza in responsePlazas) {
      final plazaId = plaza['id'].toString();
      final nombre = plaza['nombre'] ?? 'Sin nombre';
      
      if (!plazasConInspeccion.contains(plazaId)) {
        plazasSinInspeccion.add('$plazaId - $nombre');
      }
      
      if (!plazasConCatastro.contains(plazaId)) {
        plazasSinCatastro.add('$plazaId - $nombre');
      }
    }
    
    print('❌ Plazas SIN inspección técnica: ${plazasSinInspeccion.length}');
    if (plazasSinInspeccion.isNotEmpty && plazasSinInspeccion.length <= 10) {
      for (var plaza in plazasSinInspeccion) {
        print('   - $plaza');
      }
    }
    print('');
    
    print('❌ Plazas SIN catastro de inmuebles: ${plazasSinCatastro.length}');
    if (plazasSinCatastro.isNotEmpty && plazasSinCatastro.length <= 10) {
      for (var plaza in plazasSinCatastro) {
        print('   - $plaza');
      }
    }
    print('');

    // 5. Resumen final
    print('📋 RESUMEN FINAL:');
    print('================');
    print('🎯 OBJETIVO: 70 áreas verdes');
    print('📊 ACTUAL: $totalPlazas áreas verdes registradas');
    
    final diferencia = 70 - totalPlazas;
    if (diferencia > 0) {
      print('❌ FALTAN: $diferencia áreas verdes por registrar');
    } else if (diferencia < 0) {
      print('✅ EXCESO: ${-diferencia} áreas verdes adicionales registradas');
    } else {
      print('✅ COMPLETO: Exactamente 70 áreas verdes registradas');
    }
    
    print('');
    print('📈 ESTADO DE CATASTROS:');
    print('   • Inspecciones técnicas: ${plazasConInspeccion.length}/$totalPlazas plazas');
    print('   • Catastros inmuebles: ${plazasConCatastro.length}/$totalPlazas plazas');
    
    final porcentajeInspecciones = totalPlazas > 0 
        ? (plazasConInspeccion.length * 100.0 / totalPlazas).toStringAsFixed(1)
        : '0.0';
    final porcentajeCatastros = totalPlazas > 0 
        ? (plazasConCatastro.length * 100.0 / totalPlazas).toStringAsFixed(1)
        : '0.0';
        
    print('   • Cobertura inspecciones: $porcentajeInspecciones%');
    print('   • Cobertura catastros: $porcentajeCatastros%');

  } catch (e) {
    print('❌ ERROR: $e');
  }
}