/// Fast image helper for Nigerian networks.
/// Unsplash allows w + q + auto=format (WebP). We serve small files:
/// - cards/thumbs: w=600 q=60 (~60-90KB vs 400KB before)
/// - hero mobile: w=800 q=60, hero desktop: w=1200 q=60
/// Falls back to original URL if not Unsplash.
String fastImg(String url, {int w = 600, int q = 60}) {
  try {
    if (!url.contains('images.unsplash.com')) return url;
    final uri = Uri.parse(url);
    final params = Map<String, String>.from(uri.queryParameters);
    params.remove('auto');
    params['fm'] = 'jpg';
    params['fit'] = 'crop';
    params['w'] = '$w';
    params['q'] = '$q';
    return uri.replace(queryParameters: params).toString();
  } catch (_) {
    return url;
  }
}
