import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../bookstore/models/physical_book_model.dart';
import '../bookstore/models/order_model.dart';
import '../sermons/sermon_model.dart';
import '../sermons/video_player_screen.dart';
import '../music/song_model.dart';
import '../music/music_player_screen.dart';
import 'admin_book_editor.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isActionProcessing = false;

  // Daily Quote Controllers
  final _quoteTextController = TextEditingController();
  final _quoteRefController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quoteTextController.dispose();
    _quoteRefController.dispose();
    super.dispose();
  }

  // ==========================================
  // 💰 UPDATE ORDER STATUS
  // ==========================================
  Future<void> _updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order $orderId updated to ${newStatus.name.toUpperCase()}'),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update order: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==========================================
  // 📚 QUICK ADJUST BOOK STOCK
  // ==========================================
  Future<void> _adjustStock(String bookId, int delta) async {
    try {
      await FirebaseFirestore.instance.collection('bookstore_items').doc(bookId).update({
        'stockCount': FieldValue.increment(delta),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inventory stock adjusted by ${delta > 0 ? "+$delta" : "$delta"} copies.'),
            duration: const Duration(milliseconds: 900),
          ),
        );
      }
    } catch (e) {
      debugPrint('Stock adjustment error: $e');
    }
  }

  // ==========================================
  // 🔴 END LIVE STREAM BROADCAST
  // ==========================================
  Future<void> _endLiveStream(String streamId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Live Broadcast?'),
        content: Text('Are you sure you want to stop the live stream "$title"? This will remove the live banner and alert for all users.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End Stream'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('live_announcements').doc(streamId).update({
        'isActive': false,
        'endedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ended broadcast "$title"'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==========================================
  // 🧹 PURGE MOCK DATA
  // ==========================================
  Future<void> _purgeMockData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Purge Mock Data?'),
          ],
        ),
        content: const Text(
          'This will delete all test orders, sample live announcements, and non-verified test items from the database.\n\nOnly real literature orders will remain. Continue?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Purge All Mock Data'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isActionProcessing = true);
      try {
        // Clear live announcements that are inactive
        final oldAnnounce = await FirebaseFirestore.instance
            .collection('live_announcements')
            .where('isActive', isEqualTo: false)
            .get();
        for (var doc in oldAnnounce.docs) {
          await doc.reference.delete();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pristine database state confirmed! Mock records cleaned.'),
              backgroundColor: AppTheme.primaryGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Purge error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isActionProcessing = false);
      }
    }
  }

  // ==========================================
  // ☀️ PUBLISH DAILY QUOTE
  // ==========================================
  Future<void> _publishQuote() async {
    final text = _quoteTextController.text.trim();
    final ref = _quoteRefController.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance.collection('daily_quotes').add({
      'text': text,
      'reference': ref.isNotEmpty ? ref : 'Spirit of Prophecy',
      'displayDate': FieldValue.serverTimestamp(),
    });

    _quoteTextController.clear();
    _quoteRefController.clear();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily Quote published to Home Screen!'), backgroundColor: AppTheme.primaryGreen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: AppTheme.sacredGold),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'HARVION Executive Control Center',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Secure Admin Logout',
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Exit Admin Portal?'),
                  content: const Text('You will need your admin email and password to re-enter the executive center.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Stay')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                Navigator.pop(context);
              }
            },
          ),
        ],
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.sacredGold,
          indicatorWeight: 3,
          labelColor: AppTheme.sacredGold,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Orders & Money'),
            Tab(icon: Icon(Icons.menu_book), text: 'Hardcopy Catalog'),
            Tab(icon: Icon(Icons.live_tv), text: 'Live Worship Control'),
            Tab(icon: Icon(Icons.library_music), text: 'Music & Audio'),
            Tab(icon: Icon(Icons.how_to_reg), text: 'Seller Requests'),
            Tab(icon: Icon(Icons.format_quote), text: 'Devotionals & Quotes'),
            Tab(icon: Icon(Icons.settings_suggest), text: 'System & Database'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersAndRevenueTab(),
          _buildBooksTab(),
          _buildLiveStreamsTab(),
          _buildMusicAndAudioTab(),
          _buildSellerApprovalsTab(),
          _buildQuotesTab(),
          _buildSystemSanitizerTab(),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: 💰 ORDERS & REVENUE ANALYTICS
  // ==========================================
  Widget _buildOrdersAndRevenueTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ministry_donations')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, donationSnap) {
        final donationDocs = donationSnap.hasData ? donationSnap.data!.docs : [];
        double totalDonations = 0.0;
        for (var d in donationDocs) {
          final dData = d.data() as Map<String, dynamic>;
          totalDonations += (dData['amount'] as num? ?? 0.0).toDouble();
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orders')
              .orderBy('orderDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
            }

            final docs = snapshot.hasData ? snapshot.data!.docs : [];
            double totalRevenue = 0.0;
            int pendingOrdersCount = 0;
            int deliveredCount = 0;
            Map<String, int> regionCounts = {};

            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final amount = (data['totalAmount'] as num? ?? 0.0).toDouble();
              final status = (data['status'] as String? ?? '').toLowerCase();
              final paymentStatus = (data['paymentStatus'] as String? ?? '').toLowerCase();
              final hub = data['sdaChurchDepot'] as String? ?? data['deliveryAddress'] as String? ?? 'Nairobi';

              // Extract region/town keyword
              String region = 'Nairobi';
              if (hub.contains('Maxwell')) {
                region = 'Maxwell Adventist Centre';
              } else if (hub.contains('Kisumu')) {
                region = 'Kisumu Central';
              } else if (hub.contains('Mombasa')) {
                region = 'Mombasa Central';
              } else if (hub.contains('Nakuru')) {
                region = 'Nakuru Station';
              } else if (hub.contains('Rider') || hub.contains('Doorstep')) {
                region = 'Direct Doorstep Rider';
              } else {
                region = 'SDA Church Depot';
              }

              regionCounts[region] = (regionCounts[region] ?? 0) + 1;

              if (paymentStatus.contains('paid') || status.contains('deliver') || status.contains('dispatch')) {
                totalRevenue += amount;
              }
              if (status.contains('pending') || status.contains('confirm')) {
                pendingOrdersCount++;
              }
              if (status.contains('deliver')) {
                deliveredCount++;
              }
            }

            final combinedTotal = totalRevenue + totalDonations;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 🌟 Combined Total Ministry Funds Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryBlue, Color(0xFF0D3B66)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.volunteer_activism, color: AppTheme.sacredGold, size: 18),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'TOTAL KINGDOM FUNDS COLLECTED',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Ksh ${combinedTotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Book Sales: Ksh ${totalRevenue.toStringAsFixed(0)}  •  Support: Ksh ${totalDonations.toStringAsFixed(0)}',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.sacredGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'TOTAL GIVEN',
                              style: TextStyle(color: AppTheme.sacredGold, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${donationDocs.length} Offerings',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Revenue Metric Cards Row 1: Book Sales vs Ministry Support
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Book Sales (KES)',
                        value: 'Ksh ${totalRevenue.toStringAsFixed(0)}',
                        icon: Icons.payments,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Ministry Support (KES)',
                        value: 'Ksh ${totalDonations.toStringAsFixed(0)}',
                        icon: Icons.favorite,
                        color: Colors.pink.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Orders',
                        value: '${docs.length}',
                        icon: Icons.receipt_long,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Delivered',
                        value: '$deliveredCount',
                        icon: Icons.local_shipping,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Pending Dispatch',
                        value: '$pendingOrdersCount',
                        icon: Icons.pending_actions,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Where Books Were Sold Breakdown
                if (regionCounts.isNotEmpty) ...[
                  const Text(
                    'Where Books Were Sold & Dispatched',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: regionCounts.entries.map((entry) {
                          final pct = docs.isNotEmpty ? (entry.value / docs.length) : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('${entry.value} orders (${(pct * 100).toStringAsFixed(0)}%)',
                                        style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    minHeight: 6,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 💖 Real-time Ministry Support & Offerings (M-Pesa STK Push)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.volunteer_activism, color: Colors.pink, size: 20),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Ministry Support & Offerings',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Ksh ${totalDonations.toStringAsFixed(0)} Total',
                        style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (donationDocs.isEmpty)
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'No support offerings recorded yet. Believers can give on the Harvion Support page.',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                    ),
                  )
                else
                  ...donationDocs.map((doc) {
                    final dData = doc.data() as Map<String, dynamic>;
                    final donor = dData['donorName'] as String? ?? 'Faithful Believer';
                    final phone = dData['phone'] as String? ?? '';
                    final amount = (dData['amount'] as num? ?? 0.0).toDouble();
                    final notes = dData['notes'] as String? ?? 'Support HARVION Ministry';
                    final createdAt = dData['createdAt'] as String? ?? '';
                    final status = dData['status'] as String? ?? 'initiated';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        leading: CircleAvatar(
                          backgroundColor: Colors.pink.shade50,
                          child: const Icon(Icons.favorite, color: Colors.pink, size: 20),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(donor, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                            const SizedBox(width: 8),
                            Text('+ Ksh ${amount.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryGreen, fontSize: 15)),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text('$notes • $phone', style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(createdAt, style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(status.toUpperCase(),
                                      style: const TextStyle(color: Colors.teal, fontSize: 9, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 24),

            // Real-time Orders Feed Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'All Customer Book Orders',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${docs.length} Records', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),

            if (docs.isEmpty)
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: const Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No Orders Placed Yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('When believers order books, they appear here live with M-Pesa payment and delivery address.',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              ...docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final order = BookstoreOrder.fromJson(data, doc.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Order #${order.orderId}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.statusDisplay.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('Customer: ${order.customerName} • 📞 ${order.customerPhone}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('📍 Delivery: ${order.deliveryAddress}',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                        const Divider(height: 16),

                        // Items
                        ...order.items.map((i) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text('• ${i.book.title} (x${i.quantity}) - ${i.selectedFormat}',
                                        style: const TextStyle(fontSize: 12)),
                                  ),
                                  Text('Ksh ${i.totalPrice.toInt()}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ],
                              ),
                            )),
                        const Divider(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Payment: ${order.paymentMethod} (${order.paymentStatus})',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                            Text('Total: Ksh ${order.totalAmount.toInt()}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryGreen)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Admin Action Buttons: Advance Status
                        Row(
                          children: [
                            const Text('Update Status: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<OrderStatus>(
                                initialValue: order.status,
                                isDense: true,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                items: const [
                                  DropdownMenuItem(value: OrderStatus.confirmed, child: Text('Order Confirmed', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: OrderStatus.processing, child: Text('Packing & Prep', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: OrderStatus.dispatched, child: Text('Dispatched from Depot', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: OrderStatus.inTransit, child: Text('Out for Delivery', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: OrderStatus.delivered, child: Text('Delivered', style: TextStyle(fontSize: 12))),
                                  DropdownMenuItem(value: OrderStatus.cancelled, child: Text('Cancelled', style: TextStyle(fontSize: 12))),
                                ],
                                onChanged: (newVal) {
                                  if (newVal != null && newVal != order.status) {
                                    _updateOrderStatus(doc.id, newVal);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  },
);
}

  // ==========================================
  // TAB 2: 📚 HARDCOPY BOOK CATALOG & STOCK
  // ==========================================
  Widget _buildBooksTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('ADD HARDCOPY BOOK', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookEditorScreen()));
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookstore_items').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          final docs = snapshot.hasData ? snapshot.data!.docs : [];
          final books = docs.map((d) => PhysicalBook.fromJson(d.data() as Map<String, dynamic>, d.id)).toList();

          if (books.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.menu_book, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('Catalog is Empty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    const Text('Click "Add Hardcopy Book" below or go to System tab to seed official SDA publications.',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white),
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Book'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBookEditorScreen()));
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final book = books[index];
              final isLowStock = book.stockCount <= 10;
              final isOutOfStock = book.stockCount <= 0;

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 55,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: book.coverImageUrl.isNotEmpty
                                  ? Image.network(book.coverImageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.book))
                                  : const Icon(Icons.menu_book, color: AppTheme.primaryBlue),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'By ${book.author} • ${book.category}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text('Ksh ${book.price.toInt()}',
                                        style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isOutOfStock
                                            ? Colors.red.shade100
                                            : (isLowStock ? Colors.orange.shade100 : Colors.green.shade100),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isOutOfStock ? 'OUT OF STOCK' : '${book.stockCount} in stock',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isOutOfStock
                                              ? Colors.red.shade800
                                              : (isLowStock ? Colors.orange.shade900 : Colors.green.shade900),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (book.distributionHub != null)
                                  Text(
                                    'Hub: ${book.distributionHub}',
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      // Quick Stock Adjustment & Edit Row (FittedBox prevents any pixel overflow)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            const Text('Stock: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            IconButton(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              tooltip: 'Decrease 1',
                              icon: const Icon(Icons.remove_circle_outline, size: 18, color: Colors.redAccent),
                              onPressed: () => _adjustStock(book.id, -1),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Text('${book.stockCount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            IconButton(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              tooltip: 'Add 5 Copies',
                              icon: const Icon(Icons.add_circle_outline, size: 18, color: AppTheme.primaryGreen),
                              onPressed: () => _adjustStock(book.id, 5),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              tooltip: 'Edit Book',
                              icon: const Icon(Icons.edit, color: AppTheme.primaryBlue, size: 18),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => AdminBookEditorScreen(bookToEdit: book)));
                              },
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              tooltip: 'Delete Book',
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                              onPressed: () => _deleteBook(book.id, book.title),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ==========================================
  // TAB 3: 🔴 LIVE WORSHIP BROADCASTS CONTROL
  // ==========================================
  Widget _buildLiveStreamsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('live_announcements').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
        }

        final docs = snapshot.hasData ? snapshot.data!.docs : [];

        if (docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.tv_off, size: 54, color: Colors.grey),
                  SizedBox(height: 14),
                  Text('No Active Live Broadcasts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 6),
                  Text('When any pastor or member starts a livestream, you can monitor, watch, or end it from here.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final isActive = data['isActive'] == true;
            final title = data['title'] as String? ?? 'SDA Live Worship';
            final speaker = data['speaker'] as String? ?? 'Pastor';
            final ministry = data['ministryName'] as String? ?? 'Outpost';
            final platform = data['platform'] as String? ?? 'direct';
            final mediaUrl = data['mediaUrl'] as String? ?? '';

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isActive ? Colors.red : Colors.grey.shade300, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.red : Colors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isActive ? '🔴 BROADCASTING LIVE' : 'ENDED',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text('Platform: $platform', style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
                        ),
                        const Spacer(),
                        if (isActive)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            icon: const Icon(Icons.stop, size: 16),
                            label: const Text('End Stream'),
                            onPressed: () => _endLiveStream(docs[index].id, title),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Speaker: $speaker • $ministry', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Watch Live'),
                          onPressed: () {
                            final s = Sermon(
                              id: docs[index].id,
                              title: title,
                              speaker: speaker,
                              description: 'Moderated Live Broadcast',
                              mediaUrl: mediaUrl,
                              type: SermonMediaType.video,
                              datePreached: DateTime.now(),
                              duration: Duration.zero,
                              isLiveStream: true,
                              videoSourceType: platform,
                            );
                            Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(sermon: s)));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 4: 👥 SELLER APPROVALS QUEUE
  // ==========================================
  Widget _buildSellerApprovalsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('book_seller_requests').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.how_to_reg_outlined, size: 54, color: AppTheme.primaryGreen),
                SizedBox(height: 12),
                Text('No Pending Colporteur Applications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Seller requests from literature evangelists will appear here.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          );
        }

        final requests = snapshot.data!.docs;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doc = requests[index];
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'pending';

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                title: Text(data['bookTitle'] ?? 'Book Request', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Seller: ${data['sellerName'] ?? "Colporteur"} • 📞 ${data['sellerPhone'] ?? ""}'),
                trailing: Text(status.toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 5: ☀️ DEVOTIONALS & QUOTES
  // ==========================================
  Widget _buildQuotesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Publish Daily Ellen G. White Quote', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue)),
                const SizedBox(height: 8),
                const Text('Broadcast spiritual inspiration to the top banner of all believer home screens.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 14),
                TextField(
                  controller: _quoteTextController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Quote Text *', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quoteRefController,
                  decoration: const InputDecoration(labelText: 'Reference (e.g. Desire of Ages, p. 83)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white),
                    icon: const Icon(Icons.send),
                    label: const Text('PUBLISH QUOTE TO HOME SCREEN', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _publishQuote,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 6: ⚙️ SYSTEM & DATABASE SANITIZER
  // ==========================================
  Widget _buildSystemSanitizerTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Server & Firebase Status Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.cloud_done, color: AppTheme.primaryGreen),
                    SizedBox(width: 8),
                    Text('Cloud Infrastructure Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Divider(height: 20),
                _buildStatusRow('Vercel API Server:', 'https://harvion.delstarfordworks.co.ke', true),
                _buildStatusRow('Firebase Project ID:', 'vine-3e4ab', true),
                _buildStatusRow('Cloud Firestore:', 'Active & Online (US Central)', true),
                _buildStatusRow('Storage Bucket:', 'vine-3e4ab.firebasestorage.app', true),
                _buildStatusRow('KJV Bible Engine:', 'All 66 Books Loaded Offline', true),
                _buildStatusRow('Spirit of Prophecy:', 'All 50 Books Loaded Offline', true),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Database Sanitization Actions Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.cleaning_services, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Database Maintenance & Sanitization', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage mock data, clear temporary records, and ensure your production database only serves real literature orders.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Purge Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('PURGE ALL MOCK & TEST RECORDS', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: _isActionProcessing ? null : _purgeMockData,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, bool isOk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(isOk ? Icons.check_circle : Icons.error, color: isOk ? Colors.green : Colors.red, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(value, style: TextStyle(fontSize: 12, color: Colors.grey.shade700), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed:
        return AppTheme.primaryBlue;
      case OrderStatus.processing:
        return Colors.orange.shade800;
      case OrderStatus.dispatched:
        return Colors.purple;
      case OrderStatus.inTransit:
        return Colors.blue.shade800;
      case OrderStatus.delivered:
        return AppTheme.primaryGreen;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  Future<void> _deleteBook(String bookId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Remove "$title" from the Literature Evangelism catalog?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('bookstore_items').doc(bookId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed "$title"'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ==========================================
  // 🎶 TAB 4: MUSIC & AUDIO MANAGEMENT
  // ==========================================
  Widget _buildMusicAndAudioTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sermons')
          .orderBy('publishedDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final totalTracks = docs.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.library_music, color: AppTheme.sacredGold, size: 28),
                            SizedBox(width: 10),
                            Text(
                              'Music & Audio Hub',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.sacredGold,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$totalTracks Tracks',
                            style: const TextStyle(
                              color: AppTheme.primaryBlue,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Admin control over choir pieces, sermons, and sacred audio tracks. Believers can listen and learn hymns directly inside the app.',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.sacredGold,
                              foregroundColor: AppTheme.primaryBlue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.add_circle, size: 18),
                            label: const Text(
                              'Post New Audio',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: _showAdminAddAudioDialog,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: const Text(
                              'Seed SDA Audio',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: _seedAdminSampleAudio,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Track List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Published Audio Library',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                  ),
                  Text(
                    '$totalTracks items',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (docs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.queue_music, size: 56, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      const Text(
                        'No audio published yet',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap "Post New Audio" or "Seed SDA Audio" to populate tracks for users.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final song = Song.fromJson(data, doc.id);
                    final category = data['category'] as String? ?? 'Sacred Audio';

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.music_note, color: AppTheme.primaryBlue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.primaryBlue,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${song.artist} • $category',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                if (song.isPremium)
                                  Text(
                                    'Ksh ${song.price.toInt()} (Premium)',
                                    style: const TextStyle(
                                      color: AppTheme.sacredGold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  )
                                else
                                  const Text(
                                    'Free Access',
                                    style: TextStyle(
                                      color: AppTheme.primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Preview Audio',
                            icon: const Icon(Icons.play_circle_fill, color: AppTheme.primaryGreen, size: 28),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => MusicPlayerScreen(song: song)),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Delete Track',
                            icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 22),
                            onPressed: () => _deleteAdminAudioTrack(doc.id, song.title),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // 🗑️ DELETE AUDIO TRACK (ADMIN)
  // ==========================================
  Future<void> _deleteAdminAudioTrack(String docId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Audio Track?'),
        content: Text('Are you sure you want to permanently delete "$title"? Believers will no longer be able to listen to it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('sermons').doc(docId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted "$title" from audio library.'), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete track: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // ==========================================
  // ➕ POST AUDIO TRACK (ADMIN)
  // ==========================================
  void _showAdminAddAudioDialog() {
    final titleCtrl = TextEditingController();
    final artistCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '0');
    String selectedCategory = 'Sacred Choir';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.library_music, color: AppTheme.primaryBlue),
                        SizedBox(width: 8),
                        Text(
                          'Upload Audio / Sermon',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: 'Audio Title *',
                    hintText: 'e.g. Great Is Thy Faithfulness',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: artistCtrl,
                  decoration: InputDecoration(
                    labelText: 'Artist / Choir / Speaker *',
                    hintText: 'e.g. HARVION Sacred Choir',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: InputDecoration(
                    labelText: 'Audio MP3 URL *',
                    hintText: 'https://... direct audio link',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Sacred Choir', child: Text('Sacred Choir')),
                          DropdownMenuItem(value: 'Sermon', child: Text('Sermon')),
                          DropdownMenuItem(value: 'SDA Hymn', child: Text('SDA Hymn')),
                          DropdownMenuItem(value: 'Devotional', child: Text('Devotional')),
                          DropdownMenuItem(value: 'Health Lecture', child: Text('Health Lecture')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedCategory = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Price (Ksh)',
                          hintText: '0 = Free',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(
                    isSubmitting ? 'Publishing...' : 'Publish to Library',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final title = titleCtrl.text.trim();
                          final artist = artistCtrl.text.trim();
                          final url = urlCtrl.text.trim();
                          final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;

                          if (title.isEmpty || artist.isEmpty || url.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please complete all required fields.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setModalState(() => isSubmitting = true);

                          try {
                            await FirebaseFirestore.instance.collection('sermons').add({
                              'title': title,
                              'speaker': artist,
                              'audioUrl': url,
                              'category': selectedCategory,
                              'price': price,
                              'publishedDate': FieldValue.serverTimestamp(),
                            });

                            if (mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Published "$title" to audio library!'),
                                  backgroundColor: AppTheme.primaryGreen,
                                ),
                              );
                            }
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to publish audio: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 🌱 SEED ADMIN SAMPLE AUDIO
  // ==========================================
  Future<void> _seedAdminSampleAudio() async {
    final tracks = [
      {
        'title': 'Praise to the Lord, the Almighty',
        'speaker': 'HARVION Adventist Symphony Choir',
        'audioUrl': 'https://archive.org/download/sda-hymnal-instrumental/001_Praise_to_the_Lord.mp3',
        'category': 'SDA Hymn',
        'price': 0.0,
      },
      {
        'title': 'Great Is Thy Faithfulness',
        'speaker': 'HARVION Sacred Choir',
        'audioUrl': 'https://archive.org/download/sda-hymnal-instrumental/100_Great_Is_Thy_Faithfulness.mp3',
        'category': 'Sacred Choir',
        'price': 0.0,
      },
      {
        'title': 'We Have This Hope (Advent Hymn)',
        'speaker': 'SDA General Conference Choir',
        'audioUrl': 'https://archive.org/download/sda-hymnal-instrumental/214_We_Have_This_Hope.mp3',
        'category': 'SDA Hymn',
        'price': 0.0,
      },
      {
        'title': 'Holy Sabbath, Day of Rest',
        'speaker': 'East Africa Heritage Chorale',
        'audioUrl': 'https://archive.org/download/sda-hymnal-instrumental/381_Holy_Sabbath_Day_of_Rest.mp3',
        'category': 'Sacred Choir',
        'price': 0.0,
      },
      {
        'title': 'The Three Angels\' Messages Proclaimed',
        'speaker': 'Pastor H.M.S. Richards',
        'audioUrl': 'https://archive.org/download/sda-hymnal-instrumental/108_Amazing_Grace.mp3',
        'category': 'Sermon',
        'price': 0.0,
      },
    ];

    try {
      final batch = FirebaseFirestore.instance.batch();
      final coll = FirebaseFirestore.instance.collection('sermons');
      for (final t in tracks) {
        final doc = coll.doc();
        batch.set(doc, {
          ...t,
          'publishedDate': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seeded 5 official SDA audio tracks into the library!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to seed audio: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
