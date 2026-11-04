import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/online_room_provider.dart';
import '../../widgets/stadium_background.dart';
import '../../widgets/custom_button.dart';
import '../common_player/common_player_screen.dart';

class ActiveRoomScreen extends StatelessWidget {
  const ActiveRoomScreen({super.key});

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          room.gameTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderActive, width: 1.5),
                ),
                child: Column(
                  children: [
                    const Text(
                      'ODA KODU',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Oda kodu kopyalandı! Arkadaşına gönder.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Arkadaşlarını beklerken hazır duruma geçebilirsin',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // PARTICIPANTS LIST
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Oyuncular',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${room.participants.length} / 6 Kişi',
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
                        color: isMe ? AppColors.surfaceLight : AppColors.surface,
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      p.name + (isMe ? ' (Sen)' : ''),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                                        color: AppColors.textPrimary,
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
              if (isHost) ...[
                CustomButton(
                  text: 'Düelloyu Başlat',
                  backgroundColor: AppColors.pitchGreen,
                  textColor: AppColors.textPrimary,
                  height: 52,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CommonPlayerScreen()),
                    );
                  },
                ),
              ] else ...[
                CustomButton(
                  text: myParticipant.isReady ? 'Hazır Durumu İptal Et' : 'Hazırım',
                  backgroundColor: myParticipant.isReady ? AppColors.surfaceLight : AppColors.pitchGreen,
                  textColor: AppColors.textPrimary,
                  height: 52,
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
