import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image_picker/image_picker.dart';

/// Service for generating PDF inspection reports
///
/// This service handles the creation of professional PDF documents
/// containing inspection evaluation data for all 6 sections:
/// ASEO, CÉSPED, ARBOLADO, FLORES, CAMINOS, INFRAESTRUCTURA
/// Includes photo annex with images from each section
class PDFExportService {
  /// Generates a complete PDF inspection report
  ///
  /// Parameters:
  /// - [plazaId]: Unique identifier for the plaza
  /// - [nombrePlaza]: Name of the plaza being inspected
  /// - [correoSupervisor]: Email of the supervisor
  /// - [fechaHora]: Date and time of the inspection
  /// - [allEvaluations]: Map of section names to evaluation maps
  /// - [allCriteria]: Map of section names to criteria lists
  /// - [estadoGeneral]: Overall state (Bueno/Regular/Malo)
  /// - [imagesBySection]: Map of section names to lists of XFile images
  ///
  /// Returns a [pw.Document] ready to be saved or previewed
  Future<pw.Document> generateInspectionPDF({
    required String plazaId,
    required String nombrePlaza,
    required String correoSupervisor,
    required String fechaHora,
    required Map<String, Map<String, String?>> allEvaluations,
    required Map<String, List<String>> allCriteria,
    required String estadoGeneral,
    required Map<String, List<XFile>> imagesBySection,
  }) async {
    final pdf = pw.Document();

    // Main report page
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(nombrePlaza),
          pw.SizedBox(height: 20),
          _buildInfoTable(plazaId, nombrePlaza, correoSupervisor, fechaHora),
          pw.SizedBox(height: 20),
          // Add all 6 evaluation sections
          ...allEvaluations.entries.map((entry) {
            final sectionTitle = entry.key;
            final evaluations = entry.value;
            final criteria = allCriteria[sectionTitle] ?? [];
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildEvaluationSection(sectionTitle, evaluations, criteria),
                pw.SizedBox(height: 15),
              ],
            );
          }),
          _buildSummary(estadoGeneral),
        ],
      ),
    );

    // Add photo annex if there are any images
    final hasImages = imagesBySection.values.any((list) => list.isNotEmpty);
    if (hasImages) {
      await _addPhotoAnnex(pdf, imagesBySection);
    }

    return pdf;
  }

  /// Builds the header section with title and divider
  pw.Widget _buildHeader(String nombrePlaza) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'REPORTE DE INSPECCIÓN TÉCNICA',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        pw.Divider(thickness: 2),
      ],
    );
  }

  /// Builds the information table with plaza details
  pw.Widget _buildInfoTable(
    String plazaId,
    String nombrePlaza,
    String correoSupervisor,
    String fechaHora,
  ) {
    return pw.Column(
      children: [
        // Encargado fijo
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            border: pw.Border.all(color: PdfColors.blue),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'ENCARGADO',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text('Nombre: Felipe Lagos Bastias'),
              pw.Text('Cargo: Ingeniero Agrónomo'),
            ],
          ),
        ),
        pw.SizedBox(height: 10),
        // Información de la plaza
        pw.Table(
          border: pw.TableBorder.all(),
          children: [
            _buildInfoRow('ID Plaza', plazaId),
            _buildInfoRow('DESCRIPCIÓN', nombrePlaza),
            _buildInfoRow('INSPECTOR', correoSupervisor),
            _buildInfoRow('FECHA Y HORA', fechaHora),
          ],
        ),
      ],
    );
  }

  /// Builds a single row for the information table
  pw.TableRow _buildInfoRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          color: PdfColors.grey300,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  /// Builds an evaluation section table
  pw.Widget _buildEvaluationSection(
    String sectionTitle,
    Map<String, String?> evaluations,
    List<String> criteria,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                sectionTitle,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'EVALUACIÓN',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        // Data rows
        ...criteria.map((criterio) {
          final valor = evaluations[criterio] ?? 'N/A';
          return pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(criterio),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(valor),
              ),
            ],
          );
        }),
      ],
    );
  }

  /// Builds the summary section with Estado General
  pw.Widget _buildSummary(String estadoGeneral) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        color: PdfColors.grey300,
      ),
      child: pw.Text(
        'Estado General: $estadoGeneral',
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  /// Adds photo annex pages to the PDF document
  ///
  /// Creates separate pages for each section that has images,
  /// displaying them in a 2-column grid layout
  Future<void> _addPhotoAnnex(
    pw.Document pdf,
    Map<String, List<XFile>> imagesBySection,
  ) async {
    for (final entry in imagesBySection.entries) {
      final sectionName = entry.key;
      final images = entry.value;

      if (images.isEmpty) continue;

      // Load images into memory
      final List<pw.MemoryImage> pdfImages = [];
      for (final xfile in images) {
        try {
          final bytes = await xfile.readAsBytes();
          pdfImages.add(pw.MemoryImage(bytes));
        } catch (e) {
          // Skip images that fail to load
          print('Error loading image from $sectionName: $e');
        }
      }

      if (pdfImages.isEmpty) continue;

      // Create photo annex page for this section
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            // Section header
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey300,
                border: pw.Border.all(),
              ),
              child: pw.Text(
                'ANEXO FOTOGRÁFICO - $sectionName',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 16),

            // Images in 2-column grid
            pw.Wrap(
              spacing: 16,
              runSpacing: 16,
              children: pdfImages.asMap().entries.map((imageEntry) {
                final index = imageEntry.key;
                final image = imageEntry.value;

                return pw.Container(
                  width:
                      (PdfPageFormat.a4.width - 96) /
                      2, // 2 columns with margins
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey400),
                        ),
                        child: pw.Image(
                          image,
                          fit: pw.BoxFit.cover,
                          width: (PdfPageFormat.a4.width - 96) / 2,
                          height: 180,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Foto ${index + 1}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }
  }
}
