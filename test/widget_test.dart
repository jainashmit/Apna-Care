import 'package:flutter_test/flutter_test.dart';
import 'package:apna_ghar/main.dart';
import 'package:apna_ghar/features/platform/data/mock_care_repository.dart';

void main() {
  testWidgets('ApnaCare renders its splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ApnaGharApp());
    // The splash has intentional looping animation, so pumpAndSettle would
    // never finish. Advance only far enough for the app name to animate in.
    await tester.pump(const Duration(milliseconds: 1400));
    expect(find.text('ApnaCare'), findsOneWidget);
  });

  test('mock care tasks can be updated', () async {
    final repository = MockCareRepository();
    expect(repository.tasks.first.isComplete, isFalse);

    await repository.toggleTask(repository.tasks.first.id);

    expect(repository.tasks.first.isComplete, isTrue);
  });
}
