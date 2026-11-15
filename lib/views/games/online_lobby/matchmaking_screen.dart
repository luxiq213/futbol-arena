import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/grid_challenge_model.dart';
import '../../../../data/models/play_mode_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stadium_background.dart';
import '../auction_duel/auction_duel_screen.dart';
import '../common_player/common_player_screen.dart';
import '../five_clubs/five_clubs_screen.dart';
import '../football_bridge/football_bridge_screen.dart';
import '../football_grid/football_grid_screen.dart';

class MatchmakingScreen extends StatefulWidget {
  final GameTargetType targetGame;
  final GameDifficulty difficulty;
  final CommonPlayerPairMode commonPlayerPairFormat;
  final GridThemeType gridTheme;

  const MatchmakingScreen({
    super.key,
    required this.targetGame,
    this.difficulty = GameDifficulty.medium,
    this.commonPlayerPairFormat = CommonPlayerPairMode.clubVsClub,
    this.gridTheme = GridThemeType.mixed,
  });

  @override
  State<MatchmakingScreen> createState() => _MatchmakingScreenState();
}

enum _MatchPhase { searchingOnline, fallbackAiNotice, matched }

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  _MatchPhase _phase = _MatchPhase.searchingOnline;
  OpponentProfile? _matchedOpponent;
  Timer? _phaseTimer1;
  Timer? _phaseTimer2;
  Timer? _launchTimer;

  @override
  void initState() {
    super.initState();
    _startSearchSequence();
  }

  void _startSearchSequence() {
    // After 2.0 seconds of searching online queue, notify fallback to AI opponent
    _phaseTimer1 = Timer(const Duration(milliseconds: 2000), () {
      if (!mounted || _phase == _MatchPhase.matched) return;
      setState(() {
        _phase = _MatchPhase.fallbackAiNotice;
      });
    });

    // After 3.0 seconds, lock in the AI rival and transition to game
    _phaseTimer2 = Timer(const Duration(milliseconds: 3000), () {
      if (!mounted || _phase == _MatchPhase.matched) return;
      _lockInAiOpponentAndStart();
    });
  }

  void _lockInAiOpponentAndStart() {
    _phaseTimer1?.cancel();
    _phaseTimer2?.cancel();
    final rival = OpponentProfile.randomAiRival(difficulty: widget.difficulty);
    setState(() {
      _matchedOpponent = rival;
      _phase = _MatchPhase.matched;
    });

    _launchTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      _navigateToTargetGame(rival);
    });
  }

  void _navigateToTargetGame(OpponentProfile opponent) {
    Widget destination;
    switch (widget.targetGame) {
      case GameTargetType.commonPlayer:
        destination = CommonPlayerScreen(
          playMode: PlayModeType.onlineMatchmaking,
          difficulty: widget.difficulty,
          opponent: opponent,
          initialPairFormat: widget.commonPlayerPairFormat,
        );
        break;
      case GameTargetType.fiveClubs:
        destination = FiveClubsScreen(
          playMode: PlayModeType.onlineMatchmaking,
          difficulty: widget.difficulty,
          opponent: opponent,
        );
        break;
      case GameTargetType.footballGrid:
        destination = FootballGridScreen(
          playMode: PlayModeType.onlineMatchmaking,
          difficulty: widget.difficulty,
          opponent: opponent,
          initialTheme: widget.gridTheme,
        );
        break;
      case GameTargetType.footballBridge:
        destination = FootballBridgeScreen(
          playMode: PlayModeType.onlineMatchmaking,
          difficulty: widget.difficulty,
          opponent: opponent,
        );
        break;
      case GameTargetType.auctionDuel:
        destination = AuctionDuelScreen(
          playMode: PlayModeType.onlineMatchmaking,
          difficulty: widget.difficulty,
          opponent: opponent,
        );
        break;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  void dispose() {
    _phaseTimer1?.cancel();
    _phaseTimer2?.cancel();
    _launchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    String statusHeadline;
    String statusSubtext;
    Color statusColor;

    switch (_phase) {
      case _MatchPhase.searchingOnline:
        statusHeadline = 'ONLİNE OYUNCU ARANIYOR...';
        statusSubtext = 'Puanına uygun aktif online rakipler taranıyor.';
        statusColor = AppColors.greenLight;
        break;
      case _MatchPhase.fallbackAiNotice:
        statusHeadline = 'YAPAY ZEKA RAKİP EŞLEŞTİRİLİYOR...';
        statusSubtext = 'Aktif online oyuncu bulunamadı, denk seviyede Yapay Zeka rakip atanıyor.';
        statusColor = AppColors.gold;
        break;
      case _MatchPhase.matched:
        statusHeadline = 'RAKİP BULUNDU! MAÇ BAŞLIYOR...';
        statusSubtext = '${_matchedOpponent?.name ?? "Rakip"} ile düello başlıyor.';
        statusColor = AppColors.gold;
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 46,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${widget.targetGame.title} • Eşleşme',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
        ),
      ),
      body: StadiumBackground(
        showFieldLines: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Target Game Pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.pitchGreen),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sports_soccer, size: 15, color: AppColors.greenLight),
                      const SizedBox(width: 6),
                      Text(
                        widget.targetGame.title.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Head-to-Head Matchup Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _phase == _MatchPhase.matched ? AppColors.gold : AppColors.borderGreen,
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.pitchGreen.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // User Side
                        Expanded(
                          child: _buildParticipantColumn(
                            avatar: user?.avatar ?? 'KP',
                            name: user?.username ?? 'Kaptan',
                            team: user?.favoriteTeam ?? 'Galatasaray',
                            badge: 'SEN',
                            badgeColor: AppColors.pitchGreen,
                            isLocked: true,
                          ),
                        ),

                        // Center VS / Radar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.surfaceLight,
                                  border: Border.all(color: statusColor, width: 1.5),
                                ),
                                child: Center(
                                  child: _phase == _MatchPhase.matched
                                      ? const Text(
                                          'VS',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.gold,
                                          ),
                                        )
                                      : SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            color: statusColor,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Opponent Side
                        Expanded(
                          child: _matchedOpponent != null
                              ? _buildParticipantColumn(
                                  avatar: _matchedOpponent!.avatar,
                                  name: _matchedOpponent!.name,
                                  team: _matchedOpponent!.favoriteTeam,
                                  badge: 'YAPAY ZEKA RAKİP',
                                  badgeColor: AppColors.gold,
                                  isLocked: true,
                                )
                              : _buildSearchingOpponentColumn(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Status Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: statusColor.withValues(alpha: 0.45)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            statusHeadline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusSubtext,
                            textAlign: TextAlign.center,
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
              ),

              const Spacer(),

              if (_phase != _MatchPhase.matched) ...[
                CustomButton(
                  text: 'Beklemeden Yapay Zeka İle Başlat',
                  icon: Icons.smart_toy_outlined,
                  backgroundColor: AppColors.pitchGreen,
                  textColor: Colors.white,
                  onPressed: _lockInAiOpponentAndStart,
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'İptal Et',
                  isOutlined: true,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantColumn({
    required String avatar,
    required String name,
    required String team,
    required String badge,
    required Color badgeColor,
    required bool isLocked,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.darkGreen,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: badgeColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              avatar,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: badgeColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: badgeColor.withValues(alpha: 0.5), width: 0.8),
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
        const SizedBox(height: 5),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          team,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchingOpponentColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: const Center(
            child: Icon(
              Icons.person_search_outlined,
              size: 26,
              color: AppColors.gold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'EŞLEŞME',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Rakip Aranıyor...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const Text(
          'Online / AI',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
