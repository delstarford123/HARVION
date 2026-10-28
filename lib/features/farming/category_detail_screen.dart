import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart'; // 🚀 Added for the Share Engine
import '../../core/theme.dart';
import 'farming_topic_model.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Text(categoryName),
        elevation: 0,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      // 🚀 THE FIREBASE TUNNEL
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(
                'farming_articles') // Assuming you name your collection this
            .where('category', isEqualTo: categoryName)
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 3. Empty State
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No articles in $categoryName yet.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 4. Map Firebase data to our Model & Sort
          List<FarmingTopic> topics = snapshot.data!.docs.map((doc) {
            return FarmingTopic.fromJson(
                doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          // 🚀 Sort by newest first locally (saves us from needing complex Firebase indexes!)
          topics.sort((a, b) => b.publishedDate.compareTo(a.publishedDate));

          // 5. Build the Live List
          return ListView.separated(
            padding: const EdgeInsets.all(16.0),
            itemCount: topics.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildArticleCard(context, topics[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildArticleCard(BuildContext context, FarmingTopic topic) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ArticleReadingScreen(topic: topic),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${topic.readTimeMinutes} min read',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    '${topic.publishedDate.day}/${topic.publishedDate.month}/${topic.publishedDate.year}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                topic.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                topic.shortDescription,
                style: TextStyle(color: Colors.grey.shade800, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// PRODUCTION ADDITION: Dedicated Article Reading Screen
// ---------------------------------------------------------
class ArticleReadingScreen extends StatelessWidget {
  final FarmingTopic topic;

  const ArticleReadingScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Future: Add to saved offline list using Hive!
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Article saved for offline reading'),
                  backgroundColor: AppTheme.primaryGreen,
                ),
              );
            },
          ),
          // 🚀 THE SHARE BUTTON ACTIVATED
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final String shareText =
                  "🌱 *VINE Farming Guide: ${topic.title}* 🌱\n\n"
                  "${topic.shortDescription}\n\n"
                  "✍️ Written by: ${topic.author}\n\n"
                  "Read the full comprehensive guide on the VINE App today!";
              Share.share(shareText);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              topic.category.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              topic.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppTheme.sacredGold,
                  radius: 16,
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.author,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${topic.readTimeMinutes} min read',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(),
            ),
            // 🚀 THE ARTICLE CONTENT
            Text(
              topic.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
