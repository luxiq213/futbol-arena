import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/utils/sound_effects.dart';
import '../data/models/play_mode_model.dart';
import '../data/models/player_model.dart';
import '../data/repositories/football_database.dart';

enum AuctionPhase {
  bidding,
  provingByUser,
  provingByOpponent,
  roundSummary,
}

enum BidHolder {
  user,
  opponent,
}

class AuctionDuelGameProvider extends ChangeNotifier {
  final FootballDatabase _db = FootballDatabase();
  final Random _random = Random();

  final PlayModeType playMode;
  final GameDifficulty difficulty;
  late final OpponentProfile effectiveOpponent;

  AuctionCategory? _category;
  AuctionPhase _phase = AuctionPhase.bidding;
  BidHolder _bidHolder = BidHolder.opponent;

  int _currentBid = 2;
  int _opponentMaxCap = 4;
  bool _isWaitingOpponentBid = false;
  final List<String> _bidLog = [];

  final List<PlayerModel> _foundPlayers = [];
  int _proveSecondsLeft = 30;
  Timer? _proveTimer;
  Timer? _aiActionTimer;

  int _score = 0;
  int _opponentScore = 0;
  bool _didUserWinRound = false;
  String _roundSummaryTitle = '';
  String _roundSummarySubtitle = '';
  String? _lastFeedback;
  bool _isSuccessFeedback = false;

  bool get isDuelMode => playMode != PlayModeType.solo;

  AuctionCategory? get category => _category;
  AuctionPhase get phase => _phase;
  BidHolder get bidHolder => _bidHolder;
  int get currentBid => _currentBid;
  bool get isWaitingOpponentBid => _isWaitingOpponentBid;
  List<String> get bidLog => List.unmodifiable(_bidLog);
  List<PlayerModel> get foundPlayers => List.unmodifiable(_foundPlayers);
  int get proveSecondsLeft => _proveSecondsLeft;
  int get score => _score;
  int get opponentScore => _opponentScore;
  bool get didUserWinRound => _didUserWinRound;
  String get roundSummaryTitle => _roundSummaryTitle;
  String get roundSummarySubtitle => _roundSummarySubtitle;
  String? get lastFeedback => _lastFeedback;
  bool get isSuccessFeedback => _isSuccessFeedback;

  int get maxPossibleBid => (_category?.validPlayers.length ?? 10).clamp(3, 15);
  bool get canUserRaise =>
      _phase == AuctionPhase.bidding &&
      !_isWaitingOpponentBid &&
      _currentBid < maxPossibleBid;
  bool get canUserCallProve =>
      isDuelMode &&
      _phase == AuctionPhase.bidding &&
      !_isWaitingOpponentBid &&
      _bidHolder == BidHolder.opponent;

  AuctionDuelGameProvider({
    this.playMode = PlayModeType.solo,
    this.difficulty = GameDifficulty.medium,
    OpponentProfile? opponent,
  }) {
    effectiveOpponent =
        opponent ?? OpponentProfile.randomAiRival(difficulty: difficulty);
    startNewRound();
  }

  void startNewRound() {
    _proveTimer?.cancel();
    _aiActionTimer?.cancel();

    _category = _db.getRandomAuctionCategory();
    _phase = AuctionPhase.bidding;
    _isWaitingOpponentBid = false;
    _foundPlayers.clear();
    _lastFeedback = null;
    _isSuccessFeedback = false;

    if (!isDuelMode) {
      // Solo "Kendini Sına" mode: No AI opponent! User picks their own target and proves it.
      _bidHolder = BidHolder.user;
      _currentBid = 5.clamp(1, maxPossibleBid);
      _bidLog.clear();
      notifyListeners();
      return;
    }

    _bidHolder = BidHolder.opponent;
    _currentBid = 2;

    switch (difficulty) {
      case GameDifficulty.easy:
        _opponentMaxCap = 3 + _random.nextInt(3); // 3..5
        break;
      case GameDifficulty.medium:
        _opponentMaxCap = 4 + _random.nextInt(3); // 4..6
        break;
      case GameDifficulty.hard:
        _opponentMaxCap = 5 + _random.nextInt(4); // 5..8
        break;
    }
    _opponentMaxCap = _opponentMaxCap.clamp(3, maxPossibleBid - 1);

    _bidLog
      ..clear()
      ..add(
        '${effectiveOpponent.name}: "Açılışı yapıyorum, ben $_currentBid futbolcu sayarım!"',
      );
    notifyListeners();
  }

  /// In Solo "Kendini Sına" mode, user adjusts their target claim before starting timer
  void adjustSoloTarget(int delta) {
    if (_phase != AuctionPhase.bidding) return;
    _currentBid = (_currentBid + delta).clamp(1, maxPossibleBid);
    GameFeedback.tick();
    notifyListeners();
  }

  /// In Solo "Kendini Sına" mode, user starts proving their target claim against the clock
  void startSoloProving() {
    if (_phase != AuctionPhase.bidding) return;
    _startProvingByUser();
  }

  /// User raises the bid by [delta] (+1 or +2)
  void userRaiseBid(int delta) {
    if (!isDuelMode) {
      adjustSoloTarget(delta);
      return;
    }
    if (!canUserRaise) return;
    _currentBid = (_currentBid + delta).clamp(1, maxPossibleBid);
    _bidHolder = BidHolder.user;
    _bidLog.add('Sen: "Artırıyorum! Ben $_currentBid futbolcu sayarım!"');
    _isWaitingOpponentBid = true;
    GameFeedback.tick();
    notifyListeners();

    _aiActionTimer?.cancel();
    _aiActionTimer = Timer(const Duration(milliseconds: 550), () {
      _processOpponentResponseToUserBid();
    });
  }

  void _processOpponentResponseToUserBid() {
    _isWaitingOpponentBid = false;
    final shouldCallProve =
        _currentBid >= _opponentMaxCap || _currentBid >= maxPossibleBid;

    if (shouldCallProve) {
      _bidLog.add(
        '${effectiveOpponent.name}: "KANITLA! Say bakalım $_currentBid futbolcuyu!"',
      );
      _startProvingByUser();
    } else {
      _currentBid = (_currentBid + 1).clamp(1, maxPossibleBid);
      _bidHolder = BidHolder.opponent;
      _bidLog.add(
        '${effectiveOpponent.name}: "Elini görüyorum ve artırıyorum: $_currentBid futbolcu sayarım!"',
      );
      GameFeedback.tick();
      notifyListeners();
    }
  }

  /// User challenges the opponent to prove their current bid!
  void userCallProve() {
    if (!canUserCallProve) return;
    _bidLog.add(
      'Sen: "KANITLA! ${effectiveOpponent.name}, $_currentBid futbolcuyu say bakalım!"',
    );
    GameFeedback.explode();
    _startProvingByOpponent();
  }

  void _startProvingByUser() {
    _phase = AuctionPhase.provingByUser;
    _foundPlayers.clear();
    _proveSecondsLeft = 24 + (_currentBid * 4);
    _lastFeedback =
        'Süre başladı! Kategoriye uyan $_currentBid futbolcuyu bul ve hedefini tamamla!';
    _isSuccessFeedback = true;
    GameFeedback.explode();
    notifyListeners();

    _proveTimer?.cancel();
    _proveTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_proveSecondsLeft > 1) {
        _proveSecondsLeft--;
        notifyListeners();
      } else {
        timer.cancel();
        _finishUserProvingFailed();
      }
    });
  }

  bool submitProveGuess(String query) {
    if (_phase != AuctionPhase.provingByUser ||
        _category == null ||
        query.trim().isEmpty) {
      return false;
    }

    final validList = _category!.validPlayers;
    final qLower = query.trim().toLowerCase();
    PlayerModel? matched;

    for (final p in validList) {
      if (p.name.toLowerCase() == qLower ||
          p.aliases.any((a) => a.toLowerCase() == qLower)) {
        matched = p;
        break;
      }
    }

    if (matched == null) {
      final hits = _db.searchPlayers(query, limit: 4);
      for (final h in hits) {
        if (validList.any((v) => v.id == h.id)) {
          matched = h;
          break;
        }
      }
    }

    if (matched == null) {
      _lastFeedback = '"$query" bu açık artırma kategorisine uymuyor!';
      _isSuccessFeedback = false;
      GameFeedback.error();
      notifyListeners();
      return false;
    }

    if (_foundPlayers.any((p) => p.id == matched!.id)) {
      _lastFeedback = '${matched.name} zaten listene eklendi!';
      _isSuccessFeedback = false;
      GameFeedback.tick();
      notifyListeners();
      return false;
    }

    _foundPlayers.add(matched);
    GameFeedback.success();

    if (_foundPlayers.length >= _currentBid) {
      _proveTimer?.cancel();
      final reward =
          ((130 + _currentBid * 35) * difficulty.pointsMultiplier).round();
      _score += reward;
      _didUserWinRound = true;
      _roundSummaryTitle = 'HEDEFİNİ KANITLADIN! (+$reward Puan)';
      _roundSummarySubtitle =
          '$_currentBid / $_currentBid doğru yıldızı süre dolmadan sayarak turu tamamladın!';
      _phase = AuctionPhase.roundSummary;
      notifyListeners();
      return true;
    }

    _lastFeedback =
        'Doğru! ${matched.name} eklendi (${_foundPlayers.length} / $_currentBid). Devam et!';
    _isSuccessFeedback = true;
    notifyListeners();
    return true;
  }

  void giveUpUserProving() {
    if (_phase != AuctionPhase.provingByUser) return;
    _proveTimer?.cancel();
    _finishUserProvingFailed();
  }

  void _finishUserProvingFailed() {
    _proveSecondsLeft = 0;
    _didUserWinRound = false;
    if (isDuelMode) {
      final oppReward =
          ((120 + _currentBid * 25) * difficulty.pointsMultiplier).round();
      _opponentScore += oppReward;
      _roundSummaryTitle =
          'İDDİA ÇÖKTÜ! (${_foundPlayers.length} / $_currentBid Bulundu)';
      _roundSummarySubtitle =
          'Hedeflediğin $_currentBid oyuncuyu tamamlayamadın. Puan ${effectiveOpponent.name} hanesine yazıldı.';
    } else {
      final partialReward = (_foundPlayers.length * 15 * difficulty.pointsMultiplier).round();
      _score += partialReward;
      _roundSummaryTitle =
          'SÜRE DOLDU! (${_foundPlayers.length} / $_currentBid Futbolcu Bulundu)';
      _roundSummarySubtitle =
          'Hedeflediğin $_currentBid oyuncuya ulaşamadın ama bildiğin ${_foundPlayers.length} isimden +$partialReward Puan kazandın!';
    }
    _phase = AuctionPhase.roundSummary;
    GameFeedback.error();
    notifyListeners();
  }

  void _startProvingByOpponent() {
    _phase = AuctionPhase.provingByOpponent;
    _foundPlayers.clear();
    notifyListeners();

    final pool = List<PlayerModel>.from(_category!.validPlayers)..shuffle(_random);
    int actualKnown;
    if (_currentBid <= _opponentMaxCap - 1) {
      actualKnown = _currentBid;
    } else {
      final bluffed = _random.nextDouble() < 0.65;
      actualKnown = bluffed
          ? (_currentBid - 1 - _random.nextInt(2)).clamp(1, _currentBid - 1)
          : _currentBid;
    }
    actualKnown = actualKnown.clamp(0, pool.length);

    int step = 0;
    _aiActionTimer?.cancel();
    _aiActionTimer = Timer.periodic(const Duration(milliseconds: 480), (timer) {
      if (step < actualKnown) {
        _foundPlayers.add(pool[step]);
        step++;
        GameFeedback.tick();
        notifyListeners();
      } else {
        timer.cancel();
        _finalizeOpponentProving(succeeded: actualKnown >= _currentBid);
      }
    });
  }

  void _finalizeOpponentProving({required bool succeeded}) {
    if (succeeded) {
      final oppReward =
          ((120 + _currentBid * 30) * difficulty.pointsMultiplier).round();
      _opponentScore += oppReward;
      _didUserWinRound = false;
      _roundSummaryTitle =
          '${effectiveOpponent.name.toUpperCase()} İDDİASINI KANITLADI!';
      _roundSummarySubtitle =
          'Rakibin blöf yapmıyormuş; $_currentBid / $_currentBid oyuncuyu eksiksiz saydı.';
      GameFeedback.error();
    } else {
      final userReward =
          ((150 + _currentBid * 35) * difficulty.pointsMultiplier).round();
      _score += userReward;
      _didUserWinRound = true;
      _roundSummaryTitle = 'BLÖFÜ YAKALADIN! (+$userReward Puan)';
      _roundSummarySubtitle =
          '${effectiveOpponent.name} $_currentBid oyuncu sayarım dedi ama ${_foundPlayers.length}. isimde tıkandı!';
      GameFeedback.success();
    }
    _phase = AuctionPhase.roundSummary;
    notifyListeners();
  }

  @override
  void dispose() {
    _proveTimer?.cancel();
    _aiActionTimer?.cancel();
    super.dispose();
  }
}
