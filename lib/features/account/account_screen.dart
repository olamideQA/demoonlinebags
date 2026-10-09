import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/models/models.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/wishlist_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_modal.dart';
import '../common/announcement_bar.dart';
import '../common/luxury_bottom_nav.dart';
import '../common/luxury_footer.dart';
import '../common/luxury_header.dart';
import '../common/product_card.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> _userOrders = [];
  bool _isLoadingOrders = false;

  // Profile Edit Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isSavingProfile = false;
  String? _profileMessage;

  // Add Address Form Controllers
  final _addressStreetController = TextEditingController();
  final _addressCityController = TextEditingController();
  final _addressStateController = TextEditingController(text: 'Lagos');
  final _addressPhoneController = TextEditingController();
  final _addressNotesController = TextEditingController();
  bool _isAddingAddress = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    final authState = ref.read(authProvider);
    _nameController = TextEditingController(text: authState.profile?.fullName ?? '');
    _phoneController = TextEditingController(text: authState.profile?.phone ?? '');
    _loadUserOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressStreetController.dispose();
    _addressCityController.dispose();
    _addressStateController.dispose();
    _addressPhoneController.dispose();
    _addressNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadUserOrders() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) return;

    setState(() => _isLoadingOrders = true);
    final orders = await SupabaseService.getUserOrders(
      userId: auth.user?.id,
      email: auth.user?.email,
    );

    if (mounted) {
      setState(() {
        _userOrders = orders;
        _isLoadingOrders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final wishlist = ref.watch(wishlistProvider);
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      bottomNavigationBar: isMobile ? const LuxuryBottomNav() : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AnnouncementBar(),
            const LuxuryHeader(),

            if (!authState.isAuthenticated)
              _buildGuestPrompt(context)
            else
              _buildDashboardContent(context, authState, wishlist, isMobile),

            const LuxuryFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      color: AppTheme.backgroundLight,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.primaryGold, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppTheme.obsidianNoir,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_person_outlined, color: AppTheme.primaryGold, size: 30),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'ATELIER PRIVÉ',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.2,
                    color: AppTheme.primaryGoldDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Client Suite Access',
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.obsidianNoir,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Sign in to access your order fulfillment records, bespoke monogramming requests, saved creations, and VIP client privileges.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.obsidianNoir,
                    foregroundColor: AppTheme.primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    side: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
                  ),
                  onPressed: () => AuthModal.show(context),
                  child: Text(
                    'SIGN IN / CREATE CLIENT ACCOUNT',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.obsidianNoir,
                    side: const BorderSide(color: AppTheme.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  onPressed: () => context.go('/shop'),
                  child: Text(
                    'EXPLORE ATELIER CREATIONS',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
    BuildContext context,
    AppAuthState authState,
    List<Product> wishlist,
    bool isMobile,
  ) {
    final profile = authState.profile;
    final fullName = profile?.fullName?.isNotEmpty == true
        ? profile!.fullName!
        : (authState.user?.email ?? 'Valued Client');
    final email = profile?.email ?? authState.user?.email ?? '';
    final phone = profile?.phone ?? '';
    final isAdmin = authState.isAdmin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Executive Suite Header
        Container(
          color: AppTheme.obsidianNoir,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 64, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 24,
                runSpacing: 20,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isMobile ? 56 : 72,
                        height: isMobile ? 56 : 72,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(color: AppTheme.primaryGold, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            fullName.isNotEmpty ? fullName[0].toUpperCase() : 'C',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: isMobile ? 28 : 36,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGold.withValues(alpha: 0.18),
                                  border: Border.all(color: AppTheme.primaryGold),
                                ),
                                child: Text(
                                  isAdmin ? '👑 ATELIER EXECUTIVE ADMINISTRATOR' : '✨ VIP ATELIER PRIVÉ PATRON',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppTheme.primaryGold,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            fullName,
                            style: GoogleFonts.cormorantGaramond(
                              color: Colors.white,
                              fontSize: isMobile ? 24 : 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email + (phone.isNotEmpty ? ' • $phone' : ''),
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Action Buttons
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      if (isAdmin)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          icon: const Icon(Icons.admin_panel_settings, size: 18),
                          label: Text(
                            'ENTER ATELIER CMS & ADMIN PORTAL',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 1.4),
                          ),
                          onPressed: () => context.go('/admin'),
                        ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        ),
                        icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                        label: Text(
                          'BROWSE BOUTIQUE',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                        ),
                        onPressed: () => context.go('/shop'),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        ),
                        icon: const Icon(Icons.logout, size: 16),
                        label: Text(
                          'SIGN OUT',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                        onPressed: () async {
                          await ref.read(authProvider.notifier).signOut();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('You have been signed out.')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 28),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 24),

              // Metric Highlights Cards
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _buildMetricPill(
                    icon: Icons.receipt_long,
                    label: 'ACQUISITIONS',
                    value: '${_userOrders.length} Order${_userOrders.length == 1 ? '' : 's'}',
                  ),
                  _buildMetricPill(
                    icon: Icons.favorite,
                    label: 'SAVED CREATIONS',
                    value: '${wishlist.length} Piece${wishlist.length == 1 ? '' : 's'}',
                  ),
                  _buildMetricPill(
                    icon: Icons.local_shipping,
                    label: 'VIP DELIVERY',
                    value: 'Complimentary VIP Courier',
                  ),
                  _buildMetricPill(
                    icon: Icons.verified,
                    label: 'CRAFTSMANSHIP',
                    value: '100% Italian Leather Guarantee',
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Tab Navigation
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
            tabs: [
              Tab(
                icon: const Icon(Icons.shopping_basket_outlined, size: 18),
                text: '1. MY ORDERS (${_userOrders.length})',
              ),
              Tab(
                icon: const Icon(Icons.favorite_border, size: 18),
                text: '2. WISHLIST (${wishlist.length})',
              ),
              const Tab(
                icon: Icon(Icons.location_on_outlined, size: 18),
                text: '3. DELIVERY ADDRESSES',
              ),
              const Tab(
                icon: Icon(Icons.auto_awesome_outlined, size: 18),
                text: '4. BESPOKE & CONCIERGE',
              ),
              const Tab(
                icon: Icon(Icons.manage_accounts_outlined, size: 18),
                text: '5. PROFILE & SETTINGS',
              ),
            ],
          ),
        ),

        // 3. Tab Views Content
        Container(
          color: AppTheme.backgroundLight,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 64, vertical: 36),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 500),
            child: [
              _buildOrdersTab(context, isMobile),
              _buildWishlistTab(context, wishlist, isMobile),
              _buildAddressesTab(context, profile, isMobile),
              _buildBespokeTab(context, isMobile),
              _buildSettingsTab(context, authState, isMobile),
            ][_tabController.index],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 16),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white54,
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 1: MY ORDERS ---
  Widget _buildOrdersTab(BuildContext context, bool isMobile) {
    if (_isLoadingOrders) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(color: AppTheme.primaryGold),
        ),
      );
    }

    if (_userOrders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGrey,
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.textMuted, size: 30),
              ),
              const SizedBox(height: 20),
              Text(
                'No Atelier Acquisitions Yet',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.obsidianNoir,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your signature collection begins with your first bespoke handbag or sculpted footwear selection.',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.obsidianNoir,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                onPressed: () => context.go('/shop'),
                child: Text(
                  'DISCOVER ATELIER CREATIONS',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 1.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currencyFmt = NumberFormat('#,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Acquisition History (${_userOrders.length})',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.obsidianNoir,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 20),
              tooltip: 'Refresh orders',
              onPressed: _loadUserOrders,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _userOrders.length,
          separatorBuilder: (ctx, idx) => const SizedBox(height: 20),
          itemBuilder: (context, index) {
            final order = _userOrders[index];
            final items = (order['order_items'] as List?) ?? [];
            final total = (order['total'] as num?)?.toDouble() ?? 0.0;
            final status = order['status']?.toString() ?? 'pending';
            final orderNumber = order['order_number']?.toString() ?? 'ATELIER-ORDER';
            final dateStr = order['created_at'] != null
                ? DateFormat('MMMM d, yyyy • h:mm a').format(DateTime.tryParse(order['created_at'].toString()) ?? DateTime.now())
                : 'Recent';
            final trackingCode = order['tracking_code']?.toString();
            final address = order['shipping_address'] as Map<String, dynamic>?;

            Color statusColor;
            String statusLabel;
            switch (status) {
              case 'delivered':
                statusColor = AppTheme.successGreen;
                statusLabel = 'DELIVERED TO CLIENT';
                break;
              case 'shipped':
                statusColor = Colors.blue.shade700;
                statusLabel = 'DISPATCHED WITH VIP COURIER';
                break;
              case 'processing':
                statusColor = AppTheme.primaryGoldDark;
                statusLabel = 'PREPARING IN ATELIER';
                break;
              case 'cancelled':
                statusColor = AppTheme.errorRed;
                statusLabel = 'ORDER CANCELLED';
                break;
              default:
                statusColor = Colors.orange.shade800;
                statusLabel = 'ORDER RECEIVED • AWAITING FULFILLMENT';
            }

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Order Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    color: AppTheme.surfaceGrey,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 16,
                      runSpacing: 10,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  orderNumber,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: AppTheme.obsidianNoir,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(text: orderNumber));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Order number copied to clipboard.')),
                                    );
                                  },
                                  child: const Icon(Icons.copy, size: 14, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                statusLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '₦${currencyFmt.format(total)}',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.obsidianNoir,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tracking Strip (If Available)
                  if (trackingCode != null && trackingCode.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      color: AppTheme.primaryGold.withValues(alpha: 0.08),
                      child: Row(
                        children: [
                          const Icon(Icons.local_shipping, size: 16, color: AppTheme.primaryGoldDark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'VIP Courier Tracking: $trackingCode',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.obsidianNoir,
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryGoldDark,
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: trackingCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tracking code copied.')),
                              );
                            },
                            child: const Text('COPY CODE', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),

                  // Items List
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ...items.map((item) {
                          final itemTitle = item['product_title']?.toString() ?? 'Luxury Atelier Creation';
                          final itemImage = item['product_image']?.toString() ?? '';
                          final itemColor = item['selected_color']?.toString() ?? '';
                          final itemSize = item['selected_size']?.toString() ?? '';
                          final itemQty = item['quantity'] ?? 1;
                          final itemPrice = (item['unit_price'] as num?)?.toDouble() ?? 0.0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceGrey,
                                    border: Border.all(color: AppTheme.borderSubtle),
                                  ),
                                  child: itemImage.isNotEmpty
                                      ? Image.network(
                                          itemImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, stack) => const Icon(Icons.shopping_bag_outlined, color: AppTheme.textMuted),
                                        )
                                      : const Icon(Icons.shopping_bag_outlined, color: AppTheme.textMuted),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        itemTitle,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.obsidianNoir,
                                        ),
                                      ),
                                      if (itemColor.isNotEmpty || itemSize.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          [if (itemColor.isNotEmpty) itemColor, if (itemSize.isNotEmpty) 'Size $itemSize'].join(' • '),
                                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
                                        ),
                                      ],
                                      const SizedBox(height: 2),
                                      Text(
                                        'Qty: $itemQty • ₦${currencyFmt.format(itemPrice)} each',
                                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₦${currencyFmt.format(itemPrice * itemQty)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.obsidianNoir,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),

                        const Divider(height: 20),

                        // Destination & Action Bar
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 10,
                          children: [
                            if (address != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.pin_drop_outlined, size: 14, color: AppTheme.textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Delivery: ${address['street'] ?? ''}, ${address['city'] ?? ''}, ${address['state'] ?? 'Nigeria'}',
                                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    side: const BorderSide(color: AppTheme.borderSubtle),
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  ),
                                  icon: const Icon(Icons.receipt_outlined, size: 14),
                                  label: const Text('DIGITAL INVOICE', style: TextStyle(fontSize: 10, letterSpacing: 1.0)),
                                  onPressed: () => _showInvoiceModal(context, order),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.obsidianNoir,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  ),
                                  icon: const Icon(Icons.chat_outlined, size: 14),
                                  label: const Text('CONCIERGE INQUIRY', style: TextStyle(fontSize: 10, letterSpacing: 1.0)),
                                  onPressed: () => context.go('/contact'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showInvoiceModal(BuildContext context, Map<String, dynamic> order) {
    final currencyFmt = NumberFormat('#,###');
    final items = (order['order_items'] as List?) ?? [];
    final total = (order['total'] as num?)?.toDouble() ?? 0.0;
    final orderNumber = order['order_number']?.toString() ?? 'ATELIER-ORDER';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ATELIER PRIVÉ INVOICE',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: AppTheme.primaryGoldDark),
                ),
                Text(
                  orderNumber,
                  style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => Navigator.pop(ctx)),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(height: 1),
              const SizedBox(height: 12),
              ...items.map((i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${i['quantity']}x ${i['product_title']}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12),
                          ),
                        ),
                        Text(
                          '₦${currencyFmt.format((i['unit_price'] as num? ?? 0) * (i['quantity'] as num? ?? 1))}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Paid (Paystack):', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('₦${currencyFmt.format(total)}', style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Includes complimentary VIP white-glove packaging and insured dispatch across Nigeria.',
                style: GoogleFonts.plusJakartaSans(fontSize: 10.5, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 2: WISHLIST ---
  Widget _buildWishlistTab(
    BuildContext context,
    List<Product> wishlist,
    bool isMobile,
  ) {
    final savedProducts = wishlist;

    if (savedProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border, color: AppTheme.primaryGold, size: 36),
              const SizedBox(height: 16),
              Text(
                'Your Wishlist Is Empty',
                style: GoogleFonts.cormorantGaramond(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Save your favorite handbags and sculptured shoes to revisit them any time.',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.obsidianNoir,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                onPressed: () => context.go('/shop'),
                child: const Text('BROWSE CREATIONS', style: TextStyle(fontSize: 11, letterSpacing: 1.5)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Saved Creations (${savedProducts.length})',
          style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 4,
            childAspectRatio: isMobile ? 0.58 : 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: savedProducts.length,
          itemBuilder: (context, index) {
            return ProductCard(product: savedProducts[index]);
          },
        ),
      ],
    );
  }

  // --- TAB 3: ADDRESSES ---
  Widget _buildAddressesTab(BuildContext context, Profile? profile, bool isMobile) {
    final addresses = profile?.savedAddresses ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'VIP Delivery Destination Book',
              style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.obsidianNoir,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('ADD NEW DESTINATION', style: TextStyle(fontSize: 10.5, letterSpacing: 1.2)),
              onPressed: () => _showAddAddressDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (addresses.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            color: Colors.white,
            child: Column(
              children: [
                const Icon(Icons.location_city_outlined, size: 36, color: AppTheme.textMuted),
                const SizedBox(height: 12),
                Text(
                  'No Saved Destinations',
                  style: GoogleFonts.cormorantGaramond(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add your primary Lagos, Abuja, or Port Harcourt residence for instant 1-tap checkout.',
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          )
        else
          ...addresses.map((addr) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.home_work_outlined, color: AppTheme.primaryGold, size: 24),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${addr['street'] ?? 'Residence'}, ${addr['city'] ?? ''}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${addr['state'] ?? 'Nigeria'} • Phone: ${addr['phone'] ?? ''}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
                          ),
                          if (addr['notes'] != null && addr['notes'].toString().isNotEmpty)
                            Text(
                              'Notes: ${addr['notes']}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.primaryGoldDark, fontStyle: FontStyle.italic),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
      ],
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text('Add VIP Delivery Destination', style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _addressStreetController,
                decoration: const InputDecoration(labelText: 'Street Address (e.g. 14A Admiralty Way)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressCityController,
                decoration: const InputDecoration(labelText: 'City / District (e.g. Lekki Phase 1, Ikoyi, Maitama)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressStateController,
                decoration: const InputDecoration(labelText: 'State (e.g. Lagos, Abuja FCT)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressPhoneController,
                decoration: const InputDecoration(labelText: 'Recipient Phone Number'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressNotesController,
                decoration: const InputDecoration(labelText: 'Delivery Instructions (Optional)'),
              ),
            ],
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
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: _isAddingAddress ? null : () => _handleSaveAddress(ctx),
            child: const Text('SAVE ADDRESS'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSaveAddress(BuildContext dialogContext) async {
    final auth = ref.read(authProvider);
    if (auth.user == null) return;

    final street = _addressStreetController.text.trim();
    final city = _addressCityController.text.trim();
    final state = _addressStateController.text.trim();

    if (street.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter street and city.')),
      );
      return;
    }

    setState(() => _isAddingAddress = true);
    final currentList = List<dynamic>.from(auth.profile?.savedAddresses ?? []);
    currentList.add({
      'street': street,
      'city': city,
      'state': state,
      'phone': _addressPhoneController.text.trim(),
      'notes': _addressNotesController.text.trim(),
    });

    final success = await SupabaseService.updateProfile(auth.user!.id, {
      'saved_addresses': currentList,
    });

    if (success) {
      await ref.read(authProvider.notifier).refreshProfile();
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Destination saved successfully.')),
        );
      }
    }
    setState(() => _isAddingAddress = false);
  }

  // --- TAB 4: BESPOKE & CONCIERGE ---
  Widget _buildBespokeTab(BuildContext context, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(32),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppTheme.primaryGold, size: 24),
              const SizedBox(width: 12),
              Text(
                'Atelier Bespoke & White-Glove Concierge',
                style: GoogleFonts.cormorantGaramond(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'As an Atelier Privé member, you receive dedicated access to our master leather artisans and personal styling advisors.',
            style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textMuted, height: 1.6),
          ),
          const SizedBox(height: 24),

          // Features
          _buildConciergeFeature(
            title: '1. Complimentary 24K Gold Foil Monogramming',
            desc: 'Personalize your leather clochette, luggage tag, or interior pocket with your initials hot-stamped in Italian 24k foil or blind debossed.',
          ),
          const SizedBox(height: 16),
          _buildConciergeFeature(
            title: '2. Complete the Look Styling Consultations',
            desc: 'Planning an Owambe, executive retreat, or black-tie gala? Connect directly with our lead leather curator for customized bag and footwear pairings.',
          ),
          const SizedBox(height: 16),
          _buildConciergeFeature(
            title: '3. Lifetime Stitch & Hardware Guarantee',
            desc: 'Every genuine Demo Online Bags creation includes lifetime care, edge-paint restoration, and complimentary hardware polishing.',
          ),
          const SizedBox(height: 28),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.obsidianNoir,
              foregroundColor: AppTheme.primaryGold,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              side: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
            ),
            icon: const Icon(Icons.chat, size: 18),
            label: Text(
              'CHAT DIRECTLY WITH VIP CONCIERGE',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            onPressed: () => context.go('/contact'),
          ),
        ],
      ),
    );
  }

  Widget _buildConciergeFeature({required String title, required String desc}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.obsidianNoir),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }

  // --- TAB 5: PROFILE SETTINGS ---
  Widget _buildSettingsTab(BuildContext context, AppAuthState authState, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(32),
      color: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Personal Profile & Account Details',
              style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage your verified client information and delivery communication preferences.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 24),

            if (_profileMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                color: AppTheme.successGreen.withValues(alpha: 0.1),
                child: Text(_profileMessage!, style: const TextStyle(color: AppTheme.successGreen, fontSize: 12)),
              ),
              const SizedBox(height: 16),
            ],

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number (For Courier Updates)', prefixIcon: Icon(Icons.phone_outlined)),
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              controller: TextEditingController(text: authState.user?.email ?? ''),
              decoration: const InputDecoration(labelText: 'Email Address (Account Identifier)', prefixIcon: Icon(Icons.email_outlined)),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.obsidianNoir,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: _isSavingProfile ? null : _handleSaveProfile,
              child: _isSavingProfile
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('SAVE PROFILE CHANGES', style: GoogleFonts.plusJakartaSans(fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),

            if (authState.isAdmin) ...[
              const SizedBox(height: 36),
              const Divider(),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.obsidianNoir,
                  border: Border.all(color: AppTheme.primaryGold),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings, color: AppTheme.primaryGold, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'EXECUTIVE ADMINISTRATOR CONTROLS',
                          style: GoogleFonts.plusJakartaSans(
                            color: AppTheme.primaryGold,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'You are authenticated as an Atelier Administrator. You have full privileges to edit site copy, manage products, configure pairings, and update orders.',
                      style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 11.5, height: 1.5),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      onPressed: () => context.go('/admin'),
                      child: const Text('OPEN ATELIER CMS & ADMIN PORTAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleSaveProfile() async {
    final auth = ref.read(authProvider);
    if (auth.user == null) return;

    setState(() {
      _isSavingProfile = true;
      _profileMessage = null;
    });

    final success = await SupabaseService.updateProfile(auth.user!.id, {
      'full_name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    });

    if (success) {
      await ref.read(authProvider.notifier).refreshProfile();
      setState(() {
        _profileMessage = 'Profile updated successfully!';
      });
    }

    setState(() => _isSavingProfile = false);
  }
}
