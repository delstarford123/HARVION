import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'theme.dart';
import '../shared/widgets/offline_banner.dart';
import '../shared/widgets/live_broadcast_banner.dart';

// Screens
import '../features/home/home_screen.dart';
import '../features/bookstore/bookstore_screen.dart';
import '../features/bookstore/cart_screen.dart';
import '../features/bookstore/services/cart_service.dart';
import '../features/health/health_screen.dart';
import '../features/family/family_screen.dart';
import '../features/home/more_screen.dart';
import '../features/devotional/devotional_screen.dart';
import '../features/sabbath_school/sabbath_school_screen.dart';
import '../features/prayer_wall/prayer_wall_screen.dart';
import '../features/tracts/digital_tracts_screen.dart';
import '../features/church_directory/church_directory_screen.dart';
import '../features/sabbath_tracker/sabbath_tracker_screen.dart';
import '../features/colporteur/colporteur_portal_screen.dart';
import '../features/recipes/recipes_screen.dart';
import '../features/library/library_screen.dart';
import '../features/music/music_screen.dart';
import '../features/sermons/sermons_screen.dart';
import '../features/farming/farming_screen.dart';
import '../features/education/education_screen.dart';
import '../features/fitness/fitness_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/order_history_screen.dart';
import '../features/colporteur/camp_meeting_locations_screen.dart';
import '../features/colporteur/request_sell_book_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/testimonies/testimonies_screen.dart';
import '../features/library/kjv_bible_reader_screen.dart';
import '../features/sermons/create_livestream_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final cartService = CartService();

  final List<Widget> _screens = [
    const HomeScreen(),
    const BookstoreScreen(),
    const HealthScreen(),
    const FamilyLifeScreen(),
    const MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initNetworkListener();
  }

  void _initNetworkListener() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final isDisconnected = results.contains(ConnectivityResult.none);
      setState(() {
        _isOffline = isDisconnected;
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HARVION',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          // Live Cart Badge Icon
          AnimatedBuilder(
            animation: cartService,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    tooltip: 'Bookstore Cart',
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
                    },
                  ),
                  if (cartService.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.sacredGold,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cartService.itemCount}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // Profile Button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              tooltip: 'Profile & Ministry',
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.sacredGold, width: 2),
                ),
                child: const CircleAvatar(
                  backgroundColor: AppTheme.primaryBlue,
                  radius: 14,
                  child: Icon(
                    Icons.person,
                    color: AppTheme.sacredGold,
                    size: 18,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
          ),
        ],
      ),

      // Professional Drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppTheme.primaryBlue,
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, Color(0xFF0D2544)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.sacredGold, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.sacredGold.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/harvion_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.church, color: AppTheme.sacredGold, size: 36),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'HARVION',
                          style: TextStyle(
                            color: AppTheme.sacredGold,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Text(
                          'SDA Ministry & Outpost',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Literature Evangelism • Health • Truth',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home Dashboard', 0),
            _buildDrawerItem(Icons.menu_book, 'Bookstore & Delivery', 1),
            _buildDrawerItem(Icons.volunteer_activism, 'Colporteur / LE Portal', -1,
                destination: const ColporteurPortalScreen()),
            _buildDrawerItem(Icons.campaign, 'Camp Meeting Book Stands', -1,
                destination: const CampMeetingLocationsScreen()),
            _buildDrawerItem(Icons.add_shopping_cart, 'Request to Sell Books', -1,
                destination: const RequestSellBookScreen()),
            _buildDrawerItem(Icons.local_shipping_outlined, 'Track Book Orders', -1,
                destination: const OrderHistoryScreen()),

            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('SPIRITUAL LIFE & MINISTRY',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            _buildDrawerItem(Icons.wb_sunny_outlined, 'Daily Devotional (Morning Watch)', -1,
                destination: const DevotionalScreen()),
            _buildDrawerItem(Icons.book, 'Sabbath School Quarterlies', -1,
                destination: const SabbathSchoolScreen()),
            _buildDrawerItem(Icons.handshake, 'Community Prayer Wall', -1,
                destination: const PrayerWallScreen()),
            _buildDrawerItem(Icons.share, 'Digital Tracts & Sharing Hub', -1,
                destination: const DigitalTractsScreen()),
            _buildDrawerItem(Icons.auto_stories, 'Holy Bible (KJV Reader)', -1,
                destination: const KjvBibleReaderScreen()),
            _buildDrawerItem(Icons.auto_awesome, 'Faith Testimonies & Miracles', -1,
                destination: const TestimoniesScreen()),
            _buildDrawerItem(Icons.podcasts, 'Sermons & Audio Media', -1,
                destination: const SermonsScreen()),
            _buildDrawerItem(Icons.live_tv, '🔴 Start Live Stream / Broadcast', -1,
                destination: const CreateLiveStreamScreen()),
            _buildDrawerItem(Icons.library_books, 'Free SOP Library (PDFs)', -1,
                destination: const LibraryScreen()),

            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('HEALTH & EDENIC LIVING',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            _buildDrawerItem(Icons.favorite, 'Health & Wellness (NEWSTART)', 2),
            _buildDrawerItem(Icons.soup_kitchen, 'Plant-Based Recipes & Planner', -1,
                destination: const RecipesScreen()),
            _buildDrawerItem(Icons.family_restroom, 'Family Life', 3),
            _buildDrawerItem(Icons.agriculture, 'Organic Farming', -1,
                destination: const FarmingScreen()),
            _buildDrawerItem(Icons.fitness_center, 'Physical Fitness', -1,
                destination: const FitnessScreen()),

            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('COMMUNITY & CHURCH',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            _buildDrawerItem(Icons.church, 'Church & Event Directory', -1,
                destination: const ChurchDirectoryScreen()),
            _buildDrawerItem(Icons.wb_twilight, 'Sabbath Sunset Tracker', -1,
                destination: const SabbathTrackerScreen()),
            _buildDrawerItem(Icons.school, 'Christian Education', -1,
                destination: const EducationScreen()),
            _buildDrawerItem(Icons.music_note, 'SDA Music & Hymns', -1,
                destination: const MusicScreen()),
            _buildDrawerItem(Icons.person, 'My Profile & Contacts', -1,
                destination: const ProfileScreen()),

            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text('ADMINISTRATION & MINISTRY OVERSIGHT',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            _buildDrawerItem(Icons.admin_panel_settings, 'Admin Control Center', -1,
                destination: const AdminDashboardScreen()),
            const SizedBox(height: 20),
          ],
        ),
      ),

      body: Column(
        children: [
          OfflineBanner(isVisible: _isOffline),
          const LiveBroadcastBanner(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _screens[_currentIndex],
            ),
          ),
        ],
      ),

      // Material 3 Navigation Bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Bookstore',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Health',
          ),
          NavigationDestination(
            icon: Icon(Icons.family_restroom_outlined),
            selectedIcon: Icon(Icons.family_restroom),
            label: 'Family',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_customize_outlined),
            selectedIcon: Icon(Icons.dashboard_customize),
            label: 'More',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index, {Widget? destination}) {
    final isSelected = _currentIndex == index && index != -1;

    return ListTile(
      leading: Icon(icon, color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade700, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
          fontSize: 13,
        ),
      ),
      selected: isSelected,
      dense: true,
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (index != -1) {
          setState(() {
            _currentIndex = index;
          });
        } else if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        }
      },
    );
  }
}
