import 'package:flutter/foundation.dart';
import '../core/services/supabase_service.dart';
import '../data/models/leaderboard_entry.dart';
import '../data/models/user_model.dart';
import '../data/repositories/leaderboard_repository.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardRepository _repo = LeaderboardRepository();

  bool _isFriendsTab = false;
  LeaderboardModeCategory _selectedCategory = LeaderboardModeCategory.overall;
  List<LeaderboardEntry> _currentEntries = [];

  bool get isFriendsTab => _isFriendsTab;
  LeaderboardModeCategory get selectedCategory => _selectedCategory;
  List<LeaderboardEntry> get currentList => _currentEntries;

  void setFriendsTab(bool value, UserModel? currentUser) {
    _isFriendsTab = value;
    loadRankings(currentUser);
  }

  void setModeCategory(LeaderboardModeCategory category, UserModel? currentUser) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    loadRankings(currentUser);
  }

  void loadRankings(UserModel? currentUser) {
    _currentEntries = _repo.getRankings(
      currentUser: currentUser,
      category: _selectedCategory,
      friendsOnly: _isFriendsTab,
    );
    notifyListeners();

    if (!_isFriendsTab &&
        _selectedCategory == LeaderboardModeCategory.overall &&
        SupabaseService.instance.isReady) {
      _syncRemoteOverallLeaderboard(currentUser);
    }
  }

  Future<void> _syncRemoteOverallLeaderboard(UserModel? currentUser) async {
    final remoteUsers = await SupabaseService.instance.fetchTopProfiles(limit: 25);
    if (remoteUsers.isEmpty) return;

    final merged = <String, LeaderboardEntry>{
      for (final e in _currentEntries) e.userId: e,
    };

    for (final u in remoteUsers) {
      final isMe = currentUser != null && u.id == currentUser.id;
      merged[u.id] = LeaderboardEntry(
        rank: 0,
        userId: u.id,
        username: isMe ? '${u.username} (Sen)' : u.username,
        avatar: u.avatar,
        favoriteTeam: u.favoriteTeam,
        points: u.points,
        matchesWon: u.matchesWon,
        scoreLabel: '${u.points} XP',
        secondaryLabel: '${u.matchesWon} Galibiyet',
        isCurrentUser: isMe,
      );
    }

    final sorted = merged.values.toList()
      ..sort((a, b) => b.points.compareTo(a.points));

    _currentEntries = List.generate(sorted.length, (i) {
      final e = sorted[i];
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
    notifyListeners();
  }
}
