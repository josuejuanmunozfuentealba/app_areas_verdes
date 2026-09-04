import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Servicio para funcionalidades GPS y registro de plazas en el mapa
class MapaGpsService {
  /// Obtener ubicación actual y mover cámara del mapa
  static Future<void> irAMiUbicacion({
    required BuildContext context,
    required MapController mapController,
    required Function(LatLng) onUbicacionObtenida,
  }) async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _mostrarError(context, 'Permisos de ubicación denegados');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _mostrarError(
          context,
          'Permisos de ubicación denegados permanentemente.\n'
          'Ve a Configuración → Aplicaciones → Permisos',
        );
        return;
      }

      // Mostrar loading
      _mostrarCargando(context, 'Obteniendo ubicación GPS...');

      // Obtener posición actual con MÁXIMA PRECISIÓN
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best, // BEST = máxima precisión
        forceAndroidLocationManager:
            false, // Usar Google Play Services (más preciso)
      );

      if (!context.mounted) return; // Check antes de usar context
      Navigator.of(context).pop(); // Cerrar loading

      // Mover mapa a mi ubicación
      final miUbicacion = LatLng(position.latitude, position.longitude);
      mapController.move(miUbicacion, 18.0); // Zoom 18 para ver detalle

      // Callback con la ubicación obtenida
      onUbicacionObtenida(miUbicacion);
    } catch (e) {
      if (!context.mounted) return; // Check antes de usar context
      Navigator.of(context).pop(); // Cerrar loading si hay error
      _mostrarError(context, 'Error al obtener ubicación: $e');
    }
  }

  /// Mostrar diálogo de confirmación para registrar plaza en ubicación actual
  static void confirmarRegistroEnUbicacion({
    required BuildContext context,
    required LatLng ubicacion,
    required VoidCallback onConfirmar,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.my_location, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('Mi Ubicación'),
          ],
        ),
        content: Text(
          '¿Deseas registrar una nueva plaza/área verde en esta ubicación?\n\n'
          'Lat: ${ubicacion.latitude.toStringAsFixed(6)}\n'
          'Lng: ${ubicacion.longitude.toStringAsFixed(6)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onConfirmar();
            },
            icon: const Icon(Icons.add_location),
            label: const Text('Registrar Plaza'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Modal BottomSheet para registrar nueva plaza
  static void mostrarModalNuevaPlaza({
    required BuildContext context,
    required LatLng coordenadas,
    required Function(String id, String nombre) onPlazaRegistrada,
  }) {
    final idGenerado =
        'PLZ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final nombreController = TextEditingController();
    final tipoController = TextEditingController(text: 'Plaza');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_location_alt,
                      color: Color(0xFF2E7D32),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '📍 Nueva Área Verde / Plaza',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Coordenadas
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Lat: ${coordenadas.latitude.toStringAsFixed(6)} | '
                        'Lng: ${coordenadas.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ID Plaza (autogenerado, solo lectura)
              TextField(
                controller: TextEditingController(text: idGenerado),
                decoration: InputDecoration(
                  labelText: 'ID Plaza',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.tag),
                  suffixIcon: const Icon(Icons.lock_outline, size: 16),
                  helperText: 'ID único generado automáticamente',
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                readOnly: true,
              ),
              const SizedBox(height: 12),

              // Nombre de la plaza
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Plaza / Parque *',
                  hintText: 'Ej: Plaza 21 de Mayo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.landscape),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),

              // Tipo de área verde
              TextField(
                controller: tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo / Sector',
                  hintText: 'Plaza, Parque, Bandejón, etc.',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 20),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (nombreController.text.trim().isEmpty) {
                      _mostrarError(context, 'Ingresa un nombre para la plaza');
                      return;
                    }

                    Navigator.pop(context); // Cerrar modal

                    await guardarNuevaPlazaEnSupabase(
                      context: context,
                      id: idGenerado,
                      nombre: nombreController.text.trim(),
                      tipo: tipoController.text.trim(),
                      lat: coordenadas.latitude,
                      lng: coordenadas.longitude,
                      onExito: () => onPlazaRegistrada(
                        idGenerado,
                        nombreController.text.trim(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Registrar e Iniciar Catastro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Guardar nueva plaza en Supabase
  static Future<void> guardarNuevaPlazaEnSupabase({
    required BuildContext context,
    required String id,
    required String nombre,
    required String tipo,
    required double lat,
    required double lng,
    required VoidCallback onExito,
  }) async {
    try {
      _mostrarCargando(context, 'Registrando plaza en Supabase...');

      await Supabase.instance.client.from('plazas').insert({
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'latitud': lat,
        'longitud': lng,
        'estado': 'Nuevo',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!context.mounted) return; // Check antes de usar context
      Navigator.of(context).pop(); // Cerrar loading
      onExito(); // Callback de éxito
    } catch (e) {
      if (!context.mounted) return; // Check antes de usar context
      Navigator.of(context).pop(); // Cerrar loading
      _mostrarError(context, 'Error al registrar plaza: $e');
    }
  }

  /// Mostrar diálogo de éxito y preguntar si quiere iniciar catastro
  static void mostrarExitoYPreguntarCatastro({
    required BuildContext context,
    required String nombre,
    required VoidCallback onIniciarCatastro,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Plaza Registrada'),
          ],
        ),
        content: Text(
          '✓ "$nombre" registrada exitosamente\n\n'
          '¿Deseas iniciar el catastro ahora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Más tarde'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onIniciarCatastro();
            },
            icon: const Icon(Icons.assignment),
            label: const Text('Iniciar Catastro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // FUNCIONES AUXILIARES
  // ============================================================================

  static void _mostrarCargando(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(mensaje),
          ],
        ),
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
