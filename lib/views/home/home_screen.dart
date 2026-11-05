import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../widgets/app_app_bar.dart';
import '../widgets/app_floating_glass_footer.dart';
import '../widgets/stadium_background.dart';
import '../games/common_player/common_player_screen.dart';
import '../games/five_clubs/five_clubs_screen.dart';
import '../games/football_grid/football_grid_screen.dart';
import '../games/party_mode/party_setup_screen.dart';
import '../games/online_lobby/lobby_hub_screen.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../profile/profile_screen.dart';
import 'game_mode_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activeTab = 0; // 0: Oyunlar, 1: Sıralama, 2: Profil

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Futbol Trivia'),
      body: StadiumBackground(
        showSkyEffects: true,
        child: Stack(
          children: [
            // Scrollable Content Layer
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(14, 6, 14, bottomInset + 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Compact User Status Header Card
                    _buildUserHeaderCard(user),

                    const SizedBox(height: 10),

                    // Modular Content based on _activeTab
                    if (_activeTab == 0) ...[
                      _buildGamesSection(context),
                    ] else if (_activeTab == 1) ...[
                      const LeaderboardScreen(isEmbedded: true),
                    ] else ...[
                      const ProfileScreen(isEmbedded: true),
                    ],
                  ],
                ),
              ),
            ),

            // Persistent Colorless Floating Glass Footer
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomInset > 0 ? bottomInset + 2 : 8,
              child: AppFloatingGlassFooter(
                activeIndex: _activeTab,
                onTabSelected: (index) {
                  setState(() => _activeTab = index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeaderCard(UserModel? user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderGreen.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.darkGreen,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.pitchGreen, width: 1.0),
            ),
            child: Center(
              child: Text(
                user?.avatar.isNotEmpty == true ? user!.avatar : 'KP',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.greenLight,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user?.username ?? 'Kaptan',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${user?.favoriteTeam ?? "Galatasaray"} • ${user?.rankTitle ?? "Genc Yetenek"}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_outline, size: 12, color: AppColors.gold),
                const SizedBox(width: 3),
                Text(
                  '${user?.points ?? 0} XP',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        const Text(
          'OYUN MODLARI',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppColors.pitchGreen,
          ),
        ),
        const SizedBox(height: 6),

        // Mode 1: Ortak Oyuncu Düellosu (3-2-1)
        GameModeCard(
          title: 'Ortak Oyuncu Düellosu (3-2-1)',
          subtitle: 'Iki dev kulüp armasini gör, her iki takimda oynamis efsaneyi bul.',
          icon: Icons.compare_arrows_rounded,
          tag: 'KLASİK DÜELLO',
          tagColor: AppColors.pitchGreen,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommonPlayerScreen()),
            );
          },
        ),

        // Mode 2: 5 Takım 1 Oyuncu (Solo & Scout AI)
        GameModeCard(
          title: '5 Takim 1 Oyuncu',
          subtitle: 'Ekrana gelen 5 kulübün en cogunda forma giymis futbolcuyu tespit et.',
          icon: Icons.shield_outlined,
          tag: 'REKOR ANALİZİ',
          tagColor: AppColors.greenLight,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FiveClubsScreen()),
            );
          },
        ),

        // Mode 3: Futbol Grid (3x3 Tic-Tac-Toe)
        GameModeCard(
          title: 'Futbol Grid 3x3',
          subtitle: 'Kulüpler ve basari kriterlerinin kesisim noktalarina uygun oyunculari yerlestir.',
          icon: Icons.grid_3x3_outlined,
          tag: 'STRATEJİ MATRİSİ',
          tagColor: AppColors.gold,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FootballGridScreen()),
            );
          },
        ),

        // Mode 4: 3-2-1 Bomba (Masada / Yan Yana Arkadaş Grubu)
        GameModeCard(
          title: '3-2-1 Düello Turlari (Yan Yana)',
          subtitle: 'Masada arkadaslarinla elden ele oynayin. Süre bitmeden ortak oyuncuyu söyle!',
          icon: Icons.alarm_outlined,
          tag: 'PARTİ MODU',
          tagColor: AppColors.silver,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PartySetupScreen()),
            );
          },
        ),

        // Mode 5: Online Lobi & Oda Daveti
        GameModeCard(
          title: 'Online Oda & Arkadas Daveti',
          subtitle: '6 haneli oda kodu olustur, uzaktaki arkadaslarinla ayni anda yaris.',
          icon: Icons.cell_tower_outlined,
          tag: 'ÇOK OYUNCULU',
          tagColor: AppColors.pitchGreen,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LobbyHubScreen()),
            );
          },
        ),
      ],
    );
  }
}
