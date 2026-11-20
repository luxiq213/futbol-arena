import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/club_model.dart';
import '../../../../data/models/play_mode_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/common_player_game_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/duel_scoreboard_banner.dart';
import '../../widgets/stadium_background.dart';
import 'widgets/club_card.dart';
import 'widgets/search_guess_bar.dart';
import 'widgets/answer_reveal_sheet.dart';

class CommonPlayerScreen extends StatelessWidget {
  final PlayModeType playMode;
  final GameDifficulty difficulty;
  final OpponentProfile? opponent;
  final CommonPlayerPairMode initialPairFormat;
  final ClubModel? initialClubA;
  final ClubModel? initialClubB;

  const CommonPlayerScreen({
    super.key,
    this.playMode = PlayModeType.solo,
    this.difficulty = GameDifficulty.medium,
    this.opponent,
    this.initialPairFormat = CommonPlayerPairMode.clubVsClub,
    this.initialClubA,
    this.initialClubB,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return ChangeNotifierProvider(
      create: (_) => CommonPlayerGameProvider(
        playMode: playMode,
        difficulty: difficulty,
        opponent: opponent,
        pairFormat: initialPairFormat,
        initialClubA: initialClubA,
        initialClubB: initialClubB,
      ),
      child: Consumer<CommonPlayerGameProvider>(
        builder: (context, game, _) {
          final clubA = game.clubA;
          final clubB = game.clubB;
          final isClubVsCountry = game.isCurrentRoundClubVsCountry;

          return Scaffold(
            backgroundColor: AppColors.background,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(
                game.isDuelMode ? 'Ortak Oyuncu • Düello' : 'Ortak Oyuncu (3-2-1)',
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
            body: StadiumBackground(
              child: Column(
                children: [
                  Expanded(
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
                              userScore: game.score,
                              opponent: game.opponent!,
                              opponentScore: game.opponentScore,
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Two Clubs / Club x Country Versus Display
                          if (clubA != null && clubB != null)
                            Row(
                              children: [
                                Expanded(child: ClubCard(club: clubA)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isClubVsCountry
                                          ? AppColors.pitchGreen.withValues(alpha: 0.22)
                                          : AppColors.surfaceLight,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isClubVsCountry ? AppColors.pitchGreen : AppColors.border,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isClubVsCountry
                                              ? Icons.public_rounded
                                              : Icons.compare_arrows_rounded,
                                          size: 13,
                                          color: AppColors.gold,
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          isClubVsCountry ? 'ÜLKE' : 'VS',
                                          style: const TextStyle(
                                            color: AppColors.gold,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 9.5,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(child: ClubCard(club: clubB)),
                              ],
                            ),

                          const SizedBox(height: 8),

                          // Compact Target info strip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.90),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: isClubVsCountry
                                              ? AppColors.pitchGreen.withValues(alpha: 0.22)
                                              : AppColors.gold.withValues(alpha: 0.16),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          isClubVsCountry ? 'TAKIM×ÜLKE' : 'ORTAK OYUNCU',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w800,
                                            color: isClubVsCountry ? AppColors.greenLight : AppColors.gold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          '${clubA?.name} × ${clubB?.name} (${game.totalPossible} futbolcu)',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: game.isAllFound
                                        ? AppColors.pitchGreen
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

                          const SizedBox(height: 12),

                          // Opponent Thinking Indicator in Duel Mode
                          if (game.isOpponentThinking)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '${game.opponent?.name ?? "Rakip"} ortak oyuncu düşünüyor...',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Feedback message
                          if (game.lastFeedback != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: game.isSuccessFeedback
                                    ? AppColors.pitchGreen.withValues(alpha: 0.3)
                                    : AppColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: game.isSuccessFeedback
                                      ? AppColors.pitchGreen
                                      : AppColors.error,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    game.isSuccessFeedback
                                        ? Icons.check_circle_outline
                                        : Icons.info_outline,
                                    color: game.isSuccessFeedback
                                        ? AppColors.gold
                                        : Colors.redAccent,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      game.lastFeedback!,
                                      style: TextStyle(
                                        color: game.isSuccessFeedback
                                            ? AppColors.gold
                                            : Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

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
                                color: AppColors.surface.withValues(alpha: 0.90),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Center(
                                child: Text(
                                  'Henüz bir futbolcu bulunamadı.\nAklına gelen ismi arama kutusuna yaz.',
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
                                .map((p) {
                                  final isByOpponent = game.foundByOpponentIds.contains(p.id);
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 6),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface.withValues(alpha: 0.90),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isByOpponent ? AppColors.silver.withValues(alpha: 0.5) : AppColors.border,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: isByOpponent ? AppColors.surfaceLight : AppColors.pitchGreen,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              isByOpponent ? Icons.smart_toy_outlined : Icons.person,
                                              color: AppColors.gold,
                                              size: 16,
                                            ),
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
                                        if (game.isDuelMode)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isByOpponent
                                                  ? AppColors.surfaceLight
                                                  : AppColors.pitchGreen.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: isByOpponent ? AppColors.silver : AppColors.pitchGreen,
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Text(
                                              isByOpponent ? (game.opponent?.name ?? 'Rakip') : 'Sen',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: isByOpponent ? AppColors.silver : AppColors.greenLight,
                                              ),
                                            ),
                                          )
                                        else
                                          const Icon(Icons.check_circle_outline, color: AppColors.gold, size: 18),
                                      ],
                                    ),
                                  );
                                }),

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
                                          'İpucu:',
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
                            text: game.hintsUsed == 0 ? 'İpucu (-20 Puan)' : 'İpucu Alındı',
                            isOutlined: true,
                            icon: Icons.lightbulb_outline,
                            height: 44,
                            onPressed: game.hintsUsed == 0 ? () => game.useHint() : null,
                          ),
                        ),
                        if (!game.isDuelMode || game.isAllFound) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomButton(
                              text: game.isAllFound ? 'Sonraki Tur' : 'Cevapları Gör',
                              height: 44,
                              backgroundColor: AppColors.pitchGreen,
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
