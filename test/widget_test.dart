import 'package:flutter_test/flutter_test.dart';
import 'package:futbol_party/main.dart';

void main() {
  testWidgets('FutbolPartyApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FutbolPartyApp());
    expect(find.text('Futbol Party ⚽'), findsOneWidget);
  });
}
