import datetime
import random
from flask import Blueprint, request, jsonify
from firebase_config import db

orders_bp = Blueprint("orders", __name__)
COLLECTION = "orders"

@orders_bp.route("", methods=["GET"])
@orders_bp.route("/", methods=["GET"])
def get_orders():
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        phone = request.args.get("phone")
        status = request.args.get("status")

        query = db.collection(COLLECTION)
        if phone:
            query = query.where("customerPhone", "==", phone)
        if status:
            query = query.where("status", "==", status)

        docs = query.order_by("orderDate", direction="DESCENDING").stream()
        orders = []
        for doc in docs:
            od = doc.to_dict()
            od["id"] = doc.id
            if "orderDate" in od and hasattr(od["orderDate"], "isoformat"):
                od["orderDate"] = od["orderDate"].isoformat()
            orders.append(od)

        return jsonify({"success": True, "count": len(orders), "data": orders})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@orders_bp.route("/<order_id>", methods=["GET"])
def track_order(order_id):
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        doc = db.collection(COLLECTION).document(order_id).get()
        if not doc.exists:
            # Check by orderId field
            query = db.collection(COLLECTION).where("orderId", "==", order_id).limit(1).stream()
            matching = list(query)
            if not matching:
                return jsonify({"success": False, "message": "Order not found"}), 404
            data = matching[0].to_dict()
            data["id"] = matching[0].id
            return jsonify({"success": True, "data": data})

        data = doc.to_dict()
        data["id"] = doc.id
        return jsonify({"success": True, "data": data})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@orders_bp.route("", methods=["POST"])
@orders_bp.route("/", methods=["POST"])
def create_order():
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        body = request.get_json(silent=True) or {}
        customer_name = body.get("customerName")
        customer_phone = body.get("customerPhone")
        delivery_method = body.get("deliveryMethod", "Pickup at Camp Meeting")
        delivery_address = body.get("deliveryAddress", "")
        items = body.get("items", [])
        total_amount = body.get("totalAmount", 0)
        colporteur_code = body.get("colporteurCode")

        if not customer_phone or not items:
            return jsonify({"success": False, "message": "Phone number and items are required."}), 400

        random_suffix = random.randint(1000, 9999)
        tracking_id = f"HV-{datetime.datetime.now().strftime('%Y%m%d')}-{random_suffix}"

        new_order = {
            "orderId": tracking_id,
            "customerName": customer_name or "Believer",
            "customerPhone": customer_phone,
            "deliveryMethod": delivery_method,
            "deliveryAddress": delivery_address,
            "items": items,
            "totalAmount": float(total_amount),
            "colporteurCode": colporteur_code or None,
            "status": "Pending Payment",
            "orderDate": datetime.datetime.now(datetime.timezone.utc),
            "paymentMethod": body.get("paymentMethod", "M-Pesa"),
        }

        update_time, doc_ref = db.collection(COLLECTION).add(new_order)
        new_order["id"] = doc_ref.id
        new_order["orderDate"] = new_order["orderDate"].isoformat()

        return jsonify({
            "success": True,
            "message": "Order created successfully. Please complete M-Pesa payment.",
            "orderId": tracking_id,
            "id": doc_ref.id,
            "data": new_order,
        }), 201
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@orders_bp.route("/<order_id>/status", methods=["PUT"])
def update_order_status(order_id):
    try:
        if db is None:
            return jsonify({"success": False, "message": "Database not initialized"}), 503

        body = request.get_json(silent=True) or {}
        new_status = body.get("status")
        if not new_status:
            return jsonify({"success": False, "message": "Status is required."}), 400

        doc_ref = db.collection(COLLECTION).document(order_id)
        doc = doc_ref.get()
        if not doc.exists:
            return jsonify({"success": False, "message": "Order not found"}), 404

        doc_ref.update({
            "status": new_status,
            "lastUpdated": datetime.datetime.now(datetime.timezone.utc),
        })

        return jsonify({"success": True, "message": f"Order status updated to {new_status}."})
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500

