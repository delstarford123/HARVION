import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ContentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  // 🚀 NEW: Optional parameters make this card infinitely reusable
  final String? imageUrl; // If you want to show a thumbnail instead of an icon
  final String? metadata; // E.g., "5 min read" or "14:02"
  final Widget? trailingWidget; // Pass a custom Share or Play button

  const ContentCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.iconColor,
    this.imageUrl,
    this.metadata,
    this.trailingWidget,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = iconColor ?? AppTheme.primaryGreen;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: themeColor.withOpacity(0.1),
          highlightColor: themeColor.withOpacity(0.05),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // 1. LEADING: Image or Icon Container
                // ==========================================
                if (imageUrl != null && imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildIconContainer(themeColor),
                    ),
                  )
                else
                  _buildIconContainer(themeColor),

                const SizedBox(width: 16),

                // ==========================================
                // 2. MIDDLE: Title, Subtitle, & Metadata
                // ==========================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryBlue,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Optional Metadata Row (e.g., "12 min read")
                      if (metadata != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          metadata!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // ==========================================
                // 3. TRAILING: Custom Widget or Default Chevron
                // ==========================================
                Align(
                  alignment: Alignment.center,
                  child: trailingWidget ??
                      const Icon(Icons.chevron_right, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build the nicely rounded icon container
  Widget _buildIconContainer(Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }
}
