import 'dart:typed_data';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants.dart';
import '../models/sabbath_school_model.dart';

class LessonNotesService {
  static final LessonNotesService _instance = LessonNotesService._internal();
  factory LessonNotesService() => _instance;
  LessonNotesService._internal();

  Box? _box;

  Box _getBox() {
    _box ??= Hive.box(AppConstants.boxSabbathNotes);
    return _box!;
  }

  String _getKey(int lessonNum, int dayIndex) {
    return 'note_l${lessonNum}_d$dayIndex';
  }

  /// Save personal note for a specific lesson and day
  Future<void> saveNote(int lessonNum, int dayIndex, String noteText) async {
    final box = _getBox();
    await box.put(_getKey(lessonNum, dayIndex), noteText);
  }

  /// Retrieve personal note for a specific lesson and day
  String getNote(int lessonNum, int dayIndex) {
    try {
      final box = _getBox();
      return box.get(_getKey(lessonNum, dayIndex), defaultValue: '') as String;
    } catch (_) {
      return '';
    }
  }

  /// Get all notes for a specific lesson
  Map<int, String> getAllNotesForLesson(int lessonNum) {
    final Map<int, String> map = {};
    for (int d = 0; d < 7; d++) {
      final note = getNote(lessonNum, d);
      if (note.isNotEmpty) {
        map[d] = note;
      }
    }
    return map;
  }

  /// Generate and export lesson study notes as a professional PDF document
  Future<void> exportLessonNotesPdf(SabbathSchoolLesson lesson) async {
    final pdf = pw.Document();
    final allNotes = getAllNotesForLesson(lesson.lessonNumber);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('0D3B66'),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'HARVION SABBATH SCHOOL STUDY NOTES',
                        style: pw.TextStyle(
                          color: PdfColor.fromHex('E8A838'),
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Quarterly: ${lesson.quarterlyTheme}',
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Lesson ${lesson.lessonNumber}',
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Lesson Title & Date
            pw.Text(
              lesson.title,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('0D3B66'),
              ),
            ),
            pw.Text(
              'Study Date Range: ${lesson.dateRange}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 12),

            // Memory Verse Box
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('FFF8E7'),
                border: pw.Border.all(color: PdfColor.fromHex('F4D06F')),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Memory Verse: ${lesson.memoryVerseRef}',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                      color: PdfColor.fromHex('0D3B66'),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '"${lesson.memoryVerse}"',
                    style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            pw.Text(
              'DAILY STUDY READINGS & PERSONAL REFLECTION NOTES',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('0D3B66')),
            ),
            pw.Divider(thickness: 1, color: PdfColor.fromHex('0D3B66')),
            pw.SizedBox(height: 8),

            // Daily Readings with User Notes
            ...List.generate(lesson.dailyReadings.length, (index) {
              final day = lesson.dailyReadings[index];
              final userNote = allNotes[index] ?? '';

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          '${day.dayName}: ${day.title}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColor.fromHex('0D3B66')),
                        ),
                        pw.Text(
                          day.scriptureReading,
                          style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      day.content,
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        color: userNote.isNotEmpty ? PdfColor.fromHex('E8F5E9') : PdfColors.grey100,
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            userNote.isNotEmpty ? 'My Personal Study Note:' : 'My Personal Study Note: [No note recorded]',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 9,
                              color: userNote.isNotEmpty ? PdfColor.fromHex('2E7D32') : PdfColors.grey600,
                            ),
                          ),
                          if (userNote.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              userNote,
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.black),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            pw.SizedBox(height: 16),
            pw.Align(
              alignment: pw.Alignment.center,
              child: pw.Text(
                'Produced by Harvion SDA Literature Evangelism & Ministry Platform',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ),
          ];
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();

    await Share.shareXFiles(
      [
        XFile.fromData(
          pdfBytes,
          name: 'Harvion_Lesson_${lesson.lessonNumber}_Notes.pdf',
          mimeType: 'application/pdf',
        ),
      ],
      text: '📖 Harvion Sabbath School Study Notes: Lesson ${lesson.lessonNumber} - ${lesson.title}',
    );
  }
}
