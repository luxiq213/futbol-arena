import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/common_player_game_provider.dart';
import '../../widgets/custom_button.dart';
import 'widgets/club_card.dart';
import 'widgets/search_guess_bar.dart';
import 'widgets/answer_reveal_sheet.dart';

class CommonPlayerScreen extends StatelessWidget {
  const CommonPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommonPlayerGameProvider(),
      child: Consumer<CommonPlayerGameProvider>(
        builder: (context, game, _) {
          final clubA = game.clubA;
          final clubB = game.clubB;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Ortak Oyuncu Düellosu',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              actions: [
                // Score indicator
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
                      const Icon(Icons.star_outline, color: AppColors.gold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${game.score} Puan',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Two Clubs Versus Display
                          if (clubA != null && clubB != null)
                            Row(
                              children: [
                                Expanded(child: ClubCard(club: clubA)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: const Text(
                                      'VS',
                                      style: TextStyle(
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(child: ClubCard(club: clubB)),
                              ],
                            ),

                          const SizedBox(height: 16),

                          // Target info card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${clubA?.name} & ${clubB?.name}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tarihte her iki kulüpte oynamis ${game.totalPossible} futbolcu bulunuyor',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: game.isAllFound
                                        ? AppColors.deepPurple
                                        : AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${game.totalFound} / ${game.totalPossible}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: game.isAllFound
                                          ? AppColors.gold
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Feedback message
                          if (game.lastFeedback != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: game.isSuccessFeedback
                                    ? AppColors.deepPurple.withValues(alpha: 0.3)
                                    : AppColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: game.isSuccessFeedback
                                      ? AppColors.deepPurple
                                      : AppColors.error,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    game.isSuccessFeedback
                                        ? Icons.check_circle_outline
                                        : Icons.error_outline,
                                    color: game.isSuccessFeedback
                                        ? AppColors.gold
                                        : AppColors.error,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      game.lastFeedback!,
                                      style: TextStyle(
                                        color: game.isSuccessFeedback
                                            ? AppColors.gold
                                            : Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 14),

                          // Search Guess Input
                          SearchGuessBar(
                            onSubmitted: (guess) {
                              game.submitGuess(guess);
                            },
                          ),

                          const SizedBox(height: 16),

                          // Discovered Players List
                          const Text(
                            'Bulunan Ortak Futbolcular',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          if (game.foundPlayerIds.isEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Center(
                                child: Text(
                                  'Henüz bir futbolcu bulunamadi.\nAklina gelen ismi arama kutusuna yaz.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...game.mutualPlayers
                                .where((p) => game.foundPlayerIds.contains(p.id))
                                .map(
                                  (p) => Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: AppColors.deepPurple,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.person, color: AppColors.gold, size: 16),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                '${p.country} • ${p.position} (${p.activeYears})',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.check_circle_outline, color: AppColors.gold, size: 18),
                                      ],
                                    ),
                                  ),
                                ),

                          const SizedBox(height: 14),

                          // Hint Display
                          if (game.hintsUsed > 0 && game.mutualPlayers.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.gold),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Ipucu:',
                                          style: TextStyle(
                                            color: AppColors.gold,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
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

                  // Bottom Action Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(top: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: game.hintsUsed == 0 ? 'Ipucu (-20 Puan)' : 'Ipucu Alindi',
                            isOutlined: true,
                            icon: Icons.lightbulb_outline,
                            height: 44,
                            onPressed: game.hintsUsed == 0 ? () => game.useHint() : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomButton(
                            text: game.isAllFound ? 'Sonraki Tur' : 'Cevaplari Gör',
                            height: 44,
                            backgroundColor: AppColors.deepPurple,
                            textColor: Colors.white,
                            icon: game.isAllFound ? Icons.arrow_forward : Icons.visibility_outlined,
                            onPressed: () {
                              if (game.isAllFound) {
                                context.read<AuthProvider>().addPoints(100, won: true);
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
            ),
          );
        },
      ),
    );
  }
}
