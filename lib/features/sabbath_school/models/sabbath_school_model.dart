class DailyLessonDay {
  final String dayName; // 'Sabbath Afternoon', 'Sunday', 'Monday', etc.
  final String title;
  final String scriptureReading;
  final String content;
  final List<String> discussionQuestions;

  DailyLessonDay({
    required this.dayName,
    required this.title,
    required this.scriptureReading,
    required this.content,
    this.discussionQuestions = const [],
  });
}

class SabbathSchoolLesson {
  final int lessonNumber;
  final String quarterlyTheme;
  final String title;
  final String memoryVerse;
  final String memoryVerseRef;
  final String dateRange;
  final List<DailyLessonDay> dailyReadings;

  SabbathSchoolLesson({
    required this.lessonNumber,
    required this.quarterlyTheme,
    required this.title,
    required this.memoryVerse,
    required this.memoryVerseRef,
    required this.dateRange,
    required this.dailyReadings,
  });

  static SabbathSchoolLesson getCurrentQuarterLesson() {
    return getLesson(4);
  }

  static SabbathSchoolLesson getLesson(int number) {
    final all = getAllTwentyLessons();
    return all.firstWhere(
      (l) => l.lessonNumber == number,
      orElse: () => all.first,
    );
  }

  static List<SabbathSchoolLesson> getAllTwentyLessons() {
    return [
      _createLesson(
        1,
        "God's Mission, My Mission",
        "The God Who Reaches Out",
        "Then the Lord God called to Adam and said to him, 'Where are you?'",
        "Genesis 3:9 (NKJV)",
        "Week 1",
        "From the garden of Eden after the fall, God took the initiative to pursue lost humanity. His mission is rooted in infinite love. As literature evangelists and believers, we participate in His divine pursuit of every human heart.",
        [
          "Why is mission fundamentally God's initiative rather than merely human effort?",
          "How can we reflect God's searching love in our neighborhoods this week?",
        ],
      ),
      _createLesson(
        2,
        "God's Mission, My Mission",
        "To God Be the Glory",
        "Declaring, 'The hour of His judgment has come; and worship Him who made heaven and earth.'",
        "Revelation 14:7 (NKJV)",
        "Week 2",
        "In the final conflict, God's character is vindicated before the watching universe. Giving glory to God is not merely singing songs; it involves a transformed character and consecrated living.",
        [
          "In what ways does our daily lifestyle reflect God's glory to non-believers?",
          "How does understanding the judgment give us boldness instead of fear?",
        ],
      ),
      _createLesson(
        3,
        "The Three Angels' Messages",
        "The Gospel Preached to Every Nation",
        "Go therefore and make disciples of all the nations, baptizing them in the name of the Father and of the Son and of the Holy Spirit.",
        "Matthew 28:19 (NKJV)",
        "Week 3",
        "The three angels' messages are the everlasting gospel tailored for earth's final hour. The printed page and digital literature serve as silent messengers reaching hearts behind closed doors.",
        [
          "Why is literature evangelism described as one of the most effective closing works?",
          "How can modern technology accelerate the gospel to every nation, tribe, and tongue?",
        ],
      ),
      _createLesson(
        4,
        "The Three Angels' Messages",
        "The Everlasting Gospel in the End Time",
        "Then I saw another angel flying in the midst of heaven, having the everlasting gospel to preach to those who dwell on the earth.",
        "Revelation 14:6 (NKJV)",
        "Week 4",
        "The first angel's message is an urgent call to return to the everlasting gospel. It is centered wholly in Jesus Christ and His righteousness by faith.",
        [
          "Why must every prophetic sermon be anchored in Christ's cross and righteousness?",
          "How does the Sabbath test loyalty to the Creator in the last days?",
        ],
      ),
      _createLesson(
        5,
        "The Three Angels' Messages",
        "Fear God and Give Glory to Him",
        "Let us hear the conclusion of the whole matter: Fear God and keep His commandments, for this is man's all.",
        "Ecclesiastes 12:13 (NKJV)",
        "Week 5",
        "Biblical godly fear is reverential awe and submission. In a culture driven by casual irreverence, God calls His remnant to worship in the beauty of holiness.",
        [
          "What is the difference between holy reverence and slavish fear?",
          "How do our dietary and temperance choices relate to giving glory to God?",
        ],
      ),
      _createLesson(
        6,
        "The Great Controversy",
        "The Hour of His Judgment Has Come",
        "For God will bring every work into judgment, including every secret thing, whether good or evil.",
        "Ecclesiastes 12:14 (NKJV)",
        "Week 6",
        "The investigative judgment reveals to angels and unfallen worlds that God is just in saving every repentant believer who clings to Christ's blood.",
        [
          "Why is the pre-advent judgment good news for the people of God?",
          "How does Jesus act as both our Sacrifice and our High Priest?",
        ],
      ),
      _createLesson(
        7,
        "The Great Controversy",
        "Worship the Creator & The Sabbath Memorial",
        "Remember the Sabbath day, to keep it holy. Six days you shall labor and do all your work.",
        "Exodus 20:8-9 (NKJV)",
        "Week 7",
        "The Sabbath is the golden clasp that binds human hearts to their Creator. It stands as an enduring monument against the deception of evolution and self-sufficiency.",
        [
          "How does Sabbath rest restore emotional, mental, and physical well-being?",
          "Why will the Sabbath be the focal test of allegiance in the final crisis?",
        ],
      ),
      _createLesson(
        8,
        "The Great Controversy",
        "Babylon Is Fallen: A Call to Separation",
        "And another angel followed, saying, 'Babylon is fallen, is fallen, that great city, because she has made all nations drink of the wine of the wrath of her fornication.'",
        "Revelation 14:8 (NKJV)",
        "Week 8",
        "Babylon represents religious confusion and the substitution of human traditions for the clear commandments of Scripture. God's call is to come out and stand in truth.",
        [
          "What modern spiritual deceptions correspond to Babylon's wine?",
          "How can we present this warning with tears of Christlike love rather than harshness?",
        ],
      ),
      _createLesson(
        9,
        "The Final Crisis",
        "The Mark of the Beast & The Warning",
        "If anyone worships the beast and his image, and receives his mark on his forehead or on his hand, he himself shall also drink of the wine of the wrath of God.",
        "Revelation 14:9-10 (NKJV)",
        "Week 9",
        "The third angel sounds the most solemn warning recorded in Holy Scripture. It unmasks the counterfeit sabbath and urges endurance in keeping God's commandments.",
        [
          "How do we prepare our hearts today so we will stand firm in the final crisis?",
          "What is the faith of Jesus, and how do we cultivate it daily?",
        ],
      ),
      _createLesson(
        10,
        "The Final Crisis",
        "Here Is the Patience of the Saints",
        "Here is the patience of the saints; here are those who keep the commandments of God and the faith of Jesus.",
        "Revelation 14:12 (NKJV)",
        "Week 10",
        "Patience is endurance under trials. The end-time believers do not surrender in persecution because their faith is anchored entirely in their Saviour.",
        [
          "How do present trials prepare us for the great time of trouble?",
          "What does it mean practically to keep the faith of Jesus?",
        ],
      ),
      _createLesson(
        11,
        "The Remnant & Prophecy",
        "The Seal of the Living God",
        "Do not harm the earth, the sea, or the trees till we have sealed the servants of our God on their foreheads.",
        "Revelation 7:3 (NKJV)",
        "Week 11",
        "The seal of God is settled in the truth, both intellectually and spiritually, so that God's people cannot be moved. The holy Sabbath is His sign of sanctification.",
        [
          "What is the connection between the Holy Spirit and the seal of God?",
          "How does Sabbath observance act as a seal of loyalty to the Creator?",
        ],
      ),
      _createLesson(
        12,
        "Health & Temperance",
        "NEWSTART: The Right Arm of the Message",
        "Beloved, I pray that you may prosper in all things and be in health, just as your soul prospers.",
        "3 John 1:2 (NKJV)",
        "Week 12",
        "God's health laws—Nutrition, Exercise, Water, Sunlight, Temperance, Air, Rest, and Trust in God—are gifts designed to keep mind and body pure temples for the Holy Spirit.",
        [
          "Why did Ellen G. White call medical missionary work the 'right arm' of the message?",
          "Which NEWSTART principle do you need to incorporate more faithfully this week?",
        ],
      ),
      _createLesson(
        13,
        "The Blessed Hope",
        "The Triumphant Church & The Second Coming",
        "Looking for the blessed hope and glorious appearing of our great God and Savior Jesus Christ.",
        "Titus 2:13 (NKJV)",
        "Week 13",
        "The Second Coming is the grand climax of human history. Every eye shall see Him, the dead in Christ will rise, and pain, sickness, and sorrow will be no more.",
        [
          "How does the promise of Christ's return affect your daily priorities?",
          "What must we do to ensure our lamps are filled with oil for the Bridegroom?",
        ],
      ),
      _createLesson(
        14,
        "The Book of Daniel",
        "Prophetic Foundations from Babylon to Eternity",
        "And in the days of these kings the God of heaven will set up a kingdom which shall never be destroyed.",
        "Daniel 2:44 (NKJV)",
        "Week 14",
        "Daniel 2, 7, and 8 provide the bedrock of biblical prophecy. Through world empires to the stone cut out without hands, God proves His sovereign oversight of human destiny.",
        [
          "How does biblical prophecy give us certainty in times of global instability?",
          "Why is the historicist method of prophetic interpretation the biblical standard?",
        ],
      ),
      _createLesson(
        15,
        "Sanctuary & Salvation",
        "The Heavenly Sanctuary & Christ's Priesthood",
        "We have such a High Priest, who is seated at the right hand of the throne of the Majesty in the heavens.",
        "Hebrews 8:1 (NKJV)",
        "Week 15",
        "The earthly sanctuary was a shadow of heavenly realities. In 1844, Jesus entered the Most Holy Place to begin the cleansing of the sanctuary.",
        [
          "What assurance does Christ's continuous intercession provide you?",
          "How does the Day of Atonement call for soul-searching and heart consecration?",
        ],
      ),
      _createLesson(
        16,
        "Christian Stewardship",
        "Stewardship of Talents, Time & Literature",
        "Moreover it is required in stewards that one be found faithful.",
        "1 Corinthians 4:2 (NKJV)",
        "Week 16",
        "Everything we possess belongs to God. When we invest our resources in literature evangelism and ministry, we lay up eternal treasure in heaven.",
        [
          "What talents has God entrusted to you that can be used for His cause?",
          "How does systematic benevolence strengthen the worldwide mission of the church?",
        ],
      ),
      _createLesson(
        17,
        "Family & Home",
        "The Christian Home: An Edenic Outpost",
        "As for me and my house, we will serve the Lord.",
        "Joshua 24:15 (NKJV)",
        "Week 17",
        "The family is God's foundational institution. A well-ordered, loving Christian home exerts a far more powerful influence than any sermon preached from the pulpit.",
        [
          "How can we maintain meaningful family worship in a fast-paced digital world?",
          "What practical steps can parents take to guard the avenues of the soul for their children?",
        ],
      ),
      _createLesson(
        18,
        "Spiritual Warfare",
        "Putting on the Whole Armor of God",
        "Put on the whole armor of God, that you may be able to stand against the wiles of the devil.",
        "Ephesians 6:11 (NKJV)",
        "Week 18",
        "Our battle is not against flesh and blood, but against principalities and spiritual hosts of wickedness. Clothed in Christ's armor, we are more than conquerors.",
        [
          "How do we wield the Sword of the Spirit (the Word of God) in moments of temptation?",
          "Why is prayer called the lifeline in spiritual warfare?",
        ],
      ),
      _createLesson(
        19,
        "The Holy Spirit",
        "The Holy Spirit & The Promise of Latter Rain",
        "Ask the Lord for rain in the time of the latter rain. The Lord will make flashing clouds; He will give them showers of rain.",
        "Zechariah 10:1 (NKJV)",
        "Week 19",
        "The latter rain will empower the Loud Cry of Revelation 18, ripening the harvest for the coming of Christ. We must seek the daily baptism of the Holy Spirit now.",
        [
          "What conditions are necessary before the Holy Spirit can fall in latter rain power?",
          "How can we cultivate unity of spirit in our local churches?",
        ],
      ),
      _createLesson(
        20,
        "Eternity & Hope",
        "The Earth Made New & The New Jerusalem",
        "Now I saw a new heaven and a new earth, for the first heaven and the first earth had passed away.",
        "Revelation 21:1 (NKJV)",
        "Week 20",
        "God will wipe away every tear. Sin will be forever banished, and the redeemed will dwell in the immediate presence of their King for all eternity.",
        [
          "What aspects of the earth made new do you long for most?",
          "How does keeping eternity in view change how we handle disappointments today?",
        ],
      ),
    ];
  }

  static SabbathSchoolLesson _createLesson(
    int num,
    String quarterlyTheme,
    String title,
    String memoryVerse,
    String memoryVerseRef,
    String dateRange,
    String weeklyOverview,
    List<String> discussionQuestions,
  ) {
    final days = [
      DailyLessonDay(
        dayName: 'Sabbath Afternoon',
        title: 'Introduction & Memory Verse',
        scriptureReading: memoryVerseRef,
        content:
            '$weeklyOverview\n\nStudy the memory verse deeply this week and meditate upon its implications for personal holiness and global literature evangelism.',
        discussionQuestions: discussionQuestions,
      ),
      DailyLessonDay(
        dayName: 'Sunday',
        title: 'Biblical Foundation & Context',
        scriptureReading: 'Psalm 119:105; 2 Timothy 3:16-17',
        content:
            'When we examine the biblical context of $title, we discover that God never leaves His people without clear light. His Word is an unshakeable lamp unto our feet. Every counsel given through the Spirit of Prophecy aligns in total harmony with the sacred canon.',
        discussionQuestions: [
          'How does the Holy Spirit guide our understanding as we open the scriptures with prayer?',
        ],
      ),
      DailyLessonDay(
        dayName: 'Monday',
        title: 'The Great Controversy Theme',
        scriptureReading: 'Genesis 3:15; Revelation 12:7-11',
        content:
            'Behind every earthly trial and religious struggle lies the great cosmic conflict between Christ and Satan. In $title, we see God exposing the adversary\'s counterfeits and establishing His faithful followers upon the Rock of Ages.',
        discussionQuestions: [
          'How does keeping the cosmic conflict in perspective help us overcome discouragement?',
        ],
      ),
      DailyLessonDay(
        dayName: 'Tuesday',
        title: 'Practical Application in Daily Life',
        scriptureReading: 'James 1:22-25; Romans 12:1-2',
        content:
            'The knowledge of divine truth is meant to bear fruit in holy living. In our homes, workplaces, and community outposts, $title translates into Christlike benevolence, honesty in commerce, and unswerving loyalty to God\'s moral law.',
        discussionQuestions: [
          'What is one practical change you can make in your routine based on this study?',
        ],
      ),
      DailyLessonDay(
        dayName: 'Wednesday',
        title: 'Prophetic Light for the Remnant',
        scriptureReading: 'Amos 3:7; Revelation 19:10',
        content:
            'God has blessed the Seventh-day Adventist movement with the Spirit of Prophecy to illuminate the path to the Heavenly City. In connection with $title, Sister White wrote that those who stand in truth will shine as lights amidst moral darkness.',
        discussionQuestions: [
          'How does the prophetic gift safeguard the church from modern philosophical deceptions?',
        ],
      ),
      DailyLessonDay(
        dayName: 'Thursday',
        title: 'Evangelism & Literature Colportage',
        scriptureReading: 'Isaiah 52:7; Romans 10:14-15',
        content:
            'Truth received must be truth shared. Every lesson on $title is a mandate to go forth with the printed page, digital tracts, and health consultations to win souls for Christ while probation still lingers.',
        discussionQuestions: [
          'Whom can you share a book or spiritual tract with before this Sabbath concludes?',
        ],
      ),
      DailyLessonDay(
        dayName: 'Friday',
        title: 'Further Thought & Class Discussion',
        scriptureReading: 'Philippians 4:8-9; Jude 1:24-25',
        content:
            'As we conclude this week\'s study on $title, let us review the memory verse ($memoryVerseRef) and surrender our hearts anew to the Master. Now unto Him that is able to keep you from falling, and to present you faultless before the presence of His glory with exceeding joy!',
        discussionQuestions: discussionQuestions,
      ),
    ];

    return SabbathSchoolLesson(
      lessonNumber: num,
      quarterlyTheme: quarterlyTheme,
      title: title,
      memoryVerse: memoryVerse,
      memoryVerseRef: memoryVerseRef,
      dateRange: dateRange,
      dailyReadings: days,
    );
  }
}
