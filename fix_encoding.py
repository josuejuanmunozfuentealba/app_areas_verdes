with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', encoding='utf-8') as f:
    text = f.read()

text = text.replace('C\u00c1\u00abMO', 'CÓMO')
text = text.replace('INSPECCI\u00c1\u00abN', 'INSPECCIÓN')
text = text.replace('MANTENCI\u00c1\u00abN', 'MANTENCIÓN')
text = text.replace('mantenci\u00c1\u00abn', 'mantención')
text = text.replace('inspecci\u00c1\u00abn', 'inspección')

with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', 'w', encoding='utf-8') as f:
    f.write(text)

# Verify
with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', encoding='utf-8') as f:
    t = f.read()
print('CÓMO found:', 'CÓMO' in t)
print('INSPECCIÓN found:', 'INSPECCIÓN' in t)
print('MANTENCIÓN found:', 'MANTENCIÓN' in t)
