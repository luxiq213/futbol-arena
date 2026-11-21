import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../profile/profile_screen.dart';
import 'player_avatar_widget.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showProfileShortcut;

  const AppTopBar({
    super.key,
    required this.title,
    this.showProfileShortcut = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return AppBar(
      title: Text(title),
      actions: [
        if (showProfileShortcut && user != null)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0C221A),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlayerAvatarWidget(
                    avatarKey: user.avatar.isNotEmpty ? user.avatar : 'goat_10',
                    size: 22,
                    borderColor: AppColors.pitchGreen,
                    borderWidth: 1.0,
                  ),
                  const SizedBox(width: 7),
                  const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    '${user.points} XP',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
