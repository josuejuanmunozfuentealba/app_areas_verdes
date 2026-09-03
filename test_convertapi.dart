// Test rápido de conversión PDF→Word
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Test ConvertAPI PDF→Word');
  
  // PDF vacío de prueba (mínimo)
  final pdfBytes = Uint8List.fromList([
    0x25, 0x50, 0x44, 0x46, 0x2d, 0x31, 0x2e, 0x34, 0x0a, // %PDF-1.4
  ]);
  
  print('📄 PDF size: ${pdfBytes.length} bytes');
  
  final pdfBase64 = base64Encode(pdfBytes);
  
  const supabaseUrl = 'https://speneggmlqitgfjhzsry.supabase.co';
  const anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg';
  
  final functionUrl = '$supabaseUrl/functions/v1/convert-pdf-to-word-ilovepdf';
  
  print('🌐 Llamando a: $functionUrl');
  
  try {
    final response = await http.post(
      Uri.parse(functionUrl),
      headers: {
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pdfBase64': pdfBase64,
        'filename': 'test.pdf',
      }),
    ).timeout(Duration(seconds: 30));
    
    print('📡 Status: ${response.statusCode}');
    print('📦 Response: ${response.body}');
    
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        print('✅ CONVERSIÓN EXITOSA');
        print('🔗 URL: ${result['docxUrl']}');
      } else {
        print('❌ ERROR: ${result['error']}');
        print('💬 Mensaje: ${result['message']}');
      }
    } else {
      print('❌ HTTP ERROR ${response.statusCode}');
      print('📄 Body: ${response.body}');
    }
  } catch (e) {
    print('❌ EXCEPCIÓN: $e');
  }
}
