#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import re
import json

# Leer el archivo main.dart
with open('lib/main.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Extraer todas las plazas
plazas = []
pattern = r"misPlazas\.add\(\{(.*?)\}\);"
matches = re.findall(pattern, content, re.DOTALL)

for match in matches:
    # Extraer cada campo
    id_match = re.search(r"'id':\s*'(\d+)'", match)
    nombre_match = re.search(r"'nombre':\s*'([^']+)'", match)
    tipo_match = re.search(r"'tipo':\s*'([^']+)'", match)
    comuna_match = re.search(r"'comuna':\s*'([^']+)'", match)
    direccion_match = re.search(r"'direccion':\s*'([^']+)'", match)
    coordenadas_match = re.search(r"LatLng\(([^,]+),\s*([^)]+)\)", match)
    estado_match = re.search(r"'estado':\s*'([^']+)'", match)
    
    if all([id_match, nombre_match, tipo_match, comuna_match, direccion_match, coordenadas_match, estado_match]):
        plaza = {
            "id": id_match.group(1),
            "nombre": nombre_match.group(1),
            "tipo": tipo_match.group(1),
            "comuna": comuna_match.group(1),
            "direccion": direccion_match.group(1),
            "latitud": float(coordenadas_match.group(1)),
            "longitud": float(coordenadas_match.group(2)),
            "estado": estado_match.group(1),
            "fichaTecnica": "PENDIENTE"
        }
        plazas.append(plaza)

# Guardar en JSON
with open('assets/plazas.json', 'w', encoding='utf-8') as f:
    json.dump(plazas, f, ensure_ascii=False, indent=2)

print(f"✅ Se extrajeron {len(plazas)} plazas al archivo assets/plazas.json")
print("Ahora puedes editar este archivo para agregar los enlaces de las fichas técnicas")
