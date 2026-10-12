import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/models.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/products_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/shop_video_player.dart';

/// Displays all catalogue products that include a live video (`p.hasVideo`).
/// Appears on both the Shop Catalogue page and the Homepage, and automatically
/// includes any new video products added by the store owner in Admin CMS.
class VideoCatalogueShowcase extends ConsumerWidget {
  final bool isCompactHeader;

  const VideoCatalogueShowcase({super.key, this.isCompactHeader = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProductsAsync = ref.watch(allProductsProvider);
    final allProducts = allProductsAsync.maybeWhen(
      data: (items) => items,
      orElse: () => ref.watch(filteredProductsProvider),
    );
    final videoProducts = allProducts.where((p) => p.hasVideo).toList();
    if (videoProducts.isEmpty) return const SizedBox.shrink();

    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      color: AppTheme.obsidianNoir,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 64,
        vertical: isCompactHeader ? 36 : 52,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.play_circle_fill, color: AppTheme.primaryGold, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'LIVE VIDEO CATALOGUE • REAL BAG UNBOXING',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primaryGold,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Watch Before You Buy — What Fits Inside',
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: isMobile ? 26 : 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'See the real leather texture, inner zipper compartments, and everything each tote carries.',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Video Cards Layout: 2-column on desktop, stacked on mobile
          if (isMobile)
            Column(
              children: [
                for (int i = 0; i < videoProducts.length; i++) ...[
                  if (i > 0) const SizedBox(height: 24),
                  _VideoShowcaseCard(product: videoProducts[i], isMobile: true),
                ],
              ],
            )
          else
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                for (final p in videoProducts)
                  SizedBox(
                    width: (MediaQuery.of(context).size.width - 128 - 24) / 2,
                    child: _VideoShowcaseCard(product: p, isMobile: false),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _VideoShowcaseCard extends ConsumerWidget {
  final Product product;
  final bool isMobile;

  const _VideoShowcaseCard({
    required this.product,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = product;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.45)),
      ),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 0.82,
                  child: ShopVideoPlayer(
                    videoUrl: p.effectiveVideoUrl!,
                    posterUrl: p.primaryImage,
                    autoPlay: true,
                    showControls: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildInfoColumn(context, ref, p),
                ),
              ],
            )
          : SizedBox(
              height: 420,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: ShopVideoPlayer(
                      videoUrl: p.effectiveVideoUrl!,
                      posterUrl: p.primaryImage,
                      autoPlay: true,
                      showControls: true,
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildInfoColumn(context, ref, p),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoColumn(BuildContext context, WidgetRef ref, Product p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: AppTheme.primaryGold,
              child: Text(
                p.isOnSale ? 'VIDEO FEATURE • SAVE ${p.discountPercent}%' : 'LIVE VIDEO FEATURE',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.obsidianNoir,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              p.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cormorantGaramond(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  p.formattedEffectivePrice,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.primaryGoldLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (p.isOnSale) ...[
                  const SizedBox(width: 10),
                  Text(
                    p.formattedBasePrice,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white54,
                      fontSize: 13,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              p.shortDescription ?? p.description ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
                fontSize: 12,
                height: 1.55,
              ),
            ),
            if (p.compartmentsInfo != null && p.compartmentsInfo!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, color: AppTheme.primaryGold, size: 15),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      p.compartmentsInfo!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: AppTheme.obsidianNoir,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              icon: const Icon(Icons.shopping_bag_outlined, size: 16),
              label: Text(
                'ADD TO BAG • ${p.formattedEffectivePrice}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                ),
              ),
              onPressed: () {
                ref.read(cartProvider.notifier).addToCart(p);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "${p.title}" to your bag.'),
                    backgroundColor: AppTheme.obsidianNoir,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () => context.go('/product/${p.slug}'),
              child: Text(
                'VIEW FULL DETAILS & PHOTOS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
