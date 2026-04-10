# App Documentation

## 1. Overview

This application is a Flutter-based inventory and point-of-sale system built for a clothing shop. It combines product management, barcode-assisted selling, inventory tracking, and business analytics into one mobile experience.

The goal of the app is to help a shop owner or store staff:

- add and manage clothing products
- sell products quickly using barcode scanning
- keep inventory updated automatically
- understand revenue and profit performance
- identify low stock items early

## 2. Who This App Is For

This app is suitable for:

- boutique clothing stores
- fashion retailers
- single-location retail shops
- shop owners who want a lightweight POS + stock manager
- staff who need quick product entry and simple selling workflows

## 3. How The App Works

The app is built around four main tabs in the bottom navigation bar:

1. Add
2. Sell
3. Products
4. Stats

Each tab supports a specific part of the store workflow.

## 4. Screen-by-Screen Explanation

### 4.1 Add Product Screen

Purpose:
The Add Product screen is used to create a new inventory item.

Data entered:

- Product name
- Selling price
- Cost price
- Quantity
- Category

Automatic behavior:

- The app automatically generates a barcode for the product.
- When the product is saved, it is added to Firestore in the `products` collection.
- After saving, the form clears for the next item.
- A fresh barcode is generated automatically.
- Focus returns to the product name field so staff can continue entering products quickly.

Why this matters:
This makes bulk inventory entry fast and repeatable during setup or restocking.

### 4.2 Sell Screen

Purpose:
The Sell screen acts as the point-of-sale scanner.

How it works:

1. The device camera opens in scanner mode.
2. The user points the camera at a product barcode.
3. The app searches Firestore for a product with that barcode.
4. If the product exists and quantity is available:
   - quantity is reduced by 1
   - revenue is recorded
   - profit is recorded
5. A success snackbar confirms the sale.

If something goes wrong:

- If no product matches the barcode, the app shows an error message.
- If the item is out of stock, the app informs the user.

Why this matters:
This removes manual billing steps and keeps inventory synced with actual sales.

### 4.3 Products Screen

Purpose:
The Products screen is the inventory browser and management area.

What users can do:

- see all products
- search by name
- search by category
- search by barcode
- edit products
- delete products

What each product card shows:

- product name
- price
- quantity
- category
- barcode
- low stock status

Low stock logic:
Products are marked as low stock when quantity is 5 or below.

Why this matters:
This lets staff review inventory quickly and maintain product accuracy.

### 4.4 Stats Screen

Purpose:
The Stats screen gives a business summary.

What it shows:

- total revenue
- total profit
- total product count
- low stock count
- low stock alert list

How it works:

- Revenue and profit are read from the `sales` collection.
- Product counts and low stock alerts are read from the `products` collection.

Why this matters:
This helps the owner understand shop performance without using separate reports.

## 5. Business Flow

The real-world usage flow of the app is:

1. Add products into the system.
2. Each product gets its own barcode.
3. Products appear in the inventory list.
4. During checkout, staff scan the product barcode.
5. The sale is recorded automatically.
6. Product quantity reduces automatically.
7. Dashboard stats update from recorded sales and product stock.

## 6. Data Storage

The app uses Firebase Firestore as the backend database.

### 6.1 Products Collection

Collection name:
`products`

Each document stores:

- `name`: product name
- `price`: selling price
- `cost`: cost price
- `quantity`: units in stock
- `category`: product category
- `barcode`: generated barcode value

### 6.2 Sales Collection

Collection name:
`sales`

The app stores one document per day.

Document fields:

- `revenue`: total sales amount for the day
- `profit`: total profit amount for the day

Document id pattern:
The current implementation uses the date string as the document id.

## 7. Core Logic Summary

### Add Product Logic

- Validate form values
- Generate barcode
- Save product in Firestore
- Clear form after save
- Generate next barcode

### Sell Product Logic

- Scan barcode
- Find matching product
- Confirm stock is greater than 0
- Reduce quantity
- Add revenue and profit entry

### Dashboard Logic

- Sum all `revenue` values from sales documents
- Sum all `profit` values from sales documents
- Count products from inventory
- Identify products with low stock

## 8. UI and UX Style

The app is designed to feel modern and premium.

Design characteristics:

- clean spacing
- card-based layout
- rounded corners
- premium dark-blue theme
- green used for profit/success
- red used for warnings/low stock
- minimal bottom navigation
- scanner overlay styled like modern commerce apps

## 9. Architecture

The codebase is organized into clear sections:

### `lib/screens/`
Contains the main app screens:

- home
- add product
- sales scanner
- product list
- dashboard
- edit product

### `lib/widgets/`
Contains reusable UI components such as:

- custom input field
- primary button
- product card
- section heading

### `lib/services/`
Contains backend logic and Firestore methods.

### `lib/models/`
Contains structured app models such as `Product`.

### `lib/core/`
Contains theme and design system setup.

## 10. Current Strengths

This app already provides:

- real-time Firestore product updates
- barcode generation
- barcode-based selling
- auto inventory reduction on sale
- revenue and profit tracking
- low stock visibility
- polished premium UI

## 11. Current Limitations

This version does not yet include:

- user login or staff authentication
- multi-store support
- detailed sales history screen
- printable receipts
- customer records
- product images
- advanced financial reports

These can be added in future versions.

## 12. Suggested Release Description

You can use this short explanation when sharing the app with others:

"This is a mobile inventory and POS app for clothing shops. Staff can add products, generate barcodes, scan items during sales, automatically update stock, and monitor revenue, profit, and low-stock alerts from a clean premium dashboard."

## 13. Suggested Demo Script

If you want to explain the app live, use this sequence:

1. Open the Add screen and create a product.
2. Show the auto-generated barcode.
3. Open Products and show that the item is listed.
4. Open Sell and scan the barcode.
5. Show the success message.
6. Return to Products and show reduced stock.
7. Open Stats and explain revenue, profit, and low stock cards.

## 14. Setup and Run

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Build Android release APK:

```bash
flutter build apk --release
```

Build Android App Bundle for Play Store:

```bash
flutter build appbundle --release
```

## 15. Final Summary

This app works as a focused retail tool for clothing businesses. It combines inventory entry, barcode selling, stock management, and business reporting in one mobile interface. It is well suited for MVP launch, demos, client presentations, and further production expansion.
