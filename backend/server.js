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

// Serve static assets and uploaded files (HostPinnacle friendly)
app.use("/uploads", express.static(path.join(__dirname, "uploads")));
app.use(express.static(path.join(__dirname, "public")));

// Request Logger
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Root Ping Handler (Required by cPanel / Phusion Passenger on HostPinnacle)
app.get("/", (req, res) => {
  res.json({
    status: "online",
    name: "HARVION SDA Ministry Enterprise API",
    version: "2.0.0",
    healthCheck: "/api/health",
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
