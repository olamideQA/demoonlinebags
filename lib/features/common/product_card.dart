import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/models.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/wishlist_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/shop_image.dart';
import '../../core/utils/shop_video_player.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final wishlist = ref.watch(wishlistProvider);
    final isSaved = wishlist.any((item) => item.id == p.id);

    void toggleSave() {
      ref.read(wishlistProvider.notifier).toggleWishlist(p);
      final saved = ref.read(wishlistProvider).any((item) => item.id == p.id);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(saved ? 'Saved "${p.title}" to your wishlist.' : 'Removed "${p.title}" from wishlist.'),
          duration: const Duration(seconds: 2),
          backgroundColor: AppTheme.obsidianNoir,
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        // Card tap goes to product. Heart/add buttons stop propagation below.
        onTap: () => context.go('/product/${p.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Video Container with Badges & Wishlist Button
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGrey,
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: p.hasVideo
                        ? ShopVideoPlayer(
                            videoUrl: p.effectiveVideoUrl!,
                            posterUrl: p.primaryImage,
                            autoPlay: true,
                            showControls: true,
                            compactControls: true,
                          )
                        : AnimatedScale(
                            scale: _isHovered ? 1.04 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: ShopImage(p.primaryImage, w: 600, q: 60),
                          ),
                  ),

                  // Status Badges (Top Left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (p.hasVideo)
                          const _Badge(
                            text: '▶ VIDEO SHOWCASE',
                            bgColor: AppTheme.primaryGold,
                            textColor: AppTheme.obsidianNoir,
                          ),
                        if (p.isOnSale)
                          _Badge(
                            text: 'SAVE ${p.discountPercent}%',
                            bgColor: AppTheme.obsidianNoir,
                            textColor: Colors.white,
                          ),
                        if (p.isBestseller && !p.isOnSale)
                          const _Badge(
                            text: 'BESTSELLER',
                            bgColor: AppTheme.primaryGold,
                            textColor: AppTheme.obsidianNoir,
                          ),
                        if (p.isNewArrival && !p.isBestseller && !p.isOnSale)
                          const _Badge(
                            text: 'NEW ARRIVAL',
                            bgColor: Colors.white,
                            textColor: AppTheme.obsidianNoir,
                          ),
                      ],
                    ),
                  ),

                  // Wishlist heart (Top Right) - IconButton wins gesture arena,
                  // never swallowed by card tap. Always tappable on touch + web.
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.95),
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        iconSize: 18,
                        padding: const EdgeInsets.all(7),
                        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                        icon: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: isSaved ? AppTheme.errorRed : AppTheme.obsidianNoir,
                        ),
                        tooltip: isSaved ? 'Remove from wishlist' : 'Save to wishlist',
                        onPressed: toggleSave,
                      ),
                    ),
                  ),
                  // Always-visible quick add (bottom-right) for touch phones
                  // where hover never fires. Desktop keeps hover bar too.
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Material(
                      color: AppTheme.obsidianNoir.withValues(alpha: 0.92),
                      shape: const CircleBorder(),
                      elevation: 2,
                      child: IconButton(
                        iconSize: 16,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                        tooltip: 'Quick add to bag',
                        onPressed: () {
                          ref.read(cartProvider.notifier).addToCart(p);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added "${p.title}" to bag.'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppTheme.obsidianNoir,
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Quick "Add to Bag" bar appearing on hover
                  if (_isHovered)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          ref.read(cartProvider.notifier).addToCart(p);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added "${p.title}" to bag.'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: AppTheme.obsidianNoir,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          color: AppTheme.obsidianNoir.withValues(alpha: 0.95),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 14),
                              const SizedBox(width: 8),
                              Text(
                                'QUICK ADD TO BAG',
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Product Details Text
            if (p.subCategory != null)
              Text(
                p.subCategory!.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              p.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.obsidianNoir,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p.formattedEffectivePrice,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.obsidianNoir,
                        ),
                      ),
                      if (p.isOnSale) ...[
                        const SizedBox(width: 6),
                        Text(
                          p.formattedBasePrice,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.textMuted,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 12, color: AppTheme.primaryGold),
                    const SizedBox(width: 2),
                    Text(
                      p.rating.toStringAsFixed(1),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bgColor;
  final Color textColor;

  const _Badge({
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.zero,
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
