class DigitalTract {
  final String id;
  final String title;
  final String subtitle;
  final String category; // 'Prophecy', 'Salvation', 'Sabbath', 'Health', 'Sanctuary'
  final String summary;
  final String fullText;
  final String keyVerse;
  final String shareCardQuote;
  final int shareCount;

  DigitalTract({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.summary,
    required this.fullText,
    required this.keyVerse,
    required this.shareCardQuote,
    this.shareCount = 142,
  });

  String generateShareMessage() {
    return "🕊️ *$title* 🕊️\n"
        "_${subtitle}_\n\n"
        "📖 *Scripture Anchor:* $keyVerse\n\n"
        "✨ *Key Insight:*\n$shareCardQuote\n\n"
        "Read the complete evangelistic tract & explore truth on the Harvion app:\n"
        "https://harvion.app/tracts/$id";
  }

  static List<DigitalTract> getSampleTracts() {
    return [
      DigitalTract(
        id: 'tract_01',
        title: 'The Great Hope: Peace in an Anxious World',
        subtitle: 'Finding eternal security when everything is shaken',
        category: 'Salvation',
        summary:
            'A gentle, compassionate presentation of Christ\'s love and forgiveness for troubled souls.',
        fullText:
            'In a world overwhelmed by pandemics, political turmoil, economic distress, and spiritual confusion, where can peace be found? Jesus said: "Peace I leave with you, my peace I give unto you: not as the world giveth, give I unto you. Let not your heart be troubled, neither let it be afraid." (John 14:27).\n\nReal peace is not the absence of trouble, but the presence of Christ in the soul. You do not need to clean yourself up before coming to Jesus; come as you are, for He is the Great Physician.',
        keyVerse: 'John 14:27; Matthew 11:28-30',
        shareCardQuote:
            '"Come unto me, all ye that labour and are heavy laden, and I will give you rest." — Jesus Christ',
        shareCount: 420,
      ),
      DigitalTract(
        id: 'tract_02',
        title: 'The Sabbath: God\'s Memorial of Love & Creation',
        subtitle: 'Why the 7th Day Still Matters for Modern Disciples',
        category: 'Sabbath',
        summary:
            'A biblical walk from Genesis to Revelation highlighting the blessing of God\'s holy seventh-day Sabbath.',
        fullText:
            'Before sin entered our world, God gave mankind two sacred Edenic institutions: Marriage and the Sabbath (Genesis 2:1-3). The Sabbath was not given only to the Jewish nation; it was made for all humanity at Creation, thousands of years before Abraham or Moses.\n\nIn the Ten Commandments written by the very finger of God, the Fourth Commandment begins with the word: "Remember the Sabbath day, to keep it holy." (Exodus 20:8). In the New Earth, God\'s redeemed family will still gather from one Sabbath to another to worship the King of kings (Isaiah 66:22-23).',
        keyVerse: 'Genesis 2:1-3; Exodus 20:8-11; Mark 2:27-28',
        shareCardQuote:
            '"The Sabbath was made for man, and not man for the Sabbath: Therefore the Son of man is Lord also of the Sabbath." — Mark 2:27-28',
        shareCount: 890,
      ),
      DigitalTract(
        id: 'tract_03',
        title: 'What Happens One Second After Death?',
        subtitle: 'Comfort and Truth from God\'s Word on the Resurrection',
        category: 'Prophecy',
        summary:
            'Clears the fog on death, soul sleep, and the glorious promise of the resurrection at Christ\'s Second Coming.',
        fullText:
            'Death is an enemy, but Scripture calls it a peaceful sleep. Jesus referred to the death of His friend Lazarus as sleep (John 11:11-14). Ecclesiastes 9:5 states: "The living know that they shall die: but the dead know not any thing."\n\nDeath is not a phantom spirit floating in ethereal realms; it is an unconscious pause until Jesus calls His loved ones from their dusty beds at the Last Trumpet! (1 Thessalonians 4:16-17).',
        keyVerse: '1 Thessalonians 4:16-17; Ecclesiastes 9:5,10',
        shareCardQuote:
            '"For the Lord Himself shall descend from heaven with a shout... and the dead in Christ shall rise first." — 1 Thess 4:16',
        shareCount: 650,
      ),
      DigitalTract(
        id: 'tract_04',
        title: 'The 8 Laws of Health (NEWSTART)',
        subtitle: 'God\'s Natural Prescription for Vibrant Living',
        category: 'Health',
        summary:
            'Nutrition, Exercise, Water, Sunlight, Temperance, Air, Rest, and Trust in God.',
        fullText:
            'Our bodies are temples of the Holy Ghost (1 Corinthians 6:19). God desires us to be vibrant and healthy so our minds can hear His voice clearly. The 8 natural remedies—NEWSTART—cost nothing yet possess power to reverse chronic lifestyle illness.',
        keyVerse: '3 John 1:2; 1 Corinthians 10:31',
        shareCardQuote:
            '"Pure air, sunlight, abstemiousness, rest, exercise, proper use of water, trust in divine power—these are the true remedies." — Ministry of Healing, p. 127',
        shareCount: 512,
      ),
    ];
  }
}
