import datetime
from flask import Blueprint, request, jsonify
from firebase_config import db

colporteurs_bp = Blueprint("colporteurs", __name__)
COLLECTION = "colporteurs"

@colporteurs_bp.route("/<code_param>", methods=["GET"])
def verify_referral_code(code_param):
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        code = code_param.upper().strip()
        query = db.collection(COLLECTION).where("referralCode", "==", code).limit(1).stream()
        results = list(query)

        if not results:
            return jsonify({"success": False, "message": "Invalid colporteur referral code"}), 404

        data = results[0].to_dict()
        return jsonify({
            "success": True,
            "valid": True,
            "discountPercentage": 0.10,
            "colporteur": {
                "id": results[0].id,
                "name": data.get("name"),
                "churchConference": data.get("churchConference"),
                "referralCode": data.get("referralCode"),
            },
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@colporteurs_bp.route("/locations", methods=["GET"])
def get_camp_meeting_locations():
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        query = db.collection("camp_meeting_locations").order_by("updatedAt", direction="DESCENDING").limit(50).stream()
        locations = []
        for doc in query:
            item = doc.to_dict()
            item["id"] = doc.id
            locations.append(item)

        return jsonify({"success": True, "count": len(locations), "data": locations})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@colporteurs_bp.route("/<code_param>/leads", methods=["GET"])
def get_colporteur_leads(code_param):
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        code = code_param.upper().strip()
        query = db.collection(COLLECTION).where("referralCode", "==", code).limit(1).stream()
        results = list(query)

        if not results:
            return jsonify({"success": False, "message": "Colporteur not found"}), 404

        le_ref = db.collection(COLLECTION).document(results[0].id)
        leads_stream = le_ref.collection("leads").order_by("dateAdded", direction="DESCENDING").stream()
        leads = []
        for l in leads_stream:
            ld = l.to_dict()
            ld["id"] = l.id
            leads.append(ld)

        return jsonify({"success": True, "count": len(leads), "data": leads})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@colporteurs_bp.route("/<code_param>/leads", methods=["POST"])
def record_customer_lead(code_param):
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        code = code_param.upper().strip()
        query = db.collection(COLLECTION).where("referralCode", "==", code).limit(1).stream()
        results = list(query)

        if not results:
            return jsonify({"success": False, "message": "Colporteur not found"}), 404

        body = request.get_json(silent=True) or {}
        name = body.get("name")
        phone = body.get("phone")
        book_interest = body.get("bookInterest", "Spirit of Prophecy")

        if not name or not phone:
            return jsonify({"success": False, "message": "Name and phone are required."}), 400

        lead_data = {
            "name": name,
            "phone": phone,
            "bookInterest": book_interest,
            "status": "New Prospect",
            "dateAdded": datetime.datetime.now(datetime.timezone.utc),
            "notes": body.get("notes", ""),
        }

        le_ref = db.collection(COLLECTION).document(results[0].id)
        update_time, lead_doc = le_ref.collection("leads").add(lead_data)

        return jsonify({"success": True, "message": "Lead recorded successfully.", "id": lead_doc.id}), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

