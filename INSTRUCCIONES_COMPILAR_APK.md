# 📱 Cómo compilar y probar la app en tu móvil Android

## ⚡ Opción rápida: Compilar APK

```bash
flutter build apk --release
```

📂 El archivo APK estará en:
```
build\app\outputs\flutter-apk\app-release.apk
```

---

## 📲 Instalar en tu móvil:

### **Método 1: USB (más rápido)**
1. Conecta tu teléfono por USB
2. Activa "Depuración USB" en Ajustes → Opciones de desarrollador
3. Ejecuta:
```bash
flutter install
```

### **Método 2: Transferir APK**
1. Copia `app-release.apk` a tu teléfono (WhatsApp, email, USB)
2. Abre el archivo en el móvil
3. Acepta "Instalar desde fuentes desconocidas"

---

## 🎯 ¿Qué funcionará en la app?

✅ **Cámara:** Modal con "Tomar foto" o "Galería"  
✅ **Autocorrector:** Sugerencias en móvil  
✅ **Autoguardado:** Cada 30 segundos  
✅ **Enter:** Saltos de línea en observaciones  
✅ **Internet lento:** Imágenes optimizadas  

---

## ⚠️ **En la WEB NO funcionará:**

❌ Cámara (solo galería)  
❌ Autocorrector móvil (solo spellcheck navegador)  

---

## 🔧 Comandos útiles:

```bash
# Ver dispositivos conectados
flutter devices

# Instalar directamente en móvil conectado
flutter install

# Compilar APK optimizado (más pequeño)
flutter build apk --split-per-abi

# Ver logs en tiempo real
flutter logs
```
