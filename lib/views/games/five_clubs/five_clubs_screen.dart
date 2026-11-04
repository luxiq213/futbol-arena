import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/player_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/five_clubs_game_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/club_crest_widget.dart';
import '../common_player/widgets/search_guess_bar.dart';

class FiveClubsScreen extends StatelessWidget {
  const FiveClubsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FiveClubsGameProvider(),
      child: Consumer<FiveClubsGameProvider>(
        builder: (context, game, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                '5 Takim 1 Oyuncu',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
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
                      const Icon(Icons.star_outline, color: AppColors.gold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${game.totalUserPoints} Puan',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Challenge Objective Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.military_tech_outlined, color: AppColors.gold, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'GÖREV: MAKSİMUM KULÜP EŞLEŞMESİ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Aşağıdaki 5 kulübün en çoğunda forma giymiş ortak futbolcuyu tahmin et.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 5 Clubs Crests Display Row
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: game.clubs.map((club) {
                          final isUserMatch = game.userMatchedClubs.any((c) => c.id == club.id);
                          final isAiMatch = game.aiMatchedClubs.any((c) => c.id == club.id);

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClubCrestWidget(club: club, size: 48),
                              const SizedBox(height: 6),
                              Text(
                                club.shortName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              if (game.phase != FiveClubsPhase.playing) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isUserMatch ? Icons.check_circle : Icons.remove,
                                      size: 14,
                                      color: isUserMatch ? AppColors.gold : AppColors.textMuted,
                                    ),
                                    if (game.phase == FiveClubsPhase.roundSummary) ...[
                                      const SizedBox(width: 2),
                                      Icon(
                                        isAiMatch ? Icons.smart_toy : Icons.remove,
                                        size: 12,
                                        color: isAiMatch ? AppColors.silver : AppColors.textMuted,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Search input if playing
                    if (game.phase == FiveClubsPhase.playing)
                      SearchGuessBar(
                        onSubmitted: (guess) {
                          game.submitUserGuess(guess);
                        },
                      ),

                    // Evaluating / AI Turn Indicator
                    if (game.phase == FiveClubsPhase.evaluating)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Scout AI tahmini analiz ediliyor...',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Results Comparison Section
                    if (game.phase == FiveClubsPhase.roundSummary) ...[
                      // Feedback banner
                      if (game.feedback != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.pitchGreen.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderGreen),
                          ),
                          child: Text(
                            game.feedback!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // User Guess Result Card
                      _buildDuelResultCard(
                        title: 'Senin Tahminin',
                        player: game.userPlayer,
                        matchedCount: game.userScore,
                        isWinner: game.userScore >= game.aiScore,
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 10),

                      // Scout AI Result Card
                      _buildDuelResultCard(
                        title: 'Scout AI Tahmini',
                        player: game.aiPlayer,
                        matchedCount: game.aiScore,
                        isWinner: game.aiScore > game.userScore,
                        icon: Icons.smart_toy_outlined,
                      ),

                      const SizedBox(height: 12),

                      // Best Possible Answer Highlight
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, color: AppColors.silver, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Bu turun en güçlü cevabi: ${game.bestPossible.name} (${game.maxPossible}/5 kulüp)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.silver,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Next Round Button
                      CustomButton(
                        text: 'Sonraki 5 Kulüp',
                        icon: Icons.arrow_forward,
                        backgroundColor: AppColors.pitchGreen,
                        textColor: Colors.white,
                        onPressed: () {
                          context.read<AuthProvider>().addPoints(game.userScore * 100);
                          game.startNewRound();
                        },
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDuelResultCard({
    required String title,
    required PlayerModel? player,
    required int matchedCount,
    required bool isWinner,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? AppColors.gold : AppColors.border,
          width: isWinner ? 1.2 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isWinner ? AppColors.gold : AppColors.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  player?.name ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isWinner
                  ? AppColors.pitchGreen
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$matchedCount / 5 Kulüp',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isWinner ? AppColors.gold : AppColors.silver,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
