import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/party_mode_game_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/countdown_overlay.dart';
import '../../widgets/stadium_background.dart';
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
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          toolbarHeight: 46,
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _showExitConfirmation(context, provider),
          ),
          title: const Text(
            '3-2-1 Düello Turları',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.group_outlined, size: 14, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(
                    '${provider.activePlayers.length} Hayatta',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: StadiumBackground(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Active Player Turn Banner
                    if (curPlayer != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: curPlayer.isEliminated ? AppColors.border : AppColors.gold,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.pitchGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  curPlayer.avatar,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
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
                                  const Text(
                                    'SIRADAKİ OYUNCU',
                                    style: TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 1.0,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                  Text(
                                    curPlayer.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Kalan Can',
                                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: List.generate(
                                    curPlayer.lives,
                                    (_) => const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 1),
                                      child: Icon(Icons.favorite, size: 14, color: AppColors.error),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 14),

                    // Timer Dial
                    _buildTimerRing(provider),

                    const SizedBox(height: 14),

                    // Two Clubs / Club x Country Display
                    if (clubA != null && clubB != null)
                      Row(
                        children: [
                          Expanded(child: ClubCard(club: clubA, isCompact: true)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: provider.isCurrentRoundClubVsCountry
                                    ? AppColors.pitchGreen.withValues(alpha: 0.22)
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: provider.isCurrentRoundClubVsCountry
                                      ? AppColors.pitchGreen
                                      : AppColors.border,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    provider.isCurrentRoundClubVsCountry
                                        ? Icons.public_rounded
                                        : Icons.compare_arrows_rounded,
                                    size: 13,
                                    color: AppColors.gold,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    provider.isCurrentRoundClubVsCountry ? 'ÜLKE' : 'VS',
                                    style: const TextStyle(
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(child: ClubCard(club: clubB, isCompact: true)),
                        ],
                      ),

                    const SizedBox(height: 12),

                    // Revealed answers list if requested
                    if (provider.answersRevealed)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Ortak Efsaneler:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: provider.currentMutualPlayers.map((p) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    p.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // In-Round Buttons
                    if (provider.phase == PartyPhase.inRound)
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Pas / Yandı',
                              icon: Icons.close,
                              backgroundColor: AppColors.surfaceLight,
                              textColor: AppColors.error,
                              height: 48,
                              onPressed: () => provider.playerPassed(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: CustomButton(
                              text: 'Bildim',
                              icon: Icons.check,
                              backgroundColor: AppColors.pitchGreen,
                              textColor: Colors.white,
                              height: 48,
                              onPressed: () => provider.playerKnew(),
                            ),
                          ),
                        ],
                      )
                    else if (provider.phase == PartyPhase.roundResult)
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.alarm_off, color: AppColors.error, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${curPlayer?.name ?? "Oyuncu"} sürede bilemedi ve 1 can kaybetti.',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: provider.answersRevealed ? 'Gizle' : 'Cevapları Gör',
                                  isOutlined: true,
                                  icon: Icons.visibility_outlined,
                                  height: 44,
                                  onPressed: () => provider.toggleShowAnswers(),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CustomButton(
                                  text: 'Sıradaki Tur',
                                  icon: Icons.arrow_forward,
                                  backgroundColor: AppColors.pitchGreen,
                                  textColor: Colors.white,
                                  height: 44,
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

              // Countdown 3-2-1 Overlay
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

    Color timerColor = AppColors.gold;
    if (timeLeft <= 3) {
      timerColor = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
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
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: timerColor,
                ),
              ),
              const Text(
                'sn',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
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
        title: const Text('Oyundan Çıkılsın mı?', style: TextStyle(fontSize: 16)),
        content: const Text('Mevcut düello oturumu sonlandırılacak.', style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            child: const Text('Devam Et', style: TextStyle(color: AppColors.textSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Çık', style: TextStyle(color: AppColors.error)),
            onPressed: () {
              provider.resetToSetup();
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
