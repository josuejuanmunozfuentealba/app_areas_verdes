import http.server
import json
import os
import urllib.parse
from http.server import SimpleHTTPRequestHandler

WEB_DIR = r'C:\Users\HP PAVILION\app_areas_verdes\build\web'
DATA_FILE = r'C:\Users\HP PAVILION\app_areas_verdes\historial_data.json'

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
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            if os.path.exists(DATA_FILE):
                with open(DATA_FILE, 'r', encoding='utf-8') as f:
                    self.wfile.write(f.read().encode('utf-8'))
            else:
                self.wfile.write(b'{}')
        else:
            super().do_GET()

    def do_POST(self):
        if self.path == '/api/historial':
            length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(length)
            with open(DATA_FILE, 'w', encoding='utf-8') as f:
                f.write(body.decode('utf-8'))
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(b'{"ok": true}')
        else:
            self.send_response(404)
            self.end_headers()

    def log_message(self, format, *args):
        pass  # Silencia logs

if __name__ == '__main__':
    import socketserver
    PORT = 8080
    with socketserver.TCPServer(('', PORT), Handler) as httpd:
        print(f'Servidor corriendo en http://localhost:{PORT}')
        httpd.serve_forever()
