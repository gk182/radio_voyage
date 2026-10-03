import 'package:flutter_test/flutter_test.dart';
import 'package:radio_voyage/main.dart';

void main() {
  testWidgets('RadioVoyage App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RadioVoyageApp());
    expect(find.byType(RadioVoyageApp), findsOneWidget);
  });
}
