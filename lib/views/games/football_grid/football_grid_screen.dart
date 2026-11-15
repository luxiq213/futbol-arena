import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/grid_challenge_model.dart';
import '../../../../data/models/play_mode_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/football_grid_game_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/club_crest_widget.dart';
import '../../widgets/duel_scoreboard_banner.dart';
import '../../widgets/stadium_background.dart';
import '../common_player/widgets/search_guess_bar.dart';

class FootballGridScreen extends StatelessWidget {
  final PlayModeType playMode;
  final GameDifficulty difficulty;
  final OpponentProfile? opponent;

  const FootballGridScreen({
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
      create: (_) => FootballGridGameProvider(
        playMode: playMode,
        difficulty: difficulty,
        opponent: opponent,
      ),
      child: Consumer<FootballGridGameProvider>(
        builder: (context, grid, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(
                grid.isDuelMode ? 'Futbol Grid 3x3 • Düello' : 'Futbol Grid 3x3',
              ),
              actions: [
                // Guesses Remaining Pill
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
                      const Icon(Icons.history_toggle_off, color: AppColors.gold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${grid.guessesRemaining} Hak',
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Live 1v1 Scoreboard if in Duel Mode
                    if (grid.isDuelMode && grid.opponent != null) ...[
                      DuelScoreboardBanner(
                        userName: user?.username ?? 'Kaptan',
                        userAvatar: user?.avatar ?? 'goat_10',
                        userScore: grid.score,
                        opponent: grid.opponent!,
                        opponentScore: grid.opponentScore,
                        centerSubtitle: 'HÜCRE: ${grid.userSolvedCount}-${grid.opponentSolvedCount}',
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Grid Category / Variety Selector Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: GridThemeType.values.map((theme) {
                          final isSelected = grid.selectedTheme == theme;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => grid.setGridTheme(theme),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.pitchGreen.withValues(alpha: 0.25)
                                      : AppColors.surface.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected ? AppColors.gold : AppColors.border,
                                    width: isSelected ? 1.2 : 0.8,
                                  ),
                                ),
                                child: Text(
                                  theme.label,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 7),

                    // Compact Grid Info Strip
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
                                Text(
                                  grid.challenge.title.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.gold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '• ${grid.solvedCount}/9 Hücre (${difficulty.label})',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${grid.score} Puan',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Opponent Thinking Indicator
                    if (grid.isOpponentThinking)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 10),
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
                              '${grid.opponent?.name ?? "Rakip"} hücre seçiyor...',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Feedback Message
                    if (grid.feedback != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.pitchGreen.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderGreen),
                        ),
                        child: Text(
                          grid.feedback!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ),

                    // Active Cell Selection Prompt
                    if (grid.activeRow != null && grid.activeCol != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Kesişim: ${grid.challenge.rowCriteria[grid.activeRow!].label} × ${grid.challenge.colCriteria[grid.activeCol!].label}',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.close, color: AppColors.textMuted, size: 16),
                                  onPressed: grid.clearSelection,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SearchGuessBar(
                              onSubmitted: (guess) {
                                final wasSolved = grid.submitPlayerGuess(guess);
                                if (wasSolved) {
                                  final reward = (150 * difficulty.pointsMultiplier).round();
                                  context.read<AuthProvider>().addPoints(reward);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // The 3x3 Grid Layout Table
                    _build3x3GridMatrix(context, grid),

                    const SizedBox(height: 18),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Farklı Bir 3x3 Matris Getir',
                            isOutlined: true,
                            icon: Icons.refresh,
                            onPressed: () => grid.startNewGrid(),
                          ),
                        ),
                      ],
                    ),

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

  Widget _build3x3GridMatrix(BuildContext context, FootballGridGameProvider grid) {
    final rowCriteria = grid.challenge.rowCriteria;
    final colCriteria = grid.challenge.colCriteria;

    return Column(
      children: [
        // Top Header Row (Empty corner + 3 Columns)
        Row(
          children: [
            const SizedBox(width: 90), // Corner spacer matching left header width
            ...colCriteria.map(
              (col) => Expanded(
                child: _buildCriterionHeaderBox(col, height: 88),
              ),
            ),
          ],
        ),

        // 3 Data Rows (Left Criterion + 3 Interactive Cells)
        ...List.generate(3, (r) {
          final rowCrit = rowCriteria[r];

          return Row(
            children: [
              // Row Criterion Header
              SizedBox(
                width: 90,
                height: 88,
                child: _buildCriterionHeaderBox(rowCrit, height: 88),
              ),

              // 3 Cells in Row r
              ...List.generate(3, (c) {
                final cell = grid.cells[r][c];
                final isSelected = grid.activeRow == r && grid.activeCol == c;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => grid.selectCell(r, c),
                    child: Container(
                      height: 88,
                      margin: const EdgeInsets.all(3),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cell.isSolved
                            ? (cell.solvedByOpponent
                                ? AppColors.surfaceLight.withValues(alpha: 0.85)
                                : AppColors.pitchGreen.withValues(alpha: 0.35))
                            : (isSelected ? AppColors.surfaceLight : AppColors.surface.withValues(alpha: 0.90)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold
                              : (cell.isSolved
                                  ? (cell.solvedByOpponent ? AppColors.silver : AppColors.goldMuted)
                                  : AppColors.border),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: cell.isSolved
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  cell.player!.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    height: 1.1,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  grid.isDuelMode
                                      ? (cell.solvedByOpponent ? 'Rakip' : 'Sen')
                                      : cell.player!.country,
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: cell.solvedByOpponent ? AppColors.silver : AppColors.gold,
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: Icon(
                                isSelected ? Icons.edit : Icons.add,
                                color: isSelected ? AppColors.gold : AppColors.textMuted,
                                size: 18,
                              ),
                            ),
                    ),
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCriterionHeaderBox(GridCriterion crit, {required double height}) {
    final isTrophy = crit.type == GridCriterionType.trophy;
    final isNat = crit.type == GridCriterionType.nationality;

    Color borderColor = AppColors.border;
    if (isTrophy) {
      borderColor = AppColors.gold.withValues(alpha: 0.55);
    } else if (isNat) {
      borderColor = AppColors.greenLight.withValues(alpha: 0.55);
    }

    return Container(
      height: height,
      margin: const EdgeInsets.all(3),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildCriterionEmblem(crit),
          const SizedBox(height: 4),
          Text(
            crit.club?.name ?? crit.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              height: 1.12,
              fontWeight: FontWeight.w800,
              color: isTrophy ? AppColors.gold : Colors.white,
            ),
          ),
          if (crit.sublabel.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(
              crit.sublabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: isNat ? AppColors.greenLight : AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCriterionEmblem(GridCriterion crit) {
    if (crit.club != null) {
      return ClubCrestWidget(club: crit.club!, size: 28, showShortName: false);
    }

    if (crit.type == GridCriterionType.trophy) {
      IconData trophyIcon = Icons.emoji_events_rounded;
      if (crit.id == 'trophy_ballon_dor') {
        trophyIcon = Icons.workspace_premium_rounded;
      } else if (crit.id == 'trophy_golden_boot') {
        trophyIcon = Icons.bolt_rounded;
      } else if (crit.id == 'trophy_ucl') {
        trophyIcon = Icons.stars_rounded;
      }

      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF59E0B),
              Color(0xFFB45309),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 0.9),
        ),
        child: Center(
          child: Icon(trophyIcon, color: Colors.white, size: 16),
        ),
      );
    }

    // Nationality badge with country colors
    List<Color> flagColors = [AppColors.pitchGreen, AppColors.darkGreen];
    switch (crit.id) {
      case 'nat_brezilya':
        flagColors = [const Color(0xFFFACC15), const Color(0xFF15803D)];
        break;
      case 'nat_fransa':
        flagColors = [const Color(0xFF1D4ED8), const Color(0xFFDC2626)];
        break;
      case 'nat_arjantin':
        flagColors = [const Color(0xFF38BDF8), const Color(0xFF0284C7)];
        break;
      case 'nat_portekiz':
        flagColors = [const Color(0xFFDC2626), const Color(0xFF15803D)];
        break;
      case 'nat_almanya':
        flagColors = [const Color(0xFF18181B), const Color(0xFFEAB308)];
        break;
      case 'nat_ispanya':
        flagColors = [const Color(0xFFDC2626), const Color(0xFFFACC15)];
        break;
      case 'nat_turkiye':
        flagColors = [const Color(0xFFE11D48), const Color(0xFF9F1239)];
        break;
      case 'nat_ingiltere':
        flagColors = [const Color(0xFFEF4444), const Color(0xFF1E3A8A)];
        break;
    }

    return Container(
      width: 30,
      height: 26,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: flagColors,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 0.9),
      ),
      child: Center(
        child: Text(
          crit.badgeCode.isNotEmpty ? crit.badgeCode : 'MİL',
          style: const TextStyle(
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
