import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/shop_image.dart';
import '../common/announcement_bar.dart';
import '../common/cart_drawer.dart';
import '../common/luxury_bottom_nav.dart';
import '../common/luxury_footer.dart';
import '../common/luxury_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      bottomNavigationBar: isMobile ? const LuxuryBottomNav() : null,
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
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 72),
                  child: Column(
                    children: [
                      Text(
                        'WHY LAGOS WOMEN TRUST US',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Born from an Obsession with Form & Permanence',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cormorantGaramond(
                          color: Colors.white,
                          fontSize: isMobile ? 32 : 46,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                // Narrative Section 1
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 72, vertical: 64),
                  child: isMobile
                      ? Column(
                          children: [
                            _buildStoryText(),
                            const SizedBox(height: 36),
                            _buildStoryImage('https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1200&q=80'),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(flex: 5, child: _buildStoryText()),
                            const SizedBox(width: 64),
                            Expanded(flex: 5, child: _buildStoryImage('https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1200&q=80')),
                          ],
                        ),
                ),

                // Pillars Strip
                Container(
                  color: AppTheme.surfaceGrey,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 56),
                  child: Column(
                    children: [
                      Text(
                        'OUR THREE UNCOMPROMISING PILLARS',
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryGoldDark, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.0),
                      ),
                      const SizedBox(height: 36),
                      Wrap(
                        spacing: 32,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: const [
                          _PillarCard(
                            numeral: 'I',
                            title: 'Full-Grain Italian Hides',
                            description: 'No bonded or split leathers. We select only the highest 5% grade of calfskin and lambskin with natural grain resilience.',
                          ),
                          _PillarCard(
                            numeral: 'II',
                            title: '24K Gold-Plated Hardware',
                            description: 'Solid brass locksets, chains, and rivets electroplated with 24K gold and rhodium protective sealants against humidity.',
                          ),
                          _PillarCard(
                            numeral: 'III',
                            title: 'Harmonious Styling',
                            description: 'Our footwear and handbag designers collaborate under one roof to ensure leather tones and textures match seamlessly.',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Bottom CTA
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 64),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Text('Experience the Collection', style: GoogleFonts.cormorantGaramond(fontSize: 32, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      Text('Chat on WhatsApp, see live video, pay on delivery in Lagos & Abuja.', style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 13)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/shop'),
                        child: const Text('SHOP BESTSELLERS'),
                      ),
                    ],
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

  Widget _buildStoryText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE NARRATIVE',
          style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryGoldDark, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.0),
        ),
        const SizedBox(height: 12),
        Text(
          'Crafted to Elevate Every Room You Walk Into.',
          style: GoogleFonts.cormorantGaramond(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2),
        ),
        const SizedBox(height: 18),
        Text(
          'LUXE LAGOS was started for the Nigerian woman who runs her business by day and peppers them at Owambe by night. Fine things, no fake, no story.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.7),
        ),
        const SizedBox(height: 14),
        Text(
          'From strong office totes that carry your 14-inch laptop without bending, to hand-set crystal evening minaudières and matching party stilettos, each piece represents tens of hours of artisanal patience.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13, height: 1.6, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildStoryImage(String url) {
    return AspectRatio(
      aspectRatio: 1.15,
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: AppTheme.borderSubtle)),
        clipBehavior: Clip.antiAlias,
        child: ShopImage(url),
      ),
    );
  }
}

class _PillarCard extends StatelessWidget {
  final String numeral;
  final String title;
  final String description;

  const _PillarCard({
    required this.numeral,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(28),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(numeral, style: GoogleFonts.cormorantGaramond(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryGoldDark)),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted, height: 1.5)),
        ],
      ),
    );
  }
}
