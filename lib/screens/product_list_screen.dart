import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../core/theme.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../services/inventory_export_service.dart';
import '../widgets/product_card.dart';
import '../widgets/section_heading.dart';
import 'edit_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final searchController = TextEditingController();
  String searchQuery = '';
  bool isExporting = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          children: [
            const SectionHeading(
              title: 'Products',
              subtitle:
                  'Flip through your catalog with search, tags, and stock warnings.',
            ),
            const SizedBox(height: 18),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search product, category, or barcode',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            searchController.clear();
                            setState(() => searchQuery = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() => searchQuery = value.toLowerCase());
                },
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: StreamBuilder<List<Product>>(
                stream: service.watchProducts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allProducts = snapshot.data!;

                  final query = searchQuery.trim();
                  final products = allProducts
                      .where(
                        (product) =>
                            query.isEmpty ||
                            product.name.toLowerCase().contains(query) ||
                            product.category.toLowerCase().contains(query) ||
                            product.barcode.toLowerCase().contains(query),
                      )
                      .toList();

                  if (products.isEmpty) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: const Text('No matching products found.'),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 14),
                        child: FilledButton.tonalIcon(
                          onPressed: isExporting
                              ? null
                              : () => _showExportOptions(allProducts),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.08,
                            ),
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          icon: isExporting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.file_download_outlined),
                          label: Text(
                            isExporting
                                ? 'Preparing Excel...'
                                : 'Export Present Stock to Excel',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];

                            return ProductCard(
                              product: product,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditProductScreen(product: product),
                                  ),
                                );
                              },
                              onDelete: () async {
                                await service.deleteProduct(product.id);
                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} deleted'),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExportOptions(List<Product> products) async {
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('There are no products to export.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Stock',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose whether to export all stock or only products added in a selected date range.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('Export All Stock'),
                  subtitle: const Text(
                    'Includes every product currently in inventory',
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _exportInventoryInternal(products);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.date_range_outlined),
                  title: const Text('Export by Date Range'),
                  subtitle: const Text(
                    'Includes products added within a chosen range',
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    final range = await showDateRangePicker(
                      context: this.context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      currentDate: DateTime.now(),
                    );

                    if (range == null || !mounted) {
                      return;
                    }

                    final filteredProducts = products.where((product) {
                      if (product.createdAt == null) {
                        return false;
                      }

                      final createdAt = DateTime(
                        product.createdAt!.year,
                        product.createdAt!.month,
                        product.createdAt!.day,
                      );
                      final start = DateTime(
                        range.start.year,
                        range.start.month,
                        range.start.day,
                      );
                      final end = DateTime(
                        range.end.year,
                        range.end.month,
                        range.end.day,
                      );

                      return !createdAt.isBefore(start) &&
                          !createdAt.isAfter(end);
                    }).toList();

                    await _exportInventoryInternal(
                      filteredProducts,
                      dateRange: range,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportInventoryInternal(
    List<Product> products, {
    DateTimeRange? dateRange,
  }) async {
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dateRange == null
                ? 'There are no products to export.'
                : 'No products were found in the selected date range.',
          ),
        ),
      );
      return;
    }

    setState(() => isExporting = true);

    try {
      final file = await InventoryExportService().exportProductsToExcel(
        products,
        dateRange: dateRange,
      );

      if (!mounted) {
        return;
      }

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Eva Creations current stock export',
        subject: 'Eva Creations Stock Export',
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Excel export could not be created. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isExporting = false);
      }
    }
  }
}
