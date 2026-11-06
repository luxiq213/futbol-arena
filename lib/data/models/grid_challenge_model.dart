import 'club_model.dart';
import 'player_model.dart';

class GridCriterion {
  final String id;
  final String label;
  final String sublabel;
  final bool isClub;
  final ClubModel? club;

  const GridCriterion({
    required this.id,
    required this.label,
    this.sublabel = '',
    this.isClub = false,
    this.club,
  });
}

class GridCellState {
  final int rowIndex;
  final int colIndex;
  PlayerModel? player;
  bool isSolved;
  bool solvedByOpponent;

  GridCellState({
    required this.rowIndex,
    required this.colIndex,
    this.player,
    this.isSolved = false,
    this.solvedByOpponent = false,
  });
}

class GridChallenge {
  final List<GridCriterion> rowCriteria; // 3 rows
  final List<GridCriterion> colCriteria; // 3 columns

  const GridChallenge({
    required this.rowCriteria,
    required this.colCriteria,
  });
}

class FiveClubsChallenge {
  final List<ClubModel> clubs; // 5 clubs
  final PlayerModel bestAnswer;
  final int maxMatchCount;

  const FiveClubsChallenge({
    required this.clubs,
    required this.bestAnswer,
    required this.maxMatchCount,
  });
}
