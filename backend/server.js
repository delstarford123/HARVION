const express = require("express");
const cors = require("cors");
const path = require("path");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve static assets, public web pages, and uploaded files
app.use("/uploads", express.static(path.join(__dirname, "uploads")));
app.use(express.static(path.join(__dirname, "public")));

// Request Normalization Middleware for cPanel Phusion Passenger & Apache
app.use((req, res, next) => {
  let url = req.url;

  // 1. Remove Apache rewrite suffix (/server.js)
  url = url.replace(/\/server\.js(\?.*)?$/, "$1");

  // 2. Strip known cPanel subfolder application roots if passed in URL
  const knownPrefixes = [
    "/harvion_api",
    "/harvion-api",
    "/harvion",
    "/public_html",
  ];
  for (const prefix of knownPrefixes) {
    if (url.startsWith(prefix)) {
      url = url.substring(prefix.length) || "/";
      break;
    }
  }

  // 3. Normalize empty string or index.php/index.html to root
  if (url === "" || url === "/index.html" || url === "/index.php") {
    url = "/";
  }

  req.url = url || "/";
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} -> normalized: ${req.url}`);
  next();
});

// ==========================================
// 🌐 WEB PAGES (Always served to browsers)
// ==========================================

// About Page Handler (matches /about and /about.html)
app.get(["/about", "/about.html"], (req, res) => {
  res.sendFile(path.join(__dirname, "public", "about.html"));
});

// Home Page Handler (matches /, /home, /index.html, /server.js)
app.get(["/", "/home", "/index.html", "/server.js"], (req, res) => {
  // If explicitly requested as JSON without accepting HTML (e.g. backend curl/fetch)
  const isJsonClient = req.headers["accept"] &&
      req.headers["accept"].includes("application/json") &&
      !req.headers["accept"].includes("text/html");

  if (isJsonClient) {
    return res.json({
      status: "online",
      name: "HARVION SDA Ministry Enterprise API",
      version: "2.0.0",
      healthCheck: "/api/health",
      webPages: {
        home: "/",
        about: "/about.html",
      },
      endpoints: {
        books: "/api/books",
        orders: "/api/orders",
        payments: "/api/payments",
        colporteurs: "/api/colporteurs",
        ministry: "/api/ministry",
      },
      serverTime: new Date().toISOString(),
      message: "HARVION Literature Evangelism, Health & Truth Platform is active."
    });
  }

  // Default: always serve the rich Home Portal index.html
  res.sendFile(path.join(__dirname, "public", "index.html"));
});

// Dedicated API Overview Endpoint
app.get("/api", (req, res) => {
  res.json({
    status: "online",
    name: "HARVION SDA Ministry Enterprise API",
    version: "2.0.0",
    healthCheck: "/api/health",
    webPages: {
      home: "/",
      about: "/about.html",
    },
    endpoints: {
      books: "/api/books",
      orders: "/api/orders",
      payments: "/api/payments",
      colporteurs: "/api/colporteurs",
      ministry: "/api/ministry",
    },
    serverTime: new Date().toISOString(),
  });
});

// Health check endpoint
app.get("/api/health", (req, res) => {
  res.json({
    status: "online",
    name: "HARVION API Server",
    version: "2.0.0",
    firebaseProject: process.env.FIREBASE_PROJECT_ID || "vine-3e4ab",
    time: new Date().toISOString(),
  });
});

// ==========================================
// 📦 APPLICATION API ROUTES
// ==========================================
app.use("/api/books", require("./routes/books"));
app.use("/api/orders", require("./routes/orders"));
app.use("/api/payments", require("./routes/payments"));
app.use("/api/colporteurs", require("./routes/colporteurs"));
app.use("/api/ministry", require("./routes/ministry"));

// ==========================================
// 🛡️ 404 FALLBACK HANDLER
// ==========================================
app.use((req, res) => {
  // If a web browser hit an unknown route, render index.html instead of a cold JSON error!
  if (req.method === "GET" && req.accepts("html")) {
    return res.sendFile(path.join(__dirname, "public", "index.html"));
  }

  res.status(404).json({
    success: false,
    message: "Endpoint not found",
    requestedUrl: req.originalUrl,
    normalizedPath: req.url,
    availableEndpoints: [
      "/",
      "/about.html",
      "/api/health",
      "/api/books",
      "/api/orders",
      "/api/payments",
      "/api/colporteurs",
      "/api/ministry"
    ]
  });
});

// Error Handler
app.use((err, req, res, next) => {
  console.error("Internal Server Error:", err);
  res.status(500).json({ success: false, error: err.message });
});

if (require.main === module) {
  const server = app.listen(PORT, () => {
    console.log(`===============================================`);
    console.log(`🌱 HARVION Backend running on http://localhost:${PORT}`);
    console.log(`📖 Web Pages: http://localhost:${PORT}/ and http://localhost:${PORT}/about.html`);
    console.log(`📦 Firebase Project: ${process.env.FIREBASE_PROJECT_ID || "vine-3e4ab"}`);
    console.log(`🌐 Ready for HostPinnacle cPanel / Passenger`);
    console.log(`===============================================`);
  });

  server.on("error", (err) => {
    if (err.code === "EADDRINUSE") {
      console.warn(`[Warning] Port ${PORT} in use, trying port ${Number(PORT) + 1}...`);
      server.listen(Number(PORT) + 1);
    } else {
      console.error("Server listen error:", err);
    }
  });
}

module.exports = app;
