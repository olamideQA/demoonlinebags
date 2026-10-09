import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return SupabaseService.getCategories();
});

final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  return SupabaseService.getProducts();
});

final pairingsProvider = FutureProvider<List<ProductPairing>>((ref) async {
  return SupabaseService.getPairings();
});

// Modern Riverpod 3 Notifiers for filtering & searching
class CategoryFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  @override
  set state(String? val) => super.state = val;
}
final selectedCategorySlugProvider = NotifierProvider<CategoryFilterNotifier, String?>(CategoryFilterNotifier.new);

class ProductTypeFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  @override
  set state(String? val) => super.state = val;
}
final selectedProductTypeProvider = NotifierProvider<ProductTypeFilterNotifier, String?>(ProductTypeFilterNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  @override
  set state(String val) => super.state = val;
}
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SortByNotifier extends Notifier<String> {
  @override
  String build() => 'featured';
  @override
  set state(String val) => super.state = val;
}
final sortByProvider = NotifierProvider<SortByNotifier, String>(SortByNotifier.new);

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final productsAsync = ref.watch(allProductsProvider);
  final categorySlug = ref.watch(selectedCategorySlugProvider);
  final productType = ref.watch(selectedProductTypeProvider);
  final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();
  final sortBy = ref.watch(sortByProvider);

  return productsAsync.maybeWhen(
    data: (products) {
      var filtered = List<Product>.from(products);

      // Product Type filter (Bags vs Shoes)
      if (productType != null && productType.isNotEmpty) {
        filtered = filtered.where((p) => p.productType == productType).toList();
      }

      // Category Slug filter
      if (categorySlug != null && categorySlug.isNotEmpty && categorySlug != 'all') {
        final categories = ref.watch(categoriesProvider).value ?? [];
        final matchedCategory = categories.where((c) => c.slug == categorySlug).firstOrNull;
        if (matchedCategory != null) {
          filtered = filtered.where((p) => p.categoryId == matchedCategory.id).toList();
        }
      }

      // Search Query filter
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((p) {
          final titleMatch = p.title.toLowerCase().contains(searchQuery);
          final descMatch = (p.description ?? '').toLowerCase().contains(searchQuery);
          final subCatMatch = (p.subCategory ?? '').toLowerCase().contains(searchQuery);
          final materialMatch = (p.material ?? '').toLowerCase().contains(searchQuery);
          return titleMatch || descMatch || subCatMatch || materialMatch;
        }).toList();
      }

      // Sorting
      switch (sortBy) {
        case 'price_asc':
          filtered.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
          break;
        case 'price_desc':
          filtered.sort((a, b) => b.effectivePrice.compareTo(a.effectivePrice));
          break;
        case 'rating':
          filtered.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'newest':
          filtered.sort((a, b) => (b.isNewArrival ? 1 : 0).compareTo(a.isNewArrival ? 1 : 0));
          break;
        case 'featured':
        default:
          filtered.sort((a, b) => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0));
          break;
      }

      return filtered;
    },
    orElse: () => SupabaseService.fallbackProducts,
  );
});
