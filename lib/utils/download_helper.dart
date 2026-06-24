// Export condicional: exporta download_helper_web.dart para web, download_helper_mobile.dart para móvil
export 'download_helper_web.dart'
    if (dart.library.io) 'download_helper_mobile.dart';
