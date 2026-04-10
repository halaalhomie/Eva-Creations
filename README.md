# Eva Creations Inventory + POS App

A premium Flutter mobile app for Eva Creations to manage inventory, sell products through barcode scanning, and track core business performance.

Full product documentation is available in [docs/APP_DOCUMENTATION.md](/Users/aryansingh/clothing_shop_app/docs/APP_DOCUMENTATION.md).

## What This App Does

This app is designed for small to medium clothing stores that want one simple system for:

- adding products into inventory
- generating a barcode for every item
- scanning products during sales
- reducing stock automatically after a sale
- tracking total revenue and profit
- identifying low stock items before they run out

## Main Screens

### Add
The Add screen lets staff create a new product with:

- product name
- selling price
- cost price
- quantity
- category
- auto-generated barcode

After a successful save, the form clears itself, creates a fresh barcode, and places focus back on the product name field for fast repeated entry.

### Sell
The Sell screen uses the device camera as a barcode scanner.

When a barcode is scanned:

1. the app finds the matching product
2. checks whether stock is available
3. decreases quantity by 1
4. records the sale revenue
5. records the sale profit

### Products
The Products screen shows all inventory items in card format with:

- product name
- highlighted price
- quantity
- category chip
- barcode
- low stock warning

Users can search, edit, and delete products from this screen.

### Stats
The Stats screen shows:

- total revenue
- total profit
- total products
- low stock count
- low stock alert list

## Tech Stack

- Flutter
- Firebase Core
- Cloud Firestore
- `mobile_scanner` for barcode scanning
- `barcode_widget` for barcode generation

## Firestore Collections

### `products`
Each product stores:

- `name`
- `price`
- `cost`
- `quantity`
- `category`
- `barcode`

### `sales`
Each day is stored as one document using the date as the document id.

Each sales document stores:

- `revenue`
- `profit`

## Run Locally

```bash
flutter pub get
flutter run
```

## Release Build

Android APK:

```bash
flutter build apk --release
```

Android App Bundle for Play Store:

```bash
flutter build appbundle --release
```

## Current Scope

This version is a strong MVP and release foundation. It currently focuses on:

- single-store inventory management
- barcode-based POS sales
- real-time Firestore-backed product and sales updates

Potential next steps:

- authentication and staff roles
- order history screen
- invoice/receipt generation
- advanced reports
- category analytics
- offline-first sync messaging
