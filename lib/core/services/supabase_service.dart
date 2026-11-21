import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/game_room_model.dart';
import '../../data/models/play_mode_model.dart';
import '../../data/models/user_model.dart';
import '../config/app_config.dart';

/// Manages Supabase Auth, Postgres (`profiles`, `online_rooms`), and Realtime channels.
/// Automatically falls back to local mode when [AppConfig.isSupabaseConfigured] is false.
class SupabaseService {
  SupabaseService._();
  static final SupabaseService instance = SupabaseService._();

  bool _initialized = false;
  bool get isReady => _initialized && AppConfig.isSupabaseConfigured;

  SupabaseClient get _client => Supabase.instance.client;

  Stream<AuthState> get authStateChanges =>
      isReady ? _client.auth.onAuthStateChange : const Stream.empty();

  Future<void> initialize() async {
    if (_initialized || !AppConfig.isSupabaseConfigured) return;
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: AppConfig.supabaseAnonKey,
      );
      _initialized = true;
    } catch (e) {
      debugPrint('Supabase initialization skipped/failed: $e');
      _initialized = false;
    }
  }

  // ===========================================================================
  // AUTHENTICATION & USER PROFILES (`public.profiles`)
  // ===========================================================================

  Future<UserModel?> registerWithEmail({
    required String username,
    required String email,
    required String password,
    required String favoriteTeam,
    required String avatar,
    int initialPoints = 500,
  }) async {
    if (!isReady) return null;

    final res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'username': username.trim(),
        'favorite_team': favoriteTeam,
        'avatar': avatar,
      },
    );

    final authUser = res.user;
    if (authUser == null) return null;

    final userModel = UserModel(
      id: authUser.id,
      username: username.trim(),
      email: email.trim(),
      avatar: avatar,
      favoriteTeam: favoriteTeam,
      points: initialPoints,
      matchesPlayed: 0,
      matchesWon: 0,
      currentStreak: 0,
      isGuest: false,
      isAdFree: false,
    );

    await upsertUserProfile(userModel);
    return userModel;
  }

  Future<UserModel?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isReady) return null;

    final res = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final authUser = res.user;
    if (authUser == null) return null;

    final profile = await fetchUserProfile(authUser.id);
    if (profile != null) return profile;

    final fallback = UserModel(
      id: authUser.id,
      username: authUser.userMetadata?['username']?.toString() ?? email.split('@').first,
      email: authUser.email ?? email.trim(),
      avatar: authUser.userMetadata?['avatar']?.toString() ?? 'goat_10',
      favoriteTeam: authUser.userMetadata?['favorite_team']?.toString() ?? 'Galatasaray',
      points: 500,
      isGuest: false,
    );
    await upsertUserProfile(fallback);
    return fallback;
  }

  /// Resolves or initializes a `UserModel` row in `public.profiles` from any Supabase Auth [User].
  Future<UserModel?> resolveUserFromAuthUser(
    User authUser, {
    String? preferredName,
    int initialPoints = 500,
  }) async {
    if (!isReady) return null;
    final existing = await fetchUserProfile(authUser.id);
    if (existing != null) return existing;

    final metaName = preferredName?.trim().isNotEmpty == true
        ? preferredName!.trim()
        : (authUser.userMetadata?['full_name']?.toString() ??
            authUser.userMetadata?['name']?.toString() ??
            authUser.userMetadata?['username']?.toString() ??
            authUser.email?.split('@').first ??
            'Kaptan');

    final userModel = UserModel(
      id: authUser.id,
      username: metaName.trim().isNotEmpty ? metaName.trim() : 'Kaptan',
      email: authUser.email ?? '',
      avatar: authUser.userMetadata?['avatar']?.toString() ?? 'goat_10',
      favoriteTeam:
          authUser.userMetadata?['favorite_team']?.toString() ?? 'Galatasaray',
      points: initialPoints,
      isGuest: false,
    );
    await upsertUserProfile(userModel);
    return userModel;
  }

  /// Native iOS Sign in with Apple -> authenticates directly with Supabase ID token.
  Future<UserModel?> signInWithApple({int initialPoints = 500}) async {
    if (!isReady) return null;

    final rawNonce = _client.auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null || idToken.isEmpty) {
      throw const AuthException('Apple kimlik belirteci alınamadı.');
    }

    final res = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
    final authUser = res.user;
    if (authUser == null) return null;

    final given = credential.givenName?.trim() ?? '';
    final family = credential.familyName?.trim() ?? '';
    final fullName = [given, family].where((s) => s.isNotEmpty).join(' ');

    return resolveUserFromAuthUser(
      authUser,
      preferredName: fullName.isNotEmpty ? fullName : null,
      initialPoints: initialPoints,
    );
  }

  /// Google OAuth via Supabase Auth in-app web session (`io.supabase.futbolarena://login-callback/`).
  Future<bool> signInWithGoogleOAuth() async {
    if (!isReady) return false;
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.futbolarena://login-callback/',
      authScreenLaunchMode: LaunchMode.inAppBrowserView,
    );
  }

  Future<UserModel?> fetchUserProfile(String userId) async {
    if (!isReady) return null;
    try {
      final row = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return null;
      return _userFromRow(row);
    } catch (e) {
      debugPrint('Supabase fetchUserProfile error: $e');
      return null;
    }
  }

  Future<void> upsertUserProfile(UserModel user) async {
    if (!isReady || user.isGuest) return;
    try {
      await _client.from('profiles').upsert({
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'avatar': user.avatar,
        'favorite_team': user.favoriteTeam,
        'points': user.points,
        'matches_played': user.matchesPlayed,
        'matches_won': user.matchesWon,
        'current_streak': user.currentStreak,
        'is_ad_free': user.isAdFree,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Supabase upsertUserProfile error: $e');
    }
  }

  /// Permanently deletes the user's profile & auth account (Apple Guideline 5.1.1(v))
  Future<void> deleteUserAccount(String userId) async {
    if (!isReady) return;
    try {
      await _client.from('profiles').delete().eq('id', userId);
    } catch (e) {
      debugPrint('Supabase delete profile row error: $e');
    }
    try {
      await _client.rpc('delete_own_user');
    } catch (e) {
      debugPrint('Supabase delete_own_user rpc skipped/error: $e');
    }
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }

  Future<void> signOut() async {
    if (!isReady) return;
    try {
      await _client.auth.signOut();
    } catch (_) {}
  }

  // ===========================================================================
  // GLOBAL LEADERBOARD (`public.profiles`)
  // ===========================================================================

  Future<List<UserModel>> fetchTopProfiles({int limit = 25}) async {
    if (!isReady) return const [];
    try {
      final rows = await _client
          .from('profiles')
          .select()
          .order('points', ascending: false)
          .limit(limit);
      return (rows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(_userFromRow)
          .toList();
    } catch (e) {
      debugPrint('Supabase fetchTopProfiles error: $e');
      return const [];
    }
  }

  UserModel _userFromRow(Map<String, dynamic> row) {
    return UserModel(
      id: row['id']?.toString() ?? '',
      username: row['username']?.toString() ?? 'Kaptan',
      email: row['email']?.toString() ?? '',
      avatar: row['avatar']?.toString() ?? 'goat_10',
      favoriteTeam: row['favorite_team']?.toString() ?? 'Galatasaray',
      points: (row['points'] as num?)?.toInt() ?? 0,
      matchesPlayed: (row['matches_played'] as num?)?.toInt() ?? 0,
      matchesWon: (row['matches_won'] as num?)?.toInt() ?? 0,
      currentStreak: (row['current_streak'] as num?)?.toInt() ?? 0,
      isGuest: false,
      isAdFree: row['is_ad_free'] == true,
    );
  }

  // ===========================================================================
  // REALTIME ONLINE INVITE ROOMS (`public.online_rooms`)
  // ===========================================================================

  Future<bool> createOnlineRoom(GameRoomModel room) async {
    if (!isReady) return false;
    try {
      await _client.from('online_rooms').upsert(_roomToRow(room));
      return true;
    } catch (e) {
      debugPrint('Supabase createOnlineRoom error: $e');
      return false;
    }
  }

  Future<GameRoomModel?> joinOnlineRoom({
    required String code,
    required RoomParticipant participant,
  }) async {
    if (!isReady) return null;
    try {
      final cleanCode = code.trim().toUpperCase();
      final row = await _client
          .from('online_rooms')
          .select()
          .eq('code', cleanCode)
          .maybeSingle();
      if (row == null) return null;

      final existingRoom = _roomFromRow(row);
      final updatedParticipants = List<RoomParticipant>.from(existingRoom.participants);
      final existingIdx = updatedParticipants.indexWhere((p) => p.id == participant.id);
      if (existingIdx >= 0) {
        updatedParticipants[existingIdx] = participant;
      } else {
        updatedParticipants.add(participant);
      }

      final updatedRoom = existingRoom.copyWith(participants: updatedParticipants);
      await _client
          .from('online_rooms')
          .update(_roomToRow(updatedRoom))
          .eq('code', cleanCode);
      return updatedRoom;
    } catch (e) {
      debugPrint('Supabase joinOnlineRoom error: $e');
      return null;
    }
  }

  Future<void> updateOnlineRoom(GameRoomModel room) async {
    if (!isReady) return;
    try {
      await _client
          .from('online_rooms')
          .update(_roomToRow(room))
          .eq('code', room.code);
    } catch (e) {
      debugPrint('Supabase updateOnlineRoom error: $e');
    }
  }

  StreamSubscription<List<Map<String, dynamic>>>? subscribeToRoom(
    String code,
    void Function(GameRoomModel updatedRoom) onUpdate,
  ) {
    if (!isReady) return null;
    final cleanCode = code.trim().toUpperCase();
    return _client
        .from('online_rooms')
        .stream(primaryKey: ['code'])
        .eq('code', cleanCode)
        .listen((rows) {
          if (rows.isNotEmpty) {
            onUpdate(_roomFromRow(rows.first));
          }
        });
  }

  Map<String, dynamic> _roomToRow(GameRoomModel room) {
    return {
      'code': room.code,
      'host_id': room.hostId,
      'game_title': room.gameTitle,
      'target_game': room.targetGame.name,
      'status': room.status.name,
      'participants': room.participants
          .map((p) => {
                'id': p.id,
                'name': p.name,
                'avatar': p.avatar,
                'isHost': p.isHost,
                'isReady': p.isReady,
                'score': p.score,
                'lives': p.lives,
              })
          .toList(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  GameRoomModel _roomFromRow(Map<String, dynamic> row) {
    final targetName = row['target_game']?.toString() ?? '';
    final targetGame = GameTargetType.values.firstWhere(
      (e) => e.name == targetName,
      orElse: () => GameTargetType.commonPlayer,
    );
    final statusName = row['status']?.toString() ?? '';
    final status = GameRoomStatus.values.firstWhere(
      (e) => e.name == statusName,
      orElse: () => GameRoomStatus.waiting,
    );

    final rawList = (row['participants'] as List<dynamic>?) ?? const [];
    final participants = rawList.whereType<Map<String, dynamic>>().map((p) {
      return RoomParticipant(
        id: p['id']?.toString() ?? '',
        name: p['name']?.toString() ?? 'Oyuncu',
        avatar: p['avatar']?.toString() ?? 'KP',
        isHost: p['isHost'] == true,
        isReady: p['isReady'] == true,
        score: (p['score'] as num?)?.toInt() ?? 0,
        lives: (p['lives'] as num?)?.toInt() ?? 3,
      );
    }).toList();

    return GameRoomModel(
      code: row['code']?.toString() ?? '',
      hostId: row['host_id']?.toString() ?? '',
      gameTitle: row['game_title']?.toString() ?? targetGame.title,
      targetGame: targetGame,
      participants: participants,
      status: status,
    );
  }
}
