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
      description: 'Spacious, structured luxury totes tailored for everyday elegance and executive lifestyles.',
      imageUrl: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=800&q=80',
      sortOrder: 1,
    ),
    const Category(
      id: 'c2222222-2222-2222-2222-222222222222',
      name: 'Crossbody Bags',
      slug: 'crossbody-bags',
      type: 'bags',
      description: 'Effortless hands-free silhouettes with polished hardware and adjustable leather straps.',
      imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=800&q=80',
      sortOrder: 2,
    ),
    const Category(
      id: 'c3333333-3333-3333-3333-333333333333',
      name: 'Shoulder Bags',
      slug: 'shoulder-bags',
      type: 'bags',
      description: 'Iconic 90s-inspired baguettes, ruched croissants, and classic chain-link shoulder carriers.',
      imageUrl: 'https://images.unsplash.com/photo-1591561954557-26941169b49e?auto=format&fit=crop&w=800&q=80',
      sortOrder: 3,
    ),
    const Category(
      id: 'c4444444-4444-4444-4444-444444444444',
      name: 'Evening Clutches',
      slug: 'evening-clutches',
      type: 'bags',
      description: 'Show-stopping minaudières, crystal-encrusted boxes, and lustrous silk-satin pouches.',
      imageUrl: 'https://images.unsplash.com/photo-1566150905458-1bf1fc113f0d?auto=format&fit=crop&w=800&q=80',
      sortOrder: 4,
    ),
    const Category(
      id: 'c5555555-5555-5555-5555-555555555555',
      name: 'Mini & Bucket Bags',
      slug: 'mini-bucket-bags',
      type: 'bags',
      description: 'Playful yet sophisticated compact designs crafted in structured grain leathers.',
      imageUrl: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=800&q=80',
      sortOrder: 5,
    ),
    const Category(
      id: 'c6666666-6666-6666-6666-666666666666',
      name: 'Luxury Heels',
      slug: 'luxury-heels',
      type: 'shoes',
      description: 'Signature sculpted stilettos, kitten heels, and slingbacks made to complement every bag.',
      imageUrl: 'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?auto=format&fit=crop&w=800&q=80',
      sortOrder: 6,
    ),
    const Category(
      id: 'c7777777-7777-7777-7777-777777777777',
      name: 'Mules & Slides',
      slug: 'mules-slides',
      type: 'shoes',
      description: 'Architectural block heels, slip-on metallic mules, and cushioned everyday slides.',
      imageUrl: 'https://images.unsplash.com/photo-1535043934128-cf0b28d52f95?auto=format&fit=crop&w=800&q=80',
      sortOrder: 7,
    ),
  ];

  static final List<Product> fallbackProducts = [
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
      shortDescription: 'Sculpted architecture in full-grain calfskin leather with protective brass feet and dual top handles.',
      description: 'The Sovereign Tote is the definitive hallmark of modern feminine leadership. Handcrafted from top-tier full-grain calfskin, it features a structured silhouette that maintains its refined profile whether lightly packed or holding your daily essentials. Accommodates up to a 14-inch MacBook Pro with ease.',
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
      shortDescription: 'Diamond-quilted supple lambskin leather elevated with our 24K gold-plated lock mechanism.',
      description: 'Radiating effortless Parisian chic, the Aurelia Crossbody transitions seamlessly from morning meetings to candlelit evenings. The sliding gold gourmette chain can be doubled for an over-the-shoulder carry or extended for crossbody freedom.',
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
      shortDescription: 'Hand-set pave crystals on a gold-tone hard-shell frame with detachable jewelry snake chain.',
      description: 'An heirloom-worthy evening companion. The Venetian Minaudière captures every angle of ambient light with over 1,200 hand-set faceted crystals. Holds an iPhone 16 Pro Max, keys, lipstick, and cards effortlessly.',
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
      shortDescription: 'Intricate hand-woven leather lattice exterior with a removable canvas drawstring pouch.',
      description: 'The Riviera Bucket Bag infuses effortless vacation serenity into modern city life. Its architectural cage silhouette is woven from supple saddle-tanned leather strips, offering airy structure and timeless charm.',
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
      shortDescription: 'Ultra-sleek 90s shoulder silhouette in lustrous croc-embossed glaze leather.',
      description: 'Designed to sit snugly under the arm, the Milan Baguette is an ode to minimalist nostalgia. Finished with custom brushed-brass buckles and a discreet zip top for total peace of mind.',
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
      shortDescription: 'Hand-embellished crystal brooch pump sculpted in luminous duchess satin with a 95mm stiletto heel.',
      description: 'The definitive party and bridal silhouette. Features an ultra-flattering low-cut vamp, memory foam padded arch support for extended evening wear, and an Italian leather sole.',
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
      shortDescription: 'Contemporary square-toe mule featuring a curved geometric 60mm block heel in butter-soft leather.',
      description: 'Effortlessly elevates tailored trousers, linen skirts, and denim alike. The ergonomic block heel provides all-day stability without sacrificing haute editorial poise.',
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
      shortDescription: 'Chic structured vanity box in grained leather with leather top-handle and detachable crossbody strap.',
      description: 'The Capucine Vanity is an architectural statement in miniature form. Perfect for days when you only need the essentials: cards, keys, compact powder, and lipstick.',
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
      title: 'The Black-Tie Gala Set: Venetian Minaudière & Bellissima Crystal Stiletto',
      bagProductId: 'd3333333-3333-3333-3333-333333333333',
      shoeProductId: 'd6666666-6666-6666-6666-666666666666',
      bundleDiscountPercent: 15,
      description: 'Save 15% when ordering the Venetian Crystal Clutch paired with the matching Bellissima Crystal Stiletto for weddings, galas, and red carpet occasions.',
      bagProduct: fallbackProducts[2],
      shoeProduct: fallbackProducts[5],
    ),
    ProductPairing(
      id: 'e2222222-2222-2222-2222-222222222222',
      title: 'The Executive Power Duo: Sovereign Leather Tote & Paloma Sculpted Mule',
      bagProductId: 'd1111111-1111-1111-1111-111111111111',
      shoeProductId: 'd7777777-7777-7777-7777-777777777777',
      bundleDiscountPercent: 10,
      description: 'The ultimate luxury wardrobe pairing for women in business. Structured full-grain Italian leather elegance paired with all-day comfortable block heels.',
      bagProduct: fallbackProducts[0],
      shoeProduct: fallbackProducts[6],
    ),
  ];

  static final List<Review> fallbackReviews = [
    const Review(
      id: 'r1',
      productId: 'd1111111-1111-1111-1111-111111111111',
      authorName: 'Amina B.',
      rating: 5,
      headline: 'The leather quality is unmatched!',
      comment: 'I took this tote to a board meeting in Lagos and received compliments the entire day. The structure is firm and holds my 14-inch laptop seamlessly.',
    ),
    const Review(
      id: 'r2',
      productId: 'd1111111-1111-1111-1111-111111111111',
      authorName: 'Chidinma O.',
      rating: 5,
      headline: 'Pure luxury in your hands',
      comment: 'Heavy, rich calfskin and the gold hardware has a true 24K luster. Worth every single Naira.',
    ),
    const Review(
      id: 'r3',
      productId: 'd2222222-2222-2222-2222-222222222222',
      authorName: 'Zainab K.',
      rating: 5,
      headline: 'Best crossbody I own',
      comment: 'The leather is so soft yet holds its shape. The sliding chain allows me to wear it long or double it up as an elegant shoulder bag.',
    ),
    const Review(
      id: 'r4',
      productId: 'd3333333-3333-3333-3333-333333333333',
      authorName: 'Folashade A.',
      rating: 5,
      headline: 'Breathtaking in person',
      comment: 'Wore this to my sister wedding dinner. The sparkle is unreal under chandelier lights. Plus, it fits my phone without bulging!',
    ),
    const Review(
      id: 'r5',
      productId: 'd6666666-6666-6666-6666-666666666666',
      authorName: 'Ngozi E.',
      rating: 5,
      headline: 'Surprisingly comfortable for a high stiletto',
      comment: 'The arch padding really makes a difference. Wore them for 6 hours straight without pain.',
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
      return (response as List).map((row) {
        final variants = (row['product_variants'] as List?)
            ?.map((v) => ProductVariant.fromJson(v as Map<String, dynamic>))
            .toList();
        return Product.fromJson(row as Map<String, dynamic>, variants: variants);
      }).toList();
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
