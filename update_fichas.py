#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Leer el archivo
with open('lib/main.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Nuevo mapa de fichas técnicas
nuevo_mapa = """  // Mapa de fichas técnicas por ID — Enlaces de Google Drive

  final Map<String, String> fichasTecnicas = {
    '1': 'https://drive.google.com/file/d/1qZHwXxRXfEVzNonJo4d7uTcBE6__gDMk/view?usp=drivesdk',
    '2': 'https://drive.google.com/file/d/1lP3GewzXLU-MqS8-fTfLJu-AOVlTb04f/view?usp=drivesdk',
    '3': 'https://drive.google.com/file/d/1ayS6q6l-MclUUxbxmRuODq8wIfNA_NWV/view?usp=drivesdk',
    '4': 'https://drive.google.com/file/d/1HLnj5u_c2nf7Uh491cCBlqaqeE2GxK20/view?usp=drivesdk',
    '5': 'https://drive.google.com/file/d/1wzBwZCQT1wTewT3QTZEpaPT7cmBMf8G1/view?usp=drivesdk',
    '6': 'https://drive.google.com/file/d/17nt6iP0TcMmwtZVBoSD3yo7TSc4Jd6Kf/view?usp=drivesdk',
    '7': 'https://drive.google.com/file/d/1Sxa43S5Tc_qN6wzsZFf-1Db_dVA-GvAE/view?usp=drivesdk',
    '8': 'https://drive.google.com/file/d/1UexJd8V_tYE505lYPiIEXhHxUvSCF_up/view?usp=drivesdk',
    '9': 'https://drive.google.com/file/d/1qMt9xxH4uZUcS42Yy6zO5FZj5CzV_Nbx/view?usp=drivesdk',
    '10': 'https://drive.google.com/file/d/1FCgaWIqllZLZigYPb7xX_Z1n2cjF5I-4/view?usp=drivesdk',
    '11': 'https://drive.google.com/file/d/1oL7oPjtuVug-hkk-9A9xTRk4zvKSG4H1/view?usp=drivesdk',
    '12': 'https://drive.google.com/file/d/1cQz1U2pUgXWVGDcLyIj-iT9rv20HGEqw/view?usp=drivesdk',
    '13': 'https://drive.google.com/file/d/1cCuFlbI7wcXKDsZ475eDgM3n6N_OQ-8a/view?usp=drivesdk',
    '14': 'https://drive.google.com/file/d/1PjYhhZM6O2BME5MKmF351d-8gXCQAY4A/view?usp=drivesdk',
    '15': 'https://drive.google.com/file/d/17WsaNdi6Ue3nEG9GrbT85KSkTvwMlcJo/view?usp=drivesdk',
    '16': 'https://drive.google.com/file/d/1ExjF8OVraPjAJ2A5RTi6xROxTGHTqd6-/view?usp=drivesdk',
    '17': 'https://drive.google.com/file/d/1_maqvTB-Myx8HZi5xYu9o13F0JFm_sff/view?usp=drivesdk',
    '18': 'https://drive.google.com/file/d/1mssmMZ82iwELu_Cz58F4GqlLuSyxblq6/view?usp=drivesdk',
    '19': 'https://drive.google.com/file/d/1-ikkDF-q30DEhEdHHtYLQatUjmndhgRT/view?usp=drivesdk',
    '20': 'https://drive.google.com/file/d/1q429dq-O6PK8HmZA6Ph7F6Q6OgKMOBeQ/view?usp=drivesdk',
    '21': 'https://drive.google.com/file/d/11SL4SZKGBw91Na0gvtIlfxxif93co6al/view?usp=drivesdk',
    '22': 'https://drive.google.com/file/d/1jO4p3OdmO9DZAjjY-rq6DeTkpT28tQvi/view?usp=drivesdk',
    '23': 'https://drive.google.com/file/d/1yqa1sR8lNU829Q6muAcTH3tOE-LhLnAX/view?usp=drivesdk',
    '24': 'https://drive.google.com/file/d/1iCTt4FaBXN950MAGw2ZtTjh4GULZP43x/view?usp=drivesdk',
    '25': 'https://drive.google.com/file/d/1ibl7F8x8ZU7zUuh9ba5zXBqThhMeJuXi/view?usp=drivesdk',
    '26': 'https://drive.google.com/file/d/1WpmEJLGbN-yChSHEyQCtKp2FkMg9HGPy/view?usp=drivesdk',
    '27': 'https://drive.google.com/file/d/131VBq1IF8v4tyWXuU2HEG3sXrqK0IyYu/view?usp=drivesdk',
    '28': 'https://drive.google.com/file/d/1YBGqde-1oZLpP9OMAtbq4G-9nnEZe6qG/view?usp=drivesdk',
    '29': 'https://drive.google.com/file/d/1wB2dOjUYKNOgF3Q1zVtIcPSa5Abem5tG/view?usp=drivesdk',
    '30': 'https://drive.google.com/file/d/1a4na9cJlaznZuzLI359jcAaC3zWUMPBq/view?usp=drivesdk',
    '31': 'https://drive.google.com/file/d/1S1WcIL51zkOHDN-jB3lE5RfStUuHvmu3/view?usp=drivesdk',
    '32': 'https://drive.google.com/file/d/1Oayu3yZjsx-7Wb2Qy2jD54lCj5eHf7jW/view?usp=drivesdk',
    '33': 'https://drive.google.com/file/d/1iH-kX_juMwKpO7fCdUR3Q6h8RjqRLxbg/view?usp=drivesdk',
    '34': 'https://drive.google.com/file/d/1C3ZgMKU9hXCP2F1xrAhRAvmi1bI6-pe_/view?usp=drivesdk',
    '35': 'https://drive.google.com/file/d/124Cd10R4gkqeTh4F0aCyshOdHPbUnk6l/view?usp=drivesdk',
    '36': 'https://drive.google.com/file/d/1JOIb7T7sfCzHz6SNRO0IGjNVaF2ZTimC/view?usp=drivesdk',
    '37': 'https://drive.google.com/file/d/1dx32hu0fbIw8VjCT6RiOC-F_MUJY1Ixd/view?usp=drivesdk',
    '38': 'https://drive.google.com/file/d/13m2nyktd0DQLUpegERwdbXHj6TvVld6i/view?usp=drivesdk',
    '39': 'https://drive.google.com/file/d/16bJIo4dXjQ_8r23682rr6kZs0TJe9pph/view?usp=drivesdk',
    '40': 'https://drive.google.com/file/d/14o4lQ7F4AjXlqX9OEGQIKxQANMmGnGij/view?usp=drivesdk',
    '41': 'https://drive.google.com/file/d/1UE7q75NmH7i0ME9NCkuIXnMIeo8TQJaf/view?usp=drivesdk',
    '42': 'https://drive.google.com/file/d/1GJKLMknA9sV7i2aONWgDE-0RaqOv8bAe/view?usp=drivesdk',
    '43': 'https://drive.google.com/file/d/1jYbqzS53Vn5Sb-XrcMkT4ODfH62Yyrmt/view?usp=drivesdk',
    '44': 'https://drive.google.com/file/d/1gV_sDH2SJyTU_LHlFKBDTiOF0NCf0uY0/view?usp=drivesdk',
    '45': 'https://drive.google.com/file/d/1y_LFve80AvDLUy5Foab-0nOG70OH8c1I/view?usp=drivesdk',
    '46': 'https://drive.google.com/file/d/1DYlPfQvM3c7Q2fZICwE5IMv27FAUF5T1/view?usp=drivesdk',
    '47': 'https://drive.google.com/file/d/1rJ-J9BWpH33MOfEtMgZhVkM6No2iXPoY/view?usp=drivesdk',
    '48': 'https://drive.google.com/file/d/1oRn1STH1d3IVQLLaE6hTpyBHPd-LSmcW/view?usp=drivesdk',
    '49': 'https://drive.google.com/file/d/1rzV2JpCPr3DbR_CeH_SjK_W4m6HqOi2I/view?usp=drivesdk',
    '50': 'https://drive.google.com/file/d/1uYjB4WOCkMorBYXmiCFUvgoPF6xlh4mj/view?usp=drivesdk',
    '51': 'https://drive.google.com/file/d/1wYeaiHcxBkGFdynKDoOuxZwsOcXwG5_o/view?usp=drivesdk',
    '52': 'https://drive.google.com/file/d/1NrgCk5Yw48WGyQ8t-q0zv64-CVjUhjtH/view?usp=drivesdk',
    '53': 'https://drive.google.com/file/d/1unZ7T0L-gXZJ66K4GXsKQ-zUy2Ircr4A/view?usp=drivesdk',
    '54': 'https://drive.google.com/file/d/1vMgM91_8eiOS-scIug7QAjb4VvQNLyo8/view?usp=drivesdk',
    '55': 'https://drive.google.com/file/d/1t7aGSD1skRa5aQB2PlRkc7jcGiBdrkz1/view?usp=drivesdk',
    '56': 'https://drive.google.com/file/d/1audQ6O_tZHbXv5Sl2WZid6AHZ8MbE8Ee/view?usp=drivesdk',
    '57': 'https://drive.google.com/file/d/12qa4GKWLAOytFcU2kmdYehWF1XtXEMOW/view?usp=drivesdk',
    '58': 'https://drive.google.com/file/d/1ypH-NJocqm9EdQX3V75i-jDwGhHHQcz4/view?usp=drivesdk',
    '59': 'https://drive.google.com/file/d/1KtJY9ifVd3-w2v6SpUOi0On3jcUlkmPx/view?usp=drivesdk',
    '60': 'https://drive.google.com/file/d/1OGyLEK9UsO_r_nMMoDxpF7tahWdw-GEg/view?usp=drivesdk',
    '61': 'https://drive.google.com/file/d/1GsHqcZu7Lkurnbn96NHOqXzTunlEdXUI/view?usp=drivesdk',
    '62': 'https://drive.google.com/file/d/1WAXCUs2GQlFe9BRVPvX2x1Aq2uENTuql/view?usp=drivesdk',
    '63': 'https://drive.google.com/file/d/1g6-g3KH4ifVVdAiJrFLtp7ErFFcbp5g2/view?usp=drivesdk',
    '64': 'https://drive.google.com/file/d/1px2jEWfvPIU0ryfGNDsj2LXQNOke5p-2/view?usp=drivesdk',
    '65': 'https://drive.google.com/file/d/1jNY9tEiKpbuzHo0YYYnpPbZm8HLIB-X3/view?usp=drivesdk',
    '66': 'https://drive.google.com/file/d/1NMAwm_iowyKjlXVlARBxMdEyAXL1HeGV/view?usp=drivesdk',
    '67': 'https://drive.google.com/file/d/1WC6WKOQaI2BCJ04YJEL7crY7okrdR7ew/view?usp=drivesdk',
    '68': 'https://drive.google.com/file/d/1S04jRY--MpH3O1LNiNLNMRh3eNrSXYrQ/view?usp=drivesdk',
    '69': 'https://drive.google.com/file/d/10edm9jw5RK32JSzCRnUILGFEycyKubwR/view?usp=drivesdk',
    '70': 'https://drive.google.com/file/d/17BgyWF_y7ukZ7FB3S7sb-bbzq7s6hOWX/view?usp=drivesdk',
    '71': 'https://drive.google.com/file/d/1NofPvV3wQpsOLAlonAzPKIMtJI0Ev2aT/view?usp=drivesdk',
    '72': 'https://drive.google.com/file/d/1Mad1bDtqDOnMmHDOzSkv7IxWqqPvXgge/view?usp=drivesdk',
    '73': 'https://drive.google.com/file/d/1ej01Wofs8B7wy-OQmXnBXE3k61tQ3N_i/view?usp=drivesdk',
    '74': 'https://drive.google.com/file/d/1zqV9QepEXZvNYubHr1G-abjUzCHnSsDF/view?usp=drivesdk',
    '75': 'https://drive.google.com/file/d/1VfpB8ej3tWNmRGfFhrcCF0ldUdIL91OJ/view?usp=drivesdk',
  };

  Future<void> abrirFichaTecnica(String id) async {
    final String? url = fichasTecnicas[id];

    if (url == null) return;"""

# Buscar el inicio del mapa
inicio = content.find("final Map<String, String> fichasTecnicas")
if inicio == -1:
    print("Error: No se encontró el mapa fichasTecnicas")
    exit(1)

# Buscar el final del método abrirFichaTecnica (después de la validación)
fin_busqueda = content.find("if (url == null", inicio)
if fin_busqueda == -1:
    print("Error: No se encontró la validación de url")
    exit(1)

# Buscar el final de la línea return
fin = content.find("return;", fin_busqueda) + len("return;")

# Reemplazar
nuevo_content = content[:inicio] + nuevo_mapa[2:] + content[fin:]

# Guardar
with open('lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(nuevo_content)

print("✅ Fichas técnicas actualizadas correctamente!")
print("📄 75 enlaces de Google Drive incorporados")
