import 'club_model.dart';
import 'player_model.dart';

enum GridCriterionType {
  club,
  trophy,
  nationality,
}

enum GridThemeType {
  mixed,
  trophiesAndClubs,
  nationsAndTrophies,
  superLigSpecial,
  classicClubs,
}

extension GridThemeTypeExtension on GridThemeType {
  String get label {
    switch (this) {
      case GridThemeType.mixed:
        return 'Karışık (Kupa & Takım)';
      case GridThemeType.trophiesAndClubs:
        return 'Kupalar & Devler';
      case GridThemeType.nationsAndTrophies:
        return 'Milli Takım & Kupa';
      case GridThemeType.superLigSpecial:
        return 'Süper Lig & Avrupa';
      case GridThemeType.classicClubs:
        return 'Klasik Kulüpler';
    }
  }
}

class GridCriterion {
  final String id;
  final String label;
  final String sublabel;
  final GridCriterionType type;
  final bool isClub;
  final ClubModel? club;
  final String badgeCode;

  const GridCriterion({
    required this.id,
    required this.label,
    this.sublabel = '',
    this.type = GridCriterionType.club,
    this.isClub = false,
    this.club,
    this.badgeCode = '',
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
  final String title;
  final GridThemeType theme;
  final List<GridCriterion> rowCriteria; // 3 rows
  final List<GridCriterion> colCriteria; // 3 columns

  const GridChallenge({
    this.title = 'Kupa & Kulüp Matrisi',
    this.theme = GridThemeType.mixed,
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
