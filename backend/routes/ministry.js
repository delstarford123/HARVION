const express = require("express");
const router = express.Router();
const { db } = require("../firebaseAdmin");

// 1. DEVOTIONALS
router.get("/devotionals", async (req, res) => {
  try {
    const snapshot = await db.collection("devotionals").orderBy("date", "desc").limit(30).get();
    const data = [];
    snapshot.forEach((doc) => data.push({ id: doc.id, ...doc.data() }));
    res.json({ success: true, count: data.length, data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 2. SABBATH SCHOOL
router.get("/sabbath-school", async (req, res) => {
  try {
    const snapshot = await db.collection("sabbath_school_lessons").orderBy("lessonNumber", "asc").get();
    const data = [];
    snapshot.forEach((doc) => data.push({ id: doc.id, ...doc.data() }));
    res.json({ success: true, count: data.length, data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 3. PRAYER WALL
router.get("/prayers", async (req, res) => {
  try {
    const { category } = req.query;
    let query = db.collection("prayer_requests");
    if (category && category !== "All") {
      query = query.where("category", "==", category);
    }
    const snapshot = await query.orderBy("datePosted", "desc").limit(50).get();
    const data = [];
    snapshot.forEach((doc) => data.push({ id: doc.id, ...doc.data() }));
    res.json({ success: true, count: data.length, data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post("/prayers", async (req, res) => {
  try {
    const { authorName, isAnonymous, title, description, category } = req.body;
    if (!title || !description) {
      return res.status(400).json({ success: false, message: "Title and description required." });
    }

    const newPrayer = {
      authorName: isAnonymous ? "A Fellow Believer" : authorName || "Anonymous",
      isAnonymous: Boolean(isAnonymous),
      title,
      description,
      category: category || "General",
      datePosted: new Date(),
      prayerCount: 1,
      isAnswered: false,
    };

    const docRef = await db.collection("prayer_requests").add(newPrayer);
    res.status(201).json({ success: true, id: docRef.id, data: newPrayer });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

router.post("/prayers/:id/pray", async (req, res) => {
  try {
    const prayerRef = db.collection("prayer_requests").doc(req.params.id);
    const doc = await prayerRef.get();
    if (!doc.exists) {
      return res.status(404).json({ success: false, message: "Prayer request not found" });
    }

    const currentCount = doc.data().prayerCount || 0;
    await prayerRef.update({ prayerCount: currentCount + 1 });
    res.json({ success: true, prayerCount: currentCount + 1 });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 4. HEALTHY RECIPES
router.get("/recipes", async (req, res) => {
  try {
    const { category } = req.query;
    let query = db.collection("healthy_recipes");
    if (category && category !== "All") {
      query = query.where("category", "==", category);
    }
    const snapshot = await query.get();
    const data = [];
    snapshot.forEach((doc) => data.push({ id: doc.id, ...doc.data() }));
    res.json({ success: true, count: data.length, data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 5. CHURCH DIRECTORY
router.get("/churches", async (req, res) => {
  try {
    const { city } = req.query;
    let query = db.collection("churches_directory");
    if (city && city !== "All") {
      query = query.where("city", "==", city);
    }
    const snapshot = await query.get();
    const data = [];
    snapshot.forEach((doc) => data.push({ id: doc.id, ...doc.data() }));
    res.json({ success: true, count: data.length, data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 6. DIGITAL TRACTS
router.get("/tracts", async (req, res) => {
  try {
    const snapshot = await db.collection("digital_tracts").get();
    const data = [];
    snapshot.forEach((doc) => data.push({ id: doc.id, ...doc.data() }));
    res.json({ success: true, count: data.length, data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 7. FAMILY LIFE PILLARS
router.get("/family-pillars", async (req, res) => {
  try {
    const snapshot = await db.collection("family_pillars").orderBy("orderIndex").get();
    const data = [];
    snapshot.forEach((doc) => data.push({ id: doc.id, ...doc.data() }));
    res.json({ success: true, count: data.length, data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 8. CAMP MEETING & FIELD LOCATIONS
router.get("/camp-meeting-locations", async (req, res) => {
  try {
    const snapshot = await db.collection("camp_meeting_locations").orderBy("postedAt", "desc").get();
    const data = [];
    snapshot.forEach((doc) => data.push({ id: doc.id, ...doc.data() }));
    res.json({ success: true, count: data.length, data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// 9. SERMONS & LIVESTREAMS
router.get("/sermons", async (req, res) => {
  try {
    const snapshot = await db.collection("sermons").orderBy("publishedDate", "desc").get();
    const data = [];
    snapshot.forEach((doc) => data.push({ id: doc.id, ...doc.data() }));
    res.json({ success: true, count: data.length, data });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;

