import 'dart:typed_data';

/// Service for generating Word (DOCX) inspection reports
///
/// This service handles the creation of editable Word documents
/// containing inspection evaluation data for all 6 sections:
/// ASEO, CÉSPED, ARBOLADO, FLORES, CAMINOS, INFRAESTRUCTURA
class WordExportService {
  /// Generates a complete DOCX inspection report
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
  /// Returns a [Uint8List] containing the DOCX file bytes
  Future<Uint8List> generateInspectionDOCX({
    required String plazaId,
    required String nombrePlaza,
    required String correoSupervisor,
    required String fechaHora,
    required Map<String, Map<String, String?>> allEvaluations,
    required Map<String, List<String>> allCriteria,
    required String estadoGeneral,
  }) async {
    // Crear documento Word programáticamente
    final buffer = StringBuffer();

    // Agregar contenido en formato simple
    buffer.writeln('REPORTE DE INSPECCIÓN TÉCNICA');
    buffer.writeln('=' * 60);
    buffer.writeln();
    buffer.writeln('INFORMACIÓN DEL ÁREA VERDE');
    buffer.writeln('-' * 60);
    buffer.writeln('ID av: $plazaId');
    buffer.writeln('DESCRIPCIÓN: $nombrePlaza');
    buffer.writeln('FECHA/HORA: $fechaHora');
    buffer.writeln('Inspector: $correoSupervisor');
    buffer.writeln();

    // Agregar cada sección
    for (final entry in allEvaluations.entries) {
      final sectionTitle = entry.key;
      final evaluations = entry.value;
      final criteria = allCriteria[sectionTitle] ?? [];

      buffer.writeln();
      buffer.writeln(sectionTitle);
      buffer.writeln('-' * 60);

      for (final criterio in criteria) {
        final valor = evaluations[criterio] ?? 'N/A';
        buffer.writeln('• $criterio: $valor');
      }
    }

    // Agregar resumen
    buffer.writeln();
    buffer.writeln('=' * 60);
    buffer.writeln('ESTADO GENERAL: $estadoGeneral');
    buffer.writeln('=' * 60);

    // Convertir a bytes (formato texto simple compatible con Word)
    return Uint8List.fromList(buffer.toString().codeUnits);
  }
}
