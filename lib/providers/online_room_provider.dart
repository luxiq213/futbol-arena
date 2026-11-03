import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/models/game_room_model.dart';
import '../data/models/user_model.dart';

class OnlineRoomProvider extends ChangeNotifier {
  GameRoomModel? _activeRoom;
  bool _isCreatingRoom = false;
  String? _errorMessage;

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

  /// Create a new lobby
  Future<void> createRoom(UserModel hostUser) async {
    _isCreatingRoom = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final code = _generateRoomCode();
    final hostParticipant = RoomParticipant(
      id: hostUser.id,
      name: hostUser.username,
      avatar: hostUser.avatar,
      isHost: true,
      isReady: true,
    );

    // Mock 1 or 2 friends waiting or ready to join
    final friend1 = const RoomParticipant(
      id: 'mock_friend_1',
      name: 'Burak',
      avatar: '🦅',
      isHost: false,
      isReady: true,
    );

    _activeRoom = GameRoomModel(
      code: code,
      hostId: hostUser.id,
      gameTitle: 'Ortak Futbolcu Düellosu',
      participants: [hostParticipant, friend1],
      status: GameRoomStatus.waiting,
    );

    _isCreatingRoom = false;
    notifyListeners();
  }

  /// Join existing room
  Future<bool> joinRoom(String code, UserModel user) async {
    _isCreatingRoom = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.length < 4) {
      _errorMessage = 'Geçersiz oda kodu!';
      _isCreatingRoom = false;
      notifyListeners();
      return false;
    }

    final newParticipant = RoomParticipant(
      id: user.id,
      name: user.username,
      avatar: user.avatar,
      isHost: false,
      isReady: false,
    );

    final mockHost = const RoomParticipant(
      id: 'mock_host',
      name: 'Ahmet (Lobi Lideri)',
      avatar: '⚽',
      isHost: true,
      isReady: true,
    );

    _activeRoom = GameRoomModel(
      code: cleanCode,
      hostId: 'mock_host',
      gameTitle: '3-2-1 Bomba Online',
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
    notifyListeners();
  }

  void leaveRoom() {
    _activeRoom = null;
    _errorMessage = null;
    notifyListeners();
  }
}
