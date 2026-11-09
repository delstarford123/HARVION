const express = require("express");
const router = express.Router();
const path = require("path");
const fs = require("fs");

let hymnsCatalog = null;
try {
  const jsonPath = path.join(__dirname, "../public/assets/hymns_catalog.json");
  if (fs.existsSync(jsonPath)) {
    const raw = fs.readFileSync(jsonPath, "utf-8");
    hymnsCatalog = JSON.parse(raw).hymns;
  }
} catch (e) {
  console.warn("[Hymns Route] Failed to load static hymns JSON:", e);
}

// GET /api/hymns
router.get("/", (req, res) => {
  const limit = parseInt(req.query.limit || "50", 10);
  const search = (req.query.search || req.query.q || "").toLowerCase().trim();
  const category = (req.query.category || "").trim();

  let filtered = hymnsCatalog || [];
  if (category) {
    filtered = filtered.filter(h => h.category === category);
  }
  if (search) {
    filtered = filtered.filter(h =>
      h.hymn_number.toString().includes(search) ||
      h.title.toLowerCase().includes(search) ||
      (h.tune && h.tune.toLowerCase().includes(search)) ||
      (h.author && h.author.toLowerCase().includes(search))
    );
  }

  res.json({
    success: true,
    total: filtered.length,
    hymns: filtered.slice(0, limit)
  });
});

// GET /api/hymns/categories
router.get("/categories", (req, res) => {
  const cats = Array.from(new Set((hymnsCatalog || []).map(h => h.category).filter(Boolean)));
  res.json({
    success: true,
    totalCategories: cats.length,
    categories: cats
  });
});

// GET /api/hymns/:number
router.get("/:number", (req, res) => {
  const num = parseInt(req.params.number, 10);
  const hymn = (hymnsCatalog || []).find(h => h.hymn_number === num);
  if (hymn) {
    res.json({ success: true, hymn });
  } else {
    res.status(404).json({ success: false, message: `Hymn #${num} not found` });
  }
});

module.exports = router;

