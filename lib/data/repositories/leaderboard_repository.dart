import '../models/leaderboard_entry.dart';
import '../models/user_model.dart';

class LeaderboardRepository {
  List<LeaderboardEntry> getRankings({
    required UserModel? currentUser,
    required LeaderboardModeCategory category,
    required bool friendsOnly,
  }) {
    final rawEntries = friendsOnly
        ? _buildFriendsRaw(category)
        : _buildGlobalRaw(category);

    if (currentUser != null) {
      final userEntry = _buildCurrentUserEntry(currentUser, category);
      rawEntries.add(userEntry);
    }

    rawEntries.sort((a, b) => b.points.compareTo(a.points));

    return List.generate(rawEntries.length, (i) {
      final e = rawEntries[i];
      return LeaderboardEntry(
        rank: i + 1,
        userId: e.userId,
        username: e.username,
        avatar: e.avatar,
        favoriteTeam: e.favoriteTeam,
        points: e.points,
        matchesWon: e.matchesWon,
        scoreLabel: e.scoreLabel,
        secondaryLabel: e.secondaryLabel,
        isCurrentUser: e.isCurrentUser,
      );
    });
  }

  LeaderboardEntry _buildCurrentUserEntry(
    UserModel user,
    LeaderboardModeCategory category,
  ) {
    final baseXp = user.points;
    final wins = user.matchesWon;

    switch (category) {
      case LeaderboardModeCategory.overall:
        return LeaderboardEntry(
          rank: 0,
          userId: user.id,
          username: '${user.username} (Sen)',
          avatar: user.avatar,
          favoriteTeam: user.favoriteTeam,
          points: baseXp,
          matchesWon: wins,
          scoreLabel: '$baseXp XP',
          secondaryLabel: '$wins Galibiyet',
          isCurrentUser: true,
        );
      case LeaderboardModeCategory.career:
        final careerOvr = (86 + (baseXp ~/ 500)).clamp(86, 98);
        final trophies = (4 + (baseXp ~/ 450)).clamp(4, 18);
        return LeaderboardEntry(
          rank: 0,
          userId: user.id,
          username: '${user.username} (Sen)',
          avatar: user.avatar,
          favoriteTeam: user.favoriteTeam,
          points: careerOvr,
          matchesWon: trophies,
          scoreLabel: '$careerOvr OVR',
          secondaryLabel: '$trophies Kupa • Efsane',
          isCurrentUser: true,
        );
      case LeaderboardModeCategory.commonPlayer:
        final modePts = (baseXp * 0.42).round() + 350;
        final streak = (wins + 4).clamp(4, 35);
        return LeaderboardEntry(
          rank: 0,
          userId: user.id,
          username: '${user.username} (Sen)',
          avatar: user.avatar,
          favoriteTeam: user.favoriteTeam,
          points: modePts,
          matchesWon: wins,
          scoreLabel: '$modePts Puan',
          secondaryLabel: '$streak Ortak Yıldız',
          isCurrentUser: true,
        );
      case LeaderboardModeCategory.fiveClubs:
        final modePts = (baseXp * 0.36).round() + 300;
        final fullMatches = (wins ~/ 2 + 3).clamp(3, 28);
        return LeaderboardEntry(
          rank: 0,
          userId: user.id,
          username: '${user.username} (Sen)',
          avatar: user.avatar,
          favoriteTeam: user.favoriteTeam,
          points: modePts,
          matchesWon: wins,
          scoreLabel: '$modePts Puan',
          secondaryLabel: '$fullMatches Kez 5/5 İsabet',
          isCurrentUser: true,
        );
      case LeaderboardModeCategory.footballGrid:
        final modePts = (baseXp * 0.38).round() + 450;
        final cellsSolved = (wins * 3 + 9).clamp(9, 120);
        return LeaderboardEntry(
          rank: 0,
          userId: user.id,
          username: '${user.username} (Sen)',
          avatar: user.avatar,
          favoriteTeam: user.favoriteTeam,
          points: modePts,
          matchesWon: wins,
          scoreLabel: '$modePts Puan',
          secondaryLabel: '$cellsSolved Hücre Çözüldü',
          isCurrentUser: true,
        );
      case LeaderboardModeCategory.footballBridge:
        final modePts = (baseXp * 0.34).round() + 400;
        final bridges = (wins + 5).clamp(5, 42);
        return LeaderboardEntry(
          rank: 0,
          userId: user.id,
          username: '${user.username} (Sen)',
          avatar: user.avatar,
          favoriteTeam: user.favoriteTeam,
          points: modePts,
          matchesWon: wins,
          scoreLabel: '$modePts Puan',
          secondaryLabel: '$bridges Köprü Kuruldu',
          isCurrentUser: true,
        );
      case LeaderboardModeCategory.auctionDuel:
        final modePts = (baseXp * 0.40).round() + 420;
        final maxBid = (5 + (wins ~/ 4)).clamp(5, 12);
        return LeaderboardEntry(
          rank: 0,
          userId: user.id,
          username: '${user.username} (Sen)',
          avatar: user.avatar,
          favoriteTeam: user.favoriteTeam,
          points: modePts,
          matchesWon: wins,
          scoreLabel: '$modePts Puan',
          secondaryLabel: 'Rekor İddia: $maxBid Oyuncu',
          isCurrentUser: true,
        );
    }
  }

  List<LeaderboardEntry> _buildGlobalRaw(LeaderboardModeCategory category) {
    switch (category) {
      case LeaderboardModeCategory.overall:
        return [
          const LeaderboardEntry(
            rank: 1,
            userId: 'u1',
            username: 'Hagi10',
            avatar: 'goat_10',
            favoriteTeam: 'Galatasaray',
            points: 8420,
            matchesWon: 45,
            scoreLabel: '8420 XP',
            secondaryLabel: '45 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 2,
            userId: 'u2',
            username: 'CR7_Efsane',
            avatar: 'striker_7',
            favoriteTeam: 'Real Madrid',
            points: 7650,
            matchesWon: 39,
            scoreLabel: '7650 XP',
            secondaryLabel: '39 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 3,
            userId: 'u3',
            username: 'Karakartal_99',
            avatar: 'captain_4',
            favoriteTeam: 'Beşiktaş',
            points: 6890,
            matchesWon: 34,
            scoreLabel: '6890 XP',
            secondaryLabel: '34 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 4,
            userId: 'u4',
            username: 'SariKanarya_Arda',
            avatar: 'fener_10',
            favoriteTeam: 'Fenerbahçe',
            points: 5920,
            matchesWon: 29,
            scoreLabel: '5920 XP',
            secondaryLabel: '29 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 5,
            userId: 'u5',
            username: 'Gunner4Ever',
            avatar: 'wonderkid_19',
            favoriteTeam: 'Arsenal',
            points: 5410,
            matchesWon: 26,
            scoreLabel: '5410 XP',
            secondaryLabel: '26 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 6,
            userId: 'u6',
            username: 'BarcaTikiTaka',
            avatar: 'samba_11',
            favoriteTeam: 'Barcelona',
            points: 4800,
            matchesWon: 22,
            scoreLabel: '4800 XP',
            secondaryLabel: '22 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 7,
            userId: 'u7',
            username: 'CityZen_Haaland',
            avatar: 'viking_9',
            favoriteTeam: 'Manchester City',
            points: 4210,
            matchesWon: 19,
            scoreLabel: '4210 XP',
            secondaryLabel: '19 Galibiyet',
          ),
        ];

      case LeaderboardModeCategory.career:
        return [
          const LeaderboardEntry(
            rank: 1,
            userId: 'u2',
            username: 'CR7_Efsane',
            avatar: 'striker_7',
            favoriteTeam: 'Real Madrid',
            points: 97,
            matchesWon: 19,
            scoreLabel: '97 OVR',
            secondaryLabel: '19 Kupa • 9/10 Penaltı',
          ),
          const LeaderboardEntry(
            rank: 2,
            userId: 'u1',
            username: 'Hagi10',
            avatar: 'goat_10',
            favoriteTeam: 'Galatasaray',
            points: 96,
            matchesWon: 17,
            scoreLabel: '96 OVR',
            secondaryLabel: '17 Kupa • 8/10 Penaltı',
          ),
          const LeaderboardEntry(
            rank: 3,
            userId: 'u6',
            username: 'BarcaTikiTaka',
            avatar: 'samba_11',
            favoriteTeam: 'Barcelona',
            points: 94,
            matchesWon: 15,
            scoreLabel: '94 OVR',
            secondaryLabel: '15 Kupa • 8/10 Penaltı',
          ),
          const LeaderboardEntry(
            rank: 4,
            userId: 'u4',
            username: 'SariKanarya_Arda',
            avatar: 'fener_10',
            favoriteTeam: 'Fenerbahçe',
            points: 92,
            matchesWon: 12,
            scoreLabel: '92 OVR',
            secondaryLabel: '12 Kupa • 7/10 Penaltı',
          ),
          const LeaderboardEntry(
            rank: 5,
            userId: 'u3',
            username: 'Karakartal_99',
            avatar: 'captain_4',
            favoriteTeam: 'Beşiktaş',
            points: 90,
            matchesWon: 11,
            scoreLabel: '90 OVR',
            secondaryLabel: '11 Kupa • 7/10 Penaltı',
          ),
          const LeaderboardEntry(
            rank: 6,
            userId: 'u7',
            username: 'CityZen_Haaland',
            avatar: 'viking_9',
            favoriteTeam: 'Manchester City',
            points: 89,
            matchesWon: 9,
            scoreLabel: '89 OVR',
            secondaryLabel: '9 Kupa • 6/10 Penaltı',
          ),
        ];

      case LeaderboardModeCategory.commonPlayer:
        return [
          const LeaderboardEntry(
            rank: 1,
            userId: 'u1',
            username: 'Hagi10',
            avatar: 'goat_10',
            favoriteTeam: 'Galatasaray',
            points: 3850,
            matchesWon: 24,
            scoreLabel: '3850 Puan',
            secondaryLabel: '52 Ortak Yıldız',
          ),
          const LeaderboardEntry(
            rank: 2,
            userId: 'u4',
            username: 'SariKanarya_Arda',
            avatar: 'fener_10',
            favoriteTeam: 'Fenerbahçe',
            points: 3420,
            matchesWon: 21,
            scoreLabel: '3420 Puan',
            secondaryLabel: '46 Ortak Yıldız',
          ),
          const LeaderboardEntry(
            rank: 3,
            userId: 'u2',
            username: 'CR7_Efsane',
            avatar: 'striker_7',
            favoriteTeam: 'Real Madrid',
            points: 3190,
            matchesWon: 19,
            scoreLabel: '3190 Puan',
            secondaryLabel: '41 Ortak Yıldız',
          ),
          const LeaderboardEntry(
            rank: 4,
            userId: 'u5',
            username: 'Gunner4Ever',
            avatar: 'wonderkid_19',
            favoriteTeam: 'Arsenal',
            points: 2740,
            matchesWon: 16,
            scoreLabel: '2740 Puan',
            secondaryLabel: '34 Ortak Yıldız',
          ),
          const LeaderboardEntry(
            rank: 5,
            userId: 'u3',
            username: 'Karakartal_99',
            avatar: 'captain_4',
            favoriteTeam: 'Beşiktaş',
            points: 2410,
            matchesWon: 14,
            scoreLabel: '2410 Puan',
            secondaryLabel: '29 Ortak Yıldız',
          ),
        ];

      case LeaderboardModeCategory.fiveClubs:
        return [
          const LeaderboardEntry(
            rank: 1,
            userId: 'u3',
            username: 'Karakartal_99',
            avatar: 'captain_4',
            favoriteTeam: 'Beşiktaş',
            points: 3280,
            matchesWon: 22,
            scoreLabel: '3280 Puan',
            secondaryLabel: '19 Kez 5/5 İsabet',
          ),
          const LeaderboardEntry(
            rank: 2,
            userId: 'u5',
            username: 'Gunner4Ever',
            avatar: 'wonderkid_19',
            favoriteTeam: 'Arsenal',
            points: 2960,
            matchesWon: 18,
            scoreLabel: '2960 Puan',
            secondaryLabel: '16 Kez 5/5 İsabet',
          ),
          const LeaderboardEntry(
            rank: 3,
            userId: 'u1',
            username: 'Hagi10',
            avatar: 'goat_10',
            favoriteTeam: 'Galatasaray',
            points: 2750,
            matchesWon: 17,
            scoreLabel: '2750 Puan',
            secondaryLabel: '15 Kez 5/5 İsabet',
          ),
          const LeaderboardEntry(
            rank: 4,
            userId: 'u7',
            username: 'CityZen_Haaland',
            avatar: 'viking_9',
            favoriteTeam: 'Manchester City',
            points: 2390,
            matchesWon: 14,
            scoreLabel: '2390 Puan',
            secondaryLabel: '12 Kez 5/5 İsabet',
          ),
          const LeaderboardEntry(
            rank: 5,
            userId: 'u2',
            username: 'CR7_Efsane',
            avatar: 'striker_7',
            favoriteTeam: 'Real Madrid',
            points: 2150,
            matchesWon: 12,
            scoreLabel: '2150 Puan',
            secondaryLabel: '11 Kez 5/5 İsabet',
          ),
        ];

      case LeaderboardModeCategory.footballGrid:
        return [
          const LeaderboardEntry(
            rank: 1,
            userId: 'u6',
            username: 'BarcaTikiTaka',
            avatar: 'samba_11',
            favoriteTeam: 'Barcelona',
            points: 4120,
            matchesWon: 27,
            scoreLabel: '4120 Puan',
            secondaryLabel: '81 Hücre Çözüldü',
          ),
          const LeaderboardEntry(
            rank: 2,
            userId: 'u1',
            username: 'Hagi10',
            avatar: 'goat_10',
            favoriteTeam: 'Galatasaray',
            points: 3890,
            matchesWon: 25,
            scoreLabel: '3890 Puan',
            secondaryLabel: '76 Hücre Çözüldü',
          ),
          const LeaderboardEntry(
            rank: 3,
            userId: 'u7',
            username: 'CityZen_Haaland',
            avatar: 'viking_9',
            favoriteTeam: 'Manchester City',
            points: 3540,
            matchesWon: 22,
            scoreLabel: '3540 Puan',
            secondaryLabel: '68 Hücre Çözüldü',
          ),
          const LeaderboardEntry(
            rank: 4,
            userId: 'u2',
            username: 'CR7_Efsane',
            avatar: 'striker_7',
            favoriteTeam: 'Real Madrid',
            points: 3180,
            matchesWon: 19,
            scoreLabel: '3180 Puan',
            secondaryLabel: '61 Hücre Çözüldü',
          ),
          const LeaderboardEntry(
            rank: 5,
            userId: 'u4',
            username: 'SariKanarya_Arda',
            avatar: 'fener_10',
            favoriteTeam: 'Fenerbahçe',
            points: 2840,
            matchesWon: 17,
            scoreLabel: '2840 Puan',
            secondaryLabel: '54 Hücre Çözüldü',
          ),
        ];

      case LeaderboardModeCategory.footballBridge:
        return [
          const LeaderboardEntry(
            rank: 1,
            userId: 'u1',
            username: 'Hagi10',
            avatar: 'goat_10',
            favoriteTeam: 'Galatasaray',
            points: 3640,
            matchesWon: 23,
            scoreLabel: '3640 Puan',
            secondaryLabel: '23 Köprü • Ort. 1.2 Adım',
          ),
          const LeaderboardEntry(
            rank: 2,
            userId: 'u4',
            username: 'SariKanarya_Arda',
            avatar: 'fener_10',
            favoriteTeam: 'Fenerbahçe',
            points: 3310,
            matchesWon: 20,
            scoreLabel: '3310 Puan',
            secondaryLabel: '20 Köprü • Ort. 1.4 Adım',
          ),
          const LeaderboardEntry(
            rank: 3,
            userId: 'u2',
            username: 'CR7_Efsane',
            avatar: 'striker_7',
            favoriteTeam: 'Real Madrid',
            points: 2980,
            matchesWon: 18,
            scoreLabel: '2980 Puan',
            secondaryLabel: '18 Köprü • Ort. 1.5 Adım',
          ),
          const LeaderboardEntry(
            rank: 4,
            userId: 'u3',
            username: 'Karakartal_99',
            avatar: 'captain_4',
            favoriteTeam: 'Beşiktaş',
            points: 2590,
            matchesWon: 15,
            scoreLabel: '2590 Puan',
            secondaryLabel: '15 Köprü • Ort. 1.6 Adım',
          ),
        ];

      case LeaderboardModeCategory.auctionDuel:
        return [
          const LeaderboardEntry(
            rank: 1,
            userId: 'u2',
            username: 'CR7_Efsane',
            avatar: 'striker_7',
            favoriteTeam: 'Real Madrid',
            points: 3920,
            matchesWon: 26,
            scoreLabel: '3920 Puan',
            secondaryLabel: 'Rekor İddia: 11 Oyuncu',
          ),
          const LeaderboardEntry(
            rank: 2,
            userId: 'u3',
            username: 'Karakartal_99',
            avatar: 'captain_4',
            favoriteTeam: 'Beşiktaş',
            points: 3580,
            matchesWon: 22,
            scoreLabel: '3580 Puan',
            secondaryLabel: 'Rekor İddia: 10 Oyuncu',
          ),
          const LeaderboardEntry(
            rank: 3,
            userId: 'u1',
            username: 'Hagi10',
            avatar: 'goat_10',
            favoriteTeam: 'Galatasaray',
            points: 3250,
            matchesWon: 20,
            scoreLabel: '3250 Puan',
            secondaryLabel: 'Rekor İddia: 9 Oyuncu',
          ),
          const LeaderboardEntry(
            rank: 4,
            userId: 'u5',
            username: 'Gunner4Ever',
            avatar: 'wonderkid_19',
            favoriteTeam: 'Arsenal',
            points: 2810,
            matchesWon: 17,
            scoreLabel: '2810 Puan',
            secondaryLabel: 'Rekor İddia: 8 Oyuncu',
          ),
        ];
    }
  }

  List<LeaderboardEntry> _buildFriendsRaw(LeaderboardModeCategory category) {
    switch (category) {
      case LeaderboardModeCategory.overall:
        return [
          const LeaderboardEntry(
            rank: 1,
            userId: 'f1',
            username: 'Mehmet',
            avatar: 'icardi_9',
            favoriteTeam: 'Galatasaray',
            points: 3420,
            matchesWon: 18,
            scoreLabel: '3420 XP',
            secondaryLabel: '18 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 2,
            userId: 'f2',
            username: 'Ahmet',
            avatar: 'fener_10',
            favoriteTeam: 'Fenerbahçe',
            points: 2980,
            matchesWon: 14,
            scoreLabel: '2980 XP',
            secondaryLabel: '14 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 3,
            userId: 'f3',
            username: 'Burak',
            avatar: 'captain_4',
            favoriteTeam: 'Beşiktaş',
            points: 2450,
            matchesWon: 11,
            scoreLabel: '2450 XP',
            secondaryLabel: '11 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 4,
            userId: 'f4',
            username: 'Can',
            avatar: 'wonderkid_19',
            favoriteTeam: 'Real Madrid',
            points: 1890,
            matchesWon: 9,
            scoreLabel: '1890 XP',
            secondaryLabel: '9 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 5,
            userId: 'f5',
            username: 'Kerem',
            avatar: 'pirlo_21',
            favoriteTeam: 'Arsenal',
            points: 1420,
            matchesWon: 7,
            scoreLabel: '1420 XP',
            secondaryLabel: '7 Galibiyet',
          ),
        ];

      case LeaderboardModeCategory.career:
        return [
          const LeaderboardEntry(
            rank: 1,
            userId: 'f1',
            username: 'Mehmet',
            avatar: 'icardi_9',
            favoriteTeam: 'Galatasaray',
            points: 93,
            matchesWon: 13,
            scoreLabel: '93 OVR',
            secondaryLabel: '13 Kupa • Efsane',
          ),
          const LeaderboardEntry(
            rank: 2,
            userId: 'f2',
            username: 'Ahmet',
            avatar: 'fener_10',
            favoriteTeam: 'Fenerbahçe',
            points: 91,
            matchesWon: 10,
            scoreLabel: '91 OVR',
            secondaryLabel: '10 Kupa • Yıldız',
          ),
          const LeaderboardEntry(
            rank: 3,
            userId: 'f3',
            username: 'Burak',
            avatar: 'captain_4',
            favoriteTeam: 'Beşiktaş',
            points: 89,
            matchesWon: 8,
            scoreLabel: '89 OVR',
            secondaryLabel: '8 Kupa • Kaptan',
          ),
          const LeaderboardEntry(
            rank: 4,
            userId: 'f4',
            username: 'Can',
            avatar: 'wonderkid_19',
            favoriteTeam: 'Real Madrid',
            points: 87,
            matchesWon: 6,
            scoreLabel: '87 OVR',
            secondaryLabel: '6 Kupa',
          ),
        ];

      default:
        return [
          const LeaderboardEntry(
            rank: 1,
            userId: 'f1',
            username: 'Mehmet',
            avatar: 'icardi_9',
            favoriteTeam: 'Galatasaray',
            points: 1680,
            matchesWon: 12,
            scoreLabel: '1680 Puan',
            secondaryLabel: '12 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 2,
            userId: 'f2',
            username: 'Ahmet',
            avatar: 'fener_10',
            favoriteTeam: 'Fenerbahçe',
            points: 1440,
            matchesWon: 10,
            scoreLabel: '1440 Puan',
            secondaryLabel: '10 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 3,
            userId: 'f3',
            username: 'Burak',
            avatar: 'captain_4',
            favoriteTeam: 'Beşiktaş',
            points: 1210,
            matchesWon: 8,
            scoreLabel: '1210 Puan',
            secondaryLabel: '8 Galibiyet',
          ),
          const LeaderboardEntry(
            rank: 4,
            userId: 'f4',
            username: 'Can',
            avatar: 'wonderkid_19',
            favoriteTeam: 'Real Madrid',
            points: 980,
            matchesWon: 6,
            scoreLabel: '980 Puan',
            secondaryLabel: '6 Galibiyet',
          ),
        ];
    }
  }
}
