import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import 'services/cart_service.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _selectedDeliveryMethod = 'Direct Doorstep Delivery (Rider)';
  String _selectedHub = AppConstants.sdaDistributionHubs.first;
  String _selectedPaymentMethod = 'M-Pesa (Mobile Money)';
  bool _isProcessing = false;

  final cartService = CartService();

  @override
  void initState() {
    super.initState();
    _autoFillUser();
  }

  void _autoFillUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        _nameController.text = user.displayName!;
      } else {
        _nameController.text = 'Brother / Sister';
      }
      if (user.phoneNumber != null) {
        String p = user.phoneNumber!;
        if (p.startsWith('+254')) p = '0${p.substring(4)}';
        _phoneController.text = p;
      } else {
        _phoneController.text = '0745090990';
      }
    } else {
      _nameController.text = 'Alfredo Onuko';
      _phoneController.text = '0745090990';
      _addressController.text = 'Maxwell Adventist Centre, Nairobi';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    // Simulate processing payment / order creation
    await Future.delayed(const Duration(seconds: 2));

    final deliveryAddress = _selectedDeliveryMethod == 'Direct Doorstep Delivery (Rider)'
        ? _addressController.text.trim()
        : 'Pickup at $_selectedHub';

    final order = cartService.createOrder(
      customerName: _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      deliveryMethod: _selectedDeliveryMethod,
      deliveryAddress: deliveryAddress,
      paymentMethod: _selectedPaymentMethod,
    );

    if (mounted) {
      setState(() => _isProcessing = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(order: order),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Checkout & Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Contact Information
              _buildSectionHeader('1. Recipient & Contact Information', Icons.person_outline),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person, color: AppTheme.primaryBlue),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number (M-Pesa / Delivery)',
                          prefixIcon: Icon(Icons.phone, color: AppTheme.primaryGreen),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Please enter phone number' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Delivery Options
              _buildSectionHeader('2. Choose Delivery Method', Icons.local_shipping_outlined),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('Direct Doorstep Delivery (Rider)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: const Text('Delivered to your home, office, or institution.'),
                        value: 'Direct Doorstep Delivery (Rider)',
                        groupValue: _selectedDeliveryMethod,
                        activeColor: AppTheme.primaryGreen,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDeliveryMethod = val);
                        },
                      ),
                      if (_selectedDeliveryMethod == 'Direct Doorstep Delivery (Rider)') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Street Address / Estate / House No.',
                              hintText: 'e.g. Westlands, Rhapta Road, House 4B',
                              prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryGreen),
                            ),
                            validator: (v) {
                              if (_selectedDeliveryMethod == 'Direct Doorstep Delivery (Rider)' &&
                                  (v == null || v.isEmpty)) {
                                return 'Please specify delivery address';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                      const Divider(),
                      RadioListTile<String>(
                        title: const Text('SDA Church Distribution Depot Pickup',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: const Text('Pick up from your local church center or conference book store.'),
                        value: 'SDA Church Distribution Depot',
                        groupValue: _selectedDeliveryMethod,
                        activeColor: AppTheme.primaryGreen,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDeliveryMethod = val);
                        },
                      ),
                      if (_selectedDeliveryMethod == 'SDA Church Distribution Depot') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: DropdownButtonFormField<String>(
                            value: _selectedHub,
                            decoration: const InputDecoration(
                              labelText: 'Select Church Pickup Station',
                              prefixIcon: Icon(Icons.church, color: AppTheme.primaryBlue),
                            ),
                            items: AppConstants.sdaDistributionHubs.map((hub) {
                              return DropdownMenuItem(value: hub, child: Text(hub, style: const TextStyle(fontSize: 13)));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedHub = val);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Payment Method
              _buildSectionHeader('3. Localized Payment Option', Icons.payment_outlined),
              const SizedBox(height: 12),
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: AppConstants.paymentMethods.map((method) {
                      IconData icon = Icons.phone_android;
                      if (method.contains('Card')) icon = Icons.credit_card;
                      if (method.contains('Cash')) icon = Icons.payments;

                      return RadioListTile<String>(
                        secondary: Icon(icon, color: AppTheme.primaryBlue),
                        title: Text(method, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        value: method,
                        groupValue: _selectedPaymentMethod,
                        activeColor: AppTheme.primaryGreen,
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedPaymentMethod = val);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Total review
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount Due:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                    ),
                    Text(
                      'Ksh ${cartService.totalAmount.toInt()}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.primaryGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Place Order button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isProcessing ? null : _handlePlaceOrder,
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _selectedPaymentMethod.contains('M-Pesa')
                              ? 'PAY & PLACE ORDER (STK PUSH)'
                              : 'CONFIRM & DISPATCH ORDER',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue),
        ),
      ],
    );
  }
}

