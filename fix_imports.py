with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', encoding='utf-8') as f:
    text = f.read()

# Remove unused imports
text = text.replace("import 'package:shared_preferences/shared_preferences.dart';\n\n", "")
text = text.replace("import 'package:printing/printing.dart';\n\n", "")

# Fix anchor variable warning - use cascade instead
text = text.replace(
    "    final anchor = html.AnchorElement(href: url)\n      ..setAttribute('download', nombreArchivo)\n      ..click();",
    "    html.AnchorElement(href: url)\n      ..setAttribute('download', nombreArchivo)\n      ..click();"
)

with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print('Done')
