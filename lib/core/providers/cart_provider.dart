import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

class CartState {
  final List<CartItem> items;
  final bool isDrawerOpen;
  final String? promoCode;
  final double discountPercent;

  const CartState({
    this.items = const [],
    this.isDrawerOpen = false,
    this.promoCode,
    this.discountPercent = 0.0,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get discountAmount => subtotal * (discountPercent / 100.0);

  // Complimentary courier delivery for orders ₦150,000 and above
  static const double freeShippingThreshold = 150000.0;
  static const double standardShippingFee = 5000.0;

  bool get qualifiesForFreeShipping => subtotal >= freeShippingThreshold;

  double get shippingFee {
    if (items.isEmpty) return 0.0;
    return qualifiesForFreeShipping ? 0.0 : standardShippingFee;
  }

  double get total => (subtotal - discountAmount) + shippingFee;

  double get freeShippingProgress {
    if (subtotal >= freeShippingThreshold) return 1.0;
    return subtotal / freeShippingThreshold;
  }

  double get amountNeededForFreeShipping {
    if (qualifiesForFreeShipping) return 0.0;
    return freeShippingThreshold - subtotal;
  }

  CartState copyWith({
    List<CartItem>? items,
    bool? isDrawerOpen,
    String? promoCode,
    double? discountPercent,
    bool clearPromo = false,
  }) {
    return CartState(
      items: items ?? this.items,
      isDrawerOpen: isDrawerOpen ?? this.isDrawerOpen,
      promoCode: clearPromo ? null : (promoCode ?? this.promoCode),
      discountPercent: clearPromo ? 0.0 : (discountPercent ?? this.discountPercent),
    );
  }
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void toggleDrawer([bool? open]) {
    state = state.copyWith(isDrawerOpen: open ?? !state.isDrawerOpen);
  }

  void addToCart(Product product, {String? color, String? size, int quantity = 1}) {
    final existingIndex = state.items.indexWhere((item) =>
        item.product.id == product.id &&
        item.selectedColor == color &&
        item.selectedSize == size);

    List<CartItem> updatedItems;
    if (existingIndex >= 0) {
      updatedItems = List.from(state.items);
      updatedItems[existingIndex].quantity += quantity;
    } else {
      final newItem = CartItem(
        id: '${product.id}_${color ?? "default"}_${size ?? "standard"}_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        selectedColor: color,
        selectedSize: size,
        quantity: quantity,
        unitPrice: product.effectivePrice,
      );
      updatedItems = [...state.items, newItem];
    }

    state = state.copyWith(items: updatedItems, isDrawerOpen: true);
  }

  void addBundleToCart(ProductPairing pairing) {
    if (pairing.bagProduct != null) {
      addToCart(pairing.bagProduct!, quantity: 1);
    }
    if (pairing.shoeProduct != null) {
      addToCart(pairing.shoeProduct!, quantity: 1);
    }
  }

  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(itemId);
      return;
    }
    final updatedItems = state.items.map((item) {
      if (item.id == itemId) {
        return CartItem(
          id: item.id,
          product: item.product,
          selectedColor: item.selectedColor,
          selectedSize: item.selectedSize,
          quantity: newQuantity,
          unitPrice: item.unitPrice,
        );
      }
      return item;
    }).toList();
    state = state.copyWith(items: updatedItems);
  }

  void removeFromCart(String itemId) {
    final updatedItems = state.items.where((item) => item.id != itemId).toList();
    state = state.copyWith(items: updatedItems);
  }

  bool applyPromoCode(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'VIPLUXE10' || clean == 'VIP10') {
      state = state.copyWith(promoCode: clean, discountPercent: 10.0);
      return true;
    } else if (clean == 'DEMO15') {
      state = state.copyWith(promoCode: clean, discountPercent: 15.0);
      return true;
    }
    return false;
  }

  void removePromoCode() {
    state = state.copyWith(clearPromo: true);
  }

  void clearCart() {
    state = const CartState();
  }
}

final cartProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);
