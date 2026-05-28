with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', encoding='utf-8') as f:
    text = f.read()

# Find and remove _abrirRutaNavegacion function
import re
pattern = r'\n\n  Future<void> _abrirRutaNavegacion\(LatLng destino\) async \{.*?\n  \}'
text = re.sub(pattern, '', text, flags=re.DOTALL)

with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print('Done')
