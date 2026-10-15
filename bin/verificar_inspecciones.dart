import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 VERIFICANDO INSPECCIONES TÉCNICAS EN SUPABASE');
  print('==============================================');
  print('');

  try {
    final client = HttpClient();
    
    // Consultar inspecciones técnicas
    print('1. Consultando tabla inspecciones_tecnicas...');
    final requestInspecciones = await client.getUrl(Uri.parse(
      'https://speneggmlqitgfjhzsry.supabase.co/rest/v1/inspecciones_tecnicas?select=id,plaza_id,nombre_plaza,inspector,estado_general,evaluaciones'
    ));
    
    requestInspecciones.headers.set('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg');
    requestInspecciones.headers.set('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg');

    final responseInspecciones = await requestInspecciones.close();
    
    if (responseInspecciones.statusCode == 200) {
      final responseBodyInspecciones = await responseInspecciones.transform(utf8.decoder).join();
      final List inspecciones = jsonDecode(responseBodyInspecciones);
      
      print('✅ Respuesta exitosa de inspecciones_tecnicas');
      print('📊 Total inspecciones encontradas: ${inspecciones.length}');
      print('');
      
      if (inspecciones.isEmpty) {
        print('❌ NO HAY INSPECCIONES TÉCNICAS REGISTRADAS');
        print('');
        print('💡 POSIBLES SOLUCIONES:');
        print('1. Crear algunas inspecciones técnicas desde la app');
        print('2. Verificar que la tabla inspecciones_tecnicas existe');
        print('3. Revisar permisos de la tabla en Supabase');
      } else {
        print('📋 DETALLES DE LAS INSPECCIONES:');
        print('');
        
        int conEvaluaciones = 0;
        int sinEvaluaciones = 0;
        
        for (int i = 0; i < inspecciones.length && i < 5; i++) {
          final insp = inspecciones[i];
          final id = insp['id'] ?? 'N/A';
          final plazaId = insp['plaza_id'] ?? 'N/A';
          final nombre = insp['nombre_plaza'] ?? 'Sin nombre';
          final inspector = insp['inspector'] ?? 'Sin inspector';
          final estado = insp['estado_general'] ?? 'Sin estado';
          final evaluaciones = insp['evaluaciones'];
          
          final tieneEvaluaciones = evaluaciones != null && evaluaciones is Map && evaluaciones.isNotEmpty;
          
          if (tieneEvaluaciones) {
            conEvaluaciones++;
          } else {
            sinEvaluaciones++;
          }
          
          print('${i + 1}. ID: $id');
          print('   Plaza: $plazaId - $nombre');
          print('   Inspector: $inspector');
          print('   Estado: $estado');
          print('   Evaluaciones: ${tieneEvaluaciones ? 'SÍ (${evaluaciones.length} ítems)' : 'NO'}');
          print('');
        }
        
        if (inspecciones.length > 5) {
          print('... y ${inspecciones.length - 5} inspecciones más');
          print('');
        }
        
        print('📈 RESUMEN:');
        print('• Inspecciones con evaluaciones: $conEvaluaciones');
        print('• Inspecciones sin evaluaciones: $sinEvaluaciones');
        print('• Total inspecciones: ${inspecciones.length}');
        
        if (conEvaluaciones == 0) {
          print('');
          print('⚠️  PROBLEMA IDENTIFICADO:');
          print('   Hay inspecciones registradas pero SIN evaluaciones.');
          print('   El Excel necesita inspecciones CON evaluaciones.');
          print('');
          print('💡 SOLUCIÓN:');
          print('   Completar algunas inspecciones técnicas desde la app');
          print('   para que tengan evaluaciones (ítems calificados).');
        }
      }
      
    } else {
      print('❌ Error al consultar inspecciones_tecnicas: ${responseInspecciones.statusCode}');
    }
    
    // Consultar catastros_inmuebles para comparar
    print('');
    print('2. Consultando tabla catastros_inmuebles para comparar...');
    final requestCatastros = await client.getUrl(Uri.parse(
      'https://speneggmlqitgfjhzsry.supabase.co/rest/v1/catastros_inmuebles?select=plaza_id,estado_general&limit=5'
    ));
    
    requestCatastros.headers.set('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg');
    requestCatastros.headers.set('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg');

    final responseCatastros = await requestCatastros.close();
    
    if (responseCatastros.statusCode == 200) {
      final responseBodyCatastros = await responseCatastros.transform(utf8.decoder).join();
      final List catastros = jsonDecode(responseBodyCatastros);
      
      print('✅ Catastros encontrados: ${catastros.length}');
      print('');
      
      if (catastros.isNotEmpty) {
        print('📋 COMPARACIÓN DE TABLAS:');
        print('• catastros_inmuebles: ${catastros.length} registros (modo normal)');
        print('• inspecciones_tecnicas: ? registros (modo técnico)');
        print('');
        print('💡 NOTA:');
        print('   El Excel de inspecciones técnicas usa la tabla inspecciones_tecnicas,');
        print('   NO catastros_inmuebles. Son dos modos diferentes de evaluación.');
      }
    }
    
    client.close();
    
  } catch (e) {
    print('❌ ERROR: $e');
  }
}