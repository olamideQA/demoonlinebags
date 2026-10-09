import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class AuthModal extends ConsumerStatefulWidget {
  const AuthModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const AuthModal(),
    );
  }

  @override
  ConsumerState<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends ConsumerState<AuthModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In Form Controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();

  // Sign Up Form Controllers
  final _signUpNameController = TextEditingController();
  final _signUpPhoneController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();

  bool _obscureSignInPassword = true;
  bool _obscureSignUpPassword = true;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpNameController.dispose();
    _signUpPhoneController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: authState.isAuthenticated
            ? _buildLoggedInView(context, authState)
            : _buildAuthForms(context, authState),
      ),
    );
  }

  Widget _buildLoggedInView(BuildContext context, AppAuthState authState) {
    final profile = authState.profile;
    final fullName = profile?.fullName ?? authState.user?.email ?? 'Valued Client';
    final email = profile?.email ?? authState.user?.email ?? '';
    final phone = profile?.phone ?? '';
    final isAdmin = authState.isAdmin;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WELCOME BACK',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: AppTheme.primaryGoldDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your Account',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.obsidianNoir,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 24),

          // User Badge & Info
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isAdmin ? AppTheme.obsidianNoir : AppTheme.surfaceGrey,
                  border: Border.all(color: isAdmin ? AppTheme.primaryGold : AppTheme.borderSubtle),
                ),
                child: Center(
                  child: Text(
                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'C',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isAdmin ? AppTheme.primaryGold : AppTheme.obsidianNoir,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.obsidianNoir,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceGrey,
                        border: Border.all(color: AppTheme.borderSubtle),
                      ),
                      child: Text(
                        'VIP ATELIER MEMBER',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppTheme.obsidianNoir,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (phone.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: AppTheme.textMuted),
                const SizedBox(width: 8),
                Text(
                  phone,
                  style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),

          // 1. My Orders - for all shoppers
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.obsidianNoir,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            icon: const Icon(Icons.shopping_bag_outlined, size: 18, color: AppTheme.primaryGold),
            label: Text(
              'MY ORDERS & ACCOUNT',
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/account');
            },
          ),
          const SizedBox(height: 12),

          // 3. Shop Now / Concierge
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppTheme.borderSubtle),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            icon: const Icon(Icons.shopping_bag_outlined, size: 16, color: AppTheme.obsidianNoir),
            label: Text(
              'SHOP BESTSELLERS',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2, color: AppTheme.obsidianNoir),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/shop');
            },
          ),
          const SizedBox(height: 12),

          // Sign Out Button
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            icon: const Icon(Icons.logout, size: 16),
            label: Text(
              'SIGN OUT',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You have been signed out.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForms(BuildContext context, AppAuthState authState) {
    final errorMessage = _localError ?? authState.errorMessage;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JOIN LUXE LAGOS',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: AppTheme.primaryGoldDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sign In / Create Account',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.obsidianNoir,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tab Bar
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.obsidianNoir,
              unselectedLabelColor: AppTheme.textMuted,
              indicatorColor: AppTheme.primaryGold,
              indicatorWeight: 2,
              labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1.5),
              tabs: const [
                Tab(text: 'SIGN IN'),
                Tab(text: 'CREATE ACCOUNT'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Error Message
          if (errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.08),
                border: Border.all(color: AppTheme.errorRed.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, size: 16, color: AppTheme.errorRed),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.errorRed),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Tab Views
          SizedBox(
            height: 330,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSignInTab(context, authState),
                _buildSignUpTab(context, authState),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInTab(BuildContext context, AppAuthState authState) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          TextField(
            controller: _signInEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.mail_outline, size: 18),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _signInPasswordController,
            obscureText: _obscureSignInPassword,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline, size: 18),
              suffixIcon: IconButton(
                icon: Icon(_obscureSignInPassword ? Icons.visibility_off : Icons.visibility, size: 18),
                onPressed: () => setState(() => _obscureSignInPassword = !_obscureSignInPassword),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.obsidianNoir,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: authState.isLoading ? null : _handleSignIn,
            child: authState.isLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    'SIGN IN',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                  ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Fast checkout with saved details + 10% off your first order when you join.',
              style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpTab(BuildContext context, AppAuthState authState) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instant activation assurance banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.1),
              border: Border.all(color: AppTheme.successGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, size: 16, color: AppTheme.successGreen),
                const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Instant access • No long wahala • Get 10% off',
                  style: GoogleFonts.plusJakartaSans(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppTheme.successGreen),
                ),
              ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _signUpNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _signUpEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              prefixIcon: Icon(Icons.mail_outline, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _signUpPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number (For VIP Delivery Updates)',
              prefixIcon: Icon(Icons.phone_outlined, size: 18),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _signUpPasswordController,
            obscureText: _obscureSignUpPassword,
            decoration: InputDecoration(
              labelText: 'Password (Minimum 6 characters)',
              prefixIcon: const Icon(Icons.lock_outline, size: 18),
              suffixIcon: IconButton(
                icon: Icon(_obscureSignUpPassword ? Icons.visibility_off : Icons.visibility, size: 18),
                onPressed: () => setState(() => _obscureSignUpPassword = !_obscureSignUpPassword),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            onPressed: authState.isLoading ? null : _handleSignUp,
            child: authState.isLoading
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    'CREATE MY ACCOUNT',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn() async {
    setState(() => _localError = null);
    final email = _signInEmailController.text.trim();
    final password = _signInPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _localError = 'Please provide both email and password.');
      return;
    }

    final success = await ref.read(authProvider.notifier).signIn(
      email: email,
      password: password,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      final auth = ref.read(authProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${auth.profile?.fullName ?? email}! Taking you to your dashboard.'),
          backgroundColor: AppTheme.obsidianNoir,
        ),
      );
      // Clients land straight on their dashboard after signing in.
      context.go('/account');
    }
  }

  Future<void> _handleSignUp() async {
    setState(() => _localError = null);
    final name = _signUpNameController.text.trim();
    final email = _signUpEmailController.text.trim();
    final phone = _signUpPhoneController.text.trim();
    final password = _signUpPasswordController.text.trim();

    if (name.isEmpty) {
      setState(() => _localError = 'Please enter your full name.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _localError = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _localError = 'Password must be at least 6 characters.');
      return;
    }

    final success = await ref.read(authProvider.notifier).signUp(
      fullName: name,
      email: email,
      phone: phone,
      password: password,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome to LUXE LAGOS, $name! Taking you to your dashboard.'),
          backgroundColor: AppTheme.obsidianNoir,
        ),
      );
      // New clients land straight on their dashboard after creating account.
      context.go('/account');
    }
  }
}
