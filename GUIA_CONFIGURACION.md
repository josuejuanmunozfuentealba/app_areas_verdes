# 🚀 GUÍA DE CONFIGURACIÓN COMPLETA

## PASO 1: Reemplazar el Logo (IMPORTANTE)

### ¿Dónde está el logo?
La imagen del logo que proporcionaste en el chat debe guardarse como:
```
assets/logo_municipalidad.png
```

### ¿Cómo reemplazarlo?

1. **Guarda la imagen del logo** que enviaste en el chat (la imagen con el escudo y "Municipalidad de Doñihue")

2. **Reemplaza el archivo** `assets/logo_municipalidad.png` con tu imagen

3. **Especificaciones recomendadas**:
   - Formato: PNG (con fondo transparente)
   - Dimensiones: 400x200 px (o similar, proporción 2:1)
   - Peso: Menor a 500 KB

4. **Recompila la aplicación**:
   ```bash
   flutter clean
   flutter pub get
   flutter build web --release
   flutter build apk --release
   ```

---

## PASO 2: Configurar Gmail para Envío de Correos

### A. Crear Contraseña de Aplicación en Gmail

1. **Ve a tu cuenta de Google**: https://myaccount.google.com/security

2. **Activa la verificación en dos pasos** (si no está activada):
   - Haz clic en "Verificación en dos pasos"
   - Sigue las instrucciones para activarla

3. **Crea una contraseña de aplicación**:
   - Ve a: https://myaccount.google.com/apppasswords
   - Selecciona "Correo" como aplicación
   - Selecciona "Otro (nombre personalizado)" como dispositivo
   - Escribe: "Áreas Verdes"
   - Haz clic en "Generar"
   - **Copia la contraseña de 16 caracteres** que aparece

### B. Configurar el Archivo .env

1. **Abre el archivo**: `email_server\.env`

2. **Edita estas líneas** con tus credenciales reales:
   ```
   EMAIL_USER=tucorreo@gmail.com
   EMAIL_PASSWORD=tu contraseña de aplicacion sin espacios
   ```

   **Ejemplo**:
   ```
   EMAIL_USER=areasverdes.donihue@gmail.com
   EMAIL_PASSWORD=abcdefghijklmnop
   ```

3. **Guarda el archivo**

### C. Verificar que el archivo .env NO se suba a Git

El archivo `.env` ya está en `.gitignore`, pero verifica:

```bash
git status
```

Si aparece `.env` en la lista, NO lo agregues a Git (contiene credenciales sensibles).

---

## PASO 3: Iniciar el Servidor de Correos

### Opción A: Iniciar Manualmente

1. **Abrir terminal** en la carpeta del proyecto

2. **Navegar a la carpeta del servidor**:
   ```bash
   cd email_server
   ```

3. **Iniciar el servidor**:
   ```bash
   npm start
   ```

4. **Verificar que funciona**:
   Deberías ver:
   ```
   🚀 Servidor iniciado en http://localhost:3000
   ✅ Servidor de correo configurado correctamente
   ```

5. **Probar la salud del servidor**:
   Abre en tu navegador: http://localhost:3000/api/health
   
   Deberías ver:
   ```json
   {
     "status": "ok",
     "message": "Servidor funcionando correctamente",
     "timestamp": "2026-06-23T..."
   }
   ```

### Opción B: Iniciar Automáticamente al Iniciar Windows (Opcional)

Si quieres que el servidor inicie automáticamente:

1. **Crear un archivo BAT**:
   - Crea un archivo: `iniciar_servidor.bat`
   - Contenido:
     ```batch
     @echo off
     cd /d "C:\Users\HP PAVILION\app_areas_verdes\email_server"
     start /min cmd /c npm start
     ```

2. **Agregar al inicio de Windows**:
   - Presiona `Win + R`
   - Escribe: `shell:startup`
   - Copia el archivo `iniciar_servidor.bat` a esa carpeta

---

## PASO 4: Probar el Envío de Correos

### Prueba 1: Desde la Aplicación

1. **Con el servidor corriendo**, abre la aplicación

2. **Completa una inspección**:
   - Evalúa al menos 1 ítem
   - Ingresa el nombre del inspector
   - Ingresa el correo del inspector

3. **Presiona "Enviar Reporte"**

4. **Elige "Envío Automático"**

5. **Espera**:
   - Verás un indicador de carga: "Generando PDF y enviando correo..."
   - Si todo está bien, verás: "✓ Correo enviado exitosamente con PDF adjunto"

6. **Revisa el correo** del inspector para verificar que llegó con el PDF adjunto

### Prueba 2: Probar con Postman o cURL (Opcional)

Si quieres probar el servidor directamente:

```bash
curl -X POST http://localhost:3000/api/send-email-base64 ^
  -H "Content-Type: application/json" ^
  -d "{\"destinatario\":\"tucorreo@gmail.com\",\"asunto\":\"Prueba\",\"cuerpo\":\"Mensaje de prueba\",\"nombreArchivo\":\"test.pdf\"}"
```

---

## PASO 5: Solución de Problemas

### Error: "El servidor de correos no está disponible"

**Causas**:
- El servidor no está corriendo
- La URL del servidor es incorrecta

**Solución**:
1. Verifica que el servidor esté corriendo: `npm start` en `email_server/`
2. Verifica la URL en `lib/services/email_service.dart`: debe ser `http://localhost:3000`

---

### Error: "Invalid login" en el servidor

**Causas**:
- Credenciales incorrectas
- No se usó contraseña de aplicación
- Verificación en dos pasos no activada

**Solución**:
1. Verifica que usaste una **contraseña de aplicación** (no tu contraseña normal)
2. Ve a https://myaccount.google.com/apppasswords y genera una nueva
3. Copia la contraseña **sin espacios** en el archivo `.env`
4. Reinicia el servidor: `Ctrl+C` y luego `npm start`

---

### Error: "Network error" desde Flutter Web

**Causas**:
- Problema de CORS
- El servidor no está en la misma red

**Solución**:
1. Verifica que el servidor esté corriendo
2. El código ya tiene CORS habilitado, debería funcionar
3. Si el problema persiste, usa ngrok para exponer el servidor:
   ```bash
   npx ngrok http 3000
   ```
   Y actualiza la URL en `email_service.dart`

---

### El logo no aparece en los documentos

**Causas**:
- El archivo no existe
- El archivo tiene nombre incorrecto
- No se recompiló la aplicación

**Solución**:
1. Verifica: `assets/logo_municipalidad.png` existe
2. Verifica que esté registrado en `pubspec.yaml`
3. Ejecuta:
   ```bash
   flutter clean
   flutter pub get
   flutter build web --release
   flutter build apk --release
   ```

---

## PASO 6: Desplegar en Producción (Opcional)

Si quieres que el servidor esté disponible 24/7 sin tener tu computadora encendida:

### Opción A: Heroku (Gratis)

1. Crea cuenta en https://heroku.com
2. Instala Heroku CLI
3. Desde `email_server/`:
   ```bash
   heroku login
   git init
   heroku create nombre-app
   heroku config:set EMAIL_USER=tucorreo@gmail.com
   heroku config:set EMAIL_PASSWORD=tucontraseña
   git add .
   git commit -m "Initial commit"
   git push heroku main
   ```

### Opción B: Railway (Recomendado)

1. Crea cuenta en https://railway.app
2. Conecta tu repositorio de GitHub
3. Configura las variables de entorno en el dashboard
4. Deploy automático

### Opción C: Vercel

1. Crea cuenta en https://vercel.com
2. Importa tu repositorio
3. Configura como función serverless

Una vez desplegado, actualiza la URL en `lib/services/email_service.dart`:
```dart
static const String serverUrl = 'https://tu-app.herokuapp.com';
```

---

## RESUMEN DE ARCHIVOS IMPORTANTES

```
├── assets/
│   └── logo_municipalidad.png       ← REEMPLAZAR CON LOGO REAL
│
├── email_server/
│   ├── .env                         ← CONFIGURAR CON TUS CREDENCIALES
│   ├── server.js                    ← Servidor Node.js
│   └── package.json                 ← Dependencias
│
├── lib/
│   └── services/
│       └── email_service.dart       ← Servicio de correo
│
└── build/
    ├── web/                         ← Aplicación web compilada
    └── app/outputs/flutter-apk/
        └── app-release.apk          ← APK compilado (49.9 MB)
```

---

## ¿NECESITAS AYUDA?

Si encuentras algún problema:

1. **Revisa los logs del servidor**: En la terminal donde corre `npm start`
2. **Revisa los logs de Flutter**: Se mostrarán en la interfaz de la app
3. **Verifica la configuración**: Asegúrate de que las credenciales sean correctas
4. **Prueba las alternativas**: Usa Gmail/Outlook Web si el servidor no funciona

---

**¡Listo!** Con estos pasos tendrás:
✅ Logo real en documentos
✅ Servidor de correos configurado
✅ Envío automático de correos con PDF adjunto funcionando
