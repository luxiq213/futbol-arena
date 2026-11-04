class PlayerModel {
  final String id;
  final String name;
  final String country;
  final String position;
  final List<String> clubIds;
  final List<String> trophies;
  final List<String> aliases;
  final String activeYears;
  final String hint;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.country,
    required this.position,
    required this.clubIds,
    this.trophies = const [],
    this.aliases = const [],
    required this.activeYears,
    this.hint = '',
  });

  /// Check if this player played for both clubs
  bool playedForBoth(String clubAId, String clubBId) {
    return clubIds.contains(clubAId) && clubIds.contains(clubBId);
  }

  /// Check if player played for a specific club
  bool playedFor(String clubId) {
    return clubIds.contains(clubId);
  }

  /// Check if player won a trophy
  bool hasTrophy(String trophyId) {
    return trophies.contains(trophyId);
  }

  /// Count how many of the given clubs this player played for (used in 5 Clubs mode)
  int countPlayedIn(List<String> targetClubIds) {
    return targetClubIds.where((c) => clubIds.contains(c)).length;
  }

  /// Check generic grid criterion (club ID, trophy ID, or nationality)
  bool matchesGridCriterion(String criterionId) {
    if (clubIds.contains(criterionId)) return true;
    if (trophies.contains(criterionId)) return true;
    if (country.toLowerCase() == criterionId.toLowerCase()) return true;
    return false;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'position': position,
    'clubIds': clubIds,
    'trophies': trophies,
    'aliases': aliases,
    'activeYears': activeYears,
    'hint': hint,
  };
}
