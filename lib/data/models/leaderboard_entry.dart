enum LeaderboardModeCategory {
  overall,
  career,
  commonPlayer,
  fiveClubs,
  footballGrid,
}

extension LeaderboardModeCategoryExt on LeaderboardModeCategory {
  String get label {
    switch (this) {
      case LeaderboardModeCategory.overall:
        return 'Genel Klasman';
      case LeaderboardModeCategory.career:
        return 'Kariyer Modu';
      case LeaderboardModeCategory.commonPlayer:
        return 'Ortak Oyuncu';
      case LeaderboardModeCategory.fiveClubs:
        return '5 Takım 1 Oyuncu';
      case LeaderboardModeCategory.footballGrid:
        return 'Futbol Grid 3x3';
    }
  }

  String get subtitle {
    switch (this) {
      case LeaderboardModeCategory.overall:
        return 'Tüm oyun modlarından toplanan genel XP ve galibiyet sıralaması';
      case LeaderboardModeCategory.career:
        return 'Futbolcu Kariyeri modunda ulaşılan en yüksek OVR ve kupa sayısı';
      case LeaderboardModeCategory.commonPlayer:
        return 'Ortak Oyuncu modunda bulunan yıldızlar ve kazanılan düellolar';
      case LeaderboardModeCategory.fiveClubs:
        return '5 Takım 1 Oyuncu modunda 5/5 tam isabet ve analiz puanları';
      case LeaderboardModeCategory.footballGrid:
        return 'Futbol Grid 3x3 kupa, milli takım ve kulüp matrisi puanları';
    }
  }
}

class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final String avatar;
  final String favoriteTeam;
  final int points;
  final int matchesWon;
  final String scoreLabel;
  final String secondaryLabel;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    required this.avatar,
    required this.favoriteTeam,
    required this.points,
    required this.matchesWon,
    this.scoreLabel = '',
    this.secondaryLabel = '',
    this.isCurrentUser = false,
  });

  String get effectiveScoreLabel => scoreLabel.isNotEmpty ? scoreLabel : '$points XP';
  String get effectiveSecondaryLabel =>
      secondaryLabel.isNotEmpty ? secondaryLabel : '$matchesWon Galibiyet';
}
