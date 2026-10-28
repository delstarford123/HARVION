import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'book_model.dart';
import 'pdf_viewer_screen.dart';
import 'data/sop_chapters_repository.dart';

class SopBookReaderScreen extends StatefulWidget {
  final Book book;

  const SopBookReaderScreen({super.key, required this.book});

  @override
  State<SopBookReaderScreen> createState() => _SopBookReaderScreenState();
}

class _SopBookReaderScreenState extends State<SopBookReaderScreen> {
  int _selectedChapterIndex = 0;
  double _fontSize = 16.0;
  bool _isNightMode = false;
  final TextEditingController _chapterSearchController = TextEditingController();
  String _chapterSearchQuery = '';

  late final List<Map<String, dynamic>> _allChapters;

  @override
  void initState() {
    super.initState();
    _allChapters = SopChaptersRepository.getChaptersForBook(widget.book.id, widget.book.title);
  }

  @override
  void dispose() {
    _chapterSearchController.dispose();
    super.dispose();
  }

  void _goToChapter(int index) {
    if (index >= 0 && index < _allChapters.length) {
      setState(() {
        _selectedChapterIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chapter = _allChapters[_selectedChapterIndex];
    final totalChapters = _allChapters.length;
    final title = chapter['title'] as String? ?? 'Chapter ${_selectedChapterIndex + 1}';
    final subtitle = chapter['subtitle'] as String? ?? '';
    final content = chapter['content'] as String? ?? '';
    final scripture = chapter['scripture'] as String? ?? '';

    final bgColor = _isNightMode ? const Color(0xFF1A1A1A) : const Color(0xFFFAF9F6);
    final textColor = _isNightMode ? const Color(0xFFE0E0E0) : const Color(0xFF2C2C2C);
    final cardBg = _isNightMode ? const Color(0xFF252525) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Chapter ${_selectedChapterIndex + 1} of $totalChapters',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'View Full PDF',
            icon: const Icon(Icons.picture_as_pdf, size: 20),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PdfViewerScreen(book: widget.book)),
              );
            },
          ),
          IconButton(
            tooltip: 'Share Chapter',
            icon: const Icon(Icons.share, size: 20),
            onPressed: () {
              Share.share(
                '📖 ${widget.book.title}\n$title: $subtitle\n\n'
                '$content\n\n'
                'Scripture Foundation: $scripture\n— Read on Harvion SDA Ministry App',
              );
            },
          ),
          IconButton(
            tooltip: _isNightMode ? 'Light Mode' : 'Night Mode',
            icon: Icon(_isNightMode ? Icons.light_mode : Icons.dark_mode, size: 20),
            onPressed: () => setState(() => _isNightMode = !_isNightMode),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.text_fields, size: 20),
            tooltip: 'Font Size',
            onSelected: (val) {
              setState(() {
                if (val == 'up' && _fontSize < 26) _fontSize += 2;
                if (val == 'down' && _fontSize > 13) _fontSize -= 2;
              });
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'up', child: Text('A+ Enlarge Font')),
              const PopupMenuItem(value: 'down', child: Text('A- Reduce Font')),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: _isNightMode ? const Color(0xFF1E1E1E) : Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_stories, color: AppTheme.sacredGold, size: 36),
                  const SizedBox(height: 8),
                  Text(
                    widget.book.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'By ${widget.book.author} • $totalChapters Chapters',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: TextField(
                controller: _chapterSearchController,
                onChanged: (val) => setState(() => _chapterSearchQuery = val.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'Search chapters...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  isDense: true,
                  filled: true,
                  fillColor: _isNightMode ? const Color(0xFF2A2A2A) : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _allChapters.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.2)),
                itemBuilder: (context, i) {
                  final ch = _allChapters[i];
                  final chTitle = ch['title'] as String? ?? 'Chapter ${i + 1}';
                  final chSub = ch['subtitle'] as String? ?? '';
                  final isSel = i == _selectedChapterIndex;

                  if (_chapterSearchQuery.isNotEmpty) {
                    if (!chTitle.toLowerCase().contains(_chapterSearchQuery) &&
                        !chSub.toLowerCase().contains(_chapterSearchQuery)) {
                      return const SizedBox.shrink();
                    }
                  }

                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: isSel ? AppTheme.sacredGold : (_isNightMode ? Colors.grey.shade800 : Colors.grey.shade200),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.black : (_isNightMode ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                    title: Text(
                      chTitle,
                      style: TextStyle(
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                        color: isSel ? AppTheme.primaryGreen : (_isNightMode ? Colors.white : Colors.black87),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: chSub.isNotEmpty
                        ? Text(
                            chSub,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    onTap: () {
                      _goToChapter(i);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter Header Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'CHAPTER ${_selectedChapterIndex + 1} OF $totalChapters',
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Chapter Title
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _isNightMode ? Colors.white : AppTheme.primaryBlue,
                height: 1.3,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _isNightMode ? AppTheme.sacredGold : Colors.grey.shade700,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Divider(color: Colors.grey.withValues(alpha: 0.3)),
            const SizedBox(height: 16),

            // Main Chapter Content
            SelectableText(
              content,
              style: TextStyle(
                fontSize: _fontSize,
                height: 1.75,
                color: textColor,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 24),

            // Scripture Foundation Anchor
            if (scripture.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.sacredGold.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.menu_book, color: AppTheme.sacredGold, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Key Scripture Foundation',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryGreen),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      scripture,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isNightMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Navigation Buttons (Previous Chapter / Next Chapter)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _selectedChapterIndex > 0 ? () => _goToChapter(_selectedChapterIndex - 1) : null,
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Previous', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _selectedChapterIndex < totalChapters - 1
                        ? () => _goToChapter(_selectedChapterIndex + 1)
                        : null,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Next Chapter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
