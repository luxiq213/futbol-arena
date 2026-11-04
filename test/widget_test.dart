import 'package:flutter_test/flutter_test.dart';
import 'package:futbol_party/main.dart';
import 'package:futbol_party/views/home/home_screen.dart';

void main() {
  testWidgets('FutbolPartyApp smoke test and home render', (WidgetTester tester) async {
    await tester.pumpWidget(const FutbolPartyApp());
    await tester.pumpAndSettle();

    // Verify HomeScreen is rendered
    expect(find.byType(HomeScreen), findsOneWidget);
    
    // Verify game modes exist in widget tree
    expect(find.textContaining('Ortak Oyuncu Düellosu'), findsOneWidget);
    expect(find.textContaining('5 Takim 1 Oyuncu'), findsOneWidget);
    expect(find.textContaining('Futbol Grid 3x3'), findsOneWidget);

    // Verify natural footer tabs exist
    expect(find.text('Oyunlar'), findsOneWidget);
    expect(find.text('Sıralama'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
