import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/models.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/wishlist_provider.dart';
import '../../core/theme/app_theme.dart';

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

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () => context.go('/product/${p.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container with Badges & Wishlist Button
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
                    child: AnimatedScale(
                      scale: _isHovered ? 1.04 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      child: CachedNetworkImage(
                        imageUrl: p.primaryImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.surfaceGrey,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGold),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.surfaceGrey,
                          child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.textMuted),
                        ),
                      ),
                    ),
                  ),

                  // Status Badges (Top Left)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

                  // Wishlist Icon (Top Right)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white.withOpacity(0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          ref.read(wishlistProvider.notifier).toggleWishlist(p);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(7),
                          child: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isSaved ? AppTheme.errorRed : AppTheme.obsidianNoir,
                          ),
                        ),
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
                          color: AppTheme.obsidianNoir.withOpacity(0.95),
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
                Text(
                  p.formattedEffectivePrice,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.obsidianNoir,
                  ),
                ),
                if (p.isOnSale) ...[
                  const SizedBox(width: 8),
                  Text(
                    p.formattedBasePrice,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textMuted,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
                const Spacer(),
                const Icon(Icons.star, size: 13, color: AppTheme.primaryGold),
                const SizedBox(width: 3),
                Text(
                  p.rating.toStringAsFixed(1),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
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
