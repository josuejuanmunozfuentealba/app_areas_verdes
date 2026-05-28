from PIL import Image

img = Image.open(r'C:\Users\HP PAVILION\app_areas_verdes\assets\logo.png').convert('RGBA')

# Redimensiona a 256x256 con alta calidad
img = img.resize((256, 256), Image.LANCZOS)

img.save(
    r'C:\Users\HP PAVILION\app_areas_verdes\assets\icononuevo.ico',
    format='ICO',
    sizes=[(256,256),(128,128),(64,64),(48,48),(32,32),(16,16)]
)
print('Done')
