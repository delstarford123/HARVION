import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'models/recipe_model.dart';
import '../bookstore/models/physical_book_model.dart';
import '../bookstore/book_detail_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<HealthyRecipe> _recipes = HealthyRecipe.getSampleRecipes();

  final List<String> _recipeTabs = [
    'All Recipes',
    'Breakfast',
    'Entrees & Stews',
    'Salads & Dressings',
    'Healing Juices',
    'Weekly Meal Planner',
  ];

  // Simple in-memory weekly meal planner state
  final Map<String, String> _weeklyPlanner = {
    'Sunday': 'Golden Turmeric Lentil Stew with Brown Rice',
    'Monday': 'Edenic Whole Rolled Oat & Flax Power Porridge',
    'Tuesday': 'Hearty Country Chickpea & Garden Herb Salad',
    'Wednesday': 'Steamed Sweet Potatoes, Greens & Peanut Sauce',
    'Thursday': 'Lentil & Split Pea Vegetable Soup with Millet',
    'Friday (Preparation Day)': 'Hearty Sabbath Pot: Lentil Loaf & Steamed Vegetables',
    'Sabbath (Fellowship Lunch)': 'Special Sabbath Loaf, Fresh Garden Salad & Fruit Platter',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _recipeTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRecipeDetail(HealthyRecipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      recipe.category.toUpperCase(),
                      style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                recipe.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${recipe.prepTimeMinutes + recipe.cookTimeMinutes} mins total',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                  const SizedBox(width: 14),
                  const Icon(Icons.restaurant, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${recipe.servings} servings',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.description,
                        style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                      ),
                      const SizedBox(height: 20),

                      // Ingredients
                      const Text(
                        'Wholesome Ingredients',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: recipe.ingredients.map((ing) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle, size: 16, color: AppTheme.primaryGreen),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(ing, style: const TextStyle(fontSize: 13, height: 1.3))),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Instructions
                      const Text(
                        'Preparation Instructions',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(height: 10),
                      ...recipe.instructions.asMap().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppTheme.primaryBlue,
                                child: Text('${entry.key + 1}',
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(entry.value, style: const TextStyle(fontSize: 13, height: 1.4)),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Health benefits
                      const Text(
                        'Nutritional & Healing Benefits',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                      ),
                      const SizedBox(height: 8),
                      ...recipe.healthBenefits.map((b) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Row(
                              children: [
                                const Icon(Icons.eco, size: 16, color: AppTheme.primaryGreen),
                                const SizedBox(width: 8),
                                Expanded(child: Text(b, style: const TextStyle(fontSize: 12))),
                              ],
                            ),
                          )),
                      const SizedBox(height: 24),

                      // Tied Physical Book Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.sacredGold.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.menu_book, color: AppTheme.sacredGold, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Companion Physical Book',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                                  ),
                                  Text(
                                    recipe.linkedBookTitle,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue),
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
                                Navigator.pop(ctx);
                                final sampleBooks = PhysicalBook.getSampleBooks();
                                final book = sampleBooks.firstWhere(
                                  (b) => b.id == recipe.linkedBookstoreBookId,
                                  orElse: () => sampleBooks.first,
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
                                );
                              },
                              child: const Text('VIEW IN STORE', style: TextStyle(fontSize: 10)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Plant-Based Recipes & Meal Planner', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.sacredGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _recipeTabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecipeGrid(_recipes),
          _buildRecipeGrid(_recipes.where((r) => r.category == 'Breakfast').toList()),
          _buildRecipeGrid(_recipes.where((r) => r.category == 'Entrees & Stews').toList()),
          _buildRecipeGrid(_recipes.where((r) => r.category == 'Salads & Dressings').toList()),
          _buildRecipeGrid(_recipes.where((r) => r.category == 'Healing Juices').toList()),
          _buildMealPlannerView(),
        ],
      ),
    );
  }

  Widget _buildRecipeGrid(List<HealthyRecipe> recipes) {
    if (recipes.isEmpty) {
      return Center(
        child: Text('No recipes in this category yet.', style: TextStyle(color: Colors.grey.shade600)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: recipes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final r = recipes[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showRecipeDetail(r),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          r.category.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('${r.prepTimeMinutes + r.cookTimeMinutes}m',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryBlue),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book, size: 14, color: AppTheme.sacredGold),
                          const SizedBox(width: 6),
                          Text(
                            r.linkedBookTitle,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        ],
                      ),
                      const Text(
                        'View Recipe →',
                        style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMealPlannerView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_month, color: AppTheme.primaryGreen, size: 30),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Wholesome Meal Plan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryGreen),
                      ),
                      Text(
                        'Organized plant-based nutrition for body and mind clarity.',
                        style: TextStyle(fontSize: 11, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Days of the week list
          ..._weeklyPlanner.entries.map((entry) {
            final isSabbath = entry.key.contains('Sabbath');
            final isPrep = entry.key.contains('Preparation');

            return Card(
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: isSabbath
                    ? const BorderSide(color: AppTheme.sacredGold, width: 1.5)
                    : BorderSide.none,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: isSabbath
                      ? AppTheme.sacredGold.withOpacity(0.2)
                      : (isPrep ? Colors.blue.withOpacity(0.12) : Colors.grey.shade100),
                  child: Icon(
                    isSabbath ? Icons.star : (isPrep ? Icons.soup_kitchen : Icons.restaurant_menu),
                    color: isSabbath ? Colors.brown.shade800 : AppTheme.primaryGreen,
                    size: 20,
                  ),
                ),
                title: Text(
                  entry.key,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isSabbath ? AppTheme.primaryBlue : Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 13, height: 1.3),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

