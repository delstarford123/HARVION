import 'package:flutter/material.dart';

class FamilyPillar {
  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final String colorHex;
  final String description;
  final String egwQuote;
  final String egwSource;
  final List<String> keyScriptures;
  final List<String> actionSteps;
  final String? videoLink; // YouTube, Google Drive, or direct link
  final bool isPublished;
  final int orderIndex;

  FamilyPillar({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.colorHex,
    required this.description,
    required this.egwQuote,
    required this.egwSource,
    required this.keyScriptures,
    required this.actionSteps,
    this.videoLink,
    this.isPublished = true,
    this.orderIndex = 0,
  });

  IconData get iconData {
    switch (iconName) {
      case 'favorite':
      case 'favorite_border':
        return Icons.favorite;
      case 'diversity_1':
      case 'marriage':
        return Icons.diversity_1;
      case 'child_care':
      case 'parenting':
        return Icons.child_care;
      case 'group':
      case 'youth':
        return Icons.group;
      case 'auto_stories':
      case 'worship':
        return Icons.auto_stories;
      case 'spa':
      case 'health':
        return Icons.spa;
      case 'volunteer_activism':
      case 'hospitality':
        return Icons.volunteer_activism;
      default:
        return Icons.family_restroom;
    }
  }

  Color get color {
    try {
      if (colorHex.startsWith('0x')) {
        return Color(int.parse(colorHex));
      } else if (colorHex.startsWith('#')) {
        return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      }
    } catch (_) {}
    return const Color(0xFF1E3A8A); // fallback primary blue
  }

  factory FamilyPillar.fromJson(Map<String, dynamic> json, String documentId) {
    List<String> scriptures = [];
    if (json['keyScriptures'] != null) {
      scriptures = List<String>.from(json['keyScriptures'] as List);
    }

    List<String> steps = [];
    if (json['actionSteps'] != null) {
      steps = List<String>.from(json['actionSteps'] as List);
    }

    return FamilyPillar(
      id: documentId,
      title: json['title'] as String? ?? 'Adventist Home Pillar',
      subtitle: json['subtitle'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'favorite',
      colorHex: json['colorHex'] as String? ?? '0xFF1E3A8A',
      description: json['description'] as String? ?? '',
      egwQuote: json['egwQuote'] as String? ?? '',
      egwSource: json['egwSource'] as String? ?? 'The Adventist Home',
      keyScriptures: scriptures,
      actionSteps: steps,
      videoLink: json['videoLink'] as String?,
      isPublished: json['isPublished'] as bool? ?? true,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'iconName': iconName,
      'colorHex': colorHex,
      'description': description,
      'egwQuote': egwQuote,
      'egwSource': egwSource,
      'keyScriptures': keyScriptures,
      'actionSteps': actionSteps,
      'videoLink': videoLink,
      'isPublished': isPublished,
      'orderIndex': orderIndex,
    };
  }

  static List<FamilyPillar> getMockPillars() {
    return [
      FamilyPillar(
        id: 'pillar_marriage',
        title: 'Christ-Centered Marriage',
        subtitle: 'Sacred Covenant of Mutual Love and Unselfish Ministry',
        iconName: 'favorite',
        colorHex: '0xFFE91E63',
        description:
            'Marriage was instituted by God in Eden and blessed by Jesus at Cana. When Christ dwells in the hearts of husband and wife, true oneness and sacrificial affection flourish.',
        egwQuote:
            'The family tie is the closest, the most tender and sacred, of any on earth. It was designed to be a blessing to mankind. And it is a blessing wherever the marriage covenant is entered into intelligently, in the fear of God, and with due consideration for its responsibilities.',
        egwSource: 'The Adventist Home, p. 18',
        keyScriptures: [
          'Genesis 2:24',
          'Ephesians 5:22-33',
          'Colossians 3:18-19',
          'Hebrews 13:4',
        ],
        actionSteps: [
          'Guard the sacred circle of your home against outside intrusions.',
          'Cultivate the art of daily appreciation and verbal thankfulness.',
          'Never allow bedtime without reconciling any grievance or hurt feelings.',
          'Pray together as husband and wife every morning and evening.',
        ],
        videoLink: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        orderIndex: 1,
      ),
      FamilyPillar(
        id: 'pillar_family_altar',
        title: 'The Family Altar & Daily Worship',
        subtitle: 'Surrounding the Home with an Invincible Wall of Prayer',
        iconName: 'auto_stories',
        colorHex: '0xFF3F51B5',
        description:
            'Morning and evening worship is the golden thread that binds the household to heaven. Keep family worship brief, lively, cheerful, and spiritually refreshing.',
        egwQuote:
            'Like the patriarchs of old, those who profess to love God should erect an altar to the Lord wherever they pitch their tent... Fathers and mothers should often lift up their hearts to God in humble supplication for themselves and their children.',
        egwSource: 'The Adventist Home, p. 318',
        keyScriptures: [
          'Deuteronomy 6:6-9',
          'Joshua 24:15',
          'Psalm 92:1-2',
          'Acts 10:2',
        ],
        actionSteps: [
          'Keep worship to 10-15 minutes so children stay engaged and eager.',
          'Incorporate uplifting sacred singing, musical instruments, and scripture reciting.',
          'Let every family member participate in praying and reading.',
          'Share missionary reports, answers to prayer, and nature object lessons.',
        ],
        videoLink: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        orderIndex: 2,
      ),
      FamilyPillar(
        id: 'pillar_parenting',
        title: 'Biblical Parenting & Character',
        subtitle: 'Training Hearts for Eternity with Gentleness and Firmness',
        iconName: 'child_care',
        colorHex: '0xFFFF9800',
        description:
            'Children are the heritage of the Lord. Parents are heaven\'s ambassadors to mold characters fit for the heavenly courts through love, patience, and unwavering discipline.',
        egwQuote:
            'The greatest work of parents is to educate and train their children for the future, immortal life. They should look upon them as sacred trusts to be returned to the Creator with interest.',
        egwSource: 'Child Guidance, p. 21',
        keyScriptures: [
          'Proverbs 22:6',
          'Ephesians 6:4',
          'Colossians 3:21',
          '2 Timothy 3:15',
        ],
        actionSteps: [
          'Govern with calm authority; never discipline in anger or irritation.',
          'Teach useful labor and practical skills from early childhood.',
          'Protect your children\'s minds from worldly media and corrupting companionship.',
          'Point their eyes to Christ\'s gentle example in everyday situations.',
        ],
        videoLink: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        orderIndex: 3,
      ),
      FamilyPillar(
        id: 'pillar_health',
        title: 'Health & Nutrition in the Home',
        subtitle: 'Wholesome Living, Clean Diet, and Natural Remedies',
        iconName: 'spa',
        colorHex: '0xFF4CAF50',
        description:
            'The body is the temple of the Holy Spirit. Wholesome, plant-based food, pure water, fresh air, exercise, and temperance foster mental clarity and spiritual responsiveness.',
        egwQuote:
            'Grains, fruits, nuts, and vegetables constitute the diet chosen for us by our Creator. These foods, prepared in as simple and natural a manner as possible, are the most healthful and nourishing.',
        egwSource: 'The Ministry of Healing, p. 296',
        keyScriptures: [
          '1 Corinthians 6:19-20',
          '1 Corinthians 10:31',
          'Genesis 1:29',
          '3 John 1:2',
        ],
        actionSteps: [
          'Transition toward a nutritious, whole-food, plant-based family table.',
          'Maintain regular hours for meals and avoid between-meal snacking.',
          'Drink abundant fresh water between meals and exercise outdoors daily.',
          'Introduce simple natural hydrotherapy and herbal health principles.',
        ],
        videoLink: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        orderIndex: 4,
      ),
      FamilyPillar(
        id: 'pillar_courtship',
        title: 'Sacred Courtship & Youth Guidance',
        subtitle: 'Entering Lifelong Alliances with Prayer and Discernment',
        iconName: 'diversity_1',
        colorHex: '0xFF9C27B0',
        description:
            'Youth must be guided to choose life partners who genuinely love God, cherish truth, and share the high calling of the Three Angels\' Messages.',
        egwQuote:
            'If men and women are in the habit of praying twice a day before they contemplate marriage, they should pray four times a day when such a step is anticipated.',
        egwSource: 'The Adventist Home, p. 70',
        keyScriptures: [
          '2 Corinthians 6:14',
          'Amos 3:3',
          'Proverbs 31:30',
          '1 Thessalonians 4:3-5',
        ],
        actionSteps: [
          'Seek godly counsel from parents and spiritual mentors before committing.',
          'Evaluate character, industriousness, and temper in ordinary life settings.',
          'Maintain purity and avoid emotional infatuation that clouds biblical judgment.',
          'Ensure unity of prophetic faith and divine calling before proposing.',
        ],
        videoLink: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        orderIndex: 5,
      ),
      FamilyPillar(
        id: 'pillar_hospitality',
        title: 'Hospitality & Outpost Ministry',
        subtitle: 'Making Your Home an Open Refuge of Light and Compassion',
        iconName: 'volunteer_activism',
        colorHex: '0xFF009688',
        description:
            'An Adventist home should be a light in the community, welcoming the weary, sharing spiritual food, and ministering to physical and emotional needs.',
        egwQuote:
            'Our homes should be a place of refuge for the tempted youth. Many are standing at the parting of the ways... If we would show an interest in them, invite them to our homes, we might turn their feet into the right path.',
        egwSource: 'The Adventist Home, p. 458',
        keyScriptures: [
          'Romans 12:13',
          'Hebrews 13:2',
          '1 Peter 4:9',
          'Matthew 25:35-40',
        ],
        actionSteps: [
          'Open your home for Sabbath fellowship and warm Christian hospitality.',
          'Distribute literature and healthy food baskets to neighbors in need.',
          'Host neighborhood Bible studies and health cooking demonstrations.',
          'Train children to be gracious, kind, and respectful to all guests.',
        ],
        videoLink: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        orderIndex: 6,
      ),
    ];
  }
}
