import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/party_mode_game_provider.dart';
import '../../widgets/stadium_background.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/countdown_overlay.dart';
import '../common_player/widgets/club_card.dart';
import 'party_winner_screen.dart';

class PartyGameScreen extends StatelessWidget {
  const PartyGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PartyModeGameProvider>();

    if (provider.phase == PartyPhase.gameOver) {
      return const PartyWinnerScreen();
    }

    final curPlayer = provider.currentPlayer;
    final clubA = provider.clubA;
    final clubB = provider.clubB;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showExitConfirmation(context, provider);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _showExitConfirmation(context, provider),
          ),
          title: const Text(
            '3-2-1 Bomba!',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          actions: [
            // Active Players Pill
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Text('👥', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '${provider.activePlayers.length} Hayatta',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: StadiumBackground(
          child: Stack(
            children: [
              // MAIN ROUND PLAY SCREEN
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // CURRENT PLAYER CARD
                    if (curPlayer != null)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              curPlayer.isEliminated
                                  ? Colors.grey.shade800
                                  : AppColors.electricBlue.withOpacity(0.35),
                              AppColors.surface,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.electricBlue,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(curPlayer.avatar, style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'SIRADAKİ OYUNCU',
                                    style: TextStyle(
                                      fontSize: 11,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.electricBlue,
                                    ),
                                  ),
                                  Text(
                                    curPlayer.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Lives counter
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Kalan Can',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: List.generate(
                                    curPlayer.lives,
                                    (_) => const Text('❤️', style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().slideY(begin: -0.2, duration: 300.ms),

                    const SizedBox(height: 14),

                    // TIMER RING / BOMB PROGRESS
                    _buildTimerRing(provider),

                    const SizedBox(height: 14),

                    // TWO CLUBS DISPLAY
                    if (clubA != null && clubB != null)
                      Row(
                        children: [
                          Expanded(child: ClubCard(club: clubA, isCompact: true)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.surfaceLight,
                              ),
                              child: const Text(
                                'VS',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: ClubCard(club: clubB, isCompact: true)),
                        ],
                      ).animate().scale(duration: 250.ms),

                    const SizedBox(height: 12),

                    // REVEALED ANSWERS (If toggled or round ended)
                    if (provider.answersRevealed)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Oynayan Efsaneler:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: provider.currentMutualPlayers.map((p) {
                                return Chip(
                                  backgroundColor: AppColors.surfaceLight,
                                  label: Text(
                                    p.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(),

                    const Spacer(),

                    // CONTROLS FOR IN-ROUND OR ROUND RESULT
                    if (provider.phase == PartyPhase.inRound)
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'PAS / YANDI ❌',
                              backgroundColor: AppColors.crimson,
                              textColor: Colors.white,
                              height: 54,
                              onPressed: () => provider.playerPassed(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'BİLDİ! ✅',
                              gradient: AppColors.pitchGradient,
                              textColor: Colors.black87,
                              height: 54,
                              onPressed: () => provider.playerKnew(),
                            ),
                          ),
                        ],
                      )
                    else if (provider.phase == PartyPhase.roundResult)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.crimson.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.crimson),
                            ),
                            child: Row(
                              children: [
                                const Text('💥', style: TextStyle(fontSize: 28)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${curPlayer?.name ?? "Oyuncu"} sürede bilemedi ve 1 can kaybetti!',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: provider.answersRevealed
                                      ? 'Cevapları Gizle'
                                      : 'Cevapları Gör 👁️',
                                  isOutlined: true,
                                  height: 48,
                                  onPressed: () => provider.toggleShowAnswers(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButton(
                                  text: 'Sıradaki Tur',
                                  gradient: AppColors.pitchGradient,
                                  textColor: Colors.black87,
                                  height: 48,
                                  onPressed: () => provider.continueNextTurn(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // 3-2-1 COUNTDOWN OVERLAY
              if (provider.phase == PartyPhase.countdown321)
                CountdownOverlay(count: provider.countdownNumber),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerRing(PartyModeGameProvider provider) {
    final timeLeft = provider.timerSeconds;
    final total = provider.selectedTimerDuration;
    final progress = total > 0 ? (timeLeft / total) : 0.0;

    Color timerColor = AppColors.pitchGreen;
    if (timeLeft <= 3) {
      timerColor = AppColors.crimson;
    } else if (timeLeft <= 5) {
      timerColor = AppColors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(timerColor),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$timeLeft',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: timerColor,
                ),
              ),
              const Text(
                'saniye',
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExitConfirmation(BuildContext context, PartyModeGameProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Oyundan Çıkılsın mı?'),
        content: const Text('Parti oyunu sonlandırılacak.'),
        actions: [
          TextButton(
            child: const Text('Devam Et', style: TextStyle(color: AppColors.textSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Çık', style: TextStyle(color: AppColors.crimson)),
            onPressed: () {
              provider.resetToSetup();
              Navigator.pop(context); // dialog
              Navigator.pop(context); // game screen
            },
          ),
        ],
      ),
    );
  }
}
