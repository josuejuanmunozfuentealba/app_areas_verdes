with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', encoding='utf-8') as f:
    text = f.read()

# Find where misPlazas.add blocks were incorrectly inserted
# They should be inside _PantallaMapaState.initState, not _PantallaBienvenidaState

# Find the marker where plazas were inserted (wrong location)
wrong_marker_start = "    super.initState();\n\n    misPlazas.add({"
correct_marker = "    super.initState();\n\n    _cargarHistorial();"

# Check if plazas are in wrong place (inside PantallaBienvenida)
bienvenida_start = text.find("class _PantallaBienvenidaState")
mapa_start = text.find("class _PantallaMapaState")

if bienvenida_start != -1 and mapa_start != -1:
    bienvenida_section = text[bienvenida_start:mapa_start]
    
    if "misPlazas.add" in bienvenida_section:
        print("Found misPlazas in wrong location - fixing...")
        
        # Find the initState in bienvenida section
        init_start = bienvenida_section.find("super.initState();")
        
        # Find where the plazas end (look for the closing of initState)
        # The plazas end before the next method definition
        plazas_start = bienvenida_section.find("    misPlazas.add({", init_start)
        
        # Find end of all plaza blocks - look for the pattern after last plaza
        # Find "  Future<void>" or "  // Mapa" after the plazas
        after_plazas = bienvenida_section.find("\n\n  Future<void> _abrirFichaTecnica", plazas_start)
        if after_plazas == -1:
            after_plazas = bienvenida_section.find("\n\n  // Mapa de fichas", plazas_start)
        if after_plazas == -1:
            after_plazas = bienvenida_section.find("\n\n  Widget _construirFilaInfo", plazas_start)
        
        if after_plazas != -1:
            # Extract the plaza blocks
            plaza_blocks = bienvenida_section[plazas_start:after_plazas]
            
            # Remove plazas from bienvenida section
            new_bienvenida = bienvenida_section[:plazas_start] + bienvenida_section[after_plazas:]
            
            # Find correct location in mapa section
            mapa_section = text[mapa_start:]
            correct_insert = mapa_section.find("super.initState();\n\n    // Las ubicaciones")
            if correct_insert == -1:
                correct_insert = mapa_section.find("super.initState();")
                if correct_insert != -1:
                    correct_insert += len("super.initState();")
                    new_mapa = mapa_section[:correct_insert] + "\n\n" + plaza_blocks + mapa_section[correct_insert:]
                    text = text[:bienvenida_start] + new_bienvenida + new_mapa
                    with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', 'w', encoding='utf-8') as f:
                        f.write(text)
                    print("Fixed!")
                else:
                    print("Could not find initState in mapa section")
            else:
                end_marker = mapa_section.find("\n\n  Future<void>", correct_insert)
                new_mapa = mapa_section[:correct_insert + len("super.initState();")] + "\n\n" + plaza_blocks + mapa_section[correct_insert + len("super.initState();"):]
                text = text[:bienvenida_start] + new_bienvenida + new_mapa
                with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', 'w', encoding='utf-8') as f:
                    f.write(text)
                print("Fixed!")
        else:
            print(f"Could not find end of plazas. plazas_start={plazas_start}")
    else:
        print("misPlazas not in bienvenida section - checking mapa section")
        mapa_section = text[mapa_start:]
        if "misPlazas.add" in mapa_section:
            print("misPlazas already in correct location")
        else:
            print("misPlazas not found anywhere")
else:
    print(f"bienvenida_start={bienvenida_start}, mapa_start={mapa_start}")
