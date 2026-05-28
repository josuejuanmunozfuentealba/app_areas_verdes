import http.server
import json
import os
import sys
import urllib.parse
from http.server import SimpleHTTPRequestHandler

# Obtener el directorio donde está este script
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
WEB_DIR = os.path.join(SCRIPT_DIR, 'build', 'web')
DATA_FILE = os.path.join(SCRIPT_DIR, 'historial_data.json')

class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=WEB_DIR, **kwargs)

    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

    def do_GET(self):
        if self.path == '/api/historial':
            try:
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
                self.send_header('Pragma', 'no-cache')
                self.send_header('Expires', '0')
                self.end_headers()
                if os.path.exists(DATA_FILE):
                    with open(DATA_FILE, 'r', encoding='utf-8') as f:
                        self.wfile.write(f.read().encode('utf-8'))
                else:
                    self.wfile.write(b'{}')
            except (ConnectionAbortedError, BrokenPipeError):
                pass  # Cliente cerró la conexión, ignorar
        else:
            try:
                # Dejar que el handler padre maneje archivos estáticos
                super().do_GET()
            except (ConnectionAbortedError, BrokenPipeError):
                pass  # Cliente cerró la conexión, ignorar

    def do_POST(self):
        if self.path == '/api/historial':
            try:
                length = int(self.headers.get('Content-Length', 0))
                body = self.rfile.read(length)
                with open(DATA_FILE, 'w', encoding='utf-8') as f:
                    f.write(body.decode('utf-8'))
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(b'{"ok": true}')
            except (ConnectionAbortedError, BrokenPipeError):
                pass  # Cliente cerró la conexión, ignorar
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass  # Silencia logs

if __name__ == '__main__':
    import socketserver
    PORT = 8080
    
    # Verificar que el directorio web existe
    if not os.path.exists(WEB_DIR):
        print(f'ERROR: No se encuentra el directorio web en: {WEB_DIR}')
        print(f'Directorio del script: {SCRIPT_DIR}')
        sys.exit(1)
    
    print(f'Directorio web: {WEB_DIR}')
    print(f'Archivo de datos: {DATA_FILE}')
    print(f'Servidor corriendo en http://localhost:{PORT}')
    
    # Usar ThreadingTCPServer para manejar múltiples conexiones
    class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
        allow_reuse_address = True
    
    with ThreadedTCPServer(('', PORT), Handler) as httpd:
        httpd.serve_forever()
