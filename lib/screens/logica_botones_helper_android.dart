import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../services/pdf_export_service.dart';
import '../services/word_export_service.dart';
import '../services/email_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// COORDINADOR para Android - Usa sistema de archivos nativo
class LogicaBotonesHelper {
  // ============================================================================
  // MÉTODOS PÚBLICOS - API DEL COORDINADOR
  // ============================================================================

  /// Genera PDF y lo guarda en el almacenamiento
  static Future<void> generarPDF({
    required BuildContext context,
    required Map<String, dynamic> datos,
  }) async {
    try {
      _mostrarProgreso(context, 'Generando PDF...');

      // Generar el PDF
      final pdfBytes = await PDFExportService().generarReporte(datos: datos);

      // Obtener directorio de descargas
      final directory = await getApplicationDocumentsDirectory();

      // Crear nombre de archivo
      final fecha = DateTime.now();
      final fechaStr =
          '${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year}';
      final nombrePlaza = datos['nombrePlaza']
          .toString()
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');
      final nombreArchivo = 'Inspeccion_${nombrePlaza}_$fechaStr.pdf';

      // Guardar archivo
      final file = File('${directory.path}/$nombreArchivo');
      await file.writeAsBytes(pdfBytes);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Mostrar opciones
      if (context.mounted) {
        _mostrarOpcionesArchivo(context, file.path, nombreArchivo, 'PDF');
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

  /// Genera Word y lo guarda en el almacenamiento
  static Future<void> generarWord({
    required BuildContext context,
    required Map<String, dynamic> datos,
  }) async {
    try {
      _mostrarProgreso(context, 'Generando Word...');

      // Generar el Word
      final wordBytes = await WordExportService().generarReporte(datos: datos);

      // Obtener directorio de descargas
      final directory = await getApplicationDocumentsDirectory();

      // Crear nombre de archivo
      final fecha = DateTime.now();
      final fechaStr =
          '${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year}';
      final nombrePlaza = datos['nombrePlaza']
          .toString()
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(' ', '_');
      final nombreArchivo = 'Reporte_${nombrePlaza}_$fechaStr.doc';

      // Guardar archivo
      final file = File('${directory.path}/$nombreArchivo');
      await file.writeAsBytes(wordBytes);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Mostrar opciones
      if (context.mounted) {
        _mostrarOpcionesArchivo(context, file.path, nombreArchivo, 'Word');
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

  /// Abre el cliente de correo con el formulario prellenado
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

      // Mostrar diálogo de selección
      if (!context.mounted) return;

      final clienteSeleccionado = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.email, color: Color(0xFF1565C0)),
              SizedBox(width: 8),
              Text('Enviar Reporte'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Se abrirá tu cliente de correo con el formulario prellenado.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Nota: Los archivos PDF y Word se descargan por separado con los botones correspondientes.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
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

      // Preparar datos
      final fecha = DateTime.now();
      final fechaStr =
          '${fecha.day.toString().padLeft(2, '0')}-${fecha.month.toString().padLeft(2, '0')}-${fecha.year}';

      final nombrePlaza = datos['nombrePlaza']?.toString() ?? 'Sin nombre';
      final plazaId = datos['plazaId']?.toString() ?? 'Sin ID';
      final estadoGeneral = _calcularEstadoGeneral(datos);
      final resumenProblemas = _generarResumenProblemas(datos);

      // Generar enlace
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

      // Abrir enlace
      final uri = Uri.parse(enlace);
      final puedeAbrir = await canLaunchUrl(uri);

      if (puedeAbrir) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        if (context.mounted) {
          _mostrarExito(
            context,
            '✓ Cliente de correo abierto.\n'
            'Recuerda descargar y adjuntar los archivos PDF y Word.',
          );
        }
      } else {
        if (context.mounted) {
          _mostrarError(
            context,
            '❌ No se pudo abrir el cliente de correo.\n'
            'Por favor, envía manualmente a: $email',
          );
        }
      }
    } catch (e) {
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        _mostrarError(context, 'Error al preparar correo: $e');
      }
    }
  }

  // ============================================================================
  // MÉTODOS PRIVADOS - HELPERS INTERNOS
  // ============================================================================

  static void _mostrarOpcionesArchivo(
    BuildContext context,
    String filePath,
    String fileName,
    String tipo,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Text('$tipo Generado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Archivo guardado:\n$fileName'),
            const SizedBox(height: 16),
            const Text('¿Qué deseas hacer?'),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await OpenFile.open(filePath);
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Abrir'),
          ),
          TextButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await Share.shareXFiles([
                XFile(filePath),
              ], subject: 'Reporte de Inspección');
            },
            icon: const Icon(Icons.share),
            label: const Text('Compartir'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  static String _calcularEstadoGeneral(Map<String, dynamic> datos) {
    int totalMalos = 0;
    int totalRegulares = 0;
    int totalBuenos = 0;

    final allEvaluations = datos['allEvaluations'] as Map<String, dynamic>?;
    if (allEvaluations != null) {
      for (var seccion in allEvaluations.values) {
        if (seccion is Map<String, dynamic>) {
          for (var evaluacion in seccion.values) {
            final valor = evaluacion?.toString() ?? '';
            if (valor == 'Malo') {
              totalMalos++;
            } else if (valor == 'Regular') {
              totalRegulares++;
            } else if (valor == 'Bueno') {
              totalBuenos++;
            }
          }
        }
      }
    }

    if (totalMalos > 0) return 'Malo';
    if (totalRegulares > 0) return 'Regular';
    if (totalBuenos > 0) return 'Bueno';
    return 'Por evaluar';
  }

  static String _generarResumenProblemas(Map<String, dynamic> datos) {
    final buffer = StringBuffer();
    buffer.writeln('RESUMEN DE PROBLEMAS:\n');

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
        buffer.toString().trim() == 'RESUMEN DE PROBLEMAS:') {
      return 'No se encontraron problemas significativos.';
    }

    return buffer.toString();
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
}
