import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/sophisticated_marker.dart';
import 'screens/inspeccion_tecnica_screen.dart';
import 'screens/catastro_inmuebles_screen.dart';
import 'screens/inspeccion_urgencia_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://speneggmlqitgfjhzsry.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwZW5lZ2dtbHFpdGdmamh6c3J5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY1MzUzMDksImV4cCI6MjEwMjExMTMwOX0.31WSG-j7m_TO4uGjmXW59jTrxrX7wFvHT8sHtY5zIQg',
  );

  runApp(const AppAreasVerdes());
}

class AppAreasVerdes extends StatelessWidget {
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
      // Motor Adaptativo Inteligente: Normaliza escala visual en todos los dispositivos
      builder: (context, child) {
        if (child == null) return const SizedBox.shrink();

        // Obtener dimensiones del dispositivo
        final mediaQuery = MediaQuery.of(context);
        final screenWidth = mediaQuery.size.width;

        // Factor de escala dinámico según tamaño de pantalla
        double scaleFactor;
        if (screenWidth < 360) {
          // Pantallas pequeñas (320px-360px): Escala compacta legible
          scaleFactor = 0.90;
        } else if (screenWidth <= 420) {
          // Pantallas estándar (360px-420px): Escala óptima
          scaleFactor = 1.0;
        } else if (screenWidth <= 700) {
          // Pantallas grandes (420px-700px): Escala ligeramente ampliada
          scaleFactor = 1.05;
        } else {
          // Tablets (>700px): Escala estándar sin estirar
          scaleFactor = 1.0;
        }

        // Clonar MediaQuery con ajustes adaptativos
        return MediaQuery(
          data: mediaQuery.copyWith(
            // Limitar escalado de texto por accesibilidad (0.85x a 1.15x)
            textScaler: mediaQuery.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.15,
            ),
            // Aplicar factor de escala global
            devicePixelRatio: mediaQuery.devicePixelRatio * scaleFactor,
          ),
          child: child,
        );
      },
      // IMPORTANTE: Siempre usar Flutter nativo (no WebView)
      // Esto garantiza que el Motor Adaptativo funcione en todos los dispositivos
      home: const SplashScreen(),
    );
  }
}

// Pantalla de carga (Splash Screen)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Esperar 3 segundos antes de navegar al mapa
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const PantallaMapa()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF1565C0), // Azul corporativo
      body: Padding(
        padding: const EdgeInsets.all(56.0), // 2 cm ≈ 56 pixels (aproximado)
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo sin fondo blanco, solo la imagen
              Flexible(
                child: Image.asset(
                  'assets/logowebactualizado.png',
                  width: size.width * 0.6, // 60% del ancho de la pantalla
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              // Indicador de carga
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 4,
              ),
              const SizedBox(height: 20),
              // Texto
              const Text(
                'Cargando Áreas Verdes...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PantallaMapa extends StatefulWidget {
  const PantallaMapa({super.key});

  @override
  State<PantallaMapa> createState() => _PantallaMapaState();
}

class _PantallaMapaState extends State<PantallaMapa> {
  final LatLng centroDonihue = const LatLng(-34.2278, -70.9622);
  final List<Map<String, dynamic>> misPlazas = [];
  final MapController _mapController = MapController();

  // Variables para el panel y búsqueda
  bool _isPanelVisible = false;
  Map<String, dynamic>? _selectedPlaza;
  String? _selectedPlazaId; // ID del marcador seleccionado
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredPlazas = [];
  bool _isSearching = false;

  // Diccionario de enlaces: relaciona el ID de la plaza con su URL de ficha técnica
  final Map<String, String> enlacesFichas = {
    '1':
        'https://drive.google.com/file/d/18ykxuVfjhml5Qcvip9K-mFdR6O7CDRBP/view?usp=drivesdk',
    '2':
        'https://drive.google.com/file/d/1tVzTIWYeVGF9PzmVPhrHeHPU732NVVKu/view?usp=drivesdk',
    '3':
        'https://drive.google.com/file/d/1SlrPh9gtkPlQdVDnw00vaE1ijksZbkE3/view?usp=drivesdk',
    '4':
        'https://drive.google.com/file/d/1hokJvWB4OnTn-_Hmf71D8liQKH4i9hej/view?usp=drivesdk',
    '5':
        'https://drive.google.com/file/d/1CP5Jm3E14SZkat1ffK09lp9D5MLCokaw/view?usp=drivesdk',
    '6':
        'https://drive.google.com/file/d/1v48WZxc-SUGXfXHLg2ayrJplrLttZMq_/view?usp=drivesdk',
    '7':
        'https://drive.google.com/file/d/1bJFCGNVucdpBuwzwL4WdKpqfVS_Y8-CC/view?usp=drivesdk',
    '8':
        'https://drive.google.com/file/d/1blnWZ1uPdZz6sbVp4bk7z-mUQ3291lIe/view?usp=drivesdk',
    '9':
        'https://drive.google.com/file/d/1GpcSdtFyJVG7R_Y2O51rMCjoI_Th2MtY/view?usp=drivesdk',
    '10':
        'https://drive.google.com/file/d/1c0UDHnSBchJ68lH2h_gLyv2_v2Ggr9NE/view?usp=drivesdk',
    '11':
        'https://drive.google.com/file/d/16nnsG2y2jk_DLpTLdlVp4UIR60jfROm7/view?usp=drivesdk',
    '12':
        'https://drive.google.com/file/d/17I6wPEyYXseS6vka5BIGOCqh4o0BcKSE/view?usp=drivesdk',
    '13':
        'https://drive.google.com/file/d/1mnuNC-GkNYcx2FRMLrYUm0NkgN0FR5EP/view?usp=drivesdk',
    '14':
        'https://drive.google.com/file/d/1VLzWHvkq5PpZ2mfOqSKmA8e9MGo9A-Zp/view?usp=drivesdk',
    '15':
        'https://drive.google.com/file/d/1DDVaMMz9PJCcz-B8lIzjskOgZtnZoiLw/view?usp=drivesdk',
    '16':
        'https://drive.google.com/file/d/1ygO402VEBFuN2Pfeoqmk0OLcnsRu-hVj/view?usp=drivesdk',
    '17':
        'https://drive.google.com/file/d/1FPzllZJ5Yd3DMRteRlxvnDJvJdCn7eyA/view?usp=drivesdk',
    '18':
        'https://drive.google.com/file/d/1xjN2wgh4Ur20ipGBHoNQa2NrOTxeh5mi/view?usp=drivesdk',
    '19':
        'https://drive.google.com/file/d/1XTJ5ViSAEuyYiHommATZP6KlNYgRQ6TL/view?usp=drivesdk',
    '20':
        'https://drive.google.com/file/d/1w3bP2NDWOj-wAxwD1_9P663Ng8fR8Eef/view?usp=drivesdk',
    '21':
        'https://drive.google.com/file/d/1pWqF7k49Hlz9BG2hv1Hq3ISVHASLbfhM/view?usp=drivesdk',
    '22':
        'https://drive.google.com/file/d/1KZJiGNFIqSJnrPyvQzTx4swM8njsrIKP/view?usp=drivesdk',
    '23':
        'https://drive.google.com/file/d/1xo4dIlNW2VCSztqT5T-BqfIFIS14ZTrr/view?usp=drivesdk',
    '24':
        'https://drive.google.com/file/d/1CXkNIHd7OAAswKOwXJQp8x-ce_QNs9Rr/view?usp=drivesdk',
    '25':
        'https://drive.google.com/file/d/1j7VhF2uJGWI95C_9zW4OR5GXC_CP7ZKK/view?usp=drivesdk',
    '26':
        'https://drive.google.com/file/d/1WOU2Y72WWCzxdJGIhnyCHcDExdl6dphA/view?usp=drivesdk',
    '27':
        'https://drive.google.com/file/d/1eHlSoRolcVPVlZ7WtSEhwIJuimJb_i5o/view?usp=drivesdk',
    '28':
        'https://drive.google.com/file/d/1PMGeFWujmYFH0mk0aEbGHPqHPrhnIY3N/view?usp=drivesdk',
    '29':
        'https://drive.google.com/file/d/1d5tm42sMyXuf5oL6NQEKsLUbnCSzxFES/view?usp=drivesdk',
    '30':
        'https://drive.google.com/file/d/1tT1uvg33MgHkfsjKr2OpuiYyRtBXVdSR/view?usp=drivesdk',
    '31':
        'https://drive.google.com/file/d/1q2-T7KJ7JI3S2HiW5uVY5SbaCDaDO4LS/view?usp=drivesdk',
    '32':
        'https://drive.google.com/file/d/19YpwDaC5mZdFvkrFWd6r0bFsZCNVSP83/view?usp=drivesdk',
    '33':
        'https://drive.google.com/file/d/13zHFX29_6Rq8xaevXSH22Z-Bp9keP4SL/view?usp=drivesdk',
    '34':
        'https://drive.google.com/file/d/1IioBIwHBZHku9j6Mq_cdwf5pEak0ubvY/view?usp=drivesdk',
    '35':
        'https://drive.google.com/file/d/1y1xBk93uZKT2_8lMN8N_7hj08VBCvufU/view?usp=drivesdk',
    '36':
        'https://drive.google.com/file/d/15PQwy9vCkfRdPITZVZlUJKk1xB6hCv5z/view?usp=drivesdk',
    '37':
        'https://drive.google.com/file/d/1CQqY-LSvIss6K5ri9UWUtug65nAqDOk6/view?usp=drivesdk',
    '38':
        'https://drive.google.com/file/d/1oRgl3o0bifmu7n-7VKbh99INbX8Ea-o6/view?usp=drivesdk',
    '39':
        'https://drive.google.com/file/d/1O4sq4FshDh1mdiZuu4EeQs9Ay-93s__l/view?usp=drivesdk',
    '40':
        'https://drive.google.com/file/d/1DTIHCMhpHAuDdDSzt_5vXTNw3gB_q9KZ/view?usp=drivesdk',
    '41':
        'https://drive.google.com/file/d/1Uv6mHibB-BJBsy7AA3XiY0sodiOpjgao/view?usp=drivesdk',
    '42':
        'https://drive.google.com/file/d/1mvBAkgQZ-qzaU5RxxBMTuR2JMzHkghGl/view?usp=drivesdk',
    '43':
        'https://drive.google.com/file/d/19XaahH2nL120wxkQUM4GeB-A9mxE-cVV/view?usp=drivesdk',
    '44':
        'https://drive.google.com/file/d/12kE8nfXshrfBq9q1QUfm9kA6Vnv_Ui36/view?usp=drivesdk',
    '45':
        'https://drive.google.com/file/d/1qqfhMG23yKlf147XzdZ_Xursifwm4Ri0/view?usp=drivesdk',
    '46':
        'https://drive.google.com/file/d/1oPKb4z8iwixoCoNOCX7gGRd_di0UFd7K/view?usp=drivesdk',
    '47':
        'https://drive.google.com/file/d/1L5wVosbsPR3Ibs5vlFzvhqgZda2IwFFg/view?usp=drivesdk',
    '48':
        'https://drive.google.com/file/d/1vDaqQBHgljCImq3P_OkbRbdnrXlMfIMi/view?usp=drivesdk',
    '49':
        'https://drive.google.com/file/d/1Lr95WvL349-0vbjngNn8Y4qf_k7Daiof/view?usp=drivesdk',
    '50':
        'https://drive.google.com/file/d/10Hh02lF4zwet85r7luGTB1HKVvPFfbBf/view?usp=drivesdk',
    '51':
        'https://drive.google.com/file/d/1C8U16M8LGAkjq_Sg9Uv1eN-vPtFDQTvq/view?usp=drivesdk',
    '52':
        'https://drive.google.com/file/d/1MsBLGBNsBFF_Ej16vbqYVHqogjKZsFPn/view?usp=drivesdk',
    '53':
        'https://drive.google.com/file/d/1_TF4I51NFpogI6oI4IFJUSLVnJebySVK/view?usp=drivesdk',
    '54':
        'https://drive.google.com/file/d/1aWI35fj_4dPcU82fe-aEGujL0EU2qBRK/view?usp=drivesdk',
    '55':
        'https://drive.google.com/file/d/1YENfoi1L0h-q7JHRziPJ64tJczrUdbt4/view?usp=drivesdk',
    '56':
        'https://drive.google.com/file/d/1ofmSIVX-EBrC_DfjMtXSJB-hO2sIiWK8/view?usp=drivesdk',
    '57':
        'https://drive.google.com/file/d/1PgfMhTvzOycBt-Gj0t0yXwIfc0kVOd4k/view?usp=drivesdk',
    '58':
        'https://drive.google.com/file/d/1fYyaPbKXL212nv726phOUOR88XVIC5Sk/view?usp=drivesdk',
    '59':
        'https://drive.google.com/file/d/1XgkdF48-w2PqDjx7cym4m0Fy4LY62Yj6/view?usp=drivesdk',
    '60':
        'https://drive.google.com/file/d/1EkacSpTaMAu0fVnI2uhgatTlj3D4pjx7/view?usp=drivesdk',
    '61':
        'https://drive.google.com/file/d/1ynbjdu_w2tsBp_lWdfjHFxnqf4X7J9Qc/view?usp=drivesdk',
    '62':
        'https://drive.google.com/file/d/1OxwYtdcwRSZNEqcI4kInHjYAl4toANqe/view?usp=drivesdk',
    '63':
        'https://drive.google.com/file/d/1xw7S5FokIiqfcq3YH22pBg7C3KeNTmub/view?usp=drivesdk',
    '64':
        'https://drive.google.com/file/d/1AdcSrlSU2q6PDIJq6eaB_dU37yQaiiiJ/view?usp=drivesdk',
    '65':
        'https://drive.google.com/file/d/1Q-S82zjigvAN_XyqrDdyklyFRz57Xhc8/view?usp=drivesdk',
    '66':
        'https://drive.google.com/file/d/1zRfJ88rJZDuUCMPRZUZeT5gKyKDFVnRa/view?usp=drivesdk',
    '67':
        'https://drive.google.com/file/d/1Tp33F0-JiCx_bEj5_Dl-zh8rI6APbAFj/view?usp=drivesdk',
    '68':
        'https://drive.google.com/file/d/10jxxQTwKgFUGliRoh4ruC2IdFy_VkRXI/view?usp=drivesdk',
    '69':
        'https://drive.google.com/file/d/1XKcij598nvv26wvpZfZEpCp_DmEihiI7/view?usp=drivesdk',
    '70':
        'https://drive.google.com/file/d/1_28NK2R7z2KqSAM1B2F10sWA3Nu78ehV/view?usp=drivesdk',
    '71':
        'https://drive.google.com/file/d/1CB8MHpwXlbHUiob9bLtalurJ2feW1Voe/view?usp=drivesdk',
    '72':
        'https://drive.google.com/file/d/1uOMNZZ7rK6yVKD2yyw29_61nRjYVPqx9/view?usp=drivesdk',
    '73':
        'https://drive.google.com/file/d/1vhCDJb2kfVzEz3JiN0fCQXN_4J_bU_x-/view?usp=drivesdk',
    '74':
        'https://drive.google.com/file/d/1Tyx77-NYP851ioBUhpMJ7FKbWl-PNnqx/view?usp=drivesdk',
    '75':
        'https://drive.google.com/file/d/1KHIiqAa4ucI3AziTbdx1Vo6rCIo3k7_K/view?usp=drivesdk',
    '76':
        'https://drive.google.com/file/d/1-0_DX6PICaywwsIxgOygr7fQBiMMbLVy/view?usp=drivesdk',
    '77':
        'https://drive.google.com/file/d/1CMKkPLNcVPyWl1sx_kv-oPET3A5LBfE0/view?usp=drivesdk',
  };

  @override
  void initState() {
    super.initState();
    _cargarPlazas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cargarPlazas() {
    misPlazas.addAll([
      {
        'id': '1',
        'nombre': 'Plaza de armas donihue',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Delfin Carvallo con Subteniente Valenzuela',
        'coordenadas': const LatLng(-34.226023, -70.964876),
        'estado': 'Excelente',
      },
      {
        'id': '2',
        'nombre': 'Portal letra turisticas',
        'tipo': 'Bandejon',
        'comuna': 'Donihue',
        'direccion': 'Letras Turisticas Donihue en H-10 con H-286',
        'coordenadas': const LatLng(-34.225574, -70.946515),
        'estado': 'Excelente',
      },
      {
        'id': '3',
        'nombre': 'Plaza de armas Lomiranda',
        'tipo': 'Plaza Lo Miranda',
        'comuna': 'Lo Miranda',
        'direccion': 'Cabo Moena entre H-286 y H-276',
        'coordenadas': const LatLng(-34.189699, -70.890532),
        'estado': 'Regular',
      },
      {
        'id': '4',
        'nombre': 'Monumento portal caballo lomiranda',
        'tipo': 'Plaza Dura',
        'comuna': 'Lo Miranda',
        'direccion': 'Monumento Portal Lo Miranda en H-30 con H-270',
        'coordenadas': const LatLng(-34.195218, -70.848973),
        'estado': 'Regular',
      },
      {
        'id': '5',
        'nombre': 'Gabriela mistral Donihue',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'A. Estacion con Estacion Carrera',
        'coordenadas': const LatLng(-34.227638, -70.964722),
        'estado': 'Regular',
      },
      {
        'id': '6',
        'nombre': 'Villa Centro',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Pedro Jose Vial/Humberto Vega F',
        'coordenadas': const LatLng(-34.229011, -70.966619),
        'estado': 'Regular',
      },
      {
        'id': '7',
        'nombre': 'Centro Emprendimiento Artesanal',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Bombero Vicente Carter con Emilio Cuevas',
        'coordenadas': const LatLng(-34.228077, -70.968544),
        'estado': 'Regular',
      },
      {
        'id': '8',
        'nombre': 'Villa Felipe Martinez A',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion':
            'Av. Villar del Rio entre psje. Madrid y psje. Provincia de Soria',
        'coordenadas': const LatLng(-34.224605, -70.966255),
        'estado': 'Regular',
      },
      {
        'id': '9',
        'nombre': 'Villa Felipe Martinez B',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion':
            'Av. Villar del Rio entre Maule y psje. Provincia de Soria',
        'coordenadas': const LatLng(-34.224378, -70.965693),
        'estado': 'Regular',
      },
      {
        'id': '10',
        'nombre': 'Villa Lo Carrasco A',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Daniel Carrasco referencia n 498',
        'coordenadas': const LatLng(-34.224307, -70.967516),
        'estado': 'Regular',
      },
      {
        'id': '11',
        'nombre': 'Villa Lo Carrasco B',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Daniel Carrasco con Psje. Cataluna',
        'coordenadas': const LatLng(-34.224118, -70.966509),
        'estado': 'Regular',
      },
      {
        'id': '12',
        'nombre': 'Villa Lo Carrasco C',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Maule entre psje. Navarra y psje. Cataluna',
        'coordenadas': const LatLng(-34.223959, -70.965849),
        'estado': 'Regular',
      },
      {
        'id': '13',
        'nombre': 'Dr. Sanhueza 1',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Dr Sanhueza 551 referencia',
        'coordenadas': const LatLng(-34.222825, -70.962149),
        'estado': 'Regular',
      },
      {
        'id': '14',
        'nombre': 'Dr. Sanhueza 2',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Dr. Sanhueza con Av. Rancagua',
        'coordenadas': const LatLng(-34.222262, -70.961639),
        'estado': 'Regular',
      },
      {
        'id': '15',
        'nombre': 'Plaza 21 de Mayo',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Errazuriz con Estacion Carrera',
        'coordenadas': const LatLng(-34.227596, -70.962602),
        'estado': 'Regular',
      },
      {
        'id': '16',
        'nombre': 'Plaza 21 de Mayo interior',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Plaza 21 de Mayo Interior',
        'coordenadas': const LatLng(-34.228240, -70.961847),
        'estado': 'Regular',
      },
      {
        'id': '17',
        'nombre': 'Villa O\'Higgins 1',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Calle Los Copihues con Psje. Los Claveles',
        'coordenadas': const LatLng(-34.224352, -70.970161),
        'estado': 'Regular',
      },
      {
        'id': '18',
        'nombre': 'Villa O\'Higgins 2',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion':
            'Calle Los Copihues entre Psje. Los Gladiolos y M. A. Roman (Norte)',
        'coordenadas': const LatLng(-34.224276, -70.971991),
        'estado': 'Regular',
      },
      {
        'id': '19',
        'nombre': 'Villa O\'Higgins Multicancha',
        'tipo': 'Plaza Dura',
        'comuna': 'Donihue',
        'direccion':
            'Calle Los Copihues entre Psje. Los Gladiolos y M. A. Roman (Sur)',
        'coordenadas': const LatLng(-34.224539, -70.971713),
        'estado': 'Regular',
      },
      {
        'id': '20',
        'nombre': 'Villa Valles de San Francisco 1',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Calle M. A. Roman con Rio Claro',
        'coordenadas': const LatLng(-34.226262, -70.971823),
        'estado': 'Regular',
      },
      {
        'id': '21',
        'nombre': 'Villa Valles de San Francisco Cancha',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Manuel Antonio Roman con Pje. Rio Damas',
        'coordenadas': const LatLng(-34.225757, -70.971254),
        'estado': 'Regular',
      },
      {
        'id': '22',
        'nombre': 'Villa Valles de San Francisco 2',
        'tipo': 'Plaza Dura',
        'comuna': 'Donihue',
        'direccion': 'Manuel Antonio Roman con Rio Damas',
        'coordenadas': const LatLng(-34.225323, -70.971915),
        'estado': 'Regular',
      },
      {
        'id': '23',
        'nombre': 'Villa Quimavida',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Calle Las Rosas Fte. 40',
        'coordenadas': const LatLng(-34.222844, -70.971000),
        'estado': 'Regular',
      },
      {
        'id': '24',
        'nombre': 'Villa Eusebia exterior',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Calle Las Rosas 656',
        'coordenadas': const LatLng(-34.222367, -70.971171),
        'estado': 'Regular',
      },
      {
        'id': '25',
        'nombre': 'Villa Eusebia',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Calle Las Rosas con Psje. Camarico',
        'coordenadas': const LatLng(-34.221980, -70.970954),
        'estado': 'Regular',
      },
      {
        'id': '26',
        'nombre': 'Villa Eusebia interior',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Psje. Camarico con Psje. La Manta',
        'coordenadas': const LatLng(-34.221599, -70.970609),
        'estado': 'Regular',
      },
      {
        'id': '27',
        'nombre': 'Valles de san Francisco 2',
        'tipo': 'Plaza Dura',
        'comuna': 'Donihue',
        'direccion': 'Calle Rio Cisne con Emilio Cuevas',
        'coordenadas': const LatLng(-34.225356, -70.969348),
        'estado': 'Regular',
      },
      {
        'id': '28',
        'nombre': 'Paradero 27 -San juan',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Psje. Donihue con Ruta H30 Paradero 27',
        'coordenadas': const LatLng(-34.254417, -70.991418),
        'estado': 'Regular',
      },
      {
        'id': '29',
        'nombre': 'Paradero 17 Cerrillos',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Av. Cachapoal con Cerrillos',
        'coordenadas': const LatLng(-34.241188, -70.984443),
        'estado': 'Regular',
      },
      {
        'id': '30',
        'nombre': 'Bandejon cruze coinco',
        'tipo': 'Bandejon Central',
        'comuna': 'Donihue',
        'direccion': 'Ruta H-30 con Ruta H-38',
        'coordenadas': const LatLng(-34.228822, -70.957422),
        'estado': 'Regular',
      },
      {
        'id': '31',
        'nombre': 'Tres Esquinas 1',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Av. Rancagua y Pablo VI 47',
        'coordenadas': const LatLng(-34.222638, -70.952191),
        'estado': 'Regular',
      },
      {
        'id': '32',
        'nombre': 'Tres Esquinas 2',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Av. Rancagua entre H-29 y Juan Pablo II',
        'coordenadas': const LatLng(-34.222211, -70.952834),
        'estado': 'Regular',
      },
      {
        'id': '33',
        'nombre': 'La plazuela Oratorio rinconada',
        'tipo': 'Plaza Dura',
        'comuna': 'Donihue',
        'direccion': 'H29 SN',
        'coordenadas': const LatLng(-34.206661, -70.943489),
        'estado': 'Regular',
      },
      {
        'id': '34',
        'nombre': 'Plazuela Villa Australia',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Pasaje Sidney Fte. 33',
        'coordenadas': const LatLng(-34.220947, -70.954710),
        'estado': 'Regular',
      },
      {
        'id': '35',
        'nombre': 'Plazuela Villa Sol Del Rey',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Max Jara Fte. 0045',
        'coordenadas': const LatLng(-34.221195, -70.955347),
        'estado': 'Regular',
      },
      {
        'id': '36',
        'nombre': 'Plazuela Villa Las Palmas',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Psje. Maiten Fte. 260',
        'coordenadas': const LatLng(-34.221284, -70.956358),
        'estado': 'Regular',
      },
      {
        'id': '37',
        'nombre': 'Area Verde Santa Catalina 4',
        'tipo': 'Plaza Dura',
        'comuna': 'Donihue',
        'direccion': 'Aliro Gonzales Fte. 171',
        'coordenadas': const LatLng(-34.224243, -70.959398),
        'estado': 'Regular',
      },
      {
        'id': '38',
        'nombre': 'Area Verde Santa Catalina 5',
        'tipo': 'Plaza Dura',
        'comuna': 'Donihue',
        'direccion': 'Psje. Hugo Ortiz Fte 211',
        'coordenadas': const LatLng(-34.224322, -70.958613),
        'estado': 'Regular',
      },
      {
        'id': '39',
        'nombre': 'Area Verde Santa Catalina 6',
        'tipo': 'Plaza Dura',
        'comuna': 'Donihue',
        'direccion': 'Aliro Gonzales con Victor Perez Perez',
        'coordenadas': const LatLng(-34.223666, -70.959196),
        'estado': 'Regular',
      },
      {
        'id': '40',
        'nombre': 'Plazuela De lomiranda',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'H-76 Plazuela Lo Miranda',
        'coordenadas': const LatLng(-34.191435, -70.909986),
        'estado': 'Regular',
      },
      {
        'id': '41',
        'nombre': 'Villa Lagos Fenix A',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Calle Central con Lago Rapel',
        'coordenadas': const LatLng(-34.210077, -70.901748),
        'estado': 'Regular',
      },
      {
        'id': '42',
        'nombre': 'Villa Lagos Fenix B',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Psje. Lago Llanquihue con Central',
        'coordenadas': const LatLng(-34.210019, -70.902458),
        'estado': 'Regular',
      },
      {
        'id': '43',
        'nombre': 'Area verde Villa el arrayan A',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Psje. Manquehue con Central',
        'coordenadas': const LatLng(-34.210389, -70.903560),
        'estado': 'Regular',
      },
      {
        'id': '44',
        'nombre': 'Area verde Villa el arrayan B',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Calle Central Fte. 023',
        'coordenadas': const LatLng(-34.209854, -70.903183),
        'estado': 'Regular',
      },
      {
        'id': '45',
        'nombre': 'Area Verde Gabriela Mistral',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Camino Vecinal SN',
        'coordenadas': const LatLng(-34.208744, -70.901031),
        'estado': 'Regular',
      },
      {
        'id': '46',
        'nombre': 'Area Verde Paradero 4',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Bernardo O\'Higgins entre Los Laureles y Los Condores',
        'coordenadas': const LatLng(-34.205467, -70.885553),
        'estado': 'Regular',
      },
      {
        'id': '47',
        'nombre': 'Bandejon Central Ruta H-30',
        'tipo': 'Plaza Dura',
        'comuna': 'Lo Miranda',
        'direccion': 'H-30 con Bernardo O\'Higgins',
        'coordenadas': const LatLng(-34.205318, -70.883501),
        'estado': 'Regular',
      },
      {
        'id': '48',
        'nombre': 'Area Verde Galvarino',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Cam. Antiguo con Los Tiuques, Las Aguilas y Los Condores',
        'coordenadas': const LatLng(-34.203107, -70.885696),
        'estado': 'Regular',
      },
      {
        'id': '49',
        'nombre': 'Area Verde Caupolicam',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'El Roble entre El Canelo y Camino Antiguo',
        'coordenadas': const LatLng(-34.203540, -70.886797),
        'estado': 'Regular',
      },
      {
        'id': '50',
        'nombre': 'Plaza villa lomiranda A',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Entre Psje. Astorga y Psje. El Boldo',
        'coordenadas': const LatLng(-34.198996, -70.887679),
        'estado': 'Regular',
      },
      {
        'id': '51',
        'nombre': 'Plaza villa lomiranda B',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Psje. Las Golondrinas Fte. 303',
        'coordenadas': const LatLng(-34.199774, -70.887274),
        'estado': 'Regular',
      },
      {
        'id': '52',
        'nombre': 'Plaza villa Hermosa',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Calle El Canelo Fte. 44',
        'coordenadas': const LatLng(-34.201523, -70.887170),
        'estado': 'Regular',
      },
      {
        'id': '53',
        'nombre': 'Plaza Sor Teresa',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Las Carmelitas con Rinconada de Auco',
        'coordenadas': const LatLng(-34.198702, -70.890048),
        'estado': 'Regular',
      },
      {
        'id': '54',
        'nombre': 'Area verde el Pedregal',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Los Diamantes con Los Opalos',
        'coordenadas': const LatLng(-34.199851, -70.894191),
        'estado': 'Regular',
      },
      {
        'id': '55',
        'nombre': 'Area verde Villa el Esfuerzo',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'calle la union con el progreso',
        'coordenadas': const LatLng(-34.198541, -70.895089),
        'estado': 'Regular',
      },
      {
        'id': '56',
        'nombre': 'Area verde los Conquistadores',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Av. Diego de Almagro con Psje. Isabel La Catolica',
        'coordenadas': const LatLng(-34.202028, -70.890958),
        'estado': 'Regular',
      },
      {
        'id': '57',
        'nombre': 'Plaza Villa El Bosque',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Av. Las Dalias con Psje. Las Camelias',
        'coordenadas': const LatLng(-34.196912, -70.888050),
        'estado': 'Regular',
      },
      {
        'id': '58',
        'nombre': 'Plaza Villa Ilusion',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Calle Concejal Eduardo Miranda con Psje. 4 y C.A.',
        'coordenadas': const LatLng(-34.196256, -70.888508),
        'estado': 'Regular',
      },
      {
        'id': '59',
        'nombre': 'Area Verde Dona Victoria',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion':
            'Calle Concejal Eduardo Miranda con Psje. A. Carlos Valentin',
        'coordenadas': const LatLng(-34.196173, -70.887740),
        'estado': 'Regular',
      },
      {
        'id': '60',
        'nombre': 'Area verde villa el Milagro',
        'tipo': 'Plaza Dura',
        'comuna': 'Lo Miranda',
        'direccion': 'Rosa Zuniga con Psje. Juanito y Delfina',
        'coordenadas': const LatLng(-34.195301, -70.886291),
        'estado': 'Regular',
      },
      {
        'id': '61',
        'nombre': 'Area Verde Tricahue 1',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Villa Tricahue',
        'coordenadas': const LatLng(-34.193237, -70.888389),
        'estado': 'Regular',
      },
      {
        'id': '62',
        'nombre': 'Area Verde Tricahue 2',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Villa Tricahue 2',
        'coordenadas': const LatLng(-34.193417, -70.888996),
        'estado': 'Regular',
      },
      {
        'id': '63',
        'nombre': 'Area verde villa los andes 1',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'H-280 con calle Cordillera y calle Los Urales',
        'coordenadas': const LatLng(-34.192289, -70.889690),
        'estado': 'Regular',
      },
      {
        'id': '64',
        'nombre': 'Area verde villa los andes 1.1',
        'tipo': 'Plaza Dura',
        'comuna': 'Lo Miranda',
        'direccion': 'Calle Los Urales Fte.',
        'coordenadas': const LatLng(-34.192523, -70.889363),
        'estado': 'Regular',
      },
      {
        'id': '65',
        'nombre': 'Area verde villa los andes 2',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Calle Cordillera con Calle Los Urales',
        'coordenadas': const LatLng(-34.191988, -70.888203),
        'estado': 'Regular',
      },
      {
        'id': '66',
        'nombre': 'Plaza poblacion lautaro',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion':
            'Bdo. O\'Higgins con A. Bello, 18 de Septiembre y 21 de Mayo',
        'coordenadas': const LatLng(-34.204217, -70.880795),
        'estado': 'Regular',
      },
      {
        'id': '67',
        'nombre': 'Bandejon central FERIA',
        'tipo': 'Plaza Dura',
        'comuna': 'Lo Miranda',
        'direccion': 'Bernardo O\'Higgins entre Los Condores y Arturo Prat',
        'coordenadas': const LatLng(-34.204099, -70.879337),
        'estado': 'Regular',
      },
      {
        'id': '68',
        'nombre': 'Area verde villa esperanza',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'H-30 con Villa Esperanza y Psje. Sagrado Corazon',
        'coordenadas': const LatLng(-34.202715, -70.875043),
        'estado': 'Regular',
      },
      {
        'id': '69',
        'nombre': 'Area verde villa esperanza 1',
        'tipo': 'Plaza Dura',
        'comuna': 'Lo Miranda',
        'direccion': 'Psje. Lo Miranda Oriente',
        'coordenadas': const LatLng(-34.203172, -70.876275),
        'estado': 'Regular',
      },
      {
        'id': '70',
        'nombre': 'Cancha Villa Esperanza',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Calle entre Psje. San Jorge y Psje. Sagrado Corazon',
        'coordenadas': const LatLng(-34.202313, -70.875897),
        'estado': 'Regular',
      },
      {
        'id': '71',
        'nombre': 'Area verde villa esperanza 2',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Psje. Villa Luna y Psje. La Florida',
        'coordenadas': const LatLng(-34.201087, -70.875511),
        'estado': 'Regular',
      },
      {
        'id': '72',
        'nombre': 'Area verde villa esperanza 3',
        'tipo': 'Plaza',
        'comuna': 'Lo Miranda',
        'direccion': 'Entre Psje. Union Comunal y Psje. La Florida',
        'coordenadas': const LatLng(-34.200819, -70.875870),
        'estado': 'Regular',
      },
      {
        'id': '73',
        'nombre': 'Santa Catalina 3',
        'tipo': 'Plaza Dura',
        'comuna': 'Lo Miranda',
        'direccion': 'Calle Los Robles con calle Ximena Meneses',
        'coordenadas': const LatLng(-34.224075, -70.960386),
        'estado': 'Regular',
      },
      {
        'id': '74',
        'nombre': 'Santa Catalina 2',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Calle Victor Perez Perez con calle Los Robles',
        'coordenadas': const LatLng(-34.223702, -70.960092),
        'estado': 'Regular',
      },
      {
        'id': '75',
        'nombre': 'Santa Catalina 2.1',
        'tipo': 'Plaza',
        'comuna': 'Donihue',
        'direccion': 'Psje. Los Nires con calle Los Robles',
        'coordenadas': const LatLng(-34.223060, -70.959854),
        'estado': 'Regular',
      },
      {
        'id': '76',
        'nombre': 'Plaza de cerrillos paradero 17 CANAL',
        'tipo': 'Plaza',
        'comuna': 'Doñihue',
        'direccion': 'Calle Cerrillos costado acequia',
        'coordenadas': const LatLng(-34.241462, -70.984197),
        'estado': 'Regular',
      },
      {
        'id': '77',
        'nombre': 'Plaza villa ohiggins 3',
        'tipo': 'Plaza',
        'comuna': 'Doñihue',
        'direccion':
            'Psje. Las Violetas entre Los Copihues y Psje. Los Claveles',
        'coordenadas': const LatLng(-34.224683, -70.969671),
        'estado': 'Regular',
      },
    ]);
  }

  // Método para filtrar plazas según búsqueda
  void _filterPlazas(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPlazas = [];
        _isSearching = false;
      } else {
        _isSearching = true;
        _filteredPlazas = misPlazas.where((plaza) {
          // Búsqueda por ID (coincidencia exacta)
          if (query.trim() == plaza['id']) {
            return true;
          }
          // Búsqueda por nombre (contains, insensible a mayúsculas y acentos)
          String nombreNormalizado = plaza['nombre']
              .toString()
              .toLowerCase()
              .replaceAll('á', 'a')
              .replaceAll('é', 'e')
              .replaceAll('í', 'i')
              .replaceAll('ó', 'o')
              .replaceAll('ú', 'u')
              .replaceAll('ñ', 'n');
          String queryNormalizado = query
              .toLowerCase()
              .replaceAll('á', 'a')
              .replaceAll('é', 'e')
              .replaceAll('í', 'i')
              .replaceAll('ó', 'o')
              .replaceAll('ú', 'u')
              .replaceAll('ñ', 'n');
          return nombreNormalizado.contains(queryNormalizado);
        }).toList();
      }
    });
  }

  // Método para mostrar el panel con la plaza seleccionada
  void mostrarPantallaFlotante(Map<String, dynamic> plaza) {
    setState(() {
      _selectedPlaza = plaza;
      _selectedPlazaId = plaza['id']; // Guardar ID del marcador seleccionado
      _isPanelVisible = true;
      _isSearching = false;
      _searchController.clear();
      _filteredPlazas = [];
    });

    // Centrar el mapa en la plaza seleccionada con animación (fly-to)
    final LatLng coordenadas = plaza['coordenadas'];
    _mapController.move(coordenadas, 17.0); // Zoom 17 para ver mejor el área
  }

  // Método para ocultar el panel
  void _hidePanel() {
    setState(() {
      _isPanelVisible = false;
      _selectedPlaza = null;
      _selectedPlazaId = null; // Limpiar selección
    });
  }

  // Método auxiliar para capitalizar nombres
  String _capitalizeName(String name) {
    return name
        .split(' ')
        .map(
          (palabra) => palabra.isEmpty
              ? ''
              : palabra[0].toUpperCase() + palabra.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  // Método para construir el panel lateral (reemplaza el showDialog anterior)
  Widget _buildSidePanel() {
    if (!_isPanelVisible) {
      return const SizedBox.shrink();
    }

    final plaza = _selectedPlaza;
    final nombreCapitalizado = plaza != null
        ? _capitalizeName(plaza['nombre'])
        : '';

    // Obtener dimensiones de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;

    // Margen lateral proporcional (4% del ancho)
    final horizontalMargin = screenWidth * 0.04;

    // Ancho adaptativo inteligente según tipo de dispositivo
    double panelWidthPercent;
    double maxPanelWidth;

    if (screenWidth < 360) {
      // Teléfonos pequeños: 92% ancho, máx 340px
      panelWidthPercent = 0.92;
      maxPanelWidth = 340;
    } else if (screenWidth <= 420) {
      // Teléfonos estándar: 88% ancho, máx 400px
      panelWidthPercent = 0.88;
      maxPanelWidth = 400;
    } else if (screenWidth <= 600) {
      // Teléfonos grandes: 85% ancho, máx 480px
      panelWidthPercent = 0.85;
      maxPanelWidth = 480;
    } else if (screenWidth <= 900) {
      // Tablets pequeñas: 70% ancho, máx 600px
      panelWidthPercent = 0.70;
      maxPanelWidth = 600;
    } else {
      // Tablets grandes/Desktop: 50% ancho, máx 800px
      panelWidthPercent = 0.50;
      maxPanelWidth = 800;
    }

    final calculatedWidth = screenWidth * panelWidthPercent;
    final finalPanelWidth = calculatedWidth.clamp(280.0, maxPanelWidth);

    return Positioned(
      left: horizontalMargin,
      top: topPadding + 8,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: -400.0, end: 0.0),
        builder: (context, value, child) {
          return Transform.translate(offset: Offset(value, 0), child: child);
        },
        child: Material(
          elevation: 0,
          borderRadius: BorderRadius.circular(14),
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: finalPanelWidth,
              minWidth: finalPanelWidth,
              maxHeight: screenHeight * 0.72,
            ),
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 8,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Encabezado con título y botón cerrar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'Áreas Verdes',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: _hidePanel,
                            icon: const Icon(Icons.close),
                            color: const Color(0xFF6B7280),
                            iconSize: 20,
                            padding: const EdgeInsets.all(6),
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Barra de búsqueda
                    TextField(
                      controller: _searchController,
                      onChanged: _filterPlazas,
                      decoration: InputDecoration(
                        hintText: 'Buscar por ID o nombre...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF6B7280),
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Color(0xFF6B7280),
                                  size: 20,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _filterPlazas('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF3B82F6),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CONTENIDO DEL PANEL (resultados de búsqueda o información de plaza)
                    if (_isSearching)
                      _buildSearchResults()
                    else if (plaza != null)
                      _buildPlazaInfo(plaza, nombreCapitalizado),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para mostrar resultados de búsqueda
  Widget _buildSearchResults() {
    if (_filteredPlazas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text(
          'No se encontraron resultados',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredPlazas.length,
      itemBuilder: (context, index) {
        final plaza = _filteredPlazas[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                plaza['id'],
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ),
          title: Text(
            _capitalizeName(plaza['nombre']),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          subtitle: Text(
            plaza['comuna'],
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
          onTap: () {
            mostrarPantallaFlotante(plaza);
          },
        );
      },
    );
  }

  // Widget para mostrar información de la plaza seleccionada
  Widget _buildPlazaInfo(
    Map<String, dynamic> plaza,
    String nombreCapitalizado,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Título
          Flexible(
            child: Text(
              nombreCapitalizado,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${plaza['id']}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),

          // DATOS TÉCNICOS
          _buildSidebarDataRow('Estado', plaza['estado']),
          const SizedBox(height: 12),
          _buildSidebarDataRow('Tipo', plaza['tipo']),
          const SizedBox(height: 12),
          _buildSidebarDataRow('Comuna', plaza['comuna']),
          const SizedBox(height: 12),
          _buildSidebarDataRow('Dirección', plaza['direccion']),
          const SizedBox(height: 20),

          // BOTONES DE ACCIÓN (nueva paleta de colores)
          _buildNewSidebarButton(
            label: 'Cómo llegar',
            icon: Icons.navigation_outlined,
            backgroundColor: const Color(0xFFE0F2FE),
            borderColor: const Color(0xFFBAE6FD),
            textColor: const Color(0xFF0369A1),
            onPressed: () => _abrirRuta(plaza),
          ),
          const SizedBox(height: 8),
          _buildNewSidebarButton(
            label: 'Ver Ficha Técnica',
            icon: Icons.description_outlined,
            backgroundColor: const Color(0xFFDCFCE7),
            borderColor: const Color(0xFFBBF7D0),
            textColor: const Color(0xFF15803D),
            onPressed: () => _verFichaTecnica(plaza),
          ),
          const SizedBox(height: 8),
          _buildNewSidebarButton(
            label: 'Ver Ficha de Inspección',
            icon: Icons.assignment_outlined,
            backgroundColor: const Color(0xFFFEF9C3),
            borderColor: const Color(0xFFFEF08A),
            textColor: const Color(0xFFA16207),
            onPressed: () => _verFichaInspeccion(plaza),
          ),
          const SizedBox(height: 8),
          _buildNewSidebarButton(
            label: 'Catastro de Inmuebles',
            icon: Icons.domain_verification_outlined,
            backgroundColor: const Color(0xFFE0E7FF),
            borderColor: const Color(0xFFC7D2FE),
            textColor: const Color(0xFF4338CA),
            onPressed: () => _verCatastroInmuebles(plaza),
          ),
          const SizedBox(height: 8),
          _buildNewSidebarButton(
            label: 'Inspección de Urgencia',
            icon: Icons.warning_outlined,
            backgroundColor: const Color(0xFFFFE4E1),
            borderColor: const Color(0xFFFFC5C0),
            textColor: const Color(0xFFB91C1C),
            onPressed: () => _verInspeccionUrgencia(plaza),
          ),
        ],
      ),
    );
  }

  // Widget para construir filas de datos en el sidebar
  Widget _buildSidebarDataRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Color(0xFF374151),
            height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Widget para construir botones del sidebar con colores personalizados (nueva paleta)
  Widget _buildNewSidebarButton({
    required String label,
    required IconData icon,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: borderColor, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ).copyWith(
              overlayColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.hovered)) {
                  // Oscurecer 10% al hacer hover
                  return Color.fromRGBO(
                    ((backgroundColor.r * 255.0).round().clamp(0, 255) * 0.9)
                        .round(),
                    ((backgroundColor.g * 255.0).round().clamp(0, 255) * 0.9)
                        .round(),
                    ((backgroundColor.b * 255.0).round().clamp(0, 255) * 0.9)
                        .round(),
                    1,
                  );
                }
                return backgroundColor;
              }),
            ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Función para abrir Google Maps con la ruta
  Future<void> _abrirRuta(Map<String, dynamic> plaza) async {
    final LatLng coordenadas = plaza['coordenadas'];
    final lat = coordenadas.latitude;
    final lng = coordenadas.longitude;

    // URL de Google Maps con direcciones
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir Google Maps'),
              backgroundColor: Color(0xFFC53030),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al abrir la ruta: $e'),
            backgroundColor: const Color(0xFFC53030),
          ),
        );
      }
    }
  }

  // Función para ver ficha técnica
  Future<void> _verFichaTecnica(Map<String, dynamic> plaza) async {
    // Ya no cerramos el diálogo porque ahora es un panel persistente

    final String plazaId = plaza['id'];
    final String? urlFicha = enlacesFichas[plazaId];

    if (urlFicha != null) {
      // Si existe el enlace, abrirlo en el navegador
      final Uri url = Uri.parse(urlFicha);

      try {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se pudo abrir la ficha técnica'),
                backgroundColor: Color(0xFFC53030),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al abrir la ficha: $e'),
              backgroundColor: const Color(0xFFC53030),
            ),
          );
        }
      }
    } else {
      // Si no existe el enlace, mostrar mensaje
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF2F855A),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Ficha Técnica',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A202C),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD97706),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFD97706),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'La ficha técnica para "${plaza['nombre']}" aún no está disponible.',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 14,
                              color: Color(0xFF8B5A00),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F855A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'CERRAR',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  // Función para ver ficha de inspección
  void _verFichaInspeccion(Map<String, dynamic> plaza) {
    // Navegar a la pantalla de inspección técnica
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InspeccionTecnicaScreen(
          plazaId: plaza['id'] ?? '',
          nombrePlaza: plaza['nombre'] ?? '',
        ),
      ),
    );
  }

  // Función para ver catastro de inmuebles
  void _verCatastroInmuebles(Map<String, dynamic> plaza) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CatastroInmueblesScreen(
          plazaId: plaza['id'] ?? '',
          nombrePlaza: plaza['nombre'] ?? '',
        ),
      ),
    );
  }

  // Función para ver inspección de urgencia
  void _verInspeccionUrgencia(Map<String, dynamic> plaza) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => InspeccionUrgenciaScreen(
          plazaId: plaza['id'] ?? '',
          nombrePlaza: plaza['nombre'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Áreas Verdes - Doñihue'),
        backgroundColor: const Color(0xFF1A202C),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Mapa principal
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centroDonihue,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app_areas_verdes',
              ),
              MarkerLayer(
                markers: misPlazas.map((plaza) {
                  // Color del marcador según el estado
                  Color markerColor;
                  switch (plaza['estado'].toString().toLowerCase()) {
                    case 'excelente':
                      markerColor = const Color(
                        0xFF2F855A,
                      ); // Verde institucional
                      break;
                    case 'bueno':
                      markerColor = const Color(0xFF2B6CB0); // Azul corporativo
                      break;
                    case 'regular':
                      markerColor = const Color(0xFFD97706); // Naranja
                      break;
                    default:
                      markerColor = const Color(0xFF718096); // Gris
                  }

                  return Marker(
                    point: plaza['coordenadas'],
                    width: 64,
                    height: 76,
                    child: GestureDetector(
                      onTap: () => mostrarPantallaFlotante(plaza),
                      child: SophisticatedMarker(
                        icon: Icons.park_outlined,
                        accentColor: markerColor,
                        size: 44,
                        isSelected: plaza['id'] == _selectedPlazaId,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Información inferior
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tarjeta del encargado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Encargado de Área:',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Felipe Lagos',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                      const Text(
                        'Ingeniero Agrónomo',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tarjeta de versión
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Version 12.11 © 2026 Josue_Muñoz',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Botón flotante para abrir el panel (solo visible cuando está oculto)
          if (!_isPanelVisible)
            Positioned(
              left: MediaQuery.of(context).size.width * 0.04,
              top: MediaQuery.of(context).padding.top + 8,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _isPanelVisible = true;
                  });
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.search, color: Color(0xFF374151)),
              ),
            ),

          // Panel lateral (siempre visible cuando _isPanelVisible es true)
          _buildSidePanel(),
        ],
      ),
    );
  }
}

// Trigger para despliegue automático
