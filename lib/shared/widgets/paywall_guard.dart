import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/subscription/subscription_screen.dart';

class PaywallGuard extends StatelessWidget {
  final Widget premiumContent;

  const PaywallGuard({super.key, required this.premiumContent});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Failsafe: If no user is logged in, they shouldn't even be here
    if (user == null) {
      return const Center(child: Text("Authentication required."));
    }

    // We removed the hardcoded email!
    // Now, everything relies on the secure Firestore database record.
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        // 2. Error or Missing Data State
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
              body: Center(child: Text("Error loading profile.")));
        }

        // 3. Extract the User Data from Firestore
        final userData = snapshot.data!.data() as Map<String, dynamic>;

        // Safely extract the role and subscription status
        final String role = userData['role'] ?? 'user';
        final bool isSubscribed = userData['isSubscribed'] ?? false;

        // 4. 👑 THE DYNAMIC GATEKEEPER LOGIC
        if (role == 'admin') {
          return premiumContent; // 🔓 Master Key: Admins get automatic free access!
        } else if (isSubscribed) {
          return premiumContent; // 🔓 Subscriber Key: Paying users get access!
        } else {
          return const SubscriptionScreen(); // 🔒 Access Denied: Show Paywall!
        }
      },
    );
  }
}
