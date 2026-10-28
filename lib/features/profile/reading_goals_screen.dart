import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ReadingGoalsScreen extends StatefulWidget {
  const ReadingGoalsScreen({super.key});

  @override
  State<ReadingGoalsScreen> createState() => _ReadingGoalsScreenState();
}

class _ReadingGoalsScreenState extends State<ReadingGoalsScreen> {
  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'The Conflict of the Ages Series',
      'author': 'Ellen G. White',
      'description': 'Patriarchs & Prophets, Prophets & Kings, Desire of Ages, Acts of the Apostles, Great Controversy.',
      'progress': 0.60,
      'completedPages': 2280,
      'totalPages': 3800,
    },
    {
      'title': 'Daily Morning Watch Devotional',
      'author': 'Daily Habit',
      'description': '365 Days of communion with God before facing the world.',
      'progress': 0.78,
      'completedPages': 285,
      'totalPages': 365,
    },
    {
      'title': 'Steps to Christ (13 Chapters)',
      'author': 'Ellen G. White',
      'description': 'Mastering the path of repentance, faith, surrender, and growing up into Christ.',
      'progress': 1.0,
      'completedPages': 13,
      'totalPages': 13,
    },
    {
      'title': 'The Ministry of Healing (Health Ministry)',
      'author': 'Ellen G. White',
      'description': 'Studying medical missionary work and the 8 natural laws of health.',
      'progress': 0.45,
      'completedPages': 240,
      'totalPages': 540,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Spiritual Reading Goals', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_stories, color: AppTheme.sacredGold, size: 28),
                      SizedBox(width: 10),
                      Text(
                        'Read for Eternity',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '"Fill the mind with the truths of God\'s word and the Spirit of Prophecy, and there will be no room for common, worthless thoughts."',
                    style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Active Reading Milestones',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 12),

            // Goals list
            ..._goals.map((g) {
              final double prog = g['progress'];
              final isDone = prog >= 1.0;

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              g['title'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue),
                            ),
                          ),
                          if (isDone)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('COMPLETED',
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        g['description'],
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.3),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${g['completedPages']} of ${g['totalPages']} read',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${(prog * 100).toInt()}%',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: prog,
                        backgroundColor: Colors.grey.shade200,
                        color: isDone ? Colors.green : AppTheme.primaryGreen,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

