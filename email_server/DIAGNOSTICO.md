# 🔧 DIAGNÓSTICO DEL SERVIDOR DE CORREOS

## Problema Reportado
El servidor en localhost:3000 no se mantiene activo cuando se ejecuta desde el archivo batch.

---

## ✅ CAMBIOS REALIZADOS

### 1. **Mejoras en server.js**
- ✅ Agregado manejo de errores no capturados (`uncaughtException`, `unhandledRejection`)
- ✅ Mejorada la verificación de credenciales de correo (no bloquea inicio)
- ✅ Agregado manejo de error si el puerto está en uso (`EADDRINUSE`)
- ✅ Mensajes de consola más claros y descriptivos

### 2. **Batch file mejorado**
- ✅ El archivo `INICIAR_SERVIDOR.bat` ya tiene las verificaciones necesarias
- ✅ La ventana permanece abierta incluso si el servidor se detiene

### 3. **Nuevo archivo de prueba**
- ✅ Creado `PROBAR_SERVIDOR.bat` para verificar si el servidor está activo

---

## 🚀 PASOS PARA INICIAR EL SERVIDOR

### Opción 1: Usando el batch file (RECOMENDADO)
```batch
# Ejecuta este archivo:
INICIAR_SERVIDOR.bat
```

### Opción 2: Manualmente desde CMD
```batch
cd c:\Users\HP PAVILION\app_areas_verdes\email_server
node server.js
```

---

## 🔍 CÓMO VERIFICAR SI ESTÁ FUNCIONANDO

### Método 1: Ejecutar el archivo de prueba
```batch
# Ejecuta este archivo en otra ventana de CMD:
PROBAR_SERVIDOR.bat
```

### Método 2: Abrir en el navegador
Abre esta URL en tu navegador:
```
http://localhost:3000/api/health
```

Deberías ver una respuesta JSON como:
```json
{
  "status": "ok",
  "message": "Servidor funcionando correctamente",
  "timestamp": "2026-07-15T..."
}
```

### Método 3: Verificar en CMD
```batch
curl http://localhost:3000/api/health
```

---

## ⚠️ POSIBLES PROBLEMAS Y SOLUCIONES

### Problema 1: El servidor se cierra inmediatamente

**Causa probable:** Error en las credenciales de Gmail en el archivo `.env`

**Síntomas:**
- La ventana se cierra después de mostrar: "❌ Error en configuración de correo"
- No ves el mensaje: "✅ El servidor está escuchando en el puerto 3000"

**Solución:**
Con los cambios realizados, el servidor YA NO SE CIERRA por errores de credenciales. Sin embargo, para poder enviar correos, debes:

1. Verifica que el archivo `.env` tenga estas líneas:
   ```
   EMAIL_USER=josuejuan2019@gmail.com
   EMAIL_PASS=zobwgtkyvfaunvdi
   ```

2. Si la contraseña no funciona, genera una nueva "Contraseña de aplicación":
   - Ve a: https://myaccount.google.com/apppasswords
   - Crea una contraseña para "Correo"
   - Copia la contraseña SIN ESPACIOS en `EMAIL_PASS`

---

### Problema 2: "El puerto 3000 ya está en uso"

**Síntomas:**
- Mensaje: "EADDRINUSE: address already in use"

**Solución 1 - Cerrar proceso:**
```batch
# Ver qué proceso está usando el puerto 3000:
netstat -ano | findstr :3000

# Cerrar el proceso (reemplaza <PID> con el número que aparece):
taskkill /PID <PID> /F
```

**Solución 2 - Cambiar puerto:**
Edita el archivo `.env` y cambia:
```
PORT=3001
```

---

### Problema 3: Node.js no instalado

**Síntomas:**
- Mensaje: "Node.js no está instalado"

**Solución:**
1. Descarga Node.js desde: https://nodejs.org
2. Instala la versión LTS (recomendada)
3. Reinicia CMD después de instalar
4. Verifica con: `node --version`

---

### Problema 4: Faltan dependencias (node_modules)

**Síntomas:**
- Error: "Cannot find module 'express'"

**Solución:**
```batch
cd c:\Users\HP PAVILION\app_areas_verdes\email_server
npm install
```

---

## 📋 CHECKLIST DE VERIFICACIÓN

Marca cada paso después de verificarlo:

- [ ] Node.js está instalado (`node --version` funciona)
- [ ] El archivo `server.js` existe en la carpeta `email_server`
- [ ] El archivo `.env` existe y tiene las credenciales correctas
- [ ] Las dependencias están instaladas (carpeta `node_modules` existe)
- [ ] El puerto 3000 NO está siendo usado por otro proceso
- [ ] Al ejecutar `INICIAR_SERVIDOR.bat`, ves el mensaje: "✅ El servidor está escuchando en el puerto 3000"
- [ ] Al abrir `http://localhost:3000/api/health` en el navegador, ves la respuesta JSON
- [ ] La ventana de CMD permanece abierta y no se cierra sola

---

## 🎯 RESULTADO ESPERADO

Cuando todo está funcionando correctamente, deberías ver esto en la consola:

```
============================================
 SERVIDOR DE CORREOS - AREAS VERDES
============================================

[1/3] Verificando Node.js...
OK - Node.js instalado

[2/3] Verificando archivo server.js...
OK - server.js encontrado

[3/3] Iniciando servidor en puerto 3000...

IMPORTANTE:
- NO cierres esta ventana mientras uses la app
- Para detener el servidor presiona: Ctrl + C

============================================

--------------------------------------------
📧 VERIFICACIÓN DE CREDENCIALES DE CORREO
--------------------------------------------
✅ Servidor de correo configurado correctamente
✅ Listo para enviar correos desde: josuejuan2019@gmail.com

--------------------------------------------

============================================
🚀 SERVIDOR DE CORREOS ACTIVO
============================================
📍 URL: http://localhost:3000
📧 Endpoint principal: POST /api/send-email-base64
🏥 Health check: GET /api/health
============================================

✅ El servidor está escuchando en el puerto 3000
⏳ Esperando peticiones...

💡 Para detener el servidor presiona: Ctrl + C
```

---

## 💬 NOTA IMPORTANTE

Con los cambios realizados, el servidor ahora:

1. ✅ **NO se cierra** por errores de credenciales de correo
2. ✅ **Permanece activo** incluso si hay errores no capturados
3. ✅ **Muestra mensajes claros** de lo que está pasando
4. ✅ **Mantiene la ventana abierta** para que puedas ver los logs

Si después de estos cambios el servidor SIGUE cerrándose, por favor:

1. Copia TODO el texto que aparece en la ventana antes de que se cierre
2. Compártelo para diagnosticar el problema específico

---

## 🆘 SOPORTE ADICIONAL

Si ninguna de estas soluciones funciona, ejecuta estos comandos y comparte los resultados:

```batch
# Versión de Node.js
node --version

# Versión de npm
npm --version

# Verificar si el archivo .env existe
dir .env

# Ver qué está usando el puerto 3000
netstat -ano | findstr :3000

# Intentar iniciar el servidor directamente
node server.js
```
