import os
import json
import base64
import firebase_admin
from firebase_admin import credentials, firestore, storage
from dotenv import load_dotenv

load_dotenv()

def clean_val(v, default=""):
    if not v:
        return default
    return str(v).strip().replace("\ufeff", "").replace("\r", "")

PROJECT_ID = clean_val(os.getenv("FIREBASE_PROJECT_ID"), "vine-3e4ab")
STORAGE_BUCKET = clean_val(os.getenv("FIREBASE_STORAGE_BUCKET"), "vine-3e4ab.firebasestorage.app")
SERVICE_ACCOUNT_PATH = os.getenv(
    "GOOGLE_APPLICATION_CREDENTIALS",
    os.path.join(os.path.dirname(__file__), "serviceAccountKey.json"),
)
SERVICE_ACCOUNT_RAW_JSON = clean_val(os.getenv("FIREBASE_SERVICE_ACCOUNT"), "")
SERVICE_ACCOUNT_B64 = clean_val(os.getenv("FIREBASE_SERVICE_ACCOUNT_BASE64"), "")

db = None
bucket = None
firebase_app = None

def init_firebase():
    global db, bucket, firebase_app

    # Check if already initialized (important for Vercel / serverless warm containers)
    if firebase_admin._apps:
        firebase_app = firebase_admin.get_app()
        db = firestore.client()
        try:
            bucket = storage.bucket(STORAGE_BUCKET)
        except Exception:
            pass
        return

    cred = None

    # Priority 1: FIREBASE_SERVICE_ACCOUNT (raw JSON string from Vercel / cloud env vars)
    if SERVICE_ACCOUNT_RAW_JSON:
        try:
            cert_dict = json.loads(SERVICE_ACCOUNT_RAW_JSON)
            cred = credentials.Certificate(cert_dict)
            print("[Firebase Admin Python] Loaded credentials from FIREBASE_SERVICE_ACCOUNT env var.")
        except Exception as e:
            print(f"[Firebase Admin Warning] Failed to parse FIREBASE_SERVICE_ACCOUNT: {e}")

    # Priority 2: FIREBASE_SERVICE_ACCOUNT_BASE64 (base64 encoded JSON)
    if cred is None and SERVICE_ACCOUNT_B64:
        try:
            decoded = base64.b64decode(SERVICE_ACCOUNT_B64).decode("utf-8")
            cert_dict = json.loads(decoded)
            cred = credentials.Certificate(cert_dict)
            print("[Firebase Admin Python] Loaded credentials from FIREBASE_SERVICE_ACCOUNT_BASE64 env var.")
        except Exception as e:
            print(f"[Firebase Admin Warning] Failed to parse FIREBASE_SERVICE_ACCOUNT_BASE64: {e}")

    # Priority 3: Local file (serviceAccountKey.json on disk)
    if cred is None and os.path.exists(SERVICE_ACCOUNT_PATH):
        try:
            cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
            print(f"[Firebase Admin Python] Initialized with Service Account Key file for project: {PROJECT_ID}")
        except Exception as e:
            print(f"[Firebase Admin Warning] Failed to load {SERVICE_ACCOUNT_PATH}: {e}")

    try:
        if cred:
            firebase_app = firebase_admin.initialize_app(
                cred,
                {
                    "projectId": PROJECT_ID,
                    "storageBucket": STORAGE_BUCKET,
                },
            )
        else:
            firebase_app = firebase_admin.initialize_app(
                options={
                    "projectId": PROJECT_ID,
                    "storageBucket": STORAGE_BUCKET,
                }
            )
            print(f"[Firebase Admin Python] Initialized with default project ID: {PROJECT_ID}")

        db = firestore.client()
        try:
            bucket = storage.bucket(STORAGE_BUCKET)
        except Exception as e:
            print(f"[Firebase Storage Warning]: {e}")

    except Exception as err:
        print(f"[Firebase Admin Python Error]: {err}")
        try:
            db = firestore.client()
        except Exception:
            db = None

init_firebase()
