import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'health_principles_screen.dart';
import '../recipes/recipes_screen.dart';
import '../bookstore/models/physical_book_model.dart';
import '../bookstore/book_detail_screen.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Health & Wellness',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 24),

            // Plant-based Recipe Book & Meal Planner Promotion Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryGreen, Color(0xFF1B5E20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.sacredGold,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'PLANT-BASED COOKBOOK',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Wholesome Recipes & Meal Planner',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Delicious 100% vegan recipes & weekly meal organizer.',
                                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppTheme.primaryGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RecipesScreen()));
                                },
                                child: const Text('EXPLORE RECIPES', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.soup_kitchen, size: 64, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 8 Laws Section Header with "View All"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'The 8 Laws of Health',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthPrinciplesScreen()));
                    },
                    child: const Text('Guide & Habits →'),
                  ),
                ],
              ),
            ),
            _buildNewstartGrid(context),
            const SizedBox(height: 24),

            _buildSectionTitle('Natural Remedies & Hydrotherapy'),
            _buildRemediesList(),
            const SizedBox(height: 24),

            // Companion Bookstore Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book, color: AppTheme.primaryBlue, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ministry of Healing & Diet Books',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Order original hardcovers with doorstep delivery.',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        final sampleBooks = PhysicalBook.getSampleBooks();
                        final book = sampleBooks.firstWhere((b) => b.id == 'health_01');
                        Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)));
                      },
                      child: const Text('ORDER', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite_rounded, color: Colors.white, size: 54),
          const SizedBox(height: 12),
          const Text(
            '"Beloved, I wish above all things that thou mayest prosper and be in health, even as thy soul prospereth."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '3 John 1:2',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.sacredGold.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildNewstartGrid(BuildContext context) {
    final List<Map<String, dynamic>> newstart = [
      {'title': 'Nutrition', 'icon': Icons.restaurant, 'color': Colors.orange},
      {'title': 'Exercise', 'icon': Icons.directions_run, 'color': Colors.blue},
      {'title': 'Water', 'icon': Icons.water_drop, 'color': Colors.lightBlue},
      {'title': 'Sunlight', 'icon': Icons.wb_sunny, 'color': Colors.amber},
      {'title': 'Temperance', 'icon': Icons.balance, 'color': Colors.purple},
      {'title': 'Air', 'icon': Icons.air, 'color': Colors.teal},
      {'title': 'Rest', 'icon': Icons.bedtime, 'color': Colors.indigo},
      {'title': 'Trust', 'icon': Icons.favorite, 'color': Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: newstart.length,
        itemBuilder: (context, index) {
          final item = newstart[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthPrinciplesScreen()));
            },
            child: Column(
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: item['color'].withOpacity(0.5), width: 1),
                  ),
                  child: Icon(
                    item['icon'],
                    color: item['color'],
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRemediesList() {
    final remedies = [
      {'title': 'Activated Charcoal Poultice & Water', 'subtitle': 'Adsorbs toxic bites, food poisoning, and inflammation.'},
      {'title': 'Hydrotherapy Contrast Hot/Cold Baths', 'subtitle': 'Boosts circulating white blood cells and revives immunity.'},
      {'title': 'Raw Garlic, Lemon & Honey Tonic', 'subtitle': 'Natural microbial defense against respiratory viral colds.'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: remedies.length,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      itemBuilder: (context, index) {
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(14),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medical_information, color: AppTheme.primaryBlue),
            ),
            title: Text(
              remedies[index]['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(remedies[index]['subtitle']!, style: const TextStyle(fontSize: 12)),
            ),
          ),
        );
      },
    );
  }
}
