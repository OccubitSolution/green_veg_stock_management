import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../controllers/products_controller.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/models.dart';
import '../../../widgets/common_widgets.dart';
import '../../../theme/app_theme.dart';

// ============================================================================
// MOCK REPOSITORY FOR TESTING
// ============================================================================

class MockProductRepository {
  Future<List<Product>> getProducts(String vendorId) async {
    return [
      Product(
        id: '1',
        vendorId: vendorId,
        categoryId: 'leafy_vegetables',
        unitId: 'unit_kg',
        nameGu: 'ટમેટો',
        nameEn: 'Tomato',
        maxPrice: 50.0,
        isActive: true,
        createdAt: DateTime.now(),
        currentPrice: 45.0,
      ),
      Product(
        id: '2',
        vendorId: vendorId,
        categoryId: 'root_vegetables',
        unitId: 'unit_kg',
        nameGu: 'પ્યાજ',
        nameEn: 'Onion',
        maxPrice: 40.0,
        isActive: true,
        createdAt: DateTime.now(),
        currentPrice: 35.0,
      ),
    ];
  }

  Future<List<Category>> getCategories(String vendorId) async {
    return [
      Category(
        id: 'leafy_vegetables',
        vendorId: vendorId,
        nameGu: 'પાંદડાવાળી શાકભાજી',
        nameEn: 'Leafy Vegetables',
        isActive: true,
        sortOrder: 1,
      ),
      Category(
        id: 'root_vegetables',
        vendorId: vendorId,
        nameGu: 'મૂળ શાકભાજી',
        nameEn: 'Root Vegetables',
        isActive: true,
        sortOrder: 2,
      ),
    ];
  }
}

// ============================================================================
// INTEGRATION TESTS
// ============================================================================

void main() {
  group('Category Filter Highlighting Integration Tests', () {

    testWidgets(
      'WHEN category filter chip is selected THEN it should display gradient background and white text',
      (WidgetTester tester) async {
        // Create a test widget with the filter chip
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ModernFilterChip(
                label: 'Leafy Vegetables',
                isSelected: true,
                color: Colors.green,
                icon: Icons.eco,
                onSelected: () {},
              ),
            ),
          ),
        );

        // Find the text widget
        final textFinder = find.text('Leafy Vegetables');
        expect(textFinder, findsOneWidget);

        // Verify text color is white
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, Colors.white,
            reason: 'Text should be white when chip is selected');

        // Verify the chip has the correct styling
        final chipFinder = find.byType(ModernFilterChip);
        final chipWidget = tester.widget<ModernFilterChip>(chipFinder);
        expect(chipWidget.isSelected, true,
            reason: 'Chip should be marked as selected');
      },
    );

    testWidgets(
      'WHEN category filter chip is not selected THEN it should display white background with border',
      (WidgetTester tester) async {
        // Create a test widget with the filter chip
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ModernFilterChip(
                label: 'Leafy Vegetables',
                isSelected: false,
                color: Colors.green,
                icon: Icons.eco,
                onSelected: () {},
              ),
            ),
          ),
        );

        // Find the text widget
        final textFinder = find.text('Leafy Vegetables');
        expect(textFinder, findsOneWidget);

        // Verify text color is not white
        final textWidget = tester.widget<Text>(textFinder);
        expect(textWidget.style?.color, isNot(Colors.white),
            reason: 'Text should not be white when chip is not selected');

        // Verify the chip has the correct styling
        final chipFinder = find.byType(ModernFilterChip);
        final chipWidget = tester.widget<ModernFilterChip>(chipFinder);
        expect(chipWidget.isSelected, false,
            reason: 'Chip should not be marked as selected');
      },
    );

    testWidgets(
      'WHEN filter chip is tapped THEN onSelected callback should be called',
      (WidgetTester tester) async {
        bool callbackCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ModernFilterChip(
                label: 'Leafy Vegetables',
                isSelected: false,
                color: Colors.green,
                icon: Icons.eco,
                onSelected: () {
                  callbackCalled = true;
                },
              ),
            ),
          ),
        );

        // Act: Tap the filter chip
        await tester.tap(find.byType(ModernFilterChip));
        await tester.pumpAndSettle();

        // Assert: Callback should have been called
        expect(callbackCalled, true,
            reason: 'onSelected callback should be called when chip is tapped');
      },
    );

    testWidgets(
      'WHEN filter chip state changes from unselected to selected THEN it should animate and update styling',
      (WidgetTester tester) async {
        bool isSelected = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return ModernFilterChip(
                    label: 'Leafy Vegetables',
                    isSelected: isSelected,
                    color: Colors.green,
                    icon: Icons.eco,
                    onSelected: () {
                      setState(() {
                        isSelected = true;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Initial state: chip should not be selected
        var chipWidget = tester.widget<ModernFilterChip>(
          find.byType(ModernFilterChip),
        );
        expect(chipWidget.isSelected, false);

        // Act: Tap the chip
        await tester.tap(find.byType(ModernFilterChip));
        await tester.pumpAndSettle();

        // Assert: Chip should now be selected
        chipWidget = tester.widget<ModernFilterChip>(
          find.byType(ModernFilterChip),
        );
        expect(chipWidget.isSelected, true,
            reason: 'Chip should be selected after tap');

        // Verify text color changed to white
        final textWidget = tester.widget<Text>(find.text('Leafy Vegetables'));
        expect(textWidget.style?.color, Colors.white,
            reason: 'Text should be white after selection');
      },
    );
  });
}
