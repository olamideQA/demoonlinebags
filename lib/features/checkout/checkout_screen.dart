import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_theme.dart';
import '../common/announcement_bar.dart';
import '../common/luxury_footer.dart';
import '../common/luxury_header.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(text: '+234 ');
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedState = 'Lagos State';
  String _paymentMethod = 'transfer'; // 'transfer', 'card', 'cash_on_delivery'
  bool _isSubmitting = false;

  final List<String> _states = [
    'Lagos State',
    'Abuja FCT',
    'Rivers State (Port Harcourt)',
    'Oyo State (Ibadan)',
    'Delta State',
    'Edo State',
    'Enugu State',
    'Kano State',
    'Ogun State',
    'Anambra State',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cartState = ref.read(cartProvider);
    if (cartState.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your shopping bag is empty.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final orderNumber = await SupabaseService.submitOrder(
        customerName: _nameController.text.trim(),
        customerEmail: _emailController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        shippingAddress: {
          'country': 'Nigeria',
          'state': _selectedState,
          'city': _cityController.text.trim(),
          'street': _addressController.text.trim(),
          'notes': _notesController.text.trim(),
        },
        subtotal: cartState.subtotal,
        shippingFee: cartState.shippingFee,
        discount: cartState.discountAmount,
        total: cartState.total,
        paymentMethod: _paymentMethod,
        items: cartState.items,
      );

      // Clear Cart
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        context.go('/order-success/$orderNumber');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order submission error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final isMobile = MediaQuery.of(context).size.width < 900;
    final formatter = NumberFormat('#,###');

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AnnouncementBar(),
            const LuxuryHeader(),

            // Checkout Header
            Container(
              color: AppTheme.surfaceDark,
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 36),
              child: Column(
                children: [
                  Text(
                    'SAFE & SECURE • PAY ON DELIVERY AVAILABLE',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.primaryGold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Where Should We Deliver?',
                    style: GoogleFonts.cormorantGaramond(
                      color: Colors.white,
                      fontSize: isMobile ? 26 : 34,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Form + Order Summary
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 64, vertical: 48),
              child: isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOrderSummaryCard(cartState, formatter),
                        const SizedBox(height: 36),
                        _buildCheckoutForm(),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 6, child: _buildCheckoutForm()),
                        const SizedBox(width: 48),
                        Expanded(flex: 4, child: _buildOrderSummaryCard(cartState, formatter)),
                      ],
                    ),
            ),

            const LuxuryFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1. YOUR NAME & WHATSAPP',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppTheme.obsidianNoir,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name * (e.g. Adaeze Okafor)'),
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your full name' : null,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email Address *'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || !val.contains('@') ? 'Valid email required' : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'WhatsApp Number *'),
                  keyboardType: TextInputType.phone,
                  validator: (val) => val == null || val.trim().length < 8 ? 'Valid phone required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Text(
            '2. WHERE DO WE DELIVER?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppTheme.obsidianNoir,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedState,
            decoration: const InputDecoration(labelText: 'State *'),
            items: _states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedState = val);
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'Area * (e.g. Lekki Phase 1, Maitama, GRA PH)'),
            validator: (val) => val == null || val.trim().isEmpty ? 'Area is required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(labelText: 'Street + House No. *'),
            validator: (val) => val == null || val.trim().isEmpty ? 'Address is required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Landmark / Bus-stop (Optional — e.g. opposite Shoprite)'),
          ),
          const SizedBox(height: 32),

          Text(
            '3. HOW DO YOU WANT TO PAY?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppTheme.obsidianNoir,
            ),
          ),
          const SizedBox(height: 16),
          _paymentOptionTile(
            value: 'transfer',
            title: 'Bank Transfer / USSD (Fastest)',
            subtitle: 'We send account details immediately. No extra charges.',
            icon: Icons.account_balance,
          ),
          const SizedBox(height: 10),
          _paymentOptionTile(
            value: 'card',
            title: 'Card — Visa, Mastercard, Verve',
            subtitle: 'Safe payment via Paystack. Your money is protected.',
            icon: Icons.credit_card,
          ),
          const SizedBox(height: 10),
          _paymentOptionTile(
            value: 'cash_on_delivery',
            title: 'Pay When It Arrives (Lagos & Abuja)',
            subtitle: 'See your bag first, then pay. No wahala.',
            icon: Icons.local_shipping,
          ),
          const SizedBox(height: 36),

          // Submit Order Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _handlePlaceOrder,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'CONFIRM ORDER — WE WILL WHATSAPP YOU',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOptionTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceGrey : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.obsidianNoir : AppTheme.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primaryGoldDark : AppTheme.textMuted,
              size: 20,
            ),
            const SizedBox(width: 14),
            Icon(icon, color: AppTheme.obsidianNoir, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(CartState cart, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR ORDER (${cart.totalItemCount} ITEMS)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppTheme.obsidianNoir,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Mini items list
          ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cormorantGaramond(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          if (item.selectedColor != null || item.selectedSize != null)
                            Text(
                              '${item.selectedColor ?? ""} ${item.selectedSize != null ? "• ${item.selectedSize!}" : ""}',
                              style: GoogleFonts.plusJakartaSans(fontSize: 10, color: AppTheme.textMuted),
                            ),
                          Text(
                            'Qty: ${item.quantity}',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.formattedTotalPrice,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),

          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textMuted)),
              Text('₦${formatter.format(cart.subtotal)}', style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          if (cart.discountAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('VIP Discount (${cart.discountPercent.toInt()}%)', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.successGreen)),
                Text('-₦${formatter.format(cart.discountAmount)}', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.successGreen, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Delivery Fee', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: AppTheme.textMuted)),
              Text(
                cart.qualifiesForFreeShipping ? 'FREE' : '₦${formatter.format(cart.shippingFee)}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: cart.qualifiesForFreeShipping ? AppTheme.successGreen : AppTheme.obsidianNoir,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: GoogleFonts.cormorantGaramond(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₦${formatter.format(cart.total)}',
                style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.obsidianNoir),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
