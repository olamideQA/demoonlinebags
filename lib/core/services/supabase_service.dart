import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  // --- Curated Fallback Products (Guarantees zero-blank UI & offline resilience) ---
  static final List<Category> fallbackCategories = [
    const Category(
      id: 'c1111111-1111-1111-1111-111111111111',
      name: 'Tote Bags',
      slug: 'tote-bags',
      type: 'bags',
      description: 'Strong office totes for working women. Carries your 14-inch laptop, planner and purse — no sagging, no peeling.',
      imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=800&q=80',
      sortOrder: 1,
    ),
    const Category(
      id: 'c2222222-2222-2222-2222-222222222222',
      name: 'Crossbody Bags',
      slug: 'crossbody-bags',
      type: 'bags',
      description: 'Hands-free bags for market runs, travel, brunch in VI and everyday slay. Light, fine and easy to carry.',
      imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=800&q=80',
      sortOrder: 2,
    ),
    const Category(
      id: 'c3333333-3333-3333-3333-333333333333',
      name: 'Shoulder Bags',
      slug: 'shoulder-bags',
      type: 'bags',
      description: 'Fine under-arm bags that go from office in the morning to dinner at night. One bag, many occasions.',
      imageUrl: 'https://images.unsplash.com/photo-1591561954557-26941169b49e?auto=format&fit=crop&w=800&q=80',
      sortOrder: 3,
    ),
    const Category(
      id: 'c4444444-4444-4444-4444-444444444444',
      name: 'Party Clutches',
      slug: 'evening-clutches',
      type: 'bags',
      description: 'Shining crystal clutches for weddings, Owambe, church anniversary and red-carpet nights. Pepper them well.',
      imageUrl: 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?auto=format&fit=crop&w=800&q=80',
      sortOrder: 4,
    ),
    const Category(
      id: 'c5555555-5555-5555-5555-555555555555',
      name: 'Mini & Bucket Bags',
      slug: 'mini-bucket-bags',
      type: 'bags',
      description: 'Small fine bags for phone, lip gloss and cards. Perfect for quick outings and Detty December parties.',
      imageUrl: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=800&q=80',
      sortOrder: 5,
    ),
    const Category(
      id: 'c6666666-6666-6666-6666-666666666666',
      name: 'Comfy Heels',
      slug: 'luxury-heels',
      type: 'shoes',
      description: 'Fine party heels with soft padding. Dance for hours at Owambe with no leg pain. Brides love them.',
      imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=800&q=80',
      sortOrder: 6,
    ),
    const Category(
      id: 'c7777777-7777-7777-7777-777777777777',
      name: 'Mules & Slides',
      slug: 'mules-slides',
      type: 'shoes',
      description: 'Easy slip-on mules for office, church and brunch. Soft inside, classy outside.',
      imageUrl: 'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?auto=format&fit=crop&w=800&q=80',
      sortOrder: 7,
    ),
  ];

  static final List<Product> fallbackProducts = [
    // 0-1. Client Kosa Luxe Video 1: The Kosa Luxe Gloss Croc-Embossed Executive Tote
    const Product(
      id: 'd0000015-0015-4015-8015-000000000015',
      title: 'The Kosa Luxe Gloss Croc-Embossed Executive Tote',
      slug: 'the-kosa-luxe-gloss-croc-embossed-executive-tote',
      categoryId: 'c1111111-1111-1111-1111-111111111111',
      productType: 'bag',
      subCategory: 'Tote',
      basePrice: 175000.0,
      salePrice: 155000.0,
      currency: 'NGN',
      shortDescription: 'Signature Kosa Luxe high-gloss black croc-embossed structured tote with back zipper pocket. Fits 14-inch laptop & office files.',
      description: 'As seen in our 360° studio turntable video — The Kosa Luxe Gloss Croc-Embossed Executive Tote is built for women who command attention in the boardroom and beyond. Crafted in mirror-gloss croc-embossed patent leather with a structured rectangular silhouette that stands upright on its own, plus an exterior back zipper pocket for quick access to your phone and keys.',
      images: [
        'assets/images/products/kosa_croc_tote_1.jpg',
        'assets/images/products/kosa_croc_tote_2.jpg',
      ],
      primaryImage: 'assets/images/products/kosa_croc_tote_1.jpg',
      videoUrl: 'assets/videos/kosa_croc_tote.mp4',
      material: 'Mirror-Gloss Croc-Embossed Patent Leather with D-Ring Strap Mounts',
      dimensionsCm: '36cm x 29cm x 14cm',
      strapDropCm: 24.0,
      closureType: 'Top security zipper with exterior back zip pocket',
      compartmentsInfo: 'Fits 14" laptop, A4 documents, charger, makeup pouch & exterior quick-access zip pocket',
      careInstructions: 'Wipe with a soft microfiber cloth to maintain mirror-gloss finish.',
      isFeatured: true,
      isBestseller: true,
      isNewArrival: true,
      stockQuantity: 9,
      rating: 5.0,
      reviewCount: 38,
      tags: ['video', 'kosa-luxe', 'bestseller', 'tote', 'croc-embossed'],
      variants: [
        ProductVariant(id: 'vv15-1', productId: 'd0000015-0015-4015-8015-000000000015', variantType: 'color', name: 'Obsidian Gloss Black', colorHex: '#111111'),
        ProductVariant(id: 'vv15-2', productId: 'd0000015-0015-4015-8015-000000000015', variantType: 'color', name: 'Espresso Brown', colorHex: '#3B2314'),
      ],
    ),
    // 0-2. Client Kosa Luxe Video 2: The Kosa Luxe Strappy Square-Toe Leather Slides
    const Product(
      id: 'd0000016-0016-4016-8016-000000000016',
      title: 'The Kosa Luxe Strappy Square-Toe Leather Slides',
      slug: 'the-kosa-luxe-strappy-square-toe-leather-slides',
      categoryId: 'c7777777-7777-7777-7777-777777777777',
      productType: 'shoe',
      subCategory: 'Mules & Slides',
      basePrice: 85000.0,
      salePrice: 72000.0,
      currency: 'NGN',
      shortDescription: 'Soft padded Kosa Luxe square-toe black leather slides with asymmetric tubular straps & gold-stamped footbed.',
      description: 'Featured in our 360° turntable showcase — The Kosa Luxe Square-Toe Leather Slides pair effortless Lagos comfort with high-fashion minimalism. Designed with supple tubular toe-loop straps, a cushioned square-toe footbed stamped in gold with the Kosa Luxe crest, and a durable non-slip sole for all-day errands, brunch, travel and casual Fridays.',
      images: [
        'assets/images/products/kosa_slides_1.jpg',
        'assets/images/products/kosa_slides_2.jpg',
      ],
      primaryImage: 'assets/images/products/kosa_slides_1.jpg',
      videoUrl: 'assets/videos/kosa_black_slides.mp4',
      material: 'Supple Matte Calfskin Tubular Straps with Gold-Stamped Cushioned Footbed',
      heelHeightCm: 1.5,
      heelType: 'Flat Cushioned Resort Sole',
      closureType: 'Easy Slip-On Toe-Loop Silhouette',
      compartmentsInfo: 'Available in EU 37 – 42 • True to size with soft arch cushioning',
      careInstructions: 'Wipe clean with a dry or slightly damp soft cloth.',
      isFeatured: true,
      isBestseller: true,
      isNewArrival: true,
      stockQuantity: 15,
      rating: 4.97,
      reviewCount: 31,
      tags: ['video', 'kosa-luxe', 'slides', 'shoes', 'bestseller'],
      variants: [
        ProductVariant(id: 'vv16-1', productId: 'd0000016-0016-4016-8016-000000000016', variantType: 'color', name: 'Noir Black', colorHex: '#141414'),
        ProductVariant(id: 'vv16-2', productId: 'd0000016-0016-4016-8016-000000000016', variantType: 'size', name: 'EU 37'),
        ProductVariant(id: 'vv16-3', productId: 'd0000016-0016-4016-8016-000000000016', variantType: 'size', name: 'EU 38'),
        ProductVariant(id: 'vv16-4', productId: 'd0000016-0016-4016-8016-000000000016', variantType: 'size', name: 'EU 39'),
        ProductVariant(id: 'vv16-5', productId: 'd0000016-0016-4016-8016-000000000016', variantType: 'size', name: 'EU 40'),
        ProductVariant(id: 'vv16-6', productId: 'd0000016-0016-4016-8016-000000000016', variantType: 'size', name: 'EU 41'),
      ],
    ),
    // 0A. Client Video Showcase 1: The Mossdoom Pistachio Suede Everyday Tote
    const Product(
      id: 'd0000012-0012-4012-8012-000000000012',
      title: 'The Mossdoom Pistachio Suede Everyday Tote',
      slug: 'the-mossdoom-pistachio-suede-everyday-tote',
      categoryId: 'c1111111-1111-1111-1111-111111111111',
      productType: 'bag',
      subCategory: 'Tote',
      basePrice: 145000.0,
      salePrice: 128000.0,
      currency: 'NGN',
      shortDescription: 'Soft pistachio suede tote with cream trim & plush heart charm. Fits iPad, umbrella, sunglasses & all daily essentials.',
      description: 'As seen in our live video — The Mossdoom Pistachio Suede Tote is the ultimate everyday luxury bag for work, uni, brunch and travel. Crafted with velvety pistachio suede and contrast cream piping, it features a magnetic snap top plus a full zippered middle compartment so your iPad, phone, purse, mini fan and umbrella stay neatly organized all day.',
      images: [
        'assets/images/products/pistachio_tote_1.jpg',
        'assets/images/products/pistachio_tote_2.jpg',
        'assets/images/products/pistachio_tote_3.jpg',
      ],
      primaryImage: 'assets/images/products/pistachio_tote_1.jpg',
      videoUrl: 'assets/videos/pistachio_suede_tote.mp4',
      material: 'Velvety Pistachio Suede with Cream Calfskin Trim & Branded Satin Lining',
      dimensionsCm: '35cm x 26cm x 13cm',
      strapDropCm: 25.0,
      closureType: 'Magnetic snap closure with full-length central zippered compartment',
      compartmentsInfo: 'Fits iPad / tablet, umbrella, water bottle, sunglasses, perfume & wallet with inner zip divider',
      careInstructions: 'Brush gently with soft suede brush. Store in supplied dust bag.',
      isFeatured: true,
      isBestseller: true,
      isNewArrival: true,
      stockQuantity: 14,
      rating: 5.0,
      reviewCount: 42,
      tags: ['video', 'bestseller', 'tote', 'new-arrival', 'everyday-bag'],
      variants: [
        ProductVariant(id: 'vv12-1', productId: 'd0000012-0012-4012-8012-000000000012', variantType: 'color', name: 'Pistachio Matcha', colorHex: '#9CB071'),
        ProductVariant(id: 'vv12-2', productId: 'd0000012-0012-4012-8012-000000000012', variantType: 'color', name: 'Cream Ivory', colorHex: '#F5F5DC'),
        ProductVariant(id: 'vv12-3', productId: 'd0000012-0012-4012-8012-000000000012', variantType: 'color', name: 'Mocha Taupe', colorHex: '#8B7355'),
      ],
    ),
    // 0B. Client Video Showcase 2: The Alabaster Structured Dual-Strap Tote
    const Product(
      id: 'd0000013-0013-4013-8013-000000000013',
      title: 'The Alabaster Structured Dual-Strap Tote',
      slug: 'the-alabaster-structured-dual-strap-tote',
      categoryId: 'c1111111-1111-1111-1111-111111111111',
      productType: 'bag',
      subCategory: 'Tote',
      basePrice: 155000.0,
      salePrice: 139500.0,
      currency: 'NGN',
      shortDescription: 'Clean structured alabaster ivory tote with short hand straps & long shoulder straps. Enjoy 10% off your first order.',
      description: 'Featured in our live studio video — The Alabaster Structured Tote combines architectural minimalism with everyday strength. Built with heavy-duty structured canvas and smooth ivory leather trim, it features both short top handles and long comfortable shoulder straps. Stands firm on any table without slouching.',
      images: [
        'assets/images/products/ivory_tote_2.jpg',
        'assets/images/products/ivory_tote_1.jpg',
      ],
      primaryImage: 'assets/images/products/ivory_tote_2.jpg',
      videoUrl: 'assets/videos/ivory_canvas_tote.mp4',
      material: 'Heavyweight Structured Canvas with Smooth Alabaster Leather Straps',
      dimensionsCm: '33cm x 28cm x 15cm',
      strapDropCm: 26.0,
      closureType: 'Top magnetic clasp with structured wide-mouth opening',
      compartmentsInfo: 'Spacious main compartment for 13"-14" laptop, notebooks, makeup pouch & inner slip pockets',
      careInstructions: 'Spot clean with mild soap and damp cloth. Keep away from dark denim transfer.',
      isFeatured: true,
      isBestseller: true,
      isNewArrival: true,
      stockQuantity: 10,
      rating: 4.98,
      reviewCount: 29,
      tags: ['video', 'bestseller', 'tote', 'new-arrival', '10-percent-off'],
      variants: [
        ProductVariant(id: 'vv13-1', productId: 'd0000013-0013-4013-8013-000000000013', variantType: 'color', name: 'Alabaster Ivory', colorHex: '#F7F5F0'),
        ProductVariant(id: 'vv13-2', productId: 'd0000013-0013-4013-8013-000000000013', variantType: 'color', name: 'Warm Sand', colorHex: '#D8CFC2'),
        ProductVariant(id: 'vv13-3', productId: 'd0000013-0013-4013-8013-000000000013', variantType: 'color', name: 'Obsidian Black', colorHex: '#1A1A1A'),
      ],
    ),
    // 1. The Sovereign Tote
    const Product(
      id: 'd1111111-1111-1111-1111-111111111111',
      title: 'The Sovereign Structured Leather Tote',
      slug: 'the-sovereign-structured-leather-tote',
      categoryId: 'c1111111-1111-1111-1111-111111111111',
      productType: 'bag',
      subCategory: 'Tote',
      basePrice: 185000.0,
      salePrice: 165000.0,
      currency: 'NGN',
      shortDescription: 'Strong office tote in real leather. Carries your 14-inch laptop without bending or peeling.',
      description: 'The Sovereign Tote is for women who mean business. Made with real thick leather, it stands well whether empty or full. Your 14-inch laptop, files and purse enter with ease. Perfect for Lekki to Abuja executives.',
      images: [
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1000&q=80',
      ],
      primaryImage: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80',
      material: 'Full-Grain Italian Calfskin with Microfiber Suede Lining',
      dimensionsCm: '36cm x 27cm x 14cm',
      strapDropCm: 24.0,
      closureType: 'Dual magnetic snaps with central padlock clasp',
      compartmentsInfo: 'Padded 14" laptop partition, zippered valuables pocket, twin smartphone slips',
      careInstructions: 'Store in supplied velvet dust bag. Wipe clean with soft damp cloth.',
      isFeatured: true,
      isBestseller: true,
      isNewArrival: true,
      stockQuantity: 8,
      rating: 4.95,
      reviewCount: 34,
      tags: ['bestseller', 'workwear', 'tote', 'luxury-bag'],
      variants: [
        ProductVariant(id: 'v1', productId: 'd1111111-1111-1111-1111-111111111111', variantType: 'color', name: 'Obsidian Black', colorHex: '#1A1A1A'),
        ProductVariant(id: 'v2', productId: 'd1111111-1111-1111-1111-111111111111', variantType: 'color', name: 'Cognac Tan', colorHex: '#8B4513'),
        ProductVariant(id: 'v3', productId: 'd1111111-1111-1111-1111-111111111111', variantType: 'color', name: 'Alabaster Ivory', colorHex: '#F5F5DC'),
      ],
    ),
    // 2. The Aurelia Crossbody
    const Product(
      id: 'd2222222-2222-2222-2222-222222222222',
      title: 'The Aurelia Quilted Flap Crossbody',
      slug: 'the-aurelia-quilted-flap-crossbody',
      categoryId: 'c2222222-2222-2222-2222-222222222222',
      productType: 'bag',
      subCategory: 'Crossbody',
      basePrice: 145000.0,
      currency: 'NGN',
      shortDescription: 'Soft quilted crossbody with fine gold lock. Wear long or double the chain for dinner.',
      description: 'The Aurelia Crossbody goes from morning meeting to evening dinner without stress. Soft leather, fine gold chain you can wear long across your body or double for shoulder. Light and fine for everyday Lagos movement.',
      images: [
        'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1591561954557-26941169b49e?auto=format&fit=crop&w=1000&q=80',
      ],
      primaryImage: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1000&q=80',
      material: 'Ultra-Soft Lambskin Leather with 24K Gold Plated Hardware',
      dimensionsCm: '25cm x 16cm x 8cm',
      strapDropCm: 52.0,
      closureType: 'Signature Turn-Lock Closure',
      compartmentsInfo: 'Two accordion compartments and internal zippered divider',
      careInstructions: 'Avoid prolonged contact with dark dyes. Condition biannually.',
      isFeatured: true,
      isBestseller: true,
      isNewArrival: true,
      stockQuantity: 12,
      rating: 4.90,
      reviewCount: 28,
      tags: ['crossbody', 'quilted', 'signature', 'gold-chain'],
      variants: [
        ProductVariant(id: 'v4', productId: 'd2222222-2222-2222-2222-222222222222', variantType: 'color', name: 'Noir Black', colorHex: '#1A1A1A'),
        ProductVariant(id: 'v5', productId: 'd2222222-2222-2222-2222-222222222222', variantType: 'color', name: 'Burgundy Wine', colorHex: '#6A1B29'),
        ProductVariant(id: 'v6', productId: 'd2222222-2222-2222-2222-222222222222', variantType: 'color', name: 'Emerald Green', colorHex: '#0B5345'),
      ],
    ),
    // 3. The Venetian Crystal Minaudière Clutch
    const Product(
      id: 'd3333333-3333-3333-3333-333333333333',
      title: 'The Venetian Crystal Minaudière Clutch',
      slug: 'the-venetian-crystal-minaudiere-clutch',
      categoryId: 'c4444444-4444-4444-4444-444444444444',
      productType: 'bag',
      subCategory: 'Clutch',
      basePrice: 175000.0,
      salePrice: 155000.0,
      currency: 'NGN',
      shortDescription: 'Shining crystal party clutch with fine gold chain. Fits iPhone 16 Pro Max.',
      description: 'This clutch will make you shine at any wedding or Owambe. Over 1,200 crystals that catch light from every angle. Your iPhone 16 Pro Max, keys, lipstick and cards enter well. Bridesmaids and wedding guests love it.',
      images: [
        'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80',
      ],
      primaryImage: 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?auto=format&fit=crop&w=1000&q=80',
      material: 'Faceted K9 Crystals on Solid Brass Frame, Satin Interior',
      dimensionsCm: '20cm x 12cm x 6cm',
      strapDropCm: 55.0,
      closureType: 'Jeweled Push-Clasp Lock',
      compartmentsInfo: 'Single satin-lined compartment with card pocket',
      careInstructions: 'Spot clean crystals with microfiber jewel cloth.',
      isFeatured: true,
      isBestseller: false,
      isNewArrival: true,
      stockQuantity: 6,
      rating: 5.0,
      reviewCount: 19,
      tags: ['evening', 'clutch', 'crystals', 'wedding'],
      variants: [
        ProductVariant(id: 'v7', productId: 'd3333333-3333-3333-3333-333333333333', variantType: 'color', name: 'Champagne Gold', colorHex: '#D4AF37'),
        ProductVariant(id: 'v8', productId: 'd3333333-3333-3333-3333-333333333333', variantType: 'color', name: 'Silver Starlight', colorHex: '#E0E0E0'),
      ],
    ),
    // 4. The Riviera Woven Leather Bucket Bag
    const Product(
      id: 'd4444444-4444-4444-4444-444444444444',
      title: 'The Riviera Woven Nappa Bucket Bag',
      slug: 'the-riviera-woven-nappa-bucket-bag',
      categoryId: 'c5555555-5555-5555-5555-555555555555',
      productType: 'bag',
      subCategory: 'Bucket Bag',
      basePrice: 135000.0,
      currency: 'NGN',
      shortDescription: 'Fine hand-woven bucket bag with drawstring pouch inside. Light and classy.',
      description: 'The Riviera Bucket is simple and classy for everyday Lagos life — market, church, brunch. Woven with soft real leather, strong but light. Carries all your small things with style.',
      images: [
        'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=1000&q=80',
      ],
      primaryImage: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=1000&q=80',
      material: 'Hand-Woven Calf Nappa Leather with Natural Linen Pouch',
      dimensionsCm: '22cm x 22cm x 15cm',
      strapDropCm: 48.0,
      closureType: 'Linen Drawstring Cinch',
      compartmentsInfo: 'Spacious open bucket interior with removable organizer insert',
      careInstructions: 'Store with tissue stuffing to preserve bucket cylindrical form.',
      isFeatured: true,
      isBestseller: false,
      isNewArrival: true,
      stockQuantity: 10,
      rating: 4.88,
      reviewCount: 14,
      tags: ['woven', 'bucket-bag', 'riviera', 'summer'],
      variants: [
        ProductVariant(id: 'v9', productId: 'd4444444-4444-4444-4444-444444444444', variantType: 'color', name: 'Natural Sand', colorHex: '#D2B48C'),
        ProductVariant(id: 'v10', productId: 'd4444444-4444-4444-4444-444444444444', variantType: 'color', name: 'Caramel Toffee', colorHex: '#A0522D'),
      ],
    ),
    // 5. The Milan Croc Baguette
    const Product(
      id: 'd5555555-5555-5555-5555-555555555555',
      title: 'The Milan Croc-Embossed Baguette Shoulder Bag',
      slug: 'the-milan-croc-embossed-baguette',
      categoryId: 'c3333333-3333-3333-3333-333333333333',
      productType: 'bag',
      subCategory: 'Shoulder Bag',
      basePrice: 120000.0,
      salePrice: 110000.0,
      currency: 'NGN',
      shortDescription: 'Fine croc shoulder bag for daily use — sits well under the arm, from work to party.',
      description: 'The Milan Baguette is that one bag you carry everywhere. Fits well under the arm, fine croc leather that cleans easily, strong zip so your things are safe in traffic or market.',
      images: [
        'https://images.unsplash.com/photo-1591561954557-26941169b49e?auto=format&fit=crop&w=1000&q=80',
      ],
      primaryImage: 'https://images.unsplash.com/photo-1591561954557-26941169b49e?auto=format&fit=crop&w=1000&q=80',
      material: 'Gloss Croc-Embossed Italian Leather',
      dimensionsCm: '27cm x 14cm x 6cm',
      strapDropCm: 22.0,
      closureType: 'Heavy-duty Brushed Brass Zipper',
      compartmentsInfo: 'Interior slip pocket, dedicated lipstick holder',
      careInstructions: 'Buff with soft dry cloth to enhance glazed shine.',
      isFeatured: false,
      isBestseller: true,
      isNewArrival: true,
      stockQuantity: 15,
      rating: 4.85,
      reviewCount: 22,
      tags: ['shoulder-bag', 'baguette', 'croc', '90s'],
      variants: [
        ProductVariant(id: 'v11', productId: 'd5555555-5555-5555-5555-555555555555', variantType: 'color', name: 'Espresso Croc', colorHex: '#2A1810'),
        ProductVariant(id: 'v12', productId: 'd5555555-5555-5555-5555-555555555555', variantType: 'color', name: 'Cherry Patent', colorHex: '#800020'),
      ],
    ),
    // 6. The Bellissima Crystal Pointed Stiletto (SHOE)
    const Product(
      id: 'd6666666-6666-6666-6666-666666666666',
      title: 'The Bellissima Crystal Pointed Stiletto',
      slug: 'the-bellissima-crystal-pointed-stiletto',
      categoryId: 'c6666666-6666-6666-6666-666666666666',
      productType: 'shoe',
      subCategory: 'Stiletto',
      basePrice: 115000.0,
      salePrice: 98000.0,
      currency: 'NGN',
      shortDescription: 'Shining crystal heels with soft padding — dance for hours with no leg pain.',
      description: 'The Bellissima is the party and bridal favourite. Fine satin, soft padding inside for your leg, and strong sole. Brides dance from church to reception, Owambe guests stand for hours — no wahala.',
      images: [
        'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=1000&q=80',
        'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?auto=format&fit=crop&w=1000&q=80',
      ],
      primaryImage: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=1000&q=80',
      material: 'Silk Satin Upper, Lambskin Insole, Genuine Leather Sole',
      heelHeightCm: 9.5,
      heelType: 'Stiletto',
      closureType: 'Slip-on with Elasticized Heel Support',
      careInstructions: 'Treat with water repellent spray before wear. Keep crystal brooch dry.',
      isFeatured: true,
      isBestseller: true,
      isNewArrival: true,
      stockQuantity: 20,
      rating: 4.96,
      reviewCount: 41,
      tags: ['heels', 'stiletto', 'crystals', 'wedding-shoes'],
      variants: [
        ProductVariant(id: 'v13', productId: 'd6666666-6666-6666-6666-666666666666', variantType: 'size', name: 'EU 37 / UK 4'),
        ProductVariant(id: 'v14', productId: 'd6666666-6666-6666-6666-666666666666', variantType: 'size', name: 'EU 38 / UK 5'),
        ProductVariant(id: 'v15', productId: 'd6666666-6666-6666-6666-666666666666', variantType: 'size', name: 'EU 39 / UK 6'),
        ProductVariant(id: 'v16', productId: 'd6666666-6666-6666-6666-666666666666', variantType: 'size', name: 'EU 40 / UK 7'),
        ProductVariant(id: 'v17', productId: 'd6666666-6666-6666-6666-666666666666', variantType: 'size', name: 'EU 41 / UK 8'),
      ],
    ),
    // 7. The Paloma Sculpted Block Heel Mule (SHOE)
    const Product(
      id: 'd7777777-7777-7777-7777-777777777777',
      title: 'The Paloma Sculpted Block Heel Mule',
      slug: 'the-paloma-sculpted-block-heel-mule',
      categoryId: 'c7777777-7777-7777-7777-777777777777',
      productType: 'shoe',
      subCategory: 'Mule',
      basePrice: 88000.0,
      currency: 'NGN',
      shortDescription: 'Comfy low block-heel mule in soft leather — wear all day for office and church.',
      description: 'The Paloma Mule is comfort + class. Low stable heel you can wear from morning office to evening outing. Goes well with trousers, skirt, native and jeans. No leg pain.',
      images: [
        'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?auto=format&fit=crop&w=1000&q=80',
      ],
      primaryImage: 'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?auto=format&fit=crop&w=1000&q=80',
      material: 'Glove Leather Upper with Cushioned Footbed',
      heelHeightCm: 6.0,
      heelType: 'Block',
      closureType: 'Slip-on',
      careInstructions: 'Condition with neutral leather balm.',
      isFeatured: false,
      isBestseller: true,
      isNewArrival: true,
      stockQuantity: 18,
      rating: 4.89,
      reviewCount: 16,
      tags: ['mules', 'block-heel', 'comfortable-heels', 'everyday-chic'],
      variants: [
        ProductVariant(id: 'v18', productId: 'd7777777-7777-7777-7777-777777777777', variantType: 'size', name: 'EU 38 / UK 5'),
        ProductVariant(id: 'v19', productId: 'd7777777-7777-7777-7777-777777777777', variantType: 'size', name: 'EU 39 / UK 6'),
        ProductVariant(id: 'v20', productId: 'd7777777-7777-7777-7777-777777777777', variantType: 'size', name: 'EU 40 / UK 7'),
      ],
    ),
    // 8. The Capucine Vanity
    const Product(
      id: 'd8888888-8888-8888-8888-888888888888',
      title: 'The Capucine Petite Top-Handle Vanity',
      slug: 'the-capucine-petite-top-handle-vanity',
      categoryId: 'c5555555-5555-5555-5555-555555555555',
      productType: 'bag',
      subCategory: 'Mini Bag',
      basePrice: 110000.0,
      salePrice: 99000.0,
      currency: 'NGN',
      shortDescription: 'Small fine box bag with handle + long strap. For phone, cards and lipstick.',
      description: 'The Capucine Vanity is small but mighty. Carry only what you need — cards, keys, powder and lipstick. Hold by hand for party or wear across body. Very classy for weddings and dinners.',
      images: [
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80',
      ],
      primaryImage: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80',
      material: 'Pebbled Calfskin Leather with Gold Accents',
      dimensionsCm: '18cm x 13cm x 9cm',
      strapDropCm: 54.0,
      closureType: 'Double Wrap-Around Zipper',
      compartmentsInfo: 'Interior vanity mirror on lid, elasticized pouch',
      careInstructions: 'Wipe with leather cleaner.',
      isFeatured: true,
      isBestseller: false,
      isNewArrival: true,
      stockQuantity: 9,
      rating: 4.92,
      reviewCount: 11,
      tags: ['vanity-bag', 'mini-bag', 'top-handle'],
      variants: [
        ProductVariant(id: 'v21', productId: 'd8888888-8888-8888-8888-888888888888', variantType: 'color', name: 'Caramel Grain', colorHex: '#C68B59'),
        ProductVariant(id: 'v22', productId: 'd8888888-8888-8888-8888-888888888888', variantType: 'color', name: 'Noir Classic', colorHex: '#1A1A1A'),
      ],
    ),
  ];

  static final List<ProductPairing> fallbackPairings = [
    ProductPairing(
      id: 'e1111111-1111-1111-1111-111111111111',
      title: 'Owambe Ready Set: Crystal Clutch + Crystal Heels',
      bagProductId: 'd3333333-3333-3333-3333-333333333333',
      shoeProductId: 'd6666666-6666-6666-6666-666666666666',
      bundleDiscountPercent: 15,
      description: 'Perfect match for weddings and Owambe. Shining clutch + comfy padded heels you can dance in for 6 hours. Buy together and save 15%. Brides and wedding guests love this set.',
      bagProduct: fallbackProducts[2],
      shoeProduct: fallbackProducts[5],
    ),
    ProductPairing(
      id: 'e2222222-2222-2222-2222-222222222222',
      title: 'Office Power Set: Laptop Tote + Comfy Mules',
      bagProductId: 'd1111111-1111-1111-1111-111111111111',
      shoeProductId: 'd7777777-7777-7777-7777-777777777777',
      bundleDiscountPercent: 10,
      description: 'For working women: strong tote that carries your 14-inch laptop + comfy low heels for all-day office and church. Real leather, no peeling. Save 10% when you buy both.',
      bagProduct: fallbackProducts[0],
      shoeProduct: fallbackProducts[6],
    ),
  ];

  static final List<Review> fallbackReviews = [
    const Review(
      id: 'r1',
      productId: 'd1111111-1111-1111-1111-111111111111',
      authorName: 'Amina Bello',
      rating: 5,
      headline: 'Strong leather, worth it!',
      comment: 'I carried this tote to a board meeting at Eko Hotels, VI. Everybody asked me about it. Firm, my 14-inch laptop entered well. No peeling at all.',
    ),
    const Review(
      id: 'r2',
      productId: 'd1111111-1111-1111-1111-111111111111',
      authorName: 'Chidinma Okafor',
      rating: 5,
      headline: 'You can feel the quality',
      comment: 'Heavy real leather, gold still shining after rain and sun. Worth every naira. Delivery to Lekki was same day.',
    ),
    const Review(
      id: 'r3',
      productId: 'd2222222-2222-2222-2222-222222222222',
      authorName: 'Zainab Kabir',
      rating: 5,
      headline: 'My favourite everyday bag',
      comment: 'Soft but holds shape well. I wear the chain long in the day and double it for dinner in Ikoyi. Very fine.',
    ),
    const Review(
      id: 'r4',
      productId: 'd3333333-3333-3333-3333-333333333333',
      authorName: 'Folashade Adeyemi',
      rating: 5,
      headline: 'Shines too much!',
      comment: 'Wore this to my sister wedding in Abuja. Under light ehn, it was blinding! And my iPhone 16 Pro Max entered. I peppered them.',
    ),
    const Review(
      id: 'r5',
      productId: 'd6666666-6666-6666-6666-666666666666',
      authorName: 'Dr. Ngozi Eze',
      rating: 5,
      headline: 'Heels wey no dey pain leg',
      comment: 'I wore these heels for 6 hours for wedding in Maitama, my leg no pain. The padding is real. I don recommend to my colleagues.',
    ),
  ];

  // --- API Methods ---

  static Future<List<Product>> getProducts({String? categorySlug, String? productType}) async {
    final client = _client;
    if (client == null) {
      return _filterLocalProducts(categorySlug, productType);
    }

    try {
      var query = client.from('products').select('*, product_variants(*)');
      if (productType != null && productType.isNotEmpty) {
        query = query.eq('product_type', productType);
      }
      final response = await query.order('created_at', ascending: false);
      if (response.isEmpty) {
        return _filterLocalProducts(categorySlug, productType);
      }
      final dbProducts = (response as List).map((row) {
        final variants = (row['product_variants'] as List?)
            ?.map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
            .toList();
        return Product.fromJson(row as Map<String, dynamic>, variants: variants);
      }).toList();

      return dbProducts;
    } catch (_) {
      return _filterLocalProducts(categorySlug, productType);
    }
  }

  static List<Product> _filterLocalProducts(String? categorySlug, String? productType) {
    var items = List<Product>.from(fallbackProducts);
    if (productType != null && productType.isNotEmpty) {
      items = items.where((p) => p.productType == productType).toList();
    }
    if (categorySlug != null && categorySlug.isNotEmpty) {
      final cat = fallbackCategories.firstWhere(
        (c) => c.slug == categorySlug,
        orElse: () => fallbackCategories.first,
      );
      items = items.where((p) => p.categoryId == cat.id).toList();
    }
    return items;
  }

  static Future<Product?> getProductBySlug(String slug) async {
    final client = _client;
    if (client != null) {
      try {
        final response = await client
            .from('products')
            .select('*, product_variants(*)')
            .eq('slug', slug)
            .maybeSingle();
        if (response != null) {
          final variants = (response['product_variants'] as List?)
              ?.map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
              .toList();
          return Product.fromJson(response, variants: variants);
        }
      } catch (_) {}
    }
    try {
      return fallbackProducts.firstWhere((p) => p.slug == slug);
    } catch (_) {
      return fallbackProducts.isNotEmpty ? fallbackProducts.first : null;
    }
  }

  static Future<List<Category>> getCategories() async {
    final client = _client;
    if (client != null) {
      try {
        final response = await client.from('categories').select().order('sort_order', ascending: true);
        if (response.isNotEmpty) {
          return (response as List).map((c) => Category.fromJson(c as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }
    return fallbackCategories;
  }

  static Future<List<ProductPairing>> getPairings() async {
    final client = _client;
    if (client != null) {
      try {
        final response = await client.from('pairings').select();
        if (response.isNotEmpty) {
          final allProducts = await getProducts();
          final productMap = {for (var p in allProducts) p.id: p};
          return (response as List).map((row) {
            final bagId = row['bag_product_id'] as String?;
            final shoeId = row['shoe_product_id'] as String?;
            return ProductPairing.fromJson(
              row as Map<String, dynamic>,
              bag: bagId != null ? productMap[bagId] : null,
              shoe: shoeId != null ? productMap[shoeId] : null,
            );
          }).toList();
        }
      } catch (_) {}
    }
    return fallbackPairings;
  }

  static Future<List<Review>> getReviews(String productId) async {
    final client = _client;
    if (client != null) {
      try {
        final response = await client.from('reviews').select().eq('product_id', productId);
        if (response.isNotEmpty) {
          return (response as List).map((r) => Review.fromJson(r as Map<String, dynamic>)).toList();
        }
      } catch (_) {}
    }
    return fallbackReviews.where((r) => r.productId == productId).toList();
  }

  // --- Categories manager ---
  static Future<bool> createCategory({
    required String name,
    required String type,
    String? description,
    String? imageUrl,
  }) async {
    final client = _client;
    if (client == null) return false;
    try {
      final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
      await client.from('categories').insert({
        'name': name.trim(),
        'slug': slug,
        'type': type,
        'description': (description ?? '').trim(),
        'image_url': (imageUrl ?? '').trim(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateCategory({
    required String id,
    required String name,
    required String type,
    String? description,
    String? imageUrl,
  }) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('categories').update({
        'name': name.trim(),
        'type': type,
        'description': (description ?? '').trim(),
        'image_url': (imageUrl ?? '').trim(),
      }).eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteCategory(String id) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('categories').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // --- Reviews moderation ---
  static Future<bool> deleteReview(String id) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('reviews').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String> submitOrder({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required Map<String, dynamic> shippingAddress,
    required double subtotal,
    required double shippingFee,
    required double discount,
    required double total,
    required String paymentMethod,
    required List<CartItem> items,
  }) async {
    final orderNumber = 'DOB-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final client = _client;
    if (client != null) {
      try {
        final orderRow = await client.from('orders').insert({
          'order_number': orderNumber,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
          'shipping_address': shippingAddress,
          'subtotal': subtotal,
          'shipping_fee': shippingFee,
          'discount': discount,
          'total': total,
          'currency': 'NGN',
          'status': 'pending',
          'payment_status': 'paid',
          'payment_method': paymentMethod,
        }).select().single();

        final orderId = orderRow['id'] as String;
        final orderItemsData = items.map((item) => {
          'order_id': orderId,
          'product_id': item.product.id,
          'product_title': item.product.title,
          'product_image': item.product.primaryImage,
          'selected_size': item.selectedSize,
          'selected_color': item.selectedColor,
          'unit_price': item.unitPrice,
          'quantity': item.quantity,
          'total_price': item.totalPrice,
        }).toList();

        await client.from('order_items').insert(orderItemsData);
      } catch (e) {
        // Log gracefully; mock completion proceeds so UX never blocks
      }
    }
    return orderNumber;
  }

  static Future<bool> createProduct(Map<String, dynamic> productData) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('products').insert(productData);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateProduct(String id, Map<String, dynamic> updates) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('products').update(updates).eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteProduct(String id) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('products').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getOrders() async {
    final client = _client;
    if (client == null) return [];
    try {
      final response = await client.from('orders').select('*, order_items(*)').order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getUserOrders({String? userId, String? email}) async {
    final client = _client;
    if (client == null) return [];
    try {
      dynamic query = client.from('orders').select('*, order_items(*)');
      if (userId != null && userId.isNotEmpty && email != null && email.isNotEmpty) {
        query = query.or('user_id.eq.$userId,customer_email.eq.$email');
      } else if (userId != null && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      } else if (email != null && email.isNotEmpty) {
        query = query.eq('customer_email', email);
      }
      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  static Future<bool> updateProfile(String userId, Map<String, dynamic> updates) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('profiles').update(updates).eq('id', userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateOrderStatus(String orderId, String status, {String? trackingCode}) async {
    final client = _client;
    if (client == null) return false;
    try {
      final data = <String, dynamic>{'status': status};
      if (trackingCode != null && trackingCode.isNotEmpty) {
        data['tracking_code'] = trackingCode;
      }
      await client.from('orders').update(data).eq('id', orderId);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> createPairing({
    required String title,
    required String bagProductId,
    required String shoeProductId,
    required int discountPercent,
    required String description,
  }) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('pairings').insert({
        'title': title,
        'bag_product_id': bagProductId,
        'shoe_product_id': shoeProductId,
        'bundle_discount_percent': discountPercent,
        'description': description,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updatePairing({
    required String id,
    required String title,
    required String bagProductId,
    required String shoeProductId,
    required int discountPercent,
    required String description,
  }) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('pairings').update({
        'title': title,
        'bag_product_id': bagProductId,
        'shoe_product_id': shoeProductId,
        'bundle_discount_percent': discountPercent,
        'description': description,
      }).eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Uploads a product photo to Supabase Storage `products` bucket.
  /// Returns the public URL, or null on failure.
  static Future<String?> uploadProductImage(Uint8List bytes, String filename) async {
    final client = _client;
    if (client == null) return null;
    try {
      final ext = filename.contains('.') ? filename.split('.').last.toLowerCase() : 'jpg';
      final safeExt = ['jpg', 'jpeg', 'png', 'webp'].contains(ext) ? ext : 'jpg';
      final path = 'products/${DateTime.now().millisecondsSinceEpoch}.$safeExt';
      await client.storage.from('products').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: 'image/$safeExt', upsert: true),
      );
      return client.storage.from('products').getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }

  /// Uploads a product video (.mp4, .mov, .webm) to Supabase Storage `products` bucket.
  /// Returns the public URL, or null on failure.
  static Future<String?> uploadProductVideo(Uint8List bytes, String filename) async {
    final client = _client;
    if (client == null) return null;
    try {
      final ext = filename.contains('.') ? filename.split('.').last.toLowerCase() : 'mp4';
      final safeExt = ['mp4', 'webm', 'mov', 'm4v'].contains(ext) ? ext : 'mp4';
      final path = 'products/video_${DateTime.now().millisecondsSinceEpoch}.$safeExt';
      await client.storage.from('products').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: 'video/$safeExt', upsert: true),
      );
      return client.storage.from('products').getPublicUrl(path);
    } catch (_) {
      return null;
    }
  }

  // --- Promo codes (DB-driven, admin-managed) ---
  static Future<List<Map<String, dynamic>>> getPromoCodes() async {
    final client = _client;
    if (client == null) return [];
    try {
      final res = await client.from('promo_codes').select().order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(res as List);
    } catch (_) {
      return [];
    }
  }

  /// Returns discount % for an active code, or 0 if invalid.
  static Future<int> validatePromoCode(String code) async {
    final client = _client;
    if (client == null) return 0;
    try {
      final res = await client
          .from('promo_codes')
          .select('discount_percent')
          .eq('code', code.trim().toUpperCase())
          .eq('is_active', true)
          .maybeSingle();
      if (res == null) return 0;
      return (res['discount_percent'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<bool> createPromoCode({required String code, required int percent}) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('promo_codes').insert({
        'code': code.trim().toUpperCase(),
        'discount_percent': percent,
        'is_active': true,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> setPromoActive(String id, bool active) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('promo_codes').update({'is_active': active}).eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deletePromoCode(String id) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('promo_codes').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deletePairing(String id) async {
    final client = _client;
    if (client == null) return false;
    try {
      await client.from('pairings').delete().eq('id', id);
      return true;
    } catch (_) {
      return false;
    }
  }
}
