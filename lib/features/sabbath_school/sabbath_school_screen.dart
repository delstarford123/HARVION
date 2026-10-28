import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'models/sabbath_school_model.dart';
import 'services/lesson_notes_service.dart';
import '../library/library_screen.dart';

class SabbathSchoolScreen extends StatefulWidget {
  const SabbathSchoolScreen({super.key});

  @override
  State<SabbathSchoolScreen> createState() => _SabbathSchoolScreenState();
}

class _SabbathSchoolScreenState extends State<SabbathSchoolScreen> with SingleTickerProviderStateMixin {
  late SabbathSchoolLesson _lesson;
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();
  final LessonNotesService _notesService = LessonNotesService();
  bool _isExportingPdf = false;
  int _currentDayIndex = 0;

  final List<SabbathSchoolLesson> _allLessons = SabbathSchoolLesson.getAllTwentyLessons();

  @override
  void initState() {
    super.initState();
    _lesson = SabbathSchoolLesson.getCurrentQuarterLesson();
    _tabController = TabController(length: _lesson.dailyReadings.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadNoteForCurrentDay();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging || _tabController.index != _currentDayIndex) {
      setState(() {
        _currentDayIndex = _tabController.index;
      });
      _loadNoteForCurrentDay();
    }
  }

  void _loadNoteForCurrentDay() {
    final note = _notesService.getNote(_lesson.lessonNumber, _currentDayIndex);
    _notesController.text = note;
  }

  void _saveCurrentNote(String text) {
    _notesService.saveNote(_lesson.lessonNumber, _currentDayIndex, text);
  }

  void _changeLesson(SabbathSchoolLesson newLesson) {
    setState(() {
      _lesson = newLesson;
      _currentDayIndex = 0;
      _tabController.animateTo(0);
    });
    _loadNoteForCurrentDay();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _shareMemoryVerse() {
    Share.share(
      "📖 *SABBATH SCHOOL MEMORY VERSE* 📖\n"
      "\"${_lesson.memoryVerse}\"\n"
      "— ${_lesson.memoryVerseRef}\n\n"
      "Quarterly: ${_lesson.quarterlyTheme}\n"
      "Lesson ${_lesson.lessonNumber}: ${_lesson.title}\n"
      "Join Sabbath School with the Harvion App!",
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _isExportingPdf = true);
    try {
      await _notesService.exportLessonNotesPdf(_lesson);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📄 PDF Generated successfully! Opening share sheet...'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export PDF: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
  }

  void _showLessonPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          height: 480,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Sabbath School Lesson',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Text(
                'Access the last 20 Sabbath School Lessons with full offline notes.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _allLessons.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final l = _allLessons[i];
                    final isSelected = l.lessonNumber == _lesson.lessonNumber;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: isSelected ? AppTheme.sacredGold : AppTheme.primaryBlue.withOpacity(0.1),
                        foregroundColor: isSelected ? Colors.black : AppTheme.primaryBlue,
                        child: Text(
                          '${l.lessonNumber}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        l.title,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppTheme.primaryGreen : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${l.quarterlyTheme} • ${l.dateRange}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primaryGreen) : null,
                      onTap: () {
                        Navigator.pop(context);
                        _changeLesson(l);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Sabbath School Quarterly', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          // Lesson selector button
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.sacredGold,
              backgroundColor: Colors.white.withOpacity(0.12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.format_list_numbered, size: 16),
            label: Text(
              'Lesson ${_lesson.lessonNumber}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onPressed: _showLessonPickerModal,
          ),
          const SizedBox(width: 4),
          // Export PDF
          IconButton(
            tooltip: 'Export Notes as PDF',
            icon: _isExportingPdf
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf),
            onPressed: _isExportingPdf ? null : _exportPdf,
          ),
          IconButton(
            tooltip: 'Share Memory Verse',
            icon: const Icon(Icons.share),
            onPressed: _shareMemoryVerse,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.sacredGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _lesson.dailyReadings.map((day) => Tab(text: day.dayName)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Lesson Title & Quarterly Theme Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.primaryBlue.withOpacity(0.06),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lesson ${_lesson.lessonNumber}: ${_lesson.title}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _lesson.quarterlyTheme,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                  ),
                  onPressed: _showLessonPickerModal,
                  child: const Text('Change Lesson', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
                ),
              ],
            ),
          ),

          // Memory Verse Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8E7),
              border: Border(bottom: BorderSide(color: Color(0xFFFFE082))),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.bookmark_added, color: AppTheme.sacredGold, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memory Verse: ${_lesson.memoryVerseRef}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryBlue),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '"${_lesson.memoryVerse}"',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Day by Day study views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _lesson.dailyReadings.map((day) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day Title & Scripture
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          day.dayName.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        day.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.menu_book, size: 16, color: AppTheme.sacredGold),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              day.scriptureReading,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Day Content
                      Text(
                        day.content,
                        style: const TextStyle(fontSize: 15, height: 1.6, color: Colors.black87),
                      ),
                      const SizedBox(height: 22),

                      // Discussion Questions
                      if (day.discussionQuestions.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.question_answer_outlined, color: AppTheme.primaryBlue, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sabbath School Discussion Questions',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...day.discussionQuestions.map((q) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      Expanded(
                                        child: Text(q, style: const TextStyle(fontSize: 12, height: 1.4)),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Personal Study Notes (Saved locally to Hive)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.edit_note, color: AppTheme.primaryBlue, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        'My Notes (${day.dayName})',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    'Saved to device',
                                    style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _notesController,
                                maxLines: 4,
                                onChanged: _saveCurrentNote,
                                decoration: const InputDecoration(
                                  hintText: 'Record thoughts, prayer requests, and answers to discussion questions...',
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.primaryBlue,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    ),
                                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                                    label: const Text('Download / Export Lesson Notes (PDF)', style: TextStyle(fontSize: 11)),
                                    onPressed: _exportPdf,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Quick Navigation Links
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.library_books, size: 16, color: AppTheme.primaryBlue),
                              label: const Text('Open Source SOP Books', style: TextStyle(fontSize: 11)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LibraryScreen()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
