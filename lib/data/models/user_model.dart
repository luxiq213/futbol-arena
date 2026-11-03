class UserModel {
  final String id;
  final String username;
  final String email;
  final String avatar;
  final String favoriteTeam;
  final int points;
  final int matchesPlayed;
  final int matchesWon;
  final int currentStreak;
  final bool isGuest;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.favoriteTeam,
    this.points = 0,
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.currentStreak = 0,
    this.isGuest = false,
  });

  UserModel copyWith({
    String? username,
    String? email,
    String? avatar,
    String? favoriteTeam,
    int? points,
    int? matchesPlayed,
    int? matchesWon,
    int? currentStreak,
    bool? isGuest,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      favoriteTeam: favoriteTeam ?? this.favoriteTeam,
      points: points ?? this.points,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      matchesWon: matchesWon ?? this.matchesWon,
      currentStreak: currentStreak ?? this.currentStreak,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  String get rankTitle {
    if (points >= 5000) return '🏆 Şampiyonlar Ligi Efsanesi';
    if (points >= 3000) return '🥇 Ballon d\'Or Adayı';
    if (points >= 1500) return '🥈 Süper Lig Yıldızı';
    if (points >= 500) return '🥉 Scout Şefi';
    return '⚽ Genç Yetenek';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'avatar': avatar,
    'favoriteTeam': favoriteTeam,
    'points': points,
    'matchesPlayed': matchesPlayed,
    'matchesWon': matchesWon,
    'currentStreak': currentStreak,
    'isGuest': isGuest,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? 'Futbolcu',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? '⚽',
      favoriteTeam: json['favoriteTeam'] ?? 'Galatasaray',
      points: json['points'] ?? 0,
      matchesPlayed: json['matchesPlayed'] ?? 0,
      matchesWon: json['matchesWon'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      isGuest: json['isGuest'] ?? false,
    );
  }
}
