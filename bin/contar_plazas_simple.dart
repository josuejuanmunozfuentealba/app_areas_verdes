import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 VERIFICANDO TOTAL DE ÁREAS VERDES');
  print('===================================');
  print('');

  try {
    final client = HttpClient();
    
    // Configurar request a Supabase
    final request = await client.getUrl(Uri.parse(
      'https://speneggmlqitgfjhzsry.supabase.co/rest/v1/plazas?select=id,nombre,comuna'
    ));
    
    request.headers.set('apikey', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg');
    request.headers.set('Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg');

    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final List plazas = jsonDecode(responseBody);
      
      print('📊 RESULTADOS:');
      print('✅ Total plazas registradas: ${plazas.length}');
      print('🎯 Objetivo: 70 plazas');
      
      final diferencia = 70 - plazas.length;
      if (diferencia > 0) {
        print('❌ FALTAN: $diferencia áreas verdes por registrar');
      } else if (diferencia < 0) {
        print('✅ EXCESO: ${-diferencia} áreas verdes adicionales');
      } else {
        print('✅ COMPLETO: Exactamente 70 áreas verdes registradas');
      }
      
      print('');
      
      // Contar por comuna
      final Map<String, int> porComuna = {};
      for (var plaza in plazas) {
        final comuna = plaza['comuna'] ?? 'Sin comuna';
        porComuna[comuna] = (porComuna[comuna] ?? 0) + 1;
      }
      
      print('📍 DISTRIBUCIÓN POR COMUNA:');
      for (var entry in porComuna.entries) {
        print('   ${entry.key}: ${entry.value} plazas');
      }
      
      if (plazas.length < 70) {
        print('');
        print('💡 SUGERENCIA:');
        print('   Necesitas agregar ${70 - plazas.length} plazas más para completar las 70.');
        print('   Puedes usar el archivo INSERTAR_77_PLAZAS.sql como referencia.');
      }
      
    } else {
      print('❌ Error al consultar Supabase: ${response.statusCode}');
    }
    
    client.close();
    
  } catch (e) {
    print('❌ ERROR: $e');
  }
}