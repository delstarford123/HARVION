const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");
require("dotenv").config();

const projectId = process.env.FIREBASE_PROJECT_ID || "vine-3e4ab";
const storageBucket = process.env.FIREBASE_STORAGE_BUCKET || "vine-3e4ab.firebasestorage.app";
const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS || path.join(__dirname, "serviceAccountKey.json");

if (fs.existsSync(serviceAccountPath)) {
  const serviceAccount = require(serviceAccountPath);
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: projectId,
    storageBucket: storageBucket,
  });
  console.log(`[Firebase Admin] Initialized with Service Account Key for project: ${projectId}, bucket: ${storageBucket}`);
} else {
  try {
    admin.initializeApp({
      projectId: projectId,
      storageBucket: storageBucket,
    });
    console.log(`[Firebase Admin] Initialized with Project ID: ${projectId}, bucket: ${storageBucket}`);
  } catch (err) {
    console.warn(`[Firebase Admin] Initialization warning: ${err.message}. Using existing default app.`);
  }
}

const db = admin.firestore();
const bucket = admin.storage().bucket();

module.exports = { admin, db, bucket, storageBucket };
