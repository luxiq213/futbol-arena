import 'package:flutter/foundation.dart';
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
  }
}
