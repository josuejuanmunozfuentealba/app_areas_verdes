import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../services/pdf_export_service.dart';
import '../services/word_export_service.dart';
import '../services/email_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// COORDINADOR MAESTRO para la exportación y envío de reportes
///
/// Arquitectura limpia: Coordinador → Servicios (Obreros)
class LogicaBotonesHelper {
  // ============================================================================
  // MÉTODOS PÚBLICOS - API DEL COORDINADOR
  // ============================================================================

  /// Genera PDF únicamente
  static Future<void> generarPDF({
    required BuildContext context,
    required Map<String, dynamic> datos,
  }) async {
    try {
      _mostrarProgreso(context, 'Generando PDF...');

      // Generar el PDF
      final pdfBytes = await PDFExportService().generarReporte(datos: datos);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Descargar el archivo en el navegador
      final fecha = DateTime.now();
      final fechaStr =
          '${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year}';
      final nombrePlaza = datos['nombrePlaza']
          .toString()
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');
      final nombreArchivo = 'Inspeccion_${nombrePlaza}_$fechaStr.pdf';

      // Crear blob y descargar
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', nombreArchivo)
        ..click();
      html.Url.revokeObjectUrl(url);

      if (context.mounted) {
        _mostrarExito(context, '✓ PDF descargado: $nombreArchivo');
      }
    } catch (e) {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        _mostrarError(context, 'Error al generar PDF: $e');
      }
    }
  }

  /// Genera Word únicamente
  static Future<void> generarWord({
    required BuildContext context,
    required Map<String, dynamic> datos,
  }) async {
    try {
      _mostrarProgreso(context, 'Generando Word...');

      // Generar el Word
      final wordBytes = await WordExportService().generarReporte(datos: datos);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Descargar el archivo en el navegador
      final fecha = DateTime.now();
      final fechaStr =
          '${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year}';
      final nombrePlaza = datos['nombrePlaza']
          .toString()
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');
      final nombreArchivo = 'Reporte_${nombrePlaza}_$fechaStr.doc';

      // Crear blob y descargar
      final blob = html.Blob([wordBytes], 'application/msword');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', nombreArchivo)
        ..click();
      html.Url.revokeObjectUrl(url);

      if (context.mounted) {
        _mostrarExito(context, '✓ Word descargado: $nombreArchivo');
      }
    } catch (e) {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        _mostrarError(context, 'Error al generar Word: $e');
      }
    }
  }

  /// Envía notificación por correo SIN ADJUNTOS (solo texto)
  /// Abre el cliente de correo web (Gmail/Outlook) con el formulario prellenado
  /// El usuario puede adjuntar manualmente los archivos PDF/Word descargados
  static Future<void> enviarReporte({
    required BuildContext context,
    required Map<String, dynamic> datos,
  }) async {
    try {
      // Validar email
      final email = datos['correoSupervisor']?.toString() ?? '';
      if (email.isEmpty || !email.contains('@')) {
        if (context.mounted) {
          _mostrarError(
            context,
            '⚠ Por favor ingrese un correo electrónico válido',
          );
        }
        return;
      }

      // Mostrar diálogo de selección de cliente de correo
      if (!context.mounted) return;

      final clienteSeleccionado = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.email, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text('Seleccionar Cliente de Correo'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Se abrirá tu cliente de correo web con el formulario prellenado.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Podrás adjuntar manualmente los archivos PDF/Word que descargues con los otros botones.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              const Text(
                'Selecciona tu cliente de correo:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop('gmail'),
              icon: const Icon(Icons.mail_outline),
              label: const Text('Gmail'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFD93025),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop('outlook'),
              icon: const Icon(Icons.mail),
              label: const Text('Outlook'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0078D4),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );

      if (clienteSeleccionado == null || !context.mounted) return;

      _mostrarProgreso(context, 'Preparando correo...');

      // Preparar datos del correo
      final fecha = DateTime.now();
      final fechaStr =
          '${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year}';

      final nombrePlaza = datos['nombrePlaza']?.toString() ?? 'Sin nombre';
      final plazaId = datos['plazaId']?.toString() ?? 'Sin ID';
      final estadoGeneral = _calcularEstadoGeneral(datos);

      // Generar resumen de problemas
      final resumenProblemas = _generarResumenProblemas(datos);

      // Generar enlace según el cliente seleccionado
      String enlace;
      if (clienteSeleccionado == 'gmail') {
        enlace = EmailService.generarEnlaceGmailWeb(
          destinatario: email,
          nombrePlaza: nombrePlaza,
          plazaId: plazaId,
          fecha: fechaStr,
          estadoGeneral: estadoGeneral,
          resumenProblemas: resumenProblemas,
        );
      } else {
        enlace = EmailService.generarEnlaceOutlookWeb(
          destinatario: email,
          nombrePlaza: nombrePlaza,
          plazaId: plazaId,
          fecha: fechaStr,
          estadoGeneral: estadoGeneral,
          resumenProblemas: resumenProblemas,
        );
      }

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Abrir el enlace en el navegador
      final uri = Uri.parse(enlace);
      final puedeAbrir = await canLaunchUrl(uri);

      if (puedeAbrir) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (context.mounted) {
          _mostrarExitoConInstrucciones(context, clienteSeleccionado, email);
        }
      } else {
        if (context.mounted) {
          _mostrarError(
            context,
            '❌ No se pudo abrir el cliente de correo.\n'
            'Por favor, envía el correo manualmente a: $email',
          );
        }
      }
    } catch (e) {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        _mostrarError(context, 'Error al preparar el correo: $e');
      }
    }
  }

  // ============================================================================
  // MÉTODOS PRIVADOS - HELPERS INTERNOS
  // ============================================================================

  static String _generarCuerpoCorreo(Map<String, dynamic> datos, String fecha) {
    final nombreInspector = datos['nombreInspector']?.toString() ?? '';
    final inspector = nombreInspector.isNotEmpty
        ? nombreInspector
        : datos['correoSupervisor'];

    return '''FICHA DE INSPECCIÓN

Plaza: ${datos['nombrePlaza']}
ID: ${datos['plazaId']}
Fecha: $fecha
Estado: ${datos['estadoGeneral']}

Encargado: Felipe Lagos Bastias - Ingeniero Agrónomo
Inspector: $inspector

Documentos adjuntos: PDF y Word

Saludos cordiales,
$inspector
Sistema de Inspección de Áreas Verdes''';
  }

  static void _mostrarProgreso(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(mensaje),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _mostrarExito(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void _mostrarError(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void _mostrarErrorAmigable(
    BuildContext context,
    String titulo,
    String mensaje,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFFF57C00)),
            const SizedBox(width: 8),
            Expanded(child: Text(titulo)),
          ],
        ),
        content: Text(
          mensaje,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// Calcula el estado general basándose en las evaluaciones
  static String _calcularEstadoGeneral(Map<String, dynamic> datos) {
    int totalMalos = 0;
    int totalRegulares = 0;
    int totalBuenos = 0;

    // Contar evaluaciones de todas las secciones
    final allEvaluations = datos['allEvaluations'] as Map<String, dynamic>?;
    if (allEvaluations != null) {
      for (var seccion in allEvaluations.values) {
        if (seccion is Map<String, dynamic>) {
          for (var evaluacion in seccion.values) {
            final valor = evaluacion?.toString() ?? '';
            if (valor == 'Malo') {
              totalMalos++;
            } else if (valor == 'Regular')
              totalRegulares++;
            else if (valor == 'Bueno')
              totalBuenos++;
          }
        }
      }
    }

    // Determinar estado general
    if (totalMalos > 0) return 'Malo';
    if (totalRegulares > 0) return 'Regular';
    if (totalBuenos > 0) return 'Bueno';
    return 'Por evaluar';
  }

  /// Genera un resumen de los problemas encontrados
  static String _generarResumenProblemas(Map<String, dynamic> datos) {
    final buffer = StringBuffer();
    buffer.writeln('RESUMEN DE PROBLEMAS ENCONTRADOS:\n');

    final allEvaluations = datos['allEvaluations'] as Map<String, dynamic>?;
    final allCriteria = datos['allCriteria'] as Map<String, dynamic>?;
    final allObservations = datos['allObservations'] as Map<String, dynamic>?;

    if (allEvaluations != null && allCriteria != null) {
      for (var seccionEntry in allEvaluations.entries) {
        final seccion = seccionEntry.key;
        final evaluaciones = seccionEntry.value as Map<String, dynamic>?;
        final criterios = allCriteria[seccion] as List<dynamic>?;
        final observaciones =
            allObservations?[seccion] as Map<String, dynamic>?;

        if (evaluaciones != null && criterios != null) {
          bool hayProblemas = false;
          final problemasSeccion = StringBuffer();

          for (var criterio in criterios) {
            final valor = evaluaciones[criterio]?.toString() ?? '';
            if (valor == 'Regular' || valor == 'Malo') {
              if (!hayProblemas) {
                problemasSeccion.writeln('$seccion:');
                hayProblemas = true;
              }
              problemasSeccion.write('  • $criterio: $valor');

              // Agregar observación si existe
              final obs = observaciones?[criterio]?.toString() ?? '';
              if (obs.isNotEmpty) {
                problemasSeccion.write(' ($obs)');
              }
              problemasSeccion.writeln();
            }
          }

          if (hayProblemas) {
            buffer.write(problemasSeccion.toString());
            buffer.writeln();
          }
        }
      }
    }

    if (buffer.length == 0 ||
        buffer.toString().trim() == 'RESUMEN DE PROBLEMAS ENCONTRADOS:') {
      return 'No se encontraron problemas significativos en esta inspección.';
    }

    return buffer.toString();
  }

  /// Muestra mensaje de éxito con instrucciones para adjuntar archivos
  static void _mostrarExitoConInstrucciones(
    BuildContext context,
    String cliente,
    String email,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            const Expanded(child: Text('Correo Preparado')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Se ha abierto ${cliente == 'gmail' ? 'Gmail' : 'Outlook'} con el correo prellenado para $email',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Siguientes pasos:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Descarga los archivos usando los botones "PDF" y "Word"',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              '2. En la ventana del correo, haz clic en el botón de adjuntar archivos 📎',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              '3. Selecciona los archivos PDF y Word descargados',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 4),
            const Text(
              '4. Revisa el mensaje y haz clic en "Enviar"',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}
