import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/football_grid_game_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/club_crest_widget.dart';
import '../../widgets/stadium_background.dart';
import '../common_player/widgets/search_guess_bar.dart';

class FootballGridScreen extends StatelessWidget {
  const FootballGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FootballGridGameProvider(),
      child: Consumer<FootballGridGameProvider>(
        builder: (context, grid, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              toolbarHeight: 46,
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                'Futbol Grid (3x3)',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.white,
                ),
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
                    // Grid Info Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'KESİŞİM MATRİSİ',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: AppColors.gold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${grid.solvedCount} / 9 Hücre Tamamlandı',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${grid.score} Puan',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Feedback Message
                    if (grid.feedback != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        margin: const EdgeInsets.only(bottom: 12),
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
                                    'Hücre: ${grid.challenge.rowCriteria[grid.activeRow!].club?.name ?? grid.challenge.rowCriteria[grid.activeRow!].label} × ${grid.challenge.colCriteria[grid.activeCol!].club?.name ?? grid.challenge.colCriteria[grid.activeCol!].label}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
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
                                  context.read<AuthProvider>().addPoints(150);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // The 3x3 Grid Layout Table
                    _build3x3GridMatrix(context, grid),

                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Yeni Grid Başlat',
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
        // Top Header Row (Empty corner + 3 Columns with Full Club Names)
        Row(
          children: [
            const SizedBox(width: 88), // Empty corner spacer matching left header width
            ...colCriteria.map(
              (col) => Expanded(
                child: Container(
                  height: 84,
                  margin: const EdgeInsets.all(3),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (col.club != null)
                        ClubCrestWidget(club: col.club!, size: 28, showShortName: false)
                      else
                        const Icon(Icons.military_tech_outlined, color: AppColors.gold, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        col.club?.name ?? col.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          height: 1.12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      if (col.sublabel.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          col.sublabel,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 8.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // 3 Data Rows (Left Criterion with Full Club Name + 3 Interactive Cells)
        ...List.generate(3, (r) {
          final rowCrit = rowCriteria[r];

          return Row(
            children: [
              // Row Criterion Header
              SizedBox(
                width: 88,
                height: 84,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (rowCrit.club != null)
                        ClubCrestWidget(club: rowCrit.club!, size: 28, showShortName: false)
                      else
                        const Icon(Icons.military_tech_outlined, color: AppColors.gold, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        rowCrit.club?.name ?? rowCrit.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          height: 1.12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      if (rowCrit.sublabel.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          rowCrit.sublabel,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 8.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // 3 Cells in Row r
              ...List.generate(3, (c) {
                final cell = grid.cells[r][c];
                final isSelected = grid.activeRow == r && grid.activeCol == c;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => grid.selectCell(r, c),
                    child: Container(
                      height: 84,
                      margin: const EdgeInsets.all(3),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: cell.isSolved
                            ? AppColors.pitchGreen.withValues(alpha: 0.35)
                            : (isSelected ? AppColors.surfaceLight : AppColors.surface.withValues(alpha: 0.90)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold
                              : (cell.isSolved ? AppColors.goldMuted : AppColors.border),
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
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cell.player!.country,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: AppColors.gold,
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
}
