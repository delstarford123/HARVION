import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../bookstore/bookstore_screen.dart';
import '../bookstore/cart_screen.dart';
import '../colporteur/colporteur_portal_screen.dart';
import '../profile/order_history_screen.dart';
import '../profile/wishlist_screen.dart';
import '../profile/reading_goals_screen.dart';
import '../devotional/devotional_screen.dart';
import '../sabbath_school/sabbath_school_screen.dart';
import '../media/media_library_screen.dart';
import '../tracts/digital_tracts_screen.dart';
import '../prayer_wall/prayer_wall_screen.dart';
import '../health/health_principles_screen.dart';
import '../recipes/recipes_screen.dart';
import '../church_directory/church_directory_screen.dart';
import '../sabbath_tracker/sabbath_tracker_screen.dart';
import '../fitness/fitness_screen.dart';
import '../farming/farming_screen.dart';
import '../education/education_screen.dart';
import '../profile/profile_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                'Ministry & Resources Hub',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION 1: Literature Evangelism & Bookstore
                  _buildSectionTitle('1. Literature Evangelism & Bookstore'),
                  const SizedBox(height: 10),
                  _buildGrid(context, [
                    _ItemData('Bookstore Catalog', 'Physical book sales & delivery', Icons.menu_book, AppTheme.primaryBlue, const BookstoreScreen()),
                    _ItemData('Colporteur Portal', 'LE commissions & referrals', Icons.volunteer_activism, AppTheme.sacredGold, const ColporteurPortalScreen()),
                    _ItemData('Track Orders', 'Real-time dispatch timeline', Icons.local_shipping, AppTheme.primaryGreen, const OrderHistoryScreen()),
                    _ItemData('Saved Wishlist', 'Favorite books & guides', Icons.favorite, Colors.redAccent, const WishlistScreen()),
                  ]),
                  const SizedBox(height: 24),

                  // SECTION 2: Ministry & Spiritual Content
                  _buildSectionTitle('2. Ministry & Spiritual Content'),
                  const SizedBox(height: 10),
                  _buildGrid(context, [
                    _ItemData('Daily Devotional', 'Morning Watch & EGW reflections', Icons.wb_sunny_outlined, Colors.amber.shade800, const DevotionalScreen()),
                    _ItemData('Sabbath School', 'Current quarter Bible guides', Icons.book_outlined, Colors.deepPurple, const SabbathSchoolScreen()),
                    _ItemData('Media & Sermons', 'Sermons, hymns & video seminars', Icons.podcasts, Colors.indigo, const MediaLibraryScreen()),
                    _ItemData('Digital Tracts', 'Free pamphlets & WhatsApp share', Icons.share, Colors.teal, const DigitalTractsScreen()),
                    _ItemData('Prayer Wall', 'Community intercession & praises', Icons.handshake, AppTheme.primaryGreen, const PrayerWallScreen()),
                    _ItemData('Reading Goals', 'Track Spirit of Prophecy progress', Icons.auto_stories, Colors.blueGrey, const ReadingGoalsScreen()),
                  ]),
                  const SizedBox(height: 24),

                  // SECTION 3: Health & Wellness
                  _buildSectionTitle('3. Health & Edenic Living'),
                  const SizedBox(height: 10),
                  _buildGrid(context, [
                    _ItemData('8 Laws of Health', 'NEWSTART guide & habits', Icons.spa, AppTheme.primaryGreen, const HealthPrinciplesScreen()),
                    _ItemData('Plant-Based Recipes', 'Cookbook & meal planner', Icons.soup_kitchen, Colors.orange, const RecipesScreen()),
                    _ItemData('Physical Fitness', 'Invigorating physical health', Icons.fitness_center, Colors.deepOrange, const FitnessScreen()),
                    _ItemData('Organic Farming', 'Restoring soil & country outposts', Icons.agriculture, Colors.green.shade800, const FarmingScreen()),
                  ]),
                  const SizedBox(height: 24),

                  // SECTION 4: Community & Church Engagement
                  _buildSectionTitle('4. Community & Church Engagement'),
                  const SizedBox(height: 10),
                  _buildGrid(context, [
                    _ItemData('Church Directory', 'Local SDA churches & events', Icons.church, AppTheme.primaryBlue, const ChurchDirectoryScreen()),
                    _ItemData('Sabbath Tracker', 'Sunset countdown & gentle alerts', Icons.wb_twilight, Colors.amber.shade900, const SabbathTrackerScreen()),
                    _ItemData('Christian Education', 'Higher education & school guides', Icons.school, Colors.indigo, const EducationScreen()),
                    _ItemData('My Profile', 'Account, fellowship & contacts', Icons.person, Colors.brown, const ProfileScreen()),
                  ]),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
    );
  }

  Widget _buildGrid(BuildContext context, List<_ItemData> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => item.destination));
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: item.color.withOpacity(0.12),
                    child: Icon(item.icon, color: item.color, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ItemData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget destination;

  _ItemData(this.title, this.subtitle, this.icon, this.color, this.destination);
}
