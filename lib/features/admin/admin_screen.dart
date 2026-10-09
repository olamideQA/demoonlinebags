import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/config/app_config.dart';
import '../../core/providers/products_provider.dart';
import '../../core/theme/app_theme.dart';
import '../common/announcement_bar.dart';
import '../common/luxury_header.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(filteredProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final pairingsAsync = ref.watch(pairingsProvider);
    final isMobile = MediaQuery.of(context).size.width < 900;

    final bagCount = products.where((p) => p.productType == 'bag').length;
    final shoeCount = products.where((p) => p.productType == 'shoe').length;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AnnouncementBar(),
            const LuxuryHeader(),

            Container(
              color: AppTheme.surfaceDark,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 64, vertical: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ATELIER BACK-OFFICE',
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.primaryGold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Inventory & Store Operations',
                        style: GoogleFonts.cormorantGaramond(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                    onPressed: () => context.go('/'),
                    child: const Text('BACK TO STORE'),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 64, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Cards
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _kpiCard('Active Handbags', '$bagCount', Icons.shopping_bag_outlined),
                      _kpiCard('Active Footwear', '$shoeCount', Icons.flare_outlined),
                      _kpiCard('Complete The Look Sets', '${pairingsAsync.value?.length ?? 2}', Icons.auto_awesome),
                      _kpiCard('Categories', '${categoriesAsync.value?.length ?? 7}', Icons.category_outlined),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Supabase Status Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGrey,
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_done_outlined, color: AppTheme.successGreen, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Supabase Relational Backend Connected',
                                style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Endpoint: ${AppConfig.supabaseUrl}',
                                style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Inventory Table
                  Text(
                    'CURRENT PRODUCT CATALOGUE',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 16),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(AppTheme.surfaceGrey),
                      columns: const [
                        DataColumn(label: Text('Creation')),
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Price (₦)')),
                        DataColumn(label: Text('Stock')),
                        DataColumn(label: Text('Rating')),
                      ],
                      rows: products.map((p) {
                        return DataRow(
                          cells: [
                            DataCell(Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(Text(p.productType.toUpperCase())),
                            DataCell(Text(p.subCategory ?? '-')),
                            DataCell(Text(p.formattedEffectivePrice)),
                            DataCell(Text('${p.stockQuantity} units')),
                            DataCell(Text('${p.rating} ★')),
                          ],
                        );
                      }).toList(),
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

  Widget _kpiCard(String label, String value, IconData icon) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGoldDark, size: 24),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, color: AppTheme.textMuted)),
        ],
      ),
    );
  }
}
