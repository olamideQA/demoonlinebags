import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/site_settings_provider.dart';
import '../../core/theme/app_theme.dart';

class LuxuryFooter extends ConsumerWidget {
  const LuxuryFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siteSettings = ref.watch(siteSettingsProvider);
    final isAdmin = ref.watch(authProvider).isAdmin;
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
                title: '100% REAL LEATHER',
                subtitle: 'No fake, no peeling. If it peels, we refund you.',
              ),
              _TrustItem(
                icon: Icons.local_shipping_outlined,
                title: 'FAST DELIVERY + PAY ON DELIVERY',
                subtitle: 'Same-day in Lagos • 24–48hrs to Abuja, PH & everywhere',
              ),
              _TrustItem(
                icon: Icons.shield_outlined,
                title: 'GOLD THAT WILL NOT FADE',
                subtitle: 'Rain and sun will not change the colour. 7-day easy return.',
              ),
              _TrustItem(
                icon: Icons.chat_outlined,
                title: 'CHAT ON WHATSAPP ANYTIME',
                subtitle: 'See your bag on live video before you pay. We reply fast.',
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
                _buildBrandBio(context, siteSettings),
                const SizedBox(height: 32),
                _buildLinksGroup(context, 'SHOP', [
                  'Tote Bags',
                  'Crossbody Bags',
                  'Party Clutches',
                  'Comfy Heels',
                  'Matching Bag + Shoe Sets',
                ]),
                const SizedBox(height: 24),
                _buildConciergeGroup(context, siteSettings),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildBrandBio(context, siteSettings)),
                const SizedBox(width: 48),
                Expanded(
                  flex: 2,
                  child: _buildLinksGroup(context, 'SHOP', [
                    'Tote Bags',
                    'Crossbody Bags',
                    'Party Clutches',
                    'Comfy Heels',
                    'Matching Bag + Shoe Sets',
                  ]),
                ),
                Expanded(
                  flex: 3,
                  child: _buildConciergeGroup(context, siteSettings),
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
                siteSettings.footer.copyright,
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              Wrap(
                spacing: 20,
                runSpacing: 8,
                children: [
                  InkWell(
                    onTap: () => context.go('/account'),
                    child: Text(
                      'MY ACCOUNT',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  // Owner-only. Never visible to shoppers.
                  if (isAdmin)
                    InkWell(
                      onTap: () => context.go('/admin'),
                      child: Text(
                        'MANAGE STORE',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primaryGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                ],
              ),
              Text(
                'LEKKI  •  VICTORIA ISLAND  •  ABUJA  •  NATIONWIDE',
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

  Widget _buildBrandBio(BuildContext context, siteSettings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          siteSettings.header.brandName,
          style: GoogleFonts.cormorantGaramond(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          siteSettings.footer.bio,
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.textMuted,
            fontSize: 12,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildConciergeGroup(BuildContext context, siteSettings) {
    final footer = siteSettings.footer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TALK TO US',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.primaryGold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        _contactRow(Icons.mail_outline, footer.email),
        const SizedBox(height: 8),
        _contactRow(Icons.phone_outlined, footer.phone),
        const SizedBox(height: 8),
        _contactRow(Icons.chat_bubble_outline, 'WhatsApp: ${footer.whatsapp}'),
        const SizedBox(height: 8),
        _contactRow(Icons.location_on_outlined, footer.address),
      ],
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.primaryGold),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 12,
            ),
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
          'GET 10% OFF YOUR FIRST ORDER',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.primaryGold,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Join 5,000+ Lagos women. First access to new Owambe sets + WhatsApp deals.',
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
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Enter your email address...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: AppTheme.borderStrong),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: AppTheme.borderStrong),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Welcome! Your 10% code is on its way to your email & WhatsApp.')),
                );
              },
              child: const Text('GET 10% OFF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
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
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 26),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
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
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
