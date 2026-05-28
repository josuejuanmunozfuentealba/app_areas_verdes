#!/usr/bin/env python3
# -*- coding: utf-8 -*-

with open('lib/main.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Find the line after the last misPlazas.add (plaza 75)
# and add the closing brace for initState method
search_text = """    });

  
  // Mapa de fichas técnicas por ID"""

replace_text = """    });
  }

  
  // Mapa de fichas técnicas por ID"""

content = content.replace(search_text, replace_text)

with open('lib/main.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Fixed: Added closing brace for initState method")
