"""
K8s Docker Terraform POC - Simple Flask Application
Demonstrates a containerized web app for Kubernetes deployment.
"""

import os
import socket
from datetime import datetime

from flask import Flask, jsonify, render_template

app = Flask(__name__)

APP_NAME = os.getenv("APP_NAME", "K8s-Docker-Terraform POC")
APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
DB_HOST = os.getenv("DB_HOST", "localhost")
SECRET_KEY = os.getenv("SECRET_KEY", "default-secret")


@app.route("/")
def home():
    return render_template(
        "index.html",
        app_name=APP_NAME,
        version=APP_VERSION,
        environment=ENVIRONMENT,
        hostname=socket.gethostname(),
        timestamp=datetime.now().isoformat(),
    )


@app.route("/health")
def health():
    return jsonify({"status": "healthy", "timestamp": datetime.now().isoformat()})


@app.route("/ready")
def ready():
    return jsonify({"status": "ready", "version": APP_VERSION})


@app.route("/info")
def info():
    return jsonify(
        {
            "app_name": APP_NAME,
            "version": APP_VERSION,
            "environment": ENVIRONMENT,
            "hostname": socket.gethostname(),
            "db_host": DB_HOST,
            "timestamp": datetime.now().isoformat(),
        }
    )


@app.route("/stress")
def stress():
    """Endpoint to generate CPU load for testing HPA autoscaling."""
    result = 0
    for i in range(1_000_000):
        result += i * i
    return jsonify({"status": "done", "result": str(result)})


if __name__ == "__main__":
    port = int(os.getenv("PORT", "5000"))
    app.run(host="0.0.0.0", port=port, debug=(ENVIRONMENT == "development"))
