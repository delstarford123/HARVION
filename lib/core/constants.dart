class AppConstants {
  // 🚀 Prevents this class from being instantiated by mistake
  AppConstants._();

  // ==========================================
  // 📱 APP INFORMATION
  // ==========================================
  static const String appName = 'HARVION';
  static const String appVersion = '2.0.0-PRO';
  static const String organizationName = 'Harvion Ministry';

  // ==========================================
  // 👨‍💻 DEVELOPER & CONTACT DETAILS
  // ==========================================
  static const String developerName = 'Alfredo Onuko';
  static const String developerBio =
      'A passionate young minister, teacher, and creative dedicated to sharing truth, '
      'inspiring growth, and building lives through faith and practical knowledge. '
      'Committed to empowering communities through spiritual understanding and organic farming.';

  static const String contactEmail = 'afredoonuko@gmail.com';
  static const String contactPhone = '0745090990';
  static const String fellowshipLink =
      'https://chat.whatsapp.com/J8Lg4qCKyVqALdtDlXGClh?mode=gi_t';

  // ==========================================
  // ⚠️ MESSAGES & ALERTS
  // ==========================================
  static const String networkError = 'Please check your internet connection.';
  static const String genericError = 'Something went wrong. Please try again.';
  static const String offlineModeActive =
      'You are currently offline. Showing saved content.';

  // ==========================================
  // 📚 CATEGORIES (SDA & Literature Evangelism)
  // ==========================================
  static const List<String> bookstoreCategories = [
    'Spirit of Prophecy',
    'Bible Study & Sabbath School',
    'Health & Temperance',
    'Christian Living & Family',
    'Evangelism & Prophecy',
    'Children & Youth',
    'Farming & Country Living',
  ];

  // Legacy alias for existing tabs
  static const List<String> libraryCategories = bookstoreCategories;

  // Book Formats & Languages
  static const List<String> bookFormats = [
    'Paperback',
    'Hardcover',
    'Pocket Size',
    'Digital (PDF)',
  ];

  static const List<String> bookLanguages = [
    'English',
    'Kiswahili',
    'Luganda',
    'Dholuo',
  ];

  // Delivery & Payment
  static const List<String> paymentMethods = [
    'M-Pesa (Mobile Money)',
    'Credit / Debit Card',
    'Cash on Delivery / Church Pickup',
  ];

  static const List<String> sdaDistributionHubs = [
    'Nairobi Central SDA Church Depot',
    'Maxwell Adventist Media & Book Centre',
    'Newlife SDA Church Distribution Station',
    'Kisumu Central SDA Depot',
    'Mombasa Central SDA Book Depot',
    'Direct Doorstep Delivery (Rider)',
  ];

  // Organic Farming Categories
  static const List<String> farmingCategories = [
    'Soil Health & Management',
    'Crop Improvement',
    'Pest & Disease Control',
    'Plant Tissue Culture',
    'Water & Irrigation',
  ];

  // ==========================================
  // 🗄️ DATABASE & CLOUD CONSTANTS (Crucial for Firebase!)
  // ==========================================
  // Firebase Collections
  static const String colDailyQuotes = 'daily_quotes';
  static const String colSermons = 'sermons';
  static const String colFarmingGuides = 'farming_guides'; // Used for PDFs
  static const String colFarmingArticles =
      'farming_articles'; // Used for Text Articles
  static const String colHealthArticles = 'health_articles';
  static const String colFamilyArticles = 'family_articles';
  static const String colEducationResources = 'education_resources';
  static const String colFitnessGuides = 'fitness_guides';
  static const String colBookstore = 'bookstore_items';
  static const String colOrders = 'orders';
  static const String colPrayerRequests = 'prayer_requests';
  static const String colChurches = 'churches_directory';
  static const String colRecipes = 'healthy_recipes';
  static const String colDigitalTracts = 'digital_tracts';
  static const String colColporteurs = 'colporteurs';

  // Hive Local Storage Boxes
  static const String boxOfflineQueue = 'offline_queue';
  static const String boxSavedArticles = 'saved_articles';
  static const String boxCart = 'cart_items';
  static const String boxWishlist = 'wishlist_items';
  static const String boxSabbathNotes = 'sabbath_notes';
  static const String boxTestimoniesOffline = 'testimonies_offline';

  // ==========================================
  // 🖼️ ASSET PATHS & APIS
  // ==========================================
  static const String profileImagePath = 'assets/images/profile.png';
  static const String defaultCoverImage = 'assets/images/default_cover.png';

  // Backend / Database Endpoints
  static const String backendApiUrl = 'http://localhost:5000/api';
  static const String backendProductionUrl =
      'https://harvion.delstarfordworks.co.ke/api';
}
