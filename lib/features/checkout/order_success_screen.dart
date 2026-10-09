import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../common/announcement_bar.dart';
import '../common/luxury_footer.dart';
import '../common/luxury_header.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderNumber;

  const OrderSuccessScreen({super.key, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AnnouncementBar(),
            const LuxuryHeader(),

            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 64,
                vertical: 72,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryGold, width: 2),
                          color: AppTheme.surfaceGrey,
                        ),
                        child: const Icon(Icons.check, color: AppTheme.primaryGoldDark, size: 40),
                      ),
                      const SizedBox(height: 28),

                      Text(
                        'ORDER CONFIRMED',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primaryGoldDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Thank You for Your Order',
                        style: GoogleFonts.cormorantGaramond(
                          fontSize: isMobile ? 32 : 44,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      Text(
                        'Your order #$orderNumber has been placed successfully with our atelier. A confirmation receipt and live courier tracking code have been dispatched to your email and phone.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Order Details Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceGrey,
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Order Reference:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
                                Text(orderNumber, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Estimated Dispatch:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
                                Text('Within 24 Hours', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.successGreen)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Delivery Service:', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
                                Text('White-Glove VIP Courier', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => context.go('/shop'),
                          child: const Text('CONTINUE EXPLORING CREATIONS'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const LuxuryFooter(),
          ],
        ),
      ),
    );
  }
}
