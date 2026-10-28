const express = require("express");
const router = express.Router();
const { db } = require("../firebaseAdmin");

const COLLECTION = "colporteurs";

// GET /api/colporteurs/:code - Verify referral code & fetch LE profile
router.get("/:code", async (req, res) => {
  try {
    const code = req.params.code.toUpperCase();
    const query = await db.collection(COLLECTION).where("referralCode", "==", code).get();

    if (query.empty) {
      return res.status(404).json({ success: false, message: "Invalid colporteur referral code" });
    }

    const data = query.docs[0].data();
    res.json({
      success: true,
      valid: true,
      discountPercentage: 0.10, // 10% discount for buyers
      colporteur: {
        id: query.docs[0].id,
        name: data.name,
        churchConference: data.churchConference,
        referralCode: data.referralCode,
      },
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/colporteurs/:code/leads - Get customer pipeline
router.get("/:code/leads", async (req, res) => {
  try {
    const code = req.params.code.toUpperCase();
    const query = await db.collection(COLLECTION).where("referralCode", "==", code).get();

    if (query.empty) {
      return res.status(404).json({ success: false, message: "Colporteur not found" });
    }

    const leDoc = query.docs[0];
    const leadsSnapshot = await leDoc.ref.collection("leads").orderBy("dateAdded", "desc").get();
    const leads = [];
    leadsSnapshot.forEach((doc) => {
      leads.push({ id: doc.id, ...doc.data() });
    });

    res.json({ success: true, count: leads.length, data: leads });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/colporteurs/:code/leads - Record customer lead
router.post("/:code/leads", async (req, res) => {
  try {
    const code = req.params.code.toUpperCase();
    const { customerName, phone, location, interestBook, notes } = req.body;

    const query = await db.collection(COLLECTION).where("referralCode", "==", code).get();
    if (query.empty) {
      return res.status(404).json({ success: false, message: "Colporteur not found" });
    }

    const leDoc = query.docs[0];
    const newLead = {
      customerName,
      phone,
      location: location || "",
      interestBook: interestBook || "",
      notes: notes || "",
      status: "New Lead",
      dateAdded: new Date(),
    };

    const leadRef = await leDoc.ref.collection("leads").add(newLead);
    res.status(201).json({ success: true, id: leadRef.id, data: newLead });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/colporteurs/register - Register new literature evangelist
router.post("/register", async (req, res) => {
  try {
    const { name, churchConference, phone, email } = req.body;
    if (!name || !churchConference) {
      return res.status(400).json({ success: false, message: "Name and conference required" });
    }

    const codeSuffix = name.split(" ")[0].toUpperCase().replace(/[^A-Z]/g, "");
    const referralCode = `COLP-${codeSuffix}${Math.floor(10 + Math.random() * 90)}`;
    const leId = `LE-KE-2026-${Math.floor(100 + Math.random() * 900)}`;

    const newLE = {
      leId,
      name,
      churchConference,
      phone: phone || "",
      email: email || "",
      referralCode,
      totalSalesCommission: 0,
      booksDistributed: 0,
      activeCustomers: 0,
      commissionRate: 0.25,
      createdAt: new Date(),
    };

    const docRef = await db.collection(COLLECTION).add(newLE);
    res.status(201).json({ success: true, id: docRef.id, colporteur: newLE });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;

