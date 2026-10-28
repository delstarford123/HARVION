const express = require("express");
const router = express.Router();
const { db } = require("../firebaseAdmin");

const COLLECTION = "bookstore_items";

// GET /api/books - Get all books with optional category/language/search filter
router.get("/", async (req, res) => {
  try {
    const { category, language, format, search, maxPrice } = req.query;
    let query = db.collection(COLLECTION);

    if (category && category !== "All Categories") {
      query = query.where("category", "==", category);
    }
    if (language) {
      query = query.where("language", "==", language);
    }
    if (format) {
      query = query.where("format", "==", format);
    }

    const snapshot = await query.get();
    let books = [];
    snapshot.forEach((doc) => {
      books.push({ id: doc.id, ...doc.data() });
    });

    if (search) {
      const q = search.toLowerCase();
      books = books.filter(
        (b) =>
          (b.title && b.title.toLowerCase().includes(q)) ||
          (b.author && b.author.toLowerCase().includes(q)) ||
          (b.description && b.description.toLowerCase().includes(q))
      );
    }

    if (maxPrice) {
      const max = parseFloat(maxPrice);
      books = books.filter((b) => b.price <= max);
    }

    res.json({ success: true, count: books.length, data: books });
  } catch (error) {
    console.error("Error fetching books:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/books/:id - Get single book by ID
router.get("/:id", async (req, res) => {
  try {
    const doc = await db.collection(COLLECTION).doc(req.params.id).get();
    if (!doc.exists) {
      return res.status(404).json({ success: false, message: "Book not found" });
    }
    res.json({ success: true, data: { id: doc.id, ...doc.data() } });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/books - Add new book
router.post("/", async (req, res) => {
  try {
    const { title, author, category, description, price, originalPrice, format, language, coverImageUrl, inStock, pageCount, rating, isbn, isFeatured, colporteurCommissionNote } = req.body;

    if (!title || !price) {
      return res.status(400).json({ success: false, message: "Title and price are required." });
    }

    const newBook = {
      title,
      author: author || "Ellen G. White",
      category: category || "Spirit of Prophecy",
      description: description || "",
      price: Number(price),
      originalPrice: Number(originalPrice || price),
      format: format || "Paperback",
      language: language || "English",
      coverImageUrl: coverImageUrl || "",
      inStock: inStock !== undefined ? inStock : true,
      pageCount: Number(pageCount || 300),
      rating: Number(rating || 5.0),
      isbn: isbn || "",
      isFeatured: Boolean(isFeatured),
      colporteurCommissionNote: colporteurCommissionNote || null,
      createdAt: new Date(),
    };

    const docRef = await db.collection(COLLECTION).add(newBook);
    res.status(201).json({ success: true, id: docRef.id, data: newBook });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// PUT /api/books/:id - Update book details
router.put("/:id", async (req, res) => {
  try {
    const bookRef = db.collection(COLLECTION).doc(req.params.id);
    const doc = await bookRef.get();
    if (!doc.exists) {
      return res.status(404).json({ success: false, message: "Book not found" });
    }

    const updates = { ...req.body, updatedAt: new Date() };
    await bookRef.update(updates);
    res.json({ success: true, message: "Book updated successfully", id: req.params.id });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// DELETE /api/books/:id
router.delete("/:id", async (req, res) => {
  try {
    await db.collection(COLLECTION).doc(req.params.id).delete();
    res.json({ success: true, message: "Book deleted successfully" });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/books/seller-requests - Submit request to sell books
router.post("/seller-requests", async (req, res) => {
  try {
    const data = req.body;
    const docRef = await db.collection("book_seller_requests").add({
      ...data,
      status: "pending",
      submittedAt: new Date(),
    });
    // Add admin notification
    await db.collection("admin_notifications").add({
      title: "New Book Seller Application",
      message: `${data.sellerName || "Colporteur"} requested to sell "${data.bookTitle || "New Book"}"`,
      requestId: docRef.id,
      isRead: false,
      createdAt: new Date(),
    });
    res.status(201).json({ success: true, id: docRef.id, message: "Request submitted for admin approval" });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/books/seller-requests - List seller requests
router.get("/seller-requests", async (req, res) => {
  try {
    const snapshot = await db.collection("book_seller_requests").orderBy("submittedAt", "desc").get();
    const requests = [];
    snapshot.forEach((doc) => requests.push({ id: doc.id, ...doc.data() }));
    res.json({ success: true, count: requests.length, data: requests });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// PUT /api/books/seller-requests/:id/approve - Approve seller request & publish book
router.put("/seller-requests/:id/approve", async (req, res) => {
  try {
    const reqRef = db.collection("book_seller_requests").doc(req.params.id);
    const doc = await reqRef.get();
    if (!doc.exists) {
      return res.status(404).json({ success: false, message: "Request not found" });
    }

    const data = doc.data();
    // Publish into bookstore_items
    const publishedBook = {
      title: data.bookTitle || "Untitled",
      author: data.author || "Ellen G. White",
      category: data.category || "Christian Living & Family",
      description: data.description || "",
      price: Number(data.price || 0),
      originalPrice: Number(data.originalPrice || data.price || 0),
      format: data.hasHardCopy && data.hasSoftCopy ? "Hardcover & Soft Copy" : (data.hasSoftCopy ? "Digital PDF" : "Paperback"),
      hasHardCopy: Boolean(data.hasHardCopy),
      hasSoftCopy: Boolean(data.hasSoftCopy),
      softCopyPrice: data.softCopyPrice ? Number(data.softCopyPrice) : null,
      softCopyUrl: data.softCopyUrl || null,
      language: data.language || "English",
      coverImageUrl: data.coverImageUrl || "",
      previewImages: data.previewImages || [],
      inStock: true,
      pageCount: Number(data.pageCount || 250),
      rating: 5.0,
      isbn: data.isbn || "",
      isFeatured: false,
      sellerName: data.sellerName || null,
      sellerPhone: data.sellerPhone || null,
      sellerId: doc.id,
      isApproved: true,
      createdAt: new Date(),
    };

    const bookDoc = await db.collection(COLLECTION).add(publishedBook);
    await reqRef.update({ status: "approved", approvedAt: new Date(), publishedBookId: bookDoc.id });

    res.json({ success: true, message: "Request approved and book published to bookstore", bookId: bookDoc.id });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;

