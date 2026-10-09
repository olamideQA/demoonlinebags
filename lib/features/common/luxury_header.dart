import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/products_provider.dart';
import '../../core/providers/wishlist_provider.dart';
import '../../core/theme/app_theme.dart';

class LuxuryHeader extends ConsumerWidget implements PreferredSizeWidget {
  const LuxuryHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu, color: AppTheme.obsidianNoir),
              onPressed: () => _showMobileDrawer(context, ref),
            ),

          // Brand Logo
          InkWell(
            onTap: () => context.go('/'),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEMO ONLINE BAGS',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: isMobile ? 20 : 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                    color: AppTheme.obsidianNoir,
                  ),
                ),
                Text(
                  'LUXURY HANDBAGS & FOOTWEAR',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: isMobile ? 8 : 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                    color: AppTheme.primaryGoldDark,
                  ),
                ),
              ],
            ),
          ),

          if (!isMobile)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 32),
                    _NavLink(
                      title: 'BAGS',
                      onTap: () {
                        ref.read(selectedProductTypeProvider.notifier).state = 'bag';
                        ref.read(selectedCategorySlugProvider.notifier).state = null;
                        context.go('/shop');
                      },
                    ),
                    const SizedBox(width: 20),
                    _NavLink(
                      title: 'SHOES',
                      onTap: () {
                        ref.read(selectedProductTypeProvider.notifier).state = 'shoe';
                        ref.read(selectedCategorySlugProvider.notifier).state = null;
                        context.go('/shop');
                      },
                    ),
                    const SizedBox(width: 20),
                    _NavLink(
                      title: 'COMPLETE THE LOOK',
                      isHighlighted: true,
                      onTap: () => context.go('/pairings'),
                    ),
                    const SizedBox(width: 20),
                    _NavLink(
                      title: 'ALL CREATIONS',
                      onTap: () {
                        ref.read(selectedProductTypeProvider.notifier).state = null;
                        ref.read(selectedCategorySlugProvider.notifier).state = null;
                        context.go('/shop');
                      },
                    ),
                    const SizedBox(width: 20),
                    _NavLink(
                      title: 'OUR CRAFT',
                      onTap: () => context.go('/about'),
                    ),
                    const SizedBox(width: 20),
                    _NavLink(
                      title: 'CONCIERGE',
                      onTap: () => context.go('/contact'),
                    ),
                  ],
                ),
              ),
            )
          else
            const Spacer(),

          // Search Button
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.obsidianNoir, size: 22),
            onPressed: () => _showSearchDialog(context, ref),
            tooltip: 'Search creations',
          ),

          // Wishlist Icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: AppTheme.obsidianNoir, size: 22),
                onPressed: () {
                  ref.read(selectedProductTypeProvider.notifier).state = null;
                  context.go('/shop');
                },
                tooltip: 'Saved Wishlist',
              ),
              if (wishlist.isNotEmpty)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGold,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${wishlist.length}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),

          // Cart Icon with Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined, color: AppTheme.obsidianNoir, size: 24),
                onPressed: () {
                  ref.read(cartProvider.notifier).toggleDrawer(true);
                },
                tooltip: 'Shopping Bag',
              ),
              if (cartState.totalItemCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.obsidianNoir,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '${cartState.totalItemCount}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'Search Creations',
            style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. Tote, Stiletto, Crossbody, Leather...',
              prefixIcon: Icon(Icons.search, color: AppTheme.primaryGold),
            ),
            onSubmitted: (value) {
              Navigator.pop(ctx);
              ref.read(searchQueryProvider.notifier).state = value;
              context.go('/shop');
            },
          ),
        );
      },
    );
  }

  void _showMobileDrawer(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEMO ONLINE BAGS',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const Divider(height: 24),
                ListTile(
                  title: const Text('HANDBAGS & TOTES'),
                  leading: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryGold),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref.read(selectedProductTypeProvider.notifier).state = 'bag';
                    context.go('/shop');
                  },
                ),
                ListTile(
                  title: const Text('SCULPTED FOOTWEAR'),
                  leading: const Icon(Icons.flare_outlined, color: AppTheme.primaryGold),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref.read(selectedProductTypeProvider.notifier).state = 'shoe';
                    context.go('/shop');
                  },
                ),
                ListTile(
                  title: const Text('COMPLETE THE LOOK (SETS)'),
                  leading: const Icon(Icons.auto_awesome, color: AppTheme.primaryGold),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go('/pairings');
                  },
                ),
                ListTile(
                  title: const Text('ALL CREATIONS'),
                  leading: const Icon(Icons.grid_view, color: AppTheme.primaryGold),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref.read(selectedProductTypeProvider.notifier).state = null;
                    context.go('/shop');
                  },
                ),
                ListTile(
                  title: const Text('OUR CRAFT & ATELIER'),
                  leading: const Icon(Icons.info_outline, color: AppTheme.primaryGold),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go('/about');
                  },
                ),
                ListTile(
                  title: const Text('VIP CONCIERGE'),
                  leading: const Icon(Icons.support_agent, color: AppTheme.primaryGold),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go('/contact');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NavLink extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _NavLink({
    required this.title,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: isHighlighted ? AppTheme.primaryGoldDark : AppTheme.obsidianNoir,
          ),
        ),
      ),
    );
  }
}
