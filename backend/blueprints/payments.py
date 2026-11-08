import os
import base64
import time
import requests
from flask import Blueprint, request, jsonify
from firebase_config import db

payments_bp = Blueprint("payments", __name__)

def clean_val(v):
    if not v:
        return ""
    s = str(v).strip()
    # Strip Byte Order Mark (BOM), newlines, carriage returns, and enclosing quotes
    s = s.replace("\ufeff", "").replace("\r", "").replace("\n", "")
    s = s.strip('"').strip("'").strip('\\').strip('"').strip("'").strip()
    return s

CONSUMER_KEY = clean_val(os.getenv("MPESA_CONSUMER_KEY") or os.getenv("CONSUMER_KEY") or "OgkAKD4soo5xGVEegeGPvWS9HK3QuRgZYGQXnKmDxVTxnMDG")
CONSUMER_SECRET = clean_val(os.getenv("MPESA_CONSUMER_SECRET") or os.getenv("CONSUMER_SECRET") or "LXgsZGYdl6kpunxzGuAw4Fi3JK7FtTLqbCK9JZjI6VDR6e93n5mmW8gFKUORhuQQ")
PASSKEY = clean_val(os.getenv("MPESA_PASSKEY") or os.getenv("PASSKEY") or "f2d5541751a9649a49971680017613ecec69eb7bd886bda8bfb5d07c5d1c2d1f")
SHORTCODE = clean_val(os.getenv("MPESA_SHORTCODE") or os.getenv("BUSINESS_SHORT_CODE") or "4050545")
ENV = clean_val(os.getenv("MPESA_ENV") or "production").lower()
BASE_URL = "https://api.safaricom.co.ke" if ENV != "sandbox" else "https://sandbox.safaricom.co.ke"

CALLBACK_URL = clean_val(os.getenv("CALLBACK_URL") or "https://harvion.delstarfordworks.co.ke/api/payments/callback")
if not CALLBACK_URL or "your-domain.com" in CALLBACK_URL:
    CALLBACK_URL = "https://harvion.delstarfordworks.co.ke/api/payments/callback"

def get_oauth_token_details():
    try:
        c_key = clean_val(os.getenv("MPESA_CONSUMER_KEY") or os.getenv("CONSUMER_KEY") or CONSUMER_KEY)
        c_secret = clean_val(os.getenv("MPESA_CONSUMER_SECRET") or os.getenv("CONSUMER_SECRET") or CONSUMER_SECRET)
        auth_str = f"{c_key}:{c_secret}"
        auth_encoded = base64.b64encode(auth_str.encode("utf-8")).decode("utf-8")
        headers = {"Authorization": f"Basic {auth_encoded}"}
        current_env = clean_val(os.getenv("MPESA_ENV") or ENV).lower()
        base = "https://api.safaricom.co.ke" if current_env != "sandbox" else "https://sandbox.safaricom.co.ke"
        resp = requests.get(f"{base}/oauth/v1/generate?grant_type=client_credentials", headers=headers, timeout=8)
        if resp.status_code == 200:
            return resp.json().get("access_token"), None
        else:
            return None, f"HTTP {resp.status_code}: {resp.text}"
    except Exception as e:
        return None, str(e)

def get_oauth_token():
    token, _ = get_oauth_token_details()
    return token

@payments_bp.route("/test-oauth", methods=["GET"])
def test_oauth():
    token, error = get_oauth_token_details()
    c_key = clean_val(os.getenv("MPESA_CONSUMER_KEY") or os.getenv("CONSUMER_KEY") or CONSUMER_KEY)
    current_env = clean_val(os.getenv("MPESA_ENV") or ENV).lower()
    base = "https://api.safaricom.co.ke" if current_env != "sandbox" else "https://sandbox.safaricom.co.ke"
    return jsonify({
        "success": token is not None,
        "token_preview": (token[:10] + "...") if token else None,
        "error": error,
        "env": current_env,
        "base_url": base,
        "consumer_key_preview": c_key[:8] + "...",
        "shortcode": clean_val(os.getenv("MPESA_SHORTCODE") or os.getenv("BUSINESS_SHORT_CODE") or SHORTCODE),
    })

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

        token, auth_error = get_oauth_token_details()

        if not token:
            print(f"[Daraja Error]: Could not get token: {auth_error}")
            return jsonify({
                "success": False,
                "message": f"Safaricom M-Pesa gateway error: {auth_error}. Please check shortcode/passkey settings.",
                "error": auth_error
            }), 400

        cur_shortcode = clean_val(os.getenv("MPESA_SHORTCODE") or os.getenv("BUSINESS_SHORT_CODE") or SHORTCODE)
        cur_passkey = clean_val(os.getenv("MPESA_PASSKEY") or os.getenv("PASSKEY") or PASSKEY)
        cur_callback = clean_val(os.getenv("CALLBACK_URL") or CALLBACK_URL)
        if not cur_callback or "your-domain.com" in cur_callback:
            cur_callback = "https://harvion.delstarfordworks.co.ke/api/payments/callback"

        current_env = clean_val(os.getenv("MPESA_ENV") or ENV).lower()
        base = "https://api.safaricom.co.ke" if current_env != "sandbox" else "https://sandbox.safaricom.co.ke"

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

        resp = requests.post(f"{base}/mpesa/stkpush/v1/processrequest", json=payload, headers=headers, timeout=12)
        data = resp.json()

        # If CustomerPayBillOnline is rejected because shortcode is Buy Goods / Till, retry with CustomerBuyGoodsOnline
        if "Transaction type is not supported" in str(data.get("errorMessage", "")) or data.get("errorCode") in ["500.001.1001", "400.002.02"]:
            payload["TransactionType"] = "CustomerBuyGoodsOnline"
            resp = requests.post(f"{base}/mpesa/stkpush/v1/processrequest", json=payload, headers=headers, timeout=12)
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

