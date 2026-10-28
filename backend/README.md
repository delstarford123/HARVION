# HARVION - Backend API & Firebase Database Engine

Official Backend Service for **HARVION** (SDA Ministry, Health & Literature Evangelism App).

Built with **Node.js**, **Express**, **Firebase Admin SDK (Firestore)**, and **Safaricom Daraja API (M-Pesa)**.

---

## 🚀 Quick Start

### 1. Install Dependencies
```bash
cd backend
npm install
```

### 2. Environment Variables (.env)
The `.env` file is already pre-configured for your Firebase Project (`vine-3e4ab`):
```env
PORT=5000
NODE_ENV=development
FIREBASE_PROJECT_ID=vine-3e4ab
```

*(Optional)* To use a Service Account Key from Firebase Console:
1. Go to Firebase Console &rarr; Project Settings &rarr; Service Accounts.
2. Click **Generate new private key**.
3. Save the JSON file as `serviceAccountKey.json` inside the `backend/` folder.

### 3. Seed the Entire Database
Run the automated seeder to populate all collections:
```bash
npm run seed
```
This populates:
- `bookstore_items` (10 core SDA books with prices, categories, and formats)
- `devotionals` (Morning Watch daily devotionals)
- `daily_quotes` (E.G. White quote of the day)
- `colporteurs` (Literature Evangelist profiles & commissions)
- `churches_directory` (Local SDA Churches with meeting times & GPS coordinates)
- `healthy_recipes` (NEWSTART 100% plant-based recipes)
- `prayer_requests` (Community prayer wall needs)
- `digital_tracts` (Evangelism pamphlets with WhatsApp sharing links)

### 4. Start the Backend Server
```bash
npm start
# Server starts on http://localhost:5000
```

---

## 📡 REST API Documentation

### Health Check
- `GET /api/health` - Check backend server and Firebase project status.

### Bookstore & Catalog
- `GET /api/books` - Retrieve books with optional query parameters: `category`, `language`, `format`, `search`, `maxPrice`.
- `GET /api/books/:id` - Retrieve book by ID.
- `POST /api/books` - Add a new book to the bookstore catalog.
- `PUT /api/books/:id` - Update price, format, or stock.
- `DELETE /api/books/:id` - Remove a book.

### Orders & Delivery Logistics
- `POST /api/orders` - Create a new order with items, delivery address/church depot, and payment method.
- `GET /api/orders` - List orders (filter by `customerPhone` or `status`).
- `GET /api/orders/:id` - Track real-time progress of a specific order.
- `PATCH /api/orders/:id/status` - Update status (`confirmed`, `processing`, `dispatched`, `inTransit`, `delivered`).

### Localized M-Pesa Payments (Safaricom Daraja)
- `POST /api/payments/stk-push` - Initiate an STK Push prompt on buyer's phone.
- `POST /api/payments/callback` - Webhook callback from Safaricom updating order payment status to `Paid`.

### Colporteurs (Literature Evangelists)
- `GET /api/colporteurs/:code` - Verify LE referral code (gives 10% discount).
- `GET /api/colporteurs/:code/leads` - Get LE missionary customer leads.
- `POST /api/colporteurs/:code/leads` - Add a new customer prospect lead.
- `POST /api/colporteurs/register` - Register a new literature evangelist.

### Ministry & Spiritual Content
- `GET /api/ministry/devotionals` - Daily Morning Watch devotional feed.
- `GET /api/ministry/sabbath-school` - Current quarter study guides.
- `GET /api/ministry/prayers` - Community prayer wall requests.
- `POST /api/ministry/prayers` - Submit a new prayer need.
- `POST /api/ministry/prayers/:id/pray` - Increment prayer count.
- `GET /api/ministry/recipes` - Plant-based recipes & meal planner.
- `GET /api/ministry/churches` - Local SDA church directory.
- `GET /api/ministry/tracts` - Free digital evangelism tracts.

