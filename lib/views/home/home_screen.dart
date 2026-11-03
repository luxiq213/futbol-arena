import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/stadium_background.dart';
import '../widgets/app_app_bar.dart';
import '../games/common_player/common_player_screen.dart';
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
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _GamesHomeTab(),
      const LeaderboardScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondary,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (idx) => setState(() => _currentIndex = idx),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.pitchGreen,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_soccer),
              label: 'Oyunlar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_rounded),
              label: 'Sıralama',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

class _GamesHomeTab extends StatelessWidget {
  const _GamesHomeTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: const AppTopBar(title: 'Futbol Party ⚽'),
      body: StadiumBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // WELCOME STREAK BANNER
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.pitchGreen.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.pitchGreen.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Text(user?.avatar ?? '⚽', style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hoş geldin, ${user?.username ?? "Kaptan"}!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${user?.favoriteTeam ?? "Futbol"} • ${user?.rankTitle ?? "Genç Yetenek"}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.orange.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '${user?.currentStreak ?? 0}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // FEATURED PARTY HERO BANNER
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PartySetupScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.fireGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepOrange.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                '🔥 ARKADAŞLARLA YAN YANA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '3-2-1 Bomba!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Süre bitmeden ortak oyuncuyu söyle, bombadan kurtul!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('💣', style: TextStyle(fontSize: 32)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ACTIVE GAME MODES
              const Text(
                'Oyun Modları',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // MODE 1: Ortak Futbolcu (Who Played For Both)
              GameModeCard(
                title: 'Ortak Futbolcu Bul',
                subtitle: 'İki dev kulüpte de forma giymiş efsaneleri tahmin et!',
                emoji: '⚽',
                tag: 'KLASİK DÜELLO',
                tagColor: AppColors.pitchGreen,
                gradient: AppColors.pitchGradient,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CommonPlayerScreen()),
                  );
                },
              ),

              // MODE 2: Online Lobi
              GameModeCard(
                title: 'Online Oda & Arkadaş Daveti',
                subtitle: 'Oda kodu oluştur, uzaktaki arkadaşlarınla canlı oyna!',
                emoji: '🌐',
                tag: 'ÇOK OYUNCULU',
                tagColor: AppColors.electricBlue,
                gradient: AppColors.blueGradient,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LobbyHubScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // FUTURE MODES (EXTENSIBLE HUB FOR UPCOMING IDEAS)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Yakında Gelecek Modlar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.purple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'YENİ FİKİRLER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.purple,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              GameModeCard(
                title: 'Kariyer Yolu Tahmini',
                subtitle: 'Sırasıyla oynadığı kulüpleri gör, futbolcuyu bil!',
                emoji: '🗺️',
                tag: 'YAKINDA',
                tagColor: AppColors.purple,
                gradient: const LinearGradient(colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)]),
                isComingSoon: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bu mod yakında aktif olacak! Fikirlerinizi ekleyebilirsiniz.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              GameModeCard(
                title: 'Transfer Değeri (Kim Daha Pahalı?)',
                subtitle: 'İki transferden hangisi daha pahalıydı? Yüksek/Düşük!',
                emoji: '💰',
                tag: 'YAKINDA',
                tagColor: AppColors.gold,
                gradient: AppColors.goldGradient,
                isComingSoon: true,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transfer Değeri modu yakında gelecek!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
