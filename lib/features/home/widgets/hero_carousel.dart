import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/site_settings.dart';
import '../../../core/providers/products_provider.dart';
import '../../../core/theme/app_theme.dart';

class HeroCarousel extends ConsumerStatefulWidget {
  final HeroSettings heroSettings;
  final bool isMobile;

  const HeroCarousel({
    super.key,
    required this.heroSettings,
    required this.isMobile,
  });

  @override
  ConsumerState<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends ConsumerState<HeroCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoTimer;
  bool _isPaused = false;

  List<HeroSlide> get _slides =>
      widget.heroSettings.slides.isNotEmpty
          ? widget.heroSettings.slides
          : HeroSlide.defaultSlides;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoTimer?.cancel();
    _autoTimer = Timer.periodic(const Duration(milliseconds: 5500), (timer) {
      if (!mounted || _isPaused || _slides.length <= 1) return;
      final nextIndex = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _goToSlide(int index) {
    if (index >= 0 && index < _slides.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = _slides;
    final isMobile = widget.isMobile;
    final screenHeight = MediaQuery.of(context).size.height;
    // Responsive height that leaves comfortable space on mobile and tablet
    final heroHeight = isMobile
        ? (screenHeight * 0.65).clamp(460.0, 560.0)
        : 660.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _isPaused = true),
      onExit: (_) => setState(() => _isPaused = false),
      child: SizedBox(
        height: heroHeight,
        width: double.infinity,
        child: Stack(
          children: [
            // PageView Slider
            PageView.builder(
              controller: _pageController,
              itemCount: slides.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (idx) {
                setState(() => _currentPage = idx);
              },
              itemBuilder: (ctx, index) {
                final slide = slides[index];
                return _buildSlideItem(context, slide, isMobile);
              },
            ),

            // Left Navigation Chevron Arrow
            Positioned(
              left: isMobile ? 8 : 24,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavigationArrow(
                  icon: Icons.chevron_left_rounded,
                  isMobile: isMobile,
                  onTap: () {
                    final prevIndex = (_currentPage - 1 + slides.length) % slides.length;
                    _goToSlide(prevIndex);
                  },
                ),
              ),
            ),

            // Right Navigation Chevron Arrow
            Positioned(
              right: isMobile ? 8 : 24,
              top: 0,
              bottom: 0,
              child: Center(
                child: _NavigationArrow(
                  icon: Icons.chevron_right_rounded,
                  isMobile: isMobile,
                  onTap: () {
                    final nextIndex = (_currentPage + 1) % slides.length;
                    _goToSlide(nextIndex);
                  },
                ),
              ),
            ),

            // Bottom Indicators & Slide Counter
            Positioned(
              bottom: isMobile ? 12 : 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(slides.length, (i) {
                    final isActive = i == _currentPage;
                    return GestureDetector(
                      onTap: () => _goToSlide(i),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? (isMobile ? 24 : 32) : 8,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primaryGold
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 12),
                  // Subtle slide counter
                  Text(
                    '${_currentPage + 1} / ${slides.length}',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlideItem(BuildContext context, HeroSlide slide, bool isMobile) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image with CachedNetworkImage
        CachedNetworkImage(
          imageUrl: slide.imageUrl,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 400),
          placeholder: (ctx, url) => Container(
            color: AppTheme.obsidianNoir,
            child: const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGold),
              ),
            ),
          ),
          errorWidget: (ctx, url, err) => Container(
            color: AppTheme.obsidianNoir,
            child: const Center(
              child: Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryGold, size: 48),
            ),
          ),
        ),

        // Gradient Overlay: light at top to showcase product, dark at bottom for crisp text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.45, 1.0],
              colors: [
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.45),
                Colors.black.withValues(alpha: 0.88),
              ],
            ),
          ),
        ),

        // Editorial Content Block
        Positioned(
          left: isMobile ? 20 : 64,
          right: isMobile ? 20 : 64,
          bottom: isMobile ? 40 : 64,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gold Badge Pill
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8 : 12,
                  vertical: isMobile ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  slide.badge,
                  style: GoogleFonts.plusJakartaSans(
                    color: AppTheme.obsidianNoir,
                    fontSize: isMobile ? 8.5 : 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: isMobile ? 1.5 : 2.2,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 10 : 16),

              // Title (Refined, Not Verbose)
              Text(
                slide.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cormorantGaramond(
                  color: Colors.white,
                  fontSize: isMobile ? 28 : 50,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  height: 1.1,
                ),
              ),
              SizedBox(height: isMobile ? 8 : 14),

              // Concise Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Text(
                  slide.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: isMobile ? 12 : 14.5,
                    height: 1.45,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),

              // Responsive CTA Buttons (Compact so they NEVER clip on mobile)
              Wrap(
                spacing: isMobile ? 10 : 16,
                runSpacing: isMobile ? 8 : 12,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.obsidianNoir,
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 18 : 32,
                        vertical: isMobile ? 11 : 16,
                      ),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: isMobile ? 10.5 : 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                      elevation: 2,
                    ),
                    onPressed: () {
                      if (slide.ctaUrl.contains('category') || slide.ctaUrl == '/shop') {
                        if (slide.ctaText.toLowerCase().contains('shoe') ||
                            slide.ctaText.toLowerCase().contains('heel') ||
                            slide.ctaText.toLowerCase().contains('mule')) {
                          ref.read(selectedProductTypeProvider.notifier).state = 'shoe';
                        } else {
                          ref.read(selectedProductTypeProvider.notifier).state = 'bag';
                        }
                      }
                      context.go(slide.ctaUrl);
                    },
                    child: Text(slide.ctaText),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 1.4),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 18 : 32,
                        vertical: isMobile ? 11 : 16,
                      ),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: isMobile ? 10.5 : 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    onPressed: () => context.go(slide.secondaryCtaUrl),
                    child: Text(slide.secondaryCtaText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavigationArrow extends StatelessWidget {
  final IconData icon;
  final bool isMobile;
  final VoidCallback onTap;

  const _NavigationArrow({
    required this.icon,
    required this.isMobile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: isMobile ? 32 : 44,
          height: isMobile ? 32 : 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.35),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: isMobile ? 18 : 24,
          ),
        ),
      ),
    );
  }
}
