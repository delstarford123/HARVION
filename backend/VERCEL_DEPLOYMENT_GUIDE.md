# HARVION Flask Backend — Vercel & Subdomain Deployment Guide

This guide walks you through deploying the **HARVION SDA Ministry Python Flask Backend** to **Vercel** and linking your custom subdomain **`harvion.delstarfordworks.co.ke`** via HostPinnacle cPanel.

---

## 🏗️ Architecture & How It Works on Vercel

- **Runtime**: Python 3.11+ Serverless WSGI (`@vercel/python`)
- **Entry Points**: 
  - `api/index.py` & `vercel.json` (at project root)
  - `backend/api/index.py` & `backend/vercel.json` (inside backend)
- **Database**: Google Cloud Firestore (`vine-3e4ab`) & Firebase Storage
- **Credentials**: Passed securely via the `FIREBASE_SERVICE_ACCOUNT` environment variable (no sensitive files committed to GitHub).
- **Subdomain Routing**: `harvion.delstarfordworks.co.ke` &rarr; CNAME &rarr; `cname.vercel-dns.com`

---

## 🚀 Step-by-Step Deployment Instructions

### Step 1: Push All Changes to GitHub
All configuration files (`vercel.json`, `api/index.py`, `requirements.txt`, and updated `firebase_config.py`) have already been set up. They are committed and pushed to your GitHub repository:
`https://github.com/delstarford123/HARVION.git` (branch `main`).

---

### Step 2: Import the Project in Vercel

1. Log in to [vercel.com](https://vercel.com) (or sign in with your GitHub account).
2. On your Vercel Dashboard, click **Add New…** &rarr; **Project**.
3. Under **Import Git Repository**, find **`delstarford123/HARVION`** and click **Import**.

---

### Step 3: Configure Project Settings on Vercel

On the **Configure Project** screen:

1. **Project Name**: `harvion-backend` (or leave default `harvion`).
2. **Framework Preset**: Select **Other**.
3. **Root Directory**: Leave it as `./` (Root) OR click *Edit* and select `backend`.
   *(Both configurations are fully supported and tested out of the box).*

---

### Step 4: Add Environment Variables in Vercel

Before clicking Deploy, expand the **Environment Variables** section and add the following keys:

| Key | Value | Description |
| :--- | :--- | :--- |
| `FIREBASE_SERVICE_ACCOUNT` | *(Paste raw JSON content of `serviceAccountKey.json`)* | Full Firebase credentials |
| `FIREBASE_PROJECT_ID` | `vine-3e4ab` | Firebase project ID |
| `FIREBASE_STORAGE_BUCKET` | `vine-3e4ab.firebasestorage.app` | Firebase Storage bucket |
| `SECRET_KEY` | `harvion_sda_ministry_secret_key_2026` | Flask session secret |
| `MPESA_ENVIRONMENT` | `sandbox` *(or `production`)* | Daraja environment |
| `MPESA_CONSUMER_KEY` | *(Your Safaricom Daraja key)* | Daraja API Key |
| `MPESA_CONSUMER_SECRET` | *(Your Safaricom Daraja secret)* | Daraja API Secret |
| `MPESA_SHORTCODE` | `174379` | Paybill / Till Number |
| `MPESA_PASSKEY` | `bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919` | Daraja Passkey |

> [!TIP]
> **How to copy your `FIREBASE_SERVICE_ACCOUNT` JSON easily:**
> Open PowerShell in your project folder and run:
> ```powershell
> Get-Content backend\serviceAccountKey.json -Raw | Set-Clipboard
> ```
> This copies the entire service account JSON directly to your clipboard so you can paste it right into Vercel!

---

### Step 5: Click Deploy!

1. Click the blue **Deploy** button.
2. Vercel will install the Python dependencies (`Flask`, `firebase-admin`, etc.) and deploy your serverless backend.
3. In ~60 seconds, you will see a congratulations screen with a `.vercel.app` URL (e.g., `https://harvion-backend.vercel.app`).
4. Click that link to verify your web page loads!

---

### Step 6: Link Your Subdomain in Vercel

1. In your Vercel Project, go to **Settings** &rarr; **Domains**.
2. In the text box, type:
   ```
   harvion.delstarfordworks.co.ke
   ```
3. Click **Add**.
4. Vercel will display the DNS configuration requirement:
   - **Type**: `CNAME`
   - **Name**: `harvion`
   - **Value**: `cname.vercel-dns.com`

---

### Step 7: Configure DNS in HostPinnacle cPanel

1. Log in to your **HostPinnacle cPanel** (`https://cs1.hpcnoc.com:2083`).
2. In the search box or under **Domains**, open **Zone Editor**.
3. Locate your primary domain **`delstarfordworks.co.ke`** and click **Manage**.
4. **Important Check**: If there is already an old `A` record or subdomain record for `harvion.delstarfordworks.co.ke` (from earlier tests):
   - Click **Delete** on the old record (or click **Edit**).
5. Click **+ Add Record** (or **+ CNAME Record**):
   - **Name**: `harvion.delstarfordworks.co.ke.` (or `harvion`)
   - **TTL**: `14400` (or `3600`)
   - **Type**: `CNAME`
   - **Record / Target**: `cname.vercel-dns.com.`
6. Click **Save Record**.

---

### Step 8: Verification & SSL Provisioning

1. Go back to your Vercel Dashboard under **Settings > Domains**.
2. Within 1–3 minutes, Vercel will detect the CNAME record, automatically provision a free Let's Encrypt SSL/TLS certificate, and display a **Valid Configuration** green checkmark.
3. Test your endpoints in your browser:

| Test URL | Expected Output |
| :--- | :--- |
| `https://harvion.delstarfordworks.co.ke/` | Harvion SDA Ministry Interactive Web Portal |
| `https://harvion.delstarfordworks.co.ke/about.html` | Pillars of Adventist Faith & About Page |
| `https://harvion.delstarfordworks.co.ke/api/health` | `{"firebaseConnected": true, "framework": "Python Flask", "status": "online"}` |
| `https://harvion.delstarfordworks.co.ke/api/sop/books` | Complete list of all 50 Spirit of Prophecy books |
| `https://harvion.delstarfordworks.co.ke/api/ministry/devotionals` | Daily morning devotionals from Firestore |

---

## 📱 Mobile App Connection
Your Flutter app in [lib/core/constants.dart](file:///c:/Users/Delstaford/vine/lib/core/constants.dart) is already configured to communicate with:
```dart
static const String backendProductionUrl = 'https://harvion.delstarfordworks.co.ke/api';
```
As soon as DNS propagation finishes, your mobile app will seamlessly connect to this high-speed, autoscaling Vercel serverless backend!
