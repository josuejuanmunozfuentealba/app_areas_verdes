#!/usr/bin/env python3
"""
Script para subir PDFs manualmente a Supabase
Recupera catastros del primer día que no se guardaron en el historial
"""

import os
import sys
from datetime import datetime
from supabase import create_client, Client

# ============================================================================
# CONFIGURACIÓN
# ============================================================================

SUPABASE_URL = "https://speneggmlqitgfjhzsry.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg"

# Carpeta donde están los PDFs
CARPETA_PDFS = "./pdfs_pendientes"

# ============================================================================
# DATOS DE LOS CATASTROS
# ============================================================================

# Lista de catastros a subir
# EDITA ESTO con los datos de cada plaza
CATASTROS = [
    {
        "plaza_id": "15",
        "nombre_plaza": "Plaza 21 de Mayo",
        "inspector": "Josué Muñoz Fuentealba",
        "fecha_hora_registro": "2026-08-28T13:05:20",  # Fecha del correo
        "archivo_pdf": "catastro_plaza_21_mayo.pdf",  # Nombre del PDF
        "estado_general": "Regular",  # Opcional
    },
    {
        "plaza_id": "16",
        "nombre_plaza": "Plaza 21 de Mayo interior",
        "inspector": "Josué Muñoz Fuentealba",
        "fecha_hora_registro": "2026-08-28T14:00:00",
        "archivo_pdf": "catastro_plaza_21_mayo_interior.pdf",
        "estado_general": "Regular",
    },
    # Agrega aquí las otras 3 plazas con sus datos
    # {
    #     "plaza_id": "XX",
    #     "nombre_plaza": "Nombre de la plaza",
    #     "inspector": "Josué Muñoz Fuentealba",
    #     "fecha_hora_registro": "2026-08-28T15:00:00",
    #     "archivo_pdf": "nombre_del_pdf.pdf",
    #     "estado_general": "Regular",
    # },
]

# ============================================================================
# FUNCIONES
# ============================================================================

def subir_catastro(supabase: Client, catastro: dict):
    """Sube un catastro a Supabase"""
    
    print(f"\n{'='*60}")
    print(f"📋 Subiendo: {catastro['nombre_plaza']}")
    print(f"{'='*60}")
    
    # 1. Verificar que el PDF existe
    ruta_pdf = os.path.join(CARPETA_PDFS, catastro['archivo_pdf'])
    if not os.path.exists(ruta_pdf):
        print(f"❌ ERROR: No se encuentra el PDF: {ruta_pdf}")
        return False
    
    print(f"✅ PDF encontrado: {ruta_pdf}")
    tamano_kb = os.path.getsize(ruta_pdf) / 1024
    print(f"📦 Tamaño: {tamano_kb:.1f} KB")
    
    # 2. Subir PDF a bucket de Supabase
    print(f"☁️  Subiendo PDF a Supabase Storage...")
    
    timestamp = int(datetime.now().timestamp() * 1000)
    nombre_archivo_storage = f"catastro_{catastro['plaza_id']}_{timestamp}.pdf"
    
    try:
        with open(ruta_pdf, 'rb') as f:
            pdf_bytes = f.read()
        
        supabase.storage.from_("reportes-catastro").upload(
            path=nombre_archivo_storage,
            file=pdf_bytes,
            file_options={"content-type": "application/pdf"}
        )
        
        # Obtener URL pública
        pdf_url = supabase.storage.from_("reportes-catastro").get_public_url(nombre_archivo_storage)
        print(f"✅ PDF subido: {pdf_url}")
        
    except Exception as e:
        print(f"❌ Error subiendo PDF: {e}")
        return False
    
    # 3. Insertar registro en tabla catastros_inmuebles
    print(f"💾 Insertando registro en base de datos...")
    
    datos = {
        "plaza_id": catastro["plaza_id"],
        "nombre_plaza": catastro["nombre_plaza"],
        "inspector": catastro["inspector"],
        "fecha_hora_registro": catastro["fecha_hora_registro"],
        "estado_general": catastro.get("estado_general", "Regular"),
        "pdf_url": pdf_url,
        "word_url": None,  # No hay Word para catastros antiguos
        "evaluaciones": {},  # Vacío (los datos están en el PDF)
        "observaciones": {},  # Vacío
    }
    
    try:
        resultado = supabase.table("catastros_inmuebles").insert(datos).execute()
        print(f"✅ Registro insertado en Supabase")
        print(f"🆔 ID: {resultado.data[0]['id']}")
        return True
        
    except Exception as e:
        print(f"❌ Error insertando registro: {e}")
        return False


def main():
    print("\n" + "="*60)
    print("🚀 SUBIR CATASTROS PENDIENTES A SUPABASE")
    print("="*60)
    
    # Verificar que existe la carpeta de PDFs
    if not os.path.exists(CARPETA_PDFS):
        print(f"\n❌ ERROR: No existe la carpeta '{CARPETA_PDFS}'")
        print(f"\n📁 Crea la carpeta y pon los PDFs ahí:")
        print(f"   1. Crea carpeta: {CARPETA_PDFS}")
        print(f"   2. Copia los 5 PDFs del primer día")
        print(f"   3. Edita CATASTROS en este script con los datos de cada plaza")
        print(f"   4. Ejecuta: python subir_pdfs_manualmente.py")
        return
    
    print(f"\n📂 Carpeta PDFs: {CARPETA_PDFS}")
    print(f"📊 Catastros a subir: {len(CATASTROS)}")
    
    # Conectar a Supabase
    print(f"\n🔌 Conectando a Supabase...")
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    print(f"✅ Conectado")
    
    # Subir cada catastro
    exitosos = 0
    fallidos = 0
    
    for catastro in CATASTROS:
        if subir_catastro(supabase, catastro):
            exitosos += 1
        else:
            fallidos += 1
    
    # Resumen
    print(f"\n{'='*60}")
    print(f"✅ RESUMEN")
    print(f"{'='*60}")
    print(f"✅ Exitosos: {exitosos}")
    print(f"❌ Fallidos: {fallidos}")
    print(f"📊 Total: {len(CATASTROS)}")
    print(f"\n🎉 Ahora verifica el historial en la app")
    print()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Cancelado por el usuario")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        sys.exit(1)
