with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', encoding='utf-8') as f:
    text = f.read()

# Find initState start
start_marker = '  void initState() {\n    super.initState();\n'
end_marker = '\n  }\n\n  // Mapa de fichas'

start_idx = text.find(start_marker)
end_idx = text.find(end_marker)

if start_idx != -1 and end_idx != -1:
    new_text = text[:start_idx + len(start_marker)] + '\n    // Las ubicaciones se agregarán aquí\n' + text[end_idx:]
    with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', 'w', encoding='utf-8') as f:
        f.write(new_text)
    print('Done - initState limpiado')
else:
    print(f'start_idx={start_idx}, end_idx={end_idx}')
    # Show what's around initState
    idx = text.find('initState')
    print(repr(text[idx:idx+200]))
