import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/club_model.dart';
import '../../../widgets/club_crest_widget.dart';

class ClubCard extends StatelessWidget {
  final ClubModel club;
  final bool isCompact;

  const ClubCard({
    super.key,
    required this.club,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 8 : 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: club.primaryColor.withValues(alpha: 0.5),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: club.primaryColor.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Geometric Shield Crest
          ClubCrestWidget(
            club: club,
            size: isCompact ? 40 : 46,
          ),

          SizedBox(height: isCompact ? 5 : 7),

          // Club Full Name (up to 2 lines so long names never get truncated)
          Text(
            club.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isCompact ? 12 : 13,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),

          // League & Country pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
            decoration: BoxDecoration(
              color: club.isNationalTeam
                  ? AppColors.pitchGreen.withValues(alpha: 0.22)
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(8),
              border: club.isNationalTeam
                  ? Border.all(color: AppColors.pitchGreen.withValues(alpha: 0.6), width: 0.8)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (club.isNationalTeam) ...[
                  const Icon(
                    Icons.public_rounded,
                    size: 11,
                    color: AppColors.greenLight,
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    club.isNationalTeam
                        ? 'ÜLKE • ${club.country}'
                        : '${club.country} • ${club.league}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: club.isNationalTeam ? AppColors.greenLight : AppColors.textSecondary,
                      fontWeight: club.isNationalTeam ? FontWeight.w800 : FontWeight.w500,
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
