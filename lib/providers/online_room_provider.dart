import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../core/services/supabase_service.dart';
import '../data/models/game_room_model.dart';
import '../data/models/play_mode_model.dart';
import '../data/models/user_model.dart';

class OnlineRoomProvider extends ChangeNotifier {
  GameRoomModel? _activeRoom;
  bool _isCreatingRoom = false;
  String? _errorMessage;
  StreamSubscription<List<Map<String, dynamic>>>? _roomSubscription;

  GameRoomModel? get activeRoom => _activeRoom;
  bool get isCreatingRoom => _isCreatingRoom;
  String? get errorMessage => _errorMessage;
  bool get isInRoom => _activeRoom != null;

  /// Generate a memorable 6-character code e.g. "FTB742"
  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    final randomPart = List.generate(5, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'F$randomPart';
  }

  void _listenToRoomStream(String code) {
    _roomSubscription?.cancel();
    _roomSubscription = SupabaseService.instance.subscribeToRoom(code, (updatedRoom) {
      _activeRoom = updatedRoom;
      notifyListeners();
    });
  }

  /// Create a new lobby for the selected game mode (Supabase Realtime + Local Fallback)
  Future<void> createRoom(
    UserModel hostUser, {
    GameTargetType targetGame = GameTargetType.commonPlayer,
  }) async {
    _isCreatingRoom = true;
    _errorMessage = null;
    notifyListeners();

    final code = _generateRoomCode();
    final hostParticipant = RoomParticipant(
      id: hostUser.id,
      name: hostUser.username,
      avatar: hostUser.avatar,
      isHost: true,
      isReady: true,
    );

    if (SupabaseService.instance.isReady) {
      final initialRoom = GameRoomModel(
        code: code,
        hostId: hostUser.id,
        gameTitle: targetGame.title,
        targetGame: targetGame,
        participants: [hostParticipant],
        status: GameRoomStatus.waiting,
      );
      final ok = await SupabaseService.instance.createOnlineRoom(initialRoom);
      if (ok) {
        _activeRoom = initialRoom;
        _listenToRoomStream(code);
        _isCreatingRoom = false;
        notifyListeners();
        return;
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));

    // Local fallback when Supabase credentials are not yet set
    const friend1 = RoomParticipant(
      id: 'mock_friend_1',
      name: 'Burak',
      avatar: 'BK',
      isHost: false,
      isReady: true,
    );

    _activeRoom = GameRoomModel(
      code: code,
      hostId: hostUser.id,
      gameTitle: targetGame.title,
      targetGame: targetGame,
      participants: [hostParticipant, friend1],
      status: GameRoomStatus.waiting,
    );

    _isCreatingRoom = false;
    notifyListeners();
  }

  /// Join existing room (Supabase Realtime + Local Fallback)
  Future<bool> joinRoom(
    String code,
    UserModel user, {
    GameTargetType targetGame = GameTargetType.commonPlayer,
  }) async {
    _isCreatingRoom = true;
    _errorMessage = null;
    notifyListeners();

    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.length < 4) {
      _errorMessage = 'Geçersiz oda kodu! Lütfen en az 4 karakter girin.';
      _isCreatingRoom = false;
      notifyListeners();
      return false;
    }

    final newParticipant = RoomParticipant(
      id: user.id,
      name: user.username,
      avatar: user.avatar,
      isHost: false,
      isReady: true,
    );

    if (SupabaseService.instance.isReady) {
      final joinedRoom = await SupabaseService.instance.joinOnlineRoom(
        code: cleanCode,
        participant: newParticipant,
      );
      if (joinedRoom != null) {
        _activeRoom = joinedRoom;
        _listenToRoomStream(cleanCode);
        _isCreatingRoom = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Bu davet koduyla aktif bir oda bulunamadı.';
        _isCreatingRoom = false;
        notifyListeners();
        return false;
      }
    }

    await Future.delayed(const Duration(milliseconds: 500));

    const mockHost = RoomParticipant(
      id: 'mock_host',
      name: 'Ahmet',
      avatar: 'AH',
      isHost: true,
      isReady: true,
    );

    _activeRoom = GameRoomModel(
      code: cleanCode,
      hostId: 'mock_host',
      gameTitle: targetGame.title,
      targetGame: targetGame,
      participants: [mockHost, newParticipant],
      status: GameRoomStatus.waiting,
    );

    _isCreatingRoom = false;
    notifyListeners();
    return true;
  }

  void toggleReady(String userId) {
    if (_activeRoom == null) return;
    final updatedParticipants = _activeRoom!.participants.map((p) {
      if (p.id == userId) {
        return p.copyWith(isReady: !p.isReady);
      }
      return p;
    }).toList();

    _activeRoom = _activeRoom!.copyWith(participants: updatedParticipants);
    SupabaseService.instance.updateOnlineRoom(_activeRoom!);
    notifyListeners();
  }

  void leaveRoom() {
    _roomSubscription?.cancel();
    _roomSubscription = null;
    _activeRoom = null;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }
}
