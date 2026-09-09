# 🪟 INSTRUCCIONES PARA VER EL NUEVO ÍCONO EN WINDOWS PWA

## ⚠️ PROBLEMA:
Windows cachea el ícono de la PWA instalada. Aunque los archivos estén actualizados en el servidor, Windows sigue mostrando el ícono viejo (la "A" con montañas).

---

## ✅ SOLUCIÓN - SEGUIR EN ORDEN:

### **PASO 1: DESINSTALAR LA PWA ACTUAL**

1. **Busca el acceso directo** en tu escritorio: "Áreas Verdes"
2. **Click derecho** → **Desinstalar**
3. Si no aparece "Desinstalar", ve a:
   - Inicio → Configuración → Aplicaciones
   - Busca "Áreas Verdes"
   - Click → **Desinstalar**

---

### **PASO 2: LIMPIAR CACHÉ DE ÍCONOS DE WINDOWS**

Abre **PowerShell como Administrador** (Win + X → PowerShell como Admin) y ejecuta:

```powershell
# Limpiar caché de íconos de Windows
ie4uinit.exe -show
ie4uinit.exe -ClearIconCache

# Reiniciar Explorer para aplicar cambios
Stop-Process -Name explorer -Force
Start-Process explorer
```

---

### **PASO 3: LIMPIAR CACHÉ DEL NAVEGADOR**

1. Abre **Chrome/Edge**
2. Ve a: `chrome://settings/clearBrowserData` (o `edge://settings/clearBrowserData`)
3. Selecciona:
   - ✅ **Imágenes y archivos en caché**
   - ✅ **Cookies y datos de sitios**
   - Tiempo: **Desde siempre**
4. Click **Borrar datos**

O simplemente presiona: **Ctrl + Shift + Delete**

---

### **PASO 4: REINSTALAR LA PWA**

1. Abre el navegador y ve a: `https://app-areas-verdes.vercel.app/`
2. Presiona **Ctrl + Shift + R** (recarga forzada sin caché)
3. Espera 3 segundos y verifica que el **favicon** en la pestaña sea el ícono verde "AV"
4. Si el favicon es correcto, procede a instalar:
   - Click en el ícono **⊕ Instalar** en la barra de direcciones
   - O menú: **⋮ (tres puntos) → Instalar Áreas Verdes**
5. Acepta la instalación

---

### **PASO 5: VERIFICAR EL RESULTADO**

- ✅ El ícono en el escritorio debe ser: **verde con "AV" + "I.M. Doñihue"**
- ❌ Si sigue siendo la "A" con montañas, repite el **PASO 2** (limpiar caché de íconos)

---

## 🔧 ALTERNATIVA: REINSTALAR DESDE EDGE (SI USA CHROME)

Si usas Chrome y no funciona, prueba con Edge:

1. Abre **Microsoft Edge**
2. Ve a: `https://app-areas-verdes.vercel.app/`
3. **Ctrl + Shift + R**
4. Instala la PWA desde Edge

Edge usa una caché diferente y puede que funcione.

---

## 📞 SI AÚN NO FUNCIONA:

Envíame una captura de:
1. El favicon en la pestaña del navegador (antes de instalar)
2. El ícono en el escritorio (después de instalar)

Eso me dirá si el problema es del servidor o de Windows.

---

## ✅ ARCHIVOS ACTUALIZADOS EN EL SERVIDOR:

- ✅ `web/favicon.ico` → Ícono verde "AV"
- ✅ `web/favicon.png` → Ícono verde "AV"
- ✅ `web/icons/Icon-*.png` → Íconos verdes "AV"
- ✅ `web/assets/logowebactualizado.png` → Ícono verde "AV"
- ✅ `web/manifest.json` → Referencias correctas
- ✅ `web/index.html` → Referencias a favicon.ico

**Todos los archivos están actualizados. El problema es la caché de Windows.**
