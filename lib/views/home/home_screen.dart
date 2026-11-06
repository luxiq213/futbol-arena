import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/play_mode_model.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../widgets/app_floating_glass_footer.dart';
import '../widgets/game_mode_selector_sheet.dart';
import '../widgets/stadium_background.dart';
import '../games/career/career_setup_screen.dart';
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
      body: StadiumBackground(
        showFieldLines: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Compact Top Header sitting directly under the phone status bar
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
              child: _buildCompactTopBar(user),
            ),

            // Main Swipeable Content Area + Floating Glass Footer
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _activeTab = index);
                      },
                      children: [
                        // Page 0: Oyunlar (Games Hub)
                        SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(14, 2, 14, bottomInset + 80),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildCategoryFilterRow(),
                              const SizedBox(height: 10),
                              _buildGamesSection(context),
                            ],
                          ),
                        ),

                        // Page 1: Sıralama (Leaderboard)
                        SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(14, 2, 14, bottomInset + 80),
                          child: const LeaderboardScreen(isEmbedded: true),
                        ),

                        // Page 2: Profil (Profile & Settings)
                        SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(14, 2, 14, bottomInset + 80),
                          child: const ProfileScreen(isEmbedded: true),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTopBar(UserModel? user) {
    final currentTitle = _tabTitles[_activeTab.clamp(0, _tabTitles.length - 1)];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0E2B1F).withValues(alpha: 0.92),
            const Color(0xFF071A12).withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.borderGreen.withValues(alpha: 0.42),
          width: 0.9,
        ),
      ),
      child: Row(
        children: [
          // Left: Avatar / Badge + App Title & User Subtitle
          GestureDetector(
            onTap: () => _onFooterTabTapped(2),
            child: Container(
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
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _onFooterTabTapped(2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        currentTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.pitchGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          user?.username ?? 'Kaptan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.greenLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${user?.favoriteTeam ?? "Galatasaray"} • ${user?.rankTitle ?? "Genç Yetenek"}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Right: Gold XP Badge
          GestureDetector(
            onTap: () => _onFooterTabTapped(1),
            child: Container(
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
                  const SizedBox(width: 3),
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
          ),
        ],
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
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5.5),
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
                    fontSize: 11,
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
          const SizedBox(height: 5),
          _buildCareerHeroCard(context),
          const SizedBox(height: 11),
        ],

        // 2. Bölüm: Trivia & Analiz Düelloları (2'li Yan Yana Bento Grid)
        if (showDuel) ...[
          _buildSectionHeader('OYUN MODLARI • TRİVİA & DÜELLO', 'Kendini Sına • Online • Davet'),
          const SizedBox(height: 5),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: BentoGameModeCard(
                    title: 'Ortak Oyuncu Düellosu (3-2-1)',
                    subtitle: 'Kendini sına, online/AI rakiple eşleş veya arkadaşını davet et.',
                    icon: Icons.compare_arrows_rounded,
                    tag: 'SOLO / DÜELLO',
                    tagColor: AppColors.pitchGreen,
                    onTap: () {
                      showGameModeSelectorSheet(
                        context,
                        targetGame: GameTargetType.commonPlayer,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: BentoGameModeCard(
                    title: '5 Takım 1 Oyuncu',
                    subtitle: '5 kulübün en çoğunda oynamış yıldızı tek başına veya düelloda bul.',
                    icon: Icons.shield_outlined,
                    tag: 'SOLO / DÜELLO',
                    tagColor: AppColors.greenLight,
                    onTap: () {
                      showGameModeSelectorSheet(
                        context,
                        targetGame: GameTargetType.fiveClubs,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 11),
        ],

        // 3. Bölüm: Taktik Tahtası (Futbol Grid 3x3)
        if (showTactics) ...[
          _buildSectionHeader('TAKTİK TAHTASI', 'Kendini Sına • 1v1 Düello'),
          const SizedBox(height: 5),
          GameModeCard(
            title: 'Futbol Grid 3x3',
            subtitle: 'Kulüp kesişim matrisini tek başına çöz veya online/arkadaş düellosunda yarış.',
            icon: Icons.grid_3x3_outlined,
            tag: 'STRATEJİ MATRİSİ',
            tagColor: AppColors.gold,
            trailingPreview: _buildMiniTacticalGridPreview(),
            onTap: () {
              showGameModeSelectorSheet(
                context,
                targetGame: GameTargetType.footballGrid,
              );
            },
          ),
          const SizedBox(height: 4),
        ],

        // 4. Bölüm: Arkadaş & Çok Oyunculu Arena (2'li Yan Yana Bento Grid)
        if (showParty) ...[
          _buildSectionHeader('ARKADAŞ & ÇOK OYUNCULU ARENA', 'Yan Yana & Online'),
          const SizedBox(height: 5),
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
                const SizedBox(width: 9),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.pitchGreen.withValues(alpha: 0.65),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pitchGreen.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mini Pitch Badge
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF14904C),
                            Color(0xFF095028),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.greenLight, width: 1.1),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.sports_soccer,
                          color: Colors.white,
                          size: 22,
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
                                  color: AppColors.gold.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: AppColors.gold, width: 0.8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded, size: 10, color: AppColors.gold),
                                    SizedBox(width: 3),
                                    Text(
                                      'YENİ TİKTOK MODU',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
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
                                      size: 9,
                                      color: AppColors.greenLight,
                                    ),
                                  ],
                                ),
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
                            'Mevkini ve bölgeni seç, kulüp tekliflerini değerlendir, kupalar kazan ve paylaşılabilir efsane jübile kartını çıkar!',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textSecondary,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Feature Badges
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildHeroBadge(Icons.hourglass_top_outlined, '10 Dönem Simülasyon'),
                    _buildHeroBadge(Icons.sports_soccer_rounded, 'Penaltı Kader Anları'),
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
