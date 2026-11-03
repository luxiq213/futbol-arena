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
                const Text('Oda bulunamadı'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Geri Dön'),
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
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.crimson),
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
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.pitchGreen, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pitchGreen.withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'ODA KODU',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          room.code,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                            color: AppColors.pitchGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.copy, color: AppColors.pitchGreen),
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
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${room.participants.length} / 6 Kişi',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pitchGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  itemCount: room.participants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final p = room.participants[index];
                    final isMe = p.id == currentUserId;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.surfaceLight : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: p.isReady ? AppColors.pitchGreen : AppColors.cardBorder,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(p.avatar, style: const TextStyle(fontSize: 24)),
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
                                        fontSize: 15,
                                        fontWeight: isMe ? FontWeight.w800 : FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (p.isHost) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          '👑 Kurucu',
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
                                  ? AppColors.pitchGreen.withOpacity(0.18)
                                  : AppColors.crimson.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              p.isReady ? 'HAZIR ✅' : 'BEKLİYOR...',
                              style: TextStyle(
                                color: p.isReady ? AppColors.pitchGreen : AppColors.crimson,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
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
                  text: 'DÜELLOYU BAŞLAT! ⚽',
                  gradient: AppColors.pitchGradient,
                  textColor: Colors.black87,
                  height: 56,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const CommonPlayerScreen()),
                    );
                  },
                ),
              ] else ...[
                CustomButton(
                  text: myParticipant.isReady ? 'Hazır Durumu İptal Et' : 'HAZIRIM! ✅',
                  gradient: myParticipant.isReady ? null : AppColors.pitchGradient,
                  backgroundColor: myParticipant.isReady ? AppColors.surfaceLight : null,
                  textColor: myParticipant.isReady ? Colors.white : Colors.black87,
                  height: 56,
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
