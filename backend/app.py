import os
import datetime
from flask import Flask, request, jsonify, send_from_directory, send_file
from dotenv import load_dotenv

load_dotenv()

# Initialize Flask App
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
PUBLIC_DIR = os.path.join(BASE_DIR, "public")
UPLOADS_DIR = os.path.join(BASE_DIR, "uploads")

os.makedirs(UPLOADS_DIR, exist_ok=True)
os.makedirs(PUBLIC_DIR, exist_ok=True)

app = Flask(__name__, static_folder="public", static_url_path="")
app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "harvion_sda_ministry_secret_key_2026")

# ==========================================
# 🌐 CORS MIDDLEWARE
# ==========================================
@app.after_request
def apply_cors_headers(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS, HEAD"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With, Accept"
    return response

@app.before_request
def handle_options_and_url_normalization():
    # Handle preflight CORS requests immediately
    if request.method == "OPTIONS":
        return "", 204

    # URL normalization for cPanel / Phusion Passenger
    path = request.path
    # Strip cPanel application subfolder prefix if present in URL
    for prefix in ["/harvion_api", "/harvion-api", "/harvion", "/public_html"]:
        if path.startswith(prefix):
            new_path = path[len(prefix):] or "/"
            request.environ["PATH_INFO"] = new_path
            break

# ==========================================
# 📁 STATIC UPLOADS SERVING
# ==========================================
@app.route("/uploads/<path:filename>")
def serve_upload(filename):
    return send_from_directory(UPLOADS_DIR, filename)

# ==========================================
# 🌐 WEB PAGES (HTML)
# ==========================================
@app.route("/", methods=["GET"])
@app.route("/home", methods=["GET"])
@app.route("/index.html", methods=["GET"])
def home():
    accepts_json = request.headers.get("Accept", "").startswith("application/json")
    if accepts_json:
        return jsonify({
            "status": "online",
            "name": "HARVION SDA Ministry Enterprise API (Python Flask)",
            "version": "2.0.0-FLASK",
            "framework": "Flask 3.0",
            "healthCheck": "/api/health",
            "webPages": {
                "home": "/",
                "about": "/about.html",
            },
            "endpoints": {
                "books": "/api/books",
                "orders": "/api/orders",
                "payments": "/api/payments",
                "colporteurs": "/api/colporteurs",
                "ministry": "/api/ministry",
                "sop": "/api/sop/books",
            },
            "serverTime": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "message": "HARVION Literature Evangelism, Health & Truth Platform is active on HostPinnacle."
        })

    index_path = os.path.join(PUBLIC_DIR, "index.html")
    if os.path.exists(index_path):
        return send_file(index_path)
    return "<h1>HARVION SDA Ministry Ecosystem (Python Flask)</h1>"


@app.route("/about", methods=["GET"])
@app.route("/about.html", methods=["GET"])
def about():
    about_path = os.path.join(PUBLIC_DIR, "about.html")
    if os.path.exists(about_path):
        return send_file(about_path)
    return send_file(os.path.join(PUBLIC_DIR, "index.html"))

# ==========================================
# ⚡ API DISCOVERY & HEALTH CHECK
# ==========================================
@app.route("/api", methods=["GET"])
def api_discovery():
    return jsonify({
        "status": "online",
        "name": "HARVION SDA Ministry Enterprise API",
        "version": "2.0.0-FLASK",
        "healthCheck": "/api/health",
        "webPages": {
            "home": "/",
            "about": "/about.html",
        },
        "endpoints": {
            "books": "/api/books",
            "orders": "/api/orders",
            "payments": "/api/payments",
            "colporteurs": "/api/colporteurs",
            "ministry": "/api/ministry",
            "sop": "/api/sop/books",
        },
        "serverTime": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    })


@app.route("/api/health", methods=["GET"])
def health_check():
    from firebase_config import db, PROJECT_ID
    return jsonify({
        "status": "online",
        "framework": "Python Flask",
        "name": "HARVION API Server",
        "version": "2.0.0-FLASK",
        "firebaseConnected": db is not None,
        "firebaseProject": PROJECT_ID,
        "time": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    })

# ==========================================
# 📦 REGISTER BLUEPRINTS
# ==========================================
from blueprints.books import books_bp
from blueprints.orders import orders_bp
from blueprints.payments import payments_bp
from blueprints.colporteurs import colporteurs_bp
from blueprints.ministry import ministry_bp
from blueprints.sop import sop_bp

app.register_blueprint(books_bp, url_prefix="/api/books")
app.register_blueprint(orders_bp, url_prefix="/api/orders")
app.register_blueprint(payments_bp, url_prefix="/api/payments")
app.register_blueprint(colporteurs_bp, url_prefix="/api/colporteurs")
app.register_blueprint(ministry_bp, url_prefix="/api/ministry")
app.register_blueprint(sop_bp, url_prefix="/api/sop")

# ==========================================
# 🛡️ 404 NOT FOUND HANDLER
# ==========================================
@app.errorhandler(404)
def not_found(e):
    if request.method == "GET" and request.accept_mimetypes.accept_html:
        index_path = os.path.join(PUBLIC_DIR, "index.html")
        if os.path.exists(index_path):
            return send_file(index_path)
    return jsonify({
        "success": False,
        "message": "Endpoint not found",
        "requestedUrl": request.url,
        "availableEndpoints": [
            "/",
            "/about.html",
            "/api/health",
            "/api/books",
            "/api/orders",
            "/api/payments",
            "/api/colporteurs",
            "/api/ministry",
            "/api/sop/books"
        ]
    }), 404

# ==========================================
# 🚨 500 INTERNAL SERVER ERROR HANDLER
# ==========================================
@app.errorhandler(500)
def server_error(e):
    return jsonify({
        "success": False,
        "error": "Internal Server Error",
        "message": str(e),
    }), 500

if __name__ == "__main__":
    port = int(os.getenv("PORT", 5000))
    print(f"🌱 HARVION Flask Server starting on http://localhost:{port}")
    app.run(host="0.0.0.0", port=port, debug=False)

