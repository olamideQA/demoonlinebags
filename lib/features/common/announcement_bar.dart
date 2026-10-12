import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/site_settings_provider.dart';
import '../../core/theme/app_theme.dart';

/// TV news-style ticker: announcement scrolls right-to-left forever.
/// Speed is calm and readable on phone + desktop. Respects CMS on/off.
class AnnouncementBar extends ConsumerStatefulWidget {
  const AnnouncementBar({super.key});

  @override
  ConsumerState<AnnouncementBar> createState() => _AnnouncementBarState();
}

class _AnnouncementBarState extends ConsumerState<AnnouncementBar> {
  final ScrollController _ctrl = ScrollController();
  Timer? _timer;
  bool _scrolling = false;

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _startTicker() {
    if (_scrolling) return;
    _scrolling = true;
    // Wait for first layout so maxScrollExtent exists.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loop());
  }

  Future<void> _loop() async {
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted || !_ctrl.hasClients) continue;
      final max = _ctrl.position.maxScrollExtent;
      if (max <= 0) continue;
      // Pixels per second ~60: calm TV pace on all screens.
      final seconds = (max / 60).clamp(8, 30).toInt();
      try {
        await _ctrl.animateTo(
          max,
          duration: Duration(seconds: seconds),
          curve: Curves.linear,
        );
      } catch (_) {
        continue;
      }
      if (!mounted || !_ctrl.hasClients) continue;
      _ctrl.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(siteSettingsProvider).announcement;

    if (!settings.isActive || settings.text.trim().isEmpty) {
      _timer?.cancel();
      return const SizedBox.shrink();
    }
    _startTicker();

    final style = GoogleFonts.plusJakartaSans(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.2,
    );

    Widget chunk() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, color: AppTheme.primaryGold, size: 14),
          const SizedBox(width: 8),
          Text(settings.text, style: style),
          const SizedBox(width: 8),
          const Icon(Icons.stars, color: AppTheme.primaryGold, size: 14),
          const SizedBox(width: 32),
        ],
      );
    }

    return Container(
      width: double.infinity,
      color: AppTheme.obsidianNoir,
      padding: const EdgeInsets.symmetric(vertical: 8),
      // No touch scroll: it moves on its own like TV.
      child: SingleChildScrollView(
        controller: _ctrl,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [chunk(), chunk(), chunk(), chunk()],
        ),
      ),
    );
  }
}
