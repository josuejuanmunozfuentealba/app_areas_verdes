# 📸 INSTRUCCIONES PARA AGREGAR EL LOGO

## Paso 1: Guardar la imagen del logo

1. Guarda la imagen del logo que proporcionaste en el chat como:
   ```
   assets/logo_municipalidad.png
   ```

2. Asegúrate de que el archivo tenga exactamente ese nombre y esté en formato PNG.

## Paso 2: Verificar que el logo está registrado

El logo ya está registrado en `pubspec.yaml` en la sección de assets:

```yaml
assets:
  - assets/logo_municipalidad.png
```

## Paso 3: Recompilar la aplicación

Después de agregar el logo, ejecuta:

```bash
flutter pub get
flutter build web --release
flutter build apk --release
```

## ✅ El logo aparecerá en:

- **PDF**: Esquina superior derecha del encabezado
- **Word**: Esquina superior derecha del encabezado (como imagen incrustada en HTML)

## 📐 Especificaciones recomendadas del logo:

- **Formato**: PNG (con fondo transparente preferiblemente)
- **Dimensiones**: 400x200 px o similar (proporción 2:1)
- **Peso**: Menor a 500 KB para mejor rendimiento

## ⚠️ Si el logo no aparece:

- Verifica que el archivo esté en la ubicación correcta: `assets/logo_municipalidad.png`
- Ejecuta `flutter clean` y luego `flutter pub get`
- Recompila la aplicación
- Si el archivo no existe, la aplicación continuará funcionando sin el logo (sin errores)
