import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/club_model.dart';
import '../../../../data/models/play_mode_model.dart';
import '../../../../data/models/player_model.dart';
import '../../../../data/repositories/football_database.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/football_bridge_game_provider.dart';
import '../../widgets/club_crest_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/duel_scoreboard_banner.dart';
import '../../widgets/stadium_background.dart';
import '../common_player/widgets/search_guess_bar.dart';

class FootballBridgeScreen extends StatelessWidget {
  final PlayModeType playMode;
  final GameDifficulty difficulty;
  final OpponentProfile? opponent;

  const FootballBridgeScreen({
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
      create: (_) => FootballBridgeGameProvider(
        playMode: playMode,
        difficulty: difficulty,
        opponent: opponent,
      ),
      child: Consumer<FootballBridgeGameProvider>(
        builder: (context, game, _) {
          final ch = game.challenge;
          if (ch == null) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(
                game.isDuelMode ? 'Futbol Köprüsü • Düello' : 'Futbol Köprüsü',
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
                          if (game.isDuelMode && game.opponent != null) ...[
                            DuelScoreboardBanner(
                              userName: user?.username ?? 'Kaptan',
                              userAvatar: user?.avatar ?? 'goat_10',
                              userScore: game.score,
                              opponent: game.opponent!,
                              opponentScore: game.opponentScore,
                            ),
                            const SizedBox(height: 10),
                          ],

                          // Challenge Banner
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: AppColors.darkGreen,
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(color: AppColors.pitchGreen),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.hub_outlined, color: AppColors.gold, size: 18),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ch.title,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Ortak oynadıkları kulüpler üzerinden iki yıldızı birbirine bağla.',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    'Optimal: ${ch.optimalIntermediateCount} Oyuncu',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // 1. START PLAYER NODE
                          _buildEndpointPlayerCard(
                            label: 'BAŞLANGIÇ YILDIZI',
                            badgeColor: AppColors.greenLight,
                            player: ch.startPlayer,
                            clubs: game.getClubsOf(ch.startPlayer),
                          ),

                          // 2. INTERMEDIATE LINKS
                          ..._buildChainWidgets(game, ch),

                          // 3. TARGET PLAYER NODE
                          _buildEndpointPlayerCard(
                            label: 'HEDEF YILDIZ',
                            badgeColor: AppColors.gold,
                            player: ch.targetPlayer,
                            clubs: game.getClubsOf(ch.targetPlayer),
                            isCompleted: game.isBridgeCompleted,
                          ),

                          const SizedBox(height: 12),

                          // Feedback banner
                          if (game.lastFeedback != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                              decoration: BoxDecoration(
                                color: game.isSuccessFeedback
                                    ? AppColors.pitchGreen.withValues(alpha: 0.25)
                                    : AppColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: game.isSuccessFeedback ? AppColors.pitchGreen : AppColors.error,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    game.isSuccessFeedback
                                        ? Icons.check_circle_outline
                                        : Icons.info_outline,
                                    color: game.isSuccessFeedback ? AppColors.gold : Colors.redAccent,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      game.lastFeedback!,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: game.isSuccessFeedback ? AppColors.gold : Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Hint Banner
                          if (game.currentHintText != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 17),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      game.currentHintText!,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Search Guess Input (if bridge not yet completed)
                          if (!game.isBridgeCompleted)
                            SearchGuessBar(
                              onSubmitted: (query) {
                                game.submitStepByQuery(query);
                              },
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
                        if (!game.isBridgeCompleted) ...[
                          Expanded(
                            child: CustomButton(
                              text: game.hintsUsed < 2 ? 'İpucu (-25 Puan)' : 'İpucu Tamam',
                              isOutlined: true,
                              icon: Icons.lightbulb_outline,
                              height: 44,
                              onPressed: game.hintsUsed < 2 ? () => game.useHint() : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomButton(
                              text: 'Köprüyü Gör',
                              height: 44,
                              backgroundColor: AppColors.surfaceLight,
                              textColor: AppColors.gold,
                              icon: Icons.visibility_outlined,
                              onPressed: () => game.revealOptimalBridge(),
                            ),
                          ),
                        ] else ...[
                          Expanded(
                            child: CustomButton(
                              text: 'Sonraki Futbol Köprüsü',
                              height: 46,
                              backgroundColor: AppColors.pitchGreen,
                              textColor: Colors.white,
                              icon: Icons.arrow_forward_rounded,
                              onPressed: () {
                                if (!game.isRevealed) {
                                  context.read<AuthProvider>().addPoints(120, won: true);
                                }
                                game.startNewRound();
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

  List<Widget> _buildChainWidgets(FootballBridgeGameProvider game, BridgeChallenge ch) {
    final widgets = <Widget>[];
    final links = game.userLinks;

    for (int i = 0; i < links.length; i++) {
      final link = links[i];
      final isFinalLinkToTarget = link.toPlayer.id == ch.targetPlayer.id;

      // Club Connector Badge
      widgets.add(_buildClubConnectorBadge(link.sharedClub));

      // If this link goes to an intermediate player (not targetPlayer yet), render intermediate player card
      if (!isFinalLinkToTarget) {
        final isLastIntermediate = (i == links.length - 1) && !game.isBridgeCompleted;
        widgets.add(
          _buildIntermediatePlayerCard(
            stepIndex: i + 1,
            player: link.toPlayer,
            clubs: game.getClubsOf(link.toPlayer),
            canUndo: isLastIntermediate,
            onUndo: () => game.undoLastStep(),
          ),
        );
      }
    }

    // If bridge is NOT completed yet, show the open connection prompt slot
    if (!game.isBridgeCompleted) {
      final tipName = game.currentTipPlayer?.name ?? ch.startPlayer.name;
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Container(
                width: 2,
                height: 12,
                color: AppColors.gold.withValues(alpha: 0.45),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.55),
                    width: 1.1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_link_rounded, color: AppColors.gold, size: 17),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$tipName ile ortak kulübü olan aracı yıldızı aşağıdan seç!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 2,
                height: 12,
                color: AppColors.gold.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildClubConnectorBadge(ClubModel club) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        children: [
          Container(
            width: 2.2,
            height: 10,
            color: AppColors.pitchGreen,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.pitchGreen, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClubCrestWidget(club: club, size: 18),
                const SizedBox(width: 6),
                Text(
                  'ORTAK KULÜP: ${club.name.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.greenLight,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 2.2,
            height: 10,
            color: AppColors.pitchGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointPlayerCard({
    required String label,
    required Color badgeColor,
    required PlayerModel player,
    required List<ClubModel> clubs,
    bool isCompleted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted ? AppColors.pitchGreen : badgeColor.withValues(alpha: 0.65),
          width: 1.3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${player.country} • ${player.position}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            player.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 5,
            children: clubs.map((c) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClubCrestWidget(club: c, size: 15),
                    const SizedBox(width: 5),
                    Text(
                      c.name,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIntermediatePlayerCard({
    required int stepIndex,
    required PlayerModel player,
    required List<ClubModel> clubs,
    required bool canUndo,
    required VoidCallback onUndo,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.darkGreen.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.pitchGreen, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$stepIndex. KÖPRÜ YILDIZI',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (canUndo)
                InkWell(
                  onTap: onUndo,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.undo_rounded, size: 12, color: AppColors.error),
                        SizedBox(width: 3),
                        Text(
                          'Geri Al',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 5,
            runSpacing: 4,
            children: clubs.map((c) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClubCrestWidget(club: c, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      c.name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
