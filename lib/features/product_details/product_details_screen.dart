import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/models.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/products_provider.dart';
import '../../core/providers/wishlist_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../common/announcement_bar.dart';
import '../common/cart_drawer.dart';
import '../common/luxury_bottom_nav.dart';
import '../common/luxury_footer.dart';
import '../common/luxury_header.dart';
import '../../core/utils/fast_image.dart';
import '../../core/utils/shop_image.dart';
import '../../core/utils/shop_video_player.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String slug;

  const ProductDetailsScreen({super.key, required this.slug});

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  Product? _product;
  bool _isLoading = true;
  int _selectedImageIndex = 0;
  String? _selectedColor;
  String? _selectedSize;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  @override
  void didUpdateWidget(covariant ProductDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _loadProduct();
    }
  }

  Future<void> _loadProduct() async {
    setState(() => _isLoading = true);
    final p = await SupabaseService.getProductBySlug(widget.slug);
    setState(() {
      _product = p;
      _isLoading = false;
      _selectedImageIndex = 0;
      if (p != null && p.variants.isNotEmpty) {
        final colorVar = p.variants.where((v) => v.variantType == 'color').firstOrNull;
        _selectedColor = colorVar?.name;
        final sizeVar = p.variants.where((v) => v.variantType == 'size').firstOrNull;
        _selectedSize = sizeVar?.name;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final wishlist = ref.watch(wishlistProvider);
    final pairingsAsync = ref.watch(pairingsProvider);

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGold),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sorry, We Can’t Find This Bag', style: GoogleFonts.cormorantGaramond(fontSize: 28)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/shop'),
                child: const Text('BACK TO SHOP'),
              ),
            ],
          ),
        ),
      );
    }

    final p = _product!;
    final isSaved = wishlist.any((item) => item.id == p.id);
    final colorVariants = p.variants.where((v) => v.variantType == 'color').toList();
    final sizeVariants = p.variants.where((v) => v.variantType == 'size').toList();

    // Matching pairing if applicable
    final matchedPairing = pairingsAsync.value?.where((pair) =>
        pair.bagProductId == p.id || pair.shoeProductId == p.id).firstOrNull;

    return Scaffold(
      bottomNavigationBar: isMobile ? const LuxuryBottomNav() : null,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AnnouncementBar(),
                const LuxuryHeader(),

                // Breadcrumb Bar
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 64,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => context.go('/'),
                        child: Text('HOME', style: GoogleFonts.plusJakartaSans(fontSize: 10, letterSpacing: 1.5, color: AppTheme.textMuted)),
                      ),
                      const Text('  /  ', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                      InkWell(
                        onTap: () => context.go('/shop'),
                        child: Text('CATALOGUE', style: GoogleFonts.plusJakartaSans(fontSize: 10, letterSpacing: 1.5, color: AppTheme.textMuted)),
                      ),
                      const Text('  /  ', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                      Expanded(
                        child: Text(
                          p.title.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Main Product Showcase (Split Gallery & Details)
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 64,
                    vertical: 40,
                  ),
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildGallery(p, isMobile),
                            const SizedBox(height: 32),
                            _buildDetailsPanel(context, ref, p, colorVariants, sizeVariants, isSaved, matchedPairing),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 5, child: _buildGallery(p, isMobile)),
                            const SizedBox(width: 56),
                            Expanded(
                              flex: 5,
                              child: _buildDetailsPanel(context, ref, p, colorVariants, sizeVariants, isSaved, matchedPairing),
                            ),
                          ],
                        ),
                ),

                // Reviews Section
                _buildReviewsSection(context, p, isMobile),

                const SizedBox(height: 48),
                const LuxuryFooter(),
              ],
            ),
          ),

          const CartDrawer(),
        ],
      ),
    );
  }

  Widget _buildGallery(Product p, bool isMobile) {
    final photos = p.photoImages.isNotEmpty ? p.photoImages : [p.primaryImage];
    final hasVideo = p.hasVideo;
    final totalMedia = (hasVideo ? 1 : 0) + photos.length;
    final safeIndex = _selectedImageIndex < totalMedia ? _selectedImageIndex : 0;
    final isShowingVideo = hasVideo && safeIndex == 0;
    final currentPhotoIndex = hasVideo ? (safeIndex - 1).clamp(0, photos.length - 1) : safeIndex;
    final currentImage = photos[currentPhotoIndex];

    return Column(
      children: [
        // Large Hero Media (Live Video or Studio Photo)
        AspectRatio(
          aspectRatio: 0.85,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceGrey,
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            clipBehavior: Clip.antiAlias,
            child: isShowingVideo
                ? ShopVideoPlayer(
                    videoUrl: p.effectiveVideoUrl!,
                    posterUrl: p.primaryImage,
                    autoPlay: true,
                    showControls: true,
                  )
                : ShopImage(fastImg(currentImage, w: 1000, q: 65)),
          ),
        ),
        const SizedBox(height: 16),

        // Thumbnails Strip (Video + Photos)
        if (totalMedia > 1)
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: totalMedia,
              separatorBuilder: (ctx, i) => const SizedBox(width: 12),
              itemBuilder: (ctx, index) {
                final isSelected = index == safeIndex;
                final isVideoThumb = hasVideo && index == 0;
                final photoUrl = isVideoThumb
                    ? p.primaryImage
                    : photos[hasVideo ? index - 1 : index];

                return InkWell(
                  onTap: () => setState(() => _selectedImageIndex = index),
                  child: Container(
                    width: 68,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppTheme.obsidianNoir : AppTheme.borderSubtle,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ShopImage(fastImg(photoUrl, w: 200, q: 60)),
                        if (isVideoThumb)
                          Container(
                            color: Colors.black.withValues(alpha: 0.45),
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_circle_fill, color: AppTheme.primaryGold, size: 24),
                                const SizedBox(height: 2),
                                Text(
                                  'VIDEO',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDetailsPanel(
    BuildContext context,
    WidgetRef ref,
    Product p,
    List<ProductVariant> colors,
    List<ProductVariant> sizes,
    bool isSaved,
    ProductPairing? matchedPairing,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Subtitle
        if (p.subCategory != null)
          Text(
            p.subCategory!.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.primaryGoldDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
        const SizedBox(height: 8),

        // Title
        Text(
          p.title,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),

        // Rating and In-Stock Badge
        Row(
          children: [
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < p.rating.floor() ? Icons.star : Icons.star_half,
                  size: 15,
                  color: AppTheme.primaryGold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${p.rating.toStringAsFixed(1)} (${p.reviewCount} Reviews)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              color: AppTheme.surfaceGrey,
                  child: Row(
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.successGreen, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(
                        'IN STOCK • READY TO SHIP',
                        style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                    ],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Price Block
        Row(
          children: [
            Text(
              p.formattedEffectivePrice,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.obsidianNoir,
              ),
            ),
            if (p.isOnSale) ...[
              const SizedBox(width: 12),
              Text(
                p.formattedBasePrice,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  color: AppTheme.textMuted,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                color: AppTheme.obsidianNoir,
                child: Text(
                  'SAVE ${p.discountPercent}%',
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 20),

        // Short Description
        if (p.shortDescription != null)
          Text(
            p.shortDescription!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppTheme.textDark,
              height: 1.6,
            ),
          ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 20),

        // Color Selection (if bag has color variants)
        if (colors.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHOOSE COLOUR',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
              ),
              if (_selectedColor != null)
                Text(
                  _selectedColor!,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: colors.map((c) {
              final isSelected = _selectedColor == c.name;
              Color circleColor = Colors.grey;
              if (c.colorHex != null) {
                try {
                  final hex = c.colorHex!.replaceAll('#', '');
                  circleColor = Color(int.parse('FF$hex', radix: 16));
                } catch (_) {}
              }
              return InkWell(
                onTap: () => setState(() => _selectedColor = c.name),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.obsidianNoir : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Shoe Size Selection (if product is shoe)
        if (sizes.isNotEmpty || p.productType == 'shoe') ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CHOOSE YOUR SIZE',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
              ),
              InkWell(
                onTap: () => _showSizeGuideModal(context),
                child: Row(
                  children: [
                    const Icon(Icons.straighten, size: 14, color: AppTheme.primaryGoldDark),
                    const SizedBox(width: 4),
                     Text(
                       'WILL IT FIT ME?',
                       style: GoogleFonts.plusJakartaSans(
                         fontSize: 10,
                         fontWeight: FontWeight.w700,
                         color: AppTheme.primaryGoldDark,
                         letterSpacing: 1.0,
                       ),
                     ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (sizes.isNotEmpty ? sizes.map((s) => s.name).toList() : ['EU 37', 'EU 38', 'EU 39', 'EU 40', 'EU 41']).map((sizeName) {
              final isSelected = _selectedSize == sizeName;
              return InkWell(
                onTap: () => setState(() => _selectedSize = sizeName),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.obsidianNoir : Colors.white,
                    border: Border.all(color: isSelected ? AppTheme.obsidianNoir : AppTheme.borderSubtle),
                  ),
                  child: Text(
                    sizeName,
                    style: GoogleFonts.plusJakartaSans(
                      color: isSelected ? Colors.white : AppTheme.obsidianNoir,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Quantity Selector & Action Buttons
        Row(
          children: [
            // Quantity Box
            Container(
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 14),
                    onPressed: () {
                      if (_quantity > 1) setState(() => _quantity--);
                    },
                  ),
                  Text(
                    '$_quantity',
                    style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 14),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Add to Bag CTA
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(cartProvider.notifier).addToCart(
                          p,
                          color: _selectedColor,
                          size: _selectedSize,
                          quantity: _quantity,
                        );
                  },
                  child: const Text('ADD TO BAG'),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Wishlist Toggle
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: IconButton(
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? AppTheme.errorRed : AppTheme.obsidianNoir,
                ),
                tooltip: isSaved ? 'Remove from wishlist' : 'Save to wishlist',
                onPressed: () {
                  ref.read(wishlistProvider.notifier).toggleWishlist(p);
                  final saved = ref.read(wishlistProvider).any((item) => item.id == p.id);
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(saved ? 'Saved to your wishlist.' : 'Removed from wishlist.'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Instant Buy Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).addToCart(
                    p,
                    color: _selectedColor,
                    size: _selectedSize,
                    quantity: _quantity,
                  );
              ref.read(cartProvider.notifier).toggleDrawer(false);
              context.go('/checkout');
            },
            child: const Text('BUY NOW'),
          ),
        ),
        const SizedBox(height: 32),

        // Embedded Complete The Look Card if paired
        if (matchedPairing != null) ...[
          _buildEmbeddedPairingCard(context, ref, matchedPairing),
          const SizedBox(height: 32),
        ],

        // Specifications Accordion
        _buildAccordionTile(
          title: 'SIZE & DETAILS',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.dimensionsCm != null) _specRow('Size', p.dimensionsCm!),
              if (p.strapDropCm != null) _specRow('Handle Drop', '${p.strapDropCm} cm'),
              if (p.heelHeightCm != null) _specRow('Heel Height', '${p.heelHeightCm} cm'),
              if (p.heelType != null) _specRow('Heel Type', p.heelType!),
              if (p.closureType != null) _specRow('How It Closes', p.closureType!),
              if (p.compartmentsInfo != null) _specRow('Inside The Bag', p.compartmentsInfo!),
            ],
          ),
        ),
        _buildAccordionTile(
          title: 'WHAT IS IT MADE OF?',
          content: Text(
            p.material ?? 'Real full-grain Italian leather, soft lining, strong 24K gold locks that will not fade.',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.6, color: AppTheme.textMuted),
          ),
        ),
        _buildAccordionTile(
          title: 'HOW TO CARE FOR IT',
          content: Text(
            p.careInstructions ?? 'Keep in the dust bag we give you. Keep away from water. Clean with soft dry cloth.',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.6, color: AppTheme.textMuted),
          ),
        ),
        _buildAccordionTile(
          title: 'DELIVERY & EASY RETURN',
          content: Text(
            'Free delivery in Lagos for orders above ₦150,000. Delivered in fine gift box in 2-4 days. Not happy? Return within 7 days — chat with us on WhatsApp and we will sort it out. Pay on delivery available in Lagos & Abuja.',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, height: 1.6, color: AppTheme.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmbeddedPairingCard(BuildContext context, WidgetRef ref, ProductPairing pairing) {
    final otherProduct = pairing.bagProductId == _product!.id ? pairing.shoeProduct : pairing.bagProduct;
    if (otherProduct == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.primaryGold, size: 16),
              const SizedBox(width: 8),
              Text(
                'MATCHING SET • SAVE ${pairing.bundleDiscountPercent}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AppTheme.obsidianNoir,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 60,
                height: 72,
                color: Colors.white,
                child: ShopImage(otherProduct.primaryImage),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherProduct.title,
                      style: GoogleFonts.cormorantGaramond(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pairing Price: ${pairing.formattedBundlePrice}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                onPressed: () {
                  ref.read(cartProvider.notifier).addBundleToCart(pairing);
                },
                child: const Text('ADD SET', style: TextStyle(fontSize: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionTile({required String title, required Widget content}) {
    return ExpansionTile(
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
      ),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 16),
      children: [content],
    );
  }

  Widget _buildReviewsSection(BuildContext context, Product p, bool isMobile) {
    return Container(
      color: AppTheme.backgroundLight,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT BUYERS ARE SAYING',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: AppTheme.primaryGoldDark),
          ),
          const SizedBox(height: 6),
          Text(
            'Real Reviews From Real Buyers',
            style: GoogleFonts.cormorantGaramond(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),

          // Sample Reviews list
          ...SupabaseService.fallbackReviews.take(3).map((r) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Row(
                          children: List.generate(r.rating, (_) => const Icon(Icons.star, color: AppTheme.primaryGold, size: 14)),
                        ),
                        const SizedBox(width: 12),
                        Text(r.authorName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          color: AppTheme.surfaceGrey,
                          child: Text('VERIFIED BUYER', style: GoogleFonts.plusJakartaSans(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (r.headline != null)
                      Text(r.headline!, style: GoogleFonts.cormorantGaramond(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(r.comment, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted, height: 1.5)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showSizeGuideModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'What Size Will Fit You?',
            style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our shoes follow normal size. If your foot is wide, or you wear size 40 in Bata / market shoes, take one size up. Still not sure? Chat with us on WhatsApp with your normal size.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                DataTable(
                  columns: const [
                    DataColumn(label: Text('EU')),
                    DataColumn(label: Text('UK')),
                    DataColumn(label: Text('US')),
                    DataColumn(label: Text('Foot (cm)')),
                  ],
                  rows: const [
                    DataRow(cells: [DataCell(Text('36')), DataCell(Text('3')), DataCell(Text('5.5')), DataCell(Text('23.0'))]),
                    DataRow(cells: [DataCell(Text('37')), DataCell(Text('4')), DataCell(Text('6.5')), DataCell(Text('23.7'))]),
                    DataRow(cells: [DataCell(Text('38')), DataCell(Text('5')), DataCell(Text('7.5')), DataCell(Text('24.4'))]),
                    DataRow(cells: [DataCell(Text('39')), DataCell(Text('6')), DataCell(Text('8.5')), DataCell(Text('25.1'))]),
                    DataRow(cells: [DataCell(Text('40')), DataCell(Text('7')), DataCell(Text('9.5')), DataCell(Text('25.8'))]),
                    DataRow(cells: [DataCell(Text('41')), DataCell(Text('8')), DataCell(Text('10.5')), DataCell(Text('26.5'))]),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CLOSE'),
            ),
          ],
        );
      },
    );
  }
}
