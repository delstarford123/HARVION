import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../bookstore/models/physical_book_model.dart';
import '../bookstore/models/order_model.dart';
import '../sermons/sermon_model.dart';
import '../sermons/video_player_screen.dart';
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
    _tabController = TabController(length: 6, vsync: this);
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
            Text('HARVION Executive Control Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
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
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
          if (hub.contains('Maxwell')) region = 'Maxwell Adventist Centre';
          else if (hub.contains('Kisumu')) region = 'Kisumu Central';
          else if (hub.contains('Mombasa')) region = 'Mombasa Central';
          else if (hub.contains('Nakuru')) region = 'Nakuru Station';
          else if (hub.contains('Rider') || hub.contains('Doorstep')) region = 'Direct Doorstep Rider';
          else region = 'SDA Church Depot';

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

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Revenue Metric Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Gross Revenue (KES)',
                    value: 'Ksh ${totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.payments,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Total Orders',
                    value: '${docs.length}',
                    icon: Icons.receipt_long,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    title: 'Pending Dispatch',
                    value: '$pendingOrdersCount',
                    icon: Icons.pending_actions,
                    color: Colors.orange.shade800,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    title: 'Safely Delivered',
                    value: '$deliveredCount',
                    icon: Icons.check_circle_outline,
                    color: Colors.teal,
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

            // Real-time Orders Feed Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Customer Book Orders',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                ),
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
                            Text('Order #${order.orderId}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue)),
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
                                Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Text('By ${book.author} • ${book.category}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('Ksh ${book.price.toInt()}',
                                        style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(width: 8),
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
                                  Text('Hub: ${book.distributionHub}', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),

                      // Quick Stock Adjustment & Edit Row
                      Row(
                        children: [
                          const Text('Adjust Stock: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          IconButton(
                            tooltip: 'Decrease 1',
                            icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.redAccent),
                            onPressed: () => _adjustStock(book.id, -1),
                          ),
                          Text('${book.stockCount}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          IconButton(
                            tooltip: 'Add 5 Copies',
                            icon: const Icon(Icons.add_circle_outline, size: 20, color: AppTheme.primaryGreen),
                            onPressed: () => _adjustStock(book.id, 5),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.edit, color: AppTheme.primaryBlue, size: 20),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => AdminBookEditorScreen(bookToEdit: book)));
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () => _deleteBook(book.id, book.title),
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
                        Text('Platform: $platform', style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.w600)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
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
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Row(
            children: [
              Icon(isOk ? Icons.check_circle : Icons.error, color: isOk ? Colors.green : Colors.red, size: 14),
              const SizedBox(width: 4),
              Text(value, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            ],
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
}
