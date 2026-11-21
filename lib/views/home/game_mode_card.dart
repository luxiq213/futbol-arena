import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/sound_effects.dart';
import '../../providers/locale_provider.dart';

class GameModeCard extends StatefulWidget {
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
  State<GameModeCard> createState() => _GameModeCardState();
}

class _GameModeCardState extends State<GameModeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.tagColor;
    final topColor = Color.lerp(const Color(0xFF0A2018), accent, 0.12)!;
    const bottomColor = Color(0xFF06150F);

    return Listener(
      onPointerDown:
          widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: (_isPressed && widget.onTap != null) ? 0.985 : 1.0,
        duration: const Duration(milliseconds: 95),
        curve: Curves.easeOutCubic,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                topColor.withValues(alpha: 0.90),
                bottomColor.withValues(alpha: 0.92),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isComingSoon
                  ? AppColors.border
                  : accent.withValues(alpha: 0.36),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onTap == null
                  ? null
                  : () {
                      GameFeedback.tick();
                      widget.onTap!();
                    },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Subtle faint diagonal watermark on right side
                    Positioned(
                      right: -12,
                      bottom: -14,
                      child: Transform.rotate(
                        angle: -0.22,
                        child: Icon(
                          widget.icon,
                          size: 72,
                          color: accent.withValues(alpha: 0.055),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          _buildModeIconBadge(
                            widget.icon,
                            accent: accent,
                            size: 44,
                            iconSize: 22,
                          ),
                          const SizedBox(width: 13),

                          // Text Information
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.25,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    _buildTagPill(widget.tag, accent),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (widget.trailingPreview != null) ...[
                            const SizedBox(width: 10),
                            widget.trailingPreview!,
                          ] else ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: accent,
                                size: 18,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A vertical Bento-style tactical card for 2-column grid separation of game modes
class BentoGameModeCard extends StatefulWidget {
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
  State<BentoGameModeCard> createState() => _BentoGameModeCardState();
}

class _BentoGameModeCardState extends State<BentoGameModeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocaleProvider>();
    final accent = widget.tagColor;
    final topColor = Color.lerp(const Color(0xFF0A2118), accent, 0.13)!;
    const bottomColor = Color(0xFF06150F);

    return Listener(
      onPointerDown:
          widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onPointerUp: (_) => setState(() => _isPressed = false),
      onPointerCancel: (_) => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: (_isPressed && widget.onTap != null) ? 0.975 : 1.0,
        duration: const Duration(milliseconds: 95),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                topColor.withValues(alpha: 0.88),
                bottomColor.withValues(alpha: 0.92),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accent.withValues(alpha: 0.36),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: widget.onTap == null
                  ? null
                  : () {
                      GameFeedback.tick();
                      widget.onTap!();
                    },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Subtle mode watermark icon in the lower right corner
                    Positioned(
                      right: -12,
                      bottom: -14,
                      child: Transform.rotate(
                        angle: -0.22,
                        child: Icon(
                          widget.icon,
                          size: 68,
                          color: accent.withValues(alpha: 0.065),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Mode Icon + Tag Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildModeIconBadge(
                                widget.icon,
                                accent: accent,
                                size: 38,
                                iconSize: 19,
                              ),
                              Flexible(child: _buildTagPill(widget.tag, accent)),
                            ],
                          ),
                          const SizedBox(height: 11),

                          // Mode Title
                          Text(
                            widget.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.18,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Subtitle
                          Text(
                            widget.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(height: 10),

                          // Bottom Action Row
                          Row(
                            children: [
                              Text(
                                loc.t('play_now'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: accent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildModeIconBadge(
  IconData icon, {
  required Color accent,
  required double size,
  required double iconSize,
}) {
  final topTint = Color.lerp(accent, Colors.black, 0.25)!;
  final bottomTint = Color.lerp(accent, Colors.black, 0.62)!;

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(11),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.22),
        width: 0.9,
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [topTint, bottomTint],
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: 0.28),
          blurRadius: 8,
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
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
    decoration: BoxDecoration(
      color: tagColor.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: tagColor.withValues(alpha: 0.45),
        width: 0.7,
      ),
    ),
    child: Text(
      tag,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: tagColor,
        fontSize: 9,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.45,
      ),
    ),
  );
}
