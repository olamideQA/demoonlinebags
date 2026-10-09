import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

const _kWishlistKey = 'luxe_wishlist_ids_v1';

class WishlistNotifier extends Notifier<List<Product>> {
  bool _loaded = false;

  @override
  List<Product> build() {
    if (!_loaded) {
      _loaded = true;
      _restore();
    }
    return [];
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_kWishlistKey) ?? [];
      if (ids.isEmpty) return;
      // Resolve IDs to live products (handles price/image updates).
      final all = await SupabaseService.getProducts();
      final map = {for (final p in all) p.id: p};
      final restored = [
        for (final id in ids)
          if (map.containsKey(id)) map[id]!,
      ];
      if (restored.isNotEmpty) state = restored;
    } catch (_) {
      // Stay empty rather than crash on corrupted storage.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kWishlistKey, state.map((p) => p.id).toList());
    } catch (_) {}
  }

  void toggleWishlist(Product product) {
    final exists = state.any((p) => p.id == product.id);
    if (exists) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }
    _persist();
  }

  bool isInWishlist(String productId) {
    return state.any((p) => p.id == productId);
  }

  void clear() {
    state = [];
    _persist();
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, List<Product>>(WishlistNotifier.new);
