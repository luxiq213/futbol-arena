class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final String avatar;
  final String favoriteTeam;
  final int points;
  final int matchesWon;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.avatar,
    required this.favoriteTeam,
    required this.points,
    required this.matchesWon,
    this.isCurrentUser = false,
  });
}
