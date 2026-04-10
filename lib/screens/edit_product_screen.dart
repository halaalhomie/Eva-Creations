import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/firestore_service.dart';
import '../widgets/app_input_field.dart';
import '../widgets/primary_button.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key, required this.product});

  final Product product;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController costController;
  late TextEditingController qtyController;
  late TextEditingController categoryController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    costController = TextEditingController(
      text: widget.product.cost.toString(),
    );
    qtyController = TextEditingController(
      text: widget.product.quantity.toString(),
    );
    categoryController = TextEditingController(text: widget.product.category);
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    costController.dispose();
    qtyController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AppInputField(controller: nameController, label: 'Product Name'),
            const SizedBox(height: 14),
            AppInputField(
              controller: priceController,
              label: 'Selling Price',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 14),
            AppInputField(
              controller: costController,
              label: 'Cost Price',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 14),
            AppInputField(
              controller: qtyController,
              label: 'Quantity',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            AppInputField(controller: categoryController, label: 'Category'),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Update Product',
              isLoading: isSaving,
              onPressed: _updateProduct,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateProduct() async {
    final price = double.tryParse(priceController.text.trim());
    final cost = double.tryParse(costController.text.trim());
    final quantity = int.tryParse(qtyController.text.trim());

    if (price == null || cost == null || quantity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid numeric values to continue.'),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    final updatedProduct = widget.product.copyWith(
      name: nameController.text.trim(),
      price: price,
      cost: cost,
      quantity: quantity,
      category: categoryController.text.trim().isEmpty
          ? 'General'
          : categoryController.text.trim(),
    );

    await FirestoreService().updateProduct(updatedProduct);

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${updatedProduct.name} updated')));
  }
}
