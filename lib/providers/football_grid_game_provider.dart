import 'package:flutter/foundation.dart';
import '../data/models/player_model.dart';
import '../data/models/grid_challenge_model.dart';
import '../data/repositories/football_database.dart';
import '../../core/utils/sound_effects.dart';

class FootballGridGameProvider extends ChangeNotifier {
  final FootballDatabase _db = FootballDatabase();

  late GridChallenge _challenge;
  late List<List<GridCellState>> _cells;
  int _guessesRemaining = 9;
  int _score = 0;
  int? _activeRow;
  int? _activeCol;
  String? _feedback;

  GridChallenge get challenge => _challenge;
  List<List<GridCellState>> get cells => _cells;
  int get guessesRemaining => _guessesRemaining;
  int get score => _score;
  int? get activeRow => _activeRow;
  int? get activeCol => _activeCol;
  String? get feedback => _feedback;

  int get solvedCount {
    int count = 0;
    for (var r in _cells) {
      for (var c in r) {
        if (c.isSolved) count++;
      }
    }
    return count;
  }

  bool get isGameOver => _guessesRemaining <= 0 || solvedCount == 9;

  FootballGridGameProvider() {
    startNewGrid();
  }

  void startNewGrid() {
    _challenge = _db.getRandom3x3GridChallenge();
    _cells = List.generate(
      3,
      (r) => List.generate(
        3,
        (c) => GridCellState(rowIndex: r, colIndex: c),
      ),
    );
    _guessesRemaining = 9;
    _score = 0;
    _activeRow = null;
    _activeCol = null;
    _feedback = null;
    notifyListeners();
  }

  void selectCell(int row, int col) {
    if (_cells[row][col].isSolved || isGameOver) return;
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
    if (_activeRow == null || _activeCol == null || isGameOver) return false;

    final row = _activeRow!;
    final col = _activeCol!;
    final rowCriterion = _challenge.rowCriteria[row];
    final colCriterion = _challenge.colCriteria[col];

    final searchResults = _db.searchPlayers(query);
    if (searchResults.isEmpty) {
      _feedback = 'Futbolcu bulunamadi. Lütfen gecerli bir isim girin.';
      GameFeedback.error();
      notifyListeners();
      return false;
    }

    final player = searchResults.first;

    // Check if player was already used in another cell
    for (var r in _cells) {
      for (var c in r) {
        if (c.isSolved && c.player?.id == player.id) {
          _feedback = '${player.name} baska bir hücrede zaten kullanildi!';
          GameFeedback.tick();
          notifyListeners();
          return false;
        }
      }
    }

    final isValid = _db.validateGridCell(rowCriterion, colCriterion, player);

    _guessesRemaining--;

    if (isValid) {
      _cells[row][col].player = player;
      _cells[row][col].isSolved = true;
      _score += 150;
      _feedback = 'Mükemmel! ${player.name} kriterleri sagladi. (+150 Puan)';
      GameFeedback.success();
      _activeRow = null;
      _activeCol = null;
      notifyListeners();
      return true;
    } else {
      _feedback = '${player.name} bu iki kriteri ayni anda saglamiyor.';
      GameFeedback.error();
      notifyListeners();
      return false;
    }
  }

  List<PlayerModel> getValidAnswersForActiveCell() {
    if (_activeRow == null || _activeCol == null) return [];
    final rowCriterion = _challenge.rowCriteria[_activeRow!];
    final colCriterion = _challenge.colCriteria[_activeCol!];
    return _db.getValidPlayersForCell(rowCriterion, colCriterion);
  }
}
