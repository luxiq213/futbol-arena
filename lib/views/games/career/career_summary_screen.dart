import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/career_model.dart';
import '../../../../providers/career_game_provider.dart';
import '../../widgets/club_crest_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stadium_background.dart';
import 'career_setup_screen.dart';

class CareerSummaryScreen extends StatelessWidget {
  const CareerSummaryScreen({super.key});

  void _shareCareer(BuildContext context, CareerSummary summary) {
    final buffer = StringBuffer();
    buffer.writeln('--- FUTBOLCU KARIYER OZETI ---');
    buffer.writeln('Oyuncu: ${summary.playerName}');
    buffer.writeln('Mevki: ${summary.position.label} (${summary.position.shortCode})');
    buffer.writeln('Ulke: ${summary.nationality}');
    buffer.writeln('Genel Derece: ${summary.careerRating} OVR - ${summary.legacyTitle}');
    buffer.writeln('Toplam Mac: ${summary.totalMatches}');
    buffer.writeln('Toplam Gol: ${summary.totalGoals}');
    buffer.writeln('Toplam Asist: ${summary.totalAssists}');
    buffer.writeln('Toplam Kupa: ${summary.allTrophies.length}');

    if (summary.allTrophies.isNotEmpty) {
      buffer.writeln('Kazanilan Kupalar:');
      final trophyCounts = <String, int>{};
      for (var t in summary.allTrophies) {
        trophyCounts[t] = (trophyCounts[t] ?? 0) + 1;
      }
      trophyCounts.forEach((trophy, count) {
        buffer.writeln('  - $trophy (x$count)');
      });
    }

    buffer.writeln('Forma Giyilen Kulupler:');
    final clubNames = summary.clubsPlayed.map((c) => c.name).join(' -> ');
    buffer.writeln('  $clubNames');
    buffer.writeln('--------------------------------');
    buffer.writeln('#FutbolParty #FutbolKariyerim');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Kariyer ozeti panoya kopyalandi! Sosyal medyada paylasabilirsin.',
          style: TextStyle(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: AppColors.pitchGreen,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CareerGameProvider>();
    final summary = provider.finalSummary;

    if (summary == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kariyer ozeti bulunamadi.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Ana Menuye Don',
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Kariyer Jubilesi & Efsane Karti',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Kariyeri Kopyala & Paylas',
            icon: const Icon(Icons.share_outlined, color: AppColors.gold),
            onPressed: () => _shareCareer(context, summary),
          ),
        ],
      ),
      body: StadiumBackground(
        showFieldLines: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // FIFA / TikTok Style Legend Card
              _buildLegendCard(context, summary),

              const SizedBox(height: 16),

              // Career Journey: Clubs Played
              _buildClubJourneyCard(summary),

              const SizedBox(height: 14),

              // Trophy Cabinet
              _buildTrophyCabinetCard(summary),

              const SizedBox(height: 14),

              // Season-by-season Highlights
              _buildHighlightsCard(provider),

              const SizedBox(height: 20),

              // Action Buttons
              CustomButton(
                text: 'Kariyeri Kopyala & Paylas',
                icon: Icons.copy_rounded,
                onPressed: () => _shareCareer(context, summary),
              ),

              const SizedBox(height: 10),

              CustomButton(
                text: 'Yeni Bir Kariyer Baslat',
                icon: Icons.replay_rounded,
                isOutlined: true,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const CareerSetupScreen()),
                  );
                },
              ),

              const SizedBox(height: 10),

              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text(
                  'Ana Menuye Don',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendCard(BuildContext context, CareerSummary summary) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B3D2F),
            Color(0xFF0F261F),
            Color(0xFF061410),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold,
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pitch Watermark Pattern
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.sports_soccer,
                size: 220,
                color: Colors.white,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: OVR Rating & Legacy Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${summary.careerRating}',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gold,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          summary.position.shortCode,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          summary.nationality,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Legacy Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.gold, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.workspace_premium_outlined, size: 16, color: AppColors.gold),
                          const SizedBox(width: 6),
                          Text(
                            summary.legacyTitle,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Player Name
                Text(
                  summary.playerName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),

                Text(
                  summary.position.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pitchGreen,
                  ),
                ),

                const SizedBox(height: 20),

                // Core Stats Grid
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('MAC', '${summary.totalMatches}'),
                      _buildDivider(),
                      _buildStatColumn('GOL', '${summary.totalGoals}'),
                      _buildDivider(),
                      _buildStatColumn('ASIST', '${summary.totalAssists}'),
                      _buildDivider(),
                      _buildStatColumn('KUPA', '${summary.allTrophies.length}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  Widget _buildClubJourneyCard(CareerSummary summary) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: AppColors.pitchGreen),
              const SizedBox(width: 8),
              const Text(
                'KARIYER FORMA YOLCULUGU',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.pitchGreen,
                ),
              ),
              const Spacer(),
              Text(
                '${summary.clubsPlayed.length} Kulup',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < summary.clubsPlayed.length; i++) ...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClubCrestWidget(
                        club: summary.clubsPlayed[i],
                        size: 44,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary.clubsPlayed[i].shortName,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        summary.clubsPlayed[i].country,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  if (i < summary.clubsPlayed.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: AppColors.pitchGreen.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrophyCabinetCard(CareerSummary summary) {
    final trophyCounts = <String, int>{};
    for (var t in summary.allTrophies) {
      trophyCounts[t] = (trophyCounts[t] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.military_tech_outlined, size: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              const Text(
                'KUPA VE ZAFERLER MUZESI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.gold,
                ),
              ),
              const Spacer(),
              Text(
                '${summary.allTrophies.length} Kupa',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (trophyCounts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Kariyerinde resmi kupa sampiyonlugu bulunmuyor.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trophyCounts.entries.map((entry) {
                final isBigTrophy = entry.key.contains('Sampiyonlar Ligi') || entry.key.contains('Ballon d\'Or');
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isBigTrophy
                        ? AppColors.gold.withValues(alpha: 0.15)
                        : AppColors.darkGreen.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBigTrophy ? AppColors.gold : AppColors.borderGreen,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isBigTrophy ? Icons.workspace_premium : Icons.military_tech,
                        size: 14,
                        color: isBigTrophy ? AppColors.gold : AppColors.pitchGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${entry.key} ${entry.value > 1 ? "x${entry.value}" : ""}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isBigTrophy ? AppColors.gold : Colors.white,
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

  Widget _buildHighlightsCard(CareerGameProvider provider) {
    final highlights = provider.highlightsHistory;
    if (highlights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_edu_outlined, size: 16, color: AppColors.pitchGreen),
              SizedBox(width: 8),
              Text(
                'UNUTULMAZ ANLAR VE VURGULAR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.pitchGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < highlights.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.pitchGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      highlights[i],
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
