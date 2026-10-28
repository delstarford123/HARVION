
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme.dart';
import '../auth/auth_screen.dart';
import 'music_player_screen.dart';
import 'song_model.dart';
import '../subscription/payment_screen.dart'; // 🚀 Successfully imported the Payment Screen!

class AudioDetailScreen extends StatefulWidget {
  final String audioId;
  final String title;
  final String speaker;
  final int price;
  final String audioUrl;
  final Song songObject;

  const AudioDetailScreen({
    super.key,
    required this.audioId,
    required this.title,
    required this.speaker,
    required this.price,
    required this.audioUrl,
    required this.songObject,
  });

  @override
  State<AudioDetailScreen> createState() => _AudioDetailScreenState();
}

class _AudioDetailScreenState extends State<AudioDetailScreen> {
  bool _hasPurchased = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPurchaseStatus();
  }

  // 🚀 System remembers if they already paid!
  Future<void> _checkPurchaseStatus() async {
    if (widget.price == 0) {
      if (mounted) {
        setState(() {
          _hasPurchased = true; // Free items are automatically "purchased"
          _isLoading = false;
        });
      }
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return; // Not logged in, definitely hasn't purchased
    }

    try {
      // Check user's profile in Firestore for this specific Audio ID
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final List<dynamic> purchasedItems =
            doc.data()?['purchasedItems'] ?? [];
        if (purchasedItems.contains(widget.audioId) ||
            doc.data()?['role'] == 'admin') {
          _hasPurchased = true;
        }
      }
    } catch (e) {
      debugPrint("Error checking purchase status: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleUnlockClick() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // 🛑 User wants to buy, but isn't logged in. Force login NOW.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to purchase this track.")),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      ).then((_) =>
          _checkPurchaseStatus()); // Re-check after they return from login
      return;
    }

    // 🚀 ✅ User is logged in. Trigger the Real M-Pesa Payment Screen!
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          itemId: widget.audioId,
          itemName: widget.title,
          price: widget.price,
        ),
      ),
    ).then((_) => _checkPurchaseStatus()); // 🔄 Re-checks if they successfully paid when returning!
  }

  void _playAudio() {
    // Replaces this detail screen with the actual Music Player
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerScreen(song: widget.songObject),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFree = widget.price == 0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Track Details'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // 🎵 Mock Album Art / Icon
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          width: 4),
                    ),
                    child: const Icon(
                      Icons.music_note,
                      size: 80,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 🏷️ Badges (Free vs Premium)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          isFree ? AppTheme.primaryGreen : AppTheme.sacredGold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isFree ? 'FREE ACCESS' : 'PREMIUM TRACK',
                      style: TextStyle(
                        color: isFree ? Colors.white : AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 📝 Title & Speaker
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.speaker,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),

                  const Spacer(),

                  // 🚀 THE ACTION BUTTON (Play or Buy)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: _hasPurchased
                        ? ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _playAudio,
                            icon: const Icon(Icons.play_arrow,
                                color: Colors.white, size: 28),
                            label: const Text("PLAY NOW",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          )
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.sacredGold,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _handleUnlockClick,
                            icon: const Icon(Icons.lock_open,
                                color: AppTheme.primaryBlue),
                            label: Text("UNLOCK FOR KSh ${widget.price}",
                                style: const TextStyle(
                                    color: AppTheme.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}