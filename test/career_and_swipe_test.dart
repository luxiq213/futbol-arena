import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol_party/data/models/career_model.dart';
import 'package:futbol_party/data/models/grid_challenge_model.dart';
import 'package:futbol_party/data/models/leaderboard_entry.dart';
import 'package:futbol_party/data/models/play_mode_model.dart';
import 'package:futbol_party/data/repositories/football_database.dart';
import 'package:futbol_party/data/repositories/leaderboard_repository.dart';
import 'package:futbol_party/main.dart';
import 'package:futbol_party/providers/auction_duel_game_provider.dart';
import 'package:futbol_party/providers/career_game_provider.dart';
import 'package:futbol_party/providers/common_player_game_provider.dart';
import 'package:futbol_party/providers/football_bridge_game_provider.dart';
import 'package:futbol_party/views/profile/profile_screen.dart';
import 'package:futbol_party/views/widgets/player_avatar_widget.dart';

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

    test('All 3x3 Grid challenges (Trophies, Nationalities, Clubs) have valid intersections', () {
      final db = FootballDatabase();
      final challenges = db.getGridChallenges(theme: GridThemeType.mixed);
      expect(challenges.length, greaterThanOrEqualTo(8));

      for (final ch in challenges) {
        for (int r = 0; r < 3; r++) {
          for (int c = 0; c < 3; c++) {
            final validPlayers = db.getValidPlayersForCell(ch.rowCriteria[r], ch.colCriteria[c]);
            expect(
              validPlayers,
              isNotEmpty,
              reason: 'Grid "${ch.title}" cell (${ch.rowCriteria[r].label} x ${ch.colCriteria[c].label}) has 0 valid players!',
            );
          }
        }
      }
    });

    test('LeaderboardRepository supports mode-specific rankings and preset avatars resolve', () {
      final repo = LeaderboardRepository();
      for (final cat in LeaderboardModeCategory.values) {
        final list = repo.getRankings(currentUser: null, category: cat, friendsOnly: false);
        expect(list, isNotEmpty);
        final preset = PlayerAvatarRegistry.resolve(list.first.avatar);
        expect(preset.name, isNotEmpty);
      }
    });

    test('3-2-1 Common Player supports both Takım x Takım and Takım x Ülke modes', () {
      final db = FootballDatabase();

      // Verify Club x Country pairs exist and return valid mutual players
      final clubCountryPairs = db.getValidClubCountryPairs();
      expect(clubCountryPairs.length, greaterThanOrEqualTo(40));

      final fbBrazil = db.getMutualPlayers('fenerbahce', 'nat_brezilya');
      expect(fbBrazil, isNotEmpty);
      expect(fbBrazil.any((p) => p.id == 'alex_de_souza'), isTrue);

      // Verify CommonPlayerGameProvider works in both modes
      final provider = CommonPlayerGameProvider(
        pairFormat: CommonPlayerPairMode.clubVsCountry,
      );
      expect(provider.pairFormat, CommonPlayerPairMode.clubVsCountry);
      expect(provider.isCurrentRoundClubVsCountry, isTrue);
      expect(provider.clubA!.isNationalTeam, isFalse);
      expect(provider.clubB!.isNationalTeam, isTrue);
      expect(provider.mutualPlayers, isNotEmpty);

      // Guess the first valid player in Club x Country mode
      final targetPlayer = provider.mutualPlayers.first;
      final success = provider.submitGuess(targetPlayer.name);
      expect(success, isTrue);
      expect(provider.foundPlayerIds.contains(targetPlayer.id), isTrue);

      // Switch to Club x Club mode dynamically
      provider.setPairFormat(CommonPlayerPairMode.clubVsClub);
      expect(provider.pairFormat, CommonPlayerPairMode.clubVsClub);
      expect(provider.isCurrentRoundClubVsCountry, isFalse);
      expect(provider.clubB!.isNationalTeam, isFalse);
      expect(provider.mutualPlayers, isNotEmpty);
    });

    test('Futbol Köprüsü (Six Degrees) builds valid club bridges and completes chain', () {
      final db = FootballDatabase();
      final challenges = db.getBridgeChallenges();
      expect(challenges, isNotEmpty);

      for (final ch in challenges) {
        expect(ch.optimalLinks, isNotEmpty);
        expect(ch.optimalLinks.first.fromPlayer.id, ch.startPlayer.id);
        expect(ch.optimalLinks.last.toPlayer.id, ch.targetPlayer.id);
      }

      final bridgeProvider = FootballBridgeGameProvider(
        difficulty: GameDifficulty.easy,
      );
      final ch = bridgeProvider.challenge!;
      expect(bridgeProvider.isBridgeCompleted, isFalse);

      // Walk through the optimal intermediate players
      for (int i = 0; i < ch.optimalLinks.length - 1; i++) {
        final stepPlayer = ch.optimalLinks[i].toPlayer;
        final ok = bridgeProvider.submitStepPlayer(stepPlayer);
        expect(ok, isTrue);
      }

      expect(bridgeProvider.isBridgeCompleted, isTrue);
      expect(bridgeProvider.score, greaterThan(0));
    });

    test('Açık Artırma Düellosu (Auction Duel) supports bidding and proving categories', () {
      final db = FootballDatabase();
      final categories = db.getAuctionCategories();
      expect(categories.length, greaterThanOrEqualTo(10));
      for (final cat in categories) {
        expect(cat.validPlayers.length, greaterThanOrEqualTo(5));
      }

      final auctionProvider = AuctionDuelGameProvider(
        difficulty: GameDifficulty.medium,
      );
      expect(auctionProvider.phase, AuctionPhase.bidding);
      expect(auctionProvider.currentBid, 2);
      expect(auctionProvider.canUserCallProve, isTrue);
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

    testWidgets('Home screen displays all game modes directly without category filter pills', (WidgetTester tester) async {
      await tester.pumpWidget(const FutbolPartyApp());
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Futbolcu Kariyeri Yap'), findsOneWidget);
      expect(find.text('Ortak Oyuncu (3-2-1)'), findsOneWidget);
      expect(find.text('5 Takım 1 Oyuncu'), findsOneWidget);
      expect(find.text('Futbol Köprüsü'), findsOneWidget);
      expect(find.text('Açık Artırma Düellosu'), findsOneWidget);
    });
  });
}
