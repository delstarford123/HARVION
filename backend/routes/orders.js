const express = require("express");
const router = express.Router();
const { db } = require("../firebaseAdmin");

const COLLECTION = "orders";

// GET /api/orders - Get orders (with optional customer phone/id filter)
router.get("/", async (req, res) => {
  try {
    const { phone, status } = req.query;
    let query = db.collection(COLLECTION);

    if (phone) {
      query = query.where("customerPhone", "==", phone);
    }
    if (status) {
      query = query.where("status", "==", status);
    }

    const snapshot = await query.orderBy("orderDate", "desc").get();
    const orders = [];
    snapshot.forEach((doc) => {
      orders.push({ id: doc.id, ...doc.data() });
    });

    res.json({ success: true, count: orders.length, data: orders });
  } catch (error) {
    console.error("Error fetching orders:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// GET /api/orders/:id - Track order
router.get("/:id", async (req, res) => {
  try {
    const doc = await db.collection(COLLECTION).doc(req.params.id).get();
    if (!doc.exists) {
      // Check if orderId was passed as field
      const query = await db.collection(COLLECTION).where("orderId", "==", req.params.id).get();
      if (query.empty) {
        return res.status(404).json({ success: false, message: "Order not found" });
      }
      const data = query.docs[0].data();
      return res.json({ success: true, data: { id: query.docs[0].id, ...data } });
    }
    res.json({ success: true, data: { id: doc.id, ...doc.data() } });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/orders - Create new order
router.post("/", async (req, res) => {
  try {
    const {
      customerName,
      customerPhone,
      deliveryMethod,
      deliveryAddress,
      items,
      subtotal,
      deliveryFee,
      discount,
      totalAmount,
      paymentMethod,
      colporteurCode,
    } = req.body;

    if (!customerName || !customerPhone || !items || items.length === 0) {
      return res.status(400).json({ success: false, message: "Missing required order fields." });
    }

    const orderId = `HARV-${Date.now().toString().slice(-6)}`;
    const newOrder = {
      orderId,
      customerName,
      customerPhone,
      deliveryMethod: deliveryMethod || "Direct Doorstep Delivery (Rider)",
      deliveryAddress: deliveryAddress || "Nairobi Central SDA Church Depot",
      items,
      subtotal: Number(subtotal || 0),
      deliveryFee: Number(deliveryFee || 250),
      discount: Number(discount || 0),
      totalAmount: Number(totalAmount || 0),
      paymentMethod: paymentMethod || "M-Pesa (Mobile Money)",
      paymentStatus: paymentMethod === "Cash on Delivery / Church Pickup" ? "Pending" : "Paid",
      status: "confirmed",
      orderDate: new Date(),
      estimatedDelivery: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000), // 2 days
      colporteurCode: colporteurCode || null,
      deliveryRiderName: "Brother Daniel (Harvion Dispatch Courier)",
      deliveryRiderPhone: "+254 712 345 678",
    };

    const docRef = await db.collection(COLLECTION).add(newOrder);

    // If colporteur code provided, update LE stats
    if (colporteurCode) {
      const leQuery = await db.collection("colporteurs").where("referralCode", "==", colporteurCode).get();
      if (!leQuery.empty) {
        const leDoc = leQuery.docs[0];
        const leData = leDoc.data();
        const earnedCommission = newOrder.subtotal * (leData.commissionRate || 0.25);
        await leDoc.ref.update({
          totalSalesCommission: (leData.totalSalesCommission || 0) + earnedCommission,
          booksDistributed: (leData.booksDistributed || 0) + items.length,
        });
      }
    }

    res.status(201).json({
      success: true,
      message: "Order placed successfully",
      id: docRef.id,
      order: newOrder,
    });
  } catch (error) {
    console.error("Order creation error:", error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// PATCH /api/orders/:id/status - Update order tracking status
router.patch("/:id/status", async (req, res) => {
  try {
    const { status, riderName, riderPhone } = req.body;
    const validStatuses = ["confirmed", "processing", "dispatched", "inTransit", "delivered", "cancelled"];

    if (!validStatuses.includes(status)) {
      return res.status(400).json({ success: false, message: `Invalid status. Must be one of: ${validStatuses.join(", ")}` });
    }

    const orderRef = db.collection(COLLECTION).doc(req.params.id);
    const doc = await orderRef.get();
    if (!doc.exists) {
      return res.status(404).json({ success: false, message: "Order not found" });
    }

    const updateData = { status, statusUpdatedAt: new Date() };
    if (riderName) updateData.deliveryRiderName = riderName;
    if (riderPhone) updateData.deliveryRiderPhone = riderPhone;

    await orderRef.update(updateData);
    res.json({ success: true, message: `Order status updated to ${status}` });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;

