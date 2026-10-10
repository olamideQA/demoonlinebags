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
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../common/announcement_bar.dart';
import '../common/luxury_footer.dart';
import '../common/luxury_header.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Security Gate Controllers
  final _adminEmailController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  bool _obscureAdminPassword = true;
  String? _gateError;
  bool _isLoggingIn = false;

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
    _tabController = TabController(length: 6, vsync: this);
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
    _tabController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Security Gate: exclusive to verified admin
    if (!authState.isAuthenticated || !authState.isAdmin) {
      return _buildSecurityGate(context, authState);
    }

    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AnnouncementBar(),
            const LuxuryHeader(),

            // Admin Header Bar
            Container(
              color: AppTheme.obsidianNoir,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 64, vertical: 28),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.admin_panel_settings, color: AppTheme.primaryGold, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'STORE MANAGER',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.primaryGold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Orders, Products & Website Text',
                        style: GoogleFonts.cormorantGaramond(
                          color: Colors.white,
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hello ${authState.profile?.fullName ?? authState.user?.email ?? 'Owner'} • ${_ordersList.length} orders today • Tap a tab below to manage your shop',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white60,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 12,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 16),
                        label: const Text('PREVIEW STORE', style: TextStyle(fontSize: 11, letterSpacing: 1.2)),
                        onPressed: () => context.go('/'),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        icon: const Icon(Icons.logout, size: 16),
                        label: const Text('LOGOUT', style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          await ref.read(authProvider.notifier).signOut();
                          if (context.mounted) context.go('/');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Business overview - how is the shop doing today?
            _buildBusinessOverview(context, isMobile),

            // Tab Navigation
            Container(
              color: Colors.white,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppTheme.obsidianNoir,
                unselectedLabelColor: AppTheme.textMuted,
                indicatorColor: AppTheme.primaryGold,
                indicatorWeight: 3,
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.2),
                tabs: const [
                  Tab(icon: Icon(Icons.text_fields_outlined, size: 18), text: 'WEBSITE TEXT'),
                  Tab(icon: Icon(Icons.shopping_bag_outlined, size: 18), text: 'PRODUCTS'),
                  Tab(icon: Icon(Icons.auto_awesome_outlined, size: 18), text: 'MATCHING SETS'),
                  Tab(icon: Icon(Icons.receipt_long_outlined, size: 18), text: 'ORDERS'),
                  Tab(icon: Icon(Icons.local_offer_outlined, size: 18), text: 'PROMO CODES'),
                  Tab(icon: Icon(Icons.favorite_border, size: 18), text: 'STORE HEALTH'),
                ],
              ),
            ),

            // Tab Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 36),
              child: SizedBox(
                height: 900,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildCMSCustomizationTab(context),
                    _buildProductsManagerTab(context),
                    _buildPairingsManagerTab(context),
                    _buildOrdersManagerTab(context),
                    _buildPromoCodesTab(context),
                    _buildSystemHealthTab(context),
                  ],
                ),
              ),
            ),

            const LuxuryFooter(),
          ],
        ),
      ),
    );
  }

  // --- SECURITY GATE FOR ADMIN EXCLUSIVITY ---
  Widget _buildSecurityGate(BuildContext context, AppAuthState authState) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.primaryGold, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: AppTheme.obsidianNoir,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_person, color: AppTheme.primaryGold, size: 30),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'STORE OWNER ACCESS',
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
                    'Administrator Access Required',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.obsidianNoir,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This back-office suite is strictly exclusive to store owners. Unverified users cannot view store controls or modify website copy.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  if (authState.isAuthenticated && !authState.isAdmin) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed.withValues(alpha: 0.1),
                        border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        'Access Denied: Current account (${authState.user?.email}) is registered as a customer. Please sign in with an Administrator account.',
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
                      labelText: 'Administrator Email',
                      prefixIcon: Icon(Icons.mail_outline, size: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _adminPasswordController,
                    obscureText: _obscureAdminPassword,
                    decoration: InputDecoration(
                      labelText: 'Admin Security Password',
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
                            'AUTHENTICATE & UNLOCK CMS',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                          ),
                  ),
                  const SizedBox(height: 16),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppTheme.borderSubtle),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    ),
                    onPressed: () => context.go('/'),
                    child: Text(
                      'RETURN TO PUBLIC STORE',
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

  /// Business overview strip: revenue, pending orders, products, low stock.
  /// Answers "how is my shop doing?" at a glance.
  Widget _buildBusinessOverview(BuildContext context, bool isMobile) {
    final products = ref.watch(filteredProductsProvider);
    double revenue = 0;
    int pending = 0;
    for (final o in _ordersList) {
      revenue += ((o['total'] as num?)?.toDouble() ?? 0.0);
      final st = (o['status']?.toString() ?? 'pending').toLowerCase();
      if (st == 'pending' || st == 'processing') pending++;
    }
    final lowStock = products.where((p) => p.stockQuantity <= 5).length;
    final productCount = products.length;

    String naira(double v) {
      final n = v.round().toString();
      final buf = StringBuffer();
      for (int i = 0; i < n.length; i++) {
        if (i > 0 && (n.length - i) % 3 == 0) buf.write(',');
        buf.write(n[i]);
      }
      return '₦${buf}';
    }

    Widget stat(IconData icon, String label, String value, {bool alert = false}) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: alert ? AppTheme.errorRed.withValues(alpha: 0.5) : AppTheme.borderSubtle,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: alert ? AppTheme.errorRed : AppTheme.primaryGoldDark),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.plusJakartaSans(fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.obsidianNoir),
              ),
            ],
          ),
        ),
      );
    }

    final cards = [
      stat(Icons.payments_outlined, 'TOTAL SALES', naira(revenue)),
      stat(Icons.pending_actions_outlined, 'NEEDS ACTION', '$pending orders', alert: pending > 0),
      stat(Icons.inventory_2_outlined, 'PRODUCTS', '$productCount live'),
      stat(Icons.warning_amber_outlined, 'LOW STOCK', '$lowStock items', alert: lowStock > 0),
    ];

    return Container(
      color: AppTheme.surfaceGrey,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TODAY AT A GLANCE',
            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppTheme.primaryGoldDark),
          ),
          const SizedBox(height: 12),
          if (isMobile)
            Column(
              children: [
                Row(children: [cards[0], const SizedBox(width: 12), cards[1]]),
                const SizedBox(height: 12),
                Row(children: [cards[2], const SizedBox(width: 12), cards[3]]),
              ],
            )
          else
            Row(
              children: [
                cards[0], const SizedBox(width: 12),
                cards[1], const SizedBox(width: 12),
                cards[2], const SizedBox(width: 12),
                cards[3],
              ],
            ),
        ],
      ),
    );
  }

  // --- TAB 1: WEBSITE CMS (EVERY TEXT & BUTTON CUSTOMIZABLE) ---
  Widget _buildCMSCustomizationTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIVE STORE CONTENT CMS',
                    style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppTheme.primaryGoldDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customize Every Button, Header, Hero, and Copy',
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
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),

          // 1. Announcement Bar
          _sectionCard(
            title: 'Top Notice Bar',
            subtitle: 'Small message at very top — e.g. free delivery news',
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show Announcement Bar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: const Text('Toggle banner visibility across entire store', style: TextStyle(fontSize: 11)),
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
          const SizedBox(height: 24),

          // 2. Header & Branding
          _sectionCard(
            title: 'Shop Name & Tagline',
            subtitle: 'Your store name shown at top on every page',
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _headerBrandCtrl,
                      decoration: const InputDecoration(labelText: 'Shop Name (e.g. LUXE LAGOS)'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _headerTaglineCtrl,
                      decoration: const InputDecoration(labelText: 'Brand Subtitle / Tagline'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Hero Section
          _sectionCard(
            title: 'Top Welcome Banner',
            subtitle: 'Main photo, headline and shop buttons on homepage',
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heroBadgeCtrl,
                      decoration: const InputDecoration(labelText: 'Small Top Text (e.g. LAGOS BESTSELLER)'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _heroImageCtrl,
                      decoration: const InputDecoration(labelText: 'Hero Background Image URL'),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _heroTitleCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Big Headline (e.g. Pepper Them at Every Owambe)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _heroSubtitleCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Short Description Under Headline'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heroCtaTextCtrl,
                      decoration: const InputDecoration(labelText: 'Main Button Text (e.g. SHOP BAGS)'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _heroCtaUrlCtrl,
                      decoration: const InputDecoration(labelText: 'Primary Button Link (e.g. /shop)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heroSecondaryTextCtrl,
                      decoration: const InputDecoration(labelText: 'Second Button Text (e.g. SHOP MATCHING SETS)'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _heroSecondaryUrlCtrl,
                      decoration: const InputDecoration(labelText: 'Secondary Button Link (e.g. /pairings)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3b. Homepage Banners (all slides) - this is what shoppers swipe.
          _buildHeroSlidesEditor(context, ref),
          const SizedBox(height: 24),

          // 4. Footer & Contact Details
          _sectionCard(
            title: 'Contact & WhatsApp Details',
            subtitle: 'Phone, WhatsApp, shop address shown at bottom of site',
            children: [
              TextField(
                controller: _footerBioCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'About Your Shop (short story)'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _footerEmailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _footerPhoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone Line'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _footerWhatsappCtrl,
                      decoration: const InputDecoration(labelText: 'WhatsApp Number'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _footerAddressCtrl,
                      decoration: const InputDecoration(labelText: 'Shop Address'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _footerCopyrightCtrl,
                      decoration: const InputDecoration(labelText: 'Copyright Line'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. Store Currency & Free Shipping
          _sectionCard(
            title: 'Currency & Shipping Threshold',
            subtitle: 'Storewide currency symbol and VIP free shipping qualification',
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _currencySymbolCtrl,
                      decoration: const InputDecoration(labelText: 'Currency Symbol (e.g. ₦, \$, £, €)'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _freeShippingCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Free Delivery Threshold (Amount in Currency)'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
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
        SnackBar(
          content: const Text('All website content & copy published successfully to live store!'),
          backgroundColor: AppTheme.obsidianNoir,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Banners editor: every slide shoppers swipe, with photo upload.
  /// Saves instantly (no need for PUBLISH ALL).
  Widget _buildHeroSlidesEditor(BuildContext context, WidgetRef ref) {
    final slides = ref.watch(siteSettingsProvider).hero.slides;
    return _sectionCard(
      title: 'Homepage Banners (${slides.length} slides)',
      subtitle: 'These are the photos shoppers swipe on the homepage. Edit any slide or add a new one.',
      children: [
        for (int i = 0; i < slides.length; i++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGrey,
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Row(
              children: [
                ClipRRect(
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: ShopImage(slides[i].imageUrl, w: 200, q: 60),
                  ),
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
        ],
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.obsidianNoir,
            side: const BorderSide(color: AppTheme.borderSubtle),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: Text(
            slides.length >= 6 ? 'MAX 6 SLIDES' : 'ADD NEW BANNER',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          onPressed: slides.length >= 6
              ? null
              : () => _showSlideDialog(context, ref),
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
          Future<void> upload() async {
            final messenger = ScaffoldMessenger.of(context);
            final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
            if (res == null || res.files.isEmpty) return;
            final bytes = res.files.first.bytes;
            if (bytes == null) {
              messenger.showSnackBar(const SnackBar(content: Text('Could not read that file.')));
              return;
            }
            setD(() { pickedBytes = bytes; uploading = true; });
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
            title: Text(isEditing ? 'Edit Banner ${index != null ? index + 1 : ''}' : 'Add New Banner'),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
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
                            label: Text(uploading ? 'UPLOADING...' : 'UPLOAD PHOTO',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: uploading ? null : upload,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: imgCtrl, decoration: const InputDecoration(labelText: 'Photo link (auto-filled after upload, or paste)'), onChanged: (_) => setD(() {})),
                    const SizedBox(height: 12),
                    TextField(controller: badgeCtrl, decoration: const InputDecoration(labelText: 'Small top text * (e.g. LAGOS BESTSELLER)')),
                    const SizedBox(height: 12),
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Big headline * (e.g. Pepper Them at Every Owambe)')),
                    const SizedBox(height: 12),
                    TextField(controller: subCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Short description under headline')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: ctaCtrl, decoration: const InputDecoration(labelText: 'Main button (e.g. SHOP BAGS)'))),
                        const SizedBox(width: 12),
                        Expanded(child: TextField(controller: secCtrl, decoration: const InputDecoration(labelText: 'Second button'))),
                      ],
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Banner saved — live on homepage now.')));
                },
                child: Text(isEditing ? 'SAVE BANNER' : 'ADD BANNER'),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- TAB 2: PRODUCTS MANAGER (FULL CRUD) ---
  Widget _buildProductsManagerTab(BuildContext context) {
    final products = ref.watch(filteredProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRODUCTS & STOCK',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppTheme.primaryGoldDark),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage Bags, Footwear & Details (${products.length} Items)',
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
              label: Text(
                'ADD NEW CREATION',
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              ),
              onPressed: () => _showProductDialog(context, null),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 16),

        Expanded(
          child: ListView.separated(
            itemCount: products.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = products[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderSubtle),
                    image: DecorationImage(
                      image: NetworkImage(p.primaryImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  p.title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${p.productType.toUpperCase()} • ${p.subCategory ?? ''} • ₦${p.basePrice.toStringAsFixed(0)} • Stock: ${p.stockQuantity}',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.obsidianNoir),
                      tooltip: 'Edit Creation',
                      onPressed: () => _showProductDialog(context, p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.errorRed),
                      tooltip: 'Delete Creation',
                      onPressed: () => _confirmDeleteProduct(context, p),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showProductDialog(BuildContext context, Product? existing) {
    final isEditing = existing != null;
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final typeCtrl = existing?.productType ?? 'bag';
    final subCatCtrl = TextEditingController(text: existing?.subCategory ?? (typeCtrl == 'bag' ? 'Tote' : 'Stiletto'));
    final basePriceCtrl = TextEditingController(text: existing?.basePrice.toStringAsFixed(0) ?? '150000');
    final salePriceCtrl = TextEditingController(text: existing?.salePrice?.toStringAsFixed(0) ?? '');
    final shortDescCtrl = TextEditingController(text: existing?.shortDescription ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final materialCtrl = TextEditingController(text: existing?.material ?? 'Full-Grain Italian Calfskin');
    final dimensionsCtrl = TextEditingController(text: existing?.dimensionsCm ?? '');
    final primaryImgCtrl = TextEditingController(text: existing?.primaryImage ?? 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80');
    final stockCtrl = TextEditingController(text: existing?.stockQuantity.toString() ?? '10');

    String selectedType = typeCtrl;
    Uint8List? pickedBytes;
    String? pickedName;
    bool uploading = false;

    Future<void> pickAndUpload(void Function(void Function()) setDialogState, TextEditingController urlCtrl) async {
      final messenger = ScaffoldMessenger.of(context);
      final res = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
      if (res == null || res.files.isEmpty) return;
      final f = res.files.first;
      final bytes = f.bytes;
      if (bytes == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Could not read that file. Try another photo.')),
        );
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
        messenger.showSnackBar(
          const SnackBar(content: Text('Upload failed. Check connection or paste an image link instead.')),
        );
        return;
      }
      urlCtrl.text = url;
      messenger.showSnackBar(
        const SnackBar(content: Text('Photo uploaded.')),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              title: Text(
                isEditing ? 'Edit Product: ${existing.title}' : 'Add New Product',
                style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              content: SizedBox(
                width: 600,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(labelText: 'Product Title'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: selectedType,
                              decoration: const InputDecoration(labelText: 'Product Type'),
                              items: const [
                                DropdownMenuItem(value: 'bag', child: Text('Handbag')),
                                DropdownMenuItem(value: 'shoe', child: Text('Footwear')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setDialogState(() => selectedType = val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: subCatCtrl,
                              decoration: const InputDecoration(labelText: 'Silhouette (Tote, Crossbody, Mule, etc.)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: basePriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Base Price (₦)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: salePriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Sale Price (Optional, ₦)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: stockCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Stock Units'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: shortDescCtrl,
                        decoration: const InputDecoration(labelText: 'Short Tagline Description'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Full Editorial Description'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: materialCtrl,
                        decoration: const InputDecoration(labelText: 'Artisan Materials & Lining'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: dimensionsCtrl,
                        decoration: const InputDecoration(labelText: 'Dimensions (e.g. 36cm x 27cm x 14cm)'),
                      ),
                      const SizedBox(height: 12),
                      // Photo: upload from device (recommended) or paste a link.
                      Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceGrey,
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
                                    uploading ? 'UPLOADING...' : 'UPLOAD PHOTO',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: uploading ? null : () => pickAndUpload(setDialogState, primaryImgCtrl),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  pickedName ?? 'JPG/PNG from your phone or laptop. Auto-fills the link below.',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: primaryImgCtrl,
                        decoration: const InputDecoration(labelText: 'Primary Image URL (auto-filled after upload, or paste link)'),
                        onChanged: (_) => setDialogState(() {}),
                      ),
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
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final basePrice = double.tryParse(basePriceCtrl.text.trim()) ?? 100000.0;
                    final salePrice = salePriceCtrl.text.trim().isNotEmpty ? double.tryParse(salePriceCtrl.text.trim()) : null;
                    final stock = int.tryParse(stockCtrl.text.trim()) ?? 10;
                    final title = titleCtrl.text.trim();
                    final slug = isEditing ? existing.slug : title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');

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
                      'primary_image': primaryImgCtrl.text.trim(),
                      'images': [primaryImgCtrl.text.trim()],
                      'stock_quantity': stock,
                      'currency': 'NGN',
                    };

                    if (isEditing) {
                      await SupabaseService.updateProduct(existing.id, data);
                    } else {
                      await SupabaseService.createProduct(data);
                    }

                    ref.invalidate(allProductsProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(isEditing ? 'UPDATE' : 'CREATE'),
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
        content: const Text('Are you sure you want to remove this creation from the catalog? This action cannot be undone.'),
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

  // --- TAB 3: MATCHING SETS ---
  Widget _buildPairingsManagerTab(BuildContext context) {
    final pairingsAsync = ref.watch(pairingsProvider);
    final products = ref.watch(filteredProductsProvider);
    final pairings = pairingsAsync.value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MATCHING BAG + SHOE SETS',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppTheme.primaryGoldDark),
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
                side: const BorderSide(color: AppTheme.primaryGold),
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('CREATE NEW SET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              onPressed: () => _showPairingDialog(context, products),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 16),

        Expanded(
          child: ListView.separated(
            itemCount: pairings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final pair = pairings[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    if (pair.bagProduct != null)
                      ClipRRect(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: ShopImage(pair.bagProduct!.primaryImage, w: 200, q: 60),
                        ),
                      ),
                    const SizedBox(width: 8),
                    const Icon(Icons.add, size: 16, color: AppTheme.primaryGold),
                    const SizedBox(width: 8),
                    if (pair.shoeProduct != null)
                      ClipRRect(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: ShopImage(pair.shoeProduct!.primaryImage, w: 200, q: 60),
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pair.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            'Discount: ${pair.bundleDiscountPercent}% OFF • Combined Set: ₦${pair.discountedBundlePrice.toStringAsFixed(0)}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.primaryGoldDark, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(pair.description ?? '', style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// How matching sets work: pick ONE bag + ONE shoe, give the set a name,
  /// a short description and a discount (10 or 15). Shoppers see it on
  /// Matching Sets page and can buy both together cheaper.
  /// Same dialog creates new sets and edits existing ones.
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
    // Guard against deleted products still referenced by an old set.
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
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(isEditing ? 'Edit Matching Set' : 'Create Matching Set'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedBagId,
                        decoration: const InputDecoration(labelText: 'Bag in this set *'),
                        items: bags.map((b) => DropdownMenuItem(value: b.id, child: Text(b.title, overflow: TextOverflow.ellipsis))).toList(),
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedBagId = val);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedShoeId,
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
                        decoration: const InputDecoration(labelText: 'Short description (why this match is fine)'),
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
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Please give the set a name.')),
                      );
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
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Could not save. Check connection and try again.')),
                      );
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

  // --- TAB 4: ORDERS & FULFILLMENT ---
  Widget _buildOrdersManagerTab(BuildContext context) {
    if (_isLoadingOrders) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
    }

    if (_ordersList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text('No Client Orders Received Yet', style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Orders placed through the checkout will appear here in real-time.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LIVE CLIENT ORDERS (${_ordersList.length})',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppTheme.primaryGoldDark),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadOrders,
              tooltip: 'Refresh Orders',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: _ordersList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = _ordersList[index];
              final orderId = order['id'] as String? ?? '';
              final orderNum = order['order_number'] as String? ?? 'N/A';
              final customer = order['customer_name'] as String? ?? 'Unknown';
              final email = order['customer_email'] as String? ?? '';
              final total = (order['total'] as num?)?.toDouble() ?? 0.0;
              final status = order['status'] as String? ?? 'pending';

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(orderNum, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'delivered' ? AppTheme.successGreen.withValues(alpha: 0.1) : AppTheme.primaryGold.withValues(alpha: 0.15),
                            border: Border.all(color: status == 'delivered' ? AppTheme.successGreen : AppTheme.primaryGold),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Customer: $customer ($email)', style: GoogleFonts.plusJakartaSans(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('Order Total: ₦${total.toStringAsFixed(0)}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.obsidianNoir)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Update Status: ', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: status,
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
        ),
      ],
    );
  }

  // --- TAB 5: PROMO CODES (admin-managed discounts) ---
  Widget _buildPromoCodesTab(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: SupabaseService.getPromoCodes(),
      builder: (ctx, snap) {
        final codes = snap.data ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DISCOUNT CODES',
                      style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppTheme.primaryGoldDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Promo Codes (${codes.length})',
                      style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.obsidianNoir,
                    foregroundColor: AppTheme.primaryGold,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    side: const BorderSide(color: AppTheme.primaryGold),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('NEW CODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () => _showPromoDialog(ctx, null),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Shoppers type these at checkout. Example: LUXE10 = 10% off.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            if (snap.connectionState == ConnectionState.waiting)
              const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppTheme.primaryGold)))
            else if (codes.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                color: Colors.white,
                child: const Center(child: Text('No codes yet. Create LUXE10 to start.')),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: codes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
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
                                fontSize: 14,
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
                              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
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
              ),
          ],
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

  // --- TAB 6: SYSTEM HEALTH ---
  Widget _buildSystemHealthTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STORE SYSTEM STATUS',
            style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppTheme.primaryGoldDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Cloud Database Diagnostics',
            style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          _systemMetricTile(Icons.cloud_done, 'Supabase Cloud Database', 'Project Ref: htvcavnqsgyjrbtqefxk • Region: EU Central', AppTheme.successGreen),
          const SizedBox(height: 12),
          _systemMetricTile(Icons.mark_email_read, 'Supabase Auth Verification', 'Instant VIP Activation Enabled (mailer_autoconfirm: True)', AppTheme.successGreen),
          const SizedBox(height: 12),
          _systemMetricTile(Icons.storage, 'PostgreSQL Storage Engine', 'Tables: products, categories, pairings, orders, site_settings', AppTheme.primaryGold),
          const SizedBox(height: 12),
          _systemMetricTile(Icons.security, 'Row Level Security (RLS)', 'Active with public read & authenticated write policies', AppTheme.successGreen),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required String subtitle, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted)),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _systemMetricTile(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
