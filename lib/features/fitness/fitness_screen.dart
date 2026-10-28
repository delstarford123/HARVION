import 'package:flutter/material.dart';
import '../../core/theme.dart';

class FitnessScreen extends StatelessWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Physical Fitness',
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
            _buildSectionTitle('Active Living'),
            _buildFitnessGrid(),
            const SizedBox(height: 32),
            _buildSectionTitle('Daily Exercises'),
            _buildExerciseList(),
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
          const Icon(Icons.fitness_center_rounded, color: Colors.white, size: 64),
          const SizedBox(height: 16),
          const Text(
            '"The body is the only medium through which the mind and the soul are developed for the upbuilding of character... Whatever hinders the physical strength, enfeebles the mental and spiritual powers."',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ministry of Healing, p. 130',
            style: TextStyle(
              fontSize: 14,
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
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildFitnessGrid() {
    final List<Map<String, dynamic>> items = [
      {'title': 'Walking', 'icon': Icons.directions_walk, 'color': Colors.green},
      {'title': 'Strength', 'icon': Icons.fitness_center, 'color': Colors.blueGrey},
      {'title': 'Flexibility', 'icon': Icons.accessibility_new, 'color': Colors.orange},
      {'title': 'Endurance', 'icon': Icons.speed, 'color': Colors.red},
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item['color'].withOpacity(0.1),
                    item['color'].withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'], color: item['color'], size: 36),
                  const SizedBox(height: 8),
                  Text(
                    item['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExerciseList() {
    final exercises = [
      {'title': 'Nature Walking', 'desc': '30 mins of brisk walking in fresh air.'},
      {'title': 'Morning Stretching', 'desc': 'Preparing the body for a day of service.'},
      {'title': 'Deep Breathing', 'desc': 'Oxygenating the blood and calming the mind.'},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      itemBuilder: (context, index) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              backgroundColor: AppTheme.primaryGreen,
              child: Icon(Icons.bolt, color: Colors.white, size: 20),
            ),
            title: Text(exercises[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(exercises[index]['desc']!),
            trailing: const Icon(Icons.play_circle_fill, color: AppTheme.primaryGreen, size: 32),
            onTap: () {},
          ),
        );
      },
    );
  }
}
