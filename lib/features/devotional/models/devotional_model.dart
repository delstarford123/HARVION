class DailyDevotional {
  final String id;
  final String title;
  final String scriptureReference;
  final String scriptureText;
  final String commentary;
  final String author;
  final String prayerThought;
  final DateTime date;

  DailyDevotional({
    required this.id,
    required this.title,
    required this.scriptureReference,
    required this.scriptureText,
    required this.commentary,
    required this.author,
    required this.prayerThought,
    required this.date,
  });

  static DailyDevotional getTodaysDevotional() {
    return DailyDevotional(
      id: 'dev_today',
      title: 'Higher Than The Highest Thought',
      scriptureReference: 'Ephesians 3:20-21',
      scriptureText:
          'Now unto him that is able to do exceeding abundantly above all that we ask or think, according to the power that worketh in us, unto him be glory in the church by Christ Jesus throughout all ages, world without end. Amen.',
      commentary:
          'Higher than the highest human thought can reach is God\'s ideal for His children. Godliness—godlikeness—is the goal to be reached. Before the student there is opened a path of continual progress. He has an object to achieve, a standard to attain, that includes everything good, and pure, and noble.\n\nHe will advance as fast and as far as possible in every branch of true knowledge. But his efforts will be directed to objects as much higher than mere selfish and temporal interests as the heavens are higher than the earth.',
      author: 'Ellen G. White (Education, p. 18)',
      prayerThought:
          'Lord, elevate my thoughts today above earthly distractions. Grant me a character reflecting Your likeness, and anoint my hands to bless someone today in Jesus\' name. Amen.',
      date: DateTime.now(),
    );
  }

  static List<DailyDevotional> getRecentDevotionals() {
    return [
      getTodaysDevotional(),
      DailyDevotional(
        id: 'dev_yesterday',
        title: 'Peace in the Storm',
        scriptureReference: 'John 14:27',
        scriptureText:
            'Peace I leave with you, my peace I give unto you: not as the world giveth, give I unto you. Let not your heart be troubled, neither let it be afraid.',
        commentary:
            'The peace of Christ is a living, continuing presence in the soul. It is not freedom from struggle, but rest in the midst of conflict. When Christ abides within, the soul rises above the vexations and anxieties of life.',
        author: 'Ellen G. White (Desire of Ages, p. 336)',
        prayerThought:
            'Jesus, Prince of Peace, calm every troubled water in my heart today. I choose to trust in Your sovereignty.',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      DailyDevotional(
        id: 'dev_prev',
        title: 'Consecration Each Morning',
        scriptureReference: 'Romans 12:1',
        scriptureText:
            'I beseech you therefore, brethren, by the mercies of God, that ye present your bodies a living sacrifice, holy, acceptable unto God, which is your reasonable service.',
        commentary:
            'Consecrate yourself to God in the morning; make this your very first work. Let your prayer be, "Take me, O Lord, as wholly Thine. I lay all my plans at Thy feet. Use me today in Thy service. Abide with me, and let all my work be wrought in Thee." This is a daily matter.',
        author: 'Ellen G. White (Steps to Christ, p. 70)',
        prayerThought:
            'Father, I surrender all my plans into Your caring hands. Guide my steps throughout this day.',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}

