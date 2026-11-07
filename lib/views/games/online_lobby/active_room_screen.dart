import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/play_mode_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/online_room_provider.dart';
import '../../widgets/app_notification.dart';
import '../../widgets/stadium_background.dart';
import '../../widgets/custom_button.dart';
import '../auction_duel/auction_duel_screen.dart';
import '../common_player/common_player_screen.dart';
import '../five_clubs/five_clubs_screen.dart';
import '../football_bridge/football_bridge_screen.dart';
import '../football_grid/football_grid_screen.dart';

class ActiveRoomScreen extends StatelessWidget {
  const ActiveRoomScreen({super.key});

  void _launchRoomDuel(BuildContext context, GameTargetType targetGame, OpponentProfile friendOpponent) {
    Widget destination;
    switch (targetGame) {
      case GameTargetType.commonPlayer:
        destination = CommonPlayerScreen(
          playMode: PlayModeType.friendInvite,
          opponent: friendOpponent,
        );
        break;
      case GameTargetType.fiveClubs:
        destination = FiveClubsScreen(
          playMode: PlayModeType.friendInvite,
          opponent: friendOpponent,
        );
        break;
      case GameTargetType.footballGrid:
        destination = FootballGridScreen(
          playMode: PlayModeType.friendInvite,
          opponent: friendOpponent,
        );
        break;
      case GameTargetType.footballBridge:
        destination = FootballBridgeScreen(
          playMode: PlayModeType.friendInvite,
          opponent: friendOpponent,
        );
        break;
      case GameTargetType.auctionDuel:
        destination = AuctionDuelScreen(
          playMode: PlayModeType.friendInvite,
          opponent: friendOpponent,
        );
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<OnlineRoomProvider>();
    final auth = context.watch<AuthProvider>();
    final room = roomProvider.activeRoom;
    final currentUserId = auth.currentUser?.id;

    if (room == null) {
      return Scaffold(
        body: StadiumBackground(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Oda bulunamadı', style: TextStyle(color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.pitchGreen),
                  child: const Text('Geri Dön', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isHost = room.hostId == currentUserId;
    final myParticipant = room.participants.firstWhere(
      (p) => p.id == currentUserId,
      orElse: () => room.participants.first,
    );
    final rivalParticipant = room.participants.firstWhere(
      (p) => p.id != currentUserId,
      orElse: () => room.participants.last,
    );

    final friendOpponent = OpponentProfile(
      id: rivalParticipant.id,
      name: rivalParticipant.name,
      avatar: rivalParticipant.avatar,
      favoriteTeam: 'Arkadaş Lobisi',
      rankTitle: 'Davetli Rakip',
      isAiFallback: false,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 46,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${room.gameTitle} • Lobi',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.error),
            tooltip: 'Odadan Ayrıl',
            onPressed: () {
              roomProvider.leaveRoom();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: StadiumBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ROOM CODE CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderActive, width: 1.5),
                ),
                child: Column(
                  children: [
                    Text(
                      'DAVET KODU • ${room.gameTitle.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.greenLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          room.code,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.copy_outlined, color: AppColors.gold, size: 20),
                          tooltip: 'Kodu Kopyala',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: room.code));
                            AppNotification.show(
                              context,
                              title: 'Davet Kodu Kopyalandı (${room.code})',
                              message: 'Oda kodunu arkadaşına göndererek düelloya davet et.',
                              type: AppNotificationType.highlight,
                              icon: Icons.copy_rounded,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Arkadaşın kodu girerek odaya katıldığında düelloyu başlatabilirsin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PARTICIPANTS LIST
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Odadaki Oyuncular',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${room.participants.length} / 2 Oyuncu',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  itemCount: room.participants.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = room.participants[index];
                    final isMe = p.id == currentUserId;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.surfaceLight : AppColors.surface.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: p.isReady ? AppColors.gold : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.pitchGreen,
                              border: Border.all(color: AppColors.borderActive),
                            ),
                            child: Center(
                              child: Text(
                                p.avatar,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    p.name + (isMe ? ' (Sen)' : ''),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (p.isHost) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: AppColors.gold, width: 0.8),
                                    ),
                                    child: const Text(
                                      'Kurucu',
                                      style: TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: p.isReady
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              p.isReady ? 'Hazır' : 'Bekliyor',
                              style: TextStyle(
                                color: p.isReady ? AppColors.success : AppColors.error,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ACTION BUTTON
              CustomButton(
                text: isHost ? '${room.gameTitle} Düellosunu Başlat' : 'Maça Başla',
                backgroundColor: AppColors.pitchGreen,
                textColor: AppColors.textPrimary,
                icon: Icons.sports_soccer,
                height: 52,
                onPressed: () => _launchRoomDuel(context, room.targetGame, friendOpponent),
              ),
              if (!isHost) ...[
                const SizedBox(height: 8),
                CustomButton(
                  text: myParticipant.isReady ? 'Hazır Durumu İptal Et' : 'Hazırım',
                  isOutlined: true,
                  height: 44,
                  onPressed: () {
                    if (currentUserId != null) {
                      roomProvider.toggleReady(currentUserId);
                    }
                  },
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
