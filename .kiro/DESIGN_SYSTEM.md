# Design System Documentation

## Overview
This design system ensures consistency across the entire Grocery Broker application. All pages should follow these patterns and use the standard components.

## Core Principles

1. **Consistency**: Same patterns everywhere
2. **Simplicity**: Minimal, clean design
3. **Accessibility**: Clear labels, good contrast
4. **Responsiveness**: Works on all screen sizes
5. **Professional**: Enterprise-grade appearance

## Layout Patterns

### 1. Standard Page Layout
Use `StandardPageLayout` for list/view pages:
- Gradient header with title
- Optional back button
- Optional action buttons
- Refresh support
- Floating action button support

```dart
StandardPageLayout(
  title: 'page_title'.tr,
  showBackButton: true,
  onRefresh: () => controller.refresh(),
  body: ListView(...),
  floatingActionButton: FloatingActionButton(...),
)
```

### 2. Form Page Layout
Use `FormPageLayout` for create/edit pages:
- Gradient header with close button
- Scrollable form area
- Fixed bottom bar with Cancel/Save buttons
- Loading state handling

```dart
FormPageLayout(
  title: 'add_item'.tr,
  isLoading: controller.isLoading.value,
  onSave: () => controller.save(),
  form: Column(
    children: [
      StandardTextField(...),
      StandardDropdown(...),
    ],
  ),
)
```

## Form Components

### StandardTextField
Consistent text input with label, validation, and styling:
```dart
StandardTextField(
  label: 'field_name'.tr,
  hint: 'enter_value'.tr,
  controller: controller.nameController,
  validator: (value) => controller.validateRequired(value),
  keyboardType: TextInputType.text,
)
```

### StandardDropdown
Consistent dropdown with label and validation:
```dart
StandardDropdown<Category>(
  label: 'category'.tr,
  value: controller.selectedCategory.value,
  items: controller.categories,
  itemLabel: (cat) => cat.getName(lang),
  onChanged: (val) => controller.selectedCategory.value = val,
  validator: (val) => val == null ? 'required'.tr : null,
)
```

### StandardSwitch
Toggle with label and subtitle:
```dart
StandardSwitch(
  label: 'is_active'.tr,
  subtitle: 'enable_or_disable'.tr,
  value: controller.isActive.value,
  onChanged: (val) => controller.isActive.value = val,
)
```

### StandardImagePicker
Image selection with preview:
```dart
StandardImagePicker(
  label: 'product_image'.tr,
  imagePath: controller.selectedImagePath.value,
  onTap: () => controller.pickImage(),
  onClear: () => controller.selectedImagePath.value = null,
)
```

## Card Components

### StandardCard
Basic card container:
```dart
StandardCard(
  onTap: () => onItemTap(),
  child: Row(...),
)
```

### InfoCard
Card with icon, title, and value:
```dart
InfoCard(
  icon: Icons.shopping_cart,
  title: 'total_orders'.tr,
  value: '125',
  color: AppTheme.primaryColor,
  onTap: () => viewOrders(),
)
```

### StatCard
Dashboard metric card:
```dart
StatCard(
  icon: Icons.inventory,
  label: 'products'.tr,
  value: '45',
  color: AppTheme.primaryColor,
)
```

### EmptyStateCard
Empty list placeholder:
```dart
EmptyStateCard(
  icon: Icons.inbox,
  title: 'no_items'.tr,
  message: 'add_first_item'.tr,
  actionLabel: 'add_item'.tr,
  onAction: () => addItem(),
)
```

## Spacing System

Use consistent spacing values from `AppTheme`:
- `AppTheme.spacingXS` = 4px
- `AppTheme.spacingSM` = 8px
- `AppTheme.spacingMD` = 16px
- `AppTheme.spacingLG` = 24px
- `AppTheme.spacingXL` = 32px

## Color System

### Primary Colors
- `AppTheme.primaryColor` - Main brand color
- `AppTheme.primaryDark` - Darker variant
- `AppTheme.primaryGradient` - Gradient for headers

### Semantic Colors
- `AppTheme.success` - Success states
- `AppTheme.error` - Error states
- `AppTheme.warning` - Warning states
- `AppTheme.info` - Info states

### Text Colors
- `AppTheme.textPrimaryLight` - Primary text
- `AppTheme.textSecondaryLight` - Secondary text

## Typography

### Headers
- Page title: 20px, bold, white (in gradient header)
- Section header: 18px, bold, textPrimaryLight
- Card title: 16px, semibold, textPrimaryLight

### Body Text
- Primary: 14px, regular, textPrimaryLight
- Secondary: 12px, regular, grey[600]
- Value/Metric: 18-20px, bold, textPrimaryLight

## Button Styles

### Primary Button
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryColor,
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('action'.tr),
)
```

### Secondary Button
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: AppTheme.primaryColor),
    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('action'.tr),
)
```

## Border Radius

Use consistent border radius:
- Cards: 12px
- Buttons: 12px
- Input fields: 12px
- Header: 24px (bottom only)

## Migration Guide

### Converting Existing Pages

1. **Replace custom headers** with `StandardPageLayout` or `FormPageLayout`
2. **Replace custom text fields** with `StandardTextField`
3. **Replace custom dropdowns** with `StandardDropdown`
4. **Replace custom cards** with `StandardCard` or specific card types
5. **Use consistent spacing** from `AppTheme`
6. **Use consistent colors** from `AppTheme`

### Example Migration

Before:
```dart
Scaffold(
  appBar: AppBar(title: Text('Products')),
  body: ListView(...),
)
```

After:
```dart
StandardPageLayout(
  title: 'products'.tr,
  body: ListView(...),
  onRefresh: () => controller.refresh(),
)
```

## Checklist for New Pages

- [ ] Use `StandardPageLayout` or `FormPageLayout`
- [ ] Use standard form components
- [ ] Use standard card components
- [ ] Use `AppTheme` spacing constants
- [ ] Use `AppTheme` colors
- [ ] Use `.tr` for all text
- [ ] Add loading states
- [ ] Add empty states
- [ ] Add error handling
- [ ] Test on different screen sizes

## Benefits

1. **Faster Development**: Reuse components instead of rebuilding
2. **Consistency**: Same look and feel everywhere
3. **Maintainability**: Change once, update everywhere
4. **Professional**: Enterprise-grade appearance
5. **Accessibility**: Built-in best practices
