import os
from flask import Blueprint, request, jsonify, send_file, redirect, render_template, Response
from models.hymn_db import (
    get_hymn_by_number,
    list_hymns,
    get_all_categories,
    save_hymn,
    seed_all_695_hymns,
    init_hymns_db
)

hymns_bp = Blueprint("hymns", __name__)

# Ensure DB table is initialized on blueprint load
try:
    init_hymns_db()
    seed_all_695_hymns(force=False)
except Exception as e:
    print(f"[Hymns Blueprint Warning] Auto-init notice: {e}")


# ==========================================
# 📖 1. LIST & SEARCH HYMNS (PAGINATED)
# ==========================================
@hymns_bp.route("", methods=["GET"])
def get_hymns():
    """
    Query parameters:
    - page: int (default 1)
    - limit: int (default 50)
    - search / q: string (search hymn number, title, author, or lyrics)
    - category: string (filter by section, e.g. "The Holy Sabbath", "Grace / Assurance")
    """
    page = request.args.get("page", 1, type=int)
    limit = request.args.get("limit", 50, type=int)
    search = request.args.get("search", request.args.get("q", "")).strip()
    category = request.args.get("category", "").strip()

    result = list_hymns(page=page, limit=limit, search=search, category=category)
    return jsonify(result)


# ==========================================
# 🏷️ 2. GET ALL HYMNAL CATEGORIES
# ==========================================
@hymns_bp.route("/categories", methods=["GET"])
def get_categories():
    categories = get_all_categories()
    return jsonify({
        "success": True,
        "totalCategories": len(categories),
        "categories": categories
    })


# ==========================================
# 🎵 3. GET SINGLE HYMN DETAILS
# ==========================================
@hymns_bp.route("/<int:number>", methods=["GET"])
def get_hymn(number: int):
    hymn = get_hymn_by_number(number)
    if not hymn:
        return jsonify({
            "success": False,
            "error": "HymnNotFound",
            "message": f"Hymn #{number} does not exist in the 695 SDA Hymnal."
        }), 404

    return jsonify({
        "success": True,
        "hymn": hymn
    })


# ==========================================
# 🔊 4. AUDIO STREAMING & CACHING ROUTE
# ==========================================
@hymns_bp.route("/<int:number>/audio", methods=["GET"])
def stream_hymn_audio(number: int):
    """
    Serves the offline audio file with strong caching headers
    so browsers and Service Workers cache the audio permanently.
    """
    hymn = get_hymn_by_number(number)
    if not hymn:
        return jsonify({"success": False, "message": "Hymn not found"}), 404

    audio_url = hymn.get("audio_url", "")

    # 1. Check if local MP3 file exists in static/audio/hymns
    local_rel_path = os.path.join("public", "static", "audio", "hymns", f"{number}.mp3")
    local_abs_path = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", local_rel_path))

    if os.path.exists(local_abs_path):
        resp = send_file(local_abs_path, mimetype="audio/mpeg")
        resp.headers["Cache-Control"] = "public, max-age=31536000, immutable"
        resp.headers["Accept-Ranges"] = "bytes"
        return resp

    # 2. If remote audio URL provided, redirect with cache headers
    if audio_url.startswith("http"):
        resp = redirect(audio_url, code=302)
        resp.headers["Cache-Control"] = "public, max-age=86400"
        return resp

    # 3. Fallback to public archive audio
    archive_url = f"https://archive.org/download/sda-hymnal-instrumental/{number:03d}.mp3"
    return redirect(archive_url, code=302)


# ==========================================
# 🌱 5. SEED DATABASE (ALL 695 HYMNS)
# ==========================================
@hymns_bp.route("/seed", methods=["POST", "GET"])
def seed_hymns():
    force = request.args.get("force", "false").lower() == "true"
    count = seed_all_695_hymns(force=force)
    return jsonify({
        "success": True,
        "message": f"Successfully initialized and verified all {count} SDA hymns.",
        "totalHymns": count,
        "offlineStorage": "SQLite + Local CacheStorage Ready"
    })


# ==========================================
# ✍️ 6. ADMIN CREATE OR UPDATE HYMN
# ==========================================
@hymns_bp.route("", methods=["POST"])
@hymns_bp.route("/<int:number>", methods=["PUT"])
def update_or_create_hymn(number: int = None):
    data = request.get_json(silent=True) or {}
    if number is not None:
        data["hymn_number"] = number

    if "hymn_number" not in data:
        return jsonify({"success": False, "message": "hymn_number is required."}), 400

    try:
        saved = save_hymn(data)
        return jsonify({
            "success": True,
            "message": f"Hymn #{saved.get('hymn_number')} saved successfully.",
            "hymn": saved
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 400

