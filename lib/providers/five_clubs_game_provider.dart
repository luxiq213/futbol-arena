import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/club_model.dart';
import '../data/models/player_model.dart';
import '../data/models/grid_challenge_model.dart';
import '../data/repositories/football_database.dart';
import '../../core/utils/sound_effects.dart';

enum FiveClubsPhase { playing, evaluating, roundSummary }

class FiveClubsGameProvider extends ChangeNotifier {
  final FootballDatabase _db = FootballDatabase();

  late FiveClubsChallenge _currentChallenge;
  FiveClubsPhase _phase = FiveClubsPhase.playing;

  PlayerModel? _userPlayer;
  int _userScore = 0;
  List<ClubModel> _userMatchedClubs = [];

  PlayerModel? _aiPlayer;
  int _aiScore = 0;
  List<ClubModel> _aiMatchedClubs = [];

  String? _feedback;
  int _totalUserPoints = 0;
  int _roundsPlayed = 0;

  FiveClubsChallenge get currentChallenge => _currentChallenge;
  FiveClubsPhase get phase => _phase;
  List<ClubModel> get clubs => _currentChallenge.clubs;
  PlayerModel? get userPlayer => _userPlayer;
  int get userScore => _userScore;
  List<ClubModel> get userMatchedClubs => _userMatchedClubs;
  PlayerModel? get aiPlayer => _aiPlayer;
  int get aiScore => _aiScore;
  List<ClubModel> get aiMatchedClubs => _aiMatchedClubs;
  String? get feedback => _feedback;
  int get totalUserPoints => _totalUserPoints;
  int get roundsPlayed => _roundsPlayed;
  PlayerModel get bestPossible => _currentChallenge.bestAnswer;
  int get maxPossible => _currentChallenge.maxMatchCount;

  FiveClubsGameProvider() {
    startNewRound();
  }

  void startNewRound() {
    _currentChallenge = _db.getRandom5ClubsChallenge();
    _phase = FiveClubsPhase.playing;
    _userPlayer = null;
    _userScore = 0;
    _userMatchedClubs = [];
    _aiPlayer = null;
    _aiScore = 0;
    _aiMatchedClubs = [];
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

    _phase = FiveClubsPhase.evaluating;
    notifyListeners();

    // Trigger AI response after short delay
    _simulateAiTurn();
  }

  void _simulateAiTurn() {
    Timer(const Duration(milliseconds: 900), () {
      // AI chooses either the optimal answer or a close competitor
      final allPlayers = _db.getAllPlayers();
      final scoredPlayers = allPlayers.map((p) {
        final score = clubs.where((c) => p.playedFor(c.id)).length;
        return MapEntry(p, score);
      }).toList();

      scoredPlayers.sort((a, b) => b.value.compareTo(a.value));

      // AI picks best or second best
      if (scoredPlayers.isNotEmpty) {
        _aiPlayer = scoredPlayers.first.key;
        _aiScore = scoredPlayers.first.value;
        _aiMatchedClubs = clubs.where((c) => _aiPlayer!.playedFor(c.id)).toList();
      }

      _roundsPlayed++;
      final earned = _userScore * 100;
      _totalUserPoints += earned;

      if (_userScore >= _aiScore) {
        GameFeedback.success();
        _feedback = 'Tebrikler! $_userScore kulüp tutturdun. (+$earned Puan)';
      } else {
        GameFeedback.explode();
        _feedback = 'Scout AI $_aiScore kulüp ile bu turu önde tamamladı.';
      }

      _phase = FiveClubsPhase.roundSummary;
      notifyListeners();
    });
  }
}
