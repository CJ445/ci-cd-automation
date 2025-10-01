#!/usr/bin/env python3
"""
Sample Flask Application for CI/CD Pipeline Demo
A simple REST API with health checks and version information.
"""

from flask import Flask, jsonify, request
import os
import socket
from datetime import datetime

app = Flask(__name__)

# Application version - update this with each release
VERSION = os.getenv('APP_VERSION', '1.0.0')
BUILD_SHA = os.getenv('BUILD_SHA', 'dev')

@app.route('/')
def home():
    """Home endpoint with application information."""
    return jsonify({
        'service': 'CI/CD Demo Application',
        'version': VERSION,
        'build_sha': BUILD_SHA,
        'status': 'running',
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/health')
def health():
    """Health check endpoint for monitoring."""
    return jsonify({
        'status': 'healthy',
        'version': VERSION,
        'hostname': socket.gethostname(),
        'timestamp': datetime.utcnow().isoformat()
    }), 200

@app.route('/api/echo', methods=['POST'])
def echo():
    """Echo endpoint that returns the posted data."""
    data = request.get_json()
    return jsonify({
        'received': data,
        'version': VERSION,
        'timestamp': datetime.utcnow().isoformat()
    })

@app.route('/api/info')
def info():
    """Detailed application information."""
    return jsonify({
        'application': {
            'name': 'CI/CD Demo Application',
            'version': VERSION,
            'build_sha': BUILD_SHA,
            'environment': os.getenv('ENVIRONMENT', 'development')
        },
        'system': {
            'hostname': socket.gethostname(),
            'python_version': os.sys.version
        },
        'timestamp': datetime.utcnow().isoformat()
    })

@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors."""
    return jsonify({
        'error': 'Not Found',
        'message': 'The requested resource does not exist',
        'version': VERSION
    }), 404

@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors."""
    return jsonify({
        'error': 'Internal Server Error',
        'message': 'An unexpected error occurred',
        'version': VERSION
    }), 500

if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
