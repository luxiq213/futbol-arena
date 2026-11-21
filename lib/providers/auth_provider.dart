import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/iap_service.dart';
import '../core/services/supabase_service.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();
  UserModel? _currentUser;
  bool _isLoading = true;
  String? _lastAuthError;
  StreamSubscription<AuthState>? _authSub;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get lastAuthError => _lastAuthError;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadUser();
    _authSub = SupabaseService.instance.authStateChanges.listen((state) async {
      if (state.event == AuthChangeEvent.signedIn && state.session?.user != null) {
        final authUser = state.session!.user;
        if (_currentUser != null && !_currentUser!.isGuest && _currentUser!.id == authUser.id) {
          return;
        }
        final pts = (_currentUser != null && _currentUser!.points > 500)
            ? _currentUser!.points
            : 500;
        final resolved = await SupabaseService.instance.resolveUserFromAuthUser(
          authUser,
          initialPoints: pts,
        );
        if (resolved != null) {
          _currentUser = resolved;
          await _repo.saveUser(resolved);
          _isLoading = false;
          notifyListeners();
        }
      }
    });
    IapService.instance.initialize(
      onAdFreeEntitlementGranted: () async {
        await setAdFreeMode(true);
      },
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await _repo.getSavedUser();
    if (_currentUser != null && !_currentUser!.isGuest && SupabaseService.instance.isReady) {
      final remote = await SupabaseService.instance.fetchUserProfile(_currentUser!.id);
      if (remote != null) {
        _currentUser = remote;
        await _repo.saveUser(remote);
      }
    }
    // If first launch, create a guest player right away so app is immediately playable
    _currentUser ??= await _repo.loginAsGuest();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginAsGuest({String? favoriteTeam}) async {
    _isLoading = true;
    notifyListeners();
    _currentUser = await _repo.loginAsGuest(chosenTeam: favoriteTeam);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (SupabaseService.instance.isReady) {
        final remoteUser = await SupabaseService.instance.loginWithEmail(
          email: email,
          password: password,
        );
        if (remoteUser != null) {
          _currentUser = remoteUser;
          await _repo.saveUser(remoteUser);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _currentUser = await _repo.login(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastAuthError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithApple() async {
    _isLoading = true;
    _lastAuthError = null;
    notifyListeners();
    try {
      final pts = (_currentUser != null && _currentUser!.points > 500)
          ? _currentUser!.points
          : 500;
      final remoteUser = await SupabaseService.instance.signInWithApple(
        initialPoints: pts,
      );
      if (remoteUser != null) {
        _currentUser = remoteUser;
        await _repo.saveUser(remoteUser);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _lastAuthError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _lastAuthError = null;
    notifyListeners();
    try {
      final launched = await SupabaseService.instance.signInWithGoogleOAuth();
      _isLoading = false;
      notifyListeners();
      return launched;
    } catch (e) {
      _lastAuthError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String favoriteTeam,
    required String avatar,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (SupabaseService.instance.isReady) {
        final remoteUser = await SupabaseService.instance.registerWithEmail(
          username: username,
          email: email,
          password: password,
          favoriteTeam: favoriteTeam,
          avatar: avatar,
          initialPoints: (_currentUser != null && _currentUser!.points > 500)
              ? _currentUser!.points
              : 500,
        );
        if (remoteUser != null) {
          _currentUser = remoteUser;
          await _repo.saveUser(remoteUser);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _currentUser = await _repo.register(
        username: username,
        email: email,
        password: password,
        favoriteTeam: favoriteTeam,
        avatar: avatar,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastAuthError = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> addPoints(int earnedPoints, {bool won = false}) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      points: _currentUser!.points + earnedPoints,
      matchesPlayed: _currentUser!.matchesPlayed + 1,
      matchesWon: won ? _currentUser!.matchesWon + 1 : _currentUser!.matchesWon,
      currentStreak: won ? _currentUser!.currentStreak + 1 : 0,
    );
    _currentUser = updated;
    await _repo.saveUser(updated);
    await SupabaseService.instance.upsertUserProfile(updated);
    notifyListeners();
  }

  Future<void> updateProfile({
    String? username,
    String? favoriteTeam,
    String? avatar,
  }) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(
      username: username,
      favoriteTeam: favoriteTeam,
      avatar: avatar,
    );
    _currentUser = updated;
    await _repo.saveUser(updated);
    await SupabaseService.instance.upsertUserProfile(updated);
    notifyListeners();
  }

  Future<bool> setAdFreeMode(bool isAdFree) async {
    if (_currentUser == null) return false;
    if (isAdFree && _currentUser!.isGuest) {
      return false;
    }
    final updated = _currentUser!.copyWith(isAdFree: isAdFree);
    _currentUser = updated;
    await _repo.saveUser(updated);
    await SupabaseService.instance.upsertUserProfile(updated);
    notifyListeners();
    return true;
  }

  /// Launches Apple StoreKit / Google Play Billing non-consumable purchase flow
  Future<bool> purchaseAdFree() async {
    if (_currentUser == null || _currentUser!.isGuest) {
      return false;
    }
    if (IapService.instance.isStoreAvailable && IapService.instance.adFreeProduct != null) {
      return await IapService.instance.buyAdFree();
    }
    return await setAdFreeMode(true);
  }

  Future<bool> restorePurchases() async {
    if (_currentUser == null || _currentUser!.isGuest) {
      return false;
    }
    if (IapService.instance.isStoreAvailable) {
      return await IapService.instance.restorePurchases();
    }
    final updated = _currentUser!.copyWith(isAdFree: true);
    _currentUser = updated;
    await _repo.saveUser(updated);
    await SupabaseService.instance.upsertUserProfile(updated);
    notifyListeners();
    return true;
  }

  Future<void> deleteAccount() async {
    final userId = _currentUser?.id;
    if (userId != null && !(_currentUser?.isGuest ?? true)) {
      await SupabaseService.instance.deleteUserAccount(userId);
    }
    await _repo.logout();
    _currentUser = await _repo.loginAsGuest();
    notifyListeners();
  }

  Future<void> logout() async {
    await SupabaseService.instance.signOut();
    await _repo.logout();
    _currentUser = null;
    notifyListeners();
  }
}
