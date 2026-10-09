import 'package:flutter/material.dart';
import 'fast_image.dart';

/// Permanent no-blank image for all shop pages.
/// Shows local placeholder instantly, fades in network when ready,
/// keeps placeholder if network fails. Never black/blank.
class ShopImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final int w;
  final int q;

  const ShopImage(this.url, {super.key, this.fit = BoxFit.cover, this.w = 600, this.q = 60});

  bool get _isLocal => url.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    if (_isLocal) {
      return Image.asset(url, fit: fit, gaplessPlayback: true,
        errorBuilder: (_, _, _) =>
            Image.asset('assets/images/placeholder.jpg', fit: fit));
    }
    return FadeInImage(
      placeholder: const AssetImage('assets/images/placeholder.jpg'),
      image: NetworkImage(fastImg(url, w: w, q: q)),
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 250),
      fadeOutDuration: const Duration(milliseconds: 100),
      imageErrorBuilder: (_, _, _) =>
          Image.asset('assets/images/placeholder.jpg', fit: fit),
    );
  }
}
