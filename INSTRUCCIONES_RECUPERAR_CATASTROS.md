# 📋 Recuperar Catastros del Primer Día

**Problema:** 5 catastros del primer día se enviaron por correo pero no quedaron en el historial de la app.

**Solución:** Subirlos manualmente a Supabase usando script Python.

---

## 🎯 **PASOS:**

### **1. Instalar dependencia Python**

```bash
pip install supabase
```

---

### **2. Crear carpeta para los PDFs**

```bash
mkdir pdfs_pendientes
```

---

### **3. Conseguir los PDFs**

**Opción A: Desde el correo del jefe**
1. Pídele que te reenvíe los 5 correos con los PDFs adjuntos
2. Descarga cada PDF
3. Cópialos a la carpeta `pdfs_pendientes/`

**Opción B: Desde el móvil**
1. Ve a la carpeta Descargas del teléfono
2. Busca los PDFs de esas 5 plazas
3. Envíatelos por WhatsApp/Email
4. Descárgalos en PC
5. Cópialos a `pdfs_pendientes/`

---

### **4. Identificar las plazas**

Necesitas saber de cada catastro:
- **Plaza ID** (ej: 15, 16, 17, etc.)
- **Nombre plaza** (ej: "Plaza 21 de Mayo")
- **Fecha y hora** del correo (ej: "2026-08-28T13:05:20")
- **Nombre del archivo PDF**

**Para saber el Plaza ID:**
- Revisa el asunto del correo enviado al jefe
- O revisa dentro del PDF (debe aparecer el nombre)
- Luego busca en `lib/main.dart` el ID correspondiente

---

### **5. Editar el script**

Abre `subir_pdfs_manualmente.py` y edita la sección `CATASTROS`:

```python
CATASTROS = [
    {
        "plaza_id": "15",
        "nombre_plaza": "Plaza 21 de Mayo",
        "inspector": "Josué Muñoz Fuentealba",
        "fecha_hora_registro": "2026-08-28T13:05:20",  # Fecha del correo
        "archivo_pdf": "catastro_plaza_21_mayo.pdf",
        "estado_general": "Regular",
    },
    {
        "plaza_id": "16",
        "nombre_plaza": "Plaza 21 de Mayo interior",
        "inspector": "Josué Muñoz Fuentealba",
        "fecha_hora_registro": "2026-08-28T14:00:00",
        "archivo_pdf": "catastro_plaza_21_mayo_interior.pdf",
        "estado_general": "Regular",
    },
    # Agrega las otras 3 plazas aquí
    {
        "plaza_id": "XX",  # ← Cambia esto
        "nombre_plaza": "Nombre de la tercera plaza",  # ← Cambia esto
        "inspector": "Josué Muñoz Fuentealba",
        "fecha_hora_registro": "2026-08-28T15:00:00",  # ← Cambia esto
        "archivo_pdf": "nombre_del_pdf_3.pdf",  # ← Cambia esto
        "estado_general": "Regular",
    },
    # ... plaza 4
    # ... plaza 5
]
```

---

### **6. Ejecutar el script**

```bash
python subir_pdfs_manualmente.py
```

**Salida esperada:**
```
============================================================
🚀 SUBIR CATASTROS PENDIENTES A SUPABASE
============================================================

📂 Carpeta PDFs: ./pdfs_pendientes
📊 Catastros a subir: 5

🔌 Conectando a Supabase...
✅ Conectado

============================================================
📋 Subiendo: Plaza 21 de Mayo
============================================================
✅ PDF encontrado: ./pdfs_pendientes/catastro_plaza_21_mayo.pdf
📦 Tamaño: 350.2 KB
☁️  Subiendo PDF a Supabase Storage...
✅ PDF subido: https://speneggmlqitgfjhzsry.supabase.co/...
💾 Insertando registro en base de datos...
✅ Registro insertado en Supabase
🆔 ID: a1b2c3d4-...

... (repite para cada plaza)

============================================================
✅ RESUMEN
============================================================
✅ Exitosos: 5
❌ Fallidos: 0
📊 Total: 5

🎉 Ahora verifica el historial en la app
```

---

### **7. Verificar en la app**

1. Abre la app en móvil/PC
2. Ve al historial de cada plaza
3. ✅ Deben aparecer los catastros del primer día

---

## 🔍 **ENCONTRAR LOS IDS DE LAS PLAZAS:**

Si no recuerdas los IDs, búscalos en el código:

<function_calls>
<invoke name="execute_pwsh">
<parameter name="command">Select-String -Path "lib/main.dart" -Pattern "'id'.*'nombre'.*" -Context 0,1 | Select-Object -First 30