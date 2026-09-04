# 🎯 IMPLEMENTACIÓN: GPS + Registrar Plazas en el Mapa

## ✅ COMPLETADO:
1. ✅ Dependencia `geolocator: ^10.1.0` agregada a `pubspec.yaml`
2. ✅ Permisos GPS ya configurados en `AndroidManifest.xml`
3. ✅ Import de geolocator agregado en `main.dart`

---

## 📋 CAMBIOS A REALIZAR EN `lib/main.dart`:

### **1. Agregar onTap al MapOptions (línea ~1807)**

Busca esta sección:
```dart
options: MapOptions(
  initialCenter: centroDonihue,
  initialZoom: 16.0,
),
```

Reemplázala por:
```dart
options: MapOptions(
  initialCenter: centroDonihue,
  initialZoom: 16.0,
  onTap: (tapPosition, latLng) {
    // Registrar nueva plaza al tocar el mapa
    _mostrarModalNuevaPlaza(latLng);
  },
),
```

---

### **2. Agregar funciones GPS y Registro (después de la línea ~1100)**

Agrega estas funciones en la clase `_PantallaMapaState`:

```dart
  /// Obtener ubicación actual y mover cámara
  Future<void> _irAMiUbicacion() async {
    try {
      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _mostrarError('Permisos de ubicación denegados');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _mostrarError(
          'Permisos de ubicación denegados permanentemente.\n'
          'Ve a Configuración → Aplicaciones → Permisos',
        );
        return;
      }

      // Obtener posición actual
      _mostrarCargando('Obteniendo ubicación...');
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      Navigator.of(context).pop(); // Cerrar loading

      // Mover mapa a mi ubicación
      final miUbicacion = LatLng(position.latitude, position.longitude);
      _mapController.move(miUbicacion, 18.0); // Zoom 18 para ver detalle

      // Mostrar diálogo: ¿Registrar plaza aquí?
      _confirmarRegistroEnUbicacion(miUbicacion);
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar loading si hay error
      _mostrarError('Error al obtener ubicación: $e');
    }
  }

  /// Confirmar si quiere registrar plaza en su ubicación actual
  void _confirmarRegistroEnUbicacion(LatLng ubicacion) {
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
              _mostrarModalNuevaPlaza(ubicacion);
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

  /// Modal para registrar nueva plaza
  void _mostrarModalNuevaPlaza(LatLng coordenadas) {
    final idGenerado = 'PLZ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                    _mostrarError('Ingresa un nombre para la plaza');
                    return;
                  }

                  Navigator.pop(context); // Cerrar modal

                  await _guardarNuevaPlazaEnSupabase(
                    id: idGenerado,
                    nombre: nombreController.text.trim(),
                    tipo: tipoController.text.trim(),
                    lat: coordenadas.latitude,
                    lng: coordenadas.longitude,
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
    );
  }

  /// Guardar nueva plaza en Supabase
  Future<void> _guardarNuevaPlazaEnSupabase({
    required String id,
    required String nombre,
    required String tipo,
    required double lat,
    required double lng,
  }) async {
    try {
      _mostrarCargando('Registrando plaza...');

      await Supabase.instance.client.from('plazas').insert({
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'latitud': lat,
        'longitud': lng,
        'estado': 'Nuevo',
        'created_at': DateTime.now().toIso8601String(),
      });

      Navigator.of(context).pop(); // Cerrar loading

      // Agregar marcador al mapa inmediatamente
      setState(() {
        misPlazas.add({
          'id': id,
          'nombre': nombre,
          'tipo': tipo,
          'coordenadas': LatLng(lat, lng),
          'estado': 'Nuevo',
        });
      });

      // Mover cámara a la nueva plaza
      _mapController.move(LatLng(lat, lng), 18.0);

      // Mostrar éxito y preguntar si quiere iniciar catastro
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
          content: Text('✓ "$nombre" registrada exitosamente\n\n¿Deseas iniciar el catastro ahora?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Más tarde'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _abrirCatastro(id, nombre);
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
    } catch (e) {
      Navigator.of(context).pop(); // Cerrar loading si hay error
      _mostrarError('Error al registrar plaza: $e');
    }
  }

  /// Funciones auxiliares
  void _mostrarCargando(String mensaje) {
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

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
```

---

### **3. Agregar botón flotante GPS (dentro del Stack, después de línea ~1850)**

Busca donde termina el Stack con los widgets del mapa y agrega este botón ANTES del cierre del Stack:

```dart
          // Botón flotante GPS
          Positioned(
            bottom: 140, // Arriba de la tarjeta del encargado
            right: 16,
            child: FloatingActionButton(
              onPressed: _irAMiUbicacion,
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2E7D32),
              elevation: 4,
              heroTag: 'gps_button',
              child: const Icon(Icons.my_location, size: 28),
              tooltip: 'Mi ubicación',
            ),
          ),
```

---

## 🗄️ CONFIGURACIÓN SUPABASE:

### Ejecuta este SQL en Supabase SQL Editor:

```sql
-- Agregar columnas para plazas no mapeadas (si la tabla ya existe)
ALTER TABLE plazas ADD COLUMN IF NOT EXISTS tipo TEXT;
ALTER TABLE plazas ADD COLUMN IF NOT EXISTS latitud DOUBLE PRECISION;
ALTER TABLE plazas ADD COLUMN IF NOT EXISTS longitud DOUBLE PRECISION;

-- O crear tabla si no existe
CREATE TABLE IF NOT EXISTS plazas (
  id TEXT PRIMARY KEY,
  nombre TEXT NOT NULL,
  tipo TEXT,
  latitud DOUBLE PRECISION NOT NULL,
  longitud DOUBLE PRECISION NOT NULL,
  estado TEXT DEFAULT 'Nuevo',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Índice para búsqueda por ubicación
CREATE INDEX IF NOT EXISTS idx_plazas_coordenadas ON plazas(latitud, longitud);

-- Habilitar RLS
ALTER TABLE plazas ENABLE ROW LEVEL SECURITY;

-- Políticas públicas (ajustar según tu caso)
CREATE POLICY "Permitir lectura pública plazas"
ON plazas FOR SELECT
USING (true);

CREATE POLICY "Permitir inserción pública plazas"
ON plazas FOR INSERT
WITH CHECK (true);
```

---

## ✅ RESULTADO FINAL:

1. **Botón GPS flotante** → Obtiene ubicación → Confirma si quiere registrar plaza
2. **Tap en cualquier punto del mapa** → Abre formulario con coordenadas del punto tocado
3. **Formulario:**
   - ID autogenerado (PLZ-[timestamp])
   - Nombre de plaza (editable)
   - Tipo/Sector (editable)
   - Coordenadas (capturadas automáticamente)
4. **Al guardar:**
   - Inserta en Supabase tabla `plazas`
   - Agrega marcador al mapa inmediatamente
   - Mueve cámara a la nueva plaza
   - Pregunta si quiere iniciar catastro

---

**¿Quieres que implemente estos cambios en el código o prefieres hacerlo manualmente siguiendo estas instrucciones?** 🚀
