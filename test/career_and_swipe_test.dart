import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol_party/data/models/career_model.dart';
import 'package:futbol_party/main.dart';
import 'package:futbol_party/providers/career_game_provider.dart';
import 'package:futbol_party/views/profile/profile_screen.dart';

void main() {
  group('CareerGameProvider Logic Tests', () {
    test('Simulates complete football career with 6 stages', () {
      final provider = CareerGameProvider();

      expect(provider.isCareerActive, isFalse);

      provider.startCareer(
        playerName: 'Mehmet Ali',
        position: PlayerPosition.striker,
        region: 'Türkiye',
      );

      expect(provider.isCareerActive, isTrue);
      expect(provider.isCareerFinished, isFalse);
      expect(provider.playerName, 'Mehmet Ali');
      expect(provider.position, PlayerPosition.striker);
      expect(provider.currentAge, 18);
      expect(provider.currentClub, isNotNull);
      expect(provider.currentOffers.length, 2);

      // Play through all 6 stages to jubilee retirement
      for (int i = 0; i < 6; i++) {
        final nextClub = provider.currentOffers.first;
        provider.selectTransferDecision(nextClub);
      }

      // After 6 decisions, career must be finished
      expect(provider.isCareerFinished, isTrue);
      final summary = provider.finalSummary;
      expect(summary, isNotNull);
      expect(summary!.playerName, 'Mehmet Ali');
      expect(summary.totalMatches, greaterThan(150));
      expect(summary.totalGoals, greaterThan(30));
      expect(summary.careerRating, inInclusiveRange(84, 98));
      expect(summary.clubsPlayed.isNotEmpty, isTrue);
      expect(summary.legacyTitle.isNotEmpty, isTrue);
    });
  });

  group('Swipe Navigation & Category Filtering Tests', () {
    testWidgets('Horizontal swipe transitions between Oyunlar, Sıralama, and Profil', (WidgetTester tester) async {
      await tester.pumpWidget(const FutbolPartyApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Initially on Oyunlar tab (Page 0)
      expect(find.text('OYUN MODLARI'), findsOneWidget);
      expect(find.text('Futbolcu Kariyeri Yap'), findsOneWidget);

      // Test tapping footer tabs for direct animated transition
      await tester.tap(find.text('Sıralama'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Genel Siralama'), findsOneWidget);

      await tester.tap(find.text('Profil'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ProfileScreen), findsOneWidget);

      await tester.tap(find.text('Oyunlar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('OYUN MODLARI'), findsOneWidget);

      // Test horizontal fling gesture between screens
      await tester.fling(find.byType(PageView), const Offset(-600, 0), 2000);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Genel Siralama'), findsOneWidget);
    });

    testWidgets('Tapping category filter updates visible game modes', (WidgetTester tester) async {
      await tester.pumpWidget(const FutbolPartyApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Tap "Kariyer" filter
      await tester.tap(find.text('Kariyer'));
      await tester.pump(const Duration(milliseconds: 300));

      // Career hero card is present
      expect(find.text('Futbolcu Kariyeri Yap'), findsOneWidget);

      // Common player duel is filtered out in career view
      expect(find.text('Ortak Oyuncu Düellosu (3-2-1)'), findsNothing);

      // Tap "Tumu" to restore
      await tester.tap(find.text('Tumu'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Ortak Oyuncu Düellosu (3-2-1)'), findsOneWidget);
    });
  });
}
