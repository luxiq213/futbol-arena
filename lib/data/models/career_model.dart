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

class CareerStage {
  final int stageNumber;
  final int age;
  final String stageTitle; // Örn: 'Genç Yetenek (18 Yaş)', 'Zirve Dönemi (26 Yaş)'
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
}

class CareerSummary {
  final String playerName;
  final PlayerPosition position;
  final String nationality;
  final int totalMatches;
  final int totalGoals;
  final int totalAssists;
  final List<String> allTrophies;
  final List<ClubModel> clubsPlayed;
  final int careerRating; // 80 - 99
  final String legacyTitle; // Örn: 'DÜNYA FUTBOL EFSANESİ'

  const CareerSummary({
    required this.playerName,
    required this.position,
    required this.nationality,
    required this.totalMatches,
    required this.totalGoals,
    required this.totalAssists,
    required this.allTrophies,
    required this.clubsPlayed,
    required this.careerRating,
    required this.legacyTitle,
  });
}
