import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/play_mode_model.dart';
import 'player_avatar_widget.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0E2B1F).withValues(alpha: 0.95),
            const Color(0xFF071A12).withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.55),
          width: 0.9,
        ),
      ),
      child: Row(
        children: [
          // Left: Current User
          Expanded(
            child: Row(
              children: [
                PlayerAvatarWidget(
                  avatarKey: userAvatar.isNotEmpty ? userAvatar : 'goat_10',
                  size: 26,
                  borderColor: isLeading ? AppColors.gold : AppColors.pitchGreen,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      const Text(
                        'Sen',
                        style: TextStyle(
                          fontSize: 8.5,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$userScore',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: isLeading ? AppColors.gold : Colors.white,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '-',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Text(
                  '$opponentScore',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: isTrailing ? AppColors.gold : Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  centerSubtitle ?? opponent.modeBadgeLabel,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        opponent.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            opponent.isAiFallback ? Icons.smart_toy_outlined : Icons.person_outline,
                            size: 9,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              opponent.isAiFallback ? 'AI Rakip' : 'Arkadaş',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 8.5,
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
                const SizedBox(width: 6),
                PlayerAvatarWidget(
                  avatarKey: opponent.avatar,
                  size: 26,
                  borderColor: isTrailing ? AppColors.gold : AppColors.border,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
