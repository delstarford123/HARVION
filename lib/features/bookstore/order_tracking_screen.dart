import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import 'models/order_model.dart';

class OrderTrackingScreen extends StatelessWidget {
  final BookstoreOrder order;

  const OrderTrackingScreen({super.key, required this.order});

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not launch $launchUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text('Order #${order.orderId}', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.sacredGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.paymentStatus.toUpperCase(),
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      Text(
                        'ID: ${order.orderId}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    order.statusDisplay,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Destination: ${order.deliveryAddress}',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step Timeline
            const Text(
              'Delivery Progress Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    _buildStepRow(
                      context,
                      stepNumber: 1,
                      title: 'Order Confirmed',
                      subtitle: 'Received at Adventist Publishing depot',
                      isCompleted: order.statusStepIndex >= 0,
                      isCurrent: order.statusStepIndex == 0,
                    ),
                    _buildStepConnector(order.statusStepIndex >= 1),
                    _buildStepRow(
                      context,
                      stepNumber: 2,
                      title: 'Packing & Literature Preparation',
                      subtitle: 'Books inspected, blessed, and boxed',
                      isCompleted: order.statusStepIndex >= 1,
                      isCurrent: order.statusStepIndex == 1,
                    ),
                    _buildStepConnector(order.statusStepIndex >= 2),
                    _buildStepRow(
                      context,
                      stepNumber: 3,
                      title: 'Dispatched from Central Warehouse',
                      subtitle: 'Handed to courier / church distribution runner',
                      isCompleted: order.statusStepIndex >= 2,
                      isCurrent: order.statusStepIndex == 2,
                    ),
                    _buildStepConnector(order.statusStepIndex >= 3),
                    _buildStepRow(
                      context,
                      stepNumber: 4,
                      title: 'In Transit / En Route',
                      subtitle: 'Courier on route to destination',
                      isCompleted: order.statusStepIndex >= 3,
                      isCurrent: order.statusStepIndex == 3,
                    ),
                    _buildStepConnector(order.statusStepIndex >= 4),
                    _buildStepRow(
                      context,
                      stepNumber: 5,
                      title: 'Delivered / Ready for Pickup',
                      subtitle: 'Available at doorstep or church book center',
                      isCompleted: order.statusStepIndex >= 4,
                      isCurrent: order.statusStepIndex == 4,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Courier / Church Contact Card
            if (order.deliveryRiderName != null) ...[
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                        radius: 24,
                        child: const Icon(Icons.two_wheeler, color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Assigned Dispatcher',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              order.deliveryRiderName!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            if (order.deliveryRiderPhone != null)
                              Text(
                                order.deliveryRiderPhone!,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                              ),
                          ],
                        ),
                      ),
                      if (order.deliveryRiderPhone != null)
                        IconButton.filled(
                          style: IconButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                          icon: const Icon(Icons.phone, color: Colors.white, size: 20),
                          onPressed: () => _makeCall(order.deliveryRiderPhone!),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Ordered Items
            const Text(
              'Books in This Dispatch',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.book, size: 18, color: AppTheme.primaryBlue),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${item.book.title} (${item.selectedFormat})',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'x${item.quantity}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Paid', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Ksh ${order.totalAmount.toInt()}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Return home button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('BACK TO HOME DASHBOARD',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
  }) {
    Color indicatorColor = isCompleted
        ? AppTheme.primaryGreen
        : (isCurrent ? AppTheme.sacredGold : Colors.grey.shade300);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: indicatorColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text('$stepNumber',
                    style: TextStyle(
                        color: isCurrent ? Colors.black : Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isCurrent ? AppTheme.primaryBlue : (isCompleted ? Colors.black87 : Colors.grey),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isDone) {
    return Container(
      margin: const EdgeInsets.only(left: 13, top: 4, bottom: 4),
      width: 2,
      height: 24,
      color: isDone ? AppTheme.primaryGreen : Colors.grey.shade300,
    );
  }
}

