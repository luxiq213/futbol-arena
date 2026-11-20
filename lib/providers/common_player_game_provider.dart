import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/models/club_model.dart';
import '../data/models/player_model.dart';
import '../data/models/play_mode_model.dart';
import '../data/repositories/football_database.dart';
import '../../core/utils/sound_effects.dart';

class CommonPlayerGameProvider extends ChangeNotifier {
  final FootballDatabase _db = FootballDatabase();
  final Random _random = Random();

  final PlayModeType playMode;
  final GameDifficulty difficulty;
  final OpponentProfile? opponent;
  CommonPlayerPairMode _pairFormat = CommonPlayerPairMode.clubVsClub;

  ClubModel? _clubA;
  ClubModel? _clubB;
  List<PlayerModel> _mutualPlayers = [];
  final Set<String> _foundPlayerIds = {};
  final Set<String> _foundByOpponentIds = {};

  int _score = 0;
  int _opponentScore = 0;
  int _hintsUsed = 0;
  bool _revealed = false;
  bool _isOpponentThinking = false;
  String? _lastFeedback;
  bool _isSuccessFeedback = false;

  ClubModel? get clubA => _clubA;
  ClubModel? get clubB => _clubB;
  CommonPlayerPairMode get pairFormat => _pairFormat;
  bool get isCurrentRoundClubVsCountry => _clubB?.isNationalTeam ?? false;
  List<PlayerModel> get mutualPlayers => _mutualPlayers;
  Set<String> get foundPlayerIds => _foundPlayerIds;
  Set<String> get foundByOpponentIds => _foundByOpponentIds;
  int get score => _score;
  int get opponentScore => _opponentScore;
  int get hintsUsed => _hintsUsed;
  bool get revealed => _revealed;
  bool get isOpponentThinking => _isOpponentThinking;
  String? get lastFeedback => _lastFeedback;
  bool get isSuccessFeedback => _isSuccessFeedback;
  bool get isDuelMode => playMode != PlayModeType.solo && opponent != null;

  int get totalFound => _foundPlayerIds.length;
  int get totalPossible => _mutualPlayers.length;
  bool get isAllFound => totalPossible > 0 && totalFound == totalPossible;

  CommonPlayerGameProvider({
    this.playMode = PlayModeType.solo,
    this.difficulty = GameDifficulty.medium,
    this.opponent,
    CommonPlayerPairMode pairFormat = CommonPlayerPairMode.clubVsClub,
    ClubModel? initialClubA,
    ClubModel? initialClubB,
  })  : _initialCustomClubA = initialClubA,
        _initialCustomClubB = initialClubB {
    _pairFormat = pairFormat;
    startNewRound();
  }

  ClubModel? _initialCustomClubA;
  ClubModel? _initialCustomClubB;

  void setPairFormat(CommonPlayerPairMode mode) {
    if (_pairFormat == mode) return;
    _pairFormat = mode;
    startNewRound();
  }

  void startNewRound() {
    if (_initialCustomClubA != null && _initialCustomClubB != null) {
      _clubA = _initialCustomClubA;
      _clubB = _initialCustomClubB;
      _initialCustomClubA = null;
      _initialCustomClubB = null;
    } else {
      final pair = _db.getRandomClubPair(
        difficulty: difficulty,
        pairFormat: _pairFormat,
      );
      _clubA = pair.key;
      _clubB = pair.value;
    }
    _mutualPlayers = _db.getMutualPlayers(_clubA!.id, _clubB!.id);
    _foundPlayerIds.clear();
    _foundByOpponentIds.clear();
    _hintsUsed = 0;
    _revealed = false;
    _isOpponentThinking = false;
    _lastFeedback = null;
    notifyListeners();
  }

  /// Make a guess with a player name
  bool submitGuess(String query) {
    if (query.trim().isEmpty || _clubA == null || _clubB == null || _isOpponentThinking) {
      return false;
    }

    // Search within mutual players
    PlayerModel? matched;
    for (final player in _mutualPlayers) {
      if (query.toLowerCase().trim() == player.name.toLowerCase().trim() ||
          player.aliases.any((a) => a.toLowerCase().trim() == query.toLowerCase().trim())) {
        matched = player;
        break;
      }
    }

    // Also check fuzzy if direct exact match wasn't found
    if (matched == null) {
      final searchHits = _db.searchPlayers(query);
      for (final hit in searchHits) {
        if (_mutualPlayers.any((p) => p.id == hit.id)) {
          matched = hit;
          break;
        }
      }
    }

    bool userSucceeded = false;
    final baseReward = (100 * difficulty.pointsMultiplier).round();

    if (matched != null) {
      if (_foundPlayerIds.contains(matched.id)) {
        _lastFeedback = '${matched.name} zaten bulundu!';
        _isSuccessFeedback = false;
        GameFeedback.tick();
        notifyListeners();
        return false;
      }

      _foundPlayerIds.add(matched.id);
      _score += baseReward;
      _lastFeedback = 'Tebrikler! ${matched.name} doğru cevap! (+$baseReward Puan)';
      _isSuccessFeedback = true;
      userSucceeded = true;
      GameFeedback.success();

      if (isAllFound && !isDuelMode) {
        final bonus = (150 * difficulty.pointsMultiplier).round();
        _score += bonus;
        _lastFeedback = isCurrentRoundClubVsCountry
            ? 'MÜKEMMEL! ${_clubA!.name} & ${_clubB!.name} kesişimindeki tüm oyuncuları bildin! (+$bonus Bonus Puan)'
            : 'MÜKEMMEL! İki takımın tüm ortak oyuncularını bildin! (+$bonus Bonus Puan)';
      }
    } else {
      _lastFeedback = isCurrentRoundClubVsCountry
          ? '"$query" ${_clubA!.name} forması giymiş bir ${_clubB!.name} oyuncusu değil!'
          : '"$query" bu iki kulüpte birden oynamadı!';
      _isSuccessFeedback = false;
      GameFeedback.error();
    }

    notifyListeners();

    // If in Duel Mode and there are still unfound mutual players, let opponent make a move
    if (isDuelMode && !isAllFound) {
      _triggerOpponentTurn();
    }

    return userSucceeded;
  }

  void _triggerOpponentTurn() {
    final remaining = _mutualPlayers.where((p) => !_foundPlayerIds.contains(p.id)).toList();
    if (remaining.isEmpty) return;

    _isOpponentThinking = true;
    notifyListeners();

    Timer(const Duration(milliseconds: 650), () {
      _isOpponentThinking = false;
      final currentRemaining = _mutualPlayers.where((p) => !_foundPlayerIds.contains(p.id)).toList();
      if (currentRemaining.isEmpty) {
        notifyListeners();
        return;
      }

      final oppName = opponent?.name ?? 'Rakip';
      final oppReward = (100 * difficulty.pointsMultiplier).round();
      if (_random.nextDouble() < difficulty.aiAccuracyChance) {
        final pick = currentRemaining[_random.nextInt(currentRemaining.length)];
        _foundPlayerIds.add(pick.id);
        _foundByOpponentIds.add(pick.id);
        _opponentScore += oppReward;
        _lastFeedback = '$oppName ortak oyuncu buldu: ${pick.name} (+$oppReward Puan)';
      } else {
        _lastFeedback = '$oppName bu turda ortak oyuncu bulamadı! Sıra sende.';
      }
      notifyListeners();
    });
  }

  void useHint() {
    if (_revealed || isAllFound) return;
    _hintsUsed++;
    _score = (_score - 20).clamp(0, 99999);
    GameFeedback.tick();
    notifyListeners();
  }

  void revealAll() {
    _revealed = true;
    for (final p in _mutualPlayers) {
      _foundPlayerIds.add(p.id);
    }
    GameFeedback.explode();
    notifyListeners();
  }

  void clearFeedback() {
    _lastFeedback = null;
    notifyListeners();
  }
}
