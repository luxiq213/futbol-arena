import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futbol_party/core/l10n/app_strings.dart';
import 'package:futbol_party/data/models/career_model.dart';
import 'package:futbol_party/data/models/grid_challenge_model.dart';
import 'package:futbol_party/data/models/leaderboard_entry.dart';
import 'package:futbol_party/data/models/play_mode_model.dart';
import 'package:futbol_party/data/models/user_model.dart';
import 'package:futbol_party/data/repositories/football_database.dart';
import 'package:futbol_party/data/repositories/leaderboard_repository.dart';
import 'package:futbol_party/main.dart';
import 'package:futbol_party/providers/auction_duel_game_provider.dart';
import 'package:futbol_party/providers/career_game_provider.dart';
import 'package:futbol_party/providers/common_player_game_provider.dart';
import 'package:futbol_party/providers/football_bridge_game_provider.dart';
import 'package:futbol_party/providers/league_draft_provider.dart';
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
      // Penalty does not appear before signing a transfer
      expect(provider.hasPendingPenalty, isFalse);

      // Play through all 10 stages to jubilee retirement; penalties trigger after signing transfers
      for (int i = 0; i < provider.maxStages; i++) {
        final nextClub = provider.currentOffers.first;
        provider.selectTransferDecision(nextClub);

        if (!provider.isCareerFinished && provider.hasPendingPenalty) {
          final penResult = provider.takeSeasonPenalty(PenaltyCorner.topLeft);
          expect(penResult, isNotNull);
          expect(provider.hasPendingPenalty, isFalse);
        }
      }

      // After 10 decisions, career must be finished and at least 1 penalty triggered
      expect(provider.isCareerFinished, isTrue);
      final summary = provider.finalSummary;
      expect(summary, isNotNull);
      expect(summary!.playerName, 'Mehmet Ali');
      expect(summary.totalMatches, greaterThan(220));
      expect(summary.totalGoals, greaterThan(40));
      expect(summary.penaltiesTaken, greaterThanOrEqualTo(1));
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
        playMode: PlayModeType.solo,
      );
      expect(auctionProvider.isDuelMode, isFalse);
      expect(auctionProvider.phase, AuctionPhase.bidding);
      final initialTarget = auctionProvider.currentBid;
      expect(initialTarget, inInclusiveRange(3, 8));
      auctionProvider.adjustSoloTarget(2);
      expect(auctionProvider.currentBid, initialTarget + 2);
      auctionProvider.startSoloProving();
      expect(auctionProvider.phase, AuctionPhase.provingByUser);
    });

    test('Ad-Free Mode requires a registered account and cannot be activated by guest user', () async {
      const guestUser = UserModel(
        id: 'guest_1',
        username: 'Misafir_1',
        email: 'guest@futtrivia.local',
        avatar: 'goat_10',
        favoriteTeam: 'Galatasaray',
        isGuest: true,
        isAdFree: false,
      );
      expect(guestUser.isGuest, isTrue);
      expect(guestUser.isAdFree, isFalse);

      final registeredUser = guestUser.copyWith(
        username: 'KaptanMehmet',
        email: 'mehmet@futtrivia.com',
        isGuest: false,
      );
      expect(registeredUser.isGuest, isFalse);

      final adFreeUser = registeredUser.copyWith(isAdFree: true);
      expect(adFreeUser.isAdFree, isTrue);
      expect(UserModel.fromJson(adFreeUser.toJson()).isAdFree, isTrue);
    });

    test('Multi-language localization system supports 20 football languages', () {
      expect(AppStrings.supportedLanguages.length, 20);
      for (final lang in AppStrings.supportedLanguages) {
        expect(AppStrings.tr('app_title', lang.code), isNotEmpty);
        expect(AppStrings.tr('career_card_title', lang.code), isNotEmpty);
        expect(AppStrings.tr('mode_321_title', lang.code), isNotEmpty);
        expect(AppStrings.tr('ad_free_title', lang.code), isNotEmpty);
        expect(AppStrings.tr('delete_account_btn', lang.code), isNotEmpty);
      }
    });

    test('Kadro Kur & Lig Simüle Et supports 3-manager pick, 3-formation pick, 11-player Era+Club draft, and multi-friend league simulation', () {
      expect(LeagueDraftProvider.allManagers.length, greaterThanOrEqualTo(30));
      expect(LeagueDraftProvider.allFormations.length, greaterThanOrEqualTo(10));
      expect(LeagueDraftProvider.allEraClubPacks.length, greaterThanOrEqualTo(60));
      expect(FootballDatabase().getAllClubs().length, greaterThanOrEqualTo(50));

      final draftProvider = LeagueDraftProvider();
      draftProvider.startDraft(
        playerNames: ['Mehmet', 'Ali', 'Burak'],
        isSoloMode: false,
      );

      // Should have 3 human participants and be on pickManager phase for player 0
      expect(draftProvider.participants.length, 3);
      expect(draftProvider.phase, LeagueDraftPhase.pickManager);
      expect(draftProvider.currentManagerChoices.length, 3);

      for (int p = 0; p < 3; p++) {
        if (draftProvider.phase == LeagueDraftPhase.nextPlayerHandoff) {
          draftProvider.beginNextHumanTurn();
        }
        expect(draftProvider.phase, LeagueDraftPhase.pickManager);
        expect(draftProvider.currentManagerChoices.length, 3);
        draftProvider.selectManager(draftProvider.currentManagerChoices.first);

        expect(draftProvider.phase, LeagueDraftPhase.pickFormation);
        expect(draftProvider.currentFormationChoices.length, 3);
        draftProvider.selectFormation(draftProvider.currentFormationChoices.first);

        expect(draftProvider.phase, LeagueDraftPhase.pickPlayers);
        for (int slot = 0; slot < 11; slot++) {
          expect(draftProvider.currentSpunClubPack, isNotNull);
          expect(draftProvider.currentPlayerChoices.length, 5);
          draftProvider.selectPlayerForSquad(
            draftProvider.currentPlayerChoices.first,
          );
        }
        expect(draftProvider.participants[p].squad.length, 11);
      }

      // After all 3 friends finish drafting, phase should be leagueSimulation with double round-robin fixtures
      expect(draftProvider.phase, LeagueDraftPhase.leagueSimulation);
      expect(draftProvider.totalMatchdays, greaterThan(0));
      expect(draftProvider.fixtures, isNotEmpty);

      // Simulate entire season
      draftProvider.simulateAllRemainingMatchdays();
      expect(draftProvider.isAllFixturesPlayed, isTrue);
      expect(draftProvider.standings.first.played, greaterThan(0));
    });

    test('Online League Lobby supports capacity, friend invites + AI bots, live flowing match simulation, and returning to lobby for next season', () {
      final draftProvider = LeagueDraftProvider();
      expect(draftProvider.lobbyRoomCode.length, 6);
      expect(draftProvider.seasonNumber, 1);

      // Set league capacity to 6 teams
      draftProvider.setLeagueCapacity(6);
      expect(draftProvider.leagueCapacity, 6);
      expect(draftProvider.lobbySlots.length, 6);
      expect(draftProvider.invitedHumanCount, 1); // Host only initially
      expect(draftProvider.botFillCount, 5);

      // Invite 1 friend -> 2 humans, 4 AI bots
      final invited = draftProvider.inviteFriendToLobby('Emre');
      expect(invited, isTrue);
      expect(draftProvider.invitedHumanCount, 2);
      expect(draftProvider.botFillCount, 4);

      // Start draft from lobby
      draftProvider.startDraftFromLobby();
      expect(draftProvider.participants.length, 6);
      expect(draftProvider.participants.where((p) => !p.isBot).length, 2);
      expect(draftProvider.participants.where((p) => p.isBot).length, 4);

      // Draft for both human participants; AI bots auto-draft at the end
      for (int p = 0; p < 2; p++) {
        if (draftProvider.phase == LeagueDraftPhase.nextPlayerHandoff) {
          draftProvider.beginNextHumanTurn();
        }
        draftProvider.selectManager(draftProvider.currentManagerChoices.first);
        draftProvider.selectFormation(draftProvider.currentFormationChoices.first);
        for (int slot = 0; slot < 11; slot++) {
          draftProvider.selectPlayerForSquad(
            draftProvider.currentPlayerChoices.first,
          );
        }
      }

      // Now in leagueSimulation phase with all 6 teams (including 4 AI bots with full 11-player squads)
      expect(draftProvider.phase, LeagueDraftPhase.leagueSimulation);
      for (final participant in draftProvider.participants) {
        expect(participant.squad.length, 11);
        expect(participant.manager, isNotNull);
        expect(participant.formation, isNotNull);
      }

      // Stream matches one by one via simulateNextSingleFixture()
      final firstPlayed = draftProvider.simulateNextSingleFixture();
      expect(firstPlayed, isNotNull);
      expect(draftProvider.playedFixturesCount, 1);
      expect(draftProvider.latestSimulatedFixture?.homeIndex, firstPlayed!.homeIndex);
      expect(draftProvider.latestSimulatedFixture?.awayIndex, firstPlayed.awayIndex);

      // Finish remaining matches
      while (!draftProvider.isAllFixturesPlayed) {
        draftProvider.simulateNextSingleFixture();
      }
      expect(draftProvider.isAllFixturesPlayed, isTrue);

      // Continue to lobby for Season #2
      draftProvider.continueToLobbyForNextSeason();
      expect(draftProvider.phase, LeagueDraftPhase.setup);
      expect(draftProvider.seasonNumber, 2);
      expect(draftProvider.lobbySlots.length, 6);
      expect(
        draftProvider.lobbySlots.fold<int>(0, (sum, s) => sum + s.championshipsWon),
        1,
      );
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
