import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../widgets/stadium_background.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final lbProvider = context.watch<LeaderboardProvider>();
    final entries = lbProvider.currentList;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Liderlik Tablosu',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: StadiumBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // TOGGLE TABS (Genel / Arkadaşlarım)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => lbProvider.setFriendsTab(false, auth.currentUser),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !lbProvider.isFriendsTab ? AppColors.pitchGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '🌍 Genel Sıralama',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: !lbProvider.isFriendsTab ? Colors.black87 : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => lbProvider.setFriendsTab(true, auth.currentUser),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: lbProvider.isFriendsTab ? AppColors.pitchGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '👥 Arkadaşlarım',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: lbProvider.isFriendsTab ? Colors.black87 : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // TOP 3 PODIUM (If at least 3 players exist)
              if (entries.length >= 3) _buildPodium(entries.sublist(0, 3)),

              const SizedBox(height: 16),

              // RANKED LIST
              Expanded(
                child: ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = entries[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: item.isCurrentUser
                            ? AppColors.pitchGreen.withOpacity(0.12)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: item.isCurrentUser
                              ? AppColors.pitchGreen
                              : AppColors.cardBorder,
                          width: item.isCurrentUser ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Rank position
                          SizedBox(
                            width: 32,
                            child: Text(
                              _getRankBadge(item.rank),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Avatar
                          Text(item.avatar, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          // Name and Team
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.username,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: item.isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                                    color: item.isCurrentUser ? AppColors.pitchGreenAccent : Colors.white,
                                  ),
                                ),
                                Text(
                                  item.favoriteTeam,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Points Pill
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item.points} XP',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.gold,
                                ),
                              ),
                              Text(
                                '${item.matchesWon} Galibiyet',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRankBadge(int rank) {
    if (rank == 1) return '🥇';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  Widget _buildPodium(List<dynamic> top3) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          _buildPodiumSpot(top3[1], height: 90, rank: '🥈', color: Colors.grey.shade300),
          // 1st Place (Center & Taller)
          _buildPodiumSpot(top3[0], height: 115, rank: '👑', color: AppColors.gold),
          // 3rd Place
          _buildPodiumSpot(top3[2], height: 75, rank: '🥉', color: const Color(0xFFCD7F32)),
        ],
      ),
    );
  }

  Widget _buildPodiumSpot(dynamic item, {required double height, required String rank, required Color color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(rank, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 2),
        Text(item.avatar, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          item.username.toString().split(' ').first,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          '${item.points} XP',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 70,
          height: height * 0.4,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(
              rank,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
