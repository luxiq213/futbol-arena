import 'package:flutter/foundation.dart';
import '../data/models/leaderboard_entry.dart';
import '../data/models/user_model.dart';
import '../data/repositories/leaderboard_repository.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardRepository _repo = LeaderboardRepository();

  bool _isFriendsTab = false;
  List<LeaderboardEntry> _globalList = [];
  List<LeaderboardEntry> _friendsList = [];

  bool get isFriendsTab => _isFriendsTab;
  List<LeaderboardEntry> get currentList => _isFriendsTab ? _friendsList : _globalList;

  void setFriendsTab(bool value, UserModel? currentUser) {
    _isFriendsTab = value;
    loadRankings(currentUser);
    notifyListeners();
  }

  void loadRankings(UserModel? currentUser) {
    _globalList = _repo.getGlobalRankings(currentUser);
    _friendsList = _repo.getFriendsRankings(currentUser);
    notifyListeners();
  }
}
