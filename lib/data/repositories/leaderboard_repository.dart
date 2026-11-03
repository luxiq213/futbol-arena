import '../models/leaderboard_entry.dart';
import '../models/user_model.dart';

class LeaderboardRepository {
  List<LeaderboardEntry> getGlobalRankings(UserModel? currentUser) {
    final List<LeaderboardEntry> entries = [
      const LeaderboardEntry(
        rank: 1,
        userId: 'u1',
        username: 'Hagi10',
        avatar: '👑',
        favoriteTeam: 'Galatasaray',
        points: 8420,
        matchesWon: 45,
      ),
      const LeaderboardEntry(
        rank: 2,
        userId: 'u2',
        username: 'CR7_TheGoat',
        avatar: '⚡',
        favoriteTeam: 'Real Madrid',
        points: 7650,
        matchesWon: 39,
      ),
      const LeaderboardEntry(
        rank: 3,
        userId: 'u3',
        username: 'Karakartal_99',
        avatar: '🦅',
        favoriteTeam: 'Beşiktaş',
        points: 6890,
        matchesWon: 34,
      ),
      const LeaderboardEntry(
        rank: 4,
        userId: 'u4',
        username: 'SarıKanarya_Arda',
        avatar: '🎯',
        favoriteTeam: 'Fenerbahçe',
        points: 5920,
        matchesWon: 29,
      ),
      const LeaderboardEntry(
        rank: 5,
        userId: 'u5',
        username: 'Gunner4Ever',
        avatar: '🔥',
        favoriteTeam: 'Arsenal',
        points: 5410,
        matchesWon: 26,
      ),
      const LeaderboardEntry(
        rank: 6,
        userId: 'u6',
        username: 'BarcaTikiTaka',
        avatar: '⚽',
        favoriteTeam: 'Barcelona',
        points: 4800,
        matchesWon: 22,
      ),
      const LeaderboardEntry(
        rank: 7,
        userId: 'u7',
        username: 'CityZen_Haaland',
        avatar: '🤖',
        favoriteTeam: 'Manchester City',
        points: 4210,
        matchesWon: 19,
      ),
    ];

    if (currentUser != null) {
      // Insert current user based on points
      final userEntry = LeaderboardEntry(
        rank: 0,
        userId: currentUser.id,
        username: '${currentUser.username} (Sen)',
        avatar: currentUser.avatar,
        favoriteTeam: currentUser.favoriteTeam,
        points: currentUser.points,
        matchesWon: currentUser.matchesWon,
        isCurrentUser: true,
      );

      entries.add(userEntry);
      entries.sort((a, b) => b.points.compareTo(a.points));

      // Re-assign ranks
      final ranked = <LeaderboardEntry>[];
      for (int i = 0; i < entries.length; i++) {
        final e = entries[i];
        ranked.add(LeaderboardEntry(
          rank: i + 1,
          userId: e.userId,
          username: e.username,
          avatar: e.avatar,
          favoriteTeam: e.favoriteTeam,
          points: e.points,
          matchesWon: e.matchesWon,
          isCurrentUser: e.isCurrentUser,
        ));
      }
      return ranked;
    }

    return entries;
  }

  List<LeaderboardEntry> getFriendsRankings(UserModel? currentUser) {
    final List<LeaderboardEntry> friends = [
      const LeaderboardEntry(
        rank: 1,
        userId: 'f1',
        username: 'Mehmet',
        avatar: '🦁',
        favoriteTeam: 'Galatasaray',
        points: 3420,
        matchesWon: 18,
      ),
      const LeaderboardEntry(
        rank: 2,
        userId: 'f2',
        username: 'Ahmet',
        avatar: '⚽',
        favoriteTeam: 'Fenerbahçe',
        points: 2980,
        matchesWon: 14,
      ),
      const LeaderboardEntry(
        rank: 3,
        userId: 'f3',
        username: 'Burak',
        avatar: '🦅',
        favoriteTeam: 'Beşiktaş',
        points: 2450,
        matchesWon: 11,
      ),
      const LeaderboardEntry(
        rank: 4,
        userId: 'f4',
        username: 'Can',
        avatar: '⚡',
        favoriteTeam: 'Real Madrid',
        points: 1890,
        matchesWon: 9,
      ),
      const LeaderboardEntry(
        rank: 5,
        userId: 'f5',
        username: 'Kerem',
        avatar: '🎯',
        favoriteTeam: 'Arsenal',
        points: 1420,
        matchesWon: 7,
      ),
    ];

    if (currentUser != null) {
      final userEntry = LeaderboardEntry(
        rank: 0,
        userId: currentUser.id,
        username: '${currentUser.username} (Sen)',
        avatar: currentUser.avatar,
        favoriteTeam: currentUser.favoriteTeam,
        points: currentUser.points,
        matchesWon: currentUser.matchesWon,
        isCurrentUser: true,
      );

      friends.add(userEntry);
      friends.sort((a, b) => b.points.compareTo(a.points));

      final ranked = <LeaderboardEntry>[];
      for (int i = 0; i < friends.length; i++) {
        final e = friends[i];
        ranked.add(LeaderboardEntry(
          rank: i + 1,
          userId: e.userId,
          username: e.username,
          avatar: e.avatar,
          favoriteTeam: e.favoriteTeam,
          points: e.points,
          matchesWon: e.matchesWon,
          isCurrentUser: e.isCurrentUser,
        ));
      }
      return ranked;
    }

    return friends;
  }
}
