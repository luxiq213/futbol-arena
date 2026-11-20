import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/career_model.dart';
import '../../../../providers/career_game_provider.dart';
import '../../widgets/app_notification.dart';
import '../../widgets/club_crest_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stadium_background.dart';
import 'career_setup_screen.dart';

class CareerSummaryScreen extends StatefulWidget {
  const CareerSummaryScreen({super.key});

  @override
  State<CareerSummaryScreen> createState() => _CareerSummaryScreenState();
}

class _CareerSummaryScreenState extends State<CareerSummaryScreen> {
  int _revealStep = 0; // 0: frame, 1: OVR, 2..7: 6 stats one-by-one, 8: details
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    _revealTimer = Timer.periodic(const Duration(milliseconds: 240), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_revealStep >= 8) {
        timer.cancel();
        return;
      }
      setState(() => _revealStep++);
      if (_revealStep >= 1 && _revealStep <= 7) {
        HapticFeedback.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  void _revealAllImmediately() {
    _revealTimer?.cancel();
    if (_revealStep < 8) {
      setState(() => _revealStep = 8);
    }
  }

  void _shareCareer(BuildContext context, CareerSummary summary) {
    final buffer = StringBuffer();
    buffer.writeln('--- FUTBOLCU KARİYER ÖZETİ ---');
    buffer.writeln('Oyuncu: ${summary.playerName}');
    if (summary.originStoryTitle.isNotEmpty) {
      buffer.writeln('Hikaye: ${summary.originStoryTitle}');
    }
    buffer.writeln('Mevki: ${summary.position.label} (${summary.position.shortCode})');
    buffer.writeln('Ülke: ${summary.nationality}');
    buffer.writeln('Genel Derece: ${summary.careerRating} OVR - ${summary.legacyTitle}');
    buffer.writeln('Toplam Maç: ${summary.totalMatches}');
    buffer.writeln('Toplam Gol: ${summary.totalGoals}');
    buffer.writeln('Toplam Asist: ${summary.totalAssists}');
    buffer.writeln('Kritik Penaltı: ${summary.penaltiesScored}/${summary.penaltiesTaken}');
    buffer.writeln('Toplam Kupa: ${summary.allTrophies.length}');

    if (summary.allTrophies.isNotEmpty) {
      buffer.writeln('Kazanılan Kupalar:');
      final trophyCounts = <String, int>{};
      for (var t in summary.allTrophies) {
        trophyCounts[t] = (trophyCounts[t] ?? 0) + 1;
      }
      trophyCounts.forEach((trophy, count) {
        buffer.writeln('  - $trophy (x$count)');
      });
    }

    buffer.writeln('Forma Giyilen Kulüpler:');
    final clubNames = summary.clubsPlayed.map((c) => c.name).join(' -> ');
    buffer.writeln('  $clubNames');
    buffer.writeln('--------------------------------');
    buffer.writeln('#FutbolParty #FutbolKariyerim');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    AppNotification.show(
      context,
      title: 'Kariyer Özeti Kopyalandı',
      message: 'Jübile kartı ve istatistiklerin panoya kopyalandı, sosyal medyada paylaşabilirsin!',
      type: AppNotificationType.highlight,
      icon: Icons.share_rounded,
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
                'Kariyer özeti bulunamadı.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Ana Menüye Dön',
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Ana Menüye Dön',
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
        ),
        title: const Text('Kariyer Jübilesi & Efsane Kartı'),
        actions: [
          IconButton(
            tooltip: 'Kariyeri Kopyala & Paylaş',
            icon: const Icon(Icons.share_outlined, color: AppColors.gold),
            onPressed: () => _shareCareer(context, summary),
          ),
        ],
      ),
      body: StadiumBackground(
        showFieldLines: true,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _revealAllImmediately,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sequential Burst Legend & Stats Card
                _buildLegendCard(context, summary),

                const SizedBox(height: 16),

                AnimatedOpacity(
                  opacity: _revealStep >= 8 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 350),
                  child: _revealStep < 8
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Center(
                            child: TextButton(
                              onPressed: _revealAllImmediately,
                              child: const Text(
                                'Tüm İstatistikleri Hızlı Aç ›',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                              text: 'Kariyeri Kopyala & Paylaş',
                              icon: Icons.copy_rounded,
                              onPressed: () => _shareCareer(context, summary),
                            ),

                            const SizedBox(height: 10),

                            CustomButton(
                              text: 'Yeni Bir Kariyer Başlat',
                              icon: Icons.replay_rounded,
                              isOutlined: true,
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CareerSetupScreen(),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () =>
                                  Navigator.popUntil(context, (r) => r.isFirst),
                              child: const Text(
                                'Ana Menüye Dön',
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendCard(BuildContext context, CareerSummary summary) {
    final ballonDorCount = summary.allTrophies
        .where((t) => t.contains('Ballon') || t.contains('Altın Ayakkabı'))
        .length;
    final leagueCount = summary.allTrophies
        .where(
          (t) =>
              t.contains('Şampiyonu') && !t.contains('Ulusal Kupa'),
        )
        .length;
    final uclCount = summary.allTrophies
        .where((t) => t.contains('Şampiyonlar Ligi'))
        .length;

    final statTiles = [
      (
        label: 'TOPLAM MAÇ',
        value: '${summary.totalMatches}',
        icon: Icons.stadium_outlined,
        color: Colors.white,
        stepRequired: 2,
      ),
      (
        label: 'TOPLAM GOL',
        value: '${summary.totalGoals}',
        icon: Icons.sports_soccer,
        color: AppColors.greenLight,
        stepRequired: 3,
      ),
      (
        label: 'TOPLAM ASİST',
        value: '${summary.totalAssists}',
        icon: Icons.auto_awesome_outlined,
        color: Colors.lightBlueAccent,
        stepRequired: 4,
      ),
      (
        label: 'LİG KUPASI',
        value: '$leagueCount',
        icon: Icons.emoji_events_outlined,
        color: AppColors.gold,
        stepRequired: 5,
      ),
      (
        label: 'BALLON D\'OR',
        value: '$ballonDorCount',
        icon: Icons.workspace_premium_outlined,
        color: Colors.amberAccent,
        stepRequired: 6,
      ),
      (
        label: uclCount > 0 ? 'Ş. LİGİ / KUPA' : 'TOPLAM KUPA',
        value: uclCount > 0
            ? '$uclCount / ${summary.allTrophies.length}'
            : '${summary.allTrophies.length}',
        icon: Icons.stars_rounded,
        color: AppColors.gold,
        stepRequired: 7,
      ),
    ];

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
          const Positioned(
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
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: OVR Rating & Legacy Badge pop in at step >= 1
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedScale(
                      scale: _revealStep >= 1 ? 1.0 : 0.4,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: AnimatedOpacity(
                        opacity: _revealStep >= 1 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 220),
                        child: Column(
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
                      ),
                    ),

                    AnimatedScale(
                      scale: _revealStep >= 1 ? 1.0 : 0.5,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: AnimatedOpacity(
                        opacity: _revealStep >= 1 ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 220),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.gold, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.workspace_premium_outlined,
                                size: 15,
                                color: AppColors.gold,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                summary.legacyTitle,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.gold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Player Name & Origin Story
                Text(
                  summary.playerName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Colors.white,
                  ),
                ),
                Text(
                  summary.originStoryTitle.isNotEmpty
                      ? '${summary.position.label} • ${summary.originStoryTitle}'
                      : summary.position.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.greenLight,
                  ),
                ),

                const SizedBox(height: 16),

                // Sequential Popping 2x3 Stats Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: statTiles.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.18,
                  ),
                  itemBuilder: (context, idx) {
                    final tile = statTiles[idx];
                    final isRevealed = _revealStep >= tile.stepRequired;
                    return AnimatedScale(
                      scale: isRevealed ? 1.0 : 0.35,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: AnimatedOpacity(
                        opacity: isRevealed ? 1.0 : 0.08,
                        duration: const Duration(milliseconds: 220),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isRevealed
                                  ? tile.color.withValues(alpha: 0.48)
                                  : Colors.white.withValues(alpha: 0.08),
                              width: 1.1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(tile.icon, size: 15, color: tile.color),
                              const SizedBox(height: 3),
                              Text(
                                isRevealed ? tile.value : '?',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: tile.color,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tile.label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubJourneyCard(CareerSummary summary) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: AppColors.pitchGreen),
              const SizedBox(width: 8),
              const Text(
                'KARİYER FORMA YOLCULUĞU',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.pitchGreen,
                ),
              ),
              const Spacer(),
              Text(
                '${summary.clubsPlayed.length} Kulüp',
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
                  Container(
                    width: 96,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClubCrestWidget(
                          club: summary.clubsPlayed[i],
                          size: 40,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          summary.clubsPlayed[i].name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          summary.clubsPlayed[i].country,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < summary.clubsPlayed.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.military_tech_outlined, size: 18, color: AppColors.gold),
              const SizedBox(width: 8),
              const Text(
                'KUPA VE ZAFERLER MÜZESİ',
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
                'Kariyerinde resmi kupa şampiyonluğu bulunmuyor.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trophyCounts.entries.map((entry) {
                final isBigTrophy = entry.key.contains('Şampiyonlar Ligi') ||
                    entry.key.contains('Ballon d\'Or') ||
                    entry.key.contains('Altın Ayakkabı');
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isBigTrophy
                        ? AppColors.gold.withValues(alpha: 0.16)
                        : AppColors.darkGreen.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isBigTrophy ? AppColors.gold : AppColors.borderGreen,
                      width: 0.9,
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
                        '${entry.key}${entry.value > 1 ? " x${entry.value}" : ""}',
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
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.35)),
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
                    margin: const EdgeInsets.only(top: 5),
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
