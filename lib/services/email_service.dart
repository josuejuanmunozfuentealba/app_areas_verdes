import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Servicio para envío de correos electrónicos con adjuntos
///
/// Usa los endpoints serverless de Vercel para enviar correos formales
class EmailService {
  // URL del servidor backend en Vercel
  static const String serverUrl = 'https://app-areas-verdes.vercel.app';

  /// Envía un correo formal con adjuntos a Felipe Lagos Bastias
  ///
  /// Parámetros requeridos:
  /// - nombreInspector: Nombre del inspector que firma el correo
  /// - nombrePlaza: Nombre de la plaza inspeccionada
  /// - estadoGeneral: Estado general ('Bueno', 'Regular', 'Malo')
  /// - fecha: Fecha legible del informe (DD/MM/YYYY)
  /// - tipoInforme: 'inspeccion' o 'catastro'
  /// - adjuntos: Lista de archivos [{filename, content (base64), contentType}]
  static Future<bool> enviarInformeFormal({
    required String nombreInspector,
    required String nombrePlaza,
    required String estadoGeneral,
    required String fecha,
    required String tipoInforme, // 'inspeccion' o 'catastro'
    required List<Map<String, dynamic>> adjuntos,
  }) async {
    try {
      // Preparar datos para el endpoint de Vercel
      final data = {
        'nombreInspector': nombreInspector,
        'nombrePlaza': nombrePlaza,
        'estadoGeneral': estadoGeneral,
        'fecha': fecha,
        'tipoInforme': tipoInforme,
        'attachments': adjuntos,
      };

      // Enviar petición al endpoint de Vercel
      final response = await http
          .post(
            Uri.parse('$serverUrl/api/send-email'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException(
                'Tiempo de espera agotado. El servidor no responde después de 60 segundos.',
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
        'Verifica tu conexión a internet.\n\n'
        'Error técnico: ${e.message}',
      );
    } on TimeoutException catch (e) {
      throw EmailSendException(
        'El servidor está tardando demasiado en responder.\n\n'
        'Posibles causas:\n'
        '• Archivos adjuntos muy grandes\n'
        '• Problemas de red\n\n'
        'Error: ${e.message}',
      );
    } on ServerNotAvailableException {
      rethrow;
    } on EmailSendException {
      rethrow;
    } catch (e) {
      throw EmailSendException('Error inesperado al enviar el correo: $e');
    }
  }

  /// Envía un correo con múltiples adjuntos (PDF y Word) a través del servidor backend
  /// DEPRECADO: Usar enviarInformeFormal() en su lugar
  static Future<bool> enviarCorreoConAdjuntos({
    required String destinatario,
    required String asunto,
    required String cuerpo,
    required List<Map<String, dynamic>> adjuntos, // [{nombre, base64, tipo}]
  }) async {
    try {
      // Preparar datos para el servidor
      final data = {
        'to': destinatario,
        'subject': asunto,
        'body': cuerpo,
        'attachments': adjuntos,
      };

      // Enviar petición al servidor
      final response = await http
          .post(
            Uri.parse('$serverUrl/api/send-email'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException(
                'Tiempo de espera agotado. El servidor no responde después de 60 segundos.',
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
        'Verifica tu conexión a internet.\n\n'
        'Error técnico: ${e.message}',
      );
    } on TimeoutException catch (e) {
      throw EmailSendException(
        'El servidor está tardando demasiado en responder.\n\n'
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
  /// DEPRECADO: Usar enviarInformeFormal() en su lugar
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
        'to': destinatario,
        'subject': asunto,
        'body': cuerpo,
        'attachments': [
          {
            'filename': nombreArchivo,
            'content': pdfBase64,
            'contentType': 'application/pdf',
          },
        ],
      };

      // Enviar petición al servidor
      final response = await http
          .post(
            Uri.parse('$serverUrl/api/send-email'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(
            const Duration(seconds: 60),
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
          .get(Uri.parse('$serverUrl/api/send-email'))
          .timeout(const Duration(seconds: 5));

      // El endpoint send-email responde 405 para GET, lo cual indica que está activo
      if (response.statusCode == 405 || response.statusCode == 200) {
        return true;
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
