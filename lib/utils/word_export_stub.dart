/// Stub para plataformas no-web
void downloadWordFile(String htmlContent, String filename) {
  // No hace nada en plataformas móviles
  throw UnsupportedError(
    'La exportación a Word solo está disponible en la versión web',
  );
}
