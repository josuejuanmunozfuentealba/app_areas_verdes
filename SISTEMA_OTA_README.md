# 🚀 Sistema de Actualización OTA Automático

## 📋 Descripción

Este sistema permite actualizaciones automáticas **sin reinstalar el APK** usando un enfoque híbrido:

- **Android/Windows**: WebView que carga la app desde tu servidor
- **Web**: Service Worker (PWA) que detecta y descarga cambios automáticamente

## 🎯 Cómo Funciona

### Para Android y Windows (WebView)
1. La app abre un WebView apuntando a `http://localhost:8080` (o tu servidor)
2. Cada vez que el usuario abre la app, carga la versión más reciente del servidor
3. **No requiere reinstalar el APK** - siempre muestra la última versión web

### Para Web (PWA + Service Worker)
1. El Service Worker se registra automáticamente
2. Verifica actualizaciones cada 60 segundos
3. Cuando detecta cambios, descarga los nuevos archivos en segundo plano
4. Recarga automáticamente la página después de 2 segundos

## ⚙️ Configuración

### Paso 1: Instalar Dependencias

```bash
flutter pub get
```

### Paso 2: Cambiar URL del Servidor

Edita `lib/online_wrapper.dart` línea 7:

```dart
const String SERVER_URL = 'https://tu-servidor.com'; // Tu URL de producción
```

### Paso 3: Compilar

**Para Web:**
```bash
flutter build web --release
```

**Para Android:**
```bash
flutter build apk --release
```

**Para Windows:**
```bash
flutter build windows --release
```

## 📦 Estructura del Sistema

```
lib/
├── main.dart              # App Flutter original (para desarrollo)
├── online_wrapper.dart    # WebView wrapper (para producción)
└── pdf_saver.dart        # Utilidades

web/
├── index.html            # Con registro de Service Worker
└── sw.js                 # Service Worker para PWA
```

## 🔄 Flujo de Actualización

### Android/Windows
```
Usuario abre app
    ↓
WebView carga SERVER_URL
    ↓
Muestra última versión del servidor
    ↓
✅ Actualización automática
```

### Web (PWA)
```
Usuario abre app web
    ↓
Service Worker verifica actualizaciones
    ↓
¿Hay cambios en el servidor?
    ↓ Sí
Descarga nuevos archivos en segundo plano
    ↓
Recarga automáticamente después de 2s
    ↓
✅ Actualización aplicada
```

## 🚀 Publicar Actualización

### Paso 1: Hacer Cambios en el Código
```dart
// Edita lib/main.dart o cualquier archivo
```

### Paso 2: Compilar Web
```bash
flutter build web --release
```

### Paso 3: Subir a tu Servidor
```bash
# Copia build/web/* a tu servidor
scp -r build/web/* usuario@servidor:/ruta/web/
```

### Paso 4: Listo
- **Android/Windows**: Los usuarios verán los cambios al abrir la app
- **Web**: El Service Worker detectará y aplicará los cambios automáticamente

## 🎨 Ventajas

✅ **Sin reinstalar APK**: Los usuarios nunca necesitan descargar un nuevo APK
✅ **Actualizaciones instantáneas**: Los cambios se aplican inmediatamente
✅ **Multiplataforma**: Funciona en Android, Windows y Web
✅ **Automático**: No requiere intervención del usuario
✅ **Offline**: El Service Worker permite funcionamiento sin conexión

## ⚠️ Limitaciones

❌ **No actualiza código nativo**: Solo actualiza la parte web (Dart/Flutter)
❌ **Requiere servidor web**: Necesitas un servidor para alojar los archivos
❌ **Dependencias nativas**: Si agregas plugins nativos, necesitas nuevo APK

## 🔧 Modo de Desarrollo vs Producción

### Desarrollo (App Flutter Nativa)
```dart
// main.dart
void main() {
  runApp(const AppAreasVerdes()); // App Flutter completa
}
```

### Producción (WebView)
```dart
// main.dart
void main() {
  runApp(const MaterialApp(
    home: OnlineWrapper(), // WebView apuntando al servidor
  ));
}
```

## 🌐 Configurar Servidor

### Opción 1: Servidor Propio
```bash
# Nginx
server {
    listen 80;
    server_name tu-dominio.com;
    root /var/www/areas-verdes;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### Opción 2: GitHub Pages (Gratis)
1. Sube `build/web/*` a un repositorio
2. Activa GitHub Pages
3. URL: `https://usuario.github.io/repo`

### Opción 3: Firebase Hosting (Gratis)
```bash
firebase init hosting
firebase deploy
```

## 🧪 Probar el Sistema

### Probar WebView (Android)
1. Compila: `flutter build apk --release`
2. Instala el APK
3. Abre la app → Debería cargar desde `localhost:8080`
4. Cambia algo en `lib/main.dart`
5. Recompila web: `flutter build web --release`
6. Cierra y abre la app → Verás los cambios

### Probar PWA (Web)
1. Abre Chrome DevTools → Application → Service Workers
2. Verifica que `sw.js` esté registrado
3. Haz cambios en el código
4. Recompila: `flutter build web --release`
5. Espera 60 segundos o fuerza actualización
6. La página se recargará automáticamente

## 📞 Troubleshooting

### WebView no carga
- Verifica que `SERVER_URL` sea accesible
- Revisa permisos de internet en `AndroidManifest.xml`

### Service Worker no se registra
- Verifica que `sw.js` esté en `build/web/sw.js`
- Abre DevTools → Console para ver errores
- Asegúrate de usar HTTPS en producción

### Cambios no se aplican
- Limpia caché del navegador
- Desregistra el Service Worker antiguo
- Incrementa `CACHE_NAME` en `sw.js`

## 🔐 Seguridad

- Usa **HTTPS** en producción
- Configura **CORS** correctamente en tu servidor
- Valida **certificados SSL**

## 📊 Monitoreo

Para ver actualizaciones en tiempo real:

```javascript
// En Chrome DevTools → Console
navigator.serviceWorker.getRegistrations().then(regs => {
  regs.forEach(reg => console.log(reg));
});
```

## 🎯 Próximos Pasos

1. Cambia `SERVER_URL` a tu servidor de producción
2. Compila y distribuye el APK inicial
3. Publica actualizaciones solo recompilando web
4. Los usuarios recibirán actualizaciones automáticamente
