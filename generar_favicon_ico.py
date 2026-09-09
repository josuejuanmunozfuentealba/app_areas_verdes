#!/usr/bin/env python3
"""
Generador de favicon.ico para Windows Desktop
Convierte el PNG generado a formato ICO con múltiples resoluciones
"""

from PIL import Image
import os

def generar_favicon_ico():
    """Convierte el favicon.png a favicon.ico con múltiples tamaños"""
    
    print("🖼️ Generador de favicon.ico para Windows Desktop")
    print("=" * 50)
    
    # Ruta del PNG base
    png_path = os.path.join('web', 'favicon.png')
    ico_path = os.path.join('web', 'favicon.ico')
    
    if not os.path.exists(png_path):
        print(f"❌ ERROR: No se encontró {png_path}")
        print("   Ejecuta primero: python generar_iconos.py")
        return
    
    # Cargar imagen PNG base
    img = Image.open(png_path)
    
    # Generar múltiples tamaños para el ICO (estándar Windows)
    sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    
    print(f"\n📂 Generando: {ico_path}")
    print("-" * 50)
    
    # Crear íconos en diferentes tamaños
    icon_imgs = []
    for size in sizes:
        resized = img.resize(size, Image.Resampling.LANCZOS)
        icon_imgs.append(resized)
        print(f"   ✅ Tamaño: {size[0]}x{size[1]}")
    
    # Guardar como ICO con múltiples resoluciones
    icon_imgs[0].save(
        ico_path,
        format='ICO',
        sizes=sizes,
        append_images=icon_imgs[1:]
    )
    
    print("-" * 50)
    print(f"✅ favicon.ico generado exitosamente!")
    print(f"\n📍 Ubicación: {ico_path}")
    print("\n🌐 AHORA EL ÍCONO SE VERÁ EN:")
    print("   • Pestaña del navegador (favicon)")
    print("   • Acceso directo en Escritorio de Windows")
    print("   • PWA instalada en Windows")
    print("\n📋 Próximo paso:")
    print("   1. git add web/favicon.ico")
    print("   2. git commit -m 'Add favicon.ico for Windows'")
    print("   3. git push origin main")
    print("   4. Reinstalar PWA desde el navegador")

if __name__ == '__main__':
    try:
        generar_favicon_ico()
    except ImportError:
        print("\n❌ ERROR: PIL (Pillow) no está instalado")
        print("\n📦 Instálalo con:")
        print("   pip install Pillow")
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
