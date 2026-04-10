import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../core/theme.dart';
import '../services/firestore_service.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: controller,
          onDetect: (capture) async {
            if (isProcessing) {
              return;
            }

            final barcode = capture.barcodes.first.rawValue;
            if (barcode == null || barcode.isEmpty) {
              return;
            }

            setState(() => isProcessing = true);

            final service = FirestoreService();
            try {
              final result = await service
                  .sellProductByBarcode(barcode)
                  .timeout(const Duration(seconds: 5));

              if (!mounted) {
                return;
              }

              switch (result.status) {
                case SaleStatus.notFound:
                  _showSnackBar('No product matched this barcode.');
                  break;
                case SaleStatus.outOfStock:
                  _showSnackBar(
                    '${result.product?.name ?? 'Product'} is out of stock.',
                  );
                  break;
                case SaleStatus.success:
                  final product = result.product!;
                  _showSnackBar(
                    '${product.name} sold for ₹${product.price.toStringAsFixed(0)}',
                  );
                  await Future<void>.delayed(const Duration(milliseconds: 850));
                  break;
              }
            } on TimeoutException {
              if (mounted) {
                _showSnackBar('Sale is taking too long. Please scan again.');
              }
            } on StateError catch (error) {
              if (mounted && error.message == 'out_of_stock') {
                _showSnackBar('Product is out of stock.');
              }
            } catch (_) {
              if (mounted) {
                _showSnackBar('Sale could not be completed. Please try again.');
              }
            } finally {
              if (mounted) {
                setState(() => isProcessing = false);
              }
            }
          },
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.62),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.48, 1],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            color: Colors.white,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Scan Barcode',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: IconButton(
                        onPressed: () => controller.toggleTorch(),
                        icon: const Icon(
                          Icons.flashlight_on_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  scale: isProcessing ? 0.97 : 1,
                  child: Container(
                    width: 270,
                    height: 270,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.12),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const _ScanCorner(alignment: Alignment.topLeft),
                        const _ScanCorner(
                          alignment: Alignment.topRight,
                          rotateQuarterTurns: 1,
                        ),
                        const _ScanCorner(
                          alignment: Alignment.bottomRight,
                          rotateQuarterTurns: 2,
                        ),
                        const _ScanCorner(
                          alignment: Alignment.bottomLeft,
                          rotateQuarterTurns: 3,
                        ),
                        if (isProcessing)
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.42),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Align the barcode within the frame to complete the sale instantly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ScanCorner extends StatelessWidget {
  const _ScanCorner({required this.alignment, this.rotateQuarterTurns = 0});

  final Alignment alignment;
  final int rotateQuarterTurns;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: RotatedBox(
        quarterTurns: rotateQuarterTurns,
        child: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.accent, width: 4),
              left: BorderSide(color: AppColors.accent, width: 4),
            ),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(18)),
          ),
        ),
      ),
    );
  }
}
