import os
import firebase_admin
from firebase_admin import credentials, firestore, storage
from dotenv import load_dotenv

load_dotenv()

PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID", "vine-3e4ab")
STORAGE_BUCKET = os.getenv("FIREBASE_STORAGE_BUCKET", "vine-3e4ab.firebasestorage.app")
SERVICE_ACCOUNT_PATH = os.getenv(
    "GOOGLE_APPLICATION_CREDENTIALS",
    os.path.join(os.path.dirname(__file__), "serviceAccountKey.json"),
)

db = None
bucket = None

try:
    if os.path.exists(SERVICE_ACCOUNT_PATH):
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        firebase_app = firebase_admin.initialize_app(
            cred,
            {
                "projectId": PROJECT_ID,
                "storageBucket": STORAGE_BUCKET,
            },
        )
        print(f"[Firebase Admin Python] Initialized with Service Account Key for project: {PROJECT_ID}")
    else:
        firebase_app = firebase_admin.initialize_app(
            options={
                "projectId": PROJECT_ID,
                "storageBucket": STORAGE_BUCKET,
            }
        )
        print(f"[Firebase Admin Python] Initialized with Project ID: {PROJECT_ID}")

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

