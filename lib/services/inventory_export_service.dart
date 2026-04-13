import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../models/product.dart';

class InventoryExportService {
  Future<File> exportProductsToExcel(
    List<Product> products, {
    DateTimeRange? dateRange,
  }) async {
    final excel = Excel.createExcel();
    final sheet = excel['Current Stock'];

    if (dateRange != null) {
      sheet.appendRow([
        TextCellValue('Export Range'),
        TextCellValue(
          '${_formatDate(dateRange.start)} to ${_formatDate(dateRange.end)}',
        ),
      ]);
      sheet.appendRow([
        TextCellValue('Generated On'),
        TextCellValue(_formatDateTime(DateTime.now())),
      ]);
      sheet.appendRow([TextCellValue('')]);
    }

    sheet.appendRow([
      TextCellValue('Product Name'),
      TextCellValue('Category'),
      TextCellValue('Barcode'),
      TextCellValue('Added On'),
      TextCellValue('Selling Price'),
      TextCellValue('Cost Price'),
      TextCellValue('Quantity'),
      TextCellValue('Low Stock'),
      TextCellValue('Stock Value'),
    ]);

    for (final product in products) {
      sheet.appendRow([
        TextCellValue(product.name),
        TextCellValue(product.category),
        TextCellValue(product.barcode),
        TextCellValue(
          product.createdAt == null
              ? 'Unknown'
              : _formatDate(product.createdAt!),
        ),
        DoubleCellValue(product.price),
        DoubleCellValue(product.cost),
        IntCellValue(product.quantity),
        TextCellValue(product.isLowStock ? 'Yes' : 'No'),
        DoubleCellValue(product.price * product.quantity),
      ]);
    }

    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final rangeLabel = dateRange == null
        ? 'all-stock'
        : '${_formatFileDate(dateRange.start)}_to_${_formatFileDate(dateRange.end)}';
    final file = File(
      '${directory.path}/eva-creations excel export $rangeLabel $timestamp.xlsx',
    );

    final bytes = excel.save();
    if (bytes == null) {
      throw StateError('Excel file could not be generated.');
    }

    return file.writeAsBytes(bytes, flush: true);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${_formatDate(date)} $hour:$minute';
  }

  String _formatFileDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
