# 🔧 Guía de Solución: Error "Servidor no conectado"

## 📋 Problema
La aplicación muestra el error: **"Servidor no disponible - El servidor Python no está conectado en http://localhost:3000"**

## ✅ Solución Paso a Paso

### **Paso 1: Verificar el Diagnóstico**
1. Abre CMD en la carpeta del proyecto: `c:\Users\HP PAVILION\app_areas_verdes`
2. Ejecuta: `diagnosticar_servidor.bat`
3. Revisa los resultados y sigue las instrucciones

### **Paso 2: Iniciar el Servidor**

#### Opción A: Usando el Script Automatizado (RECOMENDADO)
1. Haz doble clic en: **`iniciar_servidor.bat`**
2. Verás una ventana CMD con el servidor corriendo
3. **NO CIERRES ESTA VENTANA** mientras uses la aplicación
4. Deberías ver:
   ```
   ============================================
   SERVIDOR PYTHON - AREAS VERDES
   ============================================
   Servidor corriendo en http://localhost:3000
   ```

#### Opción B: Manualmente desde CMD
1. Abre CMD en la carpeta del proyecto
2. Ejecuta: `python servidor.py`
3. Mantén la ventana abierta

### **Paso 3: Verificar la Conexión**

#### Método 1: Navegador
1. Abre tu navegador
2. Ve a: http://localhost:3000/api/health
3. Deberías ver: `{"status": "ok", "message": "Servidor Python funcionando correctamente"}`

#### Método 2: CMD
```cmd
curl http://localhost:3000/api/health
```

### **Paso 4: Probar la Aplicación**
1. Abre la aplicación Flutter
2. Llena el formulario de inspección
3. Haz clic en "Enviar Reporte"
4. Ahora debería funcionar ✅

---

## 🚨 Problemas Comunes y Soluciones

### Error: "Puerto 3000 ya está en uso"
**Causa**: Otro proceso está usando el puerto 3000

**Solución**:
```cmd
# Ver qué proceso usa el puerto
netstat -ano | findstr ":3000"

# Matar el proceso (reemplaza PID con el número que viste)
taskkill /PID <PID> /F
```

### Error: "Python no está instalado"
**Causa**: Python no está en el PATH o no está instalado

**Solución**:
1. Descarga Python desde: https://www.python.org/downloads/
2. Durante la instalación, marca: **"Add Python to PATH"**
3. Reinicia CMD y prueba de nuevo

### Error: "No se encuentra servidor.py"
**Causa**: Estás en el directorio incorrecto

**Solución**:
```cmd
# Navega a la carpeta correcta
cd "c:\Users\HP PAVILION\app_areas_verdes"

# Verifica que el archivo existe
dir servidor.py
```

### Error: "No se encuentra build/web"
**Causa**: No has construido la versión web de Flutter

**Solución**:
```cmd
flutter build web
```

---

## 📊 Flujo de Trabajo Correcto

```
1. Iniciar Servidor
   ↓
2. Mantener CMD Abierta
   ↓
3. Abrir Aplicación Flutter
   ↓
4. Usar Aplicación
   ↓
5. Cerrar Servidor (Ctrl+C) cuando termines
```

---

## 🔍 Verificación Rápida

Ejecuta estos comandos para verificar todo:

```cmd
# 1. Verificar Python
python --version

# 2. Verificar servidor.py existe
dir servidor.py

# 3. Iniciar servidor
python servidor.py

# En otra ventana CMD:
# 4. Verificar conexión
curl http://localhost:3000/api/health
```

---

## 📝 Notas Importantes

1. **El servidor debe estar corriendo ANTES de usar "Enviar Reporte"**
2. **Los botones PDF y Word NO necesitan servidor** (funcionan sin servidor)
3. **Solo "Enviar Reporte" requiere el servidor Python**
4. **Mantén la ventana CMD abierta mientras uses la app**

---

## 🎯 Endpoints Disponibles

Cuando el servidor está corriendo:

| Endpoint | Método | Descripción |
|----------|--------|-------------|
| `/api/health` | GET | Verificar estado del servidor |
| `/api/historial` | GET | Obtener historial de inspecciones |
| `/api/historial` | POST | Guardar inspección |
| `/api/send-email` | POST | Enviar correo de notificación |

---

## ⚡ Solución Rápida (TL;DR)

```cmd
# 1. Abre CMD en la carpeta del proyecto
cd "c:\Users\HP PAVILION\app_areas_verdes"

# 2. Inicia el servidor
iniciar_servidor.bat

# 3. Verifica en navegador
http://localhost:3000/api/health

# 4. Usa la aplicación
```

---

## 📞 Soporte

Si el problema persiste después de seguir esta guía:

1. Ejecuta: `diagnosticar_servidor.bat`
2. Captura el error exacto que muestra
3. Verifica los logs en: `servidor_log.txt`
