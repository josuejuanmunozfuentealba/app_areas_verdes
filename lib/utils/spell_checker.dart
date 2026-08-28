/// Corrector ortográfico simple para español
class SpellChecker {
  /// Palabras comunes en español (top 1000 más usadas en contexto de inspecciones)
  static final Set<String> _diccionario = {
    // Verbos comunes
    'observa', 'observar', 'observado', 'se', 'es', 'son', 'esta', 'están', 
    'tiene', 'tienen', 'hay', 'necesita', 'necesitan', 'requiere', 'requieren',
    'presenta', 'presentan', 'encuentra', 'encuentran', 'debe', 'deben',
    
    // Sustantivos relacionados con inspecciones
    'bancas', 'banca', 'material', 'materiales', 'madera', 'metal', 'concreto',
    'estructura', 'estructuras', 'pintura', 'deterioro', 'reparacion', 'reparación',
    'mantenimiento', 'limpieza', 'estado', 'condicion', 'condición', 'ubicacion',
    'ubicación', 'zona', 'area', 'área', 'espacio', 'superficie', 'juego', 'juegos',
    'dobladas', 'rotas', 'rota', 'doblada', 'oxidadas', 'oxidada', 'desgastada',
    'desgastadas', 'agrietada', 'agrietadas', 'sucia', 'sucias', 'limpia', 'limpias',
    'buena', 'buenas', 'mala', 'malas', 'regular', 'regulares', 'excelente',
    
    // Adjetivos comunes
    'bueno', 'malo', 'regular', 'excelente', 'deficiente', 'óptimo', 'optimo',
    'adecuado', 'inadecuado', 'suficiente', 'insuficiente', 'mayor', 'menor',
    'grande', 'pequeño', 'amplio', 'reducido', 'completo', 'incompleto',
    
    // Preposiciones y artículos
    'de', 'del', 'la', 'las', 'el', 'los', 'un', 'una', 'unos', 'unas',
    'en', 'con', 'sin', 'por', 'para', 'sobre', 'bajo', 'entre', 'desde',
    'hasta', 'hacia', 'a', 'al', 'y', 'o', 'u', 'e', 'ni', 'que', 'cual',
    
    // Números
    '1', '2', '3', '4', '5', '6', '7', '8', '9', '10',
    'uno', 'dos', 'tres', 'cuatro', 'cinco', 'seis', 'siete', 'ocho', 'nueve', 'diez',
    'primera', 'segundo', 'tercera', 'cuarta', 'quinta',
    
    // Palabras técnicas comunes
    'instalacion', 'instalación', 'infraestructura', 'equipamiento', 'mobiliario',
    'acceso', 'accesibilidad', 'seguridad', 'iluminacion', 'iluminación',
    'señalizacion', 'señalización', 'vegetacion', 'vegetación', 'jardineria',
    'jardinería', 'pasto', 'cesped', 'césped', 'arboles', 'árboles',
  };

  /// Detecta palabras sospechosas (no están en el diccionario)
  static List<String> detectarPalabrasSospechosas(String texto) {
    if (texto.trim().isEmpty) return [];

    // Limpiar y dividir el texto
    final palabras = texto
        .toLowerCase()
        .replaceAll(RegExp(r'[^\wáéíóúñü\s]'), ' ') // Mantener letras con acentos
        .split(RegExp(r'\s+'))
        .where((p) => p.length > 2) // Ignorar palabras muy cortas
        .toSet();

    // Filtrar palabras que NO están en el diccionario
    final sospechosas = palabras
        .where((palabra) => !_diccionario.contains(palabra))
        .toList();

    return sospechosas;
  }

  /// Revisa todo el formulario y retorna un mapa de palabras sospechosas por campo
  static Map<String, List<String>> revisarFormulario({
    required Map<String, String> observaciones,
    required List<Map<String, dynamic>> fotos,
  }) {
    final Map<String, List<String>> resultados = {};

    // Revisar observaciones
    observaciones.forEach((criterio, texto) {
      final sospechosas = detectarPalabrasSospechosas(texto);
      if (sospechosas.isNotEmpty) {
        resultados['Observación: $criterio'] = sospechosas;
      }
    });

    // Revisar notas de fotos
    for (var i = 0; i < fotos.length; i++) {
      final nota = fotos[i]['nota'] as String? ?? '';
      final sospechosas = detectarPalabrasSospechosas(nota);
      if (sospechosas.isNotEmpty) {
        resultados['Nota foto ${i + 1}'] = sospechosas;
      }
    }

    return resultados;
  }

  /// Sugerencias simples basadas en distancia Levenshtein simplificada
  static String? sugerirCorreccion(String palabra) {
    palabra = palabra.toLowerCase();
    
    // Buscar coincidencias exactas primero
    if (_diccionario.contains(palabra)) return null;

    // Buscar palabras similares (diferencia de 1-2 caracteres)
    final similares = _diccionario.where((correcta) {
      if ((correcta.length - palabra.length).abs() > 2) return false;
      
      int diferencias = 0;
      int maxLen = palabra.length > correcta.length ? palabra.length : correcta.length;
      
      for (int i = 0; i < maxLen; i++) {
        if (i >= palabra.length || i >= correcta.length) {
          diferencias++;
        } else if (palabra[i] != correcta[i]) {
          diferencias++;
        }
        if (diferencias > 2) return false;
      }
      
      return diferencias <= 2;
    }).toList();

    return similares.isNotEmpty ? similares.first : null;
  }
}
