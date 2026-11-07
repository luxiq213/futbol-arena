import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/utils/sound_effects.dart';
import '../data/models/club_model.dart';
import '../data/models/play_mode_model.dart';
import '../data/models/player_model.dart';
import '../data/repositories/football_database.dart';

class FootballBridgeGameProvider extends ChangeNotifier {
  final FootballDatabase _db = FootballDatabase();
  final Random _random = Random();

  final PlayModeType playMode;
  final GameDifficulty difficulty;
  final OpponentProfile? opponent;

  BridgeChallenge? _challenge;
  final List<BridgeLink> _userLinks = [];
  bool _isBridgeCompleted = false;
  bool _isRevealed = false;
  int _score = 0;
  int _opponentScore = 0;
  int _hintsUsed = 0;
  String? _lastFeedback;
  bool _isSuccessFeedback = false;

  BridgeChallenge? get challenge => _challenge;
  List<BridgeLink> get userLinks => List.unmodifiable(_userLinks);
  bool get isBridgeCompleted => _isBridgeCompleted;
  bool get isRevealed => _isRevealed;
  int get score => _score;
  int get opponentScore => _opponentScore;
  int get hintsUsed => _hintsUsed;
  String? get lastFeedback => _lastFeedback;
  bool get isSuccessFeedback => _isSuccessFeedback;
  bool get isDuelMode => playMode != PlayModeType.solo && opponent != null;

  PlayerModel? get currentTipPlayer {
    if (_challenge == null) return null;
    if (_userLinks.isEmpty) return _challenge!.startPlayer;
    return _userLinks.last.toPlayer;
  }

  int get intermediateStepsUsed {
    if (_userLinks.isEmpty) return 0;
    if (_isBridgeCompleted) {
      return (_userLinks.length - 1).clamp(1, 20);
    }
    return _userLinks.length;
  }

  FootballBridgeGameProvider({
    this.playMode = PlayModeType.solo,
    this.difficulty = GameDifficulty.medium,
    this.opponent,
  }) {
    startNewRound();
  }

  void startNewRound() {
    _challenge = _db.getRandomBridgeChallenge(difficulty: difficulty);
    _userLinks.clear();
    _isBridgeCompleted = false;
    _isRevealed = false;
    _hintsUsed = 0;
    _lastFeedback = null;
    _isSuccessFeedback = false;
    notifyListeners();
  }

  List<ClubModel> getClubsOf(PlayerModel player) {
    return player.clubIds
        .map((id) => _db.getClub(id))
        .whereType<ClubModel>()
        .toList();
  }

  bool submitStepByQuery(String query) {
    if (query.trim().isEmpty || _challenge == null || _isBridgeCompleted) {
      return false;
    }

    PlayerModel? candidate;
    final allPlayers = _db.getAllPlayers();
    final qLower = query.trim().toLowerCase();

    for (final p in allPlayers) {
      if (p.name.toLowerCase() == qLower ||
          p.aliases.any((a) => a.toLowerCase() == qLower)) {
        candidate = p;
        break;
      }
    }

    if (candidate == null) {
      final hits = _db.searchPlayers(query, limit: 3);
      if (hits.isNotEmpty) {
        candidate = hits.first;
      }
    }

    if (candidate == null) {
      _lastFeedback = '"$query" veritabanında bulunamadı.';
      _isSuccessFeedback = false;
      GameFeedback.error();
      notifyListeners();
      return false;
    }

    return submitStepPlayer(candidate);
  }

  bool submitStepPlayer(PlayerModel candidate) {
    if (_challenge == null || _isBridgeCompleted) return false;

    final start = _challenge!.startPlayer;
    final target = _challenge!.targetPlayer;
    final tip = currentTipPlayer!;

    if (candidate.id == start.id ||
        _userLinks.any((l) => l.toPlayer.id == candidate.id)) {
      _lastFeedback = '${candidate.name} zaten köprü zincirinde yer alıyor!';
      _isSuccessFeedback = false;
      GameFeedback.tick();
      notifyListeners();
      return false;
    }

    if (candidate.id == target.id) {
      final directClub = _db.findSharedClub(tip, target);
      if (directClub != null) {
        _userLinks.add(
          BridgeLink(
            fromPlayer: tip,
            sharedClub: directClub,
            toPlayer: target,
          ),
        );
        _completeBridge(
          closingSummary:
              '${tip.name} ile ${target.name} doğrudan ${directClub.name} üzerinden bağlandı!',
        );
        return true;
      } else {
        _lastFeedback =
            '${tip.name} ile hedef yıldız ${target.name} aynı kulüpte oynamadı! Aradaki ortak bir yıldızı yazmalısın.';
        _isSuccessFeedback = false;
        GameFeedback.error();
        notifyListeners();
        return false;
      }
    }

    // Check if candidate shares a club with current tip
    final sharedWithTip = _db.findSharedClub(tip, candidate);
    if (sharedWithTip == null) {
      _lastFeedback =
          '${candidate.name} ile ${tip.name} kariyerlerinde ortak bir kulüpte oynamadı!';
      _isSuccessFeedback = false;
      GameFeedback.error();
      notifyListeners();
      return false;
    }

    // Valid link from tip -> candidate!
    _userLinks.add(
      BridgeLink(
        fromPlayer: tip,
        sharedClub: sharedWithTip,
        toPlayer: candidate,
      ),
    );

    // Now check if candidate also connects directly to targetPlayer!
    final sharedWithTarget = _db.findSharedClub(candidate, target);
    if (sharedWithTarget != null) {
      _userLinks.add(
        BridgeLink(
          fromPlayer: candidate,
          sharedClub: sharedWithTarget,
          toPlayer: target,
        ),
      );
      _completeBridge(
        closingSummary:
            'KÖPRÜ TAMAMLANDI! ${candidate.name} (${sharedWithTip.name} -> ${sharedWithTarget.name}) üzerinden ${target.name} bağlantısını kurdun!',
      );
      return true;
    }

    // Otherwise candidate is added as an intermediate node; user continues from candidate
    GameFeedback.success();
    _lastFeedback =
        '${candidate.name} (${sharedWithTip.name}) zincire eklendi! Şimdi ${candidate.name} ile ${target.name} arasında köprü kuracak oyuncuyu bul.';
    _isSuccessFeedback = true;

    if (isDuelMode) {
      _simulateOpponentTurn();
    }

    notifyListeners();
    return true;
  }

  void _completeBridge({required String closingSummary}) {
    _isBridgeCompleted = true;
    final optimalIntermediates = _challenge!.optimalIntermediateCount;
    final usedIntermediates = (_userLinks.length - 1).clamp(1, 10);
    final isOptimal = usedIntermediates <= optimalIntermediates;

    final baseReward = isOptimal ? 250 : 160;
    final earned = (baseReward * difficulty.pointsMultiplier).round();
    _score += earned;
    _lastFeedback = '$closingSummary (+$earned Puan)';
    _isSuccessFeedback = true;
    GameFeedback.success();

    if (isDuelMode) {
      _simulateOpponentTurn(userCompleted: true);
    }

    notifyListeners();
  }

  void _simulateOpponentTurn({bool userCompleted = false}) {
    if (!isDuelMode) return;
    if (_random.nextDouble() < difficulty.aiAccuracyChance) {
      final oppEarned = (180 * difficulty.pointsMultiplier).round();
      if (userCompleted) {
        _opponentScore += (oppEarned * 0.6).round();
      } else {
        _opponentScore += (oppEarned * 0.4).round();
      }
    }
  }

  void undoLastStep() {
    if (_userLinks.isEmpty || _isBridgeCompleted) return;
    final removed = _userLinks.removeLast();
    _lastFeedback = '${removed.toPlayer.name} halkası geri alındı.';
    _isSuccessFeedback = false;
    GameFeedback.tick();
    notifyListeners();
  }

  void useHint() {
    if (_challenge == null || _isBridgeCompleted || _hintsUsed >= 2) return;
    _hintsUsed++;
    _score = (_score - 25).clamp(0, 999999);
    GameFeedback.tick();
    notifyListeners();
  }

  String? get currentHintText {
    if (_challenge == null || _hintsUsed == 0) return null;
    final optimal = _challenge!.optimalLinks;
    if (optimal.isEmpty) return null;

    final firstIntermediate = optimal.first.toPlayer;
    final firstClub = optimal.first.sharedClub;
    final lastClub = optimal.last.sharedClub;

    if (_hintsUsed == 1) {
      return '1. İpucu: ${firstClub.name} ve ${lastClub.name} kulüplerinden geçen bir köprü kurabilirsin.';
    }
    return '2. İpucu: Aradaki kilit yıldız (${firstIntermediate.country} • ${firstIntermediate.position}): "${firstIntermediate.hint}"';
  }

  void revealOptimalBridge() {
    if (_challenge == null || _isBridgeCompleted) return;
    _userLinks
      ..clear()
      ..addAll(_challenge!.optimalLinks);
    _isBridgeCompleted = true;
    _isRevealed = true;
    _lastFeedback = 'En kısa optimal köprü açıldı. İnceleyip sonraki tura geçebilirsin.';
    _isSuccessFeedback = false;
    GameFeedback.explode();
    notifyListeners();
  }
}
