# HARVION Python Flask Backend — HostPinnacle cPanel Deployment Guide

This guide provides step-by-step instructions to deploy the **HARVION SDA Ministry Python Flask Backend** on **HostPinnacle cPanel** using **CloudLinux "Setup Python App" (Phusion Passenger)**.

---

## 📋 Architecture & Prerequisites

- **Backend Framework**: Python 3.10+ / Flask 3.0.3
- **WSGI Server**: Phusion Passenger (CloudLinux cPanel standard)
- **Database & Storage**: Google Cloud Firestore & Firebase Storage (`gs://vine-3e4ab.firebasestorage.app`)
- **Payment Gateway**: Safaricom M-Pesa Daraja STK Push & Webhook
- **Front-facing Files**: `index.html`, `about.html`, and REST API at `/api`

### Required Files in the Deployment Package
```
harvion_api/
├── app.py                      # Flask Application factory & routing
├── passenger_wsgi.py           # Phusion Passenger WSGI entrypoint
├── wsgi.py                     # Standalone WSGI runner (Gunicorn / testing)
├── firebase_config.py          # Firebase Admin SDK initialization
├── serviceAccountKey.json      # Firebase Admin Service Account Key
├── requirements.txt            # Python dependencies (Flask, firebase-admin, etc.)
├── .env                        # Environment configuration variables
├── .htaccess                   # Apache & Passenger server configuration
├── blueprints/                 # Modular API controllers
│   ├── books.py                # Bookstore CRUD, search & categories
│   ├── orders.py               # Order placement & tracking
│   ├── payments.py             # M-Pesa STK push & callbacks
│   ├── colporteurs.py          # Evangelist portal, leads & camp meetings
│   ├── ministry.py             # Devotionals, SS lessons & prayer wall
│   └── sop.py                  # Spirit of Prophecy (Ellen G. White) library
├── public/                     # Public web assets
│   ├── index.html              # Harvion Ministry Platform homepage
│   └── about.html              # Adventist Faith & Mission statement
└── uploads/                    # Local storage fallback directory
```

---

## 🚀 Step-by-Step Deployment Instructions

### Step 1: Prepare the Zip Package on Your Computer

1. Open PowerShell in your project backend folder:
   ```powershell
   cd C:\Users\Delstaford\vine\backend
   ```
2. Compress all Python files, blueprints, public assets, and config files into `harvion-flask-backend-deploy.zip`:
   *(We have pre-packaged this for you at `backend/harvion-flask-backend-deploy.zip`)*.

---

### Step 2: Upload Files to HostPinnacle cPanel

1. Log in to your **HostPinnacle cPanel** (`https://yourdomain.com:2083` or client portal).
2. Open **File Manager** from the cPanel dashboard.
3. Decide where you want the app to live:
   - **Option A (Subfolder / Dedicated API)**: Create a directory named `harvion_api` under `/home/username/` (recommended: one level above `public_html`).
   - **Option B (Direct Main Domain)**: Extract inside `/home/username/public_html/`.
4. Click **Upload**, select `harvion-flask-backend-deploy.zip`, and click **Extract**.
5. Ensure your files (`app.py`, `passenger_wsgi.py`, `serviceAccountKey.json`, `requirements.txt`, `.env`) are directly in the selected folder.

---

### Step 3: Configure "Setup Python App" in cPanel

1. In cPanel, navigate to the **Software** section and click **Setup Python App**.
2. Click the blue **CREATE APPLICATION** button.
3. Fill in the application settings:
   - **Python version**: Select **3.10**, **3.11**, or **3.12** (Recommended: **3.11**).
   - **Application root**: `harvion_api` (or `public_html` if deployed to root).
   - **Application URL**: Select your domain or subdomain (e.g., `api.yourdomain.com` or `yourdomain.com`).
   - **Application startup file**: `passenger_wsgi.py`
   - **Application Entry point**: `application`
   - **Passenger log file**: `passenger.log` (optional, helpful for debugging).
4. Click **CREATE** in the top right corner.
5. Once created, cPanel will show the command to enter the virtual environment at the top, for example:
   ```bash
   source /home/username/virtualenv/harvion_api/3.11/bin/activate && cd /home/username/harvion_api
   ```

---

### Step 4: Install Dependencies (`requirements.txt`)

There are two easy ways to install dependencies:

#### Method A: Using cPanel GUI (Fastest)
1. On the Python App configuration page, scroll down to **Configuration files**.
2. In the text box, type `requirements.txt` and click **Add**.
3. Once added, click the **Run Pip Install** button next to `requirements.txt`.
4. Wait 30–60 seconds while cPanel installs Flask, Firebase-Admin, Requests, and Gunicorn. A green success message will appear.

#### Method B: Using cPanel Terminal / SSH
1. Open **Terminal** in cPanel.
2. Copy and paste the activation command shown at the top of your Python App page:
   ```bash
   source /home/username/virtualenv/harvion_api/3.11/bin/activate && cd /home/username/harvion_api
   ```
3. Run pip install:
   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt
   ```

---

### Step 5: Configure Environment Variables

1. On the **Setup Python App** page, scroll down to **Environment variables**.
2. Click **ADD VARIABLE** and add the following keys:

| Variable Name | Example Value | Description |
| :--- | :--- | :--- |
| `FLASK_ENV` | `production` | Production mode |
| `SECRET_KEY` | `harvion_sda_ministry_secret_key_2026` | Flask session secret |
| `FIREBASE_PROJECT_ID` | `vine-3e4ab` | Firebase project ID |
| `FIREBASE_STORAGE_BUCKET` | `vine-3e4ab.firebasestorage.app` | Firebase Storage bucket |
| `MPESA_ENVIRONMENT` | `sandbox` *(or `production`)* | Safaricom M-Pesa env |
| `MPESA_CONSUMER_KEY` | *(Your Safaricom Daraja key)* | M-Pesa API Key |
| `MPESA_CONSUMER_SECRET` | *(Your Safaricom Daraja secret)* | M-Pesa API Secret |
| `MPESA_SHORTCODE` | `174379` *(Sandbox)* | Paybill or Till Number |
| `MPESA_PASSKEY` | `bfb279f9aa9bdbcf158e97dd71a467cd...` | Daraja Passkey |
| `MPESA_CALLBACK_URL` | `https://yourdomain.com/api/payments/mpesa/callback` | Webhook URL |

3. Alternatively, simply edit the `.env` file directly using cPanel **File Manager > Code Editor**.

---

### Step 6: Verify Passenger WSGI & `.htaccess`

Ensure `passenger_wsgi.py` contains:
```python
import sys
import os

current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

from app import app as application
```

Ensure `.htaccess` contains (cPanel generates the top section automatically):
```apache
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION BEGIN
PassengerAppRoot "/home/username/harvion_api"
PassengerBaseURI "/"
PassengerPython "/home/username/virtualenv/harvion_api/3.11/bin/python"
# DO NOT REMOVE. CLOUDLINUX PASSENGER CONFIGURATION END

# Disable directory listing
Options -Indexes

# Enable gzip compression
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>
```

---

### Step 7: Restart the Python Application

1. In the **Setup Python App** page in cPanel, click the **RESTART** button at the top.
2. Every time you update a Python file, click **RESTART** so Passenger reloads the code.

---

## 🔍 Verification Checklist

Open your browser and test these URLs (replace `yourdomain.com` with your actual domain):

| URL | Expected Result |
| :--- | :--- |
| `https://yourdomain.com/` | Harvion SDA Ministry interactive homepage (`index.html`) |
| `https://yourdomain.com/about.html` | Official Adventist Faith & Pillars of Truth page |
| `https://yourdomain.com/api/health` | JSON response: `{"status": "online", "framework": "Python Flask", "firebaseConnected": true, "version": "2.0.0-FLASK"}` |
| `https://yourdomain.com/api` | API directory listing all available routes |
| `https://yourdomain.com/api/sop/books` | List of 50 Spirit of Prophecy (Ellen G. White) books |
| `https://yourdomain.com/api/books` | Bookstore literature catalog from Firestore |

---

## 🛠️ Troubleshooting Common cPanel Issues

### 1. `{"success": false, "message": "Endpoint not found"}` or 404
- **Cause**: Apache or Passenger is routing through a subfolder prefix (e.g., `/harvion_api`).
- **Fix**: The included `app.py` has automatic URL normalization middleware (`handle_options_and_url_normalization()`) that automatically strips subfolder prefixes. If using a subdomain (e.g., `api.domain.com`), set **PassengerBaseURI** to `/`.

### 2. `500 Internal Server Error`
- **Cause**: Missing Python library or permission issue with `serviceAccountKey.json`.
- **Fix**:
  1. Check `passenger.log` or cPanel **Errors** log.
  2. Verify all dependencies installed: Run `pip install -r requirements.txt`.
  3. Ensure `serviceAccountKey.json` has file permissions `644` or `600`.

### 3. Firebase Permission Denied
- **Cause**: Firebase rules or missing service account.
- **Fix**: Verify `serviceAccountKey.json` matches your Firebase project `vine-3e4ab`. In `firebase_config.py`, credentials are automatically loaded and tested on startup.

### 4. Code changes not taking effect
- **Cause**: Passenger WSGI caches Python bytecode in memory.
- **Fix**: Click **RESTART** in the Python App manager, or run:
  ```bash
  touch /home/username/harvion_api/tmp/restart.txt
  ```

---

*HARVION — Spreading the Everlasting Gospel to Every Nation, Kindred, Tongue, and People.*
