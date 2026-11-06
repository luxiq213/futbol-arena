import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/models/club_model.dart';
import '../data/models/player_model.dart';
import '../data/models/grid_challenge_model.dart';
import '../data/models/play_mode_model.dart';
import '../data/repositories/football_database.dart';
import '../../core/utils/sound_effects.dart';

enum FiveClubsPhase { playing, evaluatingOpponent, roundSummary }

class FiveClubsGameProvider extends ChangeNotifier {
  final FootballDatabase _db = FootballDatabase();
  final Random _random = Random();

  final PlayModeType playMode;
  final GameDifficulty difficulty;
  final OpponentProfile? opponent;

  late FiveClubsChallenge _currentChallenge;
  FiveClubsPhase _phase = FiveClubsPhase.playing;

  PlayerModel? _userPlayer;
  int _userScore = 0;
  List<ClubModel> _userMatchedClubs = [];

  PlayerModel? _opponentPlayer;
  int _opponentScore = 0;
  List<ClubModel> _opponentMatchedClubs = [];

  String? _feedback;
  int _totalUserPoints = 0;
  int _totalOpponentPoints = 0;
  int _roundsPlayed = 0;

  FiveClubsChallenge get currentChallenge => _currentChallenge;
  FiveClubsPhase get phase => _phase;
  List<ClubModel> get clubs => _currentChallenge.clubs;
  PlayerModel? get userPlayer => _userPlayer;
  int get userScore => _userScore;
  List<ClubModel> get userMatchedClubs => _userMatchedClubs;
  PlayerModel? get opponentPlayer => _opponentPlayer;
  int get opponentScore => _opponentScore;
  List<ClubModel> get opponentMatchedClubs => _opponentMatchedClubs;
  String? get feedback => _feedback;
  int get totalUserPoints => _totalUserPoints;
  int get totalOpponentPoints => _totalOpponentPoints;
  int get roundsPlayed => _roundsPlayed;
  PlayerModel get bestPossible => _currentChallenge.bestAnswer;
  int get maxPossible => _currentChallenge.maxMatchCount;
  bool get isDuelMode => playMode != PlayModeType.solo && opponent != null;

  FiveClubsGameProvider({
    this.playMode = PlayModeType.solo,
    this.difficulty = GameDifficulty.medium,
    this.opponent,
  }) {
    startNewRound();
  }

  void startNewRound() {
    _currentChallenge = _db.getRandom5ClubsChallenge();
    _phase = FiveClubsPhase.playing;
    _userPlayer = null;
    _userScore = 0;
    _userMatchedClubs = [];
    _opponentPlayer = null;
    _opponentScore = 0;
    _opponentMatchedClubs = [];
    _feedback = null;
    notifyListeners();
  }

  /// Submit user's guess for the 5 clubs
  void submitUserGuess(String query) {
    if (query.trim().isEmpty) return;

    final results = _db.searchPlayers(query);
    if (results.isEmpty) {
      _feedback = 'Futbolcu bulunamadı. Lütfen geçerli bir isim girin.';
      GameFeedback.error();
      notifyListeners();
      return;
    }

    final chosen = results.first;
    _userPlayer = chosen;

    // Calculate matches
    _userMatchedClubs = clubs.where((c) => chosen.playedFor(c.id)).toList();
    _userScore = _userMatchedClubs.length;

    if (!isDuelMode) {
      // SOLO MODE (Kendini Sına): Immediate evaluation without any AI opponent
      _roundsPlayed++;
      final earned = (_userScore * 100 * difficulty.pointsMultiplier).round();
      _totalUserPoints += earned;

      if (_userScore >= _currentChallenge.maxMatchCount) {
        GameFeedback.success();
        _feedback = 'MÜKEMMEL! Maksimum kulüp eşleşmesini ($_userScore/5) buldun! (+$earned Puan)';
      } else if (_userScore >= 2) {
        GameFeedback.success();
        _feedback = 'Güzel tahmin! $_userScore kulüp eşleşmesi yakaladın. (+$earned Puan)';
      } else {
        GameFeedback.tick();
        _feedback = '${chosen.name} bu listeden $_userScore kulüpte forma giydi. (+$earned Puan)';
      }

      _phase = FiveClubsPhase.roundSummary;
      notifyListeners();
      return;
    }

    // DUEL MODE (Online Matchmaking / AI Fallback / Friend Invite)
    _phase = FiveClubsPhase.evaluatingOpponent;
    notifyListeners();

    _simulateOpponentTurn();
  }

  void _simulateOpponentTurn() {
    Timer(const Duration(milliseconds: 750), () {
      final allPlayers = _db.getAllPlayers();
      final scoredPlayers = allPlayers.map((p) {
        final score = clubs.where((c) => p.playedFor(c.id)).length;
        return MapEntry(p, score);
      }).where((entry) => entry.value >= 2).toList();

      scoredPlayers.sort((a, b) => b.value.compareTo(a.value));

      if (scoredPlayers.isNotEmpty) {
        final maxIdx = difficulty == GameDifficulty.hard
            ? 2
            : (difficulty == GameDifficulty.medium ? 4 : 6);
        final pickIndex = _random.nextInt(scoredPlayers.length.clamp(1, maxIdx));
        _opponentPlayer = scoredPlayers[pickIndex].key;
        _opponentScore = scoredPlayers[pickIndex].value;
        _opponentMatchedClubs = clubs.where((c) => _opponentPlayer!.playedFor(c.id)).toList();
      }

      _roundsPlayed++;
      final userEarned = (_userScore * 100 * difficulty.pointsMultiplier).round();
      final oppEarned = (_opponentScore * 100 * difficulty.pointsMultiplier).round();
      _totalUserPoints += userEarned;
      _totalOpponentPoints += oppEarned;

      final oppName = opponent?.name ?? 'Rakip';

      if (_userScore > _opponentScore) {
        GameFeedback.success();
        _feedback = 'Tebrikler! $_userScore - $_opponentScore ile $oppName karşısında bu turu kazandın! (+$userEarned Puan)';
      } else if (_userScore == _opponentScore) {
        GameFeedback.tick();
        _feedback = 'Baş başa mücadele! İkiniz de $_userScore kulüp bildiniz. (+$userEarned Puan)';
      } else {
        GameFeedback.explode();
        _feedback = '$oppName $_opponentScore kulüp eşleşmesiyle bu turu önde tamamladı.';
      }

      _phase = FiveClubsPhase.roundSummary;
      notifyListeners();
    });
  }
}
