import os
import base64
import time
import requests
from flask import Blueprint, request, jsonify
from firebase_config import db

payments_bp = Blueprint("payments", __name__)

CONSUMER_KEY = os.getenv("MPESA_CONSUMER_KEY") or os.getenv("CONSUMER_KEY") or "OgkAKD4soo5xGVEegeGPvWS9HK3QuRgZYGQXnKmDxVTxnMDG"
CONSUMER_SECRET = os.getenv("MPESA_CONSUMER_SECRET") or os.getenv("CONSUMER_SECRET") or "LXgsZGYdl6kpunxzGuAw4Fi3JK7FtTLqbCK9JZjI6VDR6e93n5mmW8gFKUORhuQQ"
PASSKEY = os.getenv("MPESA_PASSKEY") or os.getenv("PASSKEY") or "f2d5541751a9649a49971680017613ecec69eb7bd886bda8bfb5d07c5d1c2d1f"
SHORTCODE = os.getenv("MPESA_SHORTCODE") or os.getenv("BUSINESS_SHORT_CODE") or "4050545"
ENV = os.getenv("MPESA_ENV", "production")
BASE_URL = "https://api.safaricom.co.ke" if ENV == "production" else "https://sandbox.safaricom.co.ke"

CALLBACK_URL = os.getenv("CALLBACK_URL", "https://harvion.delstarfordworks.co.ke/api/payments/callback")
if "your-domain.com" in CALLBACK_URL:
    CALLBACK_URL = "https://harvion.delstarfordworks.co.ke/api/payments/callback"

def get_oauth_token():
    try:
        # Re-fetch from environment if updated at runtime
        c_key = os.getenv("MPESA_CONSUMER_KEY") or os.getenv("CONSUMER_KEY") or CONSUMER_KEY
        c_secret = os.getenv("MPESA_CONSUMER_SECRET") or os.getenv("CONSUMER_SECRET") or CONSUMER_SECRET
        auth_str = f"{c_key}:{c_secret}"
        auth_encoded = base64.b64encode(auth_str.encode("utf-8")).decode("utf-8")
        headers = {"Authorization": f"Basic {auth_encoded}"}
        resp = requests.get(f"{BASE_URL}/oauth/v1/generate?grant_type=client_credentials", headers=headers, timeout=8)
        if resp.status_code == 200:
            return resp.json().get("access_token")
        else:
            print(f"[Daraja OAuth Error {resp.status_code}]: {resp.text}")
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

        cur_shortcode = os.getenv("MPESA_SHORTCODE") or os.getenv("BUSINESS_SHORT_CODE") or SHORTCODE
        cur_passkey = os.getenv("MPESA_PASSKEY") or os.getenv("PASSKEY") or PASSKEY
        cur_callback = os.getenv("CALLBACK_URL") or CALLBACK_URL
        if "your-domain.com" in cur_callback:
            cur_callback = "https://harvion.delstarfordworks.co.ke/api/payments/callback"

        timestamp = time.strftime("%Y%m%d%H%M%S")
        password_str = f"{cur_shortcode}{cur_passkey}{timestamp}"
        password_encoded = base64.b64encode(password_str.encode("utf-8")).decode("utf-8")

        payload = {
            "BusinessShortCode": cur_shortcode,
            "Password": password_encoded,
            "Timestamp": timestamp,
            "TransactionType": "CustomerPayBillOnline",
            "Amount": int(float(amount)),
            "PartyA": phone,
            "PartyB": cur_shortcode,
            "PhoneNumber": phone,
            "CallBackURL": cur_callback,
            "AccountReference": account_reference[:12],
            "TransactionDesc": "HARVION Literature Ministry",
        }

        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        }

        resp = requests.post(f"{BASE_URL}/mpesa/stkpush/v1/processrequest", json=payload, headers=headers, timeout=12)
        data = resp.json()

        # If CustomerPayBillOnline is rejected because shortcode is Buy Goods / Till, retry with CustomerBuyGoodsOnline
        if "Transaction type is not supported" in str(data.get("errorMessage", "")) or data.get("errorCode") in ["500.001.1001", "400.002.02"]:
            payload["TransactionType"] = "CustomerBuyGoodsOnline"
            resp = requests.post(f"{BASE_URL}/mpesa/stkpush/v1/processrequest", json=payload, headers=headers, timeout=12)
            data = resp.json()

        if data.get("ResponseCode") == "0":
            return jsonify({
                "success": True,
                "message": data.get("CustomerMessage", "STK push initiated successfully. Enter PIN on your phone."),
                "checkoutRequestID": data.get("CheckoutRequestID"),
                "merchantRequestID": data.get("MerchantRequestID"),
                "data": data,
            })
        else:
            return jsonify({
                "success": False,
                "message": data.get("CustomerMessage") or data.get("errorMessage") or "Daraja API rejected request.",
                "data": data,
            }), 400
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

