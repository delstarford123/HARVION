import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../features/profile/profile_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  // 🚀 NEW: Parameters for maximum reusability across different screens
  final bool centerTitle;
  final double elevation;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.centerTitle = false, // Defaults to left-aligned (Android standard)
    this.elevation = 0.0, // Flat, modern look by default
    this.leading, // Allows passing custom drawer icons or back buttons
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing:
              0.5, // Slight letter spacing for a premium typographic feel
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: AppTheme.primaryBlue,
      foregroundColor: Colors.white,
      leading: leading,

      // If no custom actions are passed, use the default Profile button
      actions: actions ??
          [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                tooltip:
                    'View Profile & Mission', // Accessibility for screen readers
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                ),
                icon: Container(
                  // Creates a beautiful ring around the profile icon
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.sacredGold, width: 2),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue,
                    radius: 14,
                    child: Icon(Icons.person,
                        size: 18, color: AppTheme.sacredGold),
                  ),
                ),
              ),
            ),
          ],
    );
  }

  // Tells Flutter how tall the AppBar should be (required when implementing PreferredSizeWidget)
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
