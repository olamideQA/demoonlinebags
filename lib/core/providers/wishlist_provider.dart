import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

class WishlistNotifier extends Notifier<List<Product>> {
  @override
  List<Product> build() => [];

  void toggleWishlist(Product product) {
    final exists = state.any((p) => p.id == product.id);
    if (exists) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }
  }

  bool isInWishlist(String productId) {
    return state.any((p) => p.id == productId);
  }
}

final wishlistProvider = NotifierProvider<WishlistNotifier, List<Product>>(WishlistNotifier.new);
