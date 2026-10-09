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
  String _inquiryType = 'Help me choose size / style';

  final List<String> _types = [
    'Help me choose size / style',
    'I want another colour',
    'Where is my order?',
    'Wedding / Aso-ebi / Bulk order',
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
        content: Text('Thank you! We have received your message. We will WhatsApp or call you within 2 hours.'),
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
                        'TALK TO US — WE REPLY FAST',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Chat With Us on WhatsApp',
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
                          'Not sure of your size? Want to see the bag on live video before you pay? Message us — we help with size, colour, matching bag + shoe, and delivery.',
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
          'CALL OR WHATSAPP US DIRECTLY',
          style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2.0, color: AppTheme.primaryGoldDark),
        ),
        const SizedBox(height: 16),
        _contactItem(Icons.chat, 'WhatsApp (Fastest)', '+234 906 791 4511', () {
          launchUrl(Uri.parse('https://wa.me/2349067914511?text=Hello%20LUXE%20LAGOS%2C%20I%20need%20help%20with%20a%20bag'), mode: LaunchMode.externalApplication);
        }),
        const SizedBox(height: 16),
        _contactItem(Icons.email_outlined, 'Email Us', AppConfig.conciergeEmail, () {
          launchUrl(Uri.parse('mailto:${AppConfig.conciergeEmail}'));
        }),
        const SizedBox(height: 16),
        _contactItem(Icons.location_on_outlined, 'Visit Our Store', '12 Admiralty Way, Lekki Phase 1, Lagos', null),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          color: AppTheme.surfaceGrey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WE ARE OPEN', style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              Text('Mon - Sat: 8am - 9pm (Lagos time)', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
              Text('Sunday: 12pm - 6pm (Lagos time)', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
              Text('We reply on WhatsApp within 30 mins.', style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted)),
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
            'SEND US A MESSAGE',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5, color: AppTheme.obsidianNoir),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            initialValue: _inquiryType,
            decoration: const InputDecoration(labelText: 'What do you need? *'),
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
            decoration: const InputDecoration(labelText: 'Your Email or WhatsApp Number *'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _msgController,
            decoration: const InputDecoration(labelText: 'Your Message * (e.g. I wear size 40, will this heel fit?)'),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              child: const Text('SEND MESSAGE'),
            ),
          ),
        ],
      ),
    );
  }
}
