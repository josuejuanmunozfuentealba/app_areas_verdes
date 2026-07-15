import 'dart:convert';
import 'dart:io';
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
      // Primero verificar que el servidor esté disponible
      final servidorDisponible = await verificarServidor();
      if (!servidorDisponible) {
        throw ServerNotAvailableException(
          'El servidor de correos no está disponible.\n\n'
          'Para iniciar el servidor:\n'
          '1. Abre una terminal\n'
          '2. Ve a la carpeta: cd email_server\n'
          '3. Ejecuta: node server.js\n\n'
          'El servidor debe estar corriendo en $serverUrl',
        );
      }

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
              throw TimeoutException(
                'Tiempo de espera agotado. El servidor no responde después de 45 segundos.',
              );
            },
          );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['success'] == true;
      } else {
        final error = jsonDecode(response.body);
        throw EmailSendException(
          error['error'] ?? 'Error desconocido del servidor',
        );
      }
    } on SocketException catch (e) {
      throw ServerNotAvailableException(
        'No se puede conectar al servidor de correos.\n\n'
        'Verifica que el servidor esté iniciado:\n'
        '• cd email_server\n'
        '• node server.js\n\n'
        'Error técnico: ${e.message}',
      );
    } on TimeoutException catch (e) {
      throw EmailSendException(
        'El servidor está tardando demasiado en responder.\n\n'
        'Posibles causas:\n'
        '• El servidor está sobrecargado\n'
        '• Problemas de red\n'
        '• Archivos adjuntos muy grandes\n\n'
        'Error: ${e.message}',
      );
    } on ServerNotAvailableException {
      rethrow; // Re-lanzar excepciones personalizadas
    } on EmailSendException {
      rethrow;
    } catch (e) {
      throw EmailSendException('Error inesperado al enviar el correo: $e');
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
      // Primero verificar que el servidor esté disponible
      final servidorDisponible = await verificarServidor();
      if (!servidorDisponible) {
        throw ServerNotAvailableException(
          'El servidor de correos no está disponible.\n\n'
          'Para iniciar el servidor:\n'
          '1. Abre una terminal\n'
          '2. Ve a la carpeta: cd email_server\n'
          '3. Ejecuta: node server.js',
        );
      }

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
              throw TimeoutException(
                'Tiempo de espera agotado. El servidor no responde.',
              );
            },
          );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['success'] == true;
      } else {
        final error = jsonDecode(response.body);
        throw EmailSendException(
          error['error'] ?? 'Error desconocido del servidor',
        );
      }
    } on SocketException catch (e) {
      throw ServerNotAvailableException(
        'No se puede conectar al servidor de correos (${e.message})',
      );
    } on TimeoutException catch (e) {
      throw EmailSendException('El servidor no responde: ${e.message}');
    } on ServerNotAvailableException {
      rethrow;
    } on EmailSendException {
      rethrow;
    } catch (e) {
      throw EmailSendException('Error inesperado: $e');
    }
  }

  /// Verifica si el servidor backend está disponible y respondiendo
  ///
  /// Retorna true si el servidor está activo y responde correctamente
  /// Retorna false si el servidor no está disponible
  static Future<bool> verificarServidor() async {
    try {
      final response = await http
          .get(Uri.parse('$serverUrl/api/health'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['status'] == 'ok';
      }
      return false;
    } on SocketException {
      // Servidor no disponible (conexión rechazada)
      return false;
    } on TimeoutException {
      // Servidor no responde a tiempo
      return false;
    } catch (e) {
      // Cualquier otro error
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
Estimado Felipe Lagos Bastias

Se ha completado la inspección técnica:

Plaza: $nombrePlaza
ID: $plazaId
Fecha: $fecha
Estado General: $estadoGeneral

A continuación, adjunto el PDF y el archivo Word editable que incluye las capturas fotográficas y los comentarios detallados de esta inspección.

Saludos atentamente,
Josue Muñoz Fuentealba
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
Estimado Felipe Lagos Bastias

Se ha completado la inspección técnica:

Plaza: $nombrePlaza
ID: $plazaId
Fecha: $fecha
Estado General: $estadoGeneral

A continuación, adjunto el PDF y el archivo Word editable que incluye las capturas fotográficas y los comentarios detallados de esta inspección.

Saludos atentamente,
Josue Muñoz Fuentealba
''');

    return 'https://outlook.office.com/mail/deeplink/compose?to=$destinatario&subject=$asunto&body=$cuerpo';
  }
}

// ============================================================================
// EXCEPCIONES PERSONALIZADAS
// ============================================================================

/// Excepción lanzada cuando el servidor de correos no está disponible
class ServerNotAvailableException implements Exception {
  final String message;
  ServerNotAvailableException(this.message);

  @override
  String toString() => message;
}

/// Excepción lanzada cuando hay un error al enviar el correo
class EmailSendException implements Exception {
  final String message;
  EmailSendException(this.message);

  @override
  String toString() => message;
}

/// Excepción lanzada cuando se excede el tiempo de espera
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
