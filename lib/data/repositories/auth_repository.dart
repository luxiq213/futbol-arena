import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthRepository {
  static const String _userKey = 'futbol_party_active_user';
  final _uuid = const Uuid();

  /// Retrieve active saved user session
  Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Save or update user
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  /// Guest Login (Instant play)
  Future<UserModel> loginAsGuest({String? chosenTeam}) async {
    final randomDigits = DateTime.now().millisecondsSinceEpoch % 10000;
    final guest = UserModel(
      id: _uuid.v4(),
      username: 'Futbolcu_$randomDigits',
      email: 'guest_$randomDigits@futtrivia.local',
      avatar: 'KP',
      favoriteTeam: chosenTeam ?? 'Galatasaray',
      points: 250,
      matchesPlayed: 1,
      matchesWon: 1,
      currentStreak: 1,
      isGuest: true,
    );
    await saveUser(guest);
    return guest;
  }

  /// Register new user (preserving any earned guest XP/stats)
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String favoriteTeam,
    required String avatar,
  }) async {
    final existing = await getSavedUser();
    final user = UserModel(
      id: existing?.id ?? _uuid.v4(),
      username: username.trim(),
      email: email.trim(),
      avatar: avatar,
      favoriteTeam: favoriteTeam,
      points: (existing != null && existing.points > 500) ? existing.points : 500,
      matchesPlayed: existing?.matchesPlayed ?? 0,
      matchesWon: existing?.matchesWon ?? 0,
      currentStreak: existing?.currentStreak ?? 0,
      isGuest: false,
      isAdFree: existing?.isAdFree ?? false,
    );
    await saveUser(user);
    return user;
  }

  /// Login existing user
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // In local / prototype mode, check saved or create session
    final saved = await getSavedUser();
    if (saved != null && (saved.email == email || saved.username == email)) {
      final upgraded = saved.copyWith(isGuest: false);
      await saveUser(upgraded);
      return upgraded;
    }

    final name = email.split('@').first;
    final user = UserModel(
      id: _uuid.v4(),
      username: name.isEmpty ? 'Kaptan' : name,
      email: email,
      avatar: 'KP',
      favoriteTeam: 'Real Madrid',
      points: 1250,
      matchesPlayed: 8,
      matchesWon: 6,
      currentStreak: 3,
      isGuest: false,
    );
    await saveUser(user);
    return user;
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
