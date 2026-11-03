import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/club_model.dart';
import '../data/models/player_model.dart';
import '../data/repositories/football_database.dart';
import '../../core/utils/sound_effects.dart';

enum PartyPhase { setup, countdown321, inRound, roundResult, gameOver }

class PartyPlayer {
  final String id;
  final String name;
  final String avatar;
  int lives;
  int score;

  PartyPlayer({
    required this.id,
    required this.name,
    required this.avatar,
    this.lives = 3,
    this.score = 0,
  });

  bool get isEliminated => lives <= 0;
}

class PartyModeGameProvider extends ChangeNotifier {
  final FootballDatabase _db = FootballDatabase();

  PartyPhase _phase = PartyPhase.setup;
  List<PartyPlayer> _players = [];
  int _currentPlayerIndex = 0;
  int _timerSeconds = 8;
  int _selectedTimerDuration = 8;
  int _initialLives = 3;
  int _countdownNumber = 3;

  ClubModel? _clubA;
  ClubModel? _clubB;
  List<PlayerModel> _currentMutualPlayers = [];
  bool _answersRevealed = false;

  Timer? _gameTimer;
  Timer? _countdownTimer;

  // Getters
  PartyPhase get phase => _phase;
  List<PartyPlayer> get players => _players;
  List<PartyPlayer> get activePlayers => _players.where((p) => !p.isEliminated).toList();
  PartyPlayer? get currentPlayer => _players.isNotEmpty ? _players[_currentPlayerIndex] : null;
  int get timerSeconds => _timerSeconds;
  int get selectedTimerDuration => _selectedTimerDuration;
  int get initialLives => _initialLives;
  int get countdownNumber => _countdownNumber;
  ClubModel? get clubA => _clubA;
  ClubModel? get clubB => _clubB;
  List<PlayerModel> get currentMutualPlayers => _currentMutualPlayers;
  bool get answersRevealed => _answersRevealed;
  PartyPlayer? get winner => activePlayers.length == 1 ? activePlayers.first : null;

  PartyModeGameProvider() {
    _initDefaultPlayers();
  }

  void _initDefaultPlayers() {
    _players = [
      PartyPlayer(id: '1', name: 'Mehmet', avatar: '🦁', lives: _initialLives),
      PartyPlayer(id: '2', name: 'Ahmet', avatar: '⚡', lives: _initialLives),
      PartyPlayer(id: '3', name: 'Can', avatar: '🎯', lives: _initialLives),
      PartyPlayer(id: '4', name: 'Burak', avatar: '🦅', lives: _initialLives),
    ];
  }

  void setTimerDuration(int seconds) {
    _selectedTimerDuration = seconds;
    _timerSeconds = seconds;
    notifyListeners();
  }

  void setInitialLives(int lives) {
    _initialLives = lives;
    for (final p in _players) {
      p.lives = lives;
    }
    notifyListeners();
  }

  void addPlayer(String name) {
    if (name.trim().isEmpty) return;
    const avatars = ['⚽', '🔥', '🦁', '🦅', '⚡', '👑', '🎯', '🚀', '💣', '🌟'];
    final avatar = avatars[_players.length % avatars.length];
    _players.add(PartyPlayer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      avatar: avatar,
      lives: _initialLives,
    ));
    notifyListeners();
  }

  void removePlayer(String id) {
    if (_players.length <= 2) return; // Keep at least 2 players
    _players.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  /// Start Game Sequence (Starts 3-2-1 countdown)
  void startGame() {
    for (final p in _players) {
      p.lives = _initialLives;
      p.score = 0;
    }
    _currentPlayerIndex = 0;
    _start321Countdown();
  }

  void _start321Countdown() {
    _phase = PartyPhase.countdown321;
    _countdownNumber = 3;
    GameFeedback.tick();
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownNumber > 1) {
        _countdownNumber--;
        GameFeedback.tick();
        notifyListeners();
      } else {
        timer.cancel();
        _startRound();
      }
    });
  }

  void _startRound() {
    final pair = _db.getRandomClubPair();
    _clubA = pair.key;
    _clubB = pair.value;
    _currentMutualPlayers = _db.getMutualPlayers(_clubA!.id, _clubB!.id);
    _answersRevealed = false;

    _timerSeconds = _selectedTimerDuration;
    _phase = PartyPhase.inRound;
    notifyListeners();

    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 1) {
        _timerSeconds--;
        GameFeedback.tick();
        notifyListeners();
      } else {
        // TIME OUT! Player failed to answer
        timer.cancel();
        _onTimeOut();
      }
    });
  }

  void _onTimeOut() {
    _timerSeconds = 0;
    GameFeedback.explode();
    if (currentPlayer != null) {
      currentPlayer!.lives--;
    }
    _phase = PartyPhase.roundResult;
    notifyListeners();
  }

  /// Current player knew the answer in time
  void playerKnew() {
    _gameTimer?.cancel();
    GameFeedback.success();
    if (currentPlayer != null) {
      currentPlayer!.score += 100;
    }
    _moveToNextPlayer();
  }

  /// Current player passed or failed
  void playerPassed() {
    _gameTimer?.cancel();
    GameFeedback.error();
    if (currentPlayer != null) {
      currentPlayer!.lives--;
    }
    _phase = PartyPhase.roundResult;
    notifyListeners();
  }

  void toggleShowAnswers() {
    _answersRevealed = !_answersRevealed;
    notifyListeners();
  }

  void continueNextTurn() {
    _moveToNextPlayer();
  }

  void _moveToNextPlayer() {
    // Check if only 1 player remains alive
    if (activePlayers.length <= 1) {
      _phase = PartyPhase.gameOver;
      GameFeedback.success();
      notifyListeners();
      return;
    }

    // Find next non-eliminated player
    int nextIdx = (_currentPlayerIndex + 1) % _players.length;
    while (_players[nextIdx].isEliminated) {
      nextIdx = (nextIdx + 1) % _players.length;
    }
    _currentPlayerIndex = nextIdx;

    _startRound();
  }

  void resetToSetup() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    _phase = PartyPhase.setup;
    for (final p in _players) {
      p.lives = _initialLives;
      p.score = 0;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
