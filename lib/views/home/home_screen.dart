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
  bool _isAnimatingToTab = false;

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

  Future<void> _onFooterTabTapped(int index) async {
    if (_activeTab == index && !_isAnimatingToTab) return;
    setState(() => _activeTab = index);
    _isAnimatingToTab = true;
    try {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeOutCubic,
      );
    } finally {
      if (mounted) {
        _isAnimatingToTab = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = context.watch<LocaleProvider>();
    final user = auth.currentUser;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final footerBottom =
        bottomInset > 0 ? (bottomInset * 0.56).clamp(10.0, 22.0) : 12.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StadiumBackground(
        showFieldLines: true,
        showLiveMatch: _activeTab == 0,
        safeBottom: false,
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
                        if (!_isAnimatingToTab && _activeTab != index) {
                          setState(() => _activeTab = index);
                        }
                      },
                      children: [
                        // Page 0: Oyunlar (Games Hub)
                        SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            14,
                            2,
                            14,
                            footerBottom + 86,
                          ),
                          child: _buildGamesSection(context, loc),
                        ),

                        // Page 1: Lobi Kur & Davet Et (Online Lobby Hub)
                        SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            14,
                            2,
                            14,
                            footerBottom + 86,
                          ),
                          child: const LobbyHubScreen(isEmbedded: true),
                        ),

                        // Page 2: Profil (Profile & Settings)
                        SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            14,
                            2,
                            14,
                            footerBottom + 86,
                          ),
                          child: const ProfileScreen(isEmbedded: true),
                        ),
                      ],
                    ),
                  ),

                  // Floating Smoked Glass Footer
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: footerBottom,
                    child: AppFloatingGlassFooter(
                      activeIndex: _activeTab,
                      onTabSelected: _onFooterTabTapped,
                      pageController: _pageController,
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
      loc.t('header_lobby'),
      loc.t('header_profile'),
    ];
    final currentTitle = tabTitles[_activeTab.clamp(0, tabTitles.length - 1)];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF103123).withValues(alpha: 0.92),
            const Color(0xFF071912).withValues(alpha: 0.94),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Illustrated Footballer Avatar + Full App Title & User Subtitle
          GestureDetector(
            onTap: () => _onFooterTabTapped(2),
            child: PlayerAvatarWidget(
              avatarKey: user?.avatar ?? 'goat_10',
              size: 32,
              borderColor: AppColors.pitchGreen,
              borderWidth: 1.2,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: GestureDetector(
              onTap: () => _onFooterTabTapped(2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    ),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                    child: Text(
                      currentTitle,
                      key: ValueKey(currentTitle),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.25,
                        height: 1.12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          user?.username ?? 'Kaptan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
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
                          fontSize: 10.2,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Language Switcher Pill
          GestureDetector(
            onTap: () => showLanguageSelectorSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language_rounded, size: 12, color: AppColors.greenLight),
                  const SizedBox(width: 3),
                  Text(
                    loc.currentLanguage.shortCode,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (AppConfig.enableAdsAndIapInStoreBuild) ...[
            const SizedBox(width: 5),
            // Ad-Free Single Purchase Badge
            GestureDetector(
              onTap: () => showAdFreePurchaseSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: (user?.isAdFree ?? false)
                      ? AppColors.pitchGreen.withValues(alpha: 0.20)
                      : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9),
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
                      size: 11.5,
                      color: (user?.isAdFree ?? false) ? AppColors.greenLight : AppColors.gold,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      (user?.isAdFree ?? false) ? loc.t('pro_badge') : loc.t('ad_free_badge'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: (user?.isAdFree ?? false) ? AppColors.greenLight : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(width: 5),
          // Right: Gold XP Badge
          GestureDetector(
            onTap: () => _onFooterTabTapped(2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.22),
                    AppColors.goldMuted.withValues(alpha: 0.14),
                  ],
                ),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.50), width: 0.9),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 12.5, color: AppColors.goldLight),
                  const SizedBox(width: 3),
                  Text(
                    '${user?.points ?? 0}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.goldLight,
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
        const SizedBox(height: 8),
        _buildCareerHeroCard(context, loc),
        const SizedBox(height: 10),
        GameModeCard(
          title: loc.t('league_sim_title'),
          subtitle: loc.t('league_sim_sub'),
          icon: Icons.emoji_events_rounded,
          tag: loc.t('league_sim_tag'),
          tagColor: AppColors.gold,
          trailingPreview: _buildMiniFormationPreview(),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeagueDraftScreen()),
            );
          },
        ),
        const SizedBox(height: 12),

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
        const SizedBox(height: 8),
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
              const SizedBox(width: 10),
              Expanded(
                child: BentoGameModeCard(
                  title: loc.t('mode_5clubs_title'),
                  subtitle: loc.t('mode_5clubs_sub'),
                  icon: Icons.shield_outlined,
                  tag: loc.t('mode_5clubs_tag'),
                  tagColor: AppColors.info,
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
        const SizedBox(height: 10),
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
              const SizedBox(width: 10),
              Expanded(
                child: BentoGameModeCard(
                  title: loc.t('mode_auction_title'),
                  subtitle: loc.t('mode_auction_sub'),
                  icon: Icons.gavel_rounded,
                  tag: loc.t('mode_auction_tag'),
                  tagColor: const Color(0xFFFB923C),
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
        const SizedBox(height: 14),

        // 3. Bölüm: Taktik Tahtası (Futbol Grid 3x3)
        _buildSectionHeader(loc.t('tactics_section_title'), loc.t('tactics_section_sub')),
        const SizedBox(height: 8),
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
                width: 3.5,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.greenLight, AppColors.gold],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onRightTap,
          child: Container(
            padding: onRightTap != null
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
                : EdgeInsets.zero,
            decoration: onRightTap != null
                ? BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.35),
                      width: 0.8,
                    ),
                  )
                : null,
            child: Text(
              rightSubtitle,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: onRightTap != null ? FontWeight.w800 : FontWeight.w600,
                color: onRightTap != null
                    ? AppColors.goldLight
                    : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniFormationPreview() {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF14532D).withValues(alpha: 0.65),
            const Color(0xFF052E16).withValues(alpha: 0.80),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.45),
          width: 0.9,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (_) => _miniPitchDot(AppColors.goldLight)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (_) => _miniPitchDot(AppColors.greenLight)),
          ),
          Center(child: _miniPitchDot(Colors.white)),
        ],
      ),
    );
  }

  Widget _miniPitchDot(Color color) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.55), blurRadius: 3),
        ],
      ),
    );
  }

  Widget _buildMiniTacticalGridPreview() {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(4.5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.45), width: 0.9),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2.5,
          mainAxisSpacing: 2.5,
        ),
        itemBuilder: (_, index) {
          final isHighlighted = index == 0 || index == 4 || index == 8;
          return Container(
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.gold.withValues(alpha: 0.82)
                  : AppColors.pitchGreen.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCareerHeroCard(BuildContext context, LocaleProvider loc) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF144830),
            Color(0xFF0A281A),
            Color(0xFF05130D),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.pitchGreen.withValues(alpha: 0.65),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.pitchGreen.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CareerSetupScreen()),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // Top-right golden spotlight accent & trophy watermark
                Positioned(
                  top: -28,
                  right: -28,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.gold.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -10,
                  bottom: -18,
                  child: Transform.rotate(
                    angle: -0.18,
                    child: Icon(
                      Icons.workspace_premium_outlined,
                      size: 92,
                      color: AppColors.gold.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Spotlight Pitch Crest Badge
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF19A55A),
                                  Color(0xFF084C27),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(color: AppColors.greenLight, width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.pitchGreen.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.sports_soccer,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: AppColors.gold.withValues(alpha: 0.75),
                                            width: 0.8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star_rounded,
                                              size: 11, color: AppColors.goldLight),
                                          const SizedBox(width: 3),
                                          Text(
                                            loc.t('career_new_tag'),
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.goldLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.pitchGreen,
                                            AppColors.emerald,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.pitchGreen.withValues(alpha: 0.35),
                                            blurRadius: 6,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            loc.t('start_btn'),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          const Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  loc.t('career_card_title'),
                                  style: const TextStyle(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  loc.t('career_card_sub'),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      // Feature Badges
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _buildHeroBadge(
                              Icons.hourglass_top_outlined, loc.t('career_badge_1')),
                          _buildHeroBadge(
                              Icons.sports_soccer_rounded, loc.t('career_badge_2')),
                          _buildHeroBadge(
                              Icons.swap_horiz_rounded, loc.t('career_badge_3')),
                          _buildHeroBadge(
                              Icons.workspace_premium_outlined, loc.t('career_badge_4')),
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
    );
  }

  Widget _buildHeroBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.greenLight),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
