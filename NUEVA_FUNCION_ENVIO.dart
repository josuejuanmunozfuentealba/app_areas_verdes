// NUEVA FUNCIÓN _enviarCorreoAutomatico
// Reemplaza la función actual en lib/screens/inspeccion_tecnica_screen.dart
// Esta versión envía PDF Y Word adjuntos con un mensaje breve

/// Envía el correo automáticamente con PDF y Word adjuntos usando el servidor backend
Future<void> _enviarCorreoAutomatico(
  String destinatario,
  String nombrePlaza,
  String plazaId,
  String fecha,
  String estadoGeneral,
  String resumenProblemas,
) async {
  if (!mounted) return;

  // Mostrar indicador de carga
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Generando PDF y Word...'),
                SizedBox(height: 8),
                Text(
                  'Enviando correo con adjuntos',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  try {
    // 1. Verificar que el servidor esté disponible
    final servidorDisponible = await EmailService.verificarServidor();

    if (!servidorDisponible) {
      if (mounted) Navigator.of(context).pop();
      throw Exception(
        'El servidor de correos no está disponible.\n\n'
        'Asegúrate de que el servidor backend esté corriendo en http://localhost:3000\n\n'
        'Usa las alternativas de Gmail/Outlook web en su lugar.',
      );
    }

    // 2. Generar el PDF
    final datos = _compilarDatosInspeccion();
    final pdfService = PDFExportService();
    final pdfDoc = await pdfService.generateInspectionPDF(
      plazaId: datos.plazaId,
      nombrePlaza: datos.nombrePlaza,
      correoSupervisor: datos.correoSupervisor,
      fechaHora: datos.fechaHoraFormatted,
      allEvaluations: {
        'ASEO': _evaluacionesAseo,
        'CÉSPED': _evaluacionesCesped,
        'ARBOLADO': _evaluacionesArbolado,
        'FLORES': _evaluacionesFlores,
        'CAMINOS': _evaluacionesCaminos,
        'INFRAESTRUCTURA': _evaluacionesInfraestructura,
      },
      allCriteria: {
        'ASEO': _criteriosAseo,
        'CÉSPED': _criteriosCesped,
        'ARBOLADO': _criteriosArbolado,
        'FLORES': _criteriosFlores,
        'CAMINOS': _criteriosCaminos,
        'INFRAESTRUCTURA': _criteriosInfraestructura,
      },
      estadoGeneral: datos.estadoGeneral,
      imagesBySection: datos.images,
    );

    final pdfBytes = await pdfDoc.save();

    // 3. Generar el documento Word (HTML)
    final now = DateTime.now();
    final fechaFormateada =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    final htmlContent =
        '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Reporte de Inspección Técnica</title>
</head>
<body>
  <h1>REPORTE DE INSPECCIÓN TÉCNICA</h1>
  <p><strong>Encargado:</strong> Felipe Lagos Bastias - Ingeniero Agrónomo</p>
  <p><strong>Plaza:</strong> $nombrePlaza</p>
  <p><strong>ID:</strong> $plazaId</p>
  <p><strong>Fecha:</strong> $fechaFormateada</p>
  <p><strong>Estado General:</strong> $estadoGeneral</p>
  ${_generarSeccionHTML('ASEO', _evaluacionesAseo, _criteriosAseo)}
  ${_generarSeccionHTML('CÉSPED', _evaluacionesCesped, _criteriosCesped)}
  ${_generarSeccionHTML('ARBOLADO', _evaluacionesArbolado, _criteriosArbolado)}
  ${_generarSeccionHTML('FLORES', _evaluacionesFlores, _criteriosFlores)}
  ${_generarSeccionHTML('CAMINOS', _evaluacionesCaminos, _criteriosCaminos)}
  ${_generarSeccionHTML('INFRAESTRUCTURA', _evaluacionesInfraestructura, _criteriosInfraestructura)}
</body>
</html>
''';

    final wordBytes = utf8.encode(htmlContent);

    // 4. Preparar nombres de archivos
    final nombrePlazaLimpio = nombrePlaza
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_')
        .substring(0, nombrePlaza.length > 30 ? 30 : nombrePlaza.length);
    final pdfFilename =
        'Inspeccion_${nombrePlazaLimpio}_ID${plazaId}_$fecha.pdf';
    final wordFilename = 'Reporte_${nombrePlazaLimpio}_ID${plazaId}_$fecha.doc';

    // 5. Preparar mensaje breve del correo
    final cuerpoCorreo =
        '''
═══════════════════════════════════════
   FICHA DE INSPECCIÓN TÉCNICA
═══════════════════════════════════════

📍 PLAZA: $nombrePlaza
🆔 ID: $plazaId
📅 FECHA: $fecha
🕐 HORA: ${now.hour}:${now.minute.toString().padLeft(2, '0')}

📊 ESTADO GENERAL: $estadoGeneral

👤 ENCARGADO:
   Felipe Lagos Bastias
   Ingeniero Agrónomo

$resumenProblemas

═══════════════════════════════════════
📎 DOCUMENTOS ADJUNTOS:
   • Informe de Inspección (PDF)
   • Reporte Detallado (Word)
═══════════════════════════════════════

Sistema de Inspección de Áreas Verdes
Municipalidad de Doñihue
''';

    final asuntoCorreo =
        '📋 Ficha Inspección - $nombrePlaza (ID$plazaId) - $estadoGeneral';

    // 6. Preparar adjuntos
    final adjuntos = [
      {
        'nombre': pdfFilename,
        'base64': base64Encode(pdfBytes),
        'tipo': 'application/pdf',
      },
      {
        'nombre': wordFilename,
        'base64': base64Encode(wordBytes),
        'tipo': 'application/msword',
      },
    ];

    // 7. Enviar correo con ambos adjuntos
    final enviado = await EmailService.enviarCorreoConAdjuntos(
      destinatario: destinatario,
      asunto: asuntoCorreo,
      cuerpo: cuerpoCorreo,
      adjuntos: adjuntos,
    );

    // Cerrar indicador de carga
    if (mounted) Navigator.of(context).pop();

    if (enviado) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('✓ Correo enviado con PDF y Word adjuntos'),
                ),
              ],
            ),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  } catch (e) {
    // Cerrar indicador de carga si está abierto
    if (mounted) Navigator.of(context).pop();

    // Mostrar error
    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Error al Enviar'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'No se pudo enviar el correo automáticamente:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(e.toString(), style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 16),
                const Text(
                  'Sugerencia:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Usa las opciones de Gmail o Outlook web y adjunta los archivos manualmente.',
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
          );
        },
      );
    }
  }
}
