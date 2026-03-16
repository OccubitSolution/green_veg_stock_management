# Centralized Strings System

## Overview
All app text is now centralized in `strings.dart` for easy management and translation.

## Benefits
1. **Easy to Find**: All strings in one file, organized by category
2. **Easy to Update**: Change translation key in one place
3. **Type Safe**: Use constants instead of string literals
4. **No Typos**: IDE autocomplete prevents mistakes
5. **Easy to Translate**: Translators can see all text in one place

## How to Use

### Basic Usage

**OLD WAY** (Hard to manage):
```dart
Text('product_name'.tr)
```

**NEW WAY** (Easy and organized):
```dart
import 'package:green_veg_stock_management/app/core/values/strings.dart';

Text(AppStrings.productName.tr)
```

### In Forms

```dart
StandardTextField(
  label: AppStrings.productName.tr,
  hint: AppStrings.enterProductName.tr,
  controller: controller.nameController,
  validator: (value) => value == null ? AppStrings.fieldRequired.tr : null,
)
```

### In Snackbars

```dart
Get.snackbar(
  AppStrings.success.tr,
  AppStrings.productAddedSuccessfully.tr,
)
```

### In Buttons

```dart
ElevatedButton(
  onPressed: () => save(),
  child: Text(AppStrings.save.tr),
)
```

## How to Add New Strings

1. Open `lib/app/core/values/strings.dart`
2. Find the appropriate section (or create a new one)
3. Add your constant:
```dart
static const String myNewString = 'my_new_string';
```
4. Add translations in `lib/app/translations/app_translations.dart`:
```dart
// Gujarati
'my_new_string': 'મારી નવી સ્ટ્રિંગ',

// English
'my_new_string': 'My New String',
```

## Organization

Strings are organized into logical sections:
- **COMMON WORDS**: save, cancel, delete, etc.
- **AUTHENTICATION**: login, register, password, etc.
- **NAVIGATION**: home, dashboard, products, etc.
- **PRODUCTS**: product-related strings
- **CUSTOMERS**: customer-related strings
- **ORDERS**: order-related strings
- **VALIDATION**: error messages
- **MESSAGES**: success/error messages
- And more...

## Finding Strings

Use your IDE's search (Ctrl+F or Cmd+F) to find strings:
1. Open `strings.dart`
2. Search for keywords like "product", "customer", "order"
3. Find the constant you need

## Migration Guide

To convert existing code:

1. **Find hardcoded strings**:
```dart
// OLD
Text('product_name'.tr)
```

2. **Import strings**:
```dart
import 'package:green_veg_stock_management/app/core/values/strings.dart';
```

3. **Replace with constant**:
```dart
// NEW
Text(AppStrings.productName.tr)
```

## Best Practices

1. **Always use AppStrings**: Never use hardcoded translation keys
2. **Group related strings**: Keep related strings together
3. **Use descriptive names**: `productAddedSuccessfully` not `msg1`
4. **Follow naming convention**: camelCase for constants
5. **Add comments**: Add section comments for clarity

## Example: Complete Form

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_veg_stock_management/app/core/values/strings.dart';

class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title
        Text(AppStrings.addProduct.tr),
        
        // Name field
        StandardTextField(
          label: AppStrings.productName.tr,
          hint: AppStrings.enterProductName.tr,
        ),
        
        // Category dropdown
        StandardDropdown(
          label: AppStrings.category.tr,
          hint: AppStrings.selectCategory.tr,
        ),
        
        // Buttons
        Row(
          children: [
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text(AppStrings.cancel.tr),
            ),
            ElevatedButton(
              onPressed: () => save(),
              child: Text(AppStrings.save.tr),
            ),
          ],
        ),
      ],
    );
  }
  
  void save() {
    Get.snackbar(
      AppStrings.success.tr,
      AppStrings.productAddedSuccessfully.tr,
    );
  }
}
```

## Troubleshooting

**Q: String not translating?**
A: Make sure the translation key exists in `app_translations.dart` for both languages

**Q: IDE not autocompleting?**
A: Make sure you imported: `import 'package:green_veg_stock_management/app/core/values/strings.dart';`

**Q: Want to add a new string?**
A: Add constant in `strings.dart`, then add translations in `app_translations.dart`

## Summary

- ✅ All strings in one place (`strings.dart`)
- ✅ Easy to find and update
- ✅ Type-safe with autocomplete
- ✅ Organized by category
- ✅ No more typos or missing translations
