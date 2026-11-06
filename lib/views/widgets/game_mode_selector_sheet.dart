import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/play_mode_model.dart';
import '../games/common_player/common_player_screen.dart';
import '../games/five_clubs/five_clubs_screen.dart';
import '../games/football_grid/football_grid_screen.dart';
import '../games/online_lobby/lobby_hub_screen.dart';
import '../games/online_lobby/matchmaking_screen.dart';
import '../games/party_mode/party_setup_screen.dart';

void showGameModeSelectorSheet(
  BuildContext context, {
  required GameTargetType targetGame,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => GameModeSelectorSheet(targetGame: targetGame),
  );
}

class GameModeSelectorSheet extends StatefulWidget {
  final GameTargetType targetGame;

  const GameModeSelectorSheet({
    super.key,
    required this.targetGame,
  });

  @override
  State<GameModeSelectorSheet> createState() => _GameModeSelectorSheetState();
}

class _GameModeSelectorSheetState extends State<GameModeSelectorSheet> {
  GameDifficulty _selectedDifficulty = GameDifficulty.medium;

  void _launchSolo(BuildContext context) {
    Navigator.of(context).pop();
    Widget destination;
    switch (widget.targetGame) {
      case GameTargetType.commonPlayer:
        destination = CommonPlayerScreen(
          playMode: PlayModeType.solo,
          difficulty: _selectedDifficulty,
        );
        break;
      case GameTargetType.fiveClubs:
        destination = FiveClubsScreen(
          playMode: PlayModeType.solo,
          difficulty: _selectedDifficulty,
        );
        break;
      case GameTargetType.footballGrid:
        destination = FootballGridScreen(
          playMode: PlayModeType.solo,
          difficulty: _selectedDifficulty,
        );
        break;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  void _launchOnlineMatchmaking(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MatchmakingScreen(
          targetGame: widget.targetGame,
          difficulty: _selectedDifficulty,
        ),
      ),
    );
  }

  void _launchFriendInvite(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LobbyHubScreen(initialGameTarget: widget.targetGame),
      ),
    );
  }

  void _launchLocalParty(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PartySetupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(18, 14, 18, bottomInset + 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0E2B1F),
            Color(0xFF061610),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.pitchGreen.withValues(alpha: 0.65), width: 1.4),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppColors.pitchGreen, width: 1.2),
                ),
                child: const Center(
                  child: Icon(Icons.sports_soccer, color: AppColors.gold, size: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.targetGame.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.targetGame.shortDescription,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 1. Difficulty Selector Section (Kolay / Orta / Zor)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '1. ZORLUK SEVİYESİNİ SEÇ',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.greenLight,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 0.8),
                ),
                child: Text(
                  _selectedDifficulty.badgeText,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: GameDifficulty.values.map((diff) {
                    final isSelected = _selectedDifficulty == diff;
                    Color diffColor;
                    switch (diff) {
                      case GameDifficulty.easy:
                        diffColor = AppColors.greenLight;
                        break;
                      case GameDifficulty.medium:
                        diffColor = AppColors.gold;
                        break;
                      case GameDifficulty.hard:
                        diffColor = const Color(0xFFF97316);
                        break;
                    }

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedDifficulty = diff),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? diffColor.withValues(alpha: 0.22)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? diffColor : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                diff.label,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? Colors.white : AppColors.textMuted,
                                ),
                              ),
                              Text(
                                '${diff.pointsMultiplier}x Puan',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? diffColor : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    _selectedDifficulty.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Text(
            '2. OYNANIŞ MODUNU SEÇ',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.greenLight,
            ),
          ),
          const SizedBox(height: 8),

          // 1. Kendini Sına (Solo)
          _buildModeOptionCard(
            icon: Icons.person_outline_rounded,
            title: 'Kendini Sına (Tek Başına)',
            subtitle: 'Rakip olmadan kendi futbol bilgini sına ve rekor puan topla.',
            badge: 'SOLO',
            badgeColor: AppColors.greenLight,
            onTap: () => _launchSolo(context),
          ),

          const SizedBox(height: 9),

          // 2. Online Eşleşme (Falls back to AI if no online player)
          _buildModeOptionCard(
            icon: Icons.public_rounded,
            title: 'Online Eşleşme (1v1 Düello)',
            subtitle: 'Online rakip ara; bulunamazsa anında Yapay Zeka rakiple düelloya gir.',
            badge: 'ONLİNE / AI',
            badgeColor: AppColors.gold,
            onTap: () => _launchOnlineMatchmaking(context),
          ),

          const SizedBox(height: 9),

          // 3. Arkadaşınla Davetli Düello (Invite Room)
          _buildModeOptionCard(
            icon: Icons.vpn_key_outlined,
            title: 'Arkadaşınla Düello (Davet İle)',
            subtitle: '6 haneli davet koduyla oda kur veya arkadaşının odasına katıl.',
            badge: 'DAVET',
            badgeColor: AppColors.pitchGreen,
            onTap: () => _launchFriendInvite(context),
          ),

          if (widget.targetGame == GameTargetType.commonPlayer) ...[
            const SizedBox(height: 9),
            // 4. Yan Yana Parti Modu (3-2-1)
            _buildModeOptionCard(
              icon: Icons.alarm_outlined,
              title: 'Yan Yana Parti Düellosu (3-2-1)',
              subtitle: 'Aynı telefonda arkadaşlarınla masada süreye karşı yarış.',
              badge: 'YAN YANA',
              badgeColor: AppColors.silver,
              onTap: () => _launchLocalParty(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModeOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: badgeColor.withValues(alpha: 0.45),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.darkGreen.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.6), width: 1.0),
                ),
                child: Center(
                  child: Icon(icon, color: badgeColor, size: 19),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: badgeColor.withValues(alpha: 0.5), width: 0.7),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: badgeColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
