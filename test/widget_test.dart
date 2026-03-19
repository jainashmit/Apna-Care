import 'package:flutter_test/flutter_test.dart';
import 'package:apna_ghar/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ApnaGharApp());
    await tester.pumpAndSettle();
  });
}
