import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/club_model.dart';
import '../../../../providers/career_game_provider.dart';
import '../../widgets/club_crest_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stadium_background.dart';
import 'career_summary_screen.dart';

class CareerSeasonScreen extends StatefulWidget {
  const CareerSeasonScreen({super.key});

  @override
  State<CareerSeasonScreen> createState() => _CareerSeasonScreenState();
}

class _CareerSeasonScreenState extends State<CareerSeasonScreen> {
  bool _isProcessing = false;

  void _onSelectClub(ClubModel? chosenClub) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final provider = context.read<CareerGameProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final isStay = chosenClub == null || chosenClub.id == provider.currentClub?.id;
    final clubName = isStay ? (provider.currentClub?.name ?? 'Kulubunde') : chosenClub.name;

    // Show a quick visual confirmation banner
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          isStay ? '$clubName ile sozlesme uzattin!' : '$clubName ile anlasma saglandi!',
          style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        ),
        backgroundColor: AppColors.pitchGreen,
        duration: const Duration(milliseconds: 1400),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    provider.selectTransferDecision(chosenClub);

    setState(() => _isProcessing = false);

    if (provider.isCareerFinished) {
      nav.pushReplacement(
        MaterialPageRoute(builder: (_) => const CareerSummaryScreen()),
      );
    }
  }

  void _confirmEarlyRetire(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Jubile Yapmak Istiyor musun?',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Kariyerini su anki yasinda sonlandirip efsane kartini ve istatistiklerini goruntulemek istiyor musun?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Devam Et', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pitchGreen,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final provider = context.read<CareerGameProvider>();
              // Fast forward to finish
              while (!provider.isCareerFinished) {
                provider.selectTransferDecision(provider.currentClub);
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CareerSummaryScreen()),
              );
            },
            child: const Text('Jubile Yap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CareerGameProvider>();
    final currentClub = provider.currentClub;
    final offers = provider.currentOffers;
    final lastSeason = provider.seasonHistory.isNotEmpty ? provider.seasonHistory.last : null;
    final lastHighlight = provider.highlightsHistory.isNotEmpty ? provider.highlightsHistory.last : null;

    if (currentClub == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.pitchGreen)),
      );
    }

    final totalGoals = provider.seasonHistory.fold<int>(0, (sum, s) => sum + s.goals);
    final totalAssists = provider.seasonHistory.fold<int>(0, (sum, s) => sum + s.assists);
    final totalTrophies = provider.seasonHistory.fold<int>(0, (sum, s) => sum + s.trophiesWon.length);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${provider.playerName} • ${provider.position.shortCode}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _confirmEarlyRetire(context),
            icon: const Icon(Icons.flag_outlined, size: 16, color: AppColors.gold),
            label: const Text(
              'Jubile',
              style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: StadiumBackground(
        showFieldLines: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Career Progress Header Bar
              _buildProgressHeader(provider),

              const SizedBox(height: 12),

              // Current Club Card & Ticker
              _buildCurrentClubBanner(currentClub, totalGoals, totalAssists, totalTrophies),

              const SizedBox(height: 12),

              // Last Season Performance & Highlight
              if (lastSeason != null) _buildSeasonReviewCard(lastSeason, lastHighlight),

              const SizedBox(height: 16),

              // Transfer Window Section Header
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.pitchGreen,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TRANSFER MASASI • TEKLIFLER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Bir sonraki donem icin kulup teklifini degerlendir veya takiminda kal:',
                style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),

              const SizedBox(height: 12),

              // Offer 1 Card
              if (offers.isNotEmpty)
                _buildOfferCard(
                  context: context,
                  club: offers[0],
                  label: '1. Transfer Teklifi',
                  isStayOption: false,
                ),

              const SizedBox(height: 10),

              // Offer 2 Card
              if (offers.length > 1)
                _buildOfferCard(
                  context: context,
                  club: offers[1],
                  label: '2. Transfer Teklifi',
                  isStayOption: false,
                ),

              const SizedBox(height: 10),

              // Stay Option Card
              _buildOfferCard(
                context: context,
                club: currentClub,
                label: 'Sadakat & Sozlesme Uzatma',
                isStayOption: true,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(CareerGameProvider provider) {
    final stageProgress = (provider.currentStageIndex + 1) / 6.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.pitchGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.pitchGreen, width: 0.8),
                    ),
                    child: Text(
                      '${provider.currentAge} YAS',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.greenLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.currentStageTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Text(
                'Donem ${provider.currentStageIndex + 1}/6',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stageProgress.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pitchGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentClubBanner(ClubModel club, int totalGoals, int totalAssists, int totalTrophies) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withValues(alpha: 0.9),
            AppColors.darkGreen.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          ClubCrestWidget(club: club, size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MEVCUT KULUBUN',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.pitchGreen,
                  ),
                ),
                Text(
                  club.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${club.country} • ${club.league}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalGoals GOL',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.greenLight,
                ),
              ),
              Text(
                '$totalAssists ASIST',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '$totalTrophies KUPA',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonReviewCard(dynamic season, String? highlight) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_outlined, size: 15, color: AppColors.pitchGreen),
              const SizedBox(width: 6),
              const Text(
                'GECTIGIMIZ SEZON RAPORU',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.pitchGreen,
                ),
              ),
              const Spacer(),
              Text(
                '${season.matches} Mac Oynadin',
                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMiniMetric('GOL', '${season.goals}'),
              const SizedBox(width: 12),
              _buildMiniMetric('ASIST', '${season.assists}'),
              const SizedBox(width: 12),
              _buildMiniMetric('KUPA', '${season.trophiesWon.length}'),
              const Spacer(),
              if (season.trophiesWon.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.gold, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events_outlined, size: 13, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(
                        season.trophiesWon.first,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (highlight != null && highlight.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_outline, size: 14, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      highlight,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard({
    required BuildContext context,
    required ClubModel club,
    required String label,
    required bool isStayOption,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isStayOption ? AppColors.silver.withValues(alpha: 0.4) : AppColors.pitchGreen.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          ClubCrestWidget(club: club, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isStayOption
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.pitchGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isStayOption ? AppColors.silver : AppColors.greenLight,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  club.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${club.country} • ${club.league}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 84, maxWidth: 104),
            child: CustomButton(
              text: isStayOption ? 'Takimda Kal' : 'Imzala',
              isOutlined: isStayOption,
              height: 38,
              onPressed: () => _onSelectClub(isStayOption ? null : club),
            ),
          ),
        ],
      ),
    );
  }
}
