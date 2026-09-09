enum ModoInspeccion {
  areasVerdes,
  inmuebles,
  urgencias,
}

extension ModoInspeccionExtension on ModoInspeccion {
  String get nombre {
    switch (this) {
      case ModoInspeccion.areasVerdes:
        return 'Áreas Verdes';
      case ModoInspeccion.inmuebles:
        return 'Catastro de Inmuebles';
      case ModoInspeccion.urgencias:
        return 'Inspección de Urgencia';
    }
  }

  String get campoEstado {
    switch (this) {
      case ModoInspeccion.areasVerdes:
        return 'estado_areas_verdes';
      case ModoInspeccion.inmuebles:
        return 'estado';  // Campo actual que usa inmuebles
      case ModoInspeccion.urgencias:
        return 'estado_urgencias';
    }
  }

  String get icono {
    switch (this) {
      case ModoInspeccion.areasVerdes:
        return '🌳';
      case ModoInspeccion.inmuebles:
        return '🏗️';
      case ModoInspeccion.urgencias:
        return '⚠️';
    }
  }

  String get descripcion {
    switch (this) {
      case ModoInspeccion.areasVerdes:
        return 'Pasto, Árboles, Riego, Aseo';
      case ModoInspeccion.inmuebles:
        return 'Bancas, Juegos, Basureros';
      case ModoInspeccion.urgencias:
        return 'Problemas críticos';
    }
  }
}
