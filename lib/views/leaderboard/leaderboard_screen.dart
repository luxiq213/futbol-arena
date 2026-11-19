import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/leaderboard_entry.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../widgets/player_avatar_widget.dart';

class LeaderboardScreen extends StatefulWidget {
  final bool isEmbedded;

  const LeaderboardScreen({super.key, this.isEmbedded = false});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<LeaderboardProvider>().loadRankings(auth.currentUser);
    });
  }

  IconData _iconForCategory(LeaderboardModeCategory cat) {
    switch (cat) {
      case LeaderboardModeCategory.overall:
        return Icons.emoji_events_outlined;
      case LeaderboardModeCategory.career:
        return Icons.sports_soccer_rounded;
      case LeaderboardModeCategory.commonPlayer:
        return Icons.compare_arrows_rounded;
      case LeaderboardModeCategory.fiveClubs:
        return Icons.shield_outlined;
      case LeaderboardModeCategory.footballGrid:
        return Icons.grid_3x3_rounded;
      case LeaderboardModeCategory.footballBridge:
        return Icons.hub_outlined;
      case LeaderboardModeCategory.auctionDuel:
        return Icons.gavel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lbProvider = context.watch<LeaderboardProvider>();
    final entries = lbProvider.currentList;
    final activeCat = lbProvider.selectedCategory;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Tab Switcher (Genel Sıralama / Arkadaşlarım)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => lbProvider.setFriendsTab(false, auth.currentUser),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !lbProvider.isFriendsTab ? AppColors.darkGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.public,
                            size: 14,
                            color: !lbProvider.isFriendsTab ? AppColors.gold : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Genel Sıralama',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: !lbProvider.isFriendsTab ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => lbProvider.setFriendsTab(true, auth.currentUser),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: lbProvider.isFriendsTab ? AppColors.darkGreen : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 14,
                            color: lbProvider.isFriendsTab ? AppColors.gold : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Arkadaşlarım',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: lbProvider.isFriendsTab ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Mode Category Filter Chips (Genel, Kariyer, Ortak Oyuncu, 5 Takım 1 Oyuncu, Grid 3x3)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: LeaderboardModeCategory.values.map((cat) {
              final isSelected = activeCat == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => lbProvider.setModeCategory(cat, auth.currentUser),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.pitchGreen.withValues(alpha: 0.25)
                          : AppColors.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.gold : AppColors.border,
                        width: isSelected ? 1.3 : 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _iconForCategory(cat),
                          size: 13,
                          color: isSelected ? AppColors.gold : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          cat.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        // Active Mode Subtitle Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(_iconForCategory(activeCat), size: 15, color: AppColors.greenLight),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  activeCat.subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // 3. Top 3 Podium
        if (entries.length >= 3) _buildPodium(entries.sublist(0, 3)),

        const SizedBox(height: 12),

        // 4. Ranked List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: entries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 6),
          itemBuilder: (context, index) {
            final item = entries[index];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: item.isCurrentUser
                    ? AppColors.darkGreen.withValues(alpha: 0.45)
                    : AppColors.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: item.isCurrentUser ? AppColors.gold : AppColors.border,
                  width: item.isCurrentUser ? 1.3 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '#${item.rank}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: item.rank <= 3 ? AppColors.gold : AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  PlayerAvatarWidget(
                    avatarKey: item.avatar,
                    size: 36,
                    borderColor: item.rank <= 3 ? AppColors.gold : AppColors.borderGreen,
                    borderWidth: 1.2,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.username,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: item.isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                            color: item.isCurrentUser ? AppColors.gold : Colors.white,
                          ),
                        ),
                        Text(
                          item.favoriteTeam,
                          style: const TextStyle(
                            fontSize: 10.5,
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
                        item.effectiveScoreLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                      Text(
                        item.effectiveSecondaryLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.greenLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Liderlik Tablosu',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: content,
        ),
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumSpot(top3[1], rank: '2', color: AppColors.silver, height: 74),
          _buildPodiumSpot(top3[0], rank: '1', color: AppColors.gold, height: 96),
          _buildPodiumSpot(top3[2], rank: '3', color: const Color(0xFFCD7F32), height: 64),
        ],
      ),
    );
  }

  Widget _buildPodiumSpot(
    LeaderboardEntry item, {
    required String rank,
    required Color color,
    required double height,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlayerAvatarWidget(
          avatarKey: item.avatar,
          size: rank == '1' ? 46 : 40,
          borderColor: color,
          borderWidth: 1.6,
        ),
        const SizedBox(height: 5),
        Text(
          item.username.split(' ').first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          item.effectiveScoreLabel,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 68,
          height: height * 0.44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.45)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
