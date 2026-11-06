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

  static const List<String> _tabTitles = [
    'Futbol Trivia',
    'Sıralama & Lig',
    'Oyuncu Profili',
  ];

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
      appBar: AppTopBar(
        title: _tabTitles[_activeTab.clamp(0, _tabTitles.length - 1)],
        showProfileShortcut: false,
      ),
      body: StadiumBackground(
        showFieldLines: true,
        child: Stack(
          children: [
            // Horizontal Swipeable PageView (Oyunlar <-> Sıralama <-> Profil)
            Positioned.fill(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _activeTab = index);
                },
                children: [
                  // Page 0: Oyunlar (Games Hub)
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(14, 4, 14, bottomInset + 84),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildUserHeaderCard(user),
                        const SizedBox(height: 10),
                        _buildCategoryFilterRow(),
                        const SizedBox(height: 12),
                        _buildGamesSection(context),
                      ],
                    ),
                  ),

                  // Page 1: Sıralama (Leaderboard)
                  SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(14, 4, 14, bottomInset + 84),
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
                    padding: EdgeInsets.fromLTRB(14, 4, 14, bottomInset + 84),
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

            // Floating Smoked Glass Footer
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
    return GestureDetector(
      onTap: () => _onFooterTabTapped(2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0E2B1F).withValues(alpha: 0.90),
              const Color(0xFF081B13).withValues(alpha: 0.90),
            ],
          ),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: AppColors.borderGreen.withValues(alpha: 0.40),
            width: 0.9,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.darkGreen,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.pitchGreen, width: 1.1),
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
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.username ?? 'Kaptan',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${user?.favoriteTeam ?? "Galatasaray"} • ${user?.rankTitle ?? "Genç Yetenek"}',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.45), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 13, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(
                    '${user?.points ?? 0} XP',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilterRow() {
    final categories = [
      {'id': 'all', 'label': 'Tümü'},
      {'id': 'career', 'label': 'Kariyer'},
      {'id': 'duel', 'label': 'Düello'},
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
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.pitchGreen.withValues(alpha: 0.25)
                      : AppColors.surface.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.pitchGreen : AppColors.border,
                    width: isSelected ? 1.2 : 0.8,
                  ),
                ),
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
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
        // 1. Vitrin: Futbolcu Kariyeri Hero Banner
        if (showCareer) ...[
          _buildSectionHeader('KARİYER SİMÜLASYONU', 'TikTok Filtre Modu'),
          const SizedBox(height: 6),
          _buildCareerHeroCard(context),
          const SizedBox(height: 14),
        ],

        // 2. Bölüm: Trivia & Analiz Düelloları (2'li Yan Yana Bento Grid)
        if (showDuel) ...[
          _buildSectionHeader('OYUN MODLARI • TRİVİA & DÜELLO', 'Bireysel Rekabet'),
          const SizedBox(height: 6),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: BentoGameModeCard(
                    title: 'Ortak Oyuncu Düellosu (3-2-1)',
                    subtitle: 'İki kulüpte de forma giymiş ortak efsaneyi bul.',
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
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BentoGameModeCard(
                    title: '5 Takım 1 Oyuncu',
                    subtitle: '5 kulübün en çoğunda oynamış yıldızı keşfet.',
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // 3. Bölüm: Taktik Tahtası (Futbol Grid 3x3)
        if (showTactics) ...[
          _buildSectionHeader('TAKTİK TAHTASI', '3x3 Kesişim Matrisi'),
          const SizedBox(height: 6),
          GameModeCard(
            title: 'Futbol Grid 3x3',
            subtitle: 'Kulüpler ve başarı kriterlerinin kesişim noktalarına uygun oyuncuları yerleştir.',
            icon: Icons.grid_3x3_outlined,
            tag: 'STRATEJİ MATRİSİ',
            tagColor: AppColors.gold,
            trailingPreview: _buildMiniTacticalGridPreview(),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FootballGridScreen()),
              );
            },
          ),
          const SizedBox(height: 6),
        ],

        // 4. Bölüm: Arkadaş & Çok Oyunculu Arena (2'li Yan Yana Bento Grid)
        if (showParty) ...[
          _buildSectionHeader('ARKADAŞ & ÇOK OYUNCULU ARENA', 'Yan Yana & Online'),
          const SizedBox(height: 6),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: BentoGameModeCard(
                    title: '3-2-1 Düello Turları (Yan Yana)',
                    subtitle: 'Masada arkadaşlarınla süre bitmeden ortak oyuncuyu söyle.',
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
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BentoGameModeCard(
                    title: 'Online Oda & Arkadaş Daveti',
                    subtitle: '6 haneli oda kodu kur, uzaktaki arkadaşlarınla yarış.',
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
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, String rightSubtitle) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.pitchGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: AppColors.greenLight,
              ),
            ),
          ],
        ),
        Text(
          rightSubtitle,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniTacticalGridPreview() {
    return Container(
      width: 38,
      height: 38,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 0.8),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemBuilder: (_, index) {
          final isHighlighted = index == 0 || index == 4 || index == 8;
          return Container(
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.gold.withValues(alpha: 0.75)
                  : AppColors.pitchGreen.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(1.5),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCareerHeroCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF12402A),
            Color(0xFF0A2619),
            Color(0xFF06160F),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.pitchGreen.withValues(alpha: 0.65),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pitchGreen.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CareerSetupScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mini Pitch Badge
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF14904C),
                            Color(0xFF095028),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(color: AppColors.greenLight, width: 1.1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.sports_soccer,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: AppColors.gold, width: 0.8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded, size: 11, color: AppColors.gold),
                                    SizedBox(width: 3),
                                    Text(
                                      'YENİ TİKTOK MODU',
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.pitchGreen.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Başla',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.greenLight,
                                      ),
                                    ),
                                    SizedBox(width: 3),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 10,
                                      color: AppColors.greenLight,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Futbolcu Kariyeri Yap',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Mevkini ve bölgeni seç, kulüp tekliflerini değerlendir, kupalar kazan ve paylaşılabilir efsane jübile kartını çıkar!',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
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
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildHeroBadge(Icons.hourglass_top_outlined, '6 Dönem Simülasyon'),
                    _buildHeroBadge(Icons.swap_horiz_rounded, 'Transfer Masası'),
                    _buildHeroBadge(Icons.workspace_premium_outlined, 'Paylaşılabilir Jübile Kartı'),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
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
