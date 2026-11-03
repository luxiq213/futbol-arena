class PlayerModel {
  final String id;
  final String name;
  final String country;
  final String position;
  final List<String> clubIds;
  final List<String> aliases;
  final String activeYears;
  final String hint;

  const PlayerModel({
    required this.id,
    required this.name,
    required this.country,
    required this.position,
    required this.clubIds,
    this.aliases = const [],
    required this.activeYears,
    this.hint = '',
  });

  /// Check if this player played for both clubs
  bool playedForBoth(String clubAId, String clubBId) {
    return clubIds.contains(clubAId) && clubIds.contains(clubBId);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'position': position,
    'clubIds': clubIds,
    'aliases': aliases,
    'activeYears': activeYears,
    'hint': hint,
  };
}
