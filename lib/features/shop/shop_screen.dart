import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/products_provider.dart';
import '../../core/theme/app_theme.dart';
import '../common/announcement_bar.dart';
import '../common/cart_drawer.dart';
import '../common/luxury_footer.dart';
import '../common/luxury_header.dart';
import '../common/product_card.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProducts = ref.watch(filteredProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategorySlugProvider);
    final selectedType = ref.watch(selectedProductTypeProvider);
    final sortBy = ref.watch(sortByProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final isMobile = MediaQuery.of(context).size.width < 900;

    final categories = categoriesAsync.value ?? [];

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AnnouncementBar(),
                const LuxuryHeader(),

                // Shop Hero Header
                Container(
                  color: AppTheme.surfaceDark,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 64,
                    vertical: 40,
                  ),
                  child: Column(
                    children: [
                      Text(
                        selectedType == 'shoe'
                            ? 'THE FOOTWEAR SALON'
                            : (selectedType == 'bag' ? 'THE HANDBAG COLLECTION' : 'ALL CREATIONS'),
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.primaryGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedType == 'shoe'
                            ? 'Sculpted Heels, Slingbacks & Mules'
                            : (selectedType == 'bag' ? 'Artisanal Handbags, Totes & Clutches' : 'The Complete Catalogue'),
                        style: GoogleFonts.cormorantGaramond(
                          color: Colors.white,
                          fontSize: isMobile ? 28 : 38,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Refined materials, hand-finished edges, and timeless poise.',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filters & Controls Toolbar
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 64,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type Switcher Row (All vs Bags vs Shoes)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _TypeTab(
                              title: 'ALL CREATIONS',
                              isSelected: selectedType == null,
                              onTap: () {
                                ref.read(selectedProductTypeProvider.notifier).state = null;
                                ref.read(selectedCategorySlugProvider.notifier).state = null;
                              },
                            ),
                            const SizedBox(width: 8),
                            _TypeTab(
                              title: 'HANDBAGS & TOTES',
                              isSelected: selectedType == 'bag',
                              onTap: () {
                                ref.read(selectedProductTypeProvider.notifier).state = 'bag';
                                ref.read(selectedCategorySlugProvider.notifier).state = null;
                              },
                            ),
                            const SizedBox(width: 8),
                            _TypeTab(
                              title: 'SCULPTED FOOTWEAR',
                              isSelected: selectedType == 'shoe',
                              onTap: () {
                                ref.read(selectedProductTypeProvider.notifier).state = 'shoe';
                                ref.read(selectedCategorySlugProvider.notifier).state = null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category Pills & Sort Dropdown
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _CategoryPill(
                            title: 'All Silhouettes',
                            isSelected: selectedCategory == null || selectedCategory == 'all',
                            onTap: () => ref.read(selectedCategorySlugProvider.notifier).state = null,
                          ),
                          ...categories.map((c) => _CategoryPill(
                                title: c.name,
                                isSelected: selectedCategory == c.slug,
                                onTap: () => ref.read(selectedCategorySlugProvider.notifier).state = c.slug,
                              )),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search bar & Sort Controls
                      Row(
                        children: [
                          // Search Box
                          Expanded(
                            child: SizedBox(
                              height: 38,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Search by silhouette, material, leather...',
                                  prefixIcon: const Icon(Icons.search, size: 18),
                                  suffixIcon: searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, size: 16),
                                          onPressed: () => ref.read(searchQueryProvider.notifier).state = '',
                                        )
                                      : null,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Sort Dropdown
                          Container(
                            height: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.borderSubtle),
                              color: Colors.white,
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: sortBy,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.obsidianNoir,
                                  fontWeight: FontWeight.w500,
                                ),
                                icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                items: const [
                                  DropdownMenuItem(value: 'featured', child: Text('Sort: Featured')),
                                  DropdownMenuItem(value: 'newest', child: Text('Sort: Newest')),
                                  DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                                  DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                                  DropdownMenuItem(value: 'rating', child: Text('Customer Rating')),
                                ],
                                onChanged: (val) {
                                  if (val != null) ref.read(sortByProvider.notifier).state = val;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Products Count Header
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 64,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredProducts.length} CREATIONS FOUND',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      if (searchQuery.isNotEmpty || selectedCategory != null || selectedType != null)
                        InkWell(
                          onTap: () {
                            ref.read(searchQueryProvider.notifier).state = '';
                            ref.read(selectedCategorySlugProvider.notifier).state = null;
                            ref.read(selectedProductTypeProvider.notifier).state = null;
                          },
                          child: Text(
                            'RESET ALL FILTERS',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryGoldDark,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Products Grid
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 20 : 64,
                    vertical: 12,
                  ),
                  child: filteredProducts.isEmpty
                      ? _buildEmptyResults(context, ref)
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isMobile ? 2 : (MediaQuery.of(context).size.width > 1200 ? 4 : 3),
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 32,
                            childAspectRatio: 0.62,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (ctx, index) => ProductCard(product: filteredProducts[index]),
                        ),
                ),

                const SizedBox(height: 64),
                const LuxuryFooter(),
              ],
            ),
          ),

          // Slide-Over Bag Drawer
          const CartDrawer(),
        ],
      ),
    );
  }

  Widget _buildEmptyResults(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 54, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            'No Creations Match Your Selection',
            style: GoogleFonts.cormorantGaramond(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms or filter selection.',
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              ref.read(searchQueryProvider.notifier).state = '';
              ref.read(selectedCategorySlugProvider.notifier).state = null;
              ref.read(selectedProductTypeProvider.notifier).state = null;
            },
            child: const Text('RESET FILTERS'),
          ),
        ],
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.obsidianNoir : Colors.white,
          border: Border.all(color: isSelected ? AppTheme.obsidianNoir : AppTheme.borderSubtle),
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? Colors.white : AppTheme.obsidianNoir,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGold : AppTheme.surfaceGrey,
          border: Border.all(color: isSelected ? AppTheme.primaryGold : AppTheme.borderSubtle),
        ),
        child: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? Colors.white : AppTheme.obsidianNoir,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
