const { onRequest } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");

// Initialize Firebase Admin to interact with Firestore
admin.initializeApp();
const db = admin.firestore();

exports.mpesaCallback = onRequest(async (req, res) => {
  // 1. Safaricom expects a quick 200 OK acknowledgment, or it will keep retrying.
  res.status(200).send("Callback received");

  try {
    // 2. Parse the Daraja JSON Payload
    const callbackData = req.body.Body.stkCallback;
    const resultCode = callbackData.ResultCode;
    const checkoutRequestId = callbackData.CheckoutRequestID;

    console.log(`Received STK Callback for CheckoutRequestID: ${checkoutRequestId} with ResultCode: ${resultCode}`);

    // 3. Check if the transaction was successful (ResultCode 0 means Success)
    if (resultCode === 0) {
      // 4. Extract Payment Details (Amount, Receipt Number, Phone)
      const meta = callbackData.CallbackMetadata.Item;
      let amount, receiptNumber, phoneNumber;

      meta.forEach(item => {
        if (item.Name === 'Amount') amount = item.Value;
        if (item.Name === 'MpesaReceiptNumber') receiptNumber = item.Value;
        if (item.Name === 'PhoneNumber') phoneNumber = item.Value;
      });

      console.log(`Payment Successful! Receipt: ${receiptNumber}, Amount: ${amount}, Phone: ${phoneNumber}`);

      // 5. Find the User in Firestore using the CheckoutRequestID
      // (Your Flutter app must save this ID to the user's document when initiating the STK push)
      const usersRef = db.collection('users');
      const querySnapshot = await usersRef.where('latestCheckoutId', '==', checkoutRequestId).get();

      if (querySnapshot.empty) {
        console.error(`CRITICAL: No user found matching CheckoutRequestID: ${checkoutRequestId}`);
        return;
      }

      // 6. Update the User's Subscription Status!
      const userDoc = querySnapshot.docs[0]; // Assuming only one match
      
      // Calculate Expiry Date (e.g., 30 days from now)
      const expiryDate = new Date();
      expiryDate.setDate(expiryDate.getDate() + 30);

      await userDoc.ref.update({
        isSubscribed: true,
        subscriptionExpiry: admin.firestore.Timestamp.fromDate(expiryDate),
        lastPaymentReceipt: receiptNumber,
      });

      console.log(`User ${userDoc.id} successfully upgraded to Premium!`);

    } else {
      // 7. Handle Failed/Cancelled Transactions
      const errorMessage = callbackData.ResultDesc;
      console.log(`Transaction Failed or Cancelled: ${errorMessage}`);
      
      // Optional: Update the user's document to reflect the failure so your Flutter UI can show a specific error
      const usersRef = db.collection('users');
      const querySnapshot = await usersRef.where('latestCheckoutId', '==', checkoutRequestId).get();
      
      if (!querySnapshot.empty) {
         await querySnapshot.docs[0].ref.update({
            lastPaymentError: errorMessage
         });
      }
    }
  } catch (error) {
    console.error("Error processing M-Pesa callback:", error);
  }
});