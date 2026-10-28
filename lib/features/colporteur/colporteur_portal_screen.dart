import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme.dart';
import 'services/colporteur_service.dart';
import 'request_sell_book_screen.dart';
import 'camp_meeting_locations_screen.dart';

class ColporteurPortalScreen extends StatefulWidget {
  const ColporteurPortalScreen({super.key});

  @override
  State<ColporteurPortalScreen> createState() => _ColporteurPortalScreenState();
}

class _ColporteurPortalScreenState extends State<ColporteurPortalScreen> {
  final colporteurService = ColporteurService();

  void _showAddLeadDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final locationController = TextEditingController();
    final bookController = TextEditingController(text: 'The Great Controversy');
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_add, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text('New Customer Prospect', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Contact / Buyer Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number (e.g. 0712...)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location / Estate / Town'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bookController,
                decoration: const InputDecoration(labelText: 'Book of Spiritual Interest'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Missionary Notes / Follow-up Need'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (nameController.text.trim().isEmpty || phoneController.text.trim().isEmpty) return;
              colporteurService.addLead(
                name: nameController.text.trim(),
                phone: phoneController.text.trim(),
                location: locationController.text.trim(),
                interestBook: bookController.text.trim(),
                notes: notesController.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New prospect registered to your missionary pipeline!'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
            child: const Text('SAVE PROSPECT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _callCustomer(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not call $phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: colporteurService,
      builder: (context, _) {
        final profile = colporteurService.profile;
        final leads = colporteurService.leads;

        return Scaffold(
          backgroundColor: AppTheme.backgroundLight,
          appBar: AppBar(
            title: const Text('Colporteur & LE Portal', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: 'Camp Meeting Book Stands',
                icon: const Icon(Icons.campaign),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CampMeetingLocationsScreen()),
                  );
                },
              ),
              IconButton(
                tooltip: 'Add Prospect',
                icon: const Icon(Icons.person_add_alt_1),
                onPressed: _showAddLeadDialog,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LE ID Badge
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
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
                            child: const Text(
                              'CERTIFIED LITERATURE EVANGELIST',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                          Text(
                            profile.leId,
                            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.name,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.churchConference,
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // TWO QUICK ACTION CARDS: 1. Camp Meeting Broadcaster & 2. Request to Sell Books
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CampMeetingLocationsScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.sacredGold.withOpacity(0.5)),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on, color: Colors.amber, size: 28),
                              SizedBox(height: 8),
                              Text('Camp Meetings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue)),
                              Text('Broadcast booth & see live spots', style: TextStyle(fontSize: 10, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RequestSellBookScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.add_shopping_cart, color: AppTheme.primaryGreen, size: 28),
                              SizedBox(height: 8),
                              Text('Sell Your Books', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGreen)),
                              Text('Upload details & get approved', style: TextStyle(fontSize: 10, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Commission & Sales Metric Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Commissions',
                        value: 'Ksh ${profile.totalSalesCommission.toInt()}',
                        subtitle: 'Earned & Available',
                        icon: Icons.account_balance_wallet,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Books Delivered',
                        value: '${profile.booksDistributed}',
                        subtitle: 'Spiritual seed sown',
                        icon: Icons.menu_book,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Active Contacts',
                        value: '${profile.activeCustomers}',
                        subtitle: 'Prospects in care',
                        icon: Icons.groups,
                        color: AppTheme.sacredGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Custom Referral Code & Share Link Card
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.qr_code, color: AppTheme.primaryBlue),
                            SizedBox(width: 8),
                            Text(
                              'Your Literature Evangelism Referral Code',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'When buyers use your code, they receive 10% OFF, and your account is credited with ${(profile.commissionRate * 100).toInt()}% literature commission!',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                profile.referralCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  letterSpacing: 1.5,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20, color: AppTheme.primaryBlue),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: profile.referralCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Colporteur code copied to clipboard!')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.share),
                            label: const Text('SHARE CODE VIA WHATSAPP', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              Share.share(colporteurService.generateWhatsAppShareText());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Customer Leads Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Missionary Customer Register',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Prospect'),
                      onPressed: _showAddLeadDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Leads list
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final lead = leads[index];
                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  lead.customerName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(lead.status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    lead.status,
                                    style: TextStyle(
                                      color: _getStatusColor(lead.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '📍 ${lead.location} • 📖 ${lead.interestBook}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            ),
                            if (lead.notes.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                '"${lead.notes}"',
                                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black87),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    side: const BorderSide(color: AppTheme.primaryGreen),
                                  ),
                                  icon: const Icon(Icons.phone, size: 14, color: AppTheme.primaryGreen),
                                  label: const Text('Call', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
                                  onPressed: () => _callCustomer(lead.phone),
                                ),
                                const SizedBox(width: 8),
                                PopupMenuButton<String>(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('Update Status ▾', style: TextStyle(fontSize: 11)),
                                  ),
                                  onSelected: (newStatus) {
                                    colporteurService.updateLeadStatus(lead.id, newStatus);
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(value: 'New Lead', child: Text('New Lead')),
                                    const PopupMenuItem(value: 'Followed Up', child: Text('Followed Up')),
                                    const PopupMenuItem(value: 'Ordered', child: Text('Ordered Book')),
                                    const PopupMenuItem(
                                        value: 'Baptism Interest', child: Text('Baptism / Bible Study Interest')),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Inspiration from Colporteur Ministry
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.format_quote, color: AppTheme.sacredGold, size: 30),
                      SizedBox(height: 6),
                      Text(
                        '"The canvassing work should no longer be languishing. It is missionary work of the highest order. The truth must be carried to every nation, kindred, tongue, and people. Canvassers are to go into all parts of the world, carrying our publications."',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, height: 1.4),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '— Ellen G. White, Colporteur Ministry, p. 5',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppTheme.primaryBlue),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Ordered':
        return Colors.green;
      case 'Followed Up':
        return Colors.blue;
      case 'Baptism Interest':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          Text(subtitle, style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}
