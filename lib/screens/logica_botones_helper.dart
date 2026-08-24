// Export condicional: usa helper web para navegador, helper android para móvil
export 'logica_botones_helper_web.dart'
    if (dart.library.io) 'logica_botones_helper_android.dart';
