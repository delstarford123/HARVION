import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../bookstore/models/physical_book_model.dart';
import '../bookstore/book_detail_screen.dart';

class HealthPrinciplesScreen extends StatelessWidget {
  const HealthPrinciplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final laws = [
      {
        'law': 'Nutrition',
        'acronym': 'N',
        'color': Colors.orange,
        'icon': Icons.restaurant,
        'scripture': 'Genesis 1:29; 1 Corinthians 10:31',
        'egw':
            'Grains, fruits, nuts, and vegetables constitute the diet chosen for us by our Creator. These foods, prepared in as simple and natural a manner as possible, are the most healthful and nourishing.',
        'egwRef': 'The Ministry of Healing, p. 296',
        'habits': [
          'Choose unrefined whole plant foods over ultra-processed items.',
          'Eat a substantial breakfast and a lighter evening meal.',
          'Avoid snacking between meals to allow proper stomach rest (5 hours).',
          'Practice seasonal eating with locally grown organic vegetables.',
        ],
      },
      {
        'law': 'Exercise',
        'acronym': 'E',
        'color': Colors.blue,
        'icon': Icons.directions_walk,
        'scripture': 'Genesis 2:15; 1 Timothy 4:8',
        'egw':
            'There is no exercise that can take the place of walking. By it the circulation of the blood is greatly improved. Walking in the fresh air is one of the most effective tonics.',
        'egwRef': 'Testimonies for the Church, vol. 3, p. 78',
        'habits': [
          'Take a brisk 30-45 minute walk in open nature or country paths every day.',
          'Incorporate gardening, soil digging, and active manual labor.',
          'Take short movement breaks after sitting at work or study for an hour.',
          'Deep diaphragmatic breathing while walking oxygenates every cell.',
        ],
      },
      {
        'law': 'Water',
        'acronym': 'W',
        'color': Colors.lightBlue,
        'icon': Icons.water_drop,
        'scripture': 'John 4:14; Revelation 22:17',
        'egw':
            'In health and in sickness, pure water is one of heaven\'s choicest blessings. Its proper use promotes health. It is the beverage which God provided to quench the thirst of animals and man.',
        'egwRef': 'The Ministry of Healing, p. 237',
        'habits': [
          'Drink 6-8 glasses of pure, filtered water daily between meals.',
          'Drink 2 glasses of warm water upon rising to flush kidneys and colon.',
          'Avoid drinking large quantities of cold liquid with meals (dilutes digestive juices).',
          'Use hydrotherapy (contrast hot and cold water treatments) to stimulate immune white blood cells.',
        ],
      },
      {
        'law': 'Sunlight',
        'acronym': 'S',
        'color': Colors.amber,
        'icon': Icons.wb_sunny,
        'scripture': 'Ecclesiastes 11:7; Malachi 4:2',
        'egw':
            'If the rooms were bathed in sunlight, sickness and disease would be significantly diminished. Sunlight is one of nature\'s most healing agencies.',
        'egwRef': 'The Ministry of Healing, p. 276',
        'habits': [
          'Spend 15-30 minutes daily in morning sunlight to synthesize natural Vitamin D.',
          'Open bedroom and house curtains widely to let ultraviolet rays disinfect living quarters.',
          'Sunlight elevates serotonin, combats depression, and normalizes circadian sleep rhythms.',
        ],
      },
      {
        'law': 'Temperance',
        'acronym': 'T',
        'color': Colors.purple,
        'icon': Icons.balance,
        'scripture': '1 Corinthians 9:25; Galatians 5:22-23',
        'egw':
            'True temperance teaches us to dispense entirely with everything hurtful and to use judiciously that which is healthful.',
        'egwRef': 'Patriarchs and Prophets, p. 562',
        'habits': [
          'Total abstinence from alcohol, tobacco, addictive substances, and caffeinated stimulants.',
          'Wise moderation in good things: work, screen time, exercise, and food intake.',
          'Guard the avenues of the soul: mind what you watch, listen to, and read.',
        ],
      },
      {
        'law': 'Air',
        'acronym': 'A',
        'color': Colors.teal,
        'icon': Icons.air,
        'scripture': 'Genesis 2:7; Job 33:4',
        'egw':
            'Air is the free blessing of heaven, calculated to electrify the whole system. The lungs need pure air, which invigorates the vital organs and purifies the blood.',
        'egwRef': 'Testimonies for the Church, vol. 1, p. 701',
        'habits': [
          'Keep windows cracked at night for continuous fresh air circulation.',
          'Practice 10 deep belly breaths outdoors in the morning.',
          'Seek country and garden environments free from urban smoke and smog.',
        ],
      },
      {
        'law': 'Rest',
        'acronym': 'R',
        'color': Colors.indigo,
        'icon': Icons.bedtime,
        'scripture': 'Exodus 20:8-11; Mark 6:31',
        'egw':
            'Sleep, nature\'s sweet restorer, invigorates the weary body and prepares it for the next day\'s duties. God gave the holy Sabbath as a weekly sanctuary in time for complete rest.',
        'egwRef': 'Child Guidance, p. 342',
        'habits': [
          'Retire early by 9:30 or 10:00 PM (hours before midnight provide deepest restorative rest).',
          'Aim for 7 to 8 hours of uninterrupted sleep in a completely dark, quiet room.',
          'Keep the Seventh-day Sabbath holy: set aside secular commerce and electronic noise for communion with God and family.',
        ],
      },
      {
        'law': 'Trust in God',
        'acronym': 'T',
        'color': Colors.red,
        'icon': Icons.favorite,
        'scripture': 'Proverbs 3:5-8; Psalm 103:2-3',
        'egw':
            'Nothing tends more to promote health of body and of soul than does a spirit of gratitude and praise. It is a positive duty to resist melancholy, discontented thoughts and feelings.',
        'egwRef': 'The Ministry of Healing, p. 251',
        'habits': [
          'Start and finish every day on your knees in thanksgiving and surrender.',
          'Cast every anxiety, fear, and grief onto Jesus through persistent prayer.',
          'Peace of conscience and forgiveness through Christ is the greatest healer of the human nervous system.',
        ],
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('The 8 Laws of Health (NEWSTART)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Intro Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.spa, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'God\'s Natural Healing Principles',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '"Pure air, sunlight, abstemiousness, rest, exercise, proper use of water, trust in divine power—these are the true remedies." — Ellen G. White',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Explore The 8 Laws',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 12),

            // Laws Expansion Tiles / Cards
            ...laws.map((law) {
              final color = law['color'] as Color;
              final icon = law['icon'] as IconData;
              final habits = law['habits'] as List<String>;

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.15),
                      child: Icon(icon, color: color),
                    ),
                    title: Text(
                      '${law['acronym']} - ${law['law']}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      law['scripture'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E7),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.sacredGold.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '"${law['egw']}"',
                                    style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, height: 1.4),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '— ${law['egwRef']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                      color: AppTheme.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Daily Practical Habits:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(height: 6),
                            ...habits.map((h) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle_outline, size: 16, color: AppTheme.primaryGreen),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(h, style: const TextStyle(fontSize: 13, height: 1.3)),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),

            // Tie-in Bookstore health books banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book, color: AppTheme.primaryBlue, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Read "The Ministry of Healing"',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Get the original physical book with delivery to your church depot.',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () {
                      final sampleBooks = PhysicalBook.getSampleBooks();
                      final healthBook = sampleBooks.firstWhere(
                        (b) => b.id == 'health_01',
                        orElse: () => sampleBooks.first,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => BookDetailScreen(book: healthBook)),
                      );
                    },
                    child: const Text('ORDER', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

