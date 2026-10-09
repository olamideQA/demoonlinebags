import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/app_config.dart';
import '../../core/theme/app_theme.dart';
import '../common/announcement_bar.dart';
import '../common/cart_drawer.dart';
import '../common/luxury_bottom_nav.dart';
import '../common/luxury_footer.dart';
import '../common/luxury_header.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _msgController = TextEditingController();
  String _inquiryType = 'Bespoke Sizing & Styling';

  final List<String> _types = [
    'Bespoke Sizing & Styling',
    'Custom Colorway / Leather Request',
    'Order Status & Tracking',
    'Corporate & Bridal Gifting',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _msgController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_nameController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide your name and email address.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your inquiry has been received. Our VIP stylist will reach out within 2 hours.'),
        backgroundColor: AppTheme.obsidianNoir,
      ),
    );
    _nameController.clear();
    _emailController.clear();
    _msgController.clear();
  }

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
                  color: AppTheme.surfaceDark,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 56),
                  child: Column(
                    children: [
                      Text(
                        'VIP CLIENT SERVICES',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'The Concierge Salon',
                        style: GoogleFonts.cormorantGaramond(
                          color: Colors.white,
                          fontSize: isMobile ? 32 : 44,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 580),
                        child: Text(
                          'Our dedicated styling advisors are available to assist you with sizing recommendations, leather care questions, or matching ensemble guidance.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(color: AppTheme.textMuted, fontSize: 13, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Contact Content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 72, vertical: 56),
                  child: isMobile
                      ? Column(
                          children: [
                            _buildConciergeInfo(),
                            const SizedBox(height: 48),
                            _buildInquiryForm(),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 4, child: _buildConciergeInfo()),
                            const SizedBox(width: 64),
                            Expanded(flex: 6, child: _buildInquiryForm()),
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

  Widget _buildConciergeInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DIRECT CONCIERGE ACCESS',
          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: AppTheme.primaryGoldDark),
        ),
        const SizedBox(height: 16),
        _contactItem(Icons.chat, 'WhatsApp VIP Concierge', '+234 810 000 BAGS', () {
          launchUrl(Uri.parse('https://wa.me/2348100000000'));
        }),
        const SizedBox(height: 16),
        _contactItem(Icons.email_outlined, 'Private Client Email', AppConfig.conciergeEmail, () {
          launchUrl(Uri.parse('mailto:${AppConfig.conciergeEmail}'));
        }),
        const SizedBox(height: 16),
        _contactItem(Icons.location_on_outlined, 'Private Atelier Showroom', 'Victoria Island, Lagos, Nigeria', null),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          color: AppTheme.surfaceGrey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CONCIERGE HOURS', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text('Monday - Saturday: 8:00 AM - 9:00 PM WAT', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
              Text('Sunday: 12:00 PM - 6:00 PM WAT', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contactItem(IconData icon, String title, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGoldDark, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryForm() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SEND A MESSAGE TO OUR STYLISTS',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppTheme.obsidianNoir),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _inquiryType,
            decoration: const InputDecoration(labelText: 'Nature of Inquiry *'),
            items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _inquiryType = val);
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Your Full Name *'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Your Email Address *'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _msgController,
            decoration: const InputDecoration(labelText: 'Message / Sizing Inquiries *'),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text('TRANSMIT INQUIRY'),
            ),
          ),
        ],
      ),
    );
  }
}
