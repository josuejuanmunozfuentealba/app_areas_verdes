import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service for generating PDF inspection reports
///
/// This service handles the creation of professional PDF documents
/// containing inspection evaluation data for all 6 sections:
/// ASEO, CÉSPED, ARBOLADO, FLORES, CAMINOS, INFRAESTRUCTURA
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
  }) async {
    final pdf = pw.Document();

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
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _buildInfoRow('ID av', plazaId),
        _buildInfoRow('DESCRIPCIÓN', nombrePlaza),
        _buildInfoRow('FECHA/HORA', fechaHora),
        _buildInfoRow('Inspector', correoSupervisor),
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
}
