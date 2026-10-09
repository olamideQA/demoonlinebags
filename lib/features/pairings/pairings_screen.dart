import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/models.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/products_provider.dart';
import '../../core/theme/app_theme.dart';
import '../common/announcement_bar.dart';
import '../common/cart_drawer.dart';
import '../common/luxury_footer.dart';
import '../common/luxury_header.dart';

class PairingsScreen extends ConsumerWidget {
  const PairingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pairingsAsync = ref.watch(pairingsProvider);
    final isMobile = MediaQuery.of(context).size.width < 900;
    final pairings = pairingsAsync.value ?? [];

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AnnouncementBar(),
                const LuxuryHeader(),

                // Hero Banner
                Container(
                  color: AppTheme.obsidianNoir,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 64,
                    vertical: 56,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'THE ART OF THE ENSEMBLE',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Complete The Look: Bags & Footwear',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          color: Colors.white,
                          fontSize: isMobile ? 32 : 46,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Text(
                          'Carefully coordinated accessories crafted in matching leather finishes, tones, and hardware. Enjoy an exclusive 10% to 15% privilege when purchasing matching sets.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pairings List
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 64,
                    vertical: 48,
                  ),
                  child: Column(
                    children: pairings.map((pairing) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 48),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: isMobile
                            ? Column(
                                children: [
                                  _buildPairingImages(pairing),
                                  Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: _buildPairingContent(context, ref, pairing),
                                  ),
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(flex: 5, child: _buildPairingImages(pairing)),
                                  Expanded(
                                    flex: 4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(40),
                                      child: _buildPairingContent(context, ref, pairing),
                                    ),
                                  ),
                                ],
                              ),
                      );
                    }).toList(),
                  ),
                ),

                const LuxuryFooter(),
              ],
            ),
          ),

          const CartDrawer(),
        ],
      ),
    );
  }

  Widget _buildPairingImages(ProductPairing pairing) {
    return Row(
      children: [
        if (pairing.bagProduct != null)
          Expanded(
            child: AspectRatio(
              aspectRatio: 0.85,
              child: Container(
                color: AppTheme.surfaceGrey,
                child: CachedNetworkImage(
                  imageUrl: pairing.bagProduct!.primaryImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        Container(width: 1, color: AppTheme.borderSubtle),
        if (pairing.shoeProduct != null)
          Expanded(
            child: AspectRatio(
              aspectRatio: 0.85,
              child: Container(
                color: AppTheme.surfaceGrey,
                child: CachedNetworkImage(
                  imageUrl: pairing.shoeProduct!.primaryImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPairingContent(BuildContext context, WidgetRef ref, ProductPairing pairing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: AppTheme.primaryGold,
          child: Text(
            'SAVE ${pairing.bundleDiscountPercent}% BUNDLE PRIVILEGE',
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.obsidianNoir,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          pairing.title,
          style: GoogleFonts.cormorantGaramond(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          pairing.description ?? '',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: AppTheme.textMuted,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),

        // Products breakdown list
        if (pairing.bagProduct != null)
          _itemLine(
            'Handbag',
            pairing.bagProduct!.title,
            pairing.bagProduct!.formattedEffectivePrice,
            () => context.go('/product/${pairing.bagProduct!.slug}'),
          ),
        if (pairing.shoeProduct != null)
          _itemLine(
            'Footwear',
            pairing.shoeProduct!.title,
            pairing.shoeProduct!.formattedEffectivePrice,
            () => context.go('/product/${pairing.shoeProduct!.slug}'),
          ),

        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 16),

        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ENSEMBLE PRICE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      pairing.formattedBundlePrice,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.obsidianNoir,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      pairing.formattedOriginalPrice,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppTheme.textMuted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).addBundleToCart(pairing);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ensemble added to shopping bag!')),
              );
            },
            child: const Text('ADD BOTH TO BAG'),
          ),
        ),
      ],
    );
  }

  Widget _itemLine(String type, String title, String price, VoidCallback onView) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            color: AppTheme.surfaceGrey,
            child: Text(type, style: GoogleFonts.plusJakartaSans(fontSize: 9, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: onView,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Text(price, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
