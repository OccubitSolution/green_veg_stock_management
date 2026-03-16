# Translation Migration Guide

## Quick Reference: Common String Replacements

Use this guide to quickly convert hardcoded translation keys to the new centralized system.

### Import Statement
Add this to the top of every file:
```dart
import 'package:green_veg_stock_management/app/core/values/strings.dart';
```

### Common Replacements

| Old Code | New Code |
|----------|----------|
| `'app_name'.tr` | `AppStrings.appName.tr` |
| `'loading'.tr` | `AppStrings.loading.tr` |
| `'error'.tr` | `AppStrings.error.tr` |
| `'success'.tr` | `AppStrings.success.tr` |
| `'cancel'.tr` | `AppStrings.cancel.tr` |
| `'save'.tr` | `AppStrings.save.tr` |
| `'delete'.tr` | `AppStrings.delete.tr` |
| `'edit'.tr` | `AppStrings.edit.tr` |
| `'add'.tr` | `AppStrings.add.tr` |
| `'search'.tr` | `AppStrings.search.tr` |
| `'yes'.tr` | `AppStrings.yes.tr` |
| `'no'.tr` | `AppStrings.no.tr` |
| `'ok'.tr` | `AppStrings.ok.tr` |
| `'close'.tr` | `AppStrings.close.tr` |
| `'back'.tr` | `AppStrings.back.tr` |

### Products

| Old Code | New Code |
|----------|----------|
| `'products'.tr` | `AppStrings.products.tr` |
| `'product_name'.tr` | `AppStrings.productName.tr` |
| `'add_product'.tr` | `AppStrings.addProduct.tr` |
| `'edit_product'.tr` | `AppStrings.editProduct.tr` |
| `'delete_product'.tr` | `AppStrings.deleteProduct.tr` |
| `'category'.tr` | `AppStrings.category.tr` |
| `'unit'.tr` | `AppStrings.unit.tr` |
| `'price'.tr` | `AppStrings.price.tr` |
| `'max_price'.tr` | `AppStrings.maxPrice.tr` |
| `'enter_product_name'.tr` | `AppStrings.enterProductName.tr` |
| `'select_category'.tr` | `AppStrings.selectCategory.tr` |
| `'select_unit'.tr` | `AppStrings.selectUnit.tr` |
| `'product_added_successfully'.tr` | `AppStrings.productAddedSuccessfully.tr` |
| `'failed_to_save_product'.tr` | `AppStrings.failedToSaveProduct.tr` |

### Customers

| Old Code | New Code |
|----------|----------|
| `'customers'.tr` | `AppStrings.customers.tr` |
| `'customer_name'.tr` | `AppStrings.customerName.tr` |
| `'add_customer'.tr` | `AppStrings.addCustomer.tr` |
| `'enter_customer_name'.tr` | `AppStrings.enterCustomerName.tr` |
| `'enter_phone'.tr` | `AppStrings.enterPhone.tr` |
| `'enter_email'.tr` | `AppStrings.enterEmail.tr` |
| `'enter_address'.tr` | `AppStrings.enterAddress.tr` |
| `'customer_created'.tr` | `AppStrings.customerCreated.tr` |
| `'customer_updated'.tr` | `AppStrings.customerUpdated.tr` |

### Orders

| Old Code | New Code |
|----------|----------|
| `'orders'.tr` | `AppStrings.orders.tr` |
| `'daily_orders'.tr` | `AppStrings.dailyOrders.tr` |
| `'add_new_order'.tr` | `AppStrings.addNewOrder.tr` |
| `'save_order'.tr` | `AppStrings.saveOrder.tr` |
| `'order_saved'.tr` | `AppStrings.orderSaved.tr` |
| `'no_orders_today'.tr` | `AppStrings.noOrdersToday.tr` |
| `'please_select_customer'.tr` | `AppStrings.pleaseSelectCustomer.tr` |
| `'please_add_items'.tr` | `AppStrings.pleaseAddItems.tr` |
| `'enter_quantity'.tr` | `AppStrings.enterQuantity.tr` |

### Purchase List

| Old Code | New Code |
|----------|----------|
| `'purchase_list'.tr` | `AppStrings.purchaseList.tr` |
| `'total_items'.tr` | `AppStrings.totalItems.tr` |
| `'total_customers'.tr` | `AppStrings.totalCustomers.tr` |
| `'copied'.tr` | `AppStrings.copied.tr` |
| `'share_list'.tr` | `AppStrings.shareList.tr` |

### Validation

| Old Code | New Code |
|----------|----------|
| `'field_required'.tr` | `AppStrings.fieldRequired.tr` |
| `'invalid_email'.tr` | `AppStrings.invalidEmail.tr` |
| `'invalid_phone'.tr` | `AppStrings.invalidPhone.tr` |
| `'invalid_number'.tr` | `AppStrings.invalidNumber.tr` |
| `'must_be_positive'.tr` | `AppStrings.mustBePositive.tr` |

### Messages

| Old Code | New Code |
|----------|----------|
| `'something_went_wrong'.tr` | `AppStrings.somethingWentWrong.tr` |
| `'saved_successfully'.tr` | `AppStrings.savedSuccessfully.tr` |
| `'deleted_successfully'.tr` | `AppStrings.deletedSuccessfully.tr` |
| `'failed_to_load_data'.tr` | `AppStrings.failedToLoadData.tr` |
| `'no_data'.tr` | `AppStrings.noData.tr` |

## How to Migrate a File

### Step 1: Add Import
```dart
import 'package:green_veg_stock_management/app/core/values/strings.dart';
```

### Step 2: Find and Replace
Use your IDE's find and replace (Ctrl+H or Cmd+H):

1. Find: `'product_name'.tr`
2. Replace: `AppStrings.productName.tr`
3. Replace All

### Step 3: Check for Errors
Run diagnostics to ensure no errors.

## Example Migration

### Before:
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('products'.tr)),
      body: Column(
        children: [
          Text('product_name'.tr),
          ElevatedButton(
            onPressed: () {},
            child: Text('add_product'.tr),
          ),
        ],
      ),
    );
  }
}
```

### After:
```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_veg_stock_management/app/core/values/strings.dart';

class ProductView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.products.tr)),
      body: Column(
        children: [
          Text(AppStrings.productName.tr),
          ElevatedButton(
            onPressed: () {},
            child: Text(AppStrings.addProduct.tr),
          ),
        ],
      ),
    );
  }
}
```

## Priority Files to Migrate

Migrate these files first for maximum impact:

1. ✅ `lib/app/modules/products/views/add_product_view.dart` (DONE)
2. ✅ `lib/app/modules/products/controllers/product_form_controller.dart` (DONE)
3. `lib/app/modules/orders/views/orders_view.dart`
4. `lib/app/modules/orders/views/simple_orders_view.dart`
5. `lib/app/modules/customers/views/customers_view.dart`
6. `lib/app/modules/orders/views/purchase_list_view.dart`
7. `lib/app/modules/home/views/home_view.dart`
8. `lib/app/modules/products/views/products_view.dart`

## Tips

1. **Use IDE Search**: Search for `.tr` to find all translation calls
2. **Batch Replace**: Use find/replace for common strings
3. **Test After**: Run the app after migrating each file
4. **Check Autocomplete**: If AppStrings doesn't autocomplete, check import
5. **Look in strings.dart**: If you can't find a string, check if it exists

## Need Help?

If you can't find a string constant:
1. Open `lib/app/core/values/strings.dart`
2. Use Ctrl+F to search for keywords
3. If not found, add it following the pattern

## Summary

- ✅ Import `strings.dart` in every file
- ✅ Replace `'key'.tr` with `AppStrings.key.tr`
- ✅ Use autocomplete to find strings
- ✅ All strings organized by category
- ✅ Easy to maintain and update
