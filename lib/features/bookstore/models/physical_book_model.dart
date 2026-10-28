class PhysicalBook {
  final String id;
  final String title;
  final String author;
  final String category;
  final String description;
  final double price; // in Ksh (Hard copy price)
  final double originalPrice;
  final String format; // Paperback, Hardcover, Soft Copy, Pocket Size, Both
  final String language; // English, Kiswahili, etc.
  final String coverImageUrl;
  final List<String> previewImages;
  final bool inStock;
  final int pageCount;
  final double rating;
  final String isbn;
  final bool isFeatured;
  final String? colporteurCommissionNote; // e.g., 'Earn 25% (Ksh 250) on delivery'
  final bool hasHardCopy;
  final bool hasSoftCopy;
  final double? softCopyPrice;
  final String? softCopyUrl;
  final bool isApproved;
  final String? sellerName;
  final String? sellerPhone;
  final String? sellerId;

  PhysicalBook({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.price,
    this.originalPrice = 0.0,
    this.format = 'Paperback',
    this.language = 'English',
    this.coverImageUrl = '',
    this.previewImages = const [],
    this.inStock = true,
    this.pageCount = 350,
    this.rating = 5.0,
    this.isbn = '978-0-8280',
    this.isFeatured = false,
    this.colporteurCommissionNote,
    this.hasHardCopy = true,
    this.hasSoftCopy = false,
    this.softCopyPrice,
    this.softCopyUrl,
    this.isApproved = true,
    this.sellerName,
    this.sellerPhone,
    this.sellerId,
  });

  bool get hasDiscount => originalPrice > price;

  factory PhysicalBook.fromJson(Map<String, dynamic> json, String documentId) {
    List<String> previews = [];
    if (json['previewImages'] != null) {
      previews = List<String>.from(json['previewImages'] as List);
    }

    return PhysicalBook(
      id: documentId,
      title: json['title'] as String? ?? 'Untitled Book',
      author: json['author'] as String? ?? 'Ellen G. White',
      category: json['category'] as String? ?? 'Spirit of Prophecy',
      description: json['description'] as String? ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      format: json['format'] as String? ?? 'Paperback',
      language: json['language'] as String? ?? 'English',
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      previewImages: previews,
      inStock: json['inStock'] as bool? ?? true,
      pageCount: json['pageCount'] as int? ?? 300,
      rating: (json['rating'] ?? 5.0).toDouble(),
      isbn: json['isbn'] as String? ?? '',
      isFeatured: json['isFeatured'] as bool? ?? false,
      colporteurCommissionNote: json['colporteurCommissionNote'] as String?,
      hasHardCopy: json['hasHardCopy'] as bool? ?? true,
      hasSoftCopy: json['hasSoftCopy'] as bool? ?? (json['format']?.toString().toLowerCase().contains('soft') ?? false),
      softCopyPrice: json['softCopyPrice'] != null ? (json['softCopyPrice'] as num).toDouble() : null,
      softCopyUrl: json['softCopyUrl'] as String?,
      isApproved: json['isApproved'] as bool? ?? true,
      sellerName: json['sellerName'] as String?,
      sellerPhone: json['sellerPhone'] as String?,
      sellerId: json['sellerId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'category': category,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'format': format,
      'language': language,
      'coverImageUrl': coverImageUrl,
      'previewImages': previewImages,
      'inStock': inStock,
      'pageCount': pageCount,
      'rating': rating,
      'isbn': isbn,
      'isFeatured': isFeatured,
      'colporteurCommissionNote': colporteurCommissionNote,
      'hasHardCopy': hasHardCopy,
      'hasSoftCopy': hasSoftCopy,
      'softCopyPrice': softCopyPrice,
      'softCopyUrl': softCopyUrl,
      'isApproved': isApproved,
      'sellerName': sellerName,
      'sellerPhone': sellerPhone,
      'sellerId': sellerId,
    };
  }

  static List<PhysicalBook> getSampleBooks() {
    return [
      PhysicalBook(
        id: 'sop_01',
        title: 'The Great Controversy',
        author: 'Ellen G. White',
        category: 'Spirit of Prophecy',
        description:
            'Traces the conflict between Christ and Satan from the destruction of Jerusalem through the Reformation to the close of Earth\'s history and the Earth made new. An essential book for our times.',
        price: 850.0,
        originalPrice: 1100.0,
        format: 'Hardcover & Soft Copy',
        hasHardCopy: true,
        hasSoftCopy: true,
        softCopyPrice: 350.0,
        softCopyUrl: 'https://m.egwwritings.org/en/book/132/toc',
        language: 'English',
        inStock: true,
        pageCount: 720,
        rating: 5.0,
        isbn: '978-1-58325-102-1',
        isFeatured: true,
        colporteurCommissionNote: 'Earn Ksh 200 per copy sold',
        coverImageUrl: 'https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/great_controversy.jpg',
      ),
      PhysicalBook(
        id: 'sop_02',
        title: 'The Desire of Ages',
        author: 'Ellen G. White',
        category: 'Spirit of Prophecy',
        description:
            'A devotional masterpiece presenting the life and ministry of Jesus Christ. Recognized globally as one of the most poignant spiritual biographies of Christ ever written.',
        price: 950.0,
        originalPrice: 1200.0,
        format: 'Hardcover & Soft Copy',
        hasHardCopy: true,
        hasSoftCopy: true,
        softCopyPrice: 350.0,
        softCopyUrl: 'https://m.egwwritings.org/en/book/130/toc',
        language: 'English',
        inStock: true,
        pageCount: 860,
        rating: 5.0,
        isbn: '978-0-8163-1815-5',
        isFeatured: true,
        colporteurCommissionNote: 'Earn Ksh 250 per copy sold',
        coverImageUrl: 'https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/desire_of_ages.jpg',
      ),
      PhysicalBook(
        id: 'sop_03',
        title: 'Steps to Christ (Hatua Kwa Kristo)',
        author: 'Ellen G. White',
        category: 'Spirit of Prophecy',
        description:
            'The classic handbook on how to experience true conversion, peace of heart, and daily walking with God. Pocket-sized and accessible in Kiswahili and English.',
        price: 350.0,
        originalPrice: 450.0,
        format: 'Pocket Size & Soft Copy',
        hasHardCopy: true,
        hasSoftCopy: true,
        softCopyPrice: 150.0,
        softCopyUrl: 'https://m.egwwritings.org/en/book/108/toc',
        language: 'English',
        inStock: true,
        pageCount: 160,
        rating: 4.9,
        isbn: '978-0-8280-0112-9',
        isFeatured: true,
        colporteurCommissionNote: 'Earn Ksh 100 per copy sold',
        coverImageUrl: 'https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/steps_to_christ.jpg',
      ),
      PhysicalBook(
        id: 'sop_04',
        title: 'The Ministry of Healing',
        author: 'Ellen G. White',
        category: 'Health & Temperance',
        description:
            'Comprehensive guidance on medical missionary work, the 8 natural laws of health, plant-based living, and how Jesus healed the sick in body and soul.',
        price: 750.0,
        originalPrice: 900.0,
        format: 'Paperback & Soft Copy',
        hasHardCopy: true,
        hasSoftCopy: true,
        softCopyPrice: 300.0,
        softCopyUrl: 'https://m.egwwritings.org/en/book/135/toc',
        language: 'English',
        inStock: true,
        pageCount: 540,
        rating: 4.9,
        isbn: '978-0-8280-0435-9',
        isFeatured: true,
        colporteurCommissionNote: 'Earn Ksh 180 per copy sold',
        coverImageUrl: 'https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/ministry_of_healing.jpg',
      ),
      PhysicalBook(
        id: 'sop_05',
        title: 'The Adventist Home',
        author: 'Ellen G. White',
        category: 'Christian Living & Family',
        description:
            'Heavenly counsel on marriage, parenting, home atmosphere, courtship, and creating a little heaven on earth within your family circle.',
        price: 700.0,
        originalPrice: 850.0,
        format: 'Paperback & Soft Copy',
        hasHardCopy: true,
        hasSoftCopy: true,
        softCopyPrice: 280.0,
        softCopyUrl: 'https://m.egwwritings.org/en/book/128/toc',
        language: 'English',
        inStock: true,
        pageCount: 560,
        rating: 5.0,
        isbn: '978-0-8280-0034-4',
        isFeatured: false,
        colporteurCommissionNote: 'Earn Ksh 170 per copy sold',
        coverImageUrl: 'https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/adventist_home.jpg',
      ),
      PhysicalBook(
        id: 'sop_06',
        title: 'Daniel and the Revelation',
        author: 'Uriah Smith',
        category: 'Evangelism & Prophecy',
        description:
            'Verse-by-verse exposition of the prophetic books of Daniel and Revelation, explaining sanctuary truth, prophetic timelines, and the Three Angels\' Messages.',
        price: 1100.0,
        originalPrice: 1400.0,
        format: 'Hardcover',
        hasHardCopy: true,
        hasSoftCopy: false,
        language: 'English',
        inStock: true,
        pageCount: 880,
        rating: 4.9,
        isbn: '978-1-87895-120-2',
        isFeatured: true,
        colporteurCommissionNote: 'Earn Ksh 280 per copy sold',
        coverImageUrl: 'https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/daniel_revelation.jpg',
      ),
      PhysicalBook(
        id: 'farm_01',
        title: 'Edenic Stewardship & Country Living',
        author: 'Alfredo Onuko',
        category: 'Farming & Country Living',
        description:
            'Practical guide on organic farming, restoring degraded soil, water conservation, and establishing self-supporting country outposts for ministry.',
        price: 600.0,
        originalPrice: 750.0,
        format: 'Paperback & Soft Copy',
        hasHardCopy: true,
        hasSoftCopy: true,
        softCopyPrice: 250.0,
        language: 'English',
        inStock: true,
        pageCount: 220,
        rating: 5.0,
        isbn: '978-9966-123-45-0',
        isFeatured: true,
        colporteurCommissionNote: 'Earn Ksh 150 per copy sold',
        coverImageUrl: 'https://storage.googleapis.com/vine-3e4ab.firebasestorage.app/books/edenic_stewardship.jpg',
      ),
    ];
  }
}
