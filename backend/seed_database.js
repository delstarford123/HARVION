/**
 * HARVION - Firebase Firestore Complete Database Seeder
 * Populates the entire Firestore database for project: vine-3e4ab
 * Storage Bucket: gs://vine-3e4ab.firebasestorage.app
 */

const { db, storageBucket } = require("./firebaseAdmin");

const sampleBooks = [
  {
    title: "The Great Controversy",
    author: "Ellen G. White",
    category: "Spirit of Prophecy",
    description: "Traces the conflict between Christ and Satan from the destruction of Jerusalem through the Reformation to the close of Earth's history and the Earth made new.",
    price: 850.0,
    originalPrice: 1100.0,
    format: "Hardcover & Soft Copy",
    hasHardCopy: true,
    hasSoftCopy: true,
    softCopyPrice: 350.0,
    softCopyUrl: "https://m.egwwritings.org/en/book/132/toc",
    coverImageUrl: "https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/great_controversy.jpg",
    previewImages: [
      "https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/great_controversy_preview1.jpg",
      "https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/great_controversy_preview2.jpg"
    ],
    language: "English",
    inStock: true,
    pageCount: 720,
    rating: 5.0,
    isbn: "978-1-58325-102-1",
    isFeatured: true,
    colporteurCommissionNote: "Earn Ksh 200 per hard copy sold, Ksh 100 per soft copy",
  },
  {
    title: "The Desire of Ages",
    author: "Ellen G. White",
    category: "Spirit of Prophecy",
    description: "A devotional masterpiece presenting the life and ministry of Jesus Christ. Recognized globally as one of the most poignant spiritual biographies of Christ ever written.",
    price: 950.0,
    originalPrice: 1200.0,
    format: "Hardcover & Soft Copy",
    hasHardCopy: true,
    hasSoftCopy: true,
    softCopyPrice: 350.0,
    softCopyUrl: "https://m.egwwritings.org/en/book/130/toc",
    coverImageUrl: "https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/desire_of_ages.jpg",
    previewImages: [
      "https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/desire_preview1.jpg"
    ],
    language: "English",
    inStock: true,
    pageCount: 860,
    rating: 5.0,
    isbn: "978-0-8163-1815-5",
    isFeatured: true,
    colporteurCommissionNote: "Earn Ksh 250 per copy sold",
  },
  {
    title: "Steps to Christ (Hatua Kwa Kristo)",
    author: "Ellen G. White",
    category: "Spirit of Prophecy",
    description: "The classic handbook on how to experience true conversion, peace of heart, and daily walking with God. Pocket-sized and accessible in Kiswahili and English.",
    price: 350.0,
    originalPrice: 450.0,
    format: "Pocket Size & Soft Copy",
    hasHardCopy: true,
    hasSoftCopy: true,
    softCopyPrice: 150.0,
    softCopyUrl: "https://m.egwwritings.org/en/book/108/toc",
    coverImageUrl: "https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/steps_to_christ.jpg",
    previewImages: [],
    language: "English",
    inStock: true,
    pageCount: 160,
    rating: 4.9,
    isbn: "978-0-8280-0112-9",
    isFeatured: true,
    colporteurCommissionNote: "Earn Ksh 100 per copy sold",
  },
  {
    title: "The Ministry of Healing",
    author: "Ellen G. White",
    category: "Health & Temperance",
    description: "Comprehensive guidance on medical missionary work, the 8 natural laws of health, plant-based living, and how Jesus healed the sick in body and soul.",
    price: 750.0,
    originalPrice: 900.0,
    format: "Paperback & Soft Copy",
    hasHardCopy: true,
    hasSoftCopy: true,
    softCopyPrice: 300.0,
    softCopyUrl: "https://m.egwwritings.org/en/book/135/toc",
    coverImageUrl: "https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/ministry_of_healing.jpg",
    previewImages: [],
    language: "English",
    inStock: true,
    pageCount: 540,
    rating: 4.9,
    isbn: "978-0-8280-0435-9",
    isFeatured: true,
    colporteurCommissionNote: "Earn Ksh 180 per copy sold",
  },
  {
    title: "The Adventist Home",
    author: "Ellen G. White",
    category: "Christian Living & Family",
    description: "Heavenly counsel on marriage, parenting, home atmosphere, courtship, and creating a little heaven on earth within your family circle.",
    price: 700.0,
    originalPrice: 850.0,
    format: "Paperback & Soft Copy",
    hasHardCopy: true,
    hasSoftCopy: true,
    softCopyPrice: 280.0,
    softCopyUrl: "https://m.egwwritings.org/en/book/128/toc",
    coverImageUrl: "https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/adventist_home.jpg",
    previewImages: [],
    language: "English",
    inStock: true,
    pageCount: 560,
    rating: 5.0,
    isbn: "978-0-8280-0034-4",
    isFeatured: true,
    colporteurCommissionNote: "Earn Ksh 170 per copy sold",
  },
  {
    title: "Daniel and the Revelation",
    author: "Uriah Smith",
    category: "Evangelism & Prophecy",
    description: "Verse-by-verse exposition of the prophetic books of Daniel and Revelation, explaining sanctuary truth, prophetic timelines, and the Three Angels' Messages.",
    price: 1100.0,
    originalPrice: 1400.0,
    format: "Hardcover",
    hasHardCopy: true,
    hasSoftCopy: false,
    coverImageUrl: "https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/daniel_revelation.jpg",
    previewImages: [],
    language: "English",
    inStock: true,
    pageCount: 880,
    rating: 4.9,
    isbn: "978-1-87895-120-2",
    isFeatured: true,
    colporteurCommissionNote: "Earn Ksh 280 per copy sold",
  },
  {
    title: "Edenic Stewardship & Country Living",
    author: "Alfredo Onuko",
    category: "Farming & Country Living",
    description: "Practical guide on organic farming, restoring degraded soil, water conservation, and establishing self-supporting country outposts for ministry.",
    price: 600.0,
    originalPrice: 750.0,
    format: "Paperback & Soft Copy",
    hasHardCopy: true,
    hasSoftCopy: true,
    softCopyPrice: 250.0,
    coverImageUrl: "https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/edenic_stewardship.jpg",
    previewImages: [],
    language: "English",
    inStock: true,
    pageCount: 220,
    rating: 5.0,
    isbn: "978-9966-123-45-0",
    isFeatured: true,
    colporteurCommissionNote: "Earn Ksh 150 per copy sold",
  },
];

// Pillars of the Adventist Home
const sampleFamilyPillars = [
  {
    id: "pillar_marriage",
    title: "Christ-Centered Marriage",
    subtitle: "Sacred Covenant of Mutual Love and Unselfish Ministry",
    iconName: "favorite",
    colorHex: "0xFFE91E63",
    description: "Marriage was instituted by God in Eden and blessed by Jesus at Cana. When Christ dwells in the hearts of husband and wife, true oneness and sacrificial affection flourish.",
    egwQuote: "The family tie is the closest, the most tender and sacred, of any on earth. It was designed to be a blessing to mankind. And it is a blessing wherever the marriage covenant is entered into intelligently, in the fear of God, and with due consideration for its responsibilities.",
    egwSource: "The Adventist Home, p. 18",
    keyScriptures: [
      "Genesis 2:24",
      "Ephesians 5:22-33",
      "Colossians 3:18-19",
      "Hebrews 13:4"
    ],
    actionSteps: [
      "Guard the sacred circle of your home against outside intrusions.",
      "Cultivate the art of daily appreciation and verbal thankfulness.",
      "Never allow bedtime without reconciling any grievance or hurt feelings.",
      "Pray together as husband and wife every morning and evening."
    ],
    videoLink: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    isPublished: true,
    orderIndex: 1,
  },
  {
    id: "pillar_family_altar",
    title: "The Family Altar & Daily Worship",
    subtitle: "Surrounding the Home with an Invincible Wall of Prayer",
    iconName: "auto_stories",
    colorHex: "0xFF3F51B5",
    description: "Morning and evening worship is the golden thread that binds the household to heaven. Keep family worship brief, lively, cheerful, and spiritually refreshing.",
    egwQuote: "Like the patriarchs of old, those who profess to love God should erect an altar to the Lord wherever they pitch their tent... Fathers and mothers should often lift up their hearts to God in humble supplication for themselves and their children.",
    egwSource: "The Adventist Home, p. 318",
    keyScriptures: [
      "Deuteronomy 6:6-9",
      "Joshua 24:15",
      "Psalm 92:1-2",
      "Acts 10:2"
    ],
    actionSteps: [
      "Keep worship to 10-15 minutes so children stay engaged and eager.",
      "Incorporate uplifting sacred singing, musical instruments, and scripture reciting.",
      "Let every family member participate in praying and reading.",
      "Share missionary reports, answers to prayer, and nature object lessons."
    ],
    videoLink: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    isPublished: true,
    orderIndex: 2,
  },
  {
    id: "pillar_parenting",
    title: "Biblical Parenting & Character",
    subtitle: "Training Hearts for Eternity with Gentleness and Firmness",
    iconName: "child_care",
    colorHex: "0xFFFF9800",
    description: "Children are the heritage of the Lord. Parents are heaven's ambassadors to mold characters fit for the heavenly courts through love, patience, and unwavering discipline.",
    egwQuote: "The greatest work of parents is to educate and train their children for the future, immortal life. They should look upon them as sacred trusts to be returned to the Creator with interest.",
    egwSource: "Child Guidance, p. 21",
    keyScriptures: [
      "Proverbs 22:6",
      "Ephesians 6:4",
      "Colossians 3:21",
      "2 Timothy 3:15"
    ],
    actionSteps: [
      "Govern with calm authority; never discipline in anger or irritation.",
      "Teach useful labor and practical skills from early childhood.",
      "Protect your children's minds from worldly media and corrupting companionship.",
      "Point their eyes to Christ's gentle example in everyday situations."
    ],
    videoLink: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    isPublished: true,
    orderIndex: 3,
  },
  {
    id: "pillar_health",
    title: "Health & Nutrition in the Home",
    subtitle: "Wholesome Living, Clean Diet, and Natural Remedies",
    iconName: "spa",
    colorHex: "0xFF4CAF50",
    description: "The body is the temple of the Holy Spirit. Wholesome, plant-based food, pure water, fresh air, exercise, and temperance foster mental clarity and spiritual responsiveness.",
    egwQuote: "Grains, fruits, nuts, and vegetables constitute the diet chosen for us by our Creator. These foods, prepared in as simple and natural a manner as possible, are the most healthful and nourishing.",
    egwSource: "The Ministry of Healing, p. 296",
    keyScriptures: [
      "1 Corinthians 6:19-20",
      "1 Corinthians 10:31",
      "Genesis 1:29",
      "3 John 1:2"
    ],
    actionSteps: [
      "Transition toward a nutritious, whole-food, plant-based family table.",
      "Maintain regular hours for meals and avoid between-meal snacking.",
      "Drink abundant fresh water between meals and exercise outdoors daily.",
      "Introduce simple natural hydrotherapy and herbal health principles."
    ],
    videoLink: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    isPublished: true,
    orderIndex: 4,
  },
  {
    id: "pillar_courtship",
    title: "Sacred Courtship & Youth Guidance",
    subtitle: "Entering Lifelong Alliances with Prayer and Discernment",
    iconName: "diversity_1",
    colorHex: "0xFF9C27B0",
    description: "Youth must be guided to choose life partners who genuinely love God, cherish truth, and share the high calling of the Three Angels' Messages.",
    egwQuote: "If men and women are in the habit of praying twice a day before they contemplate marriage, they should pray four times a day when such a step is anticipated.",
    egwSource: "The Adventist Home, p. 70",
    keyScriptures: [
      "2 Corinthians 6:14",
      "Amos 3:3",
      "Proverbs 31:30",
      "1 Thessalonians 4:3-5"
    ],
    actionSteps: [
      "Seek godly counsel from parents and spiritual mentors before committing.",
      "Evaluate character, industriousness, and temper in ordinary life settings.",
      "Maintain purity and avoid emotional infatuation that clouds biblical judgment.",
      "Ensure unity of prophetic faith and divine calling before proposing."
    ],
    videoLink: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    isPublished: true,
    orderIndex: 5,
  },
  {
    id: "pillar_hospitality",
    title: "Hospitality & Outpost Ministry",
    subtitle: "Making Your Home an Open Refuge of Light and Compassion",
    iconName: "volunteer_activism",
    colorHex: "0xFF009688",
    description: "An Adventist home should be a light in the community, welcoming the weary, sharing spiritual food, and ministering to physical and emotional needs.",
    egwQuote: "Our homes should be a place of refuge for the tempted youth. Many are standing at the parting of the ways... If we would show an interest in them, invite them to our homes, we might turn their feet into the right path.",
    egwSource: "The Adventist Home, p. 458",
    keyScriptures: [
      "Romans 12:13",
      "Hebrews 13:2",
      "1 Peter 4:9",
      "Matthew 25:35-40"
    ],
    actionSteps: [
      "Open your home for Sabbath fellowship and warm Christian hospitality.",
      "Distribute literature and healthy food baskets to neighbors in need.",
      "Host neighborhood Bible studies and health cooking demonstrations.",
      "Train children to be gracious, kind, and respectful to all guests."
    ],
    videoLink: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    isPublished: true,
    orderIndex: 6,
  },
];

// Sermons, Teachings & Livestreams
const sampleSermons = [
  {
    title: "The Three Angels' Messages in Modern Times",
    speaker: "Pastor J. Ouko",
    description: "A prophetic examination of Revelation 14:6-12, the everlasting gospel, the fall of Babylon, and the mark of the beast.",
    mediaUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    videoSourceType: "youtube",
    isLiveStream: false,
    type: "video",
    seriesName: "Prophecy & Revival",
    durationSeconds: 2700,
    price: 0.0,
    publishedDate: new Date(),
  },
  {
    title: "LIVE: Sabbath Morning Divine Service & Revival Session",
    speaker: "Pastor Alfredo Onuko",
    description: "Join us live for an inspiring Sabbath worship experience and deep study of the Sanctuary truth.",
    mediaUrl: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    videoSourceType: "youtube",
    isLiveStream: true,
    type: "video",
    seriesName: "Sabbath Live Broadcast",
    durationSeconds: 3600,
    price: 0.0,
    publishedDate: new Date(),
  },
  {
    title: "Edenic Health & Natural Immunity - Google Drive Archive",
    speaker: "Dr. Mary Mwangi",
    description: "Practical lifestyle medicine, reversing chronic ailments through plant nutrition and the 8 natural laws of health.",
    mediaUrl: "https://drive.google.com/file/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs/view?usp=sharing",
    videoSourceType: "google_drive",
    isLiveStream: false,
    type: "video",
    seriesName: "Health Ministry",
    durationSeconds: 3120,
    price: 0.0,
    publishedDate: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
  },
];

// Camp Meeting Locations & Colporteur Field Outposts
const sampleCampMeetingLocations = [
  {
    colporteurName: "Alfredo Onuko",
    phone: "0745090990",
    eventName: "Central Kenya Conference Camp Meeting",
    boothLocation: "Literature Evangelism Tent #4 (Near Maxwell Book Stand)",
    city: "Nairobi",
    description: "Come get your Spirit of Prophecy sets, The Great Controversy, health guides, and Edenic farming handbooks! Hard copies and instant soft copies available.",
    hasHardCopy: true,
    hasSoftCopy: true,
    activeFrom: new Date(),
    activeUntil: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
    latitude: -1.2933,
    longitude: 36.8123,
    status: "Active Now",
  },
  {
    colporteurName: "Sister Grace Wanjiru",
    phone: "0711223344",
    eventName: "Western Kenya Camp Meeting & Evangelistic Outpost",
    boothLocation: "Exhibition Pavillion Booth B12, Kisumu Grounds",
    city: "Kisumu",
    description: "Special discounts for church quarterly bulk orders, missionary tracts, and children's Bedtime Stories sets.",
    hasHardCopy: true,
    hasSoftCopy: true,
    activeFrom: new Date(),
    activeUntil: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000),
    latitude: -0.1022,
    longitude: 34.7617,
    status: "Active Now",
  },
];

// Digital Tracts
const sampleTracts = [
  {
    id: "tract_01",
    title: "The Great Hope: Peace in an Anxious World",
    subtitle: "Finding eternal security when everything is shaken",
    category: "Salvation",
    summary: "A gentle presentation of Christ's love and forgiveness for troubled souls.",
    fullText: "In a world overwhelmed by pandemics, economic distress, and spiritual confusion, where can peace be found? Jesus said: 'Peace I leave with you, my peace I give unto you: not as the world giveth, give I unto you. Let not your heart be troubled, neither let it be afraid.' (John 14:27).\n\nReal peace is not the absence of trouble, but the presence of Christ in the soul. You do not need to clean yourself up before coming to Jesus; come as you are, for He is the Great Physician.",
    keyVerse: "John 14:27; Matthew 11:28-30",
    shareCardQuote: "\"Come unto me, all ye that labour and are heavy laden, and I will give you rest.\" — Jesus Christ",
    shareCount: 420,
  },
  {
    id: "tract_02",
    title: "The Sabbath: God's Memorial of Love & Creation",
    subtitle: "Why the 7th Day Still Matters for Modern Disciples",
    category: "Sabbath",
    summary: "A biblical walk from Genesis to Revelation highlighting God's holy seventh-day Sabbath.",
    fullText: "Before sin entered our world, God gave mankind two sacred Edenic institutions: Marriage and the Sabbath (Genesis 2:1-3).\n\nIn the Ten Commandments written by the very finger of God, the Fourth Commandment begins with the word: 'Remember the Sabbath day, to keep it holy.' (Exodus 20:8). In the New Earth, God's redeemed family will still gather from one Sabbath to another to worship the King of kings (Isaiah 66:22-23).",
    keyVerse: "Genesis 2:1-3; Exodus 20:8-11; Mark 2:27-28",
    shareCardQuote: "\"The Sabbath was made for man, and not man for the Sabbath.\" — Mark 2:27-28",
    shareCount: 890,
  },
  {
    id: "tract_03",
    title: "What Happens One Second After Death?",
    subtitle: "Comfort and Truth from God's Word on the Resurrection",
    category: "Prophecy",
    summary: "Clears the fog on death, soul sleep, and the glorious promise of the resurrection at Christ's Second Coming.",
    fullText: "The Bible consistently compares death to an unconscious sleep (Ecclesiastes 9:5-6, John 11:11-14). The dead know not anything until the resurrection morning when the trumpet sounds and Christ awakens the sleeping saints.",
    keyVerse: "Ecclesiastes 9:5; 1 Thessalonians 4:16-17",
    shareCardQuote: "\"The dead praise not the LORD, neither any that go down into silence.\" — Psalm 115:17",
    shareCount: 654,
  },
];

const sampleDevotionals = [
  {
    title: "Higher Than The Highest Thought",
    scriptureReference: "Ephesians 3:20-21",
    scriptureText: "Now unto him that is able to do exceeding abundantly above all that we ask or think, according to the power that worketh in us, unto him be glory in the church by Christ Jesus throughout all ages, world without end. Amen.",
    commentary: "Higher than the highest human thought can reach is God's ideal for His children. Godliness—godlikeness—is the goal to be reached. Before the student there is opened a path of continual progress.",
    author: "Ellen G. White (Education, p. 18)",
    prayerThought: "Lord, elevate my thoughts today above earthly distractions. Grant me a character reflecting Your likeness in Jesus' name. Amen.",
    date: new Date(),
  },
  {
    title: "Peace in the Storm",
    scriptureReference: "John 14:27",
    scriptureText: "Peace I leave with you, my peace I give unto you: not as the world giveth, give I unto you. Let not your heart be troubled, neither let it be afraid.",
    commentary: "The peace of Christ is a living, continuing presence in the soul. It is not freedom from struggle, but rest in the midst of conflict.",
    author: "Ellen G. White (Desire of Ages, p. 336)",
    prayerThought: "Jesus, Prince of Peace, calm every troubled water in my heart today. I choose to trust in Your sovereignty.",
    date: new Date(Date.now() - 24 * 60 * 60 * 1000),
  },
];

async function seedWholeDatabase() {
  console.log("==================================================");
  console.log("🌱 STARTING HARVION FULL DATABASE SEEDING...");
  console.log(`📦 Project: vine-3e4ab | Storage: ${storageBucket}`);
  console.log("==================================================");

  try {
    // 1. Seed Bookstore Catalog
    console.log(`Writing ${sampleBooks.length} books to 'bookstore_items'...`);
    for (const book of sampleBooks) {
      await db.collection("bookstore_items").add({
        ...book,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
    }
    console.log("✅ Bookstore catalog successfully seeded.");

    // 2. Seed Family Life Pillars
    console.log(`Writing ${sampleFamilyPillars.length} pillars to 'family_pillars'...`);
    for (const pillar of sampleFamilyPillars) {
      await db.collection("family_pillars").doc(pillar.id).set(pillar, { merge: true });
    }
    console.log("✅ Family Life Pillars of Adventist Home seeded.");

    // 3. Seed Sermons & Livestreams
    console.log(`Writing ${sampleSermons.length} sermons/livestreams to 'sermons'...`);
    for (const s of sampleSermons) {
      await db.collection("sermons").add(s);
    }
    console.log("✅ Sermons and Livestream sessions seeded.");

    // 4. Seed Camp Meeting & Colporteur Spots
    console.log(`Writing ${sampleCampMeetingLocations.length} locations to 'camp_meeting_locations'...`);
    for (const loc of sampleCampMeetingLocations) {
      await db.collection("camp_meeting_locations").add(loc);
    }
    console.log("✅ Camp Meeting & Field Colporteur spots seeded.");

    // 5. Seed Devotionals & Daily Quotes
    console.log(`Writing ${sampleDevotionals.length} devotionals to 'devotionals' & 'daily_quotes'...`);
    for (const dev of sampleDevotionals) {
      await db.collection("devotionals").add(dev);
      await db.collection("daily_quotes").add({
        text: dev.commentary,
        reference: dev.author,
        displayDate: dev.date,
      });
    }
    console.log("✅ Devotionals & daily quotes seeded.");

    // 6. Seed Digital Tracts
    console.log(`Writing ${sampleTracts.length} tracts to 'digital_tracts'...`);
    for (const t of sampleTracts) {
      await db.collection("digital_tracts").doc(t.id).set(t, { merge: true });
    }
    console.log("✅ Digital evangelism tracts seeded.");

    // 7. Seed Sample Seller Request (Pending Approval)
    console.log("Writing initial pending book seller request to 'book_seller_requests'...");
    await db.collection("book_seller_requests").add({
      sellerName: "Brother David Kimani",
      sellerPhone: "+254 722 999 888",
      sellerEmail: "dkimani@gmail.com",
      conference: "Central Kenya Conference",
      bookTitle: "Victory Over Temptation in the Last Days",
      author: "David Kimani",
      category: "Christian Living & Family",
      format: "Hardcover & Soft Copy",
      proposedPrice: 500.0,
      description: "A practical spiritual guide on overcoming habitual sin through the power of Christ.",
      coverImageUrl: "https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/sample_cover.jpg",
      status: "pending",
      submittedAt: new Date(),
    });

    // 8. Seed Admin Notification
    console.log("Writing admin notification for new book seller request...");
    await db.collection("admin_notifications").add({
      title: "New Book Seller Approval Request",
      message: "Brother David Kimani submitted 'Victory Over Temptation' for approval.",
      type: "seller_request",
      isRead: false,
      createdAt: new Date(),
    });

    // 9. Seed Faith Testimonies
    console.log("Writing initial testimonies of faith & literature miracles...");
    const sampleTestimonies = [
      {
        title: "A Great Controversy Book Delivered in the Hospital",
        author: "Sister Grace Wanjiku",
        location: "Nakuru, Kenya",
        category: "Literature Evangelism",
        story: "While visiting my sister at the regional hospital, I felt impressed by the Holy Spirit to leave a copy of The Great Controversy on the bedside table. A nurse on night shift picked it up, read through the chapters on the Sabbath and the sanctuary, and two months later she was baptized at our camp meeting! Praise the Lord for silent messengers.",
        mediaUrl: "",
        mediaType: "text",
        amenCount: 42,
        createdAt: new Date(),
      },
      {
        title: "Miraculous Healing from Chronic Gastritis with NEWSTART",
        author: "Elder Joshua Omondi",
        location: "Kisumu, Kenya",
        category: "Health & Healing",
        story: "After 7 years of severe acid reflux and pain, our local literature evangelist gave me the Ministry of Healing and recipes for an all-plant based diet with regular charcoal poultices and clean water routines. In three weeks the pain subsided completely. Truly God's natural remedies work wonders!",
        mediaUrl: "",
        mediaType: "text",
        amenCount: 38,
        createdAt: new Date(),
      },
      {
        title: "TikTok Live Sermon Led a Young Soul to the Sabbath Truth",
        author: "Pastor Samuel Baraza",
        location: "Nairobi, Kenya",
        category: "Conversion & Truth",
        story: "We hosted a TikTok live study on Daniel 2 and Revelation 14. A university student who was confused by modern doctrines joined the stream and asked why we worship on the Seventh day. After four weeks of live Q&A sessions on the app, he surrendered his life to Christ and joined the baptismal class.",
        mediaUrl: "https://www.tiktok.com/@harvionsda/live",
        mediaType: "tiktok",
        amenCount: 56,
        createdAt: new Date(),
      },
    ];

    for (const test of sampleTestimonies) {
      await db.collection("testimonies").add(test);
    }
    console.log("✅ Faith testimonies seeded.");

    console.log("==================================================");
    console.log("🎉 ALL HARVION DATABASE COLLECTIONS SUCCESSFULLY SEEDED!");
    console.log("==================================================");
  } catch (error) {
    console.error("Seeding error:", error);
  }
}

if (require.main === module) {
  seedWholeDatabase().then(() => process.exit(0));
}

module.exports = { seedWholeDatabase };
