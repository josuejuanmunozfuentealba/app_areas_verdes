# 🚀 INICIO RÁPIDO DEL SERVIDOR DE CORREOS

## ⚡ Comandos Rápidos

### 1. Ir a la carpeta del servidor
```bash
cd email_server
```

### 2. Iniciar el servidor
```bash
node server.js
```

O con auto-reinicio (recomendado para desarrollo):
```bash
npm run dev
```

### 3. Verificar que funciona
Abre en tu navegador: http://localhost:3000/api/health

Deberías ver:
```json
{
  "status": "ok",
  "message": "Servidor funcionando correctamente"
}
```

## ✅ El servidor está listo cuando veas:
```
🚀 Servidor iniciado en http://localhost:3000
📧 Endpoint: POST http://localhost:3000/api/send-email-base64
✅ Servidor de correo configurado correctamente
```

## ⚠️ Si es la primera vez:

### 1. Instalar dependencias (solo una vez):
```bash
cd email_server
npm install
```

### 2. Configurar correo (solo una vez):
```bash
copy .env.example .env
```

Luego edita el archivo `.env` y agrega:
- Tu correo de Gmail
- Tu contraseña de aplicación de Gmail

**Cómo obtener la contraseña de aplicación:**
1. Ve a: https://myaccount.google.com/apppasswords
2. Crea una nueva contraseña para "Áreas Verdes"
3. Cópiala y pégala en el archivo `.env`

## 🛑 Para detener el servidor:
Presiona `Ctrl + C` en la terminal

## 📋 Archivos importantes:
- `.env` - Configuración del correo (NO subir a Git)
- `server.js` - Código del servidor
- `README.md` - Documentación completa

## 🐛 Problemas comunes:

### Error: "Cannot find module"
**Solución:** Ejecuta `npm install` en la carpeta email_server

### Error: "Port 3000 is already in use"
**Solución:** 
- Cierra otros servidores en el puerto 3000
- O cambia el puerto en el archivo `.env`: `PORT=3001`

### Error: "Invalid login"
**Solución:** 
- Verifica que la contraseña de aplicación esté correcta
- Asegúrate de tener verificación en dos pasos activada en Gmail

## 💡 Consejo:
Deja el servidor corriendo en una terminal mientras usas la aplicación Flutter.
El servidor debe estar activo para poder enviar correos.
