/// Data model for inspection reports
///
/// This file contains the data models used for compiling and exporting
/// inspection evaluation data.
library;

/// Main data model containing all inspection information
class InspectionData {
  final String plazaId;
  final String nombrePlaza;
  final String correoSupervisor;
  final DateTime fechaHora;
  final String estadoGeneral;
  final Map<String, EvaluationSection> sections;
  final Map<String, List<Map<String, dynamic>>> images;

  InspectionData({
    required this.plazaId,
    required this.nombrePlaza,
    required this.correoSupervisor,
    required this.fechaHora,
    required this.estadoGeneral,
    required this.sections,
    required this.images,
  }) {
    // Validation
    assert(plazaId.isNotEmpty, 'plazaId must not be empty');
    assert(nombrePlaza.isNotEmpty, 'nombrePlaza must not be empty');
    assert(sections.length == 6, 'sections must contain exactly 6 entries');
    assert(
      images.length == 6,
      'images must contain exactly 6 entries (one per section)',
    );
  }

  /// Gets formatted date/time string for display
  String get fechaHoraFormatted {
    return fechaHora.toString().substring(0, 16);
  }

  /// Gets total count of images across all sections
  int get totalImageCount {
    int count = 0;
    for (var list in images.values) {
      count += list.length;
    }
    return count;
  }
}

/// Represents a single evaluation section (e.g., ASEO, CÉSPED)
class EvaluationSection {
  final String title;
  final List<String> criteria;
  final Map<String, String?> evaluations;
  final Map<String, String>? observations;

  EvaluationSection({
    required this.title,
    required this.criteria,
    required this.evaluations,
    this.observations,
  }) {
    // Validation
    assert(title.isNotEmpty, 'title must not be empty');
    assert(criteria.isNotEmpty, 'criteria list must not be empty');
  }

  /// Gets all evaluated items with their values
  List<EvaluatedItem> get evaluatedItems {
    return criteria.map((criterio) {
      return EvaluatedItem(
        criterio: criterio,
        valor: evaluations[criterio] ?? 'N/A',
        observacion: observations?[criterio],
      );
    }).toList();
  }
}

/// Represents a single evaluated item (criterio + valor)
class EvaluatedItem {
  final String criterio;
  final String valor; // 'Bueno', 'Regular', 'Malo', 'N/A'
  final String? observacion;

  EvaluatedItem({
    required this.criterio,
    required this.valor,
    this.observacion,
  });

  /// Returns true if the evaluation is problematic (Regular or Malo)
  bool get isProblematic => valor == 'Regular' || valor == 'Malo';
}
