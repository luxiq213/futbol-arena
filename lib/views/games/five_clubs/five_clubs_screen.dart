import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/club_model.dart';
import '../../../../data/models/player_model.dart';
import '../../../../data/models/play_mode_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/five_clubs_game_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/club_crest_widget.dart';
import '../../widgets/duel_scoreboard_banner.dart';
import '../../widgets/stadium_background.dart';
import '../common_player/widgets/search_guess_bar.dart';

class FiveClubsScreen extends StatelessWidget {
  final PlayModeType playMode;
  final GameDifficulty difficulty;
  final OpponentProfile? opponent;

  const FiveClubsScreen({
    super.key,
    this.playMode = PlayModeType.solo,
    this.difficulty = GameDifficulty.medium,
    this.opponent,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return ChangeNotifierProvider(
      create: (_) => FiveClubsGameProvider(
        playMode: playMode,
        difficulty: difficulty,
        opponent: opponent,
      ),
      child: Consumer<FiveClubsGameProvider>(
        builder: (context, game, _) {
          final topRowClubs = game.clubs.take(3).toList();
          final bottomRowClubs = game.clubs.skip(3).take(2).toList();

          return Scaffold(
            backgroundColor: AppColors.background,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(
                game.isDuelMode ? '5 Takım 1 Oyuncu • Düello' : '5 Takım 1 Oyuncu',
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
            body: StadiumBackground(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Live 1v1 Scoreboard if in Duel Mode
                    if (game.isDuelMode && game.opponent != null) ...[
                      DuelScoreboardBanner(
                        userName: user?.username ?? 'Kaptan',
                        userAvatar: user?.avatar ?? 'KP',
                        userScore: game.totalUserPoints,
                        opponent: game.opponent!,
                        opponentScore: game.totalOpponentPoints,
                        centerSubtitle: 'TUR ${game.roundsPlayed + 1}',
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Challenge Objective Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.military_tech_outlined, color: AppColors.gold, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                game.isDuelMode
                                    ? 'DÜELLO GÖREVİ: RAKİPTEN FAZLA KULÜP TUTTUR'
                                    : 'KENDİNİ SINA: MAKSİMUM KULÜP EŞLEŞMESİ',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
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

                    const SizedBox(height: 14),

                    // 5 Clubs Display in a 3 + 2 Formation Layout with Full Team Names
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          // Top Row: 3 Clubs
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: topRowClubs
                                .map((club) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: _buildClubTile(game, club),
                                      ),
                                    ))
                                .toList(),
                          ),
                          if (bottomRowClubs.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            // Bottom Row: 2 Clubs Centered
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Spacer(flex: 1),
                                ...bottomRowClubs.map(
                                  (club) => Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: _buildClubTile(game, club),
                                    ),
                                  ),
                                ),
                                const Spacer(flex: 1),
                              ],
                            ),
                          ],
                        ],
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

                    // Opponent Turn Indicator (ONLY in Duel Mode)
                    if (game.phase == FiveClubsPhase.evaluatingOpponent)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${game.opponent?.name ?? "Rakip"} tahminini yapıyor...',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Results Section
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
                        isWinner: !game.isDuelMode || game.userScore >= game.opponentScore,
                        icon: Icons.person_outline,
                      ),

                      // Opponent Result Card ONLY if in Duel Mode
                      if (game.isDuelMode) ...[
                        const SizedBox(height: 10),
                        _buildDuelResultCard(
                          title: '${game.opponent?.name ?? "Rakip"} Tahmini',
                          player: game.opponentPlayer,
                          matchedCount: game.opponentScore,
                          isWinner: game.opponentScore > game.userScore,
                          icon: game.opponent?.isAiFallback == true
                              ? Icons.smart_toy_outlined
                              : Icons.sports_kabaddi_outlined,
                        ),
                      ],

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
                                'Bu turun en güçlü cevabı: ${game.bestPossible.name} (${game.maxPossible}/5 kulüp)',
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

  Widget _buildClubTile(FiveClubsGameProvider game, ClubModel club) {
    final isUserMatch = game.userMatchedClubs.any((c) => c.id == club.id);
    final isOppMatch = game.opponentMatchedClubs.any((c) => c.id == club.id);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isUserMatch
            ? AppColors.pitchGreen.withValues(alpha: 0.22)
            : AppColors.surfaceLight.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUserMatch ? AppColors.gold.withValues(alpha: 0.65) : AppColors.border,
          width: isUserMatch ? 1.2 : 0.8,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClubCrestWidget(club: club, size: 40),
          const SizedBox(height: 6),
          Text(
            club.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            club.country,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9.5,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (game.phase != FiveClubsPhase.playing) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUserMatch ? Icons.check_circle : Icons.remove_circle_outline,
                  size: 14,
                  color: isUserMatch ? AppColors.gold : AppColors.textMuted,
                ),
                if (game.isDuelMode && game.phase == FiveClubsPhase.roundSummary) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isOppMatch ? Icons.check_circle_outline : Icons.remove,
                    size: 13,
                    color: isOppMatch ? AppColors.silver : AppColors.textMuted,
                  ),
                ],
              ],
            ),
          ],
        ],
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
              color: isWinner ? AppColors.pitchGreen : AppColors.surfaceLight,
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
