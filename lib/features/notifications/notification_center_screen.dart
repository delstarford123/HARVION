import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../../core/services/notification_service.dart';
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
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _notificationService.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _markAllRead() {
    _notificationService.markAllAsRead([]);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Notifications?'),
        content: const Text('This will remove all current notifications from your notification center.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _notificationService.clearAllNotifications([]);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications cleared.')),
              );
            },
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _notificationService,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          appBar: AppBar(
            title: const Text('Notifications & Live Alerts', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.done_all),
                tooltip: 'Mark All Read',
                onPressed: _markAllRead,
              ),
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Clear All',
                onPressed: _confirmClearAll,
              ),
            ],
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
      },
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

        final liveDocs = (snapshot.data?.docs ?? [])
            .where((doc) => !_notificationService.isDeleted(doc.id))
            .toList();

        // Mark visible live announcements as read
        if (liveDocs.isNotEmpty) {
          _notificationService.markAllAsRead(liveDocs.map((d) => d.id));
        }

        if (liveDocs.isEmpty) {
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
                    'When an evangelist, pastor, or choir begins a live worship stream, it will be announced here instantly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: liveDocs.length,
          itemBuilder: (context, index) {
            final doc = liveDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'] as String? ?? 'SDA Live Worship & Ministry';
            final speaker = data['speaker'] as String? ?? 'Adventist Pastor / Speaker';
            final ministry = data['ministryName'] as String? ?? 'Harvion Mission Outpost';
            final mediaUrl = data['mediaUrl'] as String? ?? '';
            final platform = data['platform'] as String? ?? 'direct';
            final language = data['language'] as String? ?? 'English';

            return Dismissible(
              key: Key('live_${doc.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                _notificationService.deleteNotification(doc.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Live alert removed.'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () => _notificationService.undoDelete(doc.id),
                    ),
                  ),
                );
              },
              child: Card(
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
                          // 🗑️ Delete Notification Button
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                            tooltip: 'Delete Notification',
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              _notificationService.deleteNotification(doc.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Live notification deleted.'),
                                  action: SnackBarAction(
                                    label: 'UNDO',
                                    onPressed: () => _notificationService.undoDelete(doc.id),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                              id: doc.id,
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

        final orderDocs = (snapshot.data?.docs ?? [])
            .where((doc) => !_notificationService.isDeleted(doc.id))
            .toList();

        if (orderDocs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No Recent Orders',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your literature evangelism and personal book order tracking updates will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orderDocs.length,
          itemBuilder: (context, index) {
            final doc = orderDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status'] as String? ?? 'Pending';
            final total = data['totalAmount'] ?? 0;
            final customerName = data['customerName'] as String? ?? 'Gospel Patron';

            return Dismissible(
              key: Key('order_${doc.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                _notificationService.deleteNotification(doc.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Order alert dismissed.'),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () => _notificationService.undoDelete(doc.id),
                    ),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping, color: AppTheme.primaryGreen),
                  ),
                  title: Text(
                    'Order #${doc.id.substring(0, doc.id.length > 8 ? 8 : doc.id.length).toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Text('$customerName • KES $total • Status: $status'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                        tooltip: 'Delete Notification',
                        onPressed: () {
                          _notificationService.deleteNotification(doc.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Order alert deleted.'),
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () => _notificationService.undoDelete(doc.id),
                              ),
                            ),
                          );
                        },
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    final order = BookstoreOrder.fromJson(data, doc.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order)),
                    );
                  },
                ),
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
        final docs = (snapshot.data?.docs ?? [])
            .where((doc) => !_notificationService.isDeleted(doc.id))
            .toList();

        if (docs.isEmpty) {
          final defaultItems = [
            {
              'id': 'welcome_harvion',
              'title': 'Welcome to HARVION Ministry Ecosystem',
              'body': 'Sola Scriptura! All 66 Books of the KJV Bible and 50 Spirit of Prophecy books are fully loaded and accessible completely offline.',
              'date': 'System Announcement',
              'icon': Icons.church,
              'color': AppTheme.primaryBlue,
            },
            {
              'id': 'colporteur_notice',
              'title': 'Literature Evangelism Hardcopies Available',
              'body': 'Place orders for physical copies of The Great Controversy, Desire of Ages, and Steps to Christ with delivery to major SDA Book Centers in Kenya.',
              'date': 'Bookstore Notice',
              'icon': Icons.menu_book,
              'color': AppTheme.primaryGreen,
            },
            {
              'id': 'sabbath_reminder',
              'title': 'Prepare for the Holy Sabbath Day',
              'body': 'Remember the Sabbath day, to keep it holy. Six days shalt thou labour, and do all thy work: But the seventh day is the sabbath of the LORD thy God.',
              'date': 'Fourth Commandment',
              'icon': Icons.wb_sunny,
              'color': AppTheme.sacredGold,
            },
          ].where((item) => !_notificationService.isDeleted(item['id'] as String)).toList();

          if (defaultItems.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('No Announcements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('All announcements have been deleted or dismissed.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: defaultItems.map((item) {
              return _buildAnnouncementCard(
                id: item['id'] as String,
                title: item['title'] as String,
                body: item['body'] as String,
                date: item['date'] as String,
                icon: item['icon'] as IconData,
                color: item['color'] as Color,
              );
            }).toList(),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'] as String? ?? 'Ministry Notice';
            final message = data['message'] as String? ?? '';
            final type = data['type'] as String? ?? 'info';

            return _buildAnnouncementCard(
              id: doc.id,
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
    required String id,
    required String title,
    required String body,
    required String date,
    required IconData icon,
    required Color color,
  }) {
    return Dismissible(
      key: Key('announcement_$id'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        _notificationService.deleteNotification(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Announcement deleted.'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () => _notificationService.undoDelete(id),
            ),
          ),
        );
      },
      child: Card(
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                          tooltip: 'Delete Notification',
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _notificationService.deleteNotification(id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Announcement deleted.'),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () => _notificationService.undoDelete(id),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
      ),
    );
  }
}
