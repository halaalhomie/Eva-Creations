import 'dart:async';
import 'dart:math';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../widgets/app_input_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/section_heading.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final qtyController = TextEditingController();
  final categoryController = TextEditingController();
  final costController = TextEditingController();
  final FocusNode nameFocusNode = FocusNode();

  bool isSaving = false;
  late String barcode;

  @override
  void initState() {
    super.initState();
    barcode = generateBarcode();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    qtyController.dispose();
    categoryController.dispose();
    costController.dispose();
    nameFocusNode.dispose();
    super.dispose();
  }

  String generateBarcode() {
    return (1000000000 + Random().nextInt(900000000)).toString();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeading(
              title: 'Add Product',
              subtitle:
                  'Create a polished inventory entry with pricing, stock, and barcode details.',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AppInputField(
                    controller: nameController,
                    label: 'Product Name',
                    hint: 'Oversized Cotton Shirt',
                    focusNode: nameFocusNode,
                    prefixIcon: Icons.shopping_bag_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppInputField(
                          controller: priceController,
                          label: 'Selling Price',
                          hint: '1499',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixIcon: Icons.currency_rupee_rounded,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppInputField(
                          controller: costController,
                          label: 'Cost Price',
                          hint: '899',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefixIcon: Icons.price_change_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppInputField(
                          controller: qtyController,
                          label: 'Quantity',
                          hint: '12',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.layers_outlined,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: AppInputField(
                          controller: categoryController,
                          label: 'Category',
                          hint: 'Menswear',
                          prefixIcon: Icons.sell_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Generated Barcode',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Auto-generated for quick checkout and inventory tracking.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: BarcodeWidget(
                            barcode: Barcode.code128(),
                            data: barcode,
                            width: 240,
                            height: 84,
                            drawText: false,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            barcode,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: 'Add Product',
                    icon: Icons.add_rounded,
                    isLoading: isSaving,
                    onPressed: _saveProduct,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text.trim());
    final cost = double.tryParse(costController.text.trim());
    final quantity = int.tryParse(qtyController.text.trim());
    final category = categoryController.text.trim();

    if (name.isEmpty || price == null || cost == null || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill all fields with valid values first.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => isSaving = true);

    final nextBarcode = generateBarcode();

    var resetCompleted = false;

    try {
      await FirestoreService()
          .addProduct(
            Product(
              id: '',
              name: name,
              price: price,
              cost: cost,
              quantity: quantity,
              category: category.isEmpty ? 'General' : category,
              barcode: barcode,
              createdAt: DateTime.now(),
            ),
          )
          .timeout(const Duration(seconds: 4));

      if (!mounted) {
        return;
      }

      _resetForm(nextBarcode: nextBarcode);
      resetCompleted = true;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$name added to inventory')));
    } on TimeoutException {
      if (!mounted) {
        return;
      }

      _resetForm(nextBarcode: nextBarcode);
      resetCompleted = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved locally. Sync may take a moment.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      if (!resetCompleted) {
        _resetForm(nextBarcode: nextBarcode);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Product saved attempt finished. Please confirm in Products.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  void _resetForm({required String nextBarcode}) {
    nameController.clear();
    priceController.clear();
    costController.clear();
    qtyController.clear();
    categoryController.clear();

    setState(() {
      barcode = nextBarcode;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        nameFocusNode.requestFocus();
      }
    });
  }
}
