# 🚀 HostPinnacle cPanel Node.js Deployment Guide for HARVION

This guide explains how to deploy the **HARVION Web & API Backend** on **HostPinnacle** (or any cPanel host running CloudLinux with "Setup Node.js App").

---

### Step 1: Ready-Made Deployment Archive
A pre-packaged archive has been built for you: **`backend/harvion-backend-deploy.zip`** (approx. 68 KB).
It includes:
- `server.js` (Express & Phusion Passenger web server)
- `public/index.html` (HARVION Home Web Page)
- `public/about.html` (Comprehensive About & Adventist Faith Alignment Guide)
- `firebaseAdmin.js` & `serviceAccountKey.json` (Firebase Cloud connectivity)
- `package.json` & `package-lock.json`
- `.env` & `.htaccess`
- `routes/` (books, orders, payments, colporteurs, ministry)
- `uploads/` (static storage for media and book covers)

*(It safely excludes `node_modules/` so upload is instantaneous; cPanel installs dependencies natively).*

---

### Step 2: Create the Node.js App in HostPinnacle cPanel
1. Log in to your **HostPinnacle cPanel**.
2. Scroll to the **Software** section and click **Setup Node.js App**.
3. Click the **Create Application** button.
4. Fill in the following settings:
   - **Node.js version**: Choose `18.x` or `20.x` (Recommended).
   - **Application mode**: `Production`.
   - **Application root**: `harvion_api` (or any directory name in your home root).
   - **Application URL**: Select your domain or subdomain (e.g., `yourdomain.co.ke` or `api.yourdomain.co.ke`).
   - **Application startup file**: `server.js`.
5. Click **Create** at the top right.

---

### Step 3: Upload the Backend Code
1. In cPanel, open **File Manager**.
2. Navigate into the folder created in Step 2 (`/home/yourusername/harvion_api`).
3. Click **Upload** and upload `harvion-backend-deploy.zip`.
4. Right-click `harvion-backend-deploy.zip` and select **Extract**.
5. Ensure `server.js`, `public/`, `routes/`, `uploads/`, `package.json`, and `serviceAccountKey.json` are situated directly in the root of that folder.

---

### Step 4: Install Dependencies & Run
1. Go back to **Setup Node.js App** in cPanel and click on your application.
2. In the **Configuration** section, click **Run NPM Install** (cPanel will automatically download `express`, `cors`, `dotenv`, and `firebase-admin`).
3. Once completed, click **Restart** at the top.

---

### Step 5: Verify the Deployment in Your Browser

1. **Home Web Page (HARVION Platform Overview)**:
   ```
   https://yourdomain.co.ke/
   ```
   *(or `https://yourdomain.co.ke/index.html`)*
   Displays the full HARVION web portal with hero banner, 6 ministry pillars, live backend status, and quick links.

2. **About & Adventist Faith Page**:
   ```
   https://yourdomain.co.ke/about.html
   ```
   *(or `https://yourdomain.co.ke/about`)*
   Displays the comprehensive theological guide showing how HARVION matches the 28 Fundamental Beliefs, the Three Angels' Messages, the Spirit of Prophecy, and ethical monetization.

3. **Backend API Health Check**:
   ```
   https://yourdomain.co.ke/api/health
   ```
   Returns:
   ```json
   {
     "status": "online",
     "name": "HARVION API Server",
     "version": "2.0.0",
     "firebaseProject": "vine-3e4ab",
     "time": "2026-10-28T..."
   }
   ```

---

### Complete Endpoint Reference
| Method | URL / Path | Content | Description |
|---|---|---|---|
| `GET` | `/` or `/index.html` | HTML | Harvion Home Landing Page |
| `GET` | `/about` or `/about.html` | HTML | About the Application & Adventist Faith Alignment |
| `GET` | `/api/health` | JSON | Backend health check & Firebase connectivity status |
| `GET` | `/api` | JSON | API directory and service discovery |
| `GET` | `/api/books` | JSON | Complete literature evangelism bookstore catalog |
| `POST`| `/api/books` | JSON | Add new book to catalog (Admin/Colporteur) |
| `POST`| `/api/orders` | JSON | Place literature orders with M-Pesa tracking |
| `GET` | `/api/colporteurs/locations` | JSON | Camp meeting & colporteur field booth coordinates |
| `GET` | `/api/ministry/livestreams` | JSON | Real-time live broadcast announcements |
| `GET` | `/uploads/:filename` | Media | Public book covers, tract previews & sermon images |
