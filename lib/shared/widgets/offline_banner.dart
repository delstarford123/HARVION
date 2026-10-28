import 'package:flutter/material.dart';
import '../../core/constants.dart';

class OfflineBanner extends StatelessWidget {
  final bool isVisible;

  const OfflineBanner({super.key, required this.isVisible});

  @override
  Widget build(BuildContext context) {
    // 🚀 THE UPGRADE: AnimatedSize makes the transition smooth instead of harsh
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: isVisible
          ? Container(
              width: double.infinity,
              color: Colors.orange
                  .shade900, // Slightly darker orange for better contrast
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              // SafeArea ensures it doesn't overlap with the phone's status bar
              // if you place it at the very absolute top of the screen.
              child: SafeArea(
                bottom: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      AppConstants.offlineModeActive,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing:
                            0.5, // Slightly spaced out for readability
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
