# Dependencias Requeridas para Panel de Acciones

Agrega estas dependencias a tu archivo `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Dependencias existentes
  flutter_map: ^7.0.2
  latlong2: ^0.9.1
  url_launcher: ^6.3.1
  
  # NUEVAS DEPENDENCIAS REQUERIDAS:
  
  # Para guardar historial localmente
  shared_preferences: ^2.3.3
  
  # Para generar PDFs
  pdf: ^3.11.1
  printing: ^5.13.4
  
  # Para generar documentos Word
  docx_template: ^0.6.1
  
  # Para acceder al directorio de documentos
  path_provider: ^2.1.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

## Instalación

Después de agregar las dependencias, ejecuta:

```bash
flutter pub get
```

## Notas Importantes

1. **shared_preferences**: Guarda el historial de inspecciones de forma persistente
2. **pdf + printing**: Genera documentos PDF profesionales con tablas
3. **docx_template**: Genera archivos Word (.docx) - Si da problemas, la app creará archivos TXT como alternativa
4. **path_provider**: Permite guardar archivos en el dispositivo
5. **url_launcher**: Ya estaba en tu proyecto, se usa para abrir el cliente de correo

## Permisos Android (si usas Android)

Agrega en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
```

## Permisos iOS (si usas iOS)

Agrega en `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Necesitamos acceso para guardar archivos PDF y Word</string>
```
