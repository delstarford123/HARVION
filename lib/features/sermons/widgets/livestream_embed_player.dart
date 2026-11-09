import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme.dart';

class LivestreamEmbedPlayer extends StatefulWidget {
  final String mediaUrl;
  final String platform; // 'youtube', 'tiktok', etc.
  final String title;

  const LivestreamEmbedPlayer({
    super.key,
    required this.mediaUrl,
    required this.platform,
    required this.title,
  });

  /// Extract YouTube Video ID from any valid YouTube URL format
  static String? extractYouTubeId(String url) {
    if (url.isEmpty) return null;
    final trimmed = url.trim();

    // 1. Check youtu.be/ID
    final shortRegExp = RegExp(r'youtu\.be\/([a-zA-Z0-9_\-]{11})');
    final shortMatch = shortRegExp.firstMatch(trimmed);
    if (shortMatch != null) return shortMatch.group(1);

    // 2. Check watch?v=ID or live/ID or shorts/ID or embed/ID
    final standardRegExp = RegExp(r'(?:v=|\/live\/|\/shorts\/|\/embed\/)([a-zA-Z0-9_\-]{11})');
    final match = standardRegExp.firstMatch(trimmed);
    if (match != null) return match.group(1);

    // 3. Fallback: query parameter 'v'
    try {
      final uri = Uri.parse(trimmed);
      if (uri.queryParameters.containsKey('v')) {
        final v = uri.queryParameters['v'];
        if (v != null && v.length == 11) return v;
      }
    } catch (_) {}

    return null;
  }

  /// Extract TikTok Video ID or Username
  static String? extractTikTokVideoId(String url) {
    if (url.isEmpty) return null;
    final match = RegExp(r'video\/(\d+)').firstMatch(url.trim());
    return match?.group(1);
  }

  static String? extractTikTokUsername(String url) {
    if (url.isEmpty) return null;
    final match = RegExp(r'@([a-zA-Z0-9_\.]+)').firstMatch(url.trim());
    return match?.group(1);
  }

  @override
  State<LivestreamEmbedPlayer> createState() => _LivestreamEmbedPlayerState();
}

class _LivestreamEmbedPlayerState extends State<LivestreamEmbedPlayer> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
  }

  void _initWebViewController() {
    try {
      final isYouTube = widget.platform.toLowerCase() == 'youtube' ||
          widget.mediaUrl.contains('youtube.com') ||
          widget.mediaUrl.contains('youtu.be');

      final isTikTok = widget.platform.toLowerCase() == 'tiktok' ||
          widget.mediaUrl.contains('tiktok.com');

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (error) {
              debugPrint('[Livestream WebView Error]: ${error.description}');
            },
          ),
        );

      if (isYouTube) {
        final videoId = LivestreamEmbedPlayer.extractYouTubeId(widget.mediaUrl);
        if (videoId != null) {
          final embedHtml = '''
            <!DOCTYPE html>
            <html>
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
              <style>
                * { margin: 0; padding: 0; box-sizing: border-box; background-color: #000; }
                html, body { width: 100%; height: 100%; overflow: hidden; }
                iframe { width: 100%; height: 100%; border: 0; }
              </style>
            </head>
            <body>
              <iframe 
                src="https://www.youtube-nocookie.com/embed/$videoId?autoplay=1&playsinline=1&rel=0&modestbranding=1&enablejsapi=1" 
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" 
                allowfullscreen>
              </iframe>
            </body>
            </html>
          ''';
          controller.loadHtmlString(embedHtml, baseUrl: 'https://www.youtube-nocookie.com');
        } else {
          controller.loadRequest(Uri.parse(widget.mediaUrl));
        }
      } else if (isTikTok) {
        final videoId = LivestreamEmbedPlayer.extractTikTokVideoId(widget.mediaUrl);
        if (videoId != null) {
          final tikTokHtml = '''
            <!DOCTYPE html>
            <html>
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
              <style>
                * { margin: 0; padding: 0; box-sizing: border-box; background: #000; }
                html, body { width: 100%; height: 100%; overflow: hidden; display: flex; align-items: center; justify-content: center; }
                iframe { width: 100%; height: 100%; border: none; }
              </style>
            </head>
            <body>
              <iframe 
                src="https://www.tiktok.com/embed/v2/$videoId" 
                allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" 
                allowfullscreen>
              </iframe>
            </body>
            </html>
          ''';
          controller.loadHtmlString(tikTokHtml, baseUrl: 'https://www.tiktok.com');
        } else {
          // Live stream URL or channel
          final cleanUrl = widget.mediaUrl.contains('/live')
              ? widget.mediaUrl
              : '${widget.mediaUrl}/live';
          controller.loadRequest(Uri.parse(cleanUrl));
        }
      } else {
        controller.loadRequest(Uri.parse(widget.mediaUrl));
      }

      _controller = controller;
    } catch (e) {
      debugPrint('[Livestream Controller Init Error]: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _launchExternal() async {
    try {
      final uri = Uri.parse(widget.mediaUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _controller == null) {
      return Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.live_tv, color: Colors.redAccent, size: 40),
              const SizedBox(height: 10),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: const Text('Open External Stream'),
                onPressed: _launchExternal,
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller!),
        if (_isLoading)
          Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.sacredGold),
                  SizedBox(height: 12),
                  Text(
                    'Loading in-app live embed...',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
