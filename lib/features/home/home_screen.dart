import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import 'quote_model.dart';
import '../admin/admin_dashboard_screen.dart';
import '../bookstore/bookstore_screen.dart';
import '../bookstore/models/physical_book_model.dart';
import '../bookstore/book_detail_screen.dart';
import '../devotional/devotional_screen.dart';
import '../tracts/digital_tracts_screen.dart';
import '../sabbath_tracker/sabbath_tracker_screen.dart';
import '../colporteur/camp_meeting_locations_screen.dart';
import '../family/family_screen.dart';
import '../sermons/sermons_screen.dart';
import '../testimonies/testimonies_screen.dart';
import '../library/kjv_bible_reader_screen.dart';
import '../sabbath_school/sabbath_school_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildSabbathCountdownBanner(context),
                const SizedBox(height: 20),
                _buildVerseOfTheDay(),
                const SizedBox(height: 28),
                _buildSectionTitle('SDA Ministry & Mission'),
                const SizedBox(height: 14),
                _buildQuickActions(context),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: _buildSectionTitle('Literature Evangelism Books')),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const BookstoreScreen()));
                      },
                      child: const Text('View All Books →'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildRecommendedList(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    if (hour >= 12 && hour < 17) greeting = 'Good Afternoon';
    if (hour >= 17) greeting = 'Good Evening';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              const Text(
                'Blessed Day in Christ!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Admin & Notifications',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
            );
          },
          icon: CircleAvatar(
            backgroundColor: AppTheme.primaryBlue.withOpacity(0.12),
            child: const Icon(Icons.admin_panel_settings, color: AppTheme.primaryBlue, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSabbathCountdownBanner(BuildContext context) {
    final now = DateTime.now();
    bool isSabbath = (now.weekday == DateTime.friday && now.hour >= 18) ||
        (now.weekday == DateTime.saturday && now.hour < 18);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SabbathTrackerScreen()));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSabbath ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSabbath ? AppTheme.primaryGreen.withOpacity(0.4) : AppTheme.sacredGold.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSabbath ? Icons.spa : Icons.wb_twilight,
              color: isSabbath ? AppTheme.primaryGreen : Colors.amber.shade900,
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSabbath ? 'Holy Sabbath Rest is Here' : 'Sabbath Sunset Preparation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSabbath ? AppTheme.primaryGreen : Colors.brown.shade800,
                    ),
                  ),
                  Text(
                    isSabbath
                        ? 'Call the Sabbath a delight • Tap for Sabbath readings'
                        : 'Friday 6:30 PM • Tap for live countdown & reminders',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildVerseOfTheDay() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('daily_quotes')
          .orderBy('displayDate', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        DailyQuote currentQuote = DailyQuote(
          id: 'default_001',
          text: "Higher than the highest human thought can reach is God's ideal for His children. Godliness—godlikeness—is the goal to be reached.",
          reference: "Education, p. 18.4",
          displayDate: DateTime.now(),
        );

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final doc = snapshot.data!.docs.first;
          currentQuote = DailyQuote.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.format_quote, color: AppTheme.sacredGold, size: 36),
              const SizedBox(height: 12),
              Text(
                currentQuote.text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontStyle: FontStyle.italic, height: 1.4),
              ),
              const SizedBox(height: 12),
              Text(
                "- ${currentQuote.reference}",
                style: const TextStyle(color: AppTheme.sacredGold, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white70, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: '"${currentQuote.text}" - ${currentQuote.reference}'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Quote copied!'), behavior: SnackBarBehavior.floating),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white70, size: 18),
                    onPressed: () {
                      Share.share(currentQuote.generateShareText());
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildActionCard(context, 'Bookstore', Icons.menu_book, AppTheme.primaryBlue, const BookstoreScreen())),
            const SizedBox(width: 8),
            Expanded(child: _buildActionCard(context, 'Camp Meetings', Icons.campaign, Colors.amber.shade900, const CampMeetingLocationsScreen())),
            const SizedBox(width: 8),
            Expanded(child: _buildActionCard(context, 'Devotional', Icons.wb_sunny_outlined, Colors.deepOrange, const DevotionalScreen())),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildActionCard(context, 'Digital Tracts', Icons.share, Colors.teal, const DigitalTractsScreen())),
            const SizedBox(width: 8),
            Expanded(child: _buildActionCard(context, 'Family Pillars', Icons.family_restroom, Colors.purple, const FamilyLifeScreen())),
            const SizedBox(width: 8),
            Expanded(child: _buildActionCard(context, 'Live Sermons', Icons.live_tv, Colors.redAccent, const SermonsScreen())),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildActionCard(context, 'Testimonies', Icons.auto_awesome, Colors.indigo, const TestimoniesScreen())),
            const SizedBox(width: 8),
            Expanded(child: _buildActionCard(context, 'KJV Bible', Icons.auto_stories, Colors.amber.shade800, const KjvBibleReaderScreen())),
            const SizedBox(width: 8),
            Expanded(child: _buildActionCard(context, 'SS Lessons (20)', Icons.book, AppTheme.primaryGreen, const SabbathSchoolScreen())),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, Widget destination) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bookstore_items').limit(6).snapshots(),
      builder: (context, snapshot) {
        List<PhysicalBook> books = [];
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          books = snapshot.data!.docs.map((d) {
            return PhysicalBook.fromJson(d.data() as Map<String, dynamic>, d.id);
          }).toList();
        } else {
          books = PhysicalBook.getSampleBooks();
        }

        return SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final book = books[index];
              final hasCover = book.coverImageUrl.isNotEmpty &&
                  (book.coverImageUrl.startsWith('http://') || book.coverImageUrl.startsWith('https://'));

              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)));
                },
                child: Container(
                  width: 155,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 90,
                          width: double.infinity,
                          color: AppTheme.primaryBlue,
                          child: hasCover
                              ? Image.network(
                                  book.coverImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildFallbackBookCover(book),
                                )
                              : _buildFallbackBookCover(book),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        book.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ksh ${book.price.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGreen),
                          ),
                          if (book.hasSoftCopy)
                            const Icon(Icons.picture_as_pdf, size: 14, color: Colors.deepOrange),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFallbackBookCover(PhysicalBook book) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.menu_book, color: AppTheme.sacredGold, size: 32),
      ),
    );
  }
}
