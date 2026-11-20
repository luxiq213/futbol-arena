import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/models/player_model.dart';
import '../data/models/grid_challenge_model.dart';
import '../data/models/play_mode_model.dart';
import '../data/repositories/football_database.dart';
import '../../core/utils/sound_effects.dart';

class FootballGridGameProvider extends ChangeNotifier {
  final FootballDatabase _db = FootballDatabase();
  final Random _random = Random();

  final PlayModeType playMode;
  final GameDifficulty difficulty;
  final OpponentProfile? opponent;

  GridThemeType _selectedTheme = GridThemeType.mixed;
  late GridChallenge _challenge;
  late List<List<GridCellState>> _cells;
  int _guessesRemaining = 9;
  int _score = 0;
  int _opponentScore = 0;
  int? _activeRow;
  int? _activeCol;
  bool _isOpponentThinking = false;
  bool _hasGivenUp = false;
  Timer? _opponentTimer;
  final Set<String> _surrenderRevealedKeys = {};
  String? _feedback;

  GridThemeType get selectedTheme => _selectedTheme;
  GridChallenge get challenge => _challenge;
  List<List<GridCellState>> get cells => _cells;
  int get guessesRemaining => _guessesRemaining;
  int get score => _score;
  int get opponentScore => _opponentScore;
  int? get activeRow => _activeRow;
  int? get activeCol => _activeCol;
  bool get isOpponentThinking => _isOpponentThinking;
  bool get hasGivenUp => _hasGivenUp;
  String? get feedback => _feedback;
  bool get isDuelMode => playMode != PlayModeType.solo && opponent != null;

  bool isCellRevealedBySurrender(int row, int col) =>
      _surrenderRevealedKeys.contains('${row}_$col');

  int get solvedCount {
    int count = 0;
    for (var r in _cells) {
      for (var c in r) {
        if (c.isSolved) count++;
      }
    }
    return count;
  }

  int get userSolvedCount {
    int count = 0;
    for (var r in _cells) {
      for (var c in r) {
        if (c.isSolved && !c.solvedByOpponent) count++;
      }
    }
    return count;
  }

  int get opponentSolvedCount {
    int count = 0;
    for (var r in _cells) {
      for (var c in r) {
        if (c.isSolved && c.solvedByOpponent) count++;
      }
    }
    return count;
  }

  bool get isGameOver => _hasGivenUp || solvedCount == 9;

  @override
  void dispose() {
    _opponentTimer?.cancel();
    super.dispose();
  }

  FootballGridGameProvider({
    this.playMode = PlayModeType.solo,
    this.difficulty = GameDifficulty.medium,
    this.opponent,
    GridThemeType initialTheme = GridThemeType.mixed,
  }) : _selectedTheme = initialTheme {
    startNewGrid();
  }

  void setGridTheme(GridThemeType theme) {
    if (_selectedTheme == theme) return;
    _selectedTheme = theme;
    startNewGrid();
  }

  void startNewGrid() {
    _opponentTimer?.cancel();
    _challenge = _db.getRandom3x3GridChallenge(theme: _selectedTheme);
    _cells = List.generate(
      3,
      (r) => List.generate(
        3,
        (c) => GridCellState(rowIndex: r, colIndex: c),
      ),
    );
    _guessesRemaining = difficulty.gridGuessesAllowed;
    _score = 0;
    _opponentScore = 0;
    _activeRow = null;
    _activeCol = null;
    _isOpponentThinking = false;
    _hasGivenUp = false;
    _surrenderRevealedKeys.clear();
    _feedback = null;
    notifyListeners();
  }

  /// Surrenders the current 3x3 grid and reveals example answers for remaining empty cells.
  void giveUp() {
    if (isGameOver) return;
    _opponentTimer?.cancel();
    _isOpponentThinking = false;
    _hasGivenUp = true;
    _activeRow = null;
    _activeCol = null;

    final usedIds = <String>{};
    for (final row in _cells) {
      for (final cell in row) {
        if (cell.isSolved && cell.player != null) {
          usedIds.add(cell.player!.id);
        }
      }
    }

    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        final cell = _cells[r][c];
        if (!cell.isSolved) {
          final rCrit = _challenge.rowCriteria[r];
          final cCrit = _challenge.colCriteria[c];
          final candidates = _db
              .getValidPlayersForCell(rCrit, cCrit)
              .where((p) => !usedIds.contains(p.id))
              .toList();
          if (candidates.isNotEmpty) {
            final answer = candidates.first;
            usedIds.add(answer.id);
            cell.player = answer;
            cell.isSolved = true;
            _surrenderRevealedKeys.add('${r}_$c');
          }
        }
      }
    }

    GameFeedback.error();
    _feedback = 'Pes ettin! Çözemediğin kutuların cevapları açıldı.';
    notifyListeners();
  }

  void selectCell(int row, int col) {
    if (_cells[row][col].isSolved || isGameOver || _isOpponentThinking) return;
    _activeRow = row;
    _activeCol = col;
    _feedback = null;
    notifyListeners();
  }

  void clearSelection() {
    _activeRow = null;
    _activeCol = null;
    notifyListeners();
  }

  bool submitPlayerGuess(String query) {
    if (_activeRow == null || _activeCol == null || isGameOver || _isOpponentThinking) {
      return false;
    }

    final row = _activeRow!;
    final col = _activeCol!;
    final rowCriterion = _challenge.rowCriteria[row];
    final colCriterion = _challenge.colCriteria[col];

    final searchResults = _db.searchPlayers(query);
    if (searchResults.isEmpty) {
      _feedback = 'Futbolcu bulunamadı. Lütfen geçerli bir isim girin.';
      GameFeedback.error();
      notifyListeners();
      return false;
    }

    final player = searchResults.first;

    // Check if player was already used in another cell
    for (var r in _cells) {
      for (var c in r) {
        if (c.isSolved && c.player?.id == player.id) {
          _feedback = '${player.name} başka bir hücrede zaten kullanıldı!';
          GameFeedback.tick();
          notifyListeners();
          return false;
        }
      }
    }

    final isValid = _db.validateGridCell(rowCriterion, colCriterion, player);

    _guessesRemaining--;

    bool solved = false;
    final cellReward = (150 * difficulty.pointsMultiplier).round();
    if (isValid) {
      _cells[row][col].player = player;
      _cells[row][col].isSolved = true;
      _cells[row][col].solvedByOpponent = false;
      _score += cellReward;
      _feedback = 'Mükemmel! ${player.name} kriterleri sağladı. (+$cellReward Puan)';
      GameFeedback.success();
      _activeRow = null;
      _activeCol = null;
      solved = true;
    } else {
      _feedback = '${player.name} (${rowCriterion.label} × ${colCriterion.label}) kriterlerini aynı anda sağlamıyor.';
      GameFeedback.error();
    }

    notifyListeners();

    if (isDuelMode && !isGameOver) {
      _triggerOpponentCellTurn();
    }

    return solved;
  }

  void _triggerOpponentCellTurn() {
    final unsolved = <GridCellState>[];
    for (var r in _cells) {
      for (var c in r) {
        if (!c.isSolved) unsolved.add(c);
      }
    }
    if (unsolved.isEmpty) return;

    _isOpponentThinking = true;
    notifyListeners();

    _opponentTimer?.cancel();
    _opponentTimer = Timer(const Duration(milliseconds: 700), () {
      _isOpponentThinking = false;
      if (_hasGivenUp) {
        notifyListeners();
        return;
      }
      final currentUnsolved = <GridCellState>[];
      final usedIds = <String>{};
      for (var r in _cells) {
        for (var c in r) {
          if (c.isSolved && c.player != null) {
            usedIds.add(c.player!.id);
          } else if (!c.isSolved) {
            currentUnsolved.add(c);
          }
        }
      }
      if (currentUnsolved.isEmpty) {
        notifyListeners();
        return;
      }

      final oppName = opponent?.name ?? 'Rakip';
      final targetCell = currentUnsolved[_random.nextInt(currentUnsolved.length)];
      final rCrit = _challenge.rowCriteria[targetCell.rowIndex];
      final cCrit = _challenge.colCriteria[targetCell.colIndex];
      final validPlayers = _db
          .getValidPlayersForCell(rCrit, cCrit)
          .where((p) => !usedIds.contains(p.id))
          .toList();

      if (validPlayers.isNotEmpty && _random.nextDouble() < difficulty.aiAccuracyChance) {
        final chosen = validPlayers[_random.nextInt(validPlayers.length)];
        final oppReward = (150 * difficulty.pointsMultiplier).round();
        targetCell.player = chosen;
        targetCell.isSolved = true;
        targetCell.solvedByOpponent = true;
        _opponentScore += oppReward;
        _feedback = '$oppName (${rCrit.label} × ${cCrit.label}) hücresini ${chosen.name} ile çözdü!';
      } else {
        _feedback = '$oppName hamlesinde doğru kesişimi bulamadı. Sıra sende!';
      }
      notifyListeners();
    });
  }

  List<PlayerModel> getValidAnswersForActiveCell() {
    if (_activeRow == null || _activeCol == null) return [];
    final rowCriterion = _challenge.rowCriteria[_activeRow!];
    final colCriterion = _challenge.colCriteria[_activeCol!];
    return _db.getValidPlayersForCell(rowCriterion, colCriterion);
  }
}
