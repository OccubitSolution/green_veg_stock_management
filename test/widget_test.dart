// GreenVeg widget test
import 'package:flutter_test/flutter_test.dart';
import 'package:green_veg_stock_management/main.dart';

void main() {
  testWidgets('GreenVegApp builds without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GreenVegApp());

    // Verify the app builds successfully
    expect(find.byType(GreenVegApp), findsOneWidget);
  });
}
