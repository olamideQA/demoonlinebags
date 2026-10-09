import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/models.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/products_provider.dart';
import '../../core/providers/site_settings_provider.dart';
import '../../core/theme/app_theme.dart';
import '../common/announcement_bar.dart';
import '../common/cart_drawer.dart';
import '../common/luxury_footer.dart';
import '../common/luxury_header.dart';
import '../common/product_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);
    final pairingsAsync = ref.watch(pairingsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final isMobile = MediaQuery.of(context).size.width < 900;

    final bagProducts = products.where((p) => p.productType == 'bag').take(6).toList();
    final shoeProducts = products.where((p) => p.productType == 'shoe').take(4).toList();

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AnnouncementBar(),
                const LuxuryHeader(),

                // 1. Editorial Hero Section
                _buildHeroSection(context, ref, isMobile),

                // 2. Category Highlights
                _buildCategorySpotlights(context, ref, categoriesAsync, isMobile),

                // 3. Featured Handbags Section
                _buildHandbagsSection(context, ref, bagProducts, isMobile),

                // 4. "Complete The Look" Ensembles (Bags + Shoes Pairings)
                _buildPairingsSection(context, ref, pairingsAsync, isMobile),

                // 5. The Shoe Salon Section
                _buildShoeSalonSection(context, ref, shoeProducts, isMobile),

                // 6. Brand Craftsmanship & Atelier Heritage
                _buildCraftsmanshipBanner(context, isMobile),

                // 7. Verified Client Reviews
                _buildClientReviews(context, isMobile),

                // 8. Footer
                const LuxuryFooter(),
              ],
            ),
          ),

          // Slide-Over Bag Drawer
          const CartDrawer(),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, WidgetRef ref, bool isMobile) {
    final hero = ref.watch(siteSettingsProvider).hero;

    return Container(
      height: isMobile ? 540 : 660,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.obsidianNoir,
        image: DecorationImage(
          image: CachedNetworkImageProvider(hero.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.75),
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 72,
          vertical: 48,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: AppTheme.primaryGold,
              child: Text(
                hero.badge,
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.obsidianNoir,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hero.title,
              style: GoogleFonts.cormorantGaramond(
                color: Colors.white,
                fontSize: isMobile ? 36 : 56,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Text(
                hero.subtitle,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: isMobile ? 13 : 15,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.obsidianNoir,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  ),
                  onPressed: () {
                    if (hero.ctaUrl.contains('category')) {
                      ref.read(selectedProductTypeProvider.notifier).state = 'bag';
                    }
                    context.go(hero.ctaUrl);
                  },
                  child: Text(hero.ctaText),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  ),
                  onPressed: () => context.go(hero.secondaryCtaUrl),
                  child: Text(hero.secondaryCtaText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySpotlights(BuildContext context, WidgetRef ref, AsyncValue<List<Category>> categoriesAsync, bool isMobile) {
    final categories = categoriesAsync.value ?? [];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURATED SILHOUETTES',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryGoldDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
              InkWell(
                onTap: () => context.go('/shop'),
                child: Row(
                  children: [
                    Text(
                      'VIEW ALL',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 14),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Explore by Silhouette',
            style: GoogleFonts.cormorantGaramond(
              fontSize: isMobile ? 28 : 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 28),

          // Horizontal Category Strip
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (ctx, index) {
                final cat = categories[index];
                return InkWell(
                  onTap: () {
                    ref.read(selectedCategorySlugProvider.notifier).state = cat.slug;
                    ref.read(selectedProductTypeProvider.notifier).state = cat.type == 'shoes' ? 'shoe' : 'bag';
                    context.go('/shop');
                  },
                  child: Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGrey,
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Stack(
                      children: [
                        if (cat.imageUrl != null)
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: cat.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.75),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          left: 14,
                          right: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                cat.type == 'shoes' ? 'Footwear' : 'Handbags',
                                style: GoogleFonts.plusJakartaSans(
                                  color: AppTheme.primaryGoldLight,
                                  fontSize: 10,
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
      ),
    );
  }

  Widget _buildHandbagsSection(BuildContext context, WidgetRef ref, List<Product> bags, bool isMobile) {
    return Container(
      color: AppTheme.backgroundLight,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIGNATURE PIECES',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.primaryGoldDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'The Handbag Collection',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: isMobile ? 30 : 38,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  ref.read(selectedProductTypeProvider.notifier).state = 'bag';
                  context.go('/shop');
                },
                child: const Text('VIEW ALL BAGS'),
              ),
            ],
          ),
          const SizedBox(height: 36),

          // Responsive Grid for Bags
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : (MediaQuery.of(context).size.width > 1200 ? 4 : 3),
              crossAxisSpacing: 20,
              mainAxisSpacing: 32,
              childAspectRatio: 0.62,
            ),
            itemCount: bags.length,
            itemBuilder: (ctx, index) => ProductCard(product: bags[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildPairingsSection(BuildContext context, WidgetRef ref, AsyncValue<List<ProductPairing>> pairingsAsync, bool isMobile) {
    final pairings = pairingsAsync.value ?? [];
    if (pairings.isEmpty) return const SizedBox.shrink();

    final featuredPairing = pairings.first;

    return Container(
      color: AppTheme.surfaceDark,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 64),
      child: Column(
        children: [
          Text(
            'THE HARMONY OF ACCESSORIES',
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.primaryGold,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete The Look: Bags & Shoes',
            textAlign: TextAlign.center,
            style: GoogleFonts.cormorantGaramond(
              color: Colors.white,
              fontSize: isMobile ? 30 : 42,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'Curated luxury ensembles combining matching leather textures, hardware finishes, and colors. Receive an automatic 10-15% privilege when ordering both.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.textMuted,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 48),

          // Ensemble Display Box
          Container(
            decoration: BoxDecoration(
              color: AppTheme.obsidianNoir,
              border: Border.all(color: AppTheme.borderStrong),
            ),
            padding: EdgeInsets.all(isMobile ? 20 : 36),
            child: isMobile
                ? Column(
                    children: [
                      _buildPairingImages(featuredPairing),
                      const SizedBox(height: 24),
                      _buildPairingDetails(context, ref, featuredPairing),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(flex: 5, child: _buildPairingImages(featuredPairing)),
                      const SizedBox(width: 48),
                      Expanded(flex: 4, child: _buildPairingDetails(context, ref, featuredPairing)),
                    ],
                  ),
          ),
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
              aspectRatio: 0.8,
              child: Container(
                color: AppTheme.surfaceDark,
                child: CachedNetworkImage(
                  imageUrl: pairing.bagProduct!.primaryImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        const SizedBox(width: 12),
        if (pairing.shoeProduct != null)
          Expanded(
            child: AspectRatio(
              aspectRatio: 0.8,
              child: Container(
                color: AppTheme.surfaceDark,
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

  Widget _buildPairingDetails(BuildContext context, WidgetRef ref, ProductPairing pairing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: AppTheme.primaryGold,
          child: Text(
            'SAVE ${pairing.bundleDiscountPercent}% PRIVILEGE',
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
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          pairing.description ?? '',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.textMuted,
            fontSize: 12,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              pairing.formattedBundlePrice,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              pairing.formattedOriginalPrice,
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.textMuted,
                fontSize: 15,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: AppTheme.obsidianNoir,
              ),
              onPressed: () {
                ref.read(cartProvider.notifier).addBundleToCart(pairing);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Matching ensemble added to bag!')),
                );
              },
              child: const Text('ADD BOTH TO BAG'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: AppTheme.borderStrong),
              ),
              onPressed: () => context.go('/pairings'),
              child: const Text('VIEW ALL ENSEMBLES'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShoeSalonSection(BuildContext context, WidgetRef ref, List<Product> shoes, bool isMobile) {
    if (shoes.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 56),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COMPLEMENTARY SILHOUETTES',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.primaryGoldDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'The Footwear Salon',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: isMobile ? 30 : 38,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  ref.read(selectedProductTypeProvider.notifier).state = 'shoe';
                  context.go('/shop');
                },
                child: const Text('EXPLORE FOOTWEAR'),
              ),
            ],
          ),
          const SizedBox(height: 36),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : (MediaQuery.of(context).size.width > 1200 ? 4 : 2),
              crossAxisSpacing: 20,
              mainAxisSpacing: 32,
              childAspectRatio: 0.62,
            ),
            itemCount: shoes.length,
            itemBuilder: (ctx, index) => ProductCard(product: shoes[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildCraftsmanshipBanner(BuildContext context, bool isMobile) {
    return Container(
      color: AppTheme.surfaceGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 72, vertical: 64),
      child: isMobile
          ? Column(
              children: [
                _buildCraftsmanshipText(),
                const SizedBox(height: 32),
                _buildCraftsmanshipImage(),
              ],
            )
          : Row(
              children: [
                Expanded(flex: 5, child: _buildCraftsmanshipText()),
                const SizedBox(width: 64),
                Expanded(flex: 5, child: _buildCraftsmanshipImage()),
              ],
            ),
    );
  }

  Widget _buildCraftsmanshipText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE ATELIER HERITAGE',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.primaryGoldDark,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Artisanal Passion.\nFull-Grain Mastery.',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'At DEMO ONLINE BAGS, every stitch is an investment in timeless permanence. We source exclusively from certified Florentine and Vicenza tanneries, selecting only supple full-grain calfskins and velvet-soft lambskins.',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.textDark,
            fontSize: 14,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Our bespoke locksets and chains are plated in 24K gold and rhodium to resist tarnishing in tropical and coastal climates. Experience luxury designed to be cherished for generations.',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.textMuted,
            fontSize: 13,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildCraftsmanshipImage() {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: 'https://images.unsplash.com/photo-1590874103328-eac38a683ce7?auto=format&fit=crop&w=1000&q=80',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildClientReviews(BuildContext context, bool isMobile) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 56),
      child: Column(
        children: [
          Text(
            'TESTIMONIALS',
            style: GoogleFonts.plusJakartaSans(
              color: AppTheme.primaryGoldDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Adored by Discerning Women',
            style: GoogleFonts.cormorantGaramond(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 36),

          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: const [
              _ReviewBox(
                quote: '“The Sovereign Tote was the centerpiece of my executive conference. The calfskin is thick, rich, and retains structure impeccably.”',
                author: 'Amina B.',
                location: 'Victoria Island, Lagos',
              ),
              _ReviewBox(
                quote: '“I ordered the Venetian Crystal Minaudière with the Bellissima crystal stilettos for my sister gala. Stunning synergy and compliments all night!”',
                author: 'Folashade A.',
                location: 'Abuja, FCT',
              ),
              _ReviewBox(
                quote: '“The attention to hardware weight and stitch alignment is equivalent to high European fashion houses. Truly top notch.”',
                author: 'Zainab K.',
                location: 'Ikoyi, Lagos',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewBox extends StatelessWidget {
  final String quote;
  final String author;
  final String location;

  const _ReviewBox({
    required this.quote,
    required this.author,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              5,
              (_) => const Icon(Icons.star, color: AppTheme.primaryGold, size: 16),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            quote,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            author,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            location,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
