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
  final int stockCount;
  final int weightGrams;
  final String? distributionHub;
  final String? publisher;

  PhysicalBook({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.description,
    required this.price,
    this.originalPrice = 0.0,
    this.format = 'Hardcover',
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
    this.stockCount = 25,
    this.weightGrams = 500,
    this.distributionHub,
    this.publisher,
  });

  bool get hasDiscount => originalPrice > price;

  factory PhysicalBook.fromJson(Map<String, dynamic> json, String documentId) {
    List<String> previews = [];
    if (json['previewImages'] != null) {
      previews = List<String>.from(json['previewImages'] as List);
    }

    final stock = json['stockCount'] as int? ?? 25;

    return PhysicalBook(
      id: documentId,
      title: json['title'] as String? ?? 'Untitled Book',
      author: json['author'] as String? ?? 'Ellen G. White',
      category: json['category'] as String? ?? 'Spirit of Prophecy',
      description: json['description'] as String? ?? '',
      price: (json['price'] ?? 0).toDouble(),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      format: json['format'] as String? ?? 'Hardcover',
      language: json['language'] as String? ?? 'English',
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      previewImages: previews,
      inStock: (json['inStock'] as bool? ?? true) && stock > 0,
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
      stockCount: stock,
      weightGrams: json['weightGrams'] as int? ?? 500,
      distributionHub: json['distributionHub'] as String?,
      publisher: json['publisher'] as String?,
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
      'stockCount': stockCount,
      'weightGrams': weightGrams,
      'distributionHub': distributionHub,
      'publisher': publisher,
    };
  }

  static List<PhysicalBook> getSampleBooks() {
    return [];
  }
}
