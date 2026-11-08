import os
import datetime
from flask import Flask, request, jsonify, send_from_directory, send_file, render_template
from dotenv import load_dotenv

load_dotenv()

# Initialize Flask App
BASE_DIR = os.path.abspath(os.path.dirname(__file__))
PUBLIC_DIR = os.path.join(BASE_DIR, "public")

# On Vercel / Serverless, local filesystem is read-only except /tmp
IS_SERVERLESS = bool(os.getenv("VERCEL") or os.getenv("AWS_LAMBDA_FUNCTION_NAME"))
if IS_SERVERLESS:
    UPLOADS_DIR = os.path.join("/tmp", "uploads")
else:
    UPLOADS_DIR = os.path.join(BASE_DIR, "uploads")

try:
    os.makedirs(UPLOADS_DIR, exist_ok=True)
    if not IS_SERVERLESS:
        os.makedirs(PUBLIC_DIR, exist_ok=True)
except Exception:
    pass

app = Flask(__name__, static_folder="public", static_url_path="", template_folder="templates")
app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "harvion_sda_ministry_secret_key_2026")

# Configure Jinja to look in both backend/templates and root templates directory
try:
    from jinja2 import ChoiceLoader, FileSystemLoader
    app.jinja_loader = ChoiceLoader([
        FileSystemLoader(os.path.join(BASE_DIR, "templates")),
        FileSystemLoader(os.path.join(os.path.dirname(BASE_DIR), "templates")),
        FileSystemLoader(PUBLIC_DIR),
    ])
except Exception as je:
    print(f"[Jinja Loader Info]: {je}")

# ==========================================
# 🚀 WSGI PATH NORMALIZATION MIDDLEWARE
# ==========================================
class VercelPathMiddleware:
    def __init__(self, wsgi_app):
        self.wsgi_app = wsgi_app

    def __call__(self, environ, start_response):
        # 1. Check for __vercel_route_path__ injected by vercel.json rewrite
        query_string = environ.get("QUERY_STRING", "")
        if "__vercel_route_path__=" in query_string:
            from urllib.parse import parse_qs, urlencode
            params = parse_qs(query_string, keep_blank_values=True)
            if "__vercel_route_path__" in params:
                raw_path = params.pop("__vercel_route_path__")[0]
                # Clean up query string so Flask app doesn't see internal rewrite param
                environ["QUERY_STRING"] = urlencode(params, doseq=True)
                if not raw_path.startswith("/"):
                    raw_path = "/" + raw_path
                environ["PATH_INFO"] = raw_path

        # 2. URL normalization for cPanel / Phusion Passenger subfolders
        path = environ.get("PATH_INFO", "")
        for prefix in ["/harvion_api", "/harvion-api", "/harvion", "/public_html"]:
            if path.startswith(prefix):
                environ["PATH_INFO"] = path[len(prefix):] or "/"
                break

        return self.wsgi_app(environ, start_response)

app.wsgi_app = VercelPathMiddleware(app.wsgi_app)

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
def handle_options_requests():
    # Handle preflight CORS requests immediately
    if request.method == "OPTIONS":
        return "", 204

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
@app.route("/home.html", methods=["GET"])
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
                "hymns": "/api/hymns",
            },
            "serverTime": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "message": "HARVION Literature Evangelism, Health & Truth Platform is active on HostPinnacle."
        })

    try:
        return render_template("home.html")
    except Exception:
        index_path = os.path.join(PUBLIC_DIR, "index.html")
        if os.path.exists(index_path):
            return send_file(index_path)
        return "<h1>HARVION SDA Ministry Ecosystem (Python Flask)</h1>"


@app.route("/about", methods=["GET"])
@app.route("/about.html", methods=["GET"])
def about():
    try:
        return render_template("about.html")
    except Exception:
        about_path = os.path.join(PUBLIC_DIR, "about.html")
        if os.path.exists(about_path):
            return send_file(about_path)
        return send_file(os.path.join(PUBLIC_DIR, "index.html"))


@app.route("/contact", methods=["GET"])
@app.route("/contact.html", methods=["GET"])
def contact():
    try:
        return render_template("contact.html")
    except Exception:
        contact_path = os.path.join(PUBLIC_DIR, "contact.html")
        if os.path.exists(contact_path):
            return send_file(contact_path)
        return send_file(os.path.join(PUBLIC_DIR, "index.html"))


@app.route("/support", methods=["GET"])
@app.route("/support.html", methods=["GET"])
def support():
    try:
        return render_template("support.html")
    except Exception:
        support_path = os.path.join(PUBLIC_DIR, "support.html")
        if os.path.exists(support_path):
            return send_file(support_path)
        return send_file(os.path.join(PUBLIC_DIR, "index.html"))


@app.route("/books", methods=["GET"])
@app.route("/books.html", methods=["GET"])
@app.route("/library", methods=["GET"])
@app.route("/library.html", methods=["GET"])
def books_library():
    try:
        return render_template("books.html")
    except Exception:
        books_path = os.path.join(PUBLIC_DIR, "books.html")
        if os.path.exists(books_path):
            return send_file(books_path)
        return send_file(os.path.join(PUBLIC_DIR, "index.html"))


@app.route("/hymns", methods=["GET"])
@app.route("/hymns.html", methods=["GET"])
@app.route("/hymnal", methods=["GET"])
@app.route("/hymnal.html", methods=["GET"])
def hymns_library():
    try:
        return render_template("hymns.html")
    except Exception:
        hymns_path = os.path.join(PUBLIC_DIR, "hymns.html")
        if os.path.exists(hymns_path):
            return send_file(hymns_path)
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
            "support": "/support.html",
            "contact": "/contact.html",
            "books": "/books.html",
            "hymns": "/hymns.html",
        },
        "endpoints": {
            "books": "/api/books",
            "orders": "/api/orders",
            "payments": "/api/payments",
            "colporteurs": "/api/colporteurs",
            "ministry": "/api/ministry",
            "sop": "/api/sop/books",
            "hymns": "/api/hymns",
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
        "hymnalAvailable": True,
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
from blueprints.hymns import hymns_bp

app.register_blueprint(books_bp, url_prefix="/api/books")
app.register_blueprint(orders_bp, url_prefix="/api/orders")
app.register_blueprint(payments_bp, url_prefix="/api/payments")
app.register_blueprint(colporteurs_bp, url_prefix="/api/colporteurs")
app.register_blueprint(ministry_bp, url_prefix="/api/ministry")
app.register_blueprint(sop_bp, url_prefix="/api/sop")
app.register_blueprint(hymns_bp, url_prefix="/api/hymns")

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
            "/support.html",
            "/contact.html",
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

