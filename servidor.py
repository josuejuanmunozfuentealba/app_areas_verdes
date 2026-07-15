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
        # Solo usar directory si existe
        if os.path.exists(WEB_DIR):
            super().__init__(*args, directory=WEB_DIR, **kwargs)
        else:
            # Usar directorio actual si no existe build/web
            super().__init__(*args, **kwargs)

    def do_OPTIONS(self):
        print(f'\n[OPTIONS] {self.path}')
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
        print('[OPTIONS] ✓ Respuesta CORS enviada')

    def do_GET(self):
        print(f'\n[GET] {self.path}')
        print(f'[Headers] {dict(self.headers)}')
        
        if self.path == '/api/historial':
            try:
                print('[Historial] Solicitando historial...')
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.send_header('Cache-Control', 'no-cache, no-store, must-revalidate')
                self.send_header('Pragma', 'no-cache')
                self.send_header('Expires', '0')
                self.end_headers()
                if os.path.exists(DATA_FILE):
                    with open(DATA_FILE, 'r', encoding='utf-8') as f:
                        content = f.read()
                        print(f'[Historial] Enviando datos ({len(content)} bytes)')
                        self.wfile.write(content.encode('utf-8'))
                else:
                    print('[Historial] Archivo no existe, enviando objeto vacío')
                    self.wfile.write(b'{}')
            except (ConnectionAbortedError, BrokenPipeError):
                print('[Error] Cliente cerró la conexión')
                pass  # Cliente cerró la conexión, ignorar
        elif self.path == '/api/health':
            try:
                print('[Health] Verificación de estado')
                # Endpoint de verificación
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(b'{"status": "ok", "message": "Servidor Python funcionando correctamente"}')
                print('[Health] ✓ Respuesta exitosa')
            except (ConnectionAbortedError, BrokenPipeError):
                print('[Error] Cliente cerró la conexión')
                pass
        else:
            try:
                # Dejar que el handler padre maneje archivos estáticos
                print(f'[Archivo] Sirviendo archivo estático: {self.path}')
                super().do_GET()
            except (ConnectionAbortedError, BrokenPipeError):
                print('[Error] Cliente cerró la conexión')
                pass  # Cliente cerró la conexión, ignorar

    def do_POST(self):
        print(f'\n[POST] {self.path}')
        print(f'[Headers] {dict(self.headers)}')
        
        if self.path == '/api/historial':
            try:
                length = int(self.headers.get('Content-Length', 0))
                print(f'[Historial] Recibiendo datos ({length} bytes)...')
                body = self.rfile.read(length)
                
                # Decodificar y mostrar los datos recibidos
                data_str = body.decode('utf-8')
                try:
                    data = json.loads(data_str)
                    print(f'[Historial] Datos recibidos correctamente')
                    print(f'[Historial] Estructura: {list(data.keys()) if isinstance(data, dict) else "lista"}')
                    
                    # Mostrar detalles de las secciones si existen
                    if isinstance(data, dict):
                        for key, value in data.items():
                            if isinstance(value, dict):
                                print(f'  - {key}: {list(value.keys())}')
                            elif isinstance(value, list):
                                print(f'  - {key}: lista con {len(value)} elementos')
                            else:
                                print(f'  - {key}: {type(value).__name__}')
                except json.JSONDecodeError as e:
                    print(f'[Historial] ⚠ Error al parsear JSON: {e}')
                
                with open(DATA_FILE, 'w', encoding='utf-8') as f:
                    f.write(data_str)
                print(f'[Historial] ✓ Guardado en: {DATA_FILE}')
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(b'{"ok": true}')
                print('[Historial] ✓ Respuesta enviada')
            except (ConnectionAbortedError, BrokenPipeError):
                print('[Error] Cliente cerró la conexión')
                pass  # Cliente cerró la conexión, ignorar
        elif self.path == '/api/send-email':
            try:
                # Endpoint para enviar correo (sin adjuntos)
                length = int(self.headers.get('Content-Length', 0))
                print(f'[Email] Recibiendo petición ({length} bytes)...')
                body = self.rfile.read(length)
                data = json.loads(body.decode('utf-8'))
                
                print(f'[Email] Destinatario: {data.get("destinatario", "N/A")}')
                print(f'[Email] Asunto: {data.get("asunto", "N/A")}')
                print(f'[Email] Cuerpo preview: {data.get("cuerpo", "N/A")[:100]}...')
                
                # Simular envío exitoso
                # TODO: Implementar envío real con smtplib si se necesita
                
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(b'{"success": true, "message": "Correo enviado exitosamente"}')
                print('[Email] ✓ Respuesta exitosa enviada')
            except (ConnectionAbortedError, BrokenPipeError):
                print('[Error] Cliente cerró la conexión')
                pass  # Cliente cerró la conexión, ignorar
            except Exception as e:
                print(f'[Email] ✗ Error: {str(e)}')
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                error_msg = json.dumps({"success": False, "error": str(e)})
                self.wfile.write(error_msg.encode('utf-8'))
        elif self.path == '/api/health':
            try:
                print('[Health] Verificación POST')
                # Endpoint de verificación
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(b'{"status": "ok", "message": "Servidor funcionando correctamente"}')
                print('[Health] ✓ Respuesta exitosa')
            except (ConnectionAbortedError, BrokenPipeError):
                print('[Error] Cliente cerró la conexión')
                pass
        else:
            print(f'[404] Endpoint no encontrado: {self.path}')
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        # Habilitar logs básicos de HTTP
        return

if __name__ == '__main__':
    import socketserver
    PORT = 3000  # CAMBIADO: Ahora usa puerto 3000
    
    # Verificar que el directorio web existe (opcional ahora)
    if not os.path.exists(WEB_DIR):
        print(f'ADVERTENCIA: No se encuentra el directorio web en: {WEB_DIR}')
        print(f'El servidor funcionará solo para APIs (sin servir archivos estáticos)')
        print(f'Para servir archivos, ejecuta primero: flutter build web')
        print()
    
    print('=' * 60)
    print('SERVIDOR PYTHON PARA APP ÁREAS VERDES')
    print('=' * 60)
    print(f'Directorio web: {WEB_DIR}')
    print(f'Archivo de datos: {DATA_FILE}')
    print(f'Servidor corriendo en http://localhost:{PORT}')
    print('=' * 60)
    print('Endpoints disponibles:')
    print('  GET  /api/health    - Verificar estado del servidor')
    print('  GET  /api/historial - Obtener historial de inspecciones')
    print('  POST /api/historial - Guardar inspección en historial')
    print('  POST /api/send-email - Enviar correo de notificación')
    print('=' * 60)
    print('Consola de monitoreo activa. Todas las peticiones se registrarán aquí.')
    print('Presiona Ctrl+C para detener el servidor.')
    print('=' * 60)
    
    # Usar ThreadingTCPServer para manejar múltiples conexiones
    class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
        allow_reuse_address = True
    
    with ThreadedTCPServer(('', PORT), Handler) as httpd:
        httpd.serve_forever()
