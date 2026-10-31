import datetime
from flask import Blueprint, request, jsonify
from firebase_config import db

ministry_bp = Blueprint("ministry", __name__)

@ministry_bp.route("/devotionals", methods=["GET"])
def get_devotionals():
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        docs = db.collection("devotionals").order_by("date", direction="DESCENDING").limit(30).stream()
        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@ministry_bp.route("/sabbath-school", methods=["GET"])
def get_sabbath_school_lessons():
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        docs = db.collection("sabbath_school_lessons").order_by("lessonNumber", direction="ASCENDING").stream()
        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@ministry_bp.route("/prayers", methods=["GET"])
def get_prayers():
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        category = request.args.get("category")
        query = db.collection("prayer_requests")
        if category and category != "All":
            query = query.where("category", "==", category)

        docs = query.order_by("datePosted", direction="DESCENDING").limit(50).stream()
        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@ministry_bp.route("/prayers", methods=["POST"])
def post_prayer():
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        body = request.get_json(silent=True) or {}
        title = body.get("title")
        description = body.get("description")

        if not title or not description:
            return jsonify({"success": False, "message": "Title and description required."}), 400

        is_anon = bool(body.get("isAnonymous", False))
        new_prayer = {
            "authorName": "A Fellow Believer" if is_anon else body.get("authorName", "Anonymous"),
            "isAnonymous": is_anon,
            "title": title,
            "description": description,
            "category": body.get("category", "General"),
            "datePosted": datetime.datetime.now(datetime.timezone.utc),
            "prayerCount": 1,
        }

        update_time, doc_ref = db.collection("prayer_requests").add(new_prayer)
        return jsonify({"success": True, "message": "Prayer request submitted.", "id": doc_ref.id}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@ministry_bp.route("/livestreams", methods=["GET"])
def get_livestreams():
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        docs = db.collection("livestreams").order_by("startTime", direction="DESCENDING").limit(20).stream()
        data = []
        for d in docs:
            item = d.to_dict()
            item["id"] = d.id
            data.append(item)
        return jsonify({"success": True, "count": len(data), "data": data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500
