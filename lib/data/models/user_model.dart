class UserModel {
  final String id;
  final String username;
  final String email;
  final String avatar; // Avatar role: captain, scout, striker, maestro, etc.
  final String favoriteTeam;
  final int points;
  final int matchesPlayed;
  final int matchesWon;
  final int currentStreak;
  final bool isGuest;
  final bool isAdFree;

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
    this.isAdFree = false,
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
    bool? isAdFree,
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
      isAdFree: isAdFree ?? this.isAdFree,
    );
  }

  String get rankTitle {
    if (points >= 5000) return 'Sampiyonlar Ligi Efsanesi';
    if (points >= 3000) return 'Altin Top Adayi';
    if (points >= 1500) return 'Süper Lig Yildizi';
    if (points >= 500) return 'Bas Scout';
    return 'Genc Yetenek';
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
    'isAdFree': isAdFree,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? 'Kaptan',
      email: json['email'] ?? '',
      avatar: json['avatar'] ?? 'captain',
      favoriteTeam: json['favoriteTeam'] ?? 'Galatasaray',
      points: json['points'] ?? 0,
      matchesPlayed: json['matchesPlayed'] ?? 0,
      matchesWon: json['matchesWon'] ?? 0,
      currentStreak: json['currentStreak'] ?? 0,
      isGuest: json['isGuest'] ?? false,
      isAdFree: json['isAdFree'] ?? false,
    );
  }
}
