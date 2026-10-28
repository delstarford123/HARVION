import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../admin/admin_login_screen.dart';
import '../colporteur/colporteur_portal_screen.dart';
import 'order_history_screen.dart';
import 'wishlist_screen.dart';
import 'reading_goals_screen.dart';
import '../sabbath_tracker/sabbath_tracker_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (!await launchUrl(launchUri)) {
      debugPrint('Could not launch $launchUri');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Inquiry from Harvion App User',
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch $emailLaunchUri');
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'My Profile & Ministry Hub',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Heavenly Focus Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 36.0, top: 20.0),
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onLongPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.sacredGold,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.auto_awesome,
                          size: 46,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.displayName ?? AppConstants.developerName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Preparing a People for His Coming',
                    style: TextStyle(
                      color: AppTheme.sacredGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.email ?? user.phoneNumber ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ]
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // 🚀 LITERATURE EVANGELISM & USER ACTIONS
                  // ==========================================
                  const Text(
                    'Literature Evangelism & Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Colporteur Portal Tile (Gold & Blue)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.sacredGold, width: 1.5),
                    ),
                    color: const Color(0xFFFFFDF5),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.sacredGold.withOpacity(0.2),
                        child: const Icon(Icons.volunteer_activism, color: Colors.brown),
                      ),
                      title: const Text(
                        'Colporteur & LE Portal',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                      subtitle: const Text('Track commissions, share referral codes, and manage leads.'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryBlue),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ColporteurPortalScreen()));
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Order Tracking
                  _buildNavCard(
                    context,
                    title: 'My Book Orders & Dispatches',
                    subtitle: 'Real-time timeline tracking from warehouse to church depot or rider.',
                    icon: Icons.local_shipping_outlined,
                    color: AppTheme.primaryGreen,
                    destination: const OrderHistoryScreen(),
                  ),
                  const SizedBox(height: 10),

                  // Saved Books & Wishlist
                  _buildNavCard(
                    context,
                    title: 'My Saved Books & Wishlist',
                    subtitle: 'Quickly access and buy your favorited missionary books.',
                    icon: Icons.favorite_border,
                    color: Colors.redAccent,
                    destination: const WishlistScreen(),
                  ),
                  const SizedBox(height: 10),

                  // Reading Goals
                  _buildNavCard(
                    context,
                    title: 'Spiritual Reading Goals',
                    subtitle: 'Track your journey through Conflict of the Ages & Daily Devotionals.',
                    icon: Icons.auto_stories_outlined,
                    color: Colors.indigo,
                    destination: const ReadingGoalsScreen(),
                  ),
                  const SizedBox(height: 10),

                  // Sabbath Sunset & Reminders
                  _buildNavCard(
                    context,
                    title: 'Sabbath Sunset Tracker & Alerts',
                    subtitle: 'Countdown clock to Friday sunset & notification preferences.',
                    icon: Icons.wb_twilight,
                    color: Colors.amber.shade800,
                    destination: const SabbathTrackerScreen(),
                  ),
                  const SizedBox(height: 28),

                  // ==========================================
                  // 📖 MINISTRY VISION
                  // ==========================================
                  const Row(
                    children: [
                      Icon(Icons.menu_book, color: AppTheme.primaryGreen),
                      SizedBox(width: 8),
                      Text(
                        'Mission Statement',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(18.0),
                      child: Text(
                        "This platform is dedicated to the proclamation of the Everlasting Gospel in the context of the Three Angels' Messages. Through the study of God's Word, the Spirit of Prophecy, and the stewardship of the Earth through Organic Farming, we seek to restore the image of God in man.",
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ==========================================
                  // 🏛️ PILLARS OF FAITH
                  // ==========================================
                  const Text(
                    'Pillars of Faith & Service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildFaithTile(
                    icon: Icons.church,
                    title: 'Seventh-day Adventist Faith',
                    subtitle:
                        'Committed to the commandments of God and the faith of Jesus.',
                  ),
                  _buildFaithTile(
                    icon: Icons.nature_people,
                    title: 'Edenic Stewardship',
                    subtitle:
                        'Restoring the soil and body through organic, God-given methods.',
                  ),
                  _buildFaithTile(
                    icon: Icons.volunteer_activism,
                    title: 'Independent Literature Evangelism',
                    subtitle:
                        'Self-supporting publishing work for the advancement of the Present Truth.',
                  ),
                  const SizedBox(height: 28),

                  // ==========================================
                  // 👤 ABOUT ALFREDO ONUKO & CONTACT
                  // ==========================================
                  const Text(
                    'About Alfredo Onuko & Contact',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppConstants.developerBio,
                    style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),

                  _buildContactRow(
                    icon: Icons.phone,
                    text: '0745 090 990',
                    onTap: () => _makePhoneCall('0745090990'),
                  ),
                  _buildContactRow(
                    icon: Icons.email,
                    text: 'afredoonuko@gmail.com',
                    onTap: () => _sendEmail('afredoonuko@gmail.com'),
                  ),
                  const SizedBox(height: 24),

                  // Fellowship Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(AppConstants.fellowshipLink),
                      icon: const Icon(Icons.groups, color: Colors.white),
                      label: const Text(
                        'Join the Fellowship on WhatsApp',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Logout Button
                  if (user != null)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        onPressed: () => _handleLogout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text('LOG OUT', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  const SizedBox(height: 20),

                  const Center(
                    child: Text(
                      'Marana Tha - The Lord Cometh',
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget destination,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
        },
      ),
    );
  }

  Widget _buildFaithTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.sacredGold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.sacredGold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.primaryGreen),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
