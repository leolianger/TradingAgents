"""Minimal HTTP server for Olares entrance. TradingAgents is CLI-based; run via exec or API later."""
import http.server
import socketserver
import os

PORT = int(os.environ.get("PORT", "8080"))
DIR = os.path.join(os.path.dirname(__file__), "web_ui")

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIR, **kwargs)

    def log_message(self, format, *args):
        pass

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    httpd.serve_forever()
