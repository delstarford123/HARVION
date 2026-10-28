const express = require("express");
const router = express.Router();
const https = require("https");
const { db } = require("../firebaseAdmin");

const CONSUMER_KEY = process.env.MPESA_CONSUMER_KEY || "noADlOJZOn5nLv6DM4ZlC1P5M1ynrU3nRkT7ywNYkfjri2Xz";
const CONSUMER_SECRET = process.env.MPESA_CONSUMER_SECRET || "2yzsavvoXEaYKn8OiAR6gwM4wEWlQ7Sz8FDVYcuF164PTPQmBrDY1gcheYX3aXdX";
const PASSKEY = process.env.MPESA_PASSKEY || "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919";
const SHORTCODE = process.env.MPESA_SHORTCODE || "174379";
const BASE_URL = process.env.MPESA_ENV === "production" ? "api.safaricom.co.ke" : "sandbox.safaricom.co.ke";

// Helper: Get Daraja OAuth token
function getOAuthToken() {
  return new Promise((resolve, reject) => {
    const auth = Buffer.from(`${CONSUMER_KEY}:${CONSUMER_SECRET}`).toString("base64");
    const options = {
      hostname: BASE_URL,
      path: "/oauth/v1/generate?grant_type=client_credentials",
      method: "GET",
      headers: { Authorization: `Basic ${auth}` },
    };

    const req = https.request(options, (res) => {
      let data = "";
      res.on("data", (chunk) => (data += chunk));
      res.on("end", () => {
        try {
          const json = JSON.parse(data);
          resolve(json.access_token);
        } catch (e) {
          reject(e);
        }
      });
    });
    req.on("error", (e) => reject(e));
    req.end();
  });
}

// POST /api/payments/stk-push - Trigger M-Pesa prompt on buyer's phone
router.post("/stk-push", async (req, res) => {
  try {
    let { phone, amount, orderId, accountReference } = req.body;

    if (!phone || !amount) {
      return res.status(400).json({ success: false, message: "Phone and amount are required." });
    }

    // Format phone to 254...
    phone = phone.trim().replace(/\+/g, "");
    if (phone.startsWith("0")) phone = "254" + phone.substring(1);

    const token = await getOAuthToken().catch(() => null);

    // If sandbox credentials or network unavailable, simulate mock STK push
    if (!token) {
      const mockCheckoutId = `ws_CO_${Date.now()}`;
      return res.json({
        success: true,
        mock: true,
        message: "M-Pesa STK Push simulated for testing. Check prompt on device.",
        CheckoutRequestID: mockCheckoutId,
        CustomerMessage: "Success. Request accepted for processing",
      });
    }

    const timestamp = new Date()
      .toISOString()
      .replace(/[^0-9]/g, "")
      .slice(0, 14);
    const password = Buffer.from(`${SHORTCODE}${PASSKEY}${timestamp}`).toString("base64");

    const payload = JSON.stringify({
      BusinessShortCode: SHORTCODE,
      Password: password,
      Timestamp: timestamp,
      TransactionType: "CustomerPayBillOnline",
      Amount: Math.round(Number(amount)),
      PartyA: phone,
      PartyB: SHORTCODE,
      PhoneNumber: phone,
      CallBackURL: process.env.CALLBACK_URL || "https://harvion-backend.web.app/api/payments/callback",
      AccountReference: (accountReference || "HARVION").substring(0, 12),
      TransactionDesc: `Harvion Order ${orderId || ""}`.substring(0, 12),
    });

    const options = {
      hostname: BASE_URL,
      path: "/mpesa/stkpush/v1/processrequest",
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
        "Content-Length": Buffer.byteLength(payload),
      },
    };

    const stkReq = https.request(options, (stkRes) => {
      let data = "";
      stkRes.on("data", (chunk) => (data += chunk));
      stkRes.on("end", () => {
        try {
          const responseData = JSON.parse(data);
          res.json({ success: true, ...responseData });
        } catch (e) {
          res.status(500).json({ success: false, error: e.message });
        }
      });
    });

    stkReq.on("error", (e) => res.status(500).json({ success: false, error: e.message }));
    stkReq.write(payload);
    stkReq.end();
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/payments/callback - Webhook called by Safaricom Daraja
router.post("/callback", async (req, res) => {
  res.status(200).send("Callback received");

  try {
    const callbackData = req.body?.Body?.stkCallback;
    if (!callbackData) return;

    const { ResultCode, CheckoutRequestID, CallbackMetadata } = callbackData;

    console.log(`[M-Pesa Webhook] CheckoutRequestID: ${CheckoutRequestID}, ResultCode: ${ResultCode}`);

    if (ResultCode === 0 && CallbackMetadata) {
      let receiptNumber, amount, phoneNumber;
      CallbackMetadata.Item.forEach((item) => {
        if (item.Name === "MpesaReceiptNumber") receiptNumber = item.Value;
        if (item.Name === "Amount") amount = item.Value;
        if (item.Name === "PhoneNumber") phoneNumber = item.Value;
      });

      console.log(`[M-Pesa Success] Receipt: ${receiptNumber}, Amount: ${amount}`);

      // Update matching order in Firestore
      const ordersRef = db.collection("orders");
      const orderMatch = await ordersRef.where("checkoutRequestId", "==", CheckoutRequestID).get();
      if (!orderMatch.empty) {
        await orderMatch.docs[0].ref.update({
          paymentStatus: "Paid",
          mpesaReceipt: receiptNumber,
          paidAt: new Date(),
        });
      }
    }
  } catch (e) {
    console.error("Callback processing error:", e);
  }
});

module.exports = router;

