import '../models/club_model.dart';

enum PlayerPosition {
  striker('Santrafor', 'ST'),
  winger('Kanat Forvet', 'WNG'),
  attackingMid('10 Numara', 'CAM'),
  centralMid('Merkez Orta Saha', 'CM'),
  defender('Stoper', 'CB'),
  goalkeeper('Kaleci', 'GK');

  final String label;
  final String shortCode;
  const PlayerPosition(this.label, this.shortCode);
}

enum PenaltyCorner {
  topLeft('Sol 90'),
  topRight('Sağ 90'),
  bottomLeft('Sol Köşe'),
  center('Panenka (Orta)'),
  bottomRight('Sağ Köşe');

  final String label;
  const PenaltyCorner(this.label);
}

class PenaltyShotResult {
  final PenaltyCorner playerCorner;
  final PenaltyCorner keeperCorner;
  final bool isGoal;
  final String commentary;

  const PenaltyShotResult({
    required this.playerCorner,
    required this.keeperCorner,
    required this.isGoal,
    required this.commentary,
  });
}

class CareerStage {
  final int stageNumber;
  final int age;
  final String stageTitle;
  final ClubModel currentClub;
  final List<ClubModel> transferOffers;
  final SeasonPerformance performance;
  final String eventHighlight;

  const CareerStage({
    required this.stageNumber,
    required this.age,
    required this.stageTitle,
    required this.currentClub,
    required this.transferOffers,
    required this.performance,
    required this.eventHighlight,
  });
}

class SeasonPerformance {
  final int matches;
  final int goals;
  final int assists;
  final List<String> trophiesWon;

  const SeasonPerformance({
    required this.matches,
    required this.goals,
    required this.assists,
    required this.trophiesWon,
  });

  SeasonPerformance copyWith({
    int? matches,
    int? goals,
    int? assists,
    List<String>? trophiesWon,
  }) {
    return SeasonPerformance(
      matches: matches ?? this.matches,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      trophiesWon: trophiesWon ?? this.trophiesWon,
    );
  }
}

class CareerSummary {
  final String playerName;
  final PlayerPosition position;
  final String nationality;
  final int totalMatches;
  final int totalGoals;
  final int totalAssists;
  final int penaltiesScored;
  final int penaltiesTaken;
  final List<String> allTrophies;
  final List<ClubModel> clubsPlayed;
  final int careerRating; // 80 - 99
  final String legacyTitle;

  const CareerSummary({
    required this.playerName,
    required this.position,
    required this.nationality,
    required this.totalMatches,
    required this.totalGoals,
    required this.totalAssists,
    this.penaltiesScored = 0,
    this.penaltiesTaken = 0,
    required this.allTrophies,
    required this.clubsPlayed,
    required this.careerRating,
    required this.legacyTitle,
  });
}
