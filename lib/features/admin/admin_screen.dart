import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/models.dart';
import '../../core/models/site_settings.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/products_provider.dart';
import '../../core/providers/site_settings_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/shop_image.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminNavItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final IconData activeIcon;

  const _AdminNavItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.activeIcon,
  });
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _selectedSection = 0;

  static const List<_AdminNavItem> _navItems = [
    _AdminNavItem(
      label: 'Overview',
      subtitle: 'Sales, alerts & quick actions',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
    ),
    _AdminNavItem(
      label: 'Products & Videos',
      subtitle: 'Bags, shoes, photos & MP4 videos',
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag,
    ),
    _AdminNavItem(
      label: 'Orders',
      subtitle: 'Customer purchases & delivery status',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
    ),
    _AdminNavItem(
      label: 'Matching Sets',
      subtitle: 'Bag + shoe combo discounts',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome,
    ),
    _AdminNavItem(
      label: 'Promo Codes',
      subtitle: 'Checkout coupon codes',
      icon: Icons.local_offer_outlined,
      activeIcon: Icons.local_offer,
    ),
    _AdminNavItem(
      label: 'Website & Banners',
      subtitle: 'Homepage slides, text & WhatsApp',
      icon: Icons.web_outlined,
      activeIcon: Icons.web,
    ),
  ];

  // Security Gate Controllers
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  bool _obscureAdminPassword = true;
  String? _gateError;
  bool _isLoggingIn = false;

  // Product Filter & Search State
  final _productSearchCtrl = TextEditingController();
  String _productSearchQuery = '';
  String _productFilter = 'all'; // 'all', 'bag', 'shoe', 'video', 'low_stock'

  // Order Filter State
  String _orderStatusFilter = 'all';

  // CMS Sub-tab State
  int _cmsSubTab = 0; // 0: Banners, 1: Brand & Notice, 2: Contact & Shipping

  // CMS Form Controllers
  late TextEditingController _announcementTextCtrl;
  bool _announcementActive = true;
  late TextEditingController _headerBrandCtrl;
  late TextEditingController _headerTaglineCtrl;
  late TextEditingController _heroBadgeCtrl;
  late TextEditingController _heroTitleCtrl;
  late TextEditingController _heroSubtitleCtrl;
  late TextEditingController _heroCtaTextCtrl;
  late TextEditingController _heroCtaUrlCtrl;
  late TextEditingController _heroSecondaryTextCtrl;
  late TextEditingController _heroSecondaryUrlCtrl;
  late TextEditingController _heroImageCtrl;
  late TextEditingController _footerBioCtrl;
  late TextEditingController _footerEmailCtrl;
  late TextEditingController _footerPhoneCtrl;
  late TextEditingController _footerWhatsappCtrl;
  late TextEditingController _footerAddressCtrl;
  late TextEditingController _footerCopyrightCtrl;
  late TextEditingController _currencySymbolCtrl;
  late TextEditingController _freeShippingCtrl;

  bool _isSavingCMS = false;
  List<Map<String, dynamic>> _ordersList = [];
  bool _isLoadingOrders = false;

  @override
  void initState() {
    super.initState();
    _initCMSControllers();
    _loadOrders();
  }

  void _initCMSControllers() {
    final settings = ref.read(siteSettingsProvider);
    _announcementTextCtrl = TextEditingController(text: settings.announcement.text);
    _announcementActive = settings.announcement.isActive;
    _headerBrandCtrl = TextEditingController(text: settings.header.brandName);
    _headerTaglineCtrl = TextEditingController(text: settings.header.tagline);
    _heroBadgeCtrl = TextEditingController(text: settings.hero.badge);
    _heroTitleCtrl = TextEditingController(text: settings.hero.title);
    _heroSubtitleCtrl = TextEditingController(text: settings.hero.subtitle);
    _heroCtaTextCtrl = TextEditingController(text: settings.hero.ctaText);
    _heroCtaUrlCtrl = TextEditingController(text: settings.hero.ctaUrl);
    _heroSecondaryTextCtrl = TextEditingController(text: settings.hero.secondaryCtaText);
    _heroSecondaryUrlCtrl = TextEditingController(text: settings.hero.secondaryCtaUrl);
    _heroImageCtrl = TextEditingController(text: settings.hero.imageUrl);
    _footerBioCtrl = TextEditingController(text: settings.footer.bio);
    _footerEmailCtrl = TextEditingController(text: settings.footer.email);
    _footerPhoneCtrl = TextEditingController(text: settings.footer.phone);
    _footerWhatsappCtrl = TextEditingController(text: settings.footer.whatsapp);
    _footerAddressCtrl = TextEditingController(text: settings.footer.address);
    _footerCopyrightCtrl = TextEditingController(text: settings.footer.copyright);
    _currencySymbolCtrl = TextEditingController(text: settings.general.currencySymbol);
    _freeShippingCtrl = TextEditingController(text: settings.general.freeShippingThreshold.toStringAsFixed(0));
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoadingOrders = true);
    final orders = await SupabaseService.getOrders();
    if (mounted) {
      setState(() {
        _ordersList = orders;
        _isLoadingOrders = false;
      });
    }
  }

  @override
  void dispose() {
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    _productSearchCtrl.dispose();
    _announcementTextCtrl.dispose();
    _headerBrandCtrl.dispose();
    _headerTaglineCtrl.dispose();
    _heroBadgeCtrl.dispose();
    _heroTitleCtrl.dispose();
    _heroSubtitleCtrl.dispose();
    _heroCtaTextCtrl.dispose();
    _heroCtaUrlCtrl.dispose();
    _heroSecondaryTextCtrl.dispose();
    _heroSecondaryUrlCtrl.dispose();
    _heroImageCtrl.dispose();
    _footerBioCtrl.dispose();
    _footerEmailCtrl.dispose();
    _footerPhoneCtrl.dispose();
    _footerWhatsappCtrl.dispose();
    _footerAddressCtrl.dispose();
    _footerCopyrightCtrl.dispose();
    _currencySymbolCtrl.dispose();
    _freeShippingCtrl.dispose();
    super.dispose();
  }

  String _formatNaira(double v) {
    final n = v.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < n.length; i++) {
      if (i > 0 && (n.length - i) % 3 == 0) buf.write(',');
      buf.write(n[i]);
    }
    return '₦$buf';
  }

  Widget _responsiveFields(bool isMobile, List<Widget> fields, {double spacing = 14}) {
    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < fields.length; i++) ...[
            if (i > 0) SizedBox(height: spacing),
            fields[i],
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < fields.length; i++) ...[
          if (i > 0) SizedBox(width: spacing),
          Expanded(child: fields[i]),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Security Gate: exclusive to verified admin
    if (!authState.isAuthenticated || !authState.isAdmin) {
      return _buildSecurityGate(context, authState);
    }

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 960;
    final isMobile = width < 680;
    final products = ref.watch(allProductsProvider).value ?? SupabaseService.fallbackProducts;
    final pendingOrdersCount = _ordersList.where((o) {
      final st = (o['status']?.toString() ?? 'pending').toLowerCase();
      return st == 'pending' || st == 'processing';
    }).length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F5F2),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppTheme.obsidianNoir,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.primaryGold),
                tooltip: 'Open Admin Menu',
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STORE MANAGER',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.8,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  Text(
                    _navItems[_selectedSection].label,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: 'Add Product / Video',
                  icon: const Icon(Icons.add_box_outlined, color: AppTheme.primaryGold),
                  onPressed: () => _showProductDialog(context, null),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.storefront_outlined, size: 16, color: Colors.white70),
                  label: Text(
                    'SHOP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
      drawer: isDesktop
          ? null
          : Drawer(
              backgroundColor: AppTheme.obsidianNoir,
              child: SafeArea(
                child: _buildSidebarContent(
                  context,
                  authState: authState,
                  productCount: products.length,
                  pendingOrdersCount: pendingOrdersCount,
                  isDrawer: true,
                ),
              ),
            ),
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: SafeArea(
                child: BottomNavigationBar(
                  currentIndex: _selectedSection < 4 ? _selectedSection : 4,
                  onTap: (idx) {
                    if (idx < 4) {
                      setState(() => _selectedSection = idx);
                    } else {
                      _showMobileMoreSheet(context);
                    }
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: AppTheme.obsidianNoir,
                  unselectedItemColor: AppTheme.textMuted,
                  selectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w800),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w500),
                  elevation: 0,
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_outlined, size: 20),
                      activeIcon: Icon(Icons.dashboard, size: 20, color: AppTheme.primaryGoldDark),
                      label: 'Overview',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_bag_outlined, size: 20),
                      activeIcon: Icon(Icons.shopping_bag, size: 20, color: AppTheme.primaryGoldDark),
                      label: 'Products',
                    ),
                    BottomNavigationBarItem(
                      icon: Badge(
                        isLabelVisible: pendingOrdersCount > 0,
                        label: Text('$pendingOrdersCount'),
                        backgroundColor: AppTheme.errorRed,
                        child: const Icon(Icons.receipt_long_outlined, size: 20),
                      ),
                      activeIcon: const Icon(Icons.receipt_long, size: 20, color: AppTheme.primaryGoldDark),
                      label: 'Orders',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.auto_awesome_outlined, size: 20),
                      activeIcon: Icon(Icons.auto_awesome, size: 20, color: AppTheme.primaryGoldDark),
                      label: 'Sets',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(
                        _selectedSection >= 4 ? Icons.tune : Icons.more_horiz,
                        size: 20,
                        color: _selectedSection >= 4 ? AppTheme.primaryGoldDark : AppTheme.textMuted,
                      ),
                      label: _selectedSection == 4
                          ? 'Promos'
                          : _selectedSection == 5
                              ? 'Website'
                              : 'More',
                    ),
                  ],
                ),
              ),
            ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDesktop)
            SizedBox(
              width: 270,
              child: Material(
                color: AppTheme.obsidianNoir,
                child: _buildSidebarContent(
                  context,
                  authState: authState,
                  productCount: products.length,
                  pendingOrdersCount: pendingOrdersCount,
                  isDrawer: false,
                ),
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isDesktop) _buildDesktopTopBar(context, authState),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 36,
                      vertical: isMobile ? 20 : 32,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: _buildActiveSection(context, isMobile, products),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMobileMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'MORE STORE TOOLS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.8,
                  color: AppTheme.primaryGoldDark,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.obsidianNoir,
                  child: Icon(Icons.local_offer_outlined, color: AppTheme.primaryGold, size: 18),
                ),
                title: Text('Promo Codes & Discounts', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text('Create & pause checkout coupon codes', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedSection = 4);
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.obsidianNoir,
                  child: Icon(Icons.web_outlined, color: AppTheme.primaryGold, size: 18),
                ),
                title: Text('Website Text, Banners & WhatsApp', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text('Edit homepage slides, store name & contact info', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedSection = 5);
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.surfaceGrey,
                  child: Icon(Icons.category_outlined, color: AppTheme.obsidianNoir, size: 18),
                ),
                title: Text('Manage Categories', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text('Add or edit bag & shoe categories', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCategoriesDialog(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.surfaceGrey,
                  child: Icon(Icons.reviews_outlined, color: AppTheme.obsidianNoir, size: 18),
                ),
                title: Text('Customer Reviews', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Text('Read and moderate product reviews', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(ctx);
                  _showReviewsDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarContent(
    BuildContext context, {
    required AppAuthState authState,
    required int productCount,
    required int pendingOrdersCount,
    required bool isDrawer,
  }) {
    final brandName = ref.watch(siteSettingsProvider).header.brandName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 20, 20),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.15),
                  border: Border.all(color: AppTheme.primaryGold),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.diamond_outlined, color: AppTheme.primaryGold, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brandName.toUpperCase(),
                      style: GoogleFonts.cormorantGaramond(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'STORE ADMIN SUITE',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryGold,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 1),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: Text(
            'MANAGEMENT',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white38,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.8,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: _navItems.length,
            itemBuilder: (ctx, i) {
              final item = _navItems[i];
              final selected = _selectedSection == i;
              String? badgeText;
              Color badgeColor = AppTheme.primaryGold;
              if (i == 1) {
                badgeText = '$productCount';
              } else if (i == 2 && pendingOrdersCount > 0) {
                badgeText = '$pendingOrdersCount';
                badgeColor = AppTheme.errorRed;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedSection = i);
                    if (isDrawer) Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppTheme.primaryGold.withValues(alpha: 0.16) : Colors.transparent,
                      border: Border(
                        left: BorderSide(
                          color: selected ? AppTheme.primaryGold : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected ? item.activeIcon : item.icon,
                          size: 20,
                          color: selected ? AppTheme.primaryGold : Colors.white70,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: GoogleFonts.plusJakartaSans(
                                  color: selected ? Colors.white : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              Text(
                                item.subtitle,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white38,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (badgeText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              badgeText,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(color: Colors.white12, height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                icon: const Icon(Icons.storefront_outlined, size: 16, color: AppTheme.primaryGold),
                label: Text(
                  'VIEW LIVE WEBSITE',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                ),
                onPressed: () => context.go('/'),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white60,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                icon: const Icon(Icons.logout, size: 16),
                label: Text(
                  'SIGN OUT (${authState.user?.email?.split('@').first ?? 'Admin'})',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600),
                ),
                onPressed: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) context.go('/');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTopBar(BuildContext context, AppAuthState authState) {
    final current = _navItems[_selectedSection];
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 36),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  current.label,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.obsidianNoir,
                  ),
                ),
                Text(
                  current.subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.obsidianNoir,
              foregroundColor: AppTheme.primaryGold,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              side: const BorderSide(color: AppTheme.primaryGold),
            ),
            icon: const Icon(Icons.add, size: 17),
            label: Text(
              'ADD PRODUCT / VIDEO',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
            onPressed: () => _showProductDialog(context, null),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.obsidianNoir,
              side: const BorderSide(color: AppTheme.borderSubtle),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: Text(
              'LIVE STORE',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1),
            ),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSection(BuildContext context, bool isMobile, List<Product> products) {
    switch (_selectedSection) {
      case 0:
        return _buildOverviewSection(context, isMobile, products);
      case 1:
        return _buildProductsManagerTab(context, isMobile, products);
      case 2:
        return _buildOrdersManagerTab(context, isMobile);
      case 3:
        return _buildPairingsManagerTab(context, isMobile, products);
      case 4:
        return _buildPromoCodesTab(context, isMobile);
      case 5:
        return _buildCMSCustomizationTab(context, isMobile);
      default:
        return _buildOverviewSection(context, isMobile, products);
    }
  }

  // ===========================================================================
  // SECTION 0: DASHBOARD OVERVIEW
  // ===========================================================================
  Widget _buildOverviewSection(BuildContext context, bool isMobile, List<Product> products) {
    double revenue = 0;
    int pending = 0;
    for (final o in _ordersList) {
      revenue += ((o['total'] as num?)?.toDouble() ?? 0.0);
      final st = (o['status']?.toString() ?? 'pending').toLowerCase();
      if (st == 'pending' || st == 'processing') pending++;
    }
    final bagsCount = products.where((p) => p.productType == 'bag').length;
    final shoesCount = products.where((p) => p.productType == 'shoe').length;
    final videoProducts = products.where((p) => p.hasVideo).toList();
    final lowStockProducts = products.where((p) => p.stockQuantity <= 5).toList();

    Widget kpiCard({
      required IconData icon,
      required String title,
      required String value,
      required String subtitle,
      required VoidCallback onTap,
      bool alert = false,
      bool highlightGold = false,
    }) {
      return InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: highlightGold ? AppTheme.obsidianNoir : Colors.white,
            border: Border.all(
              color: alert
                  ? AppTheme.errorRed.withValues(alpha: 0.6)
                  : highlightGold
                      ? AppTheme.primaryGold
                      : AppTheme.borderSubtle,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: highlightGold
                        ? AppTheme.primaryGold.withValues(alpha: 0.15)
                        : alert
                            ? AppTheme.errorRed.withValues(alpha: 0.1)
                            : AppTheme.surfaceGrey,
                    child: Icon(
                      icon,
                      size: 18,
                      color: highlightGold
                          ? AppTheme.primaryGold
                          : alert
                              ? AppTheme.errorRed
                              : AppTheme.obsidianNoir,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward,
                    size: 15,
                    color: highlightGold ? Colors.white54 : AppTheme.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: highlightGold ? AppTheme.primaryGold : AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: highlightGold ? Colors.white : AppTheme.obsidianNoir,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  color: highlightGold ? Colors.white70 : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final kpis = [
      kpiCard(
        icon: Icons.payments_outlined,
        title: 'TOTAL REVENUE',
        value: _formatNaira(revenue),
        subtitle: '${_ordersList.length} total orders placed',
        highlightGold: true,
        onTap: () => setState(() => _selectedSection = 2),
      ),
      kpiCard(
        icon: Icons.pending_actions_outlined,
        title: 'ORDERS TO FULFILL',
        value: '$pending Pending',
        subtitle: pending == 0 ? 'All orders up to date' : 'Tap to update order status',
        alert: pending > 0,
        onTap: () => setState(() => _selectedSection = 2),
      ),
      kpiCard(
        icon: Icons.shopping_bag_outlined,
        title: 'LIVE CATALOGUE',
        value: '${products.length} Items',
        subtitle: '$bagsCount Bags • $shoesCount Shoes',
        onTap: () => setState(() {
          _productFilter = 'all';
          _selectedSection = 1;
        }),
      ),
      kpiCard(
        icon: Icons.videocam_outlined,
        title: 'LIVE VIDEO SHOWCASES',
        value: '${videoProducts.length} Videos',
        subtitle: lowStockProducts.isEmpty
            ? 'Playing on Home & Shop'
            : '${lowStockProducts.length} items low on stock',
        alert: lowStockProducts.isNotEmpty,
        onTap: () => setState(() {
          _productFilter = 'video';
          _selectedSection = 1;
        }),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Welcome Banner
        Container(
          padding: EdgeInsets.all(isMobile ? 20 : 28),
          decoration: BoxDecoration(
            color: AppTheme.obsidianNoir,
            border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    color: AppTheme.primaryGold,
                    child: Text(
                      'QUICK START',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Everything is organized into clear steps below',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'What would you like to do today?',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: isMobile ? 24 : 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                    label: Text(
                      'ADD NEW BAG OR SHOE',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1),
                    ),
                    onPressed: () => _showProductDialog(context, null),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: AppTheme.primaryGold),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    icon: const Icon(Icons.video_call_outlined, size: 18, color: AppTheme.primaryGold),
                    label: Text(
                      'MANAGE VIDEO PRODUCTS (${videoProducts.length})',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                    ),
                    onPressed: () => setState(() {
                      _productFilter = 'video';
                      _selectedSection = 1;
                    }),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    icon: const Icon(Icons.burst_mode_outlined, size: 18),
                    label: Text(
                      'EDIT HOMEPAGE BANNERS',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                    ),
                    onPressed: () => setState(() {
                      _cmsSubTab = 0;
                      _selectedSection = 5;
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // KPI Grid (2x2 on Mobile, 4 across on Desktop)
        if (isMobile)
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: kpis[0]),
                  const SizedBox(width: 12),
                  Expanded(child: kpis[1]),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: kpis[2]),
                  const SizedBox(width: 12),
                  Expanded(child: kpis[3]),
                ],
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(child: kpis[0]),
              const SizedBox(width: 16),
              Expanded(child: kpis[1]),
              const SizedBox(width: 16),
              Expanded(child: kpis[2]),
              const SizedBox(width: 16),
              Expanded(child: kpis[3]),
            ],
          ),

        const SizedBox(height: 28),

        // Live Video Showcase Summary Card
        _sectionCard(
          title: 'Live Video Products (${videoProducts.length} Active)',
          subtitle: 'These products auto-play in the "Watch In Motion" showcase on your Homepage and Shop page.',
          trailing: TextButton.icon(
            onPressed: () => _showProductDialog(context, null),
            icon: const Icon(Icons.video_call_outlined, size: 18, color: AppTheme.primaryGoldDark),
            label: Text(
              'UPLOAD NEW VIDEO PRODUCT',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryGoldDark),
            ),
          ),
          children: [
            if (videoProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No video products yet. Tap "Upload New Video Product" to add one.'),
              )
            else
              Column(
                children: [
                  for (final vp in videoProducts)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceGrey,
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 54,
                            height: 54,
                            child: ShopImage(vp.primaryImage, w: 160, q: 65),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      color: AppTheme.obsidianNoir,
                                      child: Text(
                                        '▶ LIVE VIDEO',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 8.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.primaryGold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      vp.productType.toUpperCase(),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vp.title,
                                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${_formatNaira(vp.effectivePrice)} • Stock: ${vp.stockQuantity}',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            tooltip: 'Edit product or replace video',
                            onPressed: () => _showProductDialog(context, vp),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),

        const SizedBox(height: 24),

        // Quick Store Shortcuts Grid
        _sectionCard(
          title: 'Store Management Shortcuts',
          subtitle: 'Jump straight to any part of your store back-office',
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _quickActionChip(
                  icon: Icons.category_outlined,
                  label: 'Manage Categories',
                  onTap: () => _showCategoriesDialog(context),
                ),
                _quickActionChip(
                  icon: Icons.reviews_outlined,
                  label: 'Moderate Reviews',
                  onTap: () => _showReviewsDialog(context),
                ),
                _quickActionChip(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Matching Sets',
                  onTap: () => setState(() => _selectedSection = 3),
                ),
                _quickActionChip(
                  icon: Icons.local_offer_outlined,
                  label: 'Promo Codes',
                  onTap: () => setState(() => _selectedSection = 4),
                ),
                _quickActionChip(
                  icon: Icons.campaign_outlined,
                  label: 'Top Notice Bar',
                  onTap: () => setState(() {
                    _cmsSubTab = 1;
                    _selectedSection = 5;
                  }),
                ),
                _quickActionChip(
                  icon: Icons.support_agent_outlined,
                  label: 'WhatsApp & Contact Info',
                  onTap: () => setState(() {
                    _cmsSubTab = 2;
                    _selectedSection = 5;
                  }),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _quickActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.obsidianNoir,
        backgroundColor: AppTheme.surfaceGrey,
        side: const BorderSide(color: AppTheme.borderSubtle),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      icon: Icon(icon, size: 17, color: AppTheme.primaryGoldDark),
      label: Text(
        label,
        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      onPressed: onTap,
    );
  }

  // ===========================================================================
  // SECTION 1: PRODUCTS & VIDEOS MANAGER
  // ===========================================================================
  Widget _buildProductsManagerTab(BuildContext context, bool isMobile, List<Product> allProducts) {
    final filtered = allProducts.where((p) {
      if (_productFilter == 'bag' && p.productType != 'bag') return false;
      if (_productFilter == 'shoe' && p.productType != 'shoe') return false;
      if (_productFilter == 'video' && !p.hasVideo) return false;
      if (_productFilter == 'low_stock' && p.stockQuantity > 5) return false;

      if (_productSearchQuery.trim().isNotEmpty) {
        final q = _productSearchQuery.toLowerCase();
        final matchTitle = p.title.toLowerCase().contains(q);
        final matchSub = (p.subCategory ?? '').toLowerCase().contains(q);
        return matchTitle || matchSub;
      }
      return true;
    }).toList();

    final bagsCount = allProducts.where((p) => p.productType == 'bag').length;
    final shoesCount = allProducts.where((p) => p.productType == 'shoe').length;
    final videoCount = allProducts.where((p) => p.hasVideo).length;
    final lowStockCount = allProducts.where((p) => p.stockQuantity <= 5).length;

    Widget filterChip(String key, String label) {
      final selected = _productFilter == key;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _productFilter = key),
        selectedColor: AppTheme.obsidianNoir,
        backgroundColor: Colors.white,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: selected ? AppTheme.primaryGold : AppTheme.obsidianNoir,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppTheme.borderSubtle),
        ),
        showCheckmark: false,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header + Action Buttons (Responsive)
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isMobile) ...[
                Text(
                  'CATALOGUE & VIDEO PRODUCTS',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.8, color: AppTheme.primaryGoldDark),
                ),
                const SizedBox(height: 4),
                Text(
                  '${allProducts.length} Total Products ($videoCount with Video)',
                  style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.obsidianNoir,
                    foregroundColor: AppTheme.primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    side: const BorderSide(color: AppTheme.primaryGold),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    'ADD NEW PRODUCT / VIDEO',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                  ),
                  onPressed: () => _showProductDialog(context, null),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.obsidianNoir,
                          side: const BorderSide(color: AppTheme.borderSubtle),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        icon: const Icon(Icons.category_outlined, size: 16),
                        label: Text('CATEGORIES', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700)),
                        onPressed: () => _showCategoriesDialog(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.obsidianNoir,
                          side: const BorderSide(color: AppTheme.borderSubtle),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        icon: const Icon(Icons.reviews_outlined, size: 16),
                        label: Text('REVIEWS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700)),
                        onPressed: () => _showReviewsDialog(context),
                      ),
                    ),
                  ],
                ),
              ] else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CATALOGUE & VIDEO PRODUCTS',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.8, color: AppTheme.primaryGoldDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage Bags, Footwear & Videos (${allProducts.length} Items)',
                          style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 10,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.obsidianNoir,
                            side: const BorderSide(color: AppTheme.borderSubtle),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          icon: const Icon(Icons.category_outlined, size: 17),
                          label: Text('CATEGORIES', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700)),
                          onPressed: () => _showCategoriesDialog(context),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.obsidianNoir,
                            side: const BorderSide(color: AppTheme.borderSubtle),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          icon: const Icon(Icons.reviews_outlined, size: 17),
                          label: Text('REVIEWS', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700)),
                          onPressed: () => _showReviewsDialog(context),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.obsidianNoir,
                            foregroundColor: AppTheme.primaryGold,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            side: const BorderSide(color: AppTheme.primaryGold),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text('ADD NEW PRODUCT', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                          onPressed: () => _showProductDialog(context, null),
                        ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 18),
              // Search Field
              TextField(
                controller: _productSearchCtrl,
                onChanged: (v) => setState(() => _productSearchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search products by name or style (e.g. Kosa Luxe, Tote, Slides)...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _productSearchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _productSearchCtrl.clear();
                            setState(() => _productSearchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 14),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    filterChip('all', 'All (${allProducts.length})'),
                    const SizedBox(width: 8),
                    filterChip('bag', 'Bags ($bagsCount)'),
                    const SizedBox(width: 8),
                    filterChip('shoe', 'Shoes ($shoesCount)'),
                    const SizedBox(width: 8),
                    filterChip('video', '▶ With Video ($videoCount)'),
                    const SizedBox(width: 8),
                    filterChip('low_stock', 'Low Stock ($lowStockCount)'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Column(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 42, color: AppTheme.textMuted),
                const SizedBox(height: 12),
                Text('No matching products found', style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Try clearing your search or switching the filter above.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final p = filtered[index];
              final isLowStock = p.stockQuantity <= 5;
              return Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: isMobile ? 68 : 76,
                              height: isMobile ? 68 : 76,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderSubtle),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: ShopImage(p.primaryImage, w: 180, q: 65),
                            ),
                            if (p.hasVideo)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: AppTheme.obsidianNoir.withValues(alpha: 0.88),
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '▶ VIDEO',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryGold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    color: AppTheme.surfaceGrey,
                                    child: Text(
                                      '${p.productType.toUpperCase()} • ${p.subCategory ?? 'Luxury'}',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppTheme.obsidianNoir),
                                    ),
                                  ),
                                  if (isLowStock)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      color: AppTheme.errorRed.withValues(alpha: 0.12),
                                      child: Text(
                                        'LOW STOCK: ${p.stockQuantity}',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.errorRed),
                                      ),
                                    )
                                  else
                                    Text(
                                      'In Stock: ${p.stockQuantity}',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppTheme.textMuted),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                p.title,
                                style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.obsidianNoir),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    _formatNaira(p.effectivePrice),
                                    style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppTheme.primaryGoldDark),
                                  ),
                                  if (p.salePrice != null && p.salePrice! < p.basePrice) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatNaira(p.basePrice),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: AppTheme.textMuted,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!isMobile)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.obsidianNoir,
                                  side: const BorderSide(color: AppTheme.borderSubtle),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                ),
                                icon: const Icon(Icons.edit_outlined, size: 16),
                                label: Text('EDIT', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700)),
                                onPressed: () => _showProductDialog(context, p),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.errorRed),
                                tooltip: 'Delete Product',
                                onPressed: () => _confirmDeleteProduct(context, p),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (isMobile) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.obsidianNoir,
                                side: const BorderSide(color: AppTheme.borderSubtle),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: Text('EDIT PRODUCT / VIDEO', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700)),
                              onPressed: () => _showProductDialog(context, p),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.errorRed,
                              side: BorderSide(color: AppTheme.errorRed.withValues(alpha: 0.4)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: Text('DELETE', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700)),
                            onPressed: () => _confirmDeleteProduct(context, p),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // ===========================================================================
  // SECTION 2: ORDERS & FULFILLMENT
  // ===========================================================================
  Widget _buildOrdersManagerTab(BuildContext context, bool isMobile) {
    final filteredOrders = _orderStatusFilter == 'all'
        ? _ordersList
        : _ordersList.where((o) => (o['status']?.toString() ?? 'pending').toLowerCase() == _orderStatusFilter).toList();

    Widget statusChip(String key, String label) {
      final selected = _orderStatusFilter == key;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _orderStatusFilter = key),
        selectedColor: AppTheme.obsidianNoir,
        backgroundColor: Colors.white,
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: selected ? AppTheme.primaryGold : AppTheme.obsidianNoir,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppTheme.borderSubtle),
        ),
        showCheckmark: false,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CUSTOMER ORDERS',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.8, color: AppTheme.primaryGoldDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Orders & Delivery Status (${_ordersList.length})',
                          style: GoogleFonts.cormorantGaramond(fontSize: isMobile ? 22 : 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.obsidianNoir,
                      side: const BorderSide(color: AppTheme.borderSubtle),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text('REFRESH', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700)),
                    onPressed: _loadOrders,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    statusChip('all', 'All (${_ordersList.length})'),
                    const SizedBox(width: 8),
                    statusChip('pending', 'Pending'),
                    const SizedBox(width: 8),
                    statusChip('processing', 'Processing'),
                    const SizedBox(width: 8),
                    statusChip('shipped', 'Shipped'),
                    const SizedBox(width: 8),
                    statusChip('delivered', 'Delivered'),
                    const SizedBox(width: 8),
                    statusChip('cancelled', 'Cancelled'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (_isLoadingOrders)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(color: AppTheme.primaryGold),
            ),
          )
        else if (filteredOrders.isEmpty)
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Column(
              children: [
                const Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textMuted),
                const SizedBox(height: 16),
                Text(
                  _ordersList.isEmpty ? 'No Customer Orders Yet' : 'No $_orderStatusFilter orders',
                  style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Orders placed through the checkout will appear here automatically.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredOrders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              final orderId = order['id'] as String? ?? '';
              final orderNum = order['order_number'] as String? ?? 'N/A';
              final customer = order['customer_name'] as String? ?? 'Guest Shopper';
              final email = order['customer_email'] as String? ?? '';
              final phone = order['customer_phone'] as String? ?? '';
              final total = (order['total'] as num?)?.toDouble() ?? 0.0;
              final status = (order['status'] as String? ?? 'pending').toLowerCase();

              return Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(orderNum, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'delivered'
                                ? AppTheme.successGreen.withValues(alpha: 0.12)
                                : AppTheme.primaryGold.withValues(alpha: 0.15),
                            border: Border.all(
                              color: status == 'delivered' ? AppTheme.successGreen : AppTheme.primaryGold,
                            ),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Customer: $customer${email.isNotEmpty ? ' • $email' : ''}${phone.isNotEmpty ? ' • $phone' : ''}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppTheme.obsidianNoir),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Order Total: ${_formatNaira(total)}',
                      style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.primaryGoldDark),
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Order Status:', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                        DropdownButton<String>(
                          value: ['pending', 'processing', 'shipped', 'delivered', 'cancelled'].contains(status) ? status : 'pending',
                          items: const [
                            DropdownMenuItem(value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'processing', child: Text('Processing')),
                            DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                            DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                            DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                          ],
                          onChanged: (newStatus) async {
                            if (newStatus != null) {
                              await SupabaseService.updateOrderStatus(orderId, newStatus);
                              _loadOrders();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  // ===========================================================================
  // SECTION 3: MATCHING SETS (BAG + SHOE BUNDLES)
  // ===========================================================================
  Widget _buildPairingsManagerTab(BuildContext context, bool isMobile, List<Product> products) {
    final pairingsAsync = ref.watch(pairingsProvider);
    final pairings = pairingsAsync.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'MATCHING BAG + SHOE SETS',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.8, color: AppTheme.primaryGoldDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Matching Sets (${pairings.length} Active)',
                      style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.obsidianNoir,
                        foregroundColor: AppTheme.primaryGold,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        side: const BorderSide(color: AppTheme.primaryGold),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('CREATE NEW MATCHING SET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _showPairingDialog(context, products),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MATCHING BAG + SHOE SETS',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.8, color: AppTheme.primaryGoldDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Matching Sets (${pairings.length} Active)',
                          style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.obsidianNoir,
                        foregroundColor: AppTheme.primaryGold,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        side: const BorderSide(color: AppTheme.primaryGold),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('CREATE NEW SET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () => _showPairingDialog(context, products),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 16),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pairings.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final pair = pairings[index];
            return Container(
              padding: EdgeInsets.all(isMobile ? 14 : 18),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (pair.bagProduct != null)
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: ShopImage(pair.bagProduct!.primaryImage, w: 180, q: 60),
                        ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 18),
                        child: Icon(Icons.add, size: 16, color: AppTheme.primaryGoldDark),
                      ),
                      if (pair.shoeProduct != null)
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: ShopImage(pair.shoeProduct!.primaryImage, w: 180, q: 60),
                        ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pair.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(
                              '${pair.bundleDiscountPercent}% OFF • Bundle: ${_formatNaira(pair.discountedBundlePrice)}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.primaryGoldDark, fontWeight: FontWeight.w700),
                            ),
                            if ((pair.description ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                pair.description!,
                                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textMuted),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!isMobile) ...[
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppTheme.obsidianNoir),
                          tooltip: 'Edit this set',
                          onPressed: () => _showPairingDialog(context, products, existing: pair),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                          tooltip: 'Delete this set',
                          onPressed: () async {
                            await SupabaseService.deletePairing(pair.id);
                            ref.invalidate(pairingsProvider);
                          },
                        ),
                      ],
                    ],
                  ),
                  if (isMobile) ...[
                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.obsidianNoir,
                              side: const BorderSide(color: AppTheme.borderSubtle),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('EDIT SET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: () => _showPairingDialog(context, products, existing: pair),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.errorRed,
                            side: BorderSide(color: AppTheme.errorRed.withValues(alpha: 0.4)),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('DELETE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            await SupabaseService.deletePairing(pair.id);
                            ref.invalidate(pairingsProvider);
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // SECTION 4: PROMO CODES
  // ===========================================================================
  Widget _buildPromoCodesTab(BuildContext context, bool isMobile) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: SupabaseService.getPromoCodes(),
      builder: (ctx, snap) {
        final codes = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'DISCOUNT CODES',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.8, color: AppTheme.primaryGoldDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Promo Codes (${codes.length})',
                          style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Shoppers type these at checkout (e.g. LUXE10 = 10% off).',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.obsidianNoir,
                            foregroundColor: AppTheme.primaryGold,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            side: const BorderSide(color: AppTheme.primaryGold),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('CREATE NEW PROMO CODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: () => _showPromoDialog(ctx, null),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DISCOUNT CODES',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.8, color: AppTheme.primaryGoldDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Promo Codes (${codes.length})',
                              style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Shoppers type these at checkout. Example: LUXE10 = 10% off.',
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.obsidianNoir,
                            foregroundColor: AppTheme.primaryGold,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            side: const BorderSide(color: AppTheme.primaryGold),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('NEW CODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          onPressed: () => _showPromoDialog(ctx, null),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            if (snap.connectionState == ConnectionState.waiting)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppTheme.primaryGold)))
            else if (codes.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppTheme.borderSubtle)),
                child: const Center(child: Text('No promo codes yet. Tap "New Code" to create LUXE10.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: codes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (c, i) {
                  final row = codes[i];
                  final active = (row['is_active'] as bool?) ?? true;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: active ? AppTheme.borderSubtle : AppTheme.errorRed.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          color: active ? AppTheme.obsidianNoir : AppTheme.surfaceGrey,
                          child: Text(
                            '${row['code']}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: active ? AppTheme.primaryGold : AppTheme.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${row['discount_percent']}% off • ${active ? 'Active' : 'Paused'}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.obsidianNoir),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await SupabaseService.setPromoActive(row['id'].toString(), !active);
                            setState(() {});
                          },
                          child: Text(active ? 'PAUSE' : 'RESUME'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                          tooltip: 'Delete code',
                          onPressed: () async {
                            await SupabaseService.deletePromoCode(row['id'].toString());
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // SECTION 5: WEBSITE TEXT, BANNERS & WHATSAPP (CLEAN SUB-TABS)
  // ===========================================================================
  Widget _buildCMSCustomizationTab(BuildContext context, bool isMobile) {
    Widget subTabBtn(int index, IconData icon, String label) {
      final selected = _cmsSubTab == index;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _cmsSubTab = index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? AppTheme.obsidianNoir : Colors.white,
              border: Border.all(color: selected ? AppTheme.obsidianNoir : AppTheme.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: selected ? AppTheme.primaryGold : AppTheme.textMuted),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : AppTheme.obsidianNoir,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header + Save Button
        Container(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isMobile) ...[
                Text(
                  'WEBSITE DESIGN & TEXT',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.8, color: AppTheme.primaryGoldDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Banners, Store Name & Contact Details',
                  style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  icon: _isSavingCMS
                      ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save, size: 18),
                  label: Text(
                    _isSavingCMS ? 'SAVING...' : 'PUBLISH TEXT CHANGES',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  onPressed: _isSavingCMS ? null : _saveAllCMSContent,
                ),
              ] else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WEBSITE DESIGN & TEXT',
                          style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.8, color: AppTheme.primaryGoldDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Customize Homepage Banners, Store Name & WhatsApp',
                          style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      icon: _isSavingCMS
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save, size: 18),
                      label: Text(
                        _isSavingCMS ? 'SAVING...' : 'PUBLISH ALL CHANGES',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      onPressed: _isSavingCMS ? null : _saveAllCMSContent,
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              // 3 Clean Sub-tabs so the owner isn't overwhelmed by 20 inputs at once
              Row(
                children: [
                  subTabBtn(0, Icons.burst_mode_outlined, '1. Banners'),
                  const SizedBox(width: 8),
                  subTabBtn(1, Icons.campaign_outlined, '2. Brand & Notice'),
                  const SizedBox(width: 8),
                  subTabBtn(2, Icons.contact_phone_outlined, '3. Contact & Shipping'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        if (_cmsSubTab == 0) ...[
          _buildHeroSlidesEditor(context, ref, isMobile),
        ] else if (_cmsSubTab == 1) ...[
          _sectionCard(
            title: 'Top Scrolling Notice Bar',
            subtitle: 'TV-style ticker bar at the very top of your website',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show Announcement Bar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: const Text('Toggle top notice bar on or off across the store', style: TextStyle(fontSize: 11)),
                value: _announcementActive,
                activeThumbColor: AppTheme.primaryGold,
                onChanged: (val) => setState(() => _announcementActive = val),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _announcementTextCtrl,
                decoration: const InputDecoration(labelText: 'Announcement Text'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _sectionCard(
            title: 'Shop Name & Tagline',
            subtitle: 'Shown in the header navigation and browser title',
            children: [
              _responsiveFields(isMobile, [
                TextField(
                  controller: _headerBrandCtrl,
                  decoration: const InputDecoration(labelText: 'Shop Name (e.g. LUXE LAGOS)'),
                ),
                TextField(
                  controller: _headerTaglineCtrl,
                  decoration: const InputDecoration(labelText: 'Brand Subtitle / Tagline'),
                ),
              ]),
            ],
          ),
        ] else ...[
          _sectionCard(
            title: 'Contact, WhatsApp & Address',
            subtitle: 'Shown in the website footer and WhatsApp floating chat button',
            children: [
              TextField(
                controller: _footerBioCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'About Your Shop (Short Footer Bio)'),
              ),
              const SizedBox(height: 14),
              _responsiveFields(isMobile, [
                TextField(
                  controller: _footerEmailCtrl,
                  decoration: const InputDecoration(labelText: 'Customer Care Email'),
                ),
                TextField(
                  controller: _footerPhoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone Line'),
                ),
                TextField(
                  controller: _footerWhatsappCtrl,
                  decoration: const InputDecoration(labelText: 'WhatsApp Number (e.g. +2348091234567)'),
                ),
              ]),
              const SizedBox(height: 14),
              _responsiveFields(isMobile, [
                TextField(
                  controller: _footerAddressCtrl,
                  decoration: const InputDecoration(labelText: 'Boutique Address'),
                ),
                TextField(
                  controller: _footerCopyrightCtrl,
                  decoration: const InputDecoration(labelText: 'Copyright Line'),
                ),
              ]),
            ],
          ),
          const SizedBox(height: 20),
          _sectionCard(
            title: 'Currency & Free Delivery Threshold',
            subtitle: 'Storewide currency symbol and free delivery minimum spend',
            children: [
              _responsiveFields(isMobile, [
                TextField(
                  controller: _currencySymbolCtrl,
                  decoration: const InputDecoration(labelText: 'Currency Symbol (e.g. ₦)'),
                ),
                TextField(
                  controller: _freeShippingCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Free Delivery Threshold (Amount in ₦)'),
                ),
              ]),
            ],
          ),
        ],
      ],
    );
  }

  // --- SECURITY GATE FOR ADMIN EXCLUSIVITY ---
  Widget _buildSecurityGate(BuildContext context, AppAuthState authState) {
    return Scaffold(
      backgroundColor: AppTheme.obsidianNoir,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.primaryGold, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 32, offset: const Offset(0, 12)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppTheme.obsidianNoir,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_person, color: AppTheme.primaryGold, size: 28),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'STORE OWNER PORTAL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: AppTheme.primaryGoldDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Admin Sign In',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.obsidianNoir,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to manage products, upload videos, track orders, and update banners.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 22),

                  if (authState.isAuthenticated && !authState.isAdmin) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Current account (${authState.user?.email}) is a customer account. Please sign in with your Administrator credentials.',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.errorRed),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_gateError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        _gateError!,
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.errorRed),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _adminEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Admin Email',
                      prefixIcon: Icon(Icons.mail_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _adminPasswordController,
                    obscureText: _obscureAdminPassword,
                    onSubmitted: (_) => _handleAdminLogin(),
                    decoration: InputDecoration(
                      labelText: 'Admin Password',
                      prefixIcon: const Icon(Icons.password, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureAdminPassword ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setState(() => _obscureAdminPassword = !_obscureAdminPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.obsidianNoir,
                      foregroundColor: AppTheme.primaryGold,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      side: const BorderSide(color: AppTheme.primaryGold),
                    ),
                    onPressed: _isLoggingIn ? null : _handleAdminLogin,
                    child: _isLoggingIn
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGold))
                        : Text(
                            'SIGN IN TO DASHBOARD',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.8),
                          ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.borderSubtle),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () => context.go('/'),
                    child: Text(
                      'BACK TO PUBLIC SHOP',
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.obsidianNoir, letterSpacing: 1.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAdminLogin() async {
    setState(() {
      _gateError = null;
      _isLoggingIn = true;
    });

    final email = _adminEmailController.text.trim();
    final password = _adminPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _gateError = 'Please enter admin email and password.';
        _isLoggingIn = false;
      });
      return;
    }

    final success = await ref.read(authProvider.notifier).signIn(
      email: email,
      password: password,
    );

    if (mounted) {
      final auth = ref.read(authProvider);
      if (!success) {
        setState(() {
          _gateError = auth.errorMessage ?? 'Invalid administrator credentials.';
          _isLoggingIn = false;
        });
      } else if (!auth.isAdmin) {
        setState(() {
          _gateError = 'This account does not have administrator privileges.';
          _isLoggingIn = false;
        });
      } else {
        setState(() => _isLoggingIn = false);
      }
    }
  }

  Future<void> _saveAllCMSContent() async {
    setState(() => _isSavingCMS = true);

    final siteNotifier = ref.read(siteSettingsProvider.notifier);

    await siteNotifier.updateAnnouncement(
      text: _announcementTextCtrl.text.trim(),
      isActive: _announcementActive,
    );

    await siteNotifier.updateHeader(
      brandName: _headerBrandCtrl.text.trim(),
      tagline: _headerTaglineCtrl.text.trim(),
    );

    await siteNotifier.updateHero(
      badge: _heroBadgeCtrl.text.trim(),
      title: _heroTitleCtrl.text.trim(),
      subtitle: _heroSubtitleCtrl.text.trim(),
      ctaText: _heroCtaTextCtrl.text.trim(),
      ctaUrl: _heroCtaUrlCtrl.text.trim(),
      secondaryCtaText: _heroSecondaryTextCtrl.text.trim(),
      secondaryCtaUrl: _heroSecondaryUrlCtrl.text.trim(),
      imageUrl: _heroImageCtrl.text.trim(),
    );

    await siteNotifier.updateFooter(
      bio: _footerBioCtrl.text.trim(),
      email: _footerEmailCtrl.text.trim(),
      phone: _footerPhoneCtrl.text.trim(),
      whatsapp: _footerWhatsappCtrl.text.trim(),
      address: _footerAddressCtrl.text.trim(),
      copyright: _footerCopyrightCtrl.text.trim(),
      instagram: 'https://instagram.com/luxelagos.ng',
    );

    final threshold = double.tryParse(_freeShippingCtrl.text.replaceAll(',', '').trim()) ?? 150000.0;
    await siteNotifier.updateGeneral(
      currency: 'NGN',
      currencySymbol: _currencySymbolCtrl.text.trim(),
      freeShippingThreshold: threshold,
    );

    setState(() => _isSavingCMS = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Website changes published live!'),
          backgroundColor: AppTheme.obsidianNoir,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildHeroSlidesEditor(BuildContext context, WidgetRef ref, bool isMobile) {
    final slides = ref.watch(siteSettingsProvider).hero.slides;
    return _sectionCard(
      title: 'Homepage Hero Banners (${slides.length} Slides)',
      subtitle: 'These are the big slideshow banners shoppers swipe at the top of the homepage.',
      children: [
        for (int i = 0; i < slides.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGrey,
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 68,
                  height: 68,
                  child: ShopImage(slides[i].imageUrl, w: 200, q: 60),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SLIDE ${i + 1} • ${slides[i].badge}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.primaryGoldDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        slides[i].title,
                        style: GoogleFonts.cormorantGaramond(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${slides[i].ctaText}  •  ${slides[i].secondaryCtaText}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppTheme.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit slide ${i + 1}',
                  onPressed: () => _showSlideDialog(context, ref, existing: slides[i], index: i),
                ),
                if (slides.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.errorRed),
                    tooltip: 'Delete slide ${i + 1}',
                    onPressed: () async {
                      final next = List<HeroSlide>.from(slides)..removeAt(i);
                      await ref.read(siteSettingsProvider.notifier).updateHeroSlides(next);
                      setState(() {});
                    },
                  ),
              ],
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.obsidianNoir,
              side: const BorderSide(color: AppTheme.borderSubtle),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              slides.length >= 6 ? 'MAX 6 SLIDES' : 'ADD NEW HOMEPAGE BANNER',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            onPressed: slides.length >= 6 ? null : () => _showSlideDialog(context, ref),
          ),
        ),
      ],
    );
  }

  void _showSlideDialog(BuildContext context, WidgetRef ref, {HeroSlide? existing, int? index}) {
    final isEditing = existing != null;
    final badgeCtrl = TextEditingController(text: existing?.badge ?? 'LAGOS BESTSELLER');
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final subCtrl = TextEditingController(text: existing?.subtitle ?? '');
    final ctaCtrl = TextEditingController(text: existing?.ctaText ?? 'SHOP BAGS');
    final ctaUrlCtrl = TextEditingController(text: existing?.ctaUrl ?? '/shop');
    final secCtrl = TextEditingController(text: existing?.secondaryCtaText ?? 'SHOP MATCHING SETS');
    final secUrlCtrl = TextEditingController(text: existing?.secondaryCtaUrl ?? '/pairings');
    final imgCtrl = TextEditingController(text: existing?.imageUrl ?? '');
    Uint8List? pickedBytes;
    bool uploading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final isDialogMobile = MediaQuery.of(ctx).size.width < 600;
          Future<void> upload() async {
            final messenger = ScaffoldMessenger.of(context);
            final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
            if (res == null || res.files.isEmpty) return;
            final bytes = res.files.first.bytes;
            if (bytes == null) {
              messenger.showSnackBar(const SnackBar(content: Text('Could not read that file.')));
              return;
            }
            setD(() {
              pickedBytes = bytes;
              uploading = true;
            });
            final url = await SupabaseService.uploadProductImage(bytes, res.files.first.name);
            setD(() => uploading = false);
            if (url == null) {
              messenger.showSnackBar(const SnackBar(content: Text('Upload failed. Paste a link instead.')));
              return;
            }
            imgCtrl.text = url;
            setD(() {});
            messenger.showSnackBar(const SnackBar(content: Text('Banner photo uploaded.')));
          }

          return AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: isDialogMobile ? 12 : 40, vertical: 16),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            title: Text(isEditing ? 'Edit Banner ${index != null ? index + 1 : ''}' : 'Add New Banner'),
            content: SizedBox(
              width: isDialogMobile ? double.maxFinite : 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceGrey,
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: pickedBytes != null
                              ? Image.memory(pickedBytes!, fit: BoxFit.cover)
                              : (imgCtrl.text.trim().isEmpty
                                  ? const Icon(Icons.image_outlined, color: AppTheme.textMuted)
                                  : ShopImage(imgCtrl.text.trim(), w: 200, q: 60)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGold,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            icon: uploading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.upload, size: 18),
                            label: Text(
                              uploading ? 'UPLOADING...' : 'UPLOAD PHOTO',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            onPressed: uploading ? null : upload,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: imgCtrl,
                      decoration: const InputDecoration(labelText: 'Photo link (auto-filled after upload, or paste)'),
                      onChanged: (_) => setD(() {}),
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: badgeCtrl, decoration: const InputDecoration(labelText: 'Small top text * (e.g. LAGOS BESTSELLER)')),
                    const SizedBox(height: 12),
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Big headline *')),
                    const SizedBox(height: 12),
                    TextField(controller: subCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Short description under headline')),
                    const SizedBox(height: 12),
                    _responsiveFields(isDialogMobile, [
                      TextField(controller: ctaCtrl, decoration: const InputDecoration(labelText: 'Main button (e.g. SHOP BAGS)')),
                      TextField(controller: secCtrl, decoration: const InputDecoration(labelText: 'Second button')),
                    ]),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.obsidianNoir, foregroundColor: Colors.white),
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty || badgeCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Top text and headline are required.')));
                    return;
                  }
                  final slides = List<HeroSlide>.from(ref.read(siteSettingsProvider).hero.slides);
                  final slide = HeroSlide(
                    id: existing?.id ?? 'custom-${DateTime.now().millisecondsSinceEpoch}',
                    badge: badgeCtrl.text.trim(),
                    title: titleCtrl.text.trim(),
                    subtitle: subCtrl.text.trim(),
                    ctaText: ctaCtrl.text.trim().isEmpty ? 'SHOP BAGS' : ctaCtrl.text.trim(),
                    ctaUrl: ctaUrlCtrl.text.trim().isEmpty ? '/shop' : ctaUrlCtrl.text.trim(),
                    secondaryCtaText: secCtrl.text.trim().isEmpty ? 'SHOP MATCHING SETS' : secCtrl.text.trim(),
                    secondaryCtaUrl: secUrlCtrl.text.trim().isEmpty ? '/pairings' : secUrlCtrl.text.trim(),
                    imageUrl: imgCtrl.text.trim().isEmpty ? 'assets/images/hero1.jpg' : imgCtrl.text.trim(),
                  );
                  if (isEditing && index != null && index < slides.length) {
                    slides[index] = slide;
                  } else {
                    slides.add(slide);
                  }
                  await ref.read(siteSettingsProvider.notifier).updateHeroSlides(slides);
                  setState(() {});
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner saved — live on homepage now.')));
                  }
                },
                child: Text(isEditing ? 'SAVE BANNER' : 'ADD BANNER'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCategoriesDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final imgCtrl = TextEditingController();
    String newType = 'bags';
    bool uploading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final isDialogMobile = MediaQuery.of(ctx).size.width < 600;
          Future<void> upload(TextEditingController target) async {
            final messenger = ScaffoldMessenger.of(context);
            final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
            if (res == null || res.files.isEmpty) return;
            final bytes = res.files.first.bytes;
            if (bytes == null) return;
            setD(() => uploading = true);
            final url = await SupabaseService.uploadProductImage(bytes, res.files.first.name);
            setD(() => uploading = false);
            if (url == null) {
              messenger.showSnackBar(const SnackBar(content: Text('Upload failed. Paste a link instead.')));
              return;
            }
            target.text = url;
            setD(() {});
          }

          return AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: isDialogMobile ? 12 : 40, vertical: 16),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            title: const Text('Manage Categories'),
            content: SizedBox(
              width: isDialogMobile ? double.maxFinite : 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FutureBuilder<List<Category>>(
                      future: SupabaseService.getCategories(),
                      builder: (c, snap) {
                        final cats = snap.data ?? [];
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppTheme.primaryGold)));
                        }
                        if (cats.isEmpty) return const Text('No categories yet.');
                        return Column(
                          children: [
                            for (final cat in cats)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppTheme.surfaceGrey, border: Border.all(color: AppTheme.borderSubtle)),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 42,
                                      height: 42,
                                      child: (cat.imageUrl ?? '').isEmpty
                                          ? const Icon(Icons.category_outlined, color: AppTheme.textMuted)
                                          : ShopImage(cat.imageUrl!, w: 200, q: 60),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(cat.name, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
                                          Text('${cat.type} • ${cat.slug}', style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppTheme.textMuted)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined, size: 18),
                                      tooltip: 'Edit category',
                                      onPressed: () {
                                        nameCtrl.text = cat.name;
                                        descCtrl.text = cat.description ?? '';
                                        imgCtrl.text = cat.imageUrl ?? '';
                                        newType = cat.type;
                                        setD(() {});
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.errorRed),
                                      tooltip: 'Delete category',
                                      onPressed: () async {
                                        final ok = await SupabaseService.deleteCategory(cat.id);
                                        if (!ok && context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete failed.')));
                                          return;
                                        }
                                        ref.invalidate(categoriesProvider);
                                        setD(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const Divider(height: 32),
                    Text('ADD / EDIT CATEGORY', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name * (e.g. Aso-Oke Clutches)')),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: newType,
                      decoration: const InputDecoration(labelText: 'Type *'),
                      items: const [
                        DropdownMenuItem(value: 'bags', child: Text('Bags')),
                        DropdownMenuItem(value: 'shoes', child: Text('Shoes')),
                        DropdownMenuItem(value: 'accessories', child: Text('Accessories')),
                      ],
                      onChanged: (v) {
                        if (v != null) setD(() => newType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'Photo link (or upload)'))),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
                          icon: uploading
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.upload, size: 16),
                          label: const Text('UPLOAD'),
                          onPressed: uploading ? null : () => upload(imgCtrl),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('DONE')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.obsidianNoir, foregroundColor: Colors.white),
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Type a name first.')));
                    return;
                  }
                  final cats = await SupabaseService.getCategories();
                  Category? match;
                  for (final c in cats) {
                    if (c.name.toLowerCase() == nameCtrl.text.trim().toLowerCase()) match = c;
                  }
                  bool ok;
                  if (match != null) {
                    ok = await SupabaseService.updateCategory(id: match.id, name: nameCtrl.text.trim(), type: newType, description: descCtrl.text.trim(), imageUrl: imgCtrl.text.trim());
                  } else {
                    ok = await SupabaseService.createCategory(name: nameCtrl.text.trim(), type: newType, description: descCtrl.text.trim(), imageUrl: imgCtrl.text.trim());
                  }
                  if (!ok && ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Save failed. Try again.')));
                    return;
                  }
                  ref.invalidate(categoriesProvider);
                  ref.invalidate(allProductsProvider);
                  nameCtrl.clear();
                  descCtrl.clear();
                  imgCtrl.clear();
                  setD(() {});
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category saved — live on shop now.')));
                  }
                },
                child: const Text('SAVE CATEGORY'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReviewsDialog(BuildContext context) {
    final products = ref.watch(allProductsProvider).value ?? SupabaseService.fallbackProducts;
    String? selectedId = products.isNotEmpty ? products.first.id : null;
    String selectedTitle = products.isNotEmpty ? products.first.title : '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final isDialogMobile = MediaQuery.of(ctx).size.width < 600;
          return AlertDialog(
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: isDialogMobile ? 12 : 40, vertical: 16),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            title: const Text('Moderate Reviews'),
            content: SizedBox(
              width: isDialogMobile ? double.maxFinite : 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Product *'),
                      items: products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.title, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setD(() {
                          selectedId = v;
                          selectedTitle = products.firstWhere((p) => p.id == v).title;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    if (selectedId == null)
                      const Text('No products yet.')
                    else
                      FutureBuilder<List<Review>>(
                        future: SupabaseService.getReviews(selectedId!),
                        builder: (c, snap) {
                          final revs = snap.data ?? [];
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: AppTheme.primaryGold)));
                          }
                          if (revs.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(24),
                              color: AppTheme.surfaceGrey,
                              child: Text(
                                'No reviews for "$selectedTitle" yet.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
                              ),
                            );
                          }
                          return Column(
                            children: [
                              for (final r in revs)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: AppTheme.surfaceGrey, border: Border.all(color: AppTheme.borderSubtle)),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                ...List.generate(r.rating, (_) => const Icon(Icons.star, size: 13, color: AppTheme.primaryGold)),
                                                const SizedBox(width: 8),
                                                Expanded(child: Text(r.authorName, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                              ],
                                            ),
                                            if (r.headline != null && r.headline!.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(r.headline!, style: GoogleFonts.cormorantGaramond(fontSize: 15, fontWeight: FontWeight.bold)),
                                            ],
                                            const SizedBox(height: 4),
                                            Text(r.comment, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted, height: 1.5)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.errorRed),
                                        tooltip: 'Delete this review',
                                        onPressed: () async {
                                          await SupabaseService.deleteReview(r.id);
                                          setD(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('DONE')),
            ],
          );
        },
      ),
    );
  }

  void _showProductDialog(BuildContext context, Product? existing) {
    final isEditing = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final typeCtrl = existing?.productType ?? 'bag';
    final subCatCtrl = TextEditingController(text: existing?.subCategory ?? (typeCtrl == 'bag' ? 'Tote' : 'Slides'));
    final basePriceCtrl = TextEditingController(text: existing?.basePrice.toStringAsFixed(0) ?? '150000');
    final salePriceCtrl = TextEditingController(text: existing?.salePrice?.toStringAsFixed(0) ?? '');
    final shortDescCtrl = TextEditingController(text: existing?.shortDescription ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final materialCtrl = TextEditingController(text: existing?.material ?? 'Full-Grain Italian Calfskin');
    final dimensionsCtrl = TextEditingController(text: existing?.dimensionsCm ?? '');
    final primaryImgCtrl = TextEditingController(text: existing?.primaryImage ?? 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?fm=jpg&fit=crop&w=1000&q=80');
    final videoUrlCtrl = TextEditingController(text: existing?.effectiveVideoUrl ?? '');
    final stockCtrl = TextEditingController(text: existing?.stockQuantity.toString() ?? '10');

    String selectedType = typeCtrl;
    Uint8List? pickedBytes;
    String? pickedName;
    bool uploading = false;
    String? pickedVideoName;
    bool uploadingVideo = false;

    Future<void> pickAndUpload(void Function(void Function()) setDialogState, TextEditingController urlCtrl) async {
      final messenger = ScaffoldMessenger.of(context);
      final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (res == null || res.files.isEmpty) return;
      final f = res.files.first;
      final bytes = f.bytes;
      if (bytes == null) {
        messenger.showSnackBar(const SnackBar(content: Text('Could not read that file. Try another photo.')));
        return;
      }
      setDialogState(() {
        pickedBytes = bytes;
        pickedName = f.name;
        uploading = true;
      });
      final url = await SupabaseService.uploadProductImage(bytes, f.name);
      setDialogState(() => uploading = false);
      if (url == null) {
        messenger.showSnackBar(const SnackBar(content: Text('Upload failed. Check connection or paste an image link instead.')));
        return;
      }
      urlCtrl.text = url;
      messenger.showSnackBar(const SnackBar(content: Text('Photo uploaded.')));
    }

    Future<void> pickAndUploadVideo(void Function(void Function()) setDialogState, TextEditingController urlCtrl) async {
      final messenger = ScaffoldMessenger.of(context);
      final res = await FilePicker.platform.pickFiles(type: FileType.video, withData: true);
      if (res == null || res.files.isEmpty) return;
      final f = res.files.first;
      final bytes = f.bytes;
      if (bytes == null) {
        messenger.showSnackBar(const SnackBar(content: Text('Could not read that video file. Try an MP4 file.')));
        return;
      }
      setDialogState(() {
        pickedVideoName = f.name;
        uploadingVideo = true;
      });
      final url = await SupabaseService.uploadProductVideo(bytes, f.name);
      setDialogState(() => uploadingVideo = false);
      if (url == null) {
        messenger.showSnackBar(const SnackBar(content: Text('Video upload failed. Paste a video link instead.')));
        return;
      }
      urlCtrl.text = url;
      setDialogState(() {});
      messenger.showSnackBar(const SnackBar(content: Text('Product video uploaded!')));
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final isDialogMobile = MediaQuery.of(ctx).size.width < 620;
            return AlertDialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(horizontal: isDialogMobile ? 10 : 40, vertical: 14),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              title: Text(
                isEditing ? 'Edit Product' : 'Add New Product / Video',
                style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: isDialogMobile ? double.maxFinite : 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. MEDIA UPLOADS AT TOP (Photo + Video)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceGrey,
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'STEP 1 • PHOTO & VIDEO MEDIA',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppTheme.primaryGoldDark),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: AppTheme.borderSubtle),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: pickedBytes != null
                                      ? Image.memory(pickedBytes!, fit: BoxFit.cover)
                                      : ShopImage(primaryImgCtrl.text.trim(), w: 200, q: 60),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryGold,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                        ),
                                        icon: uploading
                                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                            : const Icon(Icons.upload, size: 18),
                                        label: Text(
                                          uploading ? 'UPLOADING...' : 'UPLOAD PRODUCT PHOTO',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: uploading ? null : () => pickAndUpload(setDialogState, primaryImgCtrl),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        pickedName ?? 'JPG or PNG photo from your phone or computer.',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: primaryImgCtrl,
                              decoration: const InputDecoration(labelText: 'Primary Photo URL (auto-filled after upload)'),
                              onChanged: (_) => setDialogState(() {}),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: AppTheme.obsidianNoir,
                                    border: Border.all(color: AppTheme.primaryGold),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    videoUrlCtrl.text.trim().isNotEmpty ? Icons.videocam : Icons.videocam_outlined,
                                    color: AppTheme.primaryGold,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.obsidianNoir,
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(color: AppTheme.obsidianNoir),
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                        ),
                                        icon: uploadingVideo
                                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.obsidianNoir))
                                            : const Icon(Icons.video_call_outlined, size: 18),
                                        label: Text(
                                          uploadingVideo ? 'UPLOADING VIDEO...' : 'UPLOAD PRODUCT VIDEO (MP4)',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                        onPressed: uploadingVideo ? null : () => pickAndUploadVideo(setDialogState, videoUrlCtrl),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        pickedVideoName ?? 'Optional MP4 video — appears in Live Video Showcase.',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: videoUrlCtrl,
                              decoration: const InputDecoration(labelText: 'Video URL (Optional — auto-filled after upload)'),
                              onChanged: (_) => setDialogState(() {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. PRODUCT DETAILS & PRICING
                      Text(
                        'STEP 2 • NAME, CATEGORY & PRICING',
                        style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppTheme.primaryGoldDark),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Product Title *'),
                      ),
                      const SizedBox(height: 12),
                      _responsiveFields(isDialogMobile, [
                        DropdownButtonFormField<String>(
                          initialValue: selectedType,
                          decoration: const InputDecoration(labelText: 'Product Type'),
                          items: const [
                            DropdownMenuItem(value: 'bag', child: Text('Handbag')),
                            DropdownMenuItem(value: 'shoe', child: Text('Footwear / Shoe')),
                          ],
                          onChanged: (val) {
                            if (val != null) setDialogState(() => selectedType = val);
                          },
                        ),
                        TextField(
                          controller: subCatCtrl,
                          decoration: const InputDecoration(labelText: 'Style (e.g. Tote, Slides, Heel)'),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      _responsiveFields(isDialogMobile, [
                        TextField(
                          controller: basePriceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Regular Price (₦)'),
                        ),
                        TextField(
                          controller: salePriceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Sale Price (Optional, ₦)'),
                        ),
                        TextField(
                          controller: stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Stock Quantity'),
                        ),
                      ]),
                      const SizedBox(height: 12),
                      TextField(
                        controller: shortDescCtrl,
                        decoration: const InputDecoration(labelText: 'Short Tagline Description'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Full Product Description'),
                      ),
                      const SizedBox(height: 12),
                      _responsiveFields(isDialogMobile, [
                        TextField(
                          controller: materialCtrl,
                          decoration: const InputDecoration(labelText: 'Materials & Lining'),
                        ),
                        TextField(
                          controller: dimensionsCtrl,
                          decoration: const InputDecoration(labelText: 'Dimensions (e.g. 34cm x 26cm x 14cm)'),
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.obsidianNoir,
                    foregroundColor: AppTheme.primaryGold,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () async {
                    final basePrice = double.tryParse(basePriceCtrl.text.trim()) ?? 100000.0;
                    final salePrice = salePriceCtrl.text.trim().isNotEmpty ? double.tryParse(salePriceCtrl.text.trim()) : null;
                    final stock = int.tryParse(stockCtrl.text.trim()) ?? 10;
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please enter a product title.')));
                      return;
                    }
                    final slug = isEditing ? existing.slug : title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
                    final primaryImg = primaryImgCtrl.text.trim();
                    final videoUrl = videoUrlCtrl.text.trim();
                    final mediaList = <String>[
                      if (primaryImg.isNotEmpty) primaryImg,
                      if (isEditing) ...existing.photoImages.where((u) => u != primaryImg),
                      if (videoUrl.isNotEmpty) videoUrl,
                    ];

                    final data = {
                      'title': title,
                      'slug': slug,
                      'product_type': selectedType,
                      'sub_category': subCatCtrl.text.trim(),
                      'base_price': basePrice,
                      'sale_price': salePrice,
                      'short_description': shortDescCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                      'material': materialCtrl.text.trim(),
                      'dimensions_cm': dimensionsCtrl.text.trim(),
                      'primary_image': primaryImg,
                      'images': mediaList,
                      'video_url': videoUrl.isEmpty ? null : videoUrl,
                      'stock_quantity': stock,
                      'currency': 'NGN',
                      if (!isEditing) 'is_featured': true,
                    };

                    if (isEditing) {
                      await SupabaseService.updateProduct(existing.id, data);
                    } else {
                      await SupabaseService.createProduct(data);
                    }

                    ref.invalidate(allProductsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(isEditing ? 'SAVE CHANGES' : 'CREATE PRODUCT'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${product.title}?'),
        content: const Text('Are you sure you want to remove this item from the catalogue? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed, foregroundColor: Colors.white),
            onPressed: () async {
              await SupabaseService.deleteProduct(product.id);
              ref.invalidate(allProductsProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _showPairingDialog(BuildContext context, List<Product> products, {ProductPairing? existing}) {
    final bags = products.where((p) => p.productType == 'bag').toList();
    final shoes = products.where((p) => p.productType == 'shoe').toList();

    if (bags.isEmpty || shoes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one bag and one shoe first, then make a set.')),
      );
      return;
    }

    final isEditing = existing != null;
    String selectedBagId = existing?.bagProductId ?? bags.first.id;
    String selectedShoeId = existing?.shoeProductId ?? shoes.first.id;
    if (!bags.any((b) => b.id == selectedBagId)) selectedBagId = bags.first.id;
    if (!shoes.any((s) => s.id == selectedShoeId)) selectedShoeId = shoes.first.id;
    final titleCtrl = TextEditingController(text: existing?.title ?? 'New Matching Set');
    final descCtrl = TextEditingController(text: existing?.description ?? 'Matching bag + shoe set. Buy together and save.');
    final discountCtrl = TextEditingController(text: '${existing?.bundleDiscountPercent ?? 10}');

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final isDialogMobile = MediaQuery.of(ctx).size.width < 600;
            return AlertDialog(
              backgroundColor: Colors.white,
              insetPadding: EdgeInsets.symmetric(horizontal: isDialogMobile ? 12 : 40, vertical: 16),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              title: Text(isEditing ? 'Edit Matching Set' : 'Create Matching Set'),
              content: SizedBox(
                width: isDialogMobile ? double.maxFinite : 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedBagId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Bag in this set *'),
                        items: bags.map((b) => DropdownMenuItem(value: b.id, child: Text(b.title, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedBagId = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedShoeId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Shoe in this set *'),
                        items: shoes.map((s) => DropdownMenuItem(value: s.id, child: Text(s.title, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedShoeId = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Set name * (e.g. Owambe Ready Set)'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Short description'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: discountCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Discount % when bought together (10 or 15)'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.obsidianNoir, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please give the set a name.')));
                      return;
                    }
                    final discount = (int.tryParse(discountCtrl.text.trim()) ?? 10).clamp(1, 50);
                    bool ok;
                    if (isEditing) {
                      ok = await SupabaseService.updatePairing(
                        id: existing.id,
                        title: titleCtrl.text.trim(),
                        bagProductId: selectedBagId,
                        shoeProductId: selectedShoeId,
                        discountPercent: discount,
                        description: descCtrl.text.trim(),
                      );
                    } else {
                      ok = await SupabaseService.createPairing(
                        title: titleCtrl.text.trim(),
                        bagProductId: selectedBagId,
                        shoeProductId: selectedShoeId,
                        discountPercent: discount,
                        description: descCtrl.text.trim(),
                      );
                    }
                    if (!ok && ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Could not save. Check connection and try again.')));
                      return;
                    }
                    ref.invalidate(pairingsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(isEditing ? 'SAVE CHANGES' : 'CREATE SET'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPromoDialog(BuildContext context, Map<String, dynamic>? existing) {
    final codeCtrl = TextEditingController();
    final percentCtrl = TextEditingController(text: '10');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text('Create Discount Code'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Code * (e.g. DETTY20)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: percentCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Discount % (1-90)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.obsidianNoir, foregroundColor: Colors.white),
            onPressed: () async {
              final code = codeCtrl.text.trim().toUpperCase();
              final pct = (int.tryParse(percentCtrl.text.trim()) ?? 0).clamp(1, 90);
              if (code.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Type a code first.')));
                return;
              }
              final ok = await SupabaseService.createPromoCode(code: code, percent: pct);
              if (!ok && ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Code exists already or save failed.')));
                return;
              }
              setState(() {});
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('CREATE CODE'),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.obsidianNoir)),
                    const SizedBox(height: 3),
                    Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textMuted)),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}
