import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';

class PaymentScreen extends StatefulWidget {
  final String itemId;
  final String itemName;
  final int price;

  const PaymentScreen({
    super.key,
    required this.itemId,
    required this.itemName,
    required this.price,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isProcessing = false;

  // ⚠️ TODO: Replace these with your actual Safaricom Daraja credentials
  final String consumerKey = 'noADlOJZOn5nLv6DM4ZlC1P5M1ynrU3nRkT7ywNYkfjri2Xz';
  final String consumerSecret =
      '2yzsavvoXEaYKn8OiAR6gwM4wEWlQ7Sz8FDVYcuF164PTPQmBrDY1gcheYX3aXdX';
  final String passkey =
      'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';
  final String shortCode = '174379'; // Paybill or Till

  // Note: Use sandbox for testing. Change to 'api' for production.
  final String baseUrl = 'https://sandbox.safaricom.co.ke';

  @override
  void initState() {
    super.initState();
    _autoFillPhoneNumber();
  }

  // Automatically pulls the phone number they used to log in!
  void _autoFillPhoneNumber() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.phoneNumber != null) {
      String phone = user.phoneNumber!;
      // Convert +2547... to 07... for the text field display
      if (phone.startsWith('+254')) {
        phone = '0${phone.substring(4)}';
      }
      _phoneController.text = phone;
    }
  }

  // 1. Generate Auth Token
  Future<String?> _getAccessToken() async {
    final bytes = utf8.encode("$consumerKey:$consumerSecret");
    final base64Auth = base64.encode(bytes);

    final response = await http.get(
      Uri.parse('$baseUrl/oauth/v1/generate?grant_type=client_credentials'),
      headers: {'Authorization': 'Basic $base64Auth'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse['access_token'];
    }
    return null;
  }

  // 2. Trigger STK Push
  Future<void> _triggerMpesaPayment() async {
    String phone = _phoneController.text.trim();

    // Format phone to 254... for Daraja
    if (phone.startsWith('0')) {
      phone = '254${phone.substring(1)}';
    } else if (phone.startsWith('+254')) {
      phone = phone.substring(1);
    }

    if (phone.length != 12) {
      _showSnack("Please enter a valid 10-digit phone number.", isError: true);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isProcessing = true);

    try {
      final token = await _getAccessToken();
      if (token == null)
        throw Exception("Failed to authenticate with Safaricom");

      // Generate Timestamp & Password
      final timestamp = [
        DateTime.now().year.toString(),
        DateTime.now().month.toString().padLeft(2, '0'),
        DateTime.now().day.toString().padLeft(2, '0'),
        DateTime.now().hour.toString().padLeft(2, '0'),
        DateTime.now().minute.toString().padLeft(2, '0'),
        DateTime.now().second.toString().padLeft(2, '0'),
      ].join();

      final password =
          base64.encode(utf8.encode("$shortCode$passkey$timestamp"));

      // Safaricom limits AccountReference to 12 chars
      String accountRef = widget.itemName.length > 12
          ? widget.itemName.substring(0, 12)
          : widget.itemName;

      // The STK Request Payload
      final requestBody = {
        "BusinessShortCode": shortCode,
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": widget.price, // 🚀 DYNAMIC PRICE HERE!
        "PartyA": phone,
        "PartyB": shortCode,
        "PhoneNumber": phone,
        "CallBackURL":
            "https://your-cloud-function-url.net/mpesaCallback", // ⚠️ Must be updated when you launch!
        "AccountReference": accountRef,
        "TransactionDesc": "Unlock ${widget.itemName}"
      };

      final response = await http.post(
        Uri.parse('$baseUrl/mpesa/stkpush/v1/processrequest'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['ResponseCode'] == '0') {
        // Save the CheckoutRequestID to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'latestCheckoutId': responseData['CheckoutRequestID'],
          'paymentStatus': 'pending',
        });

        _showSnack("M-Pesa Prompt sent! Check your phone.");

        // 🚀 FOR TESTING ONLY: Auto-unlock the item so you can test the UI flow
        // In production, your CallBackURL (webhook) will do this!
        _simulatePaymentSuccess(user.uid);
      } else {
        throw Exception(responseData['errorMessage'] ?? "Transaction failed");
      }
    } catch (e) {
      _showSnack("Failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ⚠️ Remove this once you set up a real backend callback URL!
  Future<void> _simulatePaymentSuccess(String uid) async {
    await Future.delayed(const Duration(
        seconds: 5)); // Wait 5 seconds to simulate user entering PIN
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'purchasedItems': FieldValue.arrayUnion([widget.itemId]),
      'paymentStatus': 'completed',
    });
    if (mounted) {
      _showSnack("Payment successful! Item unlocked.");
      Navigator.pop(context); // Return to the item detail screen
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: isError ? Colors.red : AppTheme.primaryGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Unlock Content'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.lock_open, size: 100, color: AppTheme.sacredGold),
            const SizedBox(height: 24),
            const Text("Premium Access",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue)),
            const SizedBox(height: 12),
            Text(
                "You are about to securely purchase lifetime access to '${widget.itemName}'.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, color: Colors.grey, height: 1.5)),
            const SizedBox(height: 32),

            // 🚀 Dynamic Pricing Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.3))),
              child: Column(
                children: [
                  const Text("Total Amount",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen)),
                  const SizedBox(height: 8),
                  Text("Ksh ${widget.price}",
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'M-Pesa Phone Number',
                hintText: 'e.g. 0712345678',
                prefixIcon: const Icon(Icons.phone_android,
                    color: AppTheme.primaryGreen),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: _isProcessing ? null : _triggerMpesaPayment,
                child: _isProcessing
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3))
                    : const Text("PAY WITH M-PESA",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
