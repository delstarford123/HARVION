import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// HARVION - Online Reader Service
/// Seamlessly opens Spirit of Prophecy & digital Christian books online
/// using Chrome Custom Tabs (in-app browser) with external fallback.
class OnlineReaderService {
  static Future<bool> openOnlineBook(
    BuildContext context,
    String url, {
    String? title,
  }) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No digital reading link available for this title.')),
        );
      }
      return false;
    }

    final uri = Uri.tryParse(cleanUrl);
    if (uri == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid book web address.')),
        );
      }
      return false;
    }

    try {
      // 1. Try in-app browser view (Chrome Custom Tabs on Android)
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
      if (launched) return true;

      // 2. Fallback to external application
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      try {
        // Fallback to external browser if in-app tab fails
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } catch (err) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open digital reader: $err'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
        return false;
      }
    }
  }
}
