import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/play_mode_model.dart';

class DuelScoreboardBanner extends StatelessWidget {
  final String userName;
  final String userAvatar;
  final int userScore;
  final OpponentProfile opponent;
  final int opponentScore;
  final String? centerSubtitle;

  const DuelScoreboardBanner({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.userScore,
    required this.opponent,
    required this.opponentScore,
    this.centerSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isLeading = userScore > opponentScore;
    final isTrailing = opponentScore > userScore;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0E2B1F).withValues(alpha: 0.95),
            const Color(0xFF071A12).withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.55),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Current User
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isLeading ? AppColors.gold : AppColors.pitchGreen,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      userAvatar.isNotEmpty ? userAvatar : 'KP',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.greenLight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Sen',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greenLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Center Score Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$userScore',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isLeading ? AppColors.gold : Colors.white,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '-',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    Text(
                      '$opponentScore',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isTrailing ? AppColors.gold : Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  centerSubtitle ?? opponent.modeBadgeLabel,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),

          // Right: Opponent (Online / AI Fallback / Friend)
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        opponent.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            opponent.isAiFallback ? Icons.smart_toy_outlined : Icons.person_outline,
                            size: 10,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              opponent.isAiFallback ? 'AI Rakip' : 'Arkadaş',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isTrailing ? AppColors.gold : AppColors.border,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      opponent.avatar,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
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
