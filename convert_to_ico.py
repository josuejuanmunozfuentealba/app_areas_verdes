from PIL import Image
import sys

# Convertir PNG a ICO
try:
    img = Image.open('assets/logowebactualizado.png')
    # Redimensionar a tamaños estándar de icono
    icon_sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)]
    img.save('assets/iconoescri.ico', format='ICO', sizes=icon_sizes)
    print("Icono creado exitosamente: assets/iconoescri.ico")
except Exception as e:
    print(f"Error: {e}")
    sys.exit(1)
