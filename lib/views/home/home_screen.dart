import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../widgets/app_app_bar.dart';
import '../widgets/app_floating_glass_footer.dart';
import '../widgets/stadium_background.dart';
import '../games/career/career_setup_screen.dart';
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
  late final PageController _pageController;

  // Game category filter
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _activeTab);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFooterTabTapped(int index) {
    if (_activeTab == index) return;
    setState(() => _activeTab = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppTopBar(title: 'Futbol Trivia'),
      body: StadiumBackground(
        showFieldLines: true,
        child: Stack(
          children: [
            // Horizontal Swipeable PageView
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _activeTab = index);
                },
                children: [
                  // Page 0: Oyunlar (Games Hub)
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(14, 6, 14, bottomInset + 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildUserHeaderCard(user),
                        const SizedBox(height: 10),
                        _buildCategoryFilterRow(),
                        const SizedBox(height: 10),
                        _buildGamesSection(context),
                      ],
                    ),
                  ),

                  // Page 1: Sıralama (Leaderboard)
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(14, 6, 14, bottomInset + 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildUserHeaderCard(user),
                        const SizedBox(height: 10),
                        const LeaderboardScreen(isEmbedded: true),
                      ],
                    ),
                  ),

                  // Page 2: Profil (Profile & Settings)
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(14, 6, 14, bottomInset + 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const ProfileScreen(isEmbedded: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Floating Colorless Glass Footer
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomInset > 0 ? bottomInset + 2 : 8,
              child: AppFloatingGlassFooter(
                activeIndex: _activeTab,
                onTabSelected: _onFooterTabTapped,
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

  Widget _buildCategoryFilterRow() {
    final categories = [
      {'id': 'all', 'label': 'Tumu'},
      {'id': 'career', 'label': 'Kariyer'},
      {'id': 'duel', 'label': 'Duello'},
      {'id': 'tactics', 'label': 'Taktik'},
      {'id': 'party', 'label': 'Parti & Online'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() => _selectedCategory = cat['id']!);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.pitchGreen.withValues(alpha: 0.25)
                      : AppColors.surface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.pitchGreen : AppColors.border,
                    width: isSelected ? 1.2 : 0.8,
                  ),
                ),
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGamesSection(BuildContext context) {
    final showAll = _selectedCategory == 'all';
    final showCareer = showAll || _selectedCategory == 'career';
    final showDuel = showAll || _selectedCategory == 'duel';
    final showTactics = showAll || _selectedCategory == 'tactics';
    final showParty = showAll || _selectedCategory == 'party';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Hero Featured Banner for New Career Mode
        if (showCareer) ...[
          _buildCareerHeroCard(context),
          const SizedBox(height: 10),
        ],

        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'OYUN MODLARI',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.pitchGreen,
              ),
            ),
            Text(
              'Yana kaydirarak sayfalara gec',
              style: TextStyle(
                fontSize: 9.5,
                color: AppColors.textMuted.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Mode 1: Ortak Oyuncu Düellosu (3-2-1)
        if (showDuel)
          GameModeCard(
            title: 'Ortak Oyuncu Düellosu (3-2-1)',
            subtitle: 'İki dev kulüp armasını gör, her iki takımda oynamış efsaneyi bul.',
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
        if (showDuel)
          GameModeCard(
            title: '5 Takim 1 Oyuncu',
            subtitle: 'Ekrana gelen 5 kulubun en cogunda forma giymis futbolcuyu tespit et.',
            icon: Icons.shield_outlined,
            tag: 'REKOR ANALIZI',
            tagColor: AppColors.greenLight,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FiveClubsScreen()),
              );
            },
          ),

        // Mode 3: Futbol Grid (3x3 Tic-Tac-Toe)
        if (showTactics)
          GameModeCard(
            title: 'Futbol Grid 3x3',
            subtitle: 'Kulupler ve basari kriterlerinin kesisim noktalarina uygun oyunculari yerlestir.',
            icon: Icons.grid_3x3_outlined,
            tag: 'STRATEJI MATRISI',
            tagColor: AppColors.gold,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FootballGridScreen()),
              );
            },
          ),

        // Mode 4: 3-2-1 Bomba (Masada / Yan Yana Arkadaş Grubu)
        if (showParty)
          GameModeCard(
            title: '3-2-1 Duello Turlari (Yan Yana)',
            subtitle: 'Masada arkadaslarinla elden ele oynayin. Sure bitmeden ortak oyuncuyu soyle!',
            icon: Icons.alarm_outlined,
            tag: 'PARTI MODU',
            tagColor: AppColors.silver,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PartySetupScreen()),
              );
            },
          ),

        // Mode 5: Online Lobi & Oda Daveti
        if (showParty)
          GameModeCard(
            title: 'Online Oda & Arkadas Daveti',
            subtitle: '6 haneli oda kodu olustur, uzaktaki arkadaslarinla ayni anda yaris.',
            icon: Icons.cell_tower_outlined,
            tag: 'COK OYUNCULU',
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

  Widget _buildCareerHeroCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F3824),
            Color(0xFF0A2216),
            Color(0xFF061410),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.pitchGreen.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pitchGreen.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CareerSetupScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mini Pitch Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.pitchGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.pitchGreen, width: 1.2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.sports_soccer,
                          color: AppColors.greenLight,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.gold, width: 0.8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star, size: 10, color: AppColors.gold),
                                    SizedBox(width: 3),
                                    Text(
                                      'YENI TIKTOK MODU',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: AppColors.pitchGreen,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Futbolcu Kariyeri Yap',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Mevkini ve bolgeni sec, transfer tekliflerini yonet, 36 yasina kadar kupalar kazan ve paylasilabilir jubile kartini cikar!',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Feature Badges
                Row(
                  children: [
                    _buildHeroBadge(Icons.hourglass_top_outlined, '6 Donem Similasyon'),
                    const SizedBox(width: 6),
                    _buildHeroBadge(Icons.swap_horiz_rounded, 'Transfer Masasi'),
                    const SizedBox(width: 6),
                    _buildHeroBadge(Icons.workspace_premium_outlined, 'Jubile Karti'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.pitchGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
