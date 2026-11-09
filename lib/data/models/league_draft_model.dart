class ManagerOption {
  final String id;
  final String name;
  final String nationality;
  final String styleTitle;
  final String bonusDescription;
  final int rating;
  final int attackBonus;
  final int defenseBonus;

  const ManagerOption({
    required this.id,
    required this.name,
    required this.nationality,
    required this.styleTitle,
    required this.bonusDescription,
    required this.rating,
    required this.attackBonus,
    required this.defenseBonus,
  });
}

class FormationOption {
  final String id;
  final String code; // e.g. '4-3-3'
  final String title;
  final String description;
  final int defenders;
  final int midfielders;
  final int forwards;
  final int attackBonus;
  final int defenseBonus;

  const FormationOption({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.defenders,
    required this.midfielders,
    required this.forwards,
    required this.attackBonus,
    required this.defenseBonus,
  });

  /// Returns the sequence of 11 positional roles needed for the 11 draft rounds
  List<String> get draftSlotRoles {
    return [
      'GK',
      ...List.filled(defenders, 'DEF'),
      ...List.filled(midfielders, 'MID'),
      ...List.filled(forwards, 'FWD'),
    ];
  }
}

class EraPlayerCandidate {
  final String id;
  final String name;
  final String role; // 'GK', 'DEF', 'MID', 'FWD'
  final String specificPosition; // 'KL', 'STP', 'OS', 'SNT', etc.
  final int rating;
  final String clubId;
  final String clubName;
  final String seasonLabel; // e.g. '2004-05'

  const EraPlayerCandidate({
    required this.id,
    required this.name,
    required this.role,
    required this.specificPosition,
    required this.rating,
    required this.clubId,
    required this.clubName,
    required this.seasonLabel,
  });
}

class EraClubPack {
  final String id;
  final String clubId;
  final String clubName;
  final String seasonLabel;
  final String eraTitle;
  final List<EraPlayerCandidate> roster;

  const EraClubPack({
    required this.id,
    required this.clubId,
    required this.clubName,
    required this.seasonLabel,
    required this.eraTitle,
    required this.roster,
  });
}

class LeagueParticipant {
  final String id;
  final String name;
  final bool isBot;
  ManagerOption? manager;
  FormationOption? formation;
  final List<EraPlayerCandidate> squad;

  int played = 0;
  int won = 0;
  int drawn = 0;
  int lost = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
  int points = 0;

  LeagueParticipant({
    required this.id,
    required this.name,
    this.isBot = false,
    this.manager,
    this.formation,
    List<EraPlayerCandidate>? initialSquad,
  }) : squad = initialSquad ?? [];

  int get goalDifference => goalsFor - goalsAgainst;

  double get averagePlayerRating {
    if (squad.isEmpty) return 80;
    final sum = squad.fold<int>(0, (acc, p) => acc + p.rating);
    return sum / squad.length;
  }

  int get overallTeamPower {
    final base = averagePlayerRating.round();
    final mgrBonus = ((manager?.attackBonus ?? 0) + (manager?.defenseBonus ?? 0)) ~/ 2;
    return (base + mgrBonus).clamp(75, 99);
  }

  int get attackPower {
    final fwds = squad.where((p) => p.role == 'FWD' || p.role == 'MID').toList();
    final base = fwds.isEmpty
        ? averagePlayerRating.round()
        : (fwds.fold<int>(0, (a, b) => a + b.rating) / fwds.length).round();
    return base + (manager?.attackBonus ?? 0) + (formation?.attackBonus ?? 0);
  }

  int get defensePower {
    final defs = squad.where((p) => p.role == 'GK' || p.role == 'DEF').toList();
    final base = defs.isEmpty
        ? averagePlayerRating.round()
        : (defs.fold<int>(0, (a, b) => a + b.rating) / defs.length).round();
    return base + (manager?.defenseBonus ?? 0) + (formation?.defenseBonus ?? 0);
  }

  void resetLeagueStats() {
    played = 0;
    won = 0;
    drawn = 0;
    lost = 0;
    goalsFor = 0;
    goalsAgainst = 0;
    points = 0;
  }
}

class LeagueGoalEvent {
  final int minute;
  final String scorerName;
  final String clubEraTag;
  final bool isHomeGoal;

  const LeagueGoalEvent({
    required this.minute,
    required this.scorerName,
    required this.clubEraTag,
    required this.isHomeGoal,
  });
}

class LeagueMatchFixture {
  final int matchday;
  final int homeIndex;
  final int awayIndex;
  bool isPlayed;
  int homeGoals;
  int awayGoals;
  List<LeagueGoalEvent> events;

  LeagueMatchFixture({
    required this.matchday,
    required this.homeIndex,
    required this.awayIndex,
    this.isPlayed = false,
    this.homeGoals = 0,
    this.awayGoals = 0,
    List<LeagueGoalEvent>? events,
  }) : events = events ?? [];
}
