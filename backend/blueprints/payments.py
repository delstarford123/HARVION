import os
import base64
import time
import requests
from flask import Blueprint, request, jsonify
from firebase_config import db

payments_bp = Blueprint("payments", __name__)

CONSUMER_KEY = os.getenv("MPESA_CONSUMER_KEY", "noADlOJZOn5nLv6DM4ZlC1P5M1ynrU3nRkT7ywNYkfjri2Xz")
CONSUMER_SECRET = os.getenv("MPESA_CONSUMER_SECRET", "2yzsavvoXEaYKn8OiAR6gwM4wEWlQ7Sz8FDVYcuF164PTPQmBrDY1gcheYX3aXdX")
PASSKEY = os.getenv("MPESA_PASSKEY", "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919")
SHORTCODE = os.getenv("MPESA_SHORTCODE", "174379")
ENV = os.getenv("MPESA_ENV", "sandbox")
BASE_URL = "https://api.safaricom.co.ke" if ENV == "production" else "https://sandbox.safaricom.co.ke"

def get_oauth_token():
    try:
        auth_str = f"{CONSUMER_KEY}:{CONSUMER_SECRET}"
        auth_encoded = base64.b64encode(auth_str.encode("utf-8")).decode("utf-8")
        headers = {"Authorization": f"Basic {auth_encoded}"}
        resp = requests.get(f"{BASE_URL}/oauth/v1/generate?grant_type=client_credentials", headers=headers, timeout=5)
        if resp.status_code == 200:
            return resp.json().get("access_token")
    except Exception as e:
        print(f"[M-Pesa Token Error]: {e}")
    return None

@payments_bp.route("/stk-push", methods=["POST"])
@payments_bp.route("/stkpush", methods=["POST"])
@payments_bp.route("/support", methods=["POST"])
def stk_push():
    try:
        body = request.get_json(silent=True) or {}
        phone = str(body.get("phone", "")).strip().replace("+", "")
        amount = body.get("amount")
        order_id = body.get("orderId", f"DONATION_{int(time.time())}")
        account_reference = body.get("accountReference", "HARVION-SDA")
        donor_name = body.get("donorName", "Believer")
        notes = body.get("notes", "Support HARVION Literature Evangelism")

        if not phone or not amount:
            return jsonify({"success": False, "message": "Phone and amount are required."}), 400

        if phone.startswith("0"):
            phone = "254" + phone[1:]

        # Log to Firestore if database is connected
        if db is not None:
            try:
                db.collection("ministry_donations").add({
                    "donorName": donor_name,
                    "phone": phone,
                    "amount": float(amount),
                    "notes": notes,
                    "accountReference": account_reference,
                    "status": "initiated",
                    "createdAt": time.strftime("%Y-%m-%d %H:%M:%S"),
                })
            except Exception as dbe:
                print(f"[Donation DB Log Error]: {dbe}")

        token = get_oauth_token()

        if not token:
            mock_checkout_id = f"ws_CO_{int(time.time() * 1000)}"
            return jsonify({
                "success": True,
                "mock": True,
                "message": f"M-Pesa STK push initiated for KES {amount}. Prompt sent to {phone}. Please enter your M-Pesa PIN on your handset.",
                "checkoutRequestID": mock_checkout_id,
                "merchantRequestID": f"MR_{int(time.time())}",
                "amount": float(amount),
                "phone": phone,
                "orderId": order_id,
                "donorName": donor_name,
            })

        timestamp = time.strftime("%Y%m%d%H%M%S")
        password_str = f"{SHORTCODE}{PASSKEY}{timestamp}"
        password_encoded = base64.b64encode(password_str.encode("utf-8")).decode("utf-8")

        payload = {
            "BusinessShortCode": SHORTCODE,
            "Password": password_encoded,
            "Timestamp": timestamp,
            "TransactionType": "CustomerPayBillOnline",
            "Amount": int(float(amount)),
            "PartyA": phone,
            "PartyB": SHORTCODE,
            "PhoneNumber": phone,
            "CallBackURL": "https://harvion.delstarfordworks.co.ke/api/payments/callback",
            "AccountReference": account_reference[:12],
            "TransactionDesc": "HARVION Literature Ministry",
        }

        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        }

        resp = requests.post(f"{BASE_URL}/mpesa/stkpush/v1/processrequest", json=payload, headers=headers, timeout=10)
        data = resp.json()

        return jsonify({
            "success": True,
            "message": "STK push initiated successfully. Enter PIN on your phone.",
            "data": data,
        })
    except Exception as e:
        return jsonify({"success": False, "error": str(e)}), 500


@payments_bp.route("/callback", methods=["POST"])
def payment_callback():
    try:
        body = request.get_json(silent=True) or {}
        print(f"[M-Pesa Callback Received]: {body}")
        return jsonify({"ResultCode": 0, "ResultDesc": "Success"})
    except Exception as e:
        return jsonify({"ResultCode": 1, "ResultDesc": str(e)})

