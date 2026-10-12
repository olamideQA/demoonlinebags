import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';
import 'shop_image.dart';

bool isVideoPath(String? url) {
  if (url == null || url.trim().isEmpty) return false;
  final clean = url.split('?').first.toLowerCase();
  return clean.endsWith('.mp4') ||
      clean.endsWith('.webm') ||
      clean.endsWith('.mov') ||
      clean.endsWith('.m4v');
}

/// Luxury video player widget supporting both bundled assets (`assets/videos/...`)
/// and remote URLs (`https://...`). Starts muted and looping so browsers allow
/// instant autoplay, with sleek controls for sound and playback.
class ShopVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String? posterUrl;
  final bool autoPlay;
  final bool showControls;
  final bool compactControls;
  final BoxFit fit;

  const ShopVideoPlayer({
    super.key,
    required this.videoUrl,
    this.posterUrl,
    this.autoPlay = true,
    this.showControls = true,
    this.compactControls = false,
    this.fit = BoxFit.cover,
  });

  @override
  State<ShopVideoPlayer> createState() => _ShopVideoPlayerState();
}

class _ShopVideoPlayerState extends State<ShopVideoPlayer> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant ShopVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _initController();
    }
  }

  Future<void> _initController() async {
    final url = widget.videoUrl.trim();
    if (url.isEmpty) {
      if (mounted) setState(() => _hasError = true);
      return;
    }

    try {
      final options = VideoPlayerOptions(mixWithOthers: true);
      final VideoPlayerController ctrl = url.startsWith('assets/')
          ? VideoPlayerController.asset(url, videoPlayerOptions: options)
          : VideoPlayerController.networkUrl(Uri.parse(url), videoPlayerOptions: options);

      _controller = ctrl;
      await ctrl.initialize();
      await ctrl.setLooping(true);
      await ctrl.setVolume(0.0);
      if (widget.autoPlay) {
        await ctrl.play();
      }
      if (mounted) {
        setState(() {
          _initialized = true;
          _hasError = false;
          _isMuted = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _initialized = false;
        });
      }
    }
  }

  void _disposeController() {
    final ctrl = _controller;
    _controller = null;
    _initialized = false;
    ctrl?.dispose();
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _togglePlay() {
    final ctrl = _controller;
    if (ctrl == null || !_initialized) return;
    setState(() {
      if (ctrl.value.isPlaying) {
        ctrl.pause();
      } else {
        ctrl.play();
      }
    });
  }

  void _toggleMute() {
    final ctrl = _controller;
    if (ctrl == null || !_initialized) return;
    setState(() {
      _isMuted = !_isMuted;
      ctrl.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = _controller;

    if (_hasError || !_initialized || ctrl == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (widget.posterUrl != null && widget.posterUrl!.isNotEmpty)
            ShopImage(widget.posterUrl!, fit: widget.fit, w: 800, q: 75)
          else
            Container(color: AppTheme.surfaceGrey),
          if (!_hasError)
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.obsidianNoir.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    final size = ctrl.value.size;
    final videoWidth = size.width > 0 ? size.width : 480.0;
    final videoHeight = size.height > 0 ? size.height : 688.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: FittedBox(
            fit: widget.fit,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: videoWidth,
              height: videoHeight,
              child: VideoPlayer(ctrl),
            ),
          ),
        ),
        if (widget.showControls)
          Positioned(
            bottom: widget.compactControls ? 8 : 14,
            left: widget.compactControls ? 8 : 14,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play / Pause pill
                Material(
                  color: AppTheme.obsidianNoir.withValues(alpha: 0.82),
                  child: InkWell(
                    onTap: _togglePlay,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.compactControls ? 8 : 10,
                        vertical: widget.compactControls ? 5 : 7,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            ctrl.value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: AppTheme.primaryGold,
                            size: widget.compactControls ? 14 : 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ctrl.value.isPlaying ? 'LIVE VIDEO' : 'PLAY VIDEO',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: widget.compactControls ? 8.5 : 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Mute / Unmute button
                Material(
                  color: AppTheme.obsidianNoir.withValues(alpha: 0.82),
                  child: InkWell(
                    onTap: _toggleMute,
                    child: Padding(
                      padding: EdgeInsets.all(widget.compactControls ? 5 : 7),
                      child: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: _isMuted ? Colors.white70 : AppTheme.primaryGold,
                        size: widget.compactControls ? 14 : 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
