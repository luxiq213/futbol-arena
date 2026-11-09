import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GameModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String tag;
  final Color tagColor;
  final VoidCallback? onTap;
  final bool isComingSoon;
  final Widget? trailingPreview;

  const GameModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tag,
    this.tagColor = AppColors.pitchGreen,
    required this.onTap,
    this.isComingSoon = false,
    this.trailingPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0E2A1F).withValues(alpha: 0.78),
            const Color(0xFF081A13).withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isComingSoon
              ? AppColors.border
              : AppColors.borderGreen.withValues(alpha: 0.40),
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                // Turf Icon Box (Miniature football pitch tile)
                _buildTurfIconBadge(icon, size: 40, iconSize: 20),
                const SizedBox(width: 11),

                // Text Information (Title + Subtitle + Tag)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildTagPill(tag, tagColor),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),

                if (trailingPreview != null) ...[
                  const SizedBox(width: 10),
                  trailingPreview!,
                ] else ...[
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.pitchGreen,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A vertical Bento-style tactical card for 2-column grid separation of game modes
class BentoGameModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String tag;
  final Color tagColor;
  final VoidCallback? onTap;

  const BentoGameModeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tag,
    this.tagColor = AppColors.pitchGreen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F2D21).withValues(alpha: 0.78),
            const Color(0xFF071912).withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderGreen.withValues(alpha: 0.42),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Turf Icon + Tag Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTurfIconBadge(icon, size: 36, iconSize: 18),
                    Flexible(child: _buildTagPill(tag, tagColor)),
                  ],
                ),
                const SizedBox(height: 10),

                // Mode Title
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Full 2-line Subtitle
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),

                // Bottom Action Row
                Row(
                  children: [
                    Text(
                      'Sahaya Çık',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: tagColor,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: tagColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildTurfIconBadge(IconData icon, {required double size, required double iconSize}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.18),
        width: 0.8,
      ),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF14904C),
          Color(0xFF0A542B),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF083D1F).withValues(alpha: 0.4),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Center(
      child: Icon(
        icon,
        color: Colors.white,
        size: iconSize,
      ),
    ),
  );
}

Widget _buildTagPill(String tag, Color tagColor) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: tagColor.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(
        color: tagColor.withValues(alpha: 0.40),
        width: 0.7,
      ),
    ),
    child: Text(
      tag,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: tagColor,
        fontSize: 8.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    ),
  );
}
