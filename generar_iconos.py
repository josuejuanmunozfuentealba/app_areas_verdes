#!/usr/bin/env python3
"""
Generador automático de íconos - Áreas Verdes Doñihue
Genera íconos con diseño: AV + I.M. Doñihue sobre fondo verde
"""

from PIL import Image, ImageDraw, ImageFont
import os

# Configuración de diseño
FONDO_VERDE = '#2E7D32'
TEXTO_BLANCO = '#FFFFFF'

def generar_icono(size, filename):
    """Genera un ícono con el diseño AV - I.M. Doñihue"""
    
    # Crear imagen con fondo verde
    img = Image.new('RGB', (size, size), FONDO_VERDE)
    draw = ImageDraw.Draw(img)
    
    # Calcular tamaños de fuente proporcionalmente
    main_font_size = int(size * 0.35)  # 35% del tamaño para "AV"
    sub_font_size = int(size * 0.10)   # 10% del tamaño para "I.M. Doñihue"
    
    try:
        # Intentar usar fuente del sistema (bold)
        try:
            main_font = ImageFont.truetype("arialbd.ttf", main_font_size)
        except:
            try:
                main_font = ImageFont.truetype("Arial Bold.ttf", main_font_size)
            except:
                main_font = ImageFont.truetype("arial.ttf", main_font_size)
        
        try:
            sub_font = ImageFont.truetype("arial.ttf", sub_font_size)
        except:
            sub_font = ImageFont.load_default()
    except:
        # Fallback a fuente por defecto
        main_font = ImageFont.load_default()
        sub_font = ImageFont.load_default()
    
    # Dibujar "AV" (texto principal)
    main_text = "AV"
    main_bbox = draw.textbbox((0, 0), main_text, font=main_font)
    main_width = main_bbox[2] - main_bbox[0]
    main_height = main_bbox[3] - main_bbox[1]
    main_x = (size - main_width) // 2
    main_y = int(size * 0.42) - main_height // 2
    
    draw.text((main_x, main_y), main_text, fill=TEXTO_BLANCO, font=main_font)
    
    # Dibujar "I.M. Doñihue" (texto inferior)
    sub_text = "I.M. Doñihue"
    sub_bbox = draw.textbbox((0, 0), sub_text, font=sub_font)
    sub_width = sub_bbox[2] - sub_bbox[0]
    sub_height = sub_bbox[3] - sub_bbox[1]
    sub_x = (size - sub_width) // 2
    sub_y = int(size * 0.75) - sub_height // 2
    
    draw.text((sub_x, sub_y), sub_text, fill=TEXTO_BLANCO, font=sub_font)
    
    # Guardar imagen
    img.save(filename, 'PNG')
    print(f"✅ Generado: {filename} ({size}x{size})")

def main():
    print("🎨 Generador de Íconos - Áreas Verdes Doñihue")
    print("=" * 50)
    
    # Crear carpeta web/icons si no existe
    icons_dir = os.path.join('web', 'icons')
    os.makedirs(icons_dir, exist_ok=True)
    
    # Generar los 4 íconos
    iconos = [
        (192, 'Icon-192.png'),
        (512, 'Icon-512.png'),
        (192, 'Icon-maskable-192.png'),
        (512, 'Icon-maskable-512.png'),
    ]
    
    print(f"\n📂 Generando íconos en: {icons_dir}/")
    print("-" * 50)
    
    for size, filename in iconos:
        filepath = os.path.join(icons_dir, filename)
        generar_icono(size, filepath)
    
    # También generar favicon
    favicon_path = os.path.join('web', 'favicon.png')
    generar_icono(192, favicon_path)
    print(f"✅ Generado: {favicon_path} (192x192)")
    
    print("-" * 50)
    print("\n✅ ¡TODOS LOS ÍCONOS GENERADOS EXITOSAMENTE!")
    print("\n📋 Próximos pasos:")
    print("   1. Ejecuta: flutter pub run flutter_launcher_icons")
    print("   2. Haz commit y push")
    print("   3. Los íconos se verán en web y móvil")
    print("\n🎨 Diseño aplicado:")
    print("   - Fondo verde: #2E7D32")
    print("   - Texto: AV + I.M. Doñihue (blanco)")

if __name__ == '__main__':
    try:
        main()
    except ImportError:
        print("\n❌ ERROR: PIL (Pillow) no está instalado")
        print("\n📦 Instálalo con:")
        print("   pip install Pillow")
        print("\nO usa el archivo generar_iconos.html en tu navegador")
    except Exception as e:
        print(f"\n❌ ERROR: {e}")
        print("\nUsa el archivo generar_iconos.html como alternativa")
