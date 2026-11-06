import 'play_mode_model.dart';

class RoomParticipant {
  final String id;
  final String name;
  final String avatar;
  final bool isHost;
  final bool isReady;
  final int score;
  final int lives;

  const RoomParticipant({
    required this.id,
    required this.name,
    required this.avatar,
    this.isHost = false,
    this.isReady = false,
    this.score = 0,
    this.lives = 3,
  });

  RoomParticipant copyWith({
    bool? isHost,
    bool? isReady,
    int? score,
    int? lives,
  }) {
    return RoomParticipant(
      id: id,
      name: name,
      avatar: avatar,
      isHost: isHost ?? this.isHost,
      isReady: isReady ?? this.isReady,
      score: score ?? this.score,
      lives: lives ?? this.lives,
    );
  }
}

enum GameRoomStatus { waiting, starting, playing, roundFinished, gameOver }

class GameRoomModel {
  final String code;
  final String hostId;
  final String gameTitle;
  final GameTargetType targetGame;
  final List<RoomParticipant> participants;
  final GameRoomStatus status;
  final int currentRound;
  final int maxRounds;
  final int timePerTurnSeconds;

  const GameRoomModel({
    required this.code,
    required this.hostId,
    required this.gameTitle,
    this.targetGame = GameTargetType.commonPlayer,
    required this.participants,
    this.status = GameRoomStatus.waiting,
    this.currentRound = 1,
    this.maxRounds = 5,
    this.timePerTurnSeconds = 10,
  });

  GameRoomModel copyWith({
    List<RoomParticipant>? participants,
    GameRoomStatus? status,
    int? currentRound,
    GameTargetType? targetGame,
    String? gameTitle,
  }) {
    return GameRoomModel(
      code: code,
      hostId: hostId,
      gameTitle: gameTitle ?? this.gameTitle,
      targetGame: targetGame ?? this.targetGame,
      participants: participants ?? this.participants,
      status: status ?? this.status,
      currentRound: currentRound ?? this.currentRound,
      maxRounds: maxRounds,
      timePerTurnSeconds: timePerTurnSeconds,
    );
  }
}
