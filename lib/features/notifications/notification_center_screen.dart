import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../sermons/sermon_model.dart';
import '../sermons/video_player_screen.dart';
import '../bookstore/order_tracking_screen.dart';
import '../bookstore/models/order_model.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Notifications & Live Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.sacredGold,
          indicatorWeight: 3,
          labelColor: AppTheme.sacredGold,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.stream), text: 'Live Worship'),
            Tab(icon: Icon(Icons.local_shipping_outlined), text: 'Book Orders'),
            Tab(icon: Icon(Icons.campaign_outlined), text: 'Announcements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveStreamsTab(),
          _buildOrdersTab(),
          _buildAnnouncementsTab(),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: 🔴 LIVE WORSHIP BROADCASTS
  // ==========================================
  Widget _buildLiveStreamsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('live_announcements')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.live_tv, size: 36, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Active Live Streams Right Now',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When a brother, sister, or pastor starts a live worship sermon, an instant notification will appear here so you can join in prayer.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        final liveDocs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: liveDocs.length,
          itemBuilder: (context, index) {
            final data = liveDocs[index].data() as Map<String, dynamic>;
            final title = data['title'] as String? ?? 'SDA Live Worship & Ministry';
            final speaker = data['speaker'] as String? ?? 'Adventist Pastor / Speaker';
            final ministry = data['ministryName'] as String? ?? 'Harvion Mission Outpost';
            final mediaUrl = data['mediaUrl'] as String? ?? '';
            final platform = data['platform'] as String? ?? 'direct';
            final language = data['language'] as String? ?? 'English';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.red.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Pulsing Live Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.circle, color: Colors.white, size: 8),
                              SizedBox(width: 6),
                              Text(
                                'LIVE NOW',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            language.toUpperCase(),
                            style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.people_alt, size: 16, color: Colors.red),
                        const SizedBox(width: 4),
                        const Text('Active Worship', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Speaker: $speaker • $ministry',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                    const SizedBox(height: 14),

                    // JOIN LIVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.play_circle_fill, size: 22),
                        label: const Text(
                          'JOIN LIVE WORSHIP NOW',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                        ),
                        onPressed: () {
                          final sermon = Sermon(
                            id: liveDocs[index].id,
                            title: title,
                            speaker: speaker,
                            description: 'Live broadcast on $platform.',
                            mediaUrl: mediaUrl,
                            type: SermonMediaType.video,
                            datePreached: DateTime.now(),
                            duration: Duration.zero,
                            isLiveStream: true,
                            liveViewerCount: 15,
                            videoSourceType: platform,
                            language: language,
                            ministryName: ministry,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => VideoPlayerScreen(sermon: sermon)),
                          );
                        },
                      ),
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
  // TAB 2: 📦 BOOKSTORE ORDERS & DISPATCHES
  // ==========================================
  Widget _buildOrdersTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .limit(15)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No Order Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When you purchase literature evangelism hardcopies, order tracking updates and courier alerts appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final orderId = data['orderId'] as String? ?? docs[index].id;
            final status = data['status'] as String? ?? 'Confirmed';
            final customerName = data['customerName'] as String? ?? 'Believer';
            final delivery = data['deliveryAddress'] as String? ?? 'Depot Pickup';
            final total = (data['totalAmount'] as num? ?? 0).toInt();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.15),
                  child: const Icon(Icons.local_shipping, color: AppTheme.primaryGreen),
                ),
                title: Text('Order #$orderId - $status', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('Recipient: $customerName • $delivery\nTotal: Ksh $total', style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                onTap: () {
                  final order = BookstoreOrder.fromJson(data, docs[index].id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 3: ⛪ CHURCH ANNOUNCEMENTS & DEVOTIONALS
  // ==========================================
  Widget _buildAnnouncementsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('admin_notifications')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAnnouncementCard(
                title: 'Welcome to HARVION Ministry Ecosystem',
                body: 'Sola Scriptura! All 66 Books of the KJV Bible and 50 Spirit of Prophecy books are fully loaded and accessible completely offline.',
                date: 'System Announcement',
                icon: Icons.church,
                color: AppTheme.primaryBlue,
              ),
              _buildAnnouncementCard(
                title: 'Literature Evangelism Hardcopies Available',
                body: 'Place orders for physical copies of The Great Controversy, Desire of Ages, and Steps to Christ with delivery to major SDA Book Centers in Kenya.',
                date: 'Bookstore Notice',
                icon: Icons.menu_book,
                color: AppTheme.primaryGreen,
              ),
              _buildAnnouncementCard(
                title: 'Prepare for the Holy Sabbath Day',
                body: 'Remember the Sabbath day, to keep it holy. Six days shalt thou labour, and do all thy work: But the seventh day is the sabbath of the LORD thy God.',
                date: 'Fourth Commandment',
                icon: Icons.wb_sunny,
                color: AppTheme.sacredGold,
              ),
            ],
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final title = data['title'] as String? ?? 'Ministry Notice';
            final message = data['message'] as String? ?? '';
            final type = data['type'] as String? ?? 'info';

            return _buildAnnouncementCard(
              title: title,
              body: message,
              date: 'Harvion Ministry',
              icon: type == 'new_order' ? Icons.shopping_bag : Icons.notifications_active,
              color: type == 'new_order' ? AppTheme.primaryGreen : AppTheme.primaryBlue,
            );
          },
        );
      },
    );
  }

  Widget _buildAnnouncementCard({
    required String title,
    required String body,
    required String date,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(body, style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4)),
                  const SizedBox(height: 6),
                  Text(date, style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

