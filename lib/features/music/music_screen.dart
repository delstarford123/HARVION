import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'song_model.dart';
import 'music_player_screen.dart';
import 'audio_detail_screen.dart'; // 🚀 Added the Freemium Audio Detail Screen!

class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Music & Audio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      // 🚀 THE FIREBASE TUNNEL: Listens to the 'sermons' collection in real-time
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('sermons') // Matches the Admin Dashboard upload path!
                  .orderBy('publishedDate', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 100.0),
                    child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),
                  );
                }

                // 2. Error State
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading audio: ${snapshot.error}'));
                }

                // 3. Empty State (If you haven't uploaded anything yet)
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.audiotrack, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No audio sermons available yet.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // 4. Convert Firebase Documents into Dart 'Song' Objects
                final List<Song> songs = snapshot.data!.docs.map((doc) {
                  return Song.fromJson(doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                // 5. Build the List
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  itemCount: songs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildSongTile(context, songs[index]);
                  },
                );
              },
            ),
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
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.music_note_rounded, color: AppTheme.sacredGold, size: 64),
          const SizedBox(height: 16),
          const Text(
            '"Music is one of the highest arts. Good music not only gives us pleasure, but it elevates the mind and cultivates the finest qualities."',
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
            'Education, p. 167',
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

  Widget _buildSongTile(BuildContext context, Song song) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.music_note, color: AppTheme.primaryBlue),
        ),
        title: Text(
          song.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              song.artist,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            if (song.isPremium)
              Text(
                'Premium • Ksh ${song.price.toInt()}',
                style: const TextStyle(
                  color: AppTheme.sacredGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              const Text(
                'Free Access',
                style: TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        // 🚀 We wrap the trailing icons in a Row to fit both Share and Play buttons
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share,
                  size: 22, color: AppTheme.primaryBlue),
              onPressed: () {
                Share.share(song.generateShareText());
              },
            ),
            Icon(
              song.isPremium ? Icons.lock : Icons.play_circle_fill,
              color:
                  song.isPremium ? AppTheme.sacredGold : AppTheme.primaryGreen,
              size: 32,
            ),
          ],
        ),
        onTap: () => _handleSongTap(context, song),
      ),
    );
  }

  // 🚀 UPDATED: Routes directly to the Freemium Audio Detail Screen OR the Player
  void _handleSongTap(BuildContext context, Song song) {
    if (song.isPremium) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AudioDetailScreen(
            audioId: song.id,
            title: song.title,
            speaker: song.artist,
            price: song.price.toInt(),
            audioUrl: song.audioUrl,
            songObject:
                song, // Pass the whole object so the player can use it later
          ),
        ),
      );
    } else {
      // It's free! Go straight to the music player.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MusicPlayerScreen(song: song)),
      );
    }
  }
}
