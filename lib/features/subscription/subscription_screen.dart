import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isProcessing = false;

  //TODO: Replace these with your Safaricom credentials
  final String consumerKey = 'noADlOJZOn5nLv6DM4ZlC1P5M1ynrU3nRkT7ywNYkfjri2Xz';
  final String consumerSecret =
      '2yzsavvoXEaYKn8OiAR6gwM4wEWlQ7Sz8FDVYcuF164PTPQmBrDY1gcheYX3aXdX';
  final String passkey =
      'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919'; // e.g. bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919
  final String shortCode = '174379'; // Paybill or Till

  // Note: Use sandbox for testing. Change to 'api' for production.
  final String baseUrl = 'https://sandbox.safaricom.co.ke';

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

    // Format phone to 254...
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

      // The STK Request Payload
      final requestBody = {
        "BusinessShortCode": shortCode,
        "Password": password,
        "Timestamp": timestamp,
        "TransactionType": "CustomerPayBillOnline",
        "Amount": 500,
        "PartyA": phone,
        "PartyB": shortCode,
        "PhoneNumber": phone,
        "CallBackURL":
            "https://your-cloud-function-url.net/mpesaCallback", // ⚠️ Update this!
        "AccountReference": "VINE Premium",
        "TransactionDesc": "Monthly Subscription"
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

        _showSnack("M-Pesa Prompt sent! Enter your PIN on your phone.");
      } else {
        throw Exception(responseData['errorMessage'] ?? "Transaction failed");
      }
    } catch (e) {
      _showSnack("Failed: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
    // Keep your beautiful UI exactly the same!
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Unlock Premium'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.workspace_premium,
                size: 100, color: AppTheme.sacredGold),
            const SizedBox(height: 24),
            const Text("VINE Premium Access",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue)),
            const SizedBox(height: 12),
            const Text(
                "Unlock all advanced Plant Tissue Culture guides, Organic Farming manuals, and exclusive audio.",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 16, color: Colors.grey, height: 1.5)),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.3))),
              child: const Column(
                children: [
                  Text("Monthly Subscription",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryGreen)),
                  SizedBox(height: 8),
                  Text("Ksh 500",
                      style: TextStyle(
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
