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

// Request Logger
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Root Route: Serves index.html to web browsers, or JSON to API clients & monitoring
app.get("/", (req, res) => {
  const acceptsHtml = req.accepts("html");
  const acceptsJson = req.headers["accept"] && req.headers["accept"].includes("application/json");

  if (acceptsHtml && !acceptsJson && !req.xhr) {
    return res.sendFile(path.join(__dirname, "public", "index.html"));
  }

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
    message: "HARVION Literature Evangelism, Health & Truth Platform is active."
  });
});

// About Page Handler
app.get(["/about", "/about.html"], (req, res) => {
  res.sendFile(path.join(__dirname, "public", "about.html"));
});

// Home Page Handler
app.get(["/home", "/index.html"], (req, res) => {
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

// Mount Application Routes
app.use("/api/books", require("./routes/books"));
app.use("/api/orders", require("./routes/orders"));
app.use("/api/payments", require("./routes/payments"));
app.use("/api/colporteurs", require("./routes/colporteurs"));
app.use("/api/ministry", require("./routes/ministry"));

// 404 Handler
app.use((req, res) => {
  if (req.accepts("html")) {
    return res.status(404).sendFile(path.join(__dirname, "public", "index.html"));
  }
  res.status(404).json({ success: false, message: "Endpoint not found" });
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
