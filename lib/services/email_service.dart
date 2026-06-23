import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para envío de correos electrónicos con adjuntos
///
/// Usa un servidor backend Node.js para enviar correos con PDFs adjuntos
class EmailService {
  // URL del servidor backend (cambiar según tu configuración)
  static const String serverUrl = 'http://localhost:3000';

  /// Envía un correo con múltiples adjuntos (PDF y Word) a través del servidor backend
  static Future<bool> enviarCorreoConAdjuntos({
    required String destinatario,
    required String asunto,
    required String cuerpo,
    required List<Map<String, dynamic>> adjuntos, // [{nombre, base64, tipo}]
  }) async {
    try {
      // Preparar datos para el servidor
      final data = {
        'destinatario': destinatario,
        'asunto': asunto,
        'cuerpo': cuerpo,
        'adjuntos': adjuntos,
      };

      // Enviar petición al servidor
      final response = await http
          .post(
            Uri.parse('$serverUrl/api/send-email-multiple-attachments'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () {
              throw Exception(
                'Tiempo de espera agotado. El servidor no responde.',
              );
            },
          );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['success'] == true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error desconocido del servidor');
      }
    } catch (e) {
      print('Error al enviar correo: $e');
      rethrow;
    }
  }

  /// Envía un correo con el PDF adjunto a través del servidor backend
  static Future<bool> enviarCorreoConPDF({
    required String destinatario,
    required String asunto,
    required String cuerpo,
    required List<int> pdfBytes,
    required String nombreArchivo,
  }) async {
    try {
      // Convertir PDF a base64
      final pdfBase64 = base64Encode(pdfBytes);

      // Preparar datos para el servidor
      final data = {
        'destinatario': destinatario,
        'asunto': asunto,
        'cuerpo': cuerpo,
        'pdfBase64': pdfBase64,
        'nombreArchivo': nombreArchivo,
      };

      // Enviar petición al servidor
      final response = await http
          .post(
            Uri.parse('$serverUrl/api/send-email-base64'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Tiempo de espera agotado. El servidor no responde.',
              );
            },
          );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['success'] == true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Error desconocido del servidor');
      }
    } catch (e) {
      print('Error al enviar correo: $e');
      rethrow;
    }
  }

  /// Verifica si el servidor backend está disponible
  static Future<bool> verificarServidor() async {
    try {
      final response = await http
          .get(Uri.parse('$serverUrl/api/health'))
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Alternativa: Abrir enlace directo de Gmail Web con información precargada
  static String generarEnlaceGmailWeb({
    required String destinatario,
    required String nombrePlaza,
    required String plazaId,
    required String fecha,
    required String estadoGeneral,
    required String resumenProblemas,
  }) {
    final asunto = Uri.encodeComponent(
      'Inspección Técnica: $nombrePlaza - ID$plazaId - $fecha',
    );

    final cuerpo = Uri.encodeComponent('''
Estimado Inspector,

Se ha completado la inspección técnica:

Plaza: $nombrePlaza
ID: $plazaId
Fecha: $fecha
Estado General: $estadoGeneral

Encargado: Felipe Lagos Bastias - Ingeniero Agrónomo

$resumenProblemas

Saludos cordiales,
Felipe Lagos Bastias
Ingeniero Agrónomo
''');

    return 'https://mail.google.com/mail/?view=cm&to=$destinatario&su=$asunto&body=$cuerpo';
  }

  /// Alternativa: Abrir enlace directo de Outlook Web
  static String generarEnlaceOutlookWeb({
    required String destinatario,
    required String nombrePlaza,
    required String plazaId,
    required String fecha,
    required String estadoGeneral,
    required String resumenProblemas,
  }) {
    final asunto = Uri.encodeComponent(
      'Inspección Técnica: $nombrePlaza - ID$plazaId - $fecha',
    );

    final cuerpo = Uri.encodeComponent('''
Estimado Inspector,

Se ha completado la inspección técnica:

Plaza: $nombrePlaza
ID: $plazaId  
Fecha: $fecha
Estado General: $estadoGeneral

Encargado: Felipe Lagos Bastias - Ingeniero Agrónomo

$resumenProblemas

Saludos cordiales,
Felipe Lagos Bastias
Ingeniero Agrónomo
''');

    return 'https://outlook.office.com/mail/deeplink/compose?to=$destinatario&subject=$asunto&body=$cuerpo';
  }
}
