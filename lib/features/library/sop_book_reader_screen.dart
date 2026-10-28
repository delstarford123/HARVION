import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme.dart';
import 'book_model.dart';
import 'pdf_viewer_screen.dart';

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

  late final List<Map<String, dynamic>> _chapters;

  @override
  void initState() {
    super.initState();
    _chapters = _getChaptersForBook(widget.book.id);
  }

  List<Map<String, dynamic>> _getChaptersForBook(String bookId) {
    if (bookId.contains('ministry_of_healing') || widget.book.title.contains('Ministry of Healing')) {
      return [
        {
          'title': 'Chapter 1: Our Example',
          'subtitle': 'The Great Medical Missionary Work of Christ',
          'content':
              'Our Lord Jesus Christ came to this world as the unwearied servant of man\'s necessity. He "took our infirmities, and bare our sicknesses," that He might minister to every need of humanity. (Matthew 8:17). The burden of disease and wretchedness and sin He came to remove. It was His mission to bring to men complete restoration; He came to give them health and peace and perfection of character.\n\nVaried were the circumstances and needs of those who besought His aid, and none who came to Him went away unhelped. From Him flowed a stream of healing power, and in body and mind and soul men were made whole.\n\nThe Saviour\'s work was not restricted to any time or place. His compassion knew no limit. On so large a scale did He conduct His work of healing and teaching that there was no building in Palestine large enough to receive the multitudes that thronged Him. On the green hill slopes of Galilee, in the thoroughfares of travel, by the seashore, in the synagogues, and in every other place where the sick could be brought to Him, was His hospital. In every city, every town, every village through which He passed, He laid His hands upon the afflicted ones and healed them.',
        },
        {
          'title': 'Chapter 2: Days of Ministry',
          'subtitle': 'Restoring Body, Mind, and Soul',
          'content':
              'In the fisherman\'s home at Capernaum the mother of Peter\'s wife is lying sick of "a great fever," and "they tell Him of her." Jesus "touched her hand, and the fever left her; and she arose, and ministered unto them." (Mark 1:30; Matthew 8:15).\n\nRapidly the tidings spread. The miracle had been wrought upon the Sabbath day, and for fear of the rabbis the people dared not come for healing until the sun was set. Then from the homes, the shops, the marketplaces, the inhabitants of the city pressed toward the humble dwelling that sheltered Jesus. The sick were brought upon litters, they came leaning upon staffs, or, supported by friends, they cast themselves feebly into the Saviour\'s presence.\n\nHour after hour they came and went, for none could know whether tomorrow would find the Healer still among them. Never before had Capernaum witnessed a day like this. The air was filled with the voice of triumph and shouts of deliverance.',
        },
        {
          'title': 'Chapter 3: With Nature and With God',
          'subtitle': 'The Secret of Rest and Spiritual Energy',
          'content':
              'The Saviour\'s life on earth was a life of communion with nature and with God. In this communion He revealed for us the secret of a life of power.\n\nJesus was an earnest, constant worker. Never lived there among men another whose life was so filled with work, so crowded with responsibilities. Yet how often He was found in prayer! How constant was His communion with God! Again and again in the history of His earthly life are found records such as these: "Rising up a great while before day, He went out, and departed into a solitary place, and there prayed." (Mark 1:35).\n\nIn a life wholly devoted to the good of others, the Saviour found it necessary to turn aside from the thoroughfares of travel and from the throng that followed Him day after day. He must turn aside from a life of ceaseless activity and contact with human needs, to seek retirement and unbroken communion with His Father.',
        },
        {
          'title': 'Chapter 4: The Touch of Faith',
          'subtitle': 'Reaching Beyond Human Remedies',
          'content':
              '"If I may but touch His garment, I shall be whole." (Matthew 9:21). It was a poor woman who spoke these words—a woman who for twelve years had suffered from a disease that made her life a burden. She had spent all her substance upon physicians and remedies, only to be pronounced incurable. But as she heard of the Healer, her hope revived.\n\nShe thought, If I could only get near enough to speak to Him, I might be healed. As she saw Him making His way through the crowd, she tried to reach Him, but in vain. Again and again she almost gave up in despair. Then the crowd pressed Him close to where she was. The golden opportunity had come.\n\nReaching forward, she just touched the border of His garment. In that moment she knew that she was healed. Her strength returned. She felt the vitalizing power of new health bounding through every vein.',
        },
        {
          'title': 'Chapter 5: Healing of the Soul',
          'subtitle': 'Forgiveness and Peace of Conscience',
          'content':
              'Many of those who came to Christ for help had brought disease upon themselves; yet He did not refuse to heal them. And when virtue from Him entered into these souls, they were convicted of sin, and many were healed of their spiritual disease, as well as of their physical maladies.\n\nAmong these was the paralytic at Capernaum. Like the leper, this paralytic had lost all hope of recovery. His disease was the result of a life of sin, and his sufferings were embittered by remorse. In vain he had appealed to the Pharisees and the doctors for relief; they pronounced him incurable, and abandoned him to the wrath of God.\n\nWhen Jesus said, "Son, be of good cheer; thy sins be forgiven thee," the burden of despair rolled from the sick man\'s soul; the peace of forgiveness rested upon his spirit and shone out in his countenance. His physical pain was gone, and his whole being was transformed. In the simple faith that accepted Jesus\' words, he sprang to his feet, a healthy, happy man.',
        },
        {
          'title': 'Chapter 6: Diet and Health',
          'subtitle': 'God\'s Original Food for Man',
          'content':
              'Our bodies are built up from the food we eat. There is a constant breaking down of the tissues of the body; every movement of every organ involves waste, and this waste is repaired from our food. Each organ of the body requires its share of nutrition. The brain must be supplied with its portion; the bones, muscles, and nerves demand theirs.\n\nIn order to know what are the best foods, we must study God\'s original plan for man\'s diet. He who created man and who understands his needs appointed Adam his food: "Behold," He said, "I have given you every herb yielding seed, ... and every tree, in which is the fruit of a tree yielding seed; to you it shall be for food." (Genesis 1:29). Upon leaving Eden to gain his livelihood by tilling the earth under the curse of sin, man received permission to eat also "the herb of the field." (Genesis 3:18).\n\nGrains, fruits, nuts, and vegetables constitute the diet chosen for us by our Creator. These foods, prepared in as simple and natural a manner as possible, are the most healthful and nourishing. They impart a strength, a power of endurance, and a vigor of intellect that are not afforded by a more complex and stimulating diet.',
        },
      ];
    } else if (bookId.contains('steps_to_christ') || widget.book.title.contains('Steps to Christ')) {
      return [
        {
          'title': 'Chapter 1: God\'s Love for Man',
          'subtitle': 'Nature and Revelation Testify of God\'s Love',
          'content':
              'Nature and revelation alike testify of God\'s love. Our Father in heaven is the source of life, of wisdom, and of joy. Look at the wonderful and beautiful things of nature. Think of their marvelous adaptation to the needs and happiness, not only of man, but of all living creatures.\n\nThe sunshine and the rain, that gladden and refresh the earth, the hills and seas and plains, all speak to us of the Creator\'s love. It is God who supplies the daily needs of all His creatures. In the beautiful words of the psalmist: "The eyes of all wait upon Thee; and Thou givest them their meat in due season. Thou openest Thine hand, and satisfiest the desire of every living thing." (Psalm 145:15, 16).\n\nGod made man perfectly holy and happy; and the fair earth, as it came from the Creator\'s hand, bore no blight of decay or shadow of the curse. It is transgression of God\'s law—the law of love—that has brought woe and death.',
        },
        {
          'title': 'Chapter 2: The Sinner\'s Need of Christ',
          'subtitle': 'The Only Way of Restoration',
          'content':
              'Man was originally endowed with noble powers and a well-balanced mind. He was perfect in his being, and in harmony with God. His thoughts were pure, his aims holy. But through disobedience, his powers were perverted, and selfishness took the place of love. His nature became so weakened through transgression that it was impossible for him, in his own strength, to resist the power of evil.\n\nHe was made captive by Satan, and would have remained so forever had not God specially intervened. It was the tempter\'s purpose to thwart the divine plan in man\'s creation, and fill the earth with woe and desolation. And he would point to all this evil as the result of God\'s work in creating man.\n\nIn his sinless state, man held joyful communion with Him "in whom are hid all the treasures of wisdom and knowledge." (Colossians 2:3). But after his sin, he could no longer find joy in holiness, and he sought to hide from the presence of God.',
        },
        {
          'title': 'Chapter 3: Repentance',
          'subtitle': 'Sorrow for Sin and Turning to God',
          'content':
              'How shall a man be just with God? How shall the sinner be made righteous? It is only through Christ that we can be brought into harmony with God, with holiness; but how are we to come to Christ? Many are asking the same question as did the multitude on the day of Pentecost, when, convicted of sin, they cried out, "What shall we do?" The first word of Peter\'s answer was, "Repent." (Acts 2:38).\n\nRepentance includes sorrow for sin and a turning away from it. We shall not renounce sin unless we see its sinfulness; until we turn away from it in heart, there will be no real change in the life.',
        },
      ];
    }

    // Default chapters for other SOP books
    return [
      {
        'title': 'Introduction & Foundations',
        'subtitle': 'Truth for the End Time',
        'content':
            '${widget.book.description}\n\n"The light which God has given His people is not to be shut up within the churches that already know the truth. It is to be shed abroad into the dark places of the earth. Those who walk in the light are to diffuse light to those who are in darkness." (Testimonies for the Church, Vol. 9, p. 24).\n\nStudy this sacred volume prayerfully, allowing the Holy Spirit to impress eternal principles upon the mind and life.',
      },
      {
        'title': 'Principles for Christian Living',
        'subtitle': 'Walking in the Light of God\'s Word',
        'content':
            'As we advance in the study of "${widget.book.title}", we see the consistency of divine truth. God\'s purpose for His remnant people is that they shall stand before the universe as living witnesses of the power of the everlasting gospel to transform human nature.\n\nEvery soul who accepts Christ as a personal Saviour is called to be a co-worker with Him in the great harvest.',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final curChapter = _chapters[_selectedChapterIndex];
    final bgColor = _isNightMode ? const Color(0xFF1E1E1E) : const Color(0xFFFFFDF8);
    final textColor = _isNightMode ? const Color(0xFFE2E2E2) : const Color(0xFF232323);
    final titleColor = _isNightMode ? AppTheme.sacredGold : AppTheme.primaryBlue;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          // Switch to PDF View
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppTheme.sacredGold),
            icon: const Icon(Icons.picture_as_pdf, size: 16),
            label: const Text('PDF VIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
              final chapter = _chapters[_selectedChapterIndex];
              Share.share(
                '📖 ${widget.book.title}\n${chapter['title']}: ${chapter['subtitle']}\n\n'
                '${chapter['content']}\n\n— Read on Harvion SDA Ministry App',
              );
            },
          ),
          IconButton(
            tooltip: _isNightMode ? 'Light Reading' : 'Night Reading',
            icon: Icon(_isNightMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _isNightMode = !_isNightMode),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.text_fields),
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
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.primaryBlue),
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
                    'By ${widget.book.author}',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                  ),
                ],
              ),
            ),
            ...List.generate(_chapters.length, (i) {
              final ch = _chapters[i];
              final isSel = i == _selectedChapterIndex;
              return ListTile(
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: isSel ? AppTheme.sacredGold : Colors.grey.shade200,
                  child: Text('${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSel ? Colors.black : Colors.black87)),
                ),
                title: Text(
                  ch['title'] as String,
                  style: TextStyle(fontWeight: isSel ? FontWeight.bold : FontWeight.normal, fontSize: 13, color: isSel ? AppTheme.primaryGreen : Colors.black87),
                ),
                subtitle: Text(
                  ch['subtitle'] as String,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _selectedChapterIndex = i);
                },
              );
            }),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter Title
            Text(
              curChapter['title'] as String,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: titleColor),
            ),
            const SizedBox(height: 4),
            Text(
              curChapter['subtitle'] as String,
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey.shade600),
            ),
            const Divider(height: 24),

            // Content
            Text(
              curChapter['content'] as String,
              style: TextStyle(fontSize: _fontSize, height: 1.7, fontFamily: 'serif', color: textColor),
            ),
            const SizedBox(height: 36),

            // Next / Prev Chapter Navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_selectedChapterIndex > 0)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Previous Chapter', style: TextStyle(fontSize: 12)),
                    onPressed: () => setState(() => _selectedChapterIndex--),
                  )
                else
                  const SizedBox.shrink(),
                if (_selectedChapterIndex < _chapters.length - 1)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Next Chapter', style: TextStyle(fontSize: 12)),
                    onPressed: () => setState(() => _selectedChapterIndex++),
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

