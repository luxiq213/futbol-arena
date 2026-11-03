import 'package:flutter/foundation.dart';
import '../data/models/club_model.dart';
import '../data/models/player_model.dart';
import '../data/repositories/football_database.dart';
import '../../core/utils/sound_effects.dart';

class CommonPlayerGameProvider extends ChangeNotifier {
  final FootballDatabase _db = FootballDatabase();

  ClubModel? _clubA;
  ClubModel? _clubB;
  List<PlayerModel> _mutualPlayers = [];
  final Set<String> _foundPlayerIds = {};

  int _score = 0;
  int _hintsUsed = 0;
  bool _revealed = false;
  String? _lastFeedback;
  bool _isSuccessFeedback = false;

  ClubModel? get clubA => _clubA;
  ClubModel? get clubB => _clubB;
  List<PlayerModel> get mutualPlayers => _mutualPlayers;
  Set<String> get foundPlayerIds => _foundPlayerIds;
  int get score => _score;
  int get hintsUsed => _hintsUsed;
  bool get revealed => _revealed;
  String? get lastFeedback => _lastFeedback;
  bool get isSuccessFeedback => _isSuccessFeedback;

  int get totalFound => _foundPlayerIds.length;
  int get totalPossible => _mutualPlayers.length;
  bool get isAllFound => totalPossible > 0 && totalFound == totalPossible;

  CommonPlayerGameProvider() {
    startNewRound();
  }

  void startNewRound() {
    final pair = _db.getRandomClubPair();
    _clubA = pair.key;
    _clubB = pair.value;
    _mutualPlayers = _db.getMutualPlayers(_clubA!.id, _clubB!.id);
    _foundPlayerIds.clear();
    _hintsUsed = 0;
    _revealed = false;
    _lastFeedback = null;
    notifyListeners();
  }

  /// Make a guess with a player name
  bool submitGuess(String query) {
    if (query.trim().isEmpty || _clubA == null || _clubB == null) return false;

    // Search within mutual players
    PlayerModel? matched;
    for (final player in _mutualPlayers) {
      if (player.playedForBoth(_clubA!.id, _clubB!.id)) {
        if (query.toLowerCase().trim() == player.name.toLowerCase().trim() ||
            player.aliases.any((a) => a.toLowerCase().trim() == query.toLowerCase().trim())) {
          matched = player;
          break;
        }
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

    if (matched != null) {
      if (_foundPlayerIds.contains(matched.id)) {
        _lastFeedback = '${matched.name} zaten bulundu!';
        _isSuccessFeedback = false;
        GameFeedback.tick();
        notifyListeners();
        return false;
      }

      _foundPlayerIds.add(matched.id);
      _score += 100;
      _lastFeedback = 'Tebrikler! ${matched.name} doğru cevap! (+100 XP)';
      _isSuccessFeedback = true;
      GameFeedback.success();

      if (isAllFound) {
        _score += 150; // Bonus for finding all
        _lastFeedback = 'MÜKEMMEL! İki takımın tüm ortak oyuncularını bildin! (+150 Bonus XP)';
      }

      notifyListeners();
      return true;
    } else {
      _lastFeedback = '"$query" bu iki kulüpte birden oynamadı!';
      _isSuccessFeedback = false;
      GameFeedback.error();
      notifyListeners();
      return false;
    }
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
