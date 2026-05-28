with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', encoding='utf-8') as f:
    text = f.read()

# The wrong build was inserted into AppAreasVerdes - fix it
old_wrong = """class AppAreasVerdes extends StatelessWidget {

  const AppAreasVerdes({super.key});



    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SizedBox.expand(
          child: Image.asset(
            'assets/logo mejorado.png',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class PantallaMapa"""

new_correct = """class AppAreasVerdes extends StatelessWidget {

  const AppAreasVerdes({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Áreas Verdes Doñihue',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade700),
        useMaterial3: true,
      ),
      home: const PantallaBienvenida(),
    );
  }
}

class PantallaMapa"""

text = text.replace(old_wrong, new_correct)

with open(r'C:\Users\HP PAVILION\app_areas_verdes\lib\main.dart', 'w', encoding='utf-8') as f:
    f.write(text)

print('Done')
