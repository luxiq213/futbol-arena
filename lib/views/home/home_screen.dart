import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/play_mode_model.dart';
import '../../data/models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../widgets/ad_free_banner_and_sheet.dart';
import '../widgets/app_floating_glass_footer.dart';
import '../widgets/game_mode_selector_sheet.dart';
import '../widgets/language_selector_sheet.dart';
import '../widgets/player_avatar_widget.dart';
import '../widgets/stadium_background.dart';
import '../games/career/career_setup_screen.dart';
import '../games/league_draft/league_draft_screen.dart';
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
    final loc = context.watch<LocaleProvider>();
    final user = auth.currentUser;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StadiumBackground(
        showFieldLines: true,
        showLiveMatch: _activeTab == 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Compact Top Header sitting directly under the phone status bar
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 4),
              child: _buildCompactTopBar(user, loc),
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
                          child: _buildGamesSection(context, loc),
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

  Widget _buildCompactTopBar(UserModel? user, LocaleProvider loc) {
    final tabTitles = [
      loc.t('app_title'),
      loc.t('header_leaderboard'),
      loc.t('header_profile'),
    ];
    final currentTitle = tabTitles[_activeTab.clamp(0, tabTitles.length - 1)];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0E2B1F).withValues(alpha: 0.94),
            const Color(0xFF071A12).withValues(alpha: 0.94),
          ],
        ),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: AppColors.borderGreen.withValues(alpha: 0.45),
          width: 0.9,
        ),
      ),
      child: Row(
        children: [
          // Left: Illustrated Footballer Avatar + Full App Title & User Subtitle
          GestureDetector(
            onTap: () => _onFooterTabTapped(2),
            child: PlayerAvatarWidget(
              avatarKey: user?.avatar ?? 'goat_10',
              size: 28,
              borderColor: AppColors.pitchGreen,
              borderWidth: 1.1,
            ),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: GestureDetector(
              onTap: () => _onFooterTabTapped(2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.2,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user?.username ?? 'Kaptan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.greenLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '• ${user?.favoriteTeam ?? "Galatasaray"}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 9.2,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          // Language Switcher Pill
          GestureDetector(
            onTap: () => showLanguageSelectorSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, size: 10.5, color: AppColors.greenLight),
                  const SizedBox(width: 2.5),
                  Text(
                    loc.currentLanguage.shortCode,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (AppConfig.enableAdsAndIapInStoreBuild) ...[
            const SizedBox(width: 4),
            // Ad-Free Single Purchase Badge
            GestureDetector(
              onTap: () => showAdFreePurchaseSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                decoration: BoxDecoration(
                  color: (user?.isAdFree ?? false)
                      ? AppColors.pitchGreen.withValues(alpha: 0.20)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: (user?.isAdFree ?? false)
                        ? AppColors.pitchGreen.withValues(alpha: 0.55)
                        : Colors.white.withValues(alpha: 0.22),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      (user?.isAdFree ?? false) ? Icons.verified_rounded : Icons.block_flipped,
                      size: 10.5,
                      color: (user?.isAdFree ?? false) ? AppColors.greenLight : AppColors.gold,
                    ),
                    const SizedBox(width: 2.5),
                    Text(
                      (user?.isAdFree ?? false) ? loc.t('pro_badge') : loc.t('ad_free_badge'),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: (user?.isAdFree ?? false) ? AppColors.greenLight : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(width: 4),
          // Right: Gold XP Badge
          GestureDetector(
            onTap: () => _onFooterTabTapped(1),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.45), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 11, color: AppColors.gold),
                  const SizedBox(width: 2),
                  Text(
                    '${user?.points ?? 0}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
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

  Widget _buildGamesSection(BuildContext context, LocaleProvider loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Vitrin: Futbolcu Kariyeri Hero Banner & Kadro Kur Lig Simülasyonu
        _buildSectionHeader(loc.t('career_section_title'), loc.t('career_section_sub')),
        const SizedBox(height: 5),
        _buildCareerHeroCard(context, loc),
        const SizedBox(height: 8),
        GameModeCard(
          title: loc.t('league_sim_title'),
          subtitle: loc.t('league_sim_sub'),
          icon: Icons.emoji_events_rounded,
          tag: loc.t('league_sim_tag'),
          tagColor: AppColors.gold,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeagueDraftScreen()),
            );
          },
        ),
        const SizedBox(height: 11),

        // 2. Bölüm: Trivia & Analiz Düelloları (2x2 Yan Yana Bento Grid)
        _buildSectionHeader(
          loc.t('duel_section_title'),
          loc.t('join_code_link'),
          onRightTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LobbyHubScreen()),
            );
          },
        ),
        const SizedBox(height: 5),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BentoGameModeCard(
                  title: loc.t('mode_321_title'),
                  subtitle: loc.t('mode_321_sub'),
                  icon: Icons.compare_arrows_rounded,
                  tag: loc.t('mode_321_tag'),
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
                  title: loc.t('mode_5clubs_title'),
                  subtitle: loc.t('mode_5clubs_sub'),
                  icon: Icons.shield_outlined,
                  tag: loc.t('mode_5clubs_tag'),
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
        const SizedBox(height: 9),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: BentoGameModeCard(
                  title: loc.t('mode_bridge_title'),
                  subtitle: loc.t('mode_bridge_sub'),
                  icon: Icons.hub_outlined,
                  tag: loc.t('mode_bridge_tag'),
                  tagColor: AppColors.gold,
                  onTap: () {
                    showGameModeSelectorSheet(
                      context,
                      targetGame: GameTargetType.footballBridge,
                    );
                  },
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: BentoGameModeCard(
                  title: loc.t('mode_auction_title'),
                  subtitle: loc.t('mode_auction_sub'),
                  icon: Icons.gavel_rounded,
                  tag: loc.t('mode_auction_tag'),
                  tagColor: const Color(0xFFF97316),
                  onTap: () {
                    showGameModeSelectorSheet(
                      context,
                      targetGame: GameTargetType.auctionDuel,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 11),

        // 3. Bölüm: Taktik Tahtası (Futbol Grid 3x3)
        _buildSectionHeader(loc.t('tactics_section_title'), loc.t('tactics_section_sub')),
        const SizedBox(height: 5),
        GameModeCard(
          title: loc.t('mode_grid_title'),
          subtitle: loc.t('mode_grid_sub'),
          icon: Icons.grid_3x3_outlined,
          tag: loc.t('mode_grid_tag'),
          tagColor: AppColors.gold,
          trailingPreview: _buildMiniTacticalGridPreview(),
          onTap: () {
            showGameModeSelectorSheet(
              context,
              targetGame: GameTargetType.footballGrid,
            );
          },
        ),
        const AdBannerWidget(),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title,
    String rightSubtitle, {
    VoidCallback? onRightTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
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
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: AppColors.greenLight,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onRightTap,
          child: Text(
            rightSubtitle,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: onRightTap != null ? FontWeight.w800 : FontWeight.w600,
              color: onRightTap != null
                  ? AppColors.gold
                  : AppColors.textMuted.withValues(alpha: 0.9),
            ),
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

  Widget _buildCareerHeroCard(BuildContext context, LocaleProvider loc) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF12402A).withValues(alpha: 0.78),
            const Color(0xFF0A2619).withValues(alpha: 0.80),
            const Color(0xFF06160F).withValues(alpha: 0.84),
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star_rounded, size: 10, color: AppColors.gold),
                                    const SizedBox(width: 3),
                                    Text(
                                      loc.t('career_new_tag'),
                                      style: const TextStyle(
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      loc.t('start_btn'),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.greenLight,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Icon(
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
                          Text(
                            loc.t('career_card_title'),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loc.t('career_card_sub'),
                            style: const TextStyle(
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
                    _buildHeroBadge(Icons.hourglass_top_outlined, loc.t('career_badge_1')),
                    _buildHeroBadge(Icons.sports_soccer_rounded, loc.t('career_badge_2')),
                    _buildHeroBadge(Icons.swap_horiz_rounded, loc.t('career_badge_3')),
                    _buildHeroBadge(Icons.workspace_premium_outlined, loc.t('career_badge_4')),
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
