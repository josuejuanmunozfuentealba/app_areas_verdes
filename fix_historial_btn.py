with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', encoding='utf-8') as f:
    text = f.read()

# Find and replace the Row with two buttons to just the GUARDAR button
import re

# Pattern: Row with GUARDAR and HISTORIAL buttons
old = r"Row\(\s*children: \[\s*Expanded\(\s*child: ElevatedButton\.icon\(.*?onPressed: \(\) \{\s*DefaultTabController\.of\(context\)\.animateTo\(1\);\s*\},\s*\),\s*\),\s*\],\s*\),"

def replacer(m):
    full = m.group(0)
    # Keep only up to the first Expanded (GUARDAR button)
    return full

# Simpler approach - find the second Expanded in the Row and remove it
idx = text.find("backgroundColor: Colors.indigo.shade700,")
if idx != -1:
    # Find start of second Expanded
    start = text.rfind("const SizedBox(width: 10),", 0, idx)
    if start == -1:
        start = text.rfind("Expanded(", 0, idx)
        start = text.rfind("Expanded(", 0, start)  # go back one more
        end_marker = "DefaultTabController.of(context).animateTo(1);\n                          },\n                        ),\n                      ),\n                    ],"
        end_idx = text.find(end_marker, idx)
        if end_idx != -1:
            end_idx += len(end_marker)
            # Replace from second Expanded to end of Row children
            second_expanded_start = text.rfind("\n\n                      Expanded(", 0, idx)
            new_text = text[:second_expanded_start] + "\n                    ]," + text[end_idx:]
            with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', 'w', encoding='utf-8') as f:
                f.write(new_text)
            print('Done')
        else:
            print('end_marker not found')
    else:
        print(f'start found at {start}')
else:
    print('indigo button not found')
