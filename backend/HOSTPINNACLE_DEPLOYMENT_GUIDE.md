# 🚀 HostPinnacle cPanel Node.js Deployment Guide for HARVION

This guide explains how to deploy the **HARVION API Backend** on **HostPinnacle** (or any cPanel host running CloudLinux with "Setup Node.js App").

---

### Step 1: Zip the Backend Directory
Compress the contents of the `backend/` folder into a single ZIP file (`harvion-backend.zip`).
**Important**: Do NOT include `node_modules/` in the ZIP file! HostPinnacle will install them directly on the server.

Include:
- `server.js`
- `firebaseAdmin.js`
- `package.json`
- `package-lock.json`
- `serviceAccountKey.json`
- `.env`
- `routes/` (folder with all route files)
- `uploads/` (folder)

---

### Step 2: Create the Node.js App in HostPinnacle cPanel
1. Log in to your **HostPinnacle cPanel**.
2. Scroll to the **Software** section and click **Setup Node.js App**.
3. Click the **Create Application** button.
4. Fill in the following settings:
   - **Node.js version**: Choose `18.x` or `20.x` (Recommended).
   - **Application mode**: `Production`.
   - **Application root**: `harvion_api` (or any directory name in your home root).
   - **Application URL**: Select your domain or subdomain (e.g., `api.yourdomain.co.ke` or `yourdomain.co.ke/api`).
   - **Application startup file**: `server.js` (matches your `package.json` main file).
5. Click **Create** at the top right.

---

### Step 3: Upload the Backend Code
1. In cPanel, open **File Manager**.
2. Navigate into the folder created in Step 2 (`/home/yourusername/harvion_api`).
3. Click **Upload** and upload `harvion-backend.zip`.
4. Right-click `harvion-backend.zip` and select **Extract**.
5. Ensure `server.js`, `package.json`, `firebaseAdmin.js`, `routes/`, and `serviceAccountKey.json` are situated directly in the root of that folder.

---

### Step 4: Install Dependencies & Run
1. Go back to **Setup Node.js App** in cPanel and click on your application.
2. In the **Configuration** section, click **Run NPM Install** (cPanel will automatically read `package.json` and download `express`, `cors`, `dotenv`, and `firebase-admin`).
3. Once completed, click **Restart** at the top.

---

### Step 5: Verify the Deployment
Open your browser and visit your application URL:
```
https://api.yourdomain.co.ke/
```
You will receive this active JSON confirmation:
```json
{
  "status": "online",
  "name": "HARVION SDA Ministry Enterprise API",
  "version": "2.0.0",
  "healthCheck": "/api/health",
  "serverTime": "2026-10-28T...",
  "message": "HARVION Literature Evangelism, Health & Truth Platform is active."
}
```

Check the health route:
```
https://api.yourdomain.co.ke/api/health
```

---

### Available Endpoints on HostPinnacle
| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/` | Root service ping & status check |
| `GET` | `/api/health` | Service health & Firebase connection status |
| `GET` | `/api/books` | Literature evangelism book catalog (supports filters & search) |
| `GET` | `/api/books/:id` | Single book details |
| `POST`| `/api/books` | Add new book to catalog (Admin/Colporteur) |
| `POST`| `/api/orders` | Place literature orders with M-Pesa integration |
| `GET` | `/api/colporteurs/locations` | Camp meeting & colporteur field booths |
| `GET` | `/api/ministry/livestreams` | Real-time live broadcast announcements |
| `GET` | `/uploads/:filename` | Serve custom uploaded book covers or media |

