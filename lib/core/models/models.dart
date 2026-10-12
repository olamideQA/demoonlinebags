import 'package:intl/intl.dart';

class Category {
  final String id;
  final String name;
  final String slug;
  final String type; // 'bags', 'shoes', 'accessories'
  final String? description;
  final String? imageUrl;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    this.description,
    this.imageUrl,
    this.sortOrder = 0,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      type: json['type'] as String? ?? 'bags',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class Collection {
  final String id;
  final String name;
  final String slug;
  final String? tagline;
  final String? description;
  final String? coverImageUrl;
  final bool isFeatured;

  const Collection({
    required this.id,
    required this.name,
    required this.slug,
    this.tagline,
    this.description,
    this.coverImageUrl,
    this.isFeatured = false,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      tagline: json['tagline'] as String?,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }
}

class ProductVariant {
  final String id;
  final String productId;
  final String variantType; // 'color', 'size', 'hardware'
  final String name;
  final String? colorHex;
  final int stockQuantity;
  final double priceAdjustment;
  final String? sku;

  const ProductVariant({
    required this.id,
    required this.productId,
    required this.variantType,
    required this.name,
    this.colorHex,
    this.stockQuantity = 5,
    this.priceAdjustment = 0.0,
    this.sku,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      variantType: json['variant_type'] as String? ?? 'color',
      name: json['name'] as String? ?? '',
      colorHex: json['color_hex'] as String?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 5,
      priceAdjustment: (json['price_adjustment'] as num?)?.toDouble() ?? 0.0,
      sku: json['sku'] as String?,
    );
  }
}

class Product {
  final String id;
  final String title;
  final String slug;
  final String? categoryId;
  final String? collectionId;
  final String productType; // 'bag', 'shoe', 'set'
  final String? subCategory;
  final double basePrice;
  final double? salePrice;
  final String currency;
  final String? shortDescription;
  final String? description;
  final List<String> images;
  final String primaryImage;
  final String? videoUrl;
  final String? material;
  final String? dimensionsCm;
  final double? strapDropCm;
  final double? heelHeightCm;
  final String? heelType;
  final String? closureType;
  final String? compartmentsInfo;
  final String? careInstructions;
  final bool isFeatured;
  final bool isBestseller;
  final bool isNewArrival;
  final int stockQuantity;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final List<ProductVariant> variants;

  const Product({
    required this.id,
    required this.title,
    required this.slug,
    this.categoryId,
    this.collectionId,
    required this.productType,
    this.subCategory,
    required this.basePrice,
    this.salePrice,
    this.currency = 'NGN',
    this.shortDescription,
    this.description,
    required this.images,
    required this.primaryImage,
    this.videoUrl,
    this.material,
    this.dimensionsCm,
    this.strapDropCm,
    this.heelHeightCm,
    this.heelType,
    this.closureType,
    this.compartmentsInfo,
    this.careInstructions,
    this.isFeatured = false,
    this.isBestseller = false,
    this.isNewArrival = true,
    this.stockQuantity = 10,
    this.rating = 5.0,
    this.reviewCount = 0,
    this.tags = const [],
    this.variants = const [],
  });

  static bool _isVideoFile(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final clean = url.split('?').first.toLowerCase();
    return clean.endsWith('.mp4') ||
        clean.endsWith('.webm') ||
        clean.endsWith('.mov') ||
        clean.endsWith('.m4v');
  }

  String? get effectiveVideoUrl {
    if (videoUrl != null && videoUrl!.trim().isNotEmpty) {
      return videoUrl!.trim();
    }
    for (final img in images) {
      if (_isVideoFile(img)) return img.trim();
    }
    return null;
  }

  bool get hasVideo => effectiveVideoUrl != null;

  List<String> get photoImages {
    final photos = images.where((u) => !_isVideoFile(u)).toList();
    if (photos.isEmpty && !_isVideoFile(primaryImage)) {
      return [primaryImage];
    }
    return photos;
  }

  bool get isOnSale => salePrice != null && salePrice! < basePrice;
  
  double get effectivePrice => isOnSale ? salePrice! : basePrice;

  int get discountPercent {
    if (!isOnSale) return 0;
    return (((basePrice - salePrice!) / basePrice) * 100).round();
  }

  String get formattedBasePrice {
    final formatter = NumberFormat('#,###');
    return '₦${formatter.format(basePrice)}';
  }

  String get formattedEffectivePrice {
    final formatter = NumberFormat('#,###');
    return '₦${formatter.format(effectivePrice)}';
  }

  factory Product.fromJson(Map<String, dynamic> json, {List<ProductVariant>? variants}) {
    List<String> rawList = [];
    if (json['images'] is List) {
      rawList = (json['images'] as List).map((e) => e.toString()).toList();
    }
    String? explicitVideo = json['video_url'] as String?;
    if (explicitVideo == null || explicitVideo.trim().isEmpty) {
      explicitVideo = rawList.where((u) => _isVideoFile(u)).firstOrNull;
    }
    final imgList = rawList.where((u) => !_isVideoFile(u)).toList();
    final primaryRaw = json['primary_image'] as String?;
    final primary = (primaryRaw != null && !_isVideoFile(primaryRaw))
        ? primaryRaw
        : (imgList.isNotEmpty ? imgList.first : 'assets/images/placeholder.jpg');

    List<String> tagsList = [];
    if (json['tags'] is List) {
      tagsList = (json['tags'] as List).map((e) => e.toString()).toList();
    }

    return Product(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      categoryId: json['category_id'] as String?,
      collectionId: json['collection_id'] as String?,
      productType: json['product_type'] as String? ?? 'bag',
      subCategory: json['sub_category'] as String?,
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (json['sale_price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'NGN',
      shortDescription: json['short_description'] as String?,
      description: json['description'] as String?,
      images: imgList.isNotEmpty ? imgList : [primary],
      primaryImage: primary,
      videoUrl: explicitVideo,
      material: json['material'] as String?,
      dimensionsCm: json['dimensions_cm'] as String?,
      strapDropCm: (json['strap_drop_cm'] as num?)?.toDouble(),
      heelHeightCm: (json['heel_height_cm'] as num?)?.toDouble(),
      heelType: json['heel_type'] as String?,
      closureType: json['closure_type'] as String?,
      compartmentsInfo: json['compartments_info'] as String?,
      careInstructions: json['care_instructions'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      isBestseller: json['is_bestseller'] as bool? ?? false,
      isNewArrival: json['is_new_arrival'] as bool? ?? true,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 10,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      tags: tagsList,
      variants: variants ?? const [],
    );
  }

  Product copyWithVariants(List<ProductVariant> newVariants) {
    return Product(
      id: id,
      title: title,
      slug: slug,
      categoryId: categoryId,
      collectionId: collectionId,
      productType: productType,
      subCategory: subCategory,
      basePrice: basePrice,
      salePrice: salePrice,
      currency: currency,
      shortDescription: shortDescription,
      description: description,
      images: images,
      primaryImage: primaryImage,
      videoUrl: videoUrl,
      material: material,
      dimensionsCm: dimensionsCm,
      strapDropCm: strapDropCm,
      heelHeightCm: heelHeightCm,
      heelType: heelType,
      closureType: closureType,
      compartmentsInfo: compartmentsInfo,
      careInstructions: careInstructions,
      isFeatured: isFeatured,
      isBestseller: isBestseller,
      isNewArrival: isNewArrival,
      stockQuantity: stockQuantity,
      rating: rating,
      reviewCount: reviewCount,
      tags: tags,
      variants: newVariants,
    );
  }
}

class ProductPairing {
  final String id;
  final String title;
  final String bagProductId;
  final String shoeProductId;
  final int bundleDiscountPercent;
  final String? description;
  final Product? bagProduct;
  final Product? shoeProduct;

  const ProductPairing({
    required this.id,
    required this.title,
    required this.bagProductId,
    required this.shoeProductId,
    this.bundleDiscountPercent = 10,
    this.description,
    this.bagProduct,
    this.shoeProduct,
  });

  factory ProductPairing.fromJson(Map<String, dynamic> json, {Product? bag, Product? shoe}) {
    return ProductPairing(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      bagProductId: json['bag_product_id'] as String? ?? '',
      shoeProductId: json['shoe_product_id'] as String? ?? '',
      bundleDiscountPercent: (json['bundle_discount_percent'] as num?)?.toInt() ?? 10,
      description: json['description'] as String?,
      bagProduct: bag,
      shoeProduct: shoe,
    );
  }

  double get combinedOriginalPrice {
    final bagP = bagProduct?.effectivePrice ?? 0.0;
    final shoeP = shoeProduct?.effectivePrice ?? 0.0;
    return bagP + shoeP;
  }

  double get discountedBundlePrice {
    final total = combinedOriginalPrice;
    return total * (1.0 - (bundleDiscountPercent / 100.0));
  }

  String get formattedBundlePrice {
    final formatter = NumberFormat('#,###');
    return '₦${formatter.format(discountedBundlePrice)}';
  }

  String get formattedOriginalPrice {
    final formatter = NumberFormat('#,###');
    return '₦${formatter.format(combinedOriginalPrice)}';
  }
}

class CartItem {
  final String id;
  final Product product;
  final String? selectedColor;
  final String? selectedSize;
  int quantity;
  final double unitPrice;

  CartItem({
    required this.id,
    required this.product,
    this.selectedColor,
    this.selectedSize,
    this.quantity = 1,
    required this.unitPrice,
  });

  double get totalPrice => unitPrice * quantity;

  String get formattedTotalPrice {
    final formatter = NumberFormat('#,###');
    return '₦${formatter.format(totalPrice)}';
  }

  String get formattedUnitPrice {
    final formatter = NumberFormat('#,###');
    return '₦${formatter.format(unitPrice)}';
  }
}

class Review {
  final String id;
  final String productId;
  final String authorName;
  final int rating;
  final String? headline;
  final String comment;
  final bool isVerifiedBuyer;

  const Review({
    required this.id,
    required this.productId,
    required this.authorName,
    required this.rating,
    this.headline,
    required this.comment,
    this.isVerifiedBuyer = true,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      authorName: json['author_name'] as String? ?? 'Client',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      headline: json['headline'] as String?,
      comment: json['comment'] as String? ?? '',
      isVerifiedBuyer: json['is_verified_buyer'] as bool? ?? true,
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final Map<String, dynamic> shippingAddress;
  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;
  final String currency;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final List<CartItem> items;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.shippingAddress,
    required this.subtotal,
    this.shippingFee = 0.0,
    this.discount = 0.0,
    required this.total,
    this.currency = 'NGN',
    this.status = 'pending',
    this.paymentStatus = 'paid',
    this.paymentMethod = 'transfer',
    this.items = const [],
    required this.createdAt,
  });

  String get formattedTotal {
    final formatter = NumberFormat('#,###');
    return '₦${formatter.format(total)}';
  }
}

class Profile {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String role; // 'customer', 'admin', 'staff'
  final String preferredCurrency;
  final List<dynamic> savedAddresses;
  final DateTime? createdAt;

  const Profile({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.role = 'customer',
    this.preferredCurrency = 'NGN',
    this.savedAddresses = const [],
    this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'customer',
      preferredCurrency: json['preferred_currency'] as String? ?? 'NGN',
      savedAddresses: (json['saved_addresses'] as List?) ?? const [],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  bool get isAdmin => role == 'admin';
}
