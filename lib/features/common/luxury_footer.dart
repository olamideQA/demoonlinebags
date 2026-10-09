import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class LuxuryFooter extends StatelessWidget {
  const LuxuryFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
      color: AppTheme.obsidianNoir,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trust Badges Strip
          Wrap(
            spacing: 32,
            runSpacing: 24,
            alignment: WrapAlignment.spaceBetween,
            children: const [
              _TrustItem(
                icon: Icons.verified_outlined,
                title: '100% FULL-GRAIN LEATHER',
                subtitle: 'Authentic artisan materials sourced from Italy',
              ),
              _TrustItem(
                icon: Icons.local_shipping_outlined,
                title: 'INSURED NATIONWIDE DELIVERY',
                subtitle: 'White-glove courier across Nigeria & globally',
              ),
              _TrustItem(
                icon: Icons.lock_outline,
                title: 'SECURE ENCRYPTED CHECKOUT',
                subtitle: 'Guaranteed privacy & encrypted payment processing',
              ),
              _TrustItem(
                icon: Icons.support_agent_outlined,
                title: 'VIP CONCIERGE ASSISTANCE',
                subtitle: 'Dedicated styling and sizing consultants',
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Divider(color: AppTheme.borderStrong),
          const SizedBox(height: 48),

          // Main Footer Grid
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBrandBio(context),
                const SizedBox(height: 32),
                _buildLinksGroup(context, 'COLLECTIONS', [
                  'Tote Bags',
                  'Crossbody Bags',
                  'Evening Clutches',
                  'Sculpted Footwear',
                  'Complete The Look',
                ]),
                const SizedBox(height: 24),
                _buildLinksGroup(context, 'CLIENT CARE', [
                  'VIP Concierge Support',
                  'Size & Fit Guide',
                  'Shipping & Delivery Terms',
                  'Care & Maintenance',
                ]),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildBrandBio(context)),
                const SizedBox(width: 48),
                Expanded(
                  flex: 2,
                  child: _buildLinksGroup(context, 'CREATIONS', [
                    'Tote Bags',
                    'Crossbody Bags',
                    'Evening Clutches',
                    'Luxury Heels',
                    'Complete The Look',
                  ]),
                ),
                Expanded(
                  flex: 2,
                  child: _buildLinksGroup(context, 'CLIENT SERVICES', [
                    'VIP Concierge Support',
                    'Shoe Sizing Guide',
                    'Insured Delivery Details',
                    'Leather Care Ritual',
                  ]),
                ),
                Expanded(
                  flex: 3,
                  child: _buildNewsletterBox(context),
                ),
              ],
            ),

          const SizedBox(height: 48),
          const Divider(color: AppTheme.borderStrong),
          const SizedBox(height: 24),

          // Bottom Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '© 2026 DEMO ONLINE BAGS ATELIER. ALL RIGHTS RESERVED.',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'LAGOS  •  LONDON  •  MILAN',
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.primaryGold,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrandBio(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DEMO ONLINE BAGS',
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Curators of modern luxury handbags, structured totes, and complementary sculpted footwear. Each silhouette is engineered with exacting standards to stand the test of time.',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.textMuted,
            fontSize: 12,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildLinksGroup(BuildContext context, String header, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.primaryGold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => context.go('/shop'),
                child: Text(
                  link,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildNewsletterBox(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THE PRIVATE CAPSULE',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.primaryGold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Subscribe to receive private preview access to limited edition drops, runway releases, and VIP styling.',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.textMuted,
            fontSize: 12,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderStrong),
                  color: AppTheme.surfaceDark,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.centerLeft,
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: const InputDecoration(
                    hintText: 'Enter your email address',
                    hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            Container(
              height: 44,
              color: AppTheme.primaryGold,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Thank you for subscribing to private capsule access.')),
                  );
                },
                child: Text(
                  'JOIN',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.obsidianNoir,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primaryGold, size: 28),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
