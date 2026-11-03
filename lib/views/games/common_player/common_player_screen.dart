import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/common_player_game_provider.dart';
import '../../widgets/stadium_background.dart';
import '../../widgets/custom_button.dart';
import 'widgets/club_card.dart';
import 'widgets/search_guess_bar.dart';
import 'widgets/answer_reveal_sheet.dart';

class CommonPlayerScreen extends StatefulWidget {
  const CommonPlayerScreen({super.key});

  @override
  State<CommonPlayerScreen> createState() => _CommonPlayerScreenState();
}

class _CommonPlayerScreenState extends State<CommonPlayerScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onAllFoundCelebration() {
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommonPlayerGameProvider(),
      child: Consumer<CommonPlayerGameProvider>(
        builder: (context, game, child) {
          final clubA = game.clubA;
          final clubB = game.clubB;

          if (game.isAllFound && !_confettiController.state.toString().contains('playing')) {
            _onAllFoundCelebration();
            // Award XP to user
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AuthProvider>().addPoints(100, won: true);
            });
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Ortak Futbolcu',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              actions: [
                // Score Badge
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: AppColors.gold, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+${game.score} XP',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: StadiumBackground(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // VS CLUBS SECTION
                              if (clubA != null && clubB != null)
                                Row(
                                  children: [
                                    Expanded(child: ClubCard(club: clubA)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.surfaceLight,
                                          border: Border.all(color: AppColors.gold, width: 1.5),
                                        ),
                                        child: const Text(
                                          'VS',
                                          style: TextStyle(
                                            color: AppColors.gold,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(child: ClubCard(club: clubB)),
                                  ],
                                ).animate().slideY(begin: -0.1, duration: 300.ms).fadeIn(),

                              const SizedBox(height: 16),

                              // STATUS / PROGRESS BAR
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${clubA?.shortName ?? ''} & ${clubB?.shortName ?? ''} Ortak Oyuncusu',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          'Toplam ${game.totalPossible} oyuncu bu iki takımda oynadı',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: game.isAllFound
                                            ? AppColors.pitchGreen.withOpacity(0.2)
                                            : AppColors.surfaceLight,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: game.isAllFound
                                              ? AppColors.pitchGreen
                                              : AppColors.cardBorder,
                                        ),
                                      ),
                                      child: Text(
                                        '${game.totalFound} / ${game.totalPossible}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: game.isAllFound
                                              ? AppColors.pitchGreen
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 14),

                              // FEEDBACK BANNER (If any)
                              if (game.lastFeedback != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: game.isSuccessFeedback
                                        ? AppColors.pitchGreen.withOpacity(0.15)
                                        : AppColors.crimson.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: game.isSuccessFeedback
                                          ? AppColors.pitchGreen
                                          : AppColors.crimson,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        game.isSuccessFeedback ? Icons.check_circle : Icons.error,
                                        color: game.isSuccessFeedback
                                            ? AppColors.pitchGreen
                                            : AppColors.crimson,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          game.lastFeedback!,
                                          style: TextStyle(
                                            color: game.isSuccessFeedback
                                                ? AppColors.pitchGreenAccent
                                                : Colors.redAccent,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().shake(duration: 300.ms),

                              const SizedBox(height: 14),

                              // SEARCH GUESS BAR
                              SearchGuessBar(
                                onSubmitted: (guess) {
                                  game.submitGuess(guess);
                                },
                              ),

                              const SizedBox(height: 16),

                              // DISCOVERED PLAYERS LIST / CARDS
                              const Text(
                                'Bulunan Efsaneler',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),

                              if (game.foundPlayerIds.isEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 28),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.cardBorder, style: BorderStyle.solid),
                                  ),
                                  child: const Center(
                                    child: Column(
                                      children: [
                                        Text('🔎', style: TextStyle(fontSize: 28)),
                                        SizedBox(height: 8),
                                        Text(
                                          'Henüz bir oyuncu bulunamadı.\nAklına gelen bir ismi yaz!',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...game.mutualPlayers
                                    .where((p) => game.foundPlayerIds.contains(p.id))
                                    .map(
                                      (p) => Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: AppColors.pitchGreen, width: 1.2),
                                        ),
                                        child: Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 18,
                                              backgroundColor: AppColors.pitchGreen,
                                              child: Text('⭐', style: TextStyle(fontSize: 16)),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.name,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${p.country} • ${p.position}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Icon(Icons.check_circle, color: AppColors.pitchGreen),
                                          ],
                                        ),
                                      ).animate().scale(duration: 250.ms),
                                    ),

                              const SizedBox(height: 16),

                              // HINT BOX (If hint was used)
                              if (game.hintsUsed > 0 && game.mutualPlayers.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.gold),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.lightbulb, color: AppColors.gold, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'İpucu:',
                                              style: TextStyle(
                                                color: AppColors.gold,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              game.mutualPlayers.first.hint,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // BOTTOM ACTION BAR
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          border: Border(top: BorderSide(color: AppColors.cardBorder)),
                        ),
                        child: Row(
                          children: [
                            // Hint Button
                            Expanded(
                              child: CustomButton(
                                text: 'İpucu (${game.hintsUsed == 0 ? "-20 XP" : "Alındı"})',
                                isOutlined: true,
                                icon: Icons.lightbulb_outline,
                                height: 48,
                                onPressed: game.hintsUsed == 0 ? () => game.useHint() : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Reveal / Next Round
                            Expanded(
                              child: CustomButton(
                                text: game.isAllFound ? 'Sonraki Tur' : 'Cevapları Gör',
                                height: 48,
                                gradient: game.isAllFound
                                    ? AppColors.pitchGradient
                                    : AppColors.blueGradient,
                                textColor: Colors.white,
                                icon: game.isAllFound ? Icons.arrow_forward : Icons.visibility,
                                onPressed: () {
                                  if (game.isAllFound) {
                                    game.startNewRound();
                                  } else {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => AnswerRevealSheet(
                                        players: game.mutualPlayers,
                                        foundIds: game.foundPlayerIds,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // CONFETTI
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      numberOfParticles: 35,
                      colors: const [
                        AppColors.pitchGreen,
                        AppColors.gold,
                        Colors.white,
                        Colors.blueAccent,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
