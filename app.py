import os
from flask import Flask, jsonify, request
import logging
from datetime import datetime

app = Flask(__name__, static_folder='.', static_url_path='')

logging.basicConfig(level=logging.INFO)

@app.before_request
def log_request_info():
    instance_id = os.environ.get("INSTANCE_ID", "local")
    app.logger.info(f"[{datetime.utcnow().isoformat()}] [{instance_id}] Request: {request.method} {request.url}")

@app.route('/')
def index():
    return app.send_static_file('index.html')

@app.route('/health')
def health():
    return jsonify({
        "status": "healthy",
        "instance": os.environ.get("INSTANCE_ID", "local")
    })

@app.route('/instance')
def instance():
    return os.environ.get("INSTANCE_ID", "local")

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
