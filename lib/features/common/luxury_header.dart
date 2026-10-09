import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/products_provider.dart';
import '../../core/providers/site_settings_provider.dart';
import '../../core/providers/wishlist_provider.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_modal.dart';

class LuxuryHeader extends ConsumerWidget implements PreferredSizeWidget {
  const LuxuryHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final authState = ref.watch(authProvider);
    final siteSettings = ref.watch(siteSettingsProvider);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
      ),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24, vertical: isMobile ? 8 : 12),
      child: Row(
        children: [
          if (isMobile)
            IconButton(
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(Icons.menu, color: AppTheme.obsidianNoir),
              onPressed: () => _showMobileDrawer(context, ref, authState),
            ),

          // Brand Logo & Tagline (Dynamic from CMS)
          Flexible(
            child: InkWell(
              onTap: () => context.go('/'),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    siteSettings.header.brandName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: isMobile ? 16 : 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: isMobile ? 1.4 : 2.2,
                      color: AppTheme.obsidianNoir,
                    ),
                  ),
                  Text(
                    siteSettings.header.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: isMobile ? 7.5 : 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: isMobile ? 1.0 : 1.8,
                      color: AppTheme.primaryGoldDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (!isMobile)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 28),
                    _NavLink(
                      title: 'SHOP',
                      isHighlighted: true,
                      onTap: () {
                        ref.read(selectedProductTypeProvider.notifier).state = null;
                        ref.read(selectedCategorySlugProvider.notifier).state = null;
                        context.go('/shop');
                      },
                    ),
                    const SizedBox(width: 18),
                    _NavLink(
                      title: 'BAGS',
                      onTap: () {
                        ref.read(selectedProductTypeProvider.notifier).state = 'bag';
                        ref.read(selectedCategorySlugProvider.notifier).state = null;
                        context.go('/shop');
                      },
                    ),
                    const SizedBox(width: 18),
                    _NavLink(
                      title: 'SHOES',
                      onTap: () {
                        ref.read(selectedProductTypeProvider.notifier).state = 'shoe';
                        ref.read(selectedCategorySlugProvider.notifier).state = null;
                        context.go('/shop');
                      },
                    ),
                    const SizedBox(width: 18),
                    _NavLink(
                      title: 'MATCHING SETS',
                      onTap: () => context.go('/pairings'),
                    ),
                    const SizedBox(width: 18),
                    _NavLink(
                      title: 'OUR STORY',
                      onTap: () => context.go('/about'),
                    ),
                    const SizedBox(width: 18),
                    _NavLink(
                      title: 'CHAT WITH US',
                      onTap: () => context.go('/contact'),
                    ),
                    if (authState.isAuthenticated) ...[
                      const SizedBox(width: 18),
                      _NavLink(
                        title: 'MY DASHBOARD',
                        isHighlighted: true,
                        onTap: () => context.go('/account'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            const Spacer(),

          // Admin Direct Access Badge (If Admin)
          if (authState.isAdmin && !isMobile) ...[
            InkWell(
              onTap: () => context.go('/admin'),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.obsidianNoir,
                  border: Border.all(color: AppTheme.primaryGold, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.admin_panel_settings, size: 15, color: AppTheme.primaryGold),
                    const SizedBox(width: 6),
                    Text(
                      'ADMIN CMS',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryGold,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Search Button
          IconButton(
            padding: EdgeInsets.all(isMobile ? 5 : 8),
            constraints: BoxConstraints(minWidth: isMobile ? 32 : 44, minHeight: isMobile ? 32 : 44),
            icon: Icon(Icons.search, color: AppTheme.obsidianNoir, size: isMobile ? 20 : 22),
            onPressed: () => _showSearchDialog(context, ref),
            tooltip: 'Search bags & shoes',
          ),

          // Wishlist Icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                padding: EdgeInsets.all(isMobile ? 5 : 8),
                constraints: BoxConstraints(minWidth: isMobile ? 32 : 44, minHeight: isMobile ? 32 : 44),
                icon: Icon(Icons.favorite_border, color: AppTheme.obsidianNoir, size: isMobile ? 20 : 22),
                onPressed: () {
                  ref.read(selectedProductTypeProvider.notifier).state = null;
                  context.go('/shop');
                },
                tooltip: 'Saved Wishlist',
              ),
              if (wishlist.isNotEmpty)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGold,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                    child: Text(
                      '${wishlist.length}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 8.5,
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
                padding: EdgeInsets.all(isMobile ? 5 : 8),
                constraints: BoxConstraints(minWidth: isMobile ? 32 : 44, minHeight: isMobile ? 32 : 44),
                icon: Icon(Icons.shopping_bag_outlined, color: AppTheme.obsidianNoir, size: isMobile ? 21 : 24),
                onPressed: () {
                  ref.read(cartProvider.notifier).toggleDrawer(true);
                },
                tooltip: 'Shopping Bag',
              ),
              if (cartState.totalItemCount > 0)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppTheme.obsidianNoir,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cartState.totalItemCount}',
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

          // Account / Profile Icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                padding: EdgeInsets.all(isMobile ? 5 : 8),
                constraints: BoxConstraints(minWidth: isMobile ? 32 : 44, minHeight: isMobile ? 32 : 44),
                icon: Icon(
                  authState.isAuthenticated ? Icons.person : Icons.person_outline_rounded,
                  color: authState.isAdmin ? AppTheme.primaryGoldDark : AppTheme.obsidianNoir,
                  size: isMobile ? 21 : 24,
                ),
                onPressed: () => AuthModal.show(context),
                tooltip: authState.isAuthenticated
                    ? (authState.isAdmin ? 'Store Admin' : 'Account: ${authState.profile?.fullName ?? ''}')
                    : 'Sign In / Create Account',
              ),
              if (authState.isAuthenticated)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: authState.isAdmin ? AppTheme.primaryGold : AppTheme.successGreen,
                      shape: BoxShape.circle,
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
            'Search Bags & Shoes',
            style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Try tote, clutch, black, heels...',
              prefixIcon: Icon(Icons.search),
            ),
            onSubmitted: (query) {
              Navigator.pop(ctx);
              ref.read(searchQueryProvider.notifier).state = query;
              ref.read(selectedProductTypeProvider.notifier).state = null;
              context.go('/shop');
            },
          ),
        );
      },
    );
  }

  void _showMobileDrawer(BuildContext context, WidgetRef ref, AppAuthState authState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) {
        final siteSettings = ref.read(siteSettingsProvider);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    siteSettings.header.brandName,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    siteSettings.header.tagline,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryGoldDark,
                    ),
                  ),
                  const Divider(height: 24),

                  // Account / Sign In / Dashboard
                  if (authState.isAuthenticated) ...[
                    ListTile(
                      title: Text(
                        'MY CLIENT DASHBOARD',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1.0,
                          color: AppTheme.obsidianNoir,
                        ),
                      ),
                      subtitle: Text(
                        'Orders, Wishlist & Profile (${authState.profile?.fullName ?? authState.user?.email ?? 'Member'})',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppTheme.textMuted),
                      ),
                      leading: const Icon(Icons.dashboard_outlined, color: AppTheme.primaryGold),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.go('/account');
                      },
                    ),
                    if (authState.isAdmin)
                      Container(
                        color: AppTheme.obsidianNoir,
                        margin: const EdgeInsets.only(top: 4, bottom: 4),
                        child: ListTile(
                          title: Text(
                            'ADMIN DASHBOARD',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                              color: AppTheme.primaryGold,
                            ),
                          ),
                          subtitle: Text(
                            'Website copy, products & order fulfillment',
                            style: GoogleFonts.plusJakartaSans(fontSize: 9.5, color: Colors.white70),
                          ),
                          leading: const Icon(Icons.admin_panel_settings, color: AppTheme.primaryGold),
                          onTap: () {
                            Navigator.pop(ctx);
                            context.go('/admin');
                          },
                        ),
                      ),
                  ] else ...[
                    ListTile(
                      title: Text(
                        'SIGN IN / JOIN US',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.obsidianNoir,
                        ),
                      ),
                      subtitle: Text(
                        'Track orders, save favourites & get 10% off',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppTheme.textMuted),
                      ),
                      leading: const Icon(Icons.person_outline, color: AppTheme.obsidianNoir),
                      onTap: () {
                        Navigator.pop(ctx);
                        AuthModal.show(context);
                      },
                    ),
                    ListTile(
                      title: Text(
                        'ADMIN BACK-OFFICE ACCESS',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                          color: AppTheme.primaryGoldDark,
                        ),
                      ),
                      leading: const Icon(Icons.lock_outline, size: 18, color: AppTheme.primaryGoldDark),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.go('/admin');
                      },
                    ),
                  ],

                  const Divider(height: 16),
                  Container(
                    color: AppTheme.surfaceGrey,
                    child: ListTile(
                      title: Text(
                        'SHOP EVERYTHING',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          letterSpacing: 1.2,
                          color: AppTheme.obsidianNoir,
                        ),
                      ),
                      subtitle: Text(
                        'See all bags & shoes',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textMuted),
                      ),
                      leading: const Icon(Icons.storefront, color: AppTheme.primaryGold),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.primaryGold),
                      onTap: () {
                        Navigator.pop(ctx);
                        ref.read(selectedProductTypeProvider.notifier).state = null;
                        ref.read(selectedCategorySlugProvider.notifier).state = null;
                        context.go('/shop');
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    title: const Text('BAGS & TOTES'),
                    leading: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryGold),
                    onTap: () {
                      Navigator.pop(ctx);
                      ref.read(selectedProductTypeProvider.notifier).state = 'bag';
                      context.go('/shop');
                    },
                  ),
                  ListTile(
                    title: const Text('SHOES & HEELS'),
                    leading: const Icon(Icons.flare_outlined, color: AppTheme.primaryGold),
                    onTap: () {
                      Navigator.pop(ctx);
                      ref.read(selectedProductTypeProvider.notifier).state = 'shoe';
                      context.go('/shop');
                    },
                  ),
                  ListTile(
                    title: const Text('MATCHING BAG + SHOE SETS'),
                    leading: const Icon(Icons.auto_awesome, color: AppTheme.primaryGold),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/pairings');
                    },
                  ),
                  ListTile(
                    title: const Text('SHOP EVERYTHING'),
                    leading: const Icon(Icons.grid_view, color: AppTheme.primaryGold),
                    onTap: () {
                      Navigator.pop(ctx);
                      ref.read(selectedProductTypeProvider.notifier).state = null;
                      context.go('/shop');
                    },
                  ),
                  ListTile(
                    title: const Text('OUR STORY'),
                    leading: const Icon(Icons.info_outline, color: AppTheme.primaryGold),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/about');
                    },
                  ),
                  ListTile(
                    title: const Text('CHAT ON WHATSAPP'),
                    leading: const Icon(Icons.support_agent, color: AppTheme.primaryGold),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go('/contact');
                    },
                  ),
                ],
              ),
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
