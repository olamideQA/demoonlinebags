import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/fast_image.dart';
import '../../core/utils/shop_image.dart';

class CartDrawer extends ConsumerStatefulWidget {
  const CartDrawer({super.key});

  @override
  ConsumerState<CartDrawer> createState() => _CartDrawerState();
}

class _CartDrawerState extends ConsumerState<CartDrawer> {
  final _promoController = TextEditingController();
  String? _promoMessage;
  bool _promoSuccess = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final formatter = NumberFormat('#,###');

    if (!cartState.isDrawerOpen) return const SizedBox.shrink();

    return Stack(
      children: [
        // Dark backdrop
        Positioned.fill(
          child: GestureDetector(
            onTap: () => cartNotifier.toggleDrawer(false),
            child: Container(color: Colors.black.withValues(alpha: 0.5)),
          ),
        ),

        // Slide-out Drawer Panel (Right aligned)
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: MediaQuery.of(context).size.width > 500 ? 460 : MediaQuery.of(context).size.width,
          child: Material(
            color: Colors.white,
            elevation: 16,
            child: SafeArea(
              child: Column(
                children: [
                  // Drawer Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'YOUR BAG',
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${cartState.totalItemCount})',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => cartNotifier.toggleDrawer(false),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Free Shipping Progress Meter
                  Container(
                    color: AppTheme.surfaceGrey,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              cartState.qualifiesForFreeShipping ? Icons.check_circle : Icons.local_shipping_outlined,
                              size: 16,
                              color: cartState.qualifiesForFreeShipping ? AppTheme.successGreen : AppTheme.obsidianNoir,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cartState.qualifiesForFreeShipping
                                    ? 'You don unlock FREE delivery in Lagos!'
                                    : 'Add ₦${formatter.format(cartState.amountNeededForFreeShipping)} more to get FREE delivery',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.obsidianNoir,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.zero,
                          child: LinearProgressIndicator(
                            value: cartState.freeShippingProgress,
                            backgroundColor: Colors.white,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGold),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cart Items List
                  Expanded(
                    child: cartState.items.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.separated(
                            padding: const EdgeInsets.all(24),
                            itemCount: cartState.items.length,
                            separatorBuilder: (ctx, i) => const Divider(height: 32),
                            itemBuilder: (ctx, index) {
                              final item = cartState.items[index];
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image Thumbnail
                                  Container(
                                    width: 76,
                                    height: 94,
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceGrey,
                                      border: Border.all(color: AppTheme.borderSubtle),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: ShopImage(fastImg(item.product.primaryImage, w: 200, q: 60)),
                                  ),
                                  const SizedBox(width: 16),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.title,
                                          style: GoogleFonts.cormorantGaramond(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        if (item.selectedColor != null)
                                          Text(
                                            'Color: ${item.selectedColor}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        if (item.selectedSize != null)
                                          Text(
                                            'Size: ${item.selectedSize}',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 11,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Text(
                                          item.formattedUnitPrice,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 12),

                                        // Stepper & Remove
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: AppTheme.borderSubtle),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  InkWell(
                                                    onTap: () => cartNotifier.updateQuantity(item.id, item.quantity - 1),
                                                    child: const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      child: Icon(Icons.remove, size: 14),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    child: Text(
                                                      '${item.quantity}',
                                                      style: GoogleFonts.plusJakartaSans(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () => cartNotifier.updateQuantity(item.id, item.quantity + 1),
                                                    child: const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                      child: Icon(Icons.add, size: 14),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.textMuted),
                                              onPressed: () => cartNotifier.removeFromCart(item.id),
                                              tooltip: 'Remove',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),

                  // Bottom Summary & Checkout (Only if cart not empty)
                  if (cartState.items.isNotEmpty) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Promo Code Input
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 42,
                                  child: TextField(
                                    controller: _promoController,
                                    decoration: InputDecoration(
                                      hintText: 'PROMO CODE (e.g. LUXE10)',
                                      hintStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    textCapitalization: TextCapitalization.characters,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 42,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  onPressed: () async {
                                    final code = _promoController.text;
                                    setState(() {
                                      _promoMessage = 'Checking code...';
                                      _promoSuccess = false;
                                    });
                                    final percent = await cartNotifier.applyPromoCodeAsync(code);
                                    if (!mounted) return;
                                    setState(() {
                                      _promoSuccess = percent > 0;
                                      _promoMessage = percent > 0
                                          ? 'Promo applied! You save $percent%.'
                                          : 'Hmm, that code no work. Try LUXE10';
                                    });
                                  },
                                  child: const Text('APPLY'),
                                ),
                              ),
                            ],
                          ),
                          if (_promoMessage != null) ...[
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _promoMessage!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11,
                                  color: _promoSuccess ? AppTheme.successGreen : AppTheme.errorRed,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),

                          // Calculation Rows
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Subtotal', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textMuted)),
                              Text('₦${formatter.format(cartState.subtotal)}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          if (cartState.discountAmount > 0) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Discount (${cartState.discountPercent.toInt()}%)', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.successGreen)),
                                Text('-₦${formatter.format(cartState.discountAmount)}', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.successGreen, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Shipping', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textMuted)),
                              Text(
                                cartState.qualifiesForFreeShipping ? 'FREE' : '₦${formatter.format(cartState.shippingFee)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: cartState.qualifiesForFreeShipping ? AppTheme.successGreen : AppTheme.obsidianNoir,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TOTAL',
                                style: GoogleFonts.cormorantGaramond(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              Text(
                                '₦${formatter.format(cartState.total)}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.obsidianNoir,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Checkout CTA
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                cartNotifier.toggleDrawer(false);
                                context.go('/checkout');
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                backgroundColor: AppTheme.obsidianNoir,
                              ),
                              child: Text(
                                'CHECKOUT — PAY ON DELIVERY AVAILABLE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 54, color: AppTheme.primaryGold),
            const SizedBox(height: 16),
            Text(
              'Your Bag is Empty',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fine bags and comfy shoes dey wait for you. Start with our bestsellers.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                ref.read(cartProvider.notifier).toggleDrawer(false);
                context.go('/shop');
              },
              child: const Text('SHOP BESTSELLERS'),
            ),
          ],
        ),
      ),
    );
  }
}
