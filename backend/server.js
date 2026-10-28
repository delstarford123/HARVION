const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request Logger
app.use((req, res, next) => {
  console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl}`);
  next();
});

// Health check
app.get("/api/health", (req, res) => {
  res.json({
    status: "online",
    name: "HARVION API Server",
    version: "2.0.0",
    firebaseProject: process.env.FIREBASE_PROJECT_ID || "vine-3e4ab",
    time: new Date().toISOString(),
  });
});

// Mount Routes
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

if (process.env.NODE_ENV !== "test") {
  app.listen(PORT, () => {
    console.log(`===============================================`);
    console.log(`🌱 HARVION Backend running on http://localhost:${PORT}`);
    console.log(`📦 Firebase Project: ${process.env.FIREBASE_PROJECT_ID || "vine-3e4ab"}`);
    console.log(`===============================================`);
  });
}

module.exports = app;

