# Servidor de Envío de Correos con PDF Adjunto

Este servidor Node.js permite enviar correos electrónicos con archivos PDF adjuntos desde la aplicación Flutter.

## 📋 Requisitos Previos

- Node.js (versión 14 o superior)
- npm (incluido con Node.js)
- Cuenta de Gmail con "Contraseñas de aplicación" habilitadas

## 🚀 Instalación

1. **Navegar a la carpeta del servidor:**
   ```bash
   cd email_server
   ```

2. **Instalar dependencias:**
   ```bash
   npm install
   ```

3. **Configurar variables de entorno:**
   
   a. Copiar el archivo de ejemplo:
   ```bash
   copy .env.example .env
   ```
   
   b. Editar el archivo `.env` y configurar:
   - `EMAIL_USER`: Tu correo de Gmail (ej: tunombre@gmail.com)
   - `EMAIL_PASSWORD`: Tu contraseña de aplicación de Gmail

## 🔑 Obtener Contraseña de Aplicación de Gmail

1. Ve a tu cuenta de Google: https://myaccount.google.com/security
2. Activa la **verificación en dos pasos** (si no está activada)
3. Ve a **Contraseñas de aplicaciones**: https://myaccount.google.com/apppasswords
4. Selecciona "Correo" y "Otro dispositivo personalizado"
5. Escribe "Áreas Verdes" como nombre
6. Copia la contraseña generada (16 caracteres sin espacios)
7. Pégala en el archivo `.env` como valor de `EMAIL_PASSWORD`

## ▶️ Iniciar el Servidor

**Modo desarrollo (con auto-reinicio):**
```bash
npm run dev
```

**Modo producción:**
```bash
npm start
```

El servidor se iniciará en: `http://localhost:3000`

## 🧪 Probar el Servidor

Abrir en el navegador:
```
http://localhost:3000/api/health
```

Deberías ver:
```json
{
  "status": "ok",
  "message": "Servidor funcionando correctamente",
  "timestamp": "2026-06-23T..."
}
```

## 📡 API Endpoints

### POST /api/send-email-base64

Envía un correo con PDF en formato base64.

**Body (JSON):**
```json
{
  "destinatario": "inspector@ejemplo.com",
  "asunto": "Inspección Técnica: Plaza Central - ID123 - 23-06-2026",
  "cuerpo": "Estimado Inspector,\n\nAdjunto el reporte...",
  "pdfBase64": "JVBERi0xLjQKJeLj...",
  "nombreArchivo": "Inspeccion_PlazaCentral_ID123_23-06-2026.pdf"
}
```

**Respuesta exitosa:**
```json
{
  "success": true,
  "messageId": "<...@gmail.com>",
  "message": "Correo enviado exitosamente"
}
```

## 🔧 Integración con Flutter

El archivo `lib/services/email_service.dart` ya está configurado para usar este servidor.

Solo necesitas actualizar la URL del servidor en el código si es diferente de `http://localhost:3000`.

## 🐛 Solución de Problemas

### Error: "Invalid login"
- Verifica que la contraseña de aplicación esté correcta (sin espacios)
- Asegúrate de tener activada la verificación en dos pasos en Gmail

### Error: "ECONNREFUSED"
- Verifica que el servidor esté corriendo
- Comprueba el puerto en el archivo `.env`

### Error: "Network error" desde Flutter
- Si usas Flutter Web, el servidor debe estar en la misma red
- Considera usar ngrok para exponer el servidor: `npx ngrok http 3000`

## 📦 Despliegue en Producción

Para desplegar en un servidor real, puedes usar:

1. **Heroku**: Plataforma gratuita para Node.js
2. **Railway**: Alternativa moderna y fácil
3. **Vercel**: Soporte para funciones serverless
4. **AWS/Azure/GCP**: Para mayor control

## 🔐 Seguridad

- **Nunca** subas el archivo `.env` a Git (ya está en `.gitignore`)
- Usa contraseñas de aplicación, NO tu contraseña de Gmail real
- Considera agregar autenticación API si expones el servidor públicamente
- Limita el tamaño de archivos (actualmente 50MB)

## 📝 Notas

- El servidor acepta PDFs de hasta 50 MB
- Los correos se envían desde el correo configurado en `EMAIL_USER`
- El tiempo de envío depende del tamaño del PDF (típicamente 1-3 segundos)
