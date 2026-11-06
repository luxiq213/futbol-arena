import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol_party/data/models/career_model.dart';
import 'package:futbol_party/data/models/play_mode_model.dart';
import 'package:futbol_party/main.dart';
import 'package:futbol_party/providers/career_game_provider.dart';
import 'package:futbol_party/views/profile/profile_screen.dart';

void main() {
  group('CareerGameProvider Logic Tests', () {
    test('Simulates complete football career with 10 slower stages and penalty kicks', () {
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
      expect(provider.currentAge, 17);
      expect(provider.maxStages, 10);
      expect(provider.currentClub, isNotNull);
      expect(provider.currentOffers.length, 2);

      // Play through all 10 stages to jubilee retirement, taking penalty shots along the way
      for (int i = 0; i < provider.maxStages; i++) {
        expect(provider.hasPendingPenalty, isTrue);
        final penResult = provider.takeSeasonPenalty(PenaltyCorner.topLeft);
        expect(penResult, isNotNull);
        expect(provider.hasPendingPenalty, isFalse);

        final nextClub = provider.currentOffers.first;
        provider.selectTransferDecision(nextClub);
      }

      // After 10 decisions, career must be finished
      expect(provider.isCareerFinished, isTrue);
      final summary = provider.finalSummary;
      expect(summary, isNotNull);
      expect(summary!.playerName, 'Mehmet Ali');
      expect(summary.totalMatches, greaterThan(220));
      expect(summary.totalGoals, greaterThan(40));
      expect(summary.penaltiesTaken, 10);
      expect(summary.careerRating, inInclusiveRange(82, 99));
      expect(summary.clubsPlayed.isNotEmpty, isTrue);
      expect(summary.legacyTitle.isNotEmpty, isTrue);
    });

    test('GameDifficulty enum provides expected scaling properties', () {
      expect(GameDifficulty.easy.gridGuessesAllowed, 12);
      expect(GameDifficulty.medium.gridGuessesAllowed, 9);
      expect(GameDifficulty.hard.gridGuessesAllowed, 6);
      expect(GameDifficulty.hard.pointsMultiplier, greaterThan(GameDifficulty.easy.pointsMultiplier));
    });
  });

  group('Swipe Navigation & Category Filtering Tests', () {
    testWidgets('Horizontal swipe transitions between Oyunlar, Sıralama, and Profil', (WidgetTester tester) async {
      await tester.pumpWidget(const FutbolPartyApp());
      await tester.pump(const Duration(milliseconds: 200));

      // Initially on Oyunlar tab (Page 0)
      expect(find.textContaining('OYUN MODLARI'), findsOneWidget);
      expect(find.text('Futbolcu Kariyeri Yap'), findsOneWidget);

      // Test tapping footer tabs for direct animated transition
      await tester.tap(find.text('Sıralama'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Genel Sıralama'), findsOneWidget);

      await tester.tap(find.text('Profil'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ProfileScreen), findsOneWidget);

      await tester.tap(find.text('Oyunlar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.textContaining('OYUN MODLARI'), findsOneWidget);

      // Test horizontal fling gesture between screens
      await tester.fling(find.byType(PageView), const Offset(-600, 0), 2000);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Genel Sıralama'), findsOneWidget);
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

      // Tap "Tümü" to restore
      await tester.tap(find.text('Tümü'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Ortak Oyuncu Düellosu (3-2-1)'), findsOneWidget);
    });
  });
}
