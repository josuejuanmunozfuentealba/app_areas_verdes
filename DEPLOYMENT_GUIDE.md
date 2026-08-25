# 🚀 Guía de Despliegue - Áreas Verdes Doñihue

## 📋 Tabla de Contenidos
1. [Compilar la Aplicación Web](#1-compilar-la-aplicación-web)
2. [Despliegue en Vercel](#2-despliegue-en-vercel)
3. [Despliegue en GitHub Pages](#3-despliegue-en-github-pages)
4. [Configuración de Variables de Entorno](#4-configuración-de-variables-de-entorno)
5. [Solución de Problemas](#5-solución-de-problemas)

---

## 1. Compilar la Aplicación Web

### Requisitos Previos:
- Flutter SDK instalado (versión 3.16+)
- Git instalado

### Pasos:

```bash
# 1. Limpiar builds anteriores
flutter clean

# 2. Obtener dependencias
flutter pub get

# 3. Compilar para web (producción)
flutter build web --release --web-renderer html

# Opcional: Compilar para web con canvas renderer (mejor rendimiento en navegadores modernos)
# flutter build web --release --web-renderer canvaskit
```

**Resultado:** Los archivos compilados estarán en `build/web/`

---

## 2. Despliegue en Vercel

### 🎯 Método 1: Despliegue Automático (GitHub)

1. **Conectar Repositorio:**
   - Ve a [Vercel Dashboard](https://vercel.com/dashboard)
   - Click en "Add New Project"
   - Importa tu repositorio de GitHub
   - Selecciona `josuejuanmunozfuentealba/app_areas_verdes`

2. **Configurar Build Settings:**
   ```
   Framework Preset: Other
   Build Command: flutter build web --release
   Output Directory: build/web
   Install Command: flutter pub get
   ```

3. **Configurar Variables de Entorno** (ver sección 4)

4. **Deployar:**
   - Click en "Deploy"
   - Vercel automáticamente desplegará en cada push a `main`

### 🎯 Método 2: Despliegue Manual (CLI)

```bash
# 1. Instalar Vercel CLI
npm install -g vercel

# 2. Login en Vercel
vercel login

# 3. Compilar la app
flutter build web --release

# 4. Desplegar
vercel --prod

# Seguir las instrucciones interactivas
```

### 📁 Archivos de Configuración Vercel:

**`vercel.json`** (ya creado):
- Define las rutas y rewrites
- Configura la carpeta de salida (`build/web`)
- Maneja rutas SPA correctamente
- Protege las rutas de API

**`api/`** (ya creado):
- Contiene funciones serverless de Node.js
- `send-email.js` - Envío de correos con adjuntos
- `send-summary.js` - Envío de resúmenes
- `package.json` - Dependencias de las funciones

### ✅ Verificación:
- URL principal: `https://app-areas-verdes.vercel.app`
- Rutas funcionan sin 404
- API accesible en `/api/send-email` y `/api/send-summary`

---

## 3. Despliegue en GitHub Pages

### 🎯 Configuración Automática con GitHub Actions

1. **Archivo de Workflow** (crear `.github/workflows/deploy.yml`):

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.16.0'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Build web
      run: flutter build web --release --base-href /app_areas_verdes/
    
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./build/web
        cname: josuejuanmunozfuentealba.github.io
```

2. **Habilitar GitHub Pages:**
   - Ve a Settings > Pages en tu repositorio
   - Source: Deploy from a branch
   - Branch: `gh-pages` / `root`
   - Save

### 🎯 Despliegue Manual a GitHub Pages

```bash
# 1. Compilar con base-href
flutter build web --release --base-href /app_areas_verdes/

# 2. Navegar a build/web
cd build/web

# 3. Inicializar git (si no existe)
git init
git add .
git commit -m "Deploy to GitHub Pages"

# 4. Push a rama gh-pages
git branch -M gh-pages
git remote add origin https://github.com/josuejuanmunozfuentealba/app_areas_verdes.git
git push -f origin gh-pages
```

### 📁 Archivos de Configuración GitHub Pages:

**`.nojekyll`** (ya existe):
- Evita que GitHub Pages procese archivos con Jekyll
- Permite carpetas que empiezan con `_` (como `_redirects`)

**`web/404.html`** (ya creado):
- Maneja rutas SPA cuando se recarga la página
- Redirige automáticamente a index.html

**`web/_redirects`** (ya existe):
- Configuración de Netlify/Cloudflare Pages
- No aplica para GitHub Pages, pero no interfiere

### ✅ Verificación:
- URL: `https://josuejuanmunozfuentealba.github.io/app_areas_verdes/`
- Rutas funcionan correctamente
- Sin errores 404 en navegación SPA

---

## 4. Configuración de Variables de Entorno

### Para Vercel:

1. **Dashboard de Vercel:**
   - Ve a tu proyecto
   - Settings > Environment Variables
   - Agregar las siguientes variables:

```bash
# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=tu-email@gmail.com
SMTP_PASS=tu-contraseña-de-aplicación

# Supabase Configuration (opcional, si usas Supabase)
SUPABASE_URL=https://speneggmlqitgfjhzsry.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
```

2. **Redeploy** después de agregar variables:
   - Deployments > ... > Redeploy

### Para desarrollo local:

**`.env`** (crear en raíz del proyecto):
```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=tu-email@gmail.com
SMTP_PASS=tu-contraseña-de-aplicación
```

**⚠️ IMPORTANTE:** 
- Agregar `.env` a `.gitignore` para no subir credenciales
- Usar "Contraseñas de aplicación" de Gmail, no tu contraseña real

### Generar Contraseña de Aplicación Gmail:

1. Ve a [Google Account Security](https://myaccount.google.com/security)
2. Habilita "Verificación en 2 pasos"
3. Ve a "Contraseñas de aplicación"
4. Genera una nueva contraseña para "Correo"
5. Usa esa contraseña en `SMTP_PASS`

---

## 5. Solución de Problemas

### ❌ Error 404 en Vercel

**Problema:** Al recargar una ruta interna, aparece 404

**Solución:**
- Verifica que `vercel.json` exista y tenga las rutas correctamente configuradas
- El `"dest": "/index.html"` debe ser la última ruta
- Redeploy el proyecto

### ❌ Error 400 Bad Request

**Problema:** API no responde o da error 400

**Solución:**
- Verifica que las variables de entorno estén configuradas
- Revisa los logs en Vercel Dashboard > Deployments > Functions
- Asegúrate de que `nodemailer` esté en `api/package.json`
- Verifica que el SMTP_USER y SMTP_PASS sean correctos

### ❌ Assets no cargan (CSS, JS, imágenes)

**Problema:** La app carga pero sin estilos o funcionalidad

**Solución:**
- Verifica que `outputDirectory: build/web` esté en `vercel.json`
- Compila con: `flutter build web --release`
- No uses `--base-href` para Vercel (solo para GitHub Pages)
- Limpia cache: `flutter clean` y recompila

### ❌ CORS Error en API

**Problema:** Error de CORS al llamar a la API desde el frontend

**Solución:**
- Las funciones serverless ya tienen headers CORS configurados
- Verifica que las solicitudes sean a `/api/send-email` (sin dominio completo)
- Si usas dominio personalizado, agrega el dominio a los headers CORS

### ❌ GitHub Pages no actualiza

**Problema:** Los cambios no se reflejan en GitHub Pages

**Solución:**
```bash
# Limpiar caché local
flutter clean
flutter build web --release --base-href /app_areas_verdes/

# Forzar push a gh-pages
cd build/web
git init
git add .
git commit -m "Force update"
git branch -M gh-pages
git remote add origin https://github.com/josuejuanmunozfuentealba/app_areas_verdes.git
git push -f origin gh-pages
```

### ❌ API no funciona en GitHub Pages

**Problema:** GitHub Pages no soporta funciones serverless

**Solución:**
- GitHub Pages es solo hosting estático
- Para usar la API de envío de correos:
  1. Usa Vercel para la API (`https://app-areas-verdes.vercel.app/api/send-email`)
  2. O configura CORS en tu servidor backend separado
- Modifica el código para que apunte a la URL de Vercel:
  ```dart
  final apiUrl = 'https://app-areas-verdes.vercel.app/api/send-email';
  ```

### 🔍 Debugging

**Ver logs en Vercel:**
```bash
# CLI
vercel logs [deployment-url]

# Dashboard
Deployments > Click deployment > View Function Logs
```

**Probar API localmente:**
```bash
# Instalar dependencias
cd api
npm install

# Ejecutar función
node send-email.js

# O usar Vercel Dev
cd ..
vercel dev
```

---

## 📚 Recursos Adicionales

- [Documentación de Vercel](https://vercel.com/docs)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [GitHub Pages](https://docs.github.com/en/pages)
- [Supabase Docs](https://supabase.com/docs)

---

## ✅ Checklist de Despliegue

### Antes de Desplegar:
- [ ] Compilar: `flutter build web --release`
- [ ] Verificar que `build/web/` tiene archivos
- [ ] Revisar `vercel.json` y rutas
- [ ] Configurar variables de entorno
- [ ] Probar localmente: `flutter run -d chrome`

### Vercel:
- [ ] Proyecto conectado a GitHub
- [ ] Build command configurado
- [ ] Variables de entorno agregadas
- [ ] Deployment exitoso (verde)
- [ ] Probar URL principal
- [ ] Probar rutas internas
- [ ] Probar API endpoints

### GitHub Pages:
- [ ] Compilar con `--base-href /app_areas_verdes/`
- [ ] GitHub Actions configurado
- [ ] Rama `gh-pages` creada
- [ ] Settings > Pages configurado
- [ ] Deployment exitoso
- [ ] Probar URL de GitHub Pages

---

**Última actualización:** Agosto 2026  
**Versión:** 1.0.0  
**Soporte:** Ver SUPABASE_CONFIG.md y CHANGELOG_PWA_MOBILE.md
