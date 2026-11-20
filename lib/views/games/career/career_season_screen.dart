import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/career_model.dart';
import '../../../../data/models/club_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/career_game_provider.dart';
import '../../widgets/app_notification.dart';
import '../../widgets/club_crest_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stadium_background.dart';
import 'career_summary_screen.dart';

class CareerSeasonScreen extends StatefulWidget {
  const CareerSeasonScreen({super.key});

  @override
  State<CareerSeasonScreen> createState() => _CareerSeasonScreenState();
}

class _CareerSeasonScreenState extends State<CareerSeasonScreen> {
  bool _isProcessing = false;
  bool _showingFullScreenPenalty = false;
  bool _showingOriginStoryIntro = true;

  void _onSelectClub(ClubModel? chosenClub) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final provider = context.read<CareerGameProvider>();
    final auth = context.read<AuthProvider>();
    final nav = Navigator.of(context);
    final isStay = chosenClub == null || chosenClub.id == provider.currentClub?.id;
    final clubName = isStay ? (provider.currentClub?.name ?? 'Kulübünde') : chosenClub.name;

    AppNotification.show(
      context,
      title: isStay
          ? '$clubName İle Sözleşme Uzatıldı'
          : '$clubName İle Resmi Sözleşme İmzalandı!',
      subtitle: isStay
          ? 'Taraftarın sadakatinle gurur duyuyor, yeni sezon başlıyor.'
          : 'Yeni formayla sahaya çıkıyorsun, başarılar Kaptan!',
      type: isStay ? AppNotificationType.success : AppNotificationType.gold,
      icon: isStay ? Icons.verified_outlined : Icons.swap_horiz_rounded,
      duration: const Duration(milliseconds: 1400),
    );

    await Future.delayed(const Duration(milliseconds: 360));

    if (!mounted) return;

    provider.selectTransferDecision(chosenClub);

    if (provider.isCareerFinished) {
      setState(() => _isProcessing = false);
      final summary = provider.finalSummary;
      if (summary != null) {
        auth.addPoints(
          summary.careerRating,
          won: summary.allTrophies.isNotEmpty,
        );
      }
      nav.pushReplacement(
        MaterialPageRoute(builder: (_) => const CareerSummaryScreen()),
      );
      return;
    }

    setState(() {
      _isProcessing = false;
      // If the random chance triggered a penalty after signing this transfer, open Full-Screen Penalty!
      if (provider.hasPendingPenalty) {
        _showingFullScreenPenalty = true;
      }
    });
  }

  void _confirmEarlyRetire(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Jübile Yapmak İstiyor musun?',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Kariyerini şu anki yaşında sonlandırıp gizli tutulan tüm gol, asist ve kupa istatistiklerini açmak istiyor musun?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Devam Et', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pitchGreen,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final provider = context.read<CareerGameProvider>();
              final auth = context.read<AuthProvider>();
              while (!provider.isCareerFinished) {
                provider.selectTransferDecision(provider.currentClub, forcePenalty: false);
              }
              final summary = provider.finalSummary;
              if (summary != null) {
                auth.addPoints(
                  summary.careerRating,
                  won: summary.allTrophies.isNotEmpty,
                );
              }
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CareerSummaryScreen()),
              );
            },
            child: const Text('Jübile Yap', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CareerGameProvider>();
    final currentClub = provider.currentClub;
    final offers = provider.currentOffers;
    final lastHighlight = provider.highlightsHistory.isNotEmpty ? provider.highlightsHistory.last : null;

    if (currentClub == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.pitchGreen)),
      );
    }

    // Full-Screen Origin Story Reveal when a new career kicks off at age 17
    final originStory = provider.originStory;
    if (_showingOriginStoryIntro &&
        provider.currentStageIndex == 0 &&
        originStory != null) {
      return _buildOriginStoryRevealScreen(provider, originStory, currentClub);
    }

    // Full-Screen Animated 3D Penalty Shootout (triggered randomly after signing a transfer)
    if (_showingFullScreenPenalty && provider.hasPendingPenalty) {
      return _FullScreenPenaltyShootoutView(
        provider: provider,
        currentClub: currentClub,
        onCompleted: () {
          if (mounted) {
            setState(() {
              _showingFullScreenPenalty = false;
            });
          }
        },
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '${provider.playerName} • ${provider.position.shortCode}',
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _confirmEarlyRetire(context),
            icon: const Icon(Icons.flag_outlined, size: 15, color: AppColors.gold),
            label: const Text(
              'Jübile',
              style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: StadiumBackground(
        showFieldLines: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Unified Compact Career & Current Club Top HUD Bar
              _buildUnifiedTopHud(provider, currentClub),

              const SizedBox(height: 6),

              // 2. Slim 1-Line Mystery Season Strip (Stats remain secret until Jubilee)
              _buildMysterySeasonDiaryCard(provider, lastHighlight),

              const SizedBox(height: 10),

              // 3. Transfer Window Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3.5,
                        height: 13,
                        decoration: BoxDecoration(
                          color: AppColors.pitchGreen,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'TRANSFER MASASI • TEKLİFLER',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'İmza sonrası sürpriz penaltı şansı',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Offer 1 Card
              if (offers.isNotEmpty)
                _buildOfferCard(
                  provider: provider,
                  club: offers[0],
                  label: '1. Transfer Teklifi',
                  isStayOption: false,
                ),

              const SizedBox(height: 9),

              // Offer 2 Card
              if (offers.length > 1)
                _buildOfferCard(
                  provider: provider,
                  club: offers[1],
                  label: '2. Transfer Teklifi',
                  isStayOption: false,
                ),

              const SizedBox(height: 9),

              // Stay Option Card
              _buildOfferCard(
                provider: provider,
                club: currentClub,
                label: 'Sadakat & Sözleşme Uzatma',
                isStayOption: true,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOriginStoryRevealScreen(
    CareerGameProvider provider,
    CareerOriginStory story,
    ClubModel startingClub,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${provider.playerName} • ${provider.position.shortCode}'),
      ),
      body: StadiumBackground(
        showFieldLines: true,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface.withValues(alpha: 0.96),
                    AppColors.darkGreen.withValues(alpha: 0.72),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.55),
                  width: 1.3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.55),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.gold,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            story.badgeTag,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                              letterSpacing: 0.9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    story.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Başlangıç Ligi: ${story.originCountry} • ${story.originLeague}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.greenLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.30),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClubCrestWidget(club: startingClub, size: 48),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'İLK PROFESYONEL KULÜBÜN',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMuted,
                                  letterSpacing: 0.7,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                startingClub.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '17 Yaş • ${provider.position.label}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    story.introStory,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.2,
                      height: 1.48,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  CustomButton(
                    text: 'Sahaya Çık & İlk Sezona Başla',
                    icon: Icons.sports_soccer,
                    height: 50,
                    onPressed: () {
                      setState(() => _showingOriginStoryIntro = false);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnifiedTopHud(CareerGameProvider provider, ClubModel club) {
    final stageProgress = (provider.currentStageIndex + 1) / provider.maxStages;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withValues(alpha: 0.94),
            AppColors.darkGreen.withValues(alpha: 0.55),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClubCrestWidget(club: club, size: 32),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.pitchGreen.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.pitchGreen, width: 0.7),
                          ),
                          child: Text(
                            '${provider.currentAge} YAŞ • ${provider.currentStageIndex + 1}/${provider.maxStages}',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.greenLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            club.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1.5),
                    Text(
                      '${club.country} • ${club.league} • ${provider.currentStageTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9.8,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '??? GOL • ??? AST',
                      style: TextStyle(
                        fontSize: 9.2,
                        fontWeight: FontWeight.w900,
                        color: AppColors.greenLight,
                      ),
                    ),
                    Text(
                      '??? KUPA (Gizli)',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: stageProgress.clamp(0.0, 1.0),
              minHeight: 3,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.pitchGreen),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMysterySeasonDiaryCard(CareerGameProvider provider, String? highlight) {
    final lastRes = provider.lastPenaltyResult;
    final statusText = lastRes != null
        ? lastRes.commentary
        : (highlight != null && highlight.isNotEmpty
            ? highlight
            : 'Sezon gol, asist ve kupa kayıtların gizli tutuluyor (Jübilede açılır)');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: lastRes != null
              ? (lastRes.isGoal ? AppColors.pitchGreen : AppColors.error).withValues(alpha: 0.5)
              : AppColors.borderGreen.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            lastRes != null
                ? (lastRes.isGoal ? Icons.sports_soccer : Icons.info_outline)
                : Icons.visibility_off_outlined,
            size: 13,
            color: lastRes != null
                ? (lastRes.isGoal ? AppColors.greenLight : Colors.redAccent)
                : AppColors.gold,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: lastRes != null
                    ? (lastRes.isGoal ? AppColors.greenLight : Colors.redAccent)
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${provider.careerClubsHistory.length} Kulüp',
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard({
    required CareerGameProvider provider,
    required ClubModel club,
    required String label,
    required bool isStayOption,
  }) {
    final rolePromise = provider.getOfferRoleDescription(club, isStay: isStayOption);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isStayOption ? AppColors.silver.withValues(alpha: 0.4) : AppColors.pitchGreen.withValues(alpha: 0.55),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          ClubCrestWidget(club: club, size: 46),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isStayOption
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.pitchGreen.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: isStayOption ? AppColors.silver : AppColors.greenLight,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  club.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${club.country} • ${club.league}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rolePromise,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isStayOption ? AppColors.gold : AppColors.greenLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 96,
            child: CustomButton(
              text: isStayOption ? 'Takımda Kal' : 'İmzala',
              isOutlined: isStayOption,
              height: 38,
              onPressed: () => _onSelectClub(isStayOption ? null : club),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// FULL-SCREEN 3D INTERACTIVE PENALTY SHOOTOUT VIEW (SWIPE OR TAP REAL BALL SHOT)
// =============================================================================
class _FullScreenPenaltyShootoutView extends StatefulWidget {
  final CareerGameProvider provider;
  final ClubModel currentClub;
  final VoidCallback onCompleted;

  const _FullScreenPenaltyShootoutView({
    required this.provider,
    required this.currentClub,
    required this.onCompleted,
  });

  @override
  State<_FullScreenPenaltyShootoutView> createState() => _FullScreenPenaltyShootoutViewState();
}

class _FullScreenPenaltyShootoutViewState extends State<_FullScreenPenaltyShootoutView>
    with TickerProviderStateMixin {
  late final AnimationController _idleController;
  late final AnimationController _shotController;

  PenaltyCorner? _selectedCorner;
  PenaltyShotResult? _shotResult;
  bool _isShooting = false;
  bool _shotFinished = false;
  bool _showImpactFlashBanner = false;
  Timer? _flashBannerTimer;

  // Drag/flick gesture tracking from ball
  Offset? _dragStart;
  Offset? _dragCurrent;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _shotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 780),
    );
  }

  @override
  void dispose() {
    _flashBannerTimer?.cancel();
    _idleController.dispose();
    _shotController.dispose();
    super.dispose();
  }

  void _firePenaltyShot(PenaltyCorner corner) async {
    if (_isShooting || _shotFinished) return;

    final result = widget.provider.takeSeasonPenalty(corner);

    setState(() {
      _selectedCorner = corner;
      _shotResult = result;
      _isShooting = true;
      _dragStart = null;
      _dragCurrent = null;
    });

    await _shotController.forward(from: 0.0);
    if (!mounted) return;

    if (result.isGoal) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.heavyImpact();
    }

    setState(() {
      _shotFinished = true;
      _showImpactFlashBanner = true;
    });

    _flashBannerTimer?.cancel();
    _flashBannerTimer = Timer(const Duration(milliseconds: 1150), () {
      if (mounted) {
        setState(() => _showImpactFlashBanner = false);
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_isShooting || _shotFinished) return;
    setState(() {
      _dragStart = details.localPosition;
      _dragCurrent = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isShooting || _shotFinished || _dragStart == null) return;
    setState(() {
      _dragCurrent = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isShooting || _shotFinished || _dragStart == null || _dragCurrent == null) return;
    final delta = _dragCurrent! - _dragStart!;
    // Require upward swipe/flick toward the goal
    if (delta.dy > -30 && details.velocity.pixelsPerSecond.dy > -180) {
      setState(() {
        _dragStart = null;
        _dragCurrent = null;
      });
      return;
    }

    final dx = delta.dx;
    final dy = delta.dy;
    PenaltyCorner corner;
    if (dx < -45) {
      corner = dy < -125 ? PenaltyCorner.topLeft : PenaltyCorner.bottomLeft;
    } else if (dx > 45) {
      corner = dy < -125 ? PenaltyCorner.topRight : PenaltyCorner.bottomRight;
    } else {
      corner = PenaltyCorner.center;
    }
    _firePenaltyShot(corner);
  }

  @override
  Widget build(BuildContext context) {
    final isGk = widget.provider.position == PlayerPosition.goalkeeper;

    return Scaffold(
      backgroundColor: const Color(0xFF04120C),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full-Screen 3D Stadium Goal, Goalkeeper, and Flying Football Canvas
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: AnimatedBuilder(
                animation: Listenable.merge([_idleController, _shotController]),
                builder: (context, _) {
                  return CustomPaint(
                    painter: _Penalty3DArenaPainter(
                      idleProgress: _idleController.value,
                      shotProgress: _shotController.value,
                      isShooting: _isShooting,
                      targetCorner: _selectedCorner,
                      keeperCorner: _shotResult?.keeperCorner,
                      isGoal: _shotResult?.isGoal ?? false,
                      clubPrimaryColor: widget.currentClub.primaryColor,
                      dragStart: _dragStart,
                      dragCurrent: _dragCurrent,
                    ),
                  );
                },
              ),
            ),

            // 2. Top Broadcast Scoreboard HUD
            Positioned(
              top: 10,
              left: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xEB061811),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.65), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClubCrestWidget(club: widget.currentClub, size: 36),
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
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  isGk ? '90+3\' KRİTİK KURTARIŞ ANI' : '90+3\' KRİTİK PENALTI ATIŞI',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.gold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.provider.currentAge} Yaş',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.greenLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${widget.currentClub.name} • Kupa & Şampiyonluk Virajı',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Interactive Goal Target Zones (Tap directly on a corner inside the goal!)
            if (!_isShooting)
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    final goalLeft = w * 0.12;
                    final goalRight = w * 0.88;
                    final goalTop = h * 0.21;
                    final goalBottom = h * 0.46;
                    final goalW = goalRight - goalLeft;
                    final goalH = goalBottom - goalTop;

                    return Stack(
                      children: [
                        // Top-Left 90
                        Positioned(
                          left: goalLeft + 8,
                          top: goalTop + 8,
                          child: _buildGoalTargetCrosshair(
                            corner: PenaltyCorner.topLeft,
                            label: 'Sol 90',
                            isUpper90: true,
                          ),
                        ),
                        // Top-Right 90
                        Positioned(
                          right: (w - goalRight) + 8,
                          top: goalTop + 8,
                          child: _buildGoalTargetCrosshair(
                            corner: PenaltyCorner.topRight,
                            label: 'Sağ 90',
                            isUpper90: true,
                          ),
                        ),
                        // Center / Panenka
                        Positioned(
                          left: goalLeft + goalW * 0.5 - 42,
                          top: goalTop + goalH * 0.45,
                          child: _buildGoalTargetCrosshair(
                            corner: PenaltyCorner.center,
                            label: 'Panenka',
                            isUpper90: false,
                          ),
                        ),
                        // Bottom-Left
                        Positioned(
                          left: goalLeft + 8,
                          top: goalBottom - 44,
                          child: _buildGoalTargetCrosshair(
                            corner: PenaltyCorner.bottomLeft,
                            label: 'Sol Köşe',
                            isUpper90: false,
                          ),
                        ),
                        // Bottom-Right
                        Positioned(
                          right: (w - goalRight) + 8,
                          top: goalBottom - 44,
                          child: _buildGoalTargetCrosshair(
                            corner: PenaltyCorner.bottomRight,
                            label: 'Sağ Köşe',
                            isUpper90: false,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // 4. Center Fast Impact Banner (GOOOOL! / KURTARDI!) sweeping across screen on shot arrival
            Positioned(
              left: 20,
              right: 20,
              top: 150,
              child: IgnorePointer(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: Tween<double>(begin: 0.65, end: 1.0).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: (_showImpactFlashBanner && _shotResult != null)
                      ? Container(
                          key: const ValueKey('penalty_flash_banner'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _shotResult!.isGoal
                                  ? [
                                      AppColors.pitchGreen.withValues(alpha: 0.94),
                                      const Color(0xFF0A3822).withValues(alpha: 0.96),
                                    ]
                                  : [
                                      AppColors.error.withValues(alpha: 0.94),
                                      const Color(0xFF4C0D12).withValues(alpha: 0.96),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _shotResult!.isGoal
                                  ? AppColors.gold
                                  : Colors.white.withValues(alpha: 0.75),
                              width: 2.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_shotResult!.isGoal
                                        ? AppColors.gold
                                        : AppColors.error)
                                    .withValues(alpha: 0.55),
                                blurRadius: 24,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _shotResult!.isGoal
                                    ? (isGk ? 'EFSANE KURTARIŞ!' : 'GOOOOL!')
                                    : (isGk ? 'GOL YEDİN!' : 'KURTARILDI!'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.6,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Köşe: ${_shotResult!.playerCorner.label} • Kaleci: ${_shotResult!.keeperCorner.label}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            // 5. Bottom Instruction / Power Meter OR Shot Result Celebration Card
            Positioned(
              left: 16,
              right: 16,
              bottom: 18,
              child: _shotFinished && _shotResult != null
                  ? _buildResultOverlayCard(_shotResult!, isGk)
                  : _buildAimingInstructionBar(isGk),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalTargetCrosshair({
    required PenaltyCorner corner,
    required String label,
    required bool isUpper90,
  }) {
    return GestureDetector(
      onTap: () => _firePenaltyShot(corner),
      child: AnimatedBuilder(
        animation: _idleController,
        builder: (context, _) {
          final scale = 0.95 + 0.08 * _idleController.value;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 84,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: (isUpper90 ? AppColors.gold : AppColors.pitchGreen).withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isUpper90 ? AppColors.gold : AppColors.greenLight,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUpper90 ? AppColors.gold : AppColors.pitchGreen).withValues(alpha: 0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.gps_fixed_rounded,
                    size: 13,
                    color: isUpper90 ? AppColors.gold : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAimingInstructionBar(bool isGk) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xE6061811),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app_rounded, size: 16, color: AppColors.gold),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isGk
                        ? 'Atlamak istediğin köşeye dokun veya topu o yöne kaydır!'
                        : 'Topu parmağınla kaleye doğru fırlat veya kaledeki hedefe dokun!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Animated Shot Power Bar
            AnimatedBuilder(
              animation: _idleController,
              builder: (context, _) {
                final power = 0.45 + 0.55 * _idleController.value;
                return Row(
                  children: [
                    const Text(
                      'ŞUT GÜCÜ',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.gold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: power,
                          minHeight: 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            power > 0.82 ? AppColors.gold : AppColors.pitchGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '%${(power * 100).round()}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultOverlayCard(PenaltyShotResult result, bool isGk) {
    final isGoal = result.isGoal;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGoal
              ? [const Color(0xFF0F3B27), const Color(0xFF071B12)]
              : [const Color(0xFF3B1216), const Color(0xFF1A080A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGoal ? AppColors.gold : Colors.redAccent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.55),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isGoal ? AppColors.gold : Colors.redAccent).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isGoal ? Icons.sports_soccer : Icons.sports_handball,
                  color: isGoal ? AppColors.gold : Colors.redAccent,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGoal
                          ? (isGk ? 'EFSANE KURTARIŞ!' : 'GOOOL! AĞLARI SARSTIN!')
                          : (isGk ? 'PENALTI GOL OLDU' : 'KALECİ KURTARDI!'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isGoal ? AppColors.gold : Colors.redAccent,
                      ),
                    ),
                    Text(
                      'Köşen: ${result.playerCorner.label} • Kaleci: ${result.keeperCorner.label}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.commentary,
            style: const TextStyle(
              fontSize: 11.5,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Kariyere Devam Et ›',
            icon: Icons.arrow_forward_rounded,
            backgroundColor: isGoal ? AppColors.pitchGreen : AppColors.surfaceLight,
            onPressed: widget.onCompleted,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// 3D PERSPECTIVE PENALTY STADIUM, GOAL, GOALKEEPER & FLYING BALL PAINTER
// =============================================================================
class _Penalty3DArenaPainter extends CustomPainter {
  final double idleProgress;
  final double shotProgress;
  final bool isShooting;
  final PenaltyCorner? targetCorner;
  final PenaltyCorner? keeperCorner;
  final bool isGoal;
  final Color clubPrimaryColor;
  final Offset? dragStart;
  final Offset? dragCurrent;

  _Penalty3DArenaPainter({
    required this.idleProgress,
    required this.shotProgress,
    required this.isShooting,
    required this.targetCorner,
    required this.keeperCorner,
    required this.isGoal,
    required this.clubPrimaryColor,
    this.dragStart,
    this.dragCurrent,
  });

  Offset _cornerToGoalPoint(PenaltyCorner corner, Rect goalRect) {
    switch (corner) {
      case PenaltyCorner.topLeft:
        return Offset(goalRect.left + goalRect.width * 0.16, goalRect.top + goalRect.height * 0.22);
      case PenaltyCorner.topRight:
        return Offset(goalRect.right - goalRect.width * 0.16, goalRect.top + goalRect.height * 0.22);
      case PenaltyCorner.bottomLeft:
        return Offset(goalRect.left + goalRect.width * 0.16, goalRect.bottom - goalRect.height * 0.16);
      case PenaltyCorner.bottomRight:
        return Offset(goalRect.right - goalRect.width * 0.16, goalRect.bottom - goalRect.height * 0.16);
      case PenaltyCorner.center:
        return Offset(goalRect.center.dx, goalRect.top + goalRect.height * 0.42);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final horizonY = h * 0.46;

    // 1. Night Sky & Stadium Floodlights Backdrop
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF030B08),
          Color(0xFF082217),
          Color(0xFF0A2E1F),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, horizonY));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, horizonY), skyPaint);

    // Floodlight beams
    final beamPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF59E0B).withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.2, h * 0.12), radius: w * 0.45));
    canvas.drawCircle(Offset(w * 0.2, h * 0.12), w * 0.45, beamPaint);
    canvas.drawCircle(Offset(w * 0.8, h * 0.12), w * 0.45, beamPaint);

    // 2. 3D Perspective Pitch Turf (from horizonY down to h)
    final turfRect = Rect.fromLTWH(0, horizonY, w, h - horizonY);
    final turfPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0A3322),
          Color(0xFF0D442D),
          Color(0xFF07281A),
        ],
      ).createShader(turfRect);
    canvas.drawRect(turfRect, turfPaint);

    // Perspective mowing stripes
    const stripeCount = 8;
    for (int i = 0; i < stripeCount; i++) {
      if (i.isEven) continue;
      final t0 = i / stripeCount;
      final t1 = (i + 1) / stripeCount;
      final y0 = horizonY + (h - horizonY) * (t0 * t0);
      final y1 = horizonY + (h - horizonY) * (t1 * t1);
      canvas.drawRect(
        Rect.fromLTRB(0, y0, w, y1),
        Paint()..color = const Color(0xFF10B981).withValues(alpha: 0.06),
      );
    }

    // Perspective Penalty Area Lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.42)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Goal line
    canvas.drawLine(Offset(0, horizonY), Offset(w, horizonY), linePaint);

    // 6-yard box in perspective
    final sixYardPath = Path()
      ..moveTo(w * 0.22, horizonY)
      ..lineTo(w * 0.12, horizonY + (h - horizonY) * 0.22)
      ..lineTo(w * 0.88, horizonY + (h - horizonY) * 0.22)
      ..lineTo(w * 0.78, horizonY);
    canvas.drawPath(sixYardPath, linePaint);

    // 3. 3D Goal Frame & Net Mesh
    final goalLeft = w * 0.12;
    final goalRight = w * 0.88;
    final goalTop = h * 0.21;
    final goalBottom = horizonY;
    final goalRect = Rect.fromLTRB(goalLeft, goalTop, goalRight, goalBottom);

    // Inner depth frame of goal net
    final backRect = Rect.fromLTRB(
      goalLeft + 18,
      goalTop + 14,
      goalRight - 18,
      goalBottom - 6,
    );

    final netBgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.38)
      ..style = PaintingStyle.fill;
    canvas.drawRect(goalRect, netBgPaint);

    // Net mesh lines (ripples when a goal is scored!)
    final netRipple = (isShooting && isGoal && shotProgress > 0.75)
        ? math.sin((shotProgress - 0.75) * 40) * 5.0
        : 0.0;
    final netPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 0.9;

    const cols = 18;
    for (int c = 0; c <= cols; c++) {
      final f = c / cols;
      final xFront = goalLeft + goalRect.width * f;
      final xBack = backRect.left + backRect.width * f + netRipple * (f - 0.5);
      canvas.drawLine(Offset(xFront, goalTop), Offset(xBack, backRect.top), netPaint);
      canvas.drawLine(Offset(xBack, backRect.top), Offset(xBack, backRect.bottom), netPaint);
    }
    const rows = 9;
    for (int r = 0; r <= rows; r++) {
      final f = r / rows;
      final yBack = backRect.top + backRect.height * f + netRipple * 0.4;
      canvas.drawLine(Offset(backRect.left, yBack), Offset(backRect.right, yBack), netPaint);
    }

    // Goalposts & Crossbar with metallic highlight
    final postGlow = Paint()
      ..color = (isShooting && isGoal && shotProgress > 0.8)
          ? AppColors.gold.withValues(alpha: 0.55)
          : Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final postPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final postPath = Path()
      ..moveTo(goalLeft, goalBottom)
      ..lineTo(goalLeft, goalTop)
      ..lineTo(goalRight, goalTop)
      ..lineTo(goalRight, goalBottom);
    canvas.drawPath(postPath, postGlow);
    canvas.drawPath(postPath, postPaint);

    // 4. Animated Goalkeeper on Goal Line
    final idleSwayX = math.sin(idleProgress * math.pi * 2) * 14.0;
    final keeperStartCenter = Offset(goalRect.center.dx + idleSwayX, goalBottom - 36);
    Offset keeperCenter = keeperStartCenter;
    double keeperRotation = 0.0;

    if (isShooting && keeperCorner != null) {
      final diveTarget = _cornerToGoalPoint(keeperCorner!, goalRect);
      final diveT = Curves.easeOutCubic.transform((shotProgress * 1.15).clamp(0.0, 1.0));
      keeperCenter = Offset.lerp(keeperStartCenter, diveTarget, diveT)!;
      if (keeperCorner == PenaltyCorner.topLeft || keeperCorner == PenaltyCorner.bottomLeft) {
        keeperRotation = -0.85 * diveT;
      } else if (keeperCorner == PenaltyCorner.topRight || keeperCorner == PenaltyCorner.bottomRight) {
        keeperRotation = 0.85 * diveT;
      }
    }

    _drawGoalkeeper(canvas, keeperCenter, keeperRotation);

    // 5. Penalty Spot & 3D Flying Football
    final spotCenter = Offset(w * 0.5, h * 0.77);

    // Penalty spot turf mark
    canvas.drawOval(
      Rect.fromCenter(center: Offset(spotCenter.dx, spotCenter.dy + 18), width: 26, height: 8),
      Paint()..color = Colors.white.withValues(alpha: 0.65),
    );

    // Drag Aim Arrow if user is dragging the ball
    if (!isShooting && dragStart != null && dragCurrent != null) {
      final delta = dragCurrent! - dragStart!;
      if (delta.dy < -10) {
        final aimEnd = Offset(
          (spotCenter.dx + delta.dx * 1.3).clamp(goalLeft, goalRight),
          (spotCenter.dy + delta.dy * 1.4).clamp(goalTop, spotCenter.dy),
        );
        final aimPaint = Paint()
          ..color = AppColors.gold.withValues(alpha: 0.85)
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(spotCenter, aimEnd, aimPaint);
        canvas.drawCircle(aimEnd, 8, Paint()..color = AppColors.gold);
      }
    }

    // Compute Ball Position & Scale
    Offset ballPos = spotCenter;
    double ballRadius = 29.0;
    double spinAngle = 0.0;

    if (isShooting && targetCorner != null) {
      final t = Curves.easeOutQuad.transform(shotProgress.clamp(0.0, 1.0));
      final goalTarget = _cornerToGoalPoint(targetCorner!, goalRect);

      // Parabolic arc + slight curve (falso)
      final curveX = (targetCorner == PenaltyCorner.topLeft || targetCorner == PenaltyCorner.bottomLeft)
          ? -28.0 * math.sin(t * math.pi)
          : (targetCorner == PenaltyCorner.topRight || targetCorner == PenaltyCorner.bottomRight)
              ? 28.0 * math.sin(t * math.pi)
              : 0.0;
      final arcLiftY = -65.0 * math.sin(t * math.pi);

      if (!isGoal && t > 0.82) {
        // Saved by goalkeeper: deflects off gloves!
        final saveContact = _cornerToGoalPoint(targetCorner!, goalRect);
        final deflectT = (t - 0.82) / 0.18;
        final deflectDir = targetCorner!.name.contains('Left') ? -55.0 : 55.0;
        ballPos = Offset(
          saveContact.dx + deflectDir * deflectT,
          saveContact.dy + 25.0 * deflectT,
        );
      } else {
        ballPos = Offset(
          spotCenter.dx + (goalTarget.dx - spotCenter.dx) * t + curveX,
          spotCenter.dy + (goalTarget.dy - spotCenter.dy) * t + arcLiftY,
        );
      }

      ballRadius = 29.0 - 16.5 * t;
      spinAngle = t * math.pi * 5.0;

      // Motion speed trail behind flying ball
      for (int i = 1; i <= 4; i++) {
        final trailT = (t - i * 0.035).clamp(0.0, 1.0);
        final trailPos = Offset(
          spotCenter.dx + (goalTarget.dx - spotCenter.dx) * trailT + curveX * 0.8,
          spotCenter.dy + (goalTarget.dy - spotCenter.dy) * trailT - 65.0 * math.sin(trailT * math.pi),
        );
        canvas.drawCircle(
          trailPos,
          (ballRadius * (1.0 - i * 0.18)).clamp(3.0, 24.0),
          Paint()..color = AppColors.gold.withValues(alpha: (0.24 - i * 0.05).clamp(0.0, 1.0)),
        );
      }

      // Ground shadow under flying ball
      final groundY = spotCenter.dy + (goalBottom - spotCenter.dy) * t;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(ballPos.dx, groundY + 10),
          width: ballRadius * 1.6,
          height: ballRadius * 0.45,
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.42),
      );
    } else {
      // Ground shadow under stationary ball
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(spotCenter.dx, spotCenter.dy + ballRadius * 0.88),
          width: ballRadius * 1.8,
          height: ballRadius * 0.55,
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.55),
      );
    }

    _draw3DFootball(canvas, ballPos, ballRadius, spinAngle);
  }

  void _drawGoalkeeper(Canvas canvas, Offset center, double rotation) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Keeper shadow
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, 34), width: 42, height: 10),
      Paint()..color = Colors.black.withValues(alpha: 0.45),
    );

    // Legs / Shorts
    final legPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 6.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-8, 10), const Offset(-13, 30), legPaint);
    canvas.drawLine(const Offset(8, 10), const Offset(13, 30), legPaint);

    // Torso Jersey (Neon Orange/Gold Keeper Kit)
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: const Offset(0, -2), width: 26, height: 28),
      const Radius.circular(6),
    );
    canvas.drawRRect(torsoRect, Paint()..color = const Color(0xFFF59E0B));
    canvas.drawRRect(
      torsoRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Outstretched Arms & Goalkeeper Gloves
    final armPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(-12, -10), const Offset(-30, -22), armPaint);
    canvas.drawLine(const Offset(12, -10), const Offset(30, -22), armPaint);

    // Gloves
    final glovePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(-32, -23), 6.0, glovePaint);
    canvas.drawCircle(const Offset(32, -23), 6.0, glovePaint);

    // Head
    canvas.drawCircle(const Offset(0, -24), 9.0, Paint()..color = const Color(0xFFFDE68A));
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(0, -25), radius: 9.2),
      math.pi,
      math.pi,
      true,
      Paint()..color = const Color(0xFF1E293B),
    );

    canvas.restore();
  }

  void _draw3DFootball(Canvas canvas, Offset center, double radius, double spinAngle) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Outer golden glow
    canvas.drawCircle(
      Offset.zero,
      radius * 1.18,
      Paint()..color = AppColors.gold.withValues(alpha: 0.22),
    );

    // 3D Spherical shaded white ball body
    final spherePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.35),
        radius: 0.95,
        colors: const [
          Color(0xFFFFFFFF),
          Color(0xFFE2E8F0),
          Color(0xFF94A3B8),
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));
    canvas.drawCircle(Offset.zero, radius, spherePaint);

    // Rotating Pentagon Pattern
    canvas.save();
    canvas.rotate(spinAngle);

    final pentPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final seamPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = (radius * 0.06).clamp(1.0, 2.2)
      ..style = PaintingStyle.stroke;

    // Center pentagon
    final centerPent = _createPolygonPath(Offset.zero, radius * 0.36, 5);
    canvas.drawPath(centerPent, pentPaint);

    // 5 surrounding panel patches + seams
    for (int i = 0; i < 5; i++) {
      final a = (i * 2 * math.pi / 5) - math.pi / 2;
      final p1 = Offset(math.cos(a) * radius * 0.34, math.sin(a) * radius * 0.34);
      final p2 = Offset(math.cos(a) * radius * 0.78, math.sin(a) * radius * 0.78);
      canvas.drawLine(p1, p2, seamPaint);
      canvas.drawCircle(p2, radius * 0.18, pentPaint);
    }
    canvas.restore();

    // Crisp rim outline
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    canvas.restore();
  }

  Path _createPolygonPath(Offset center, double r, int sides) {
    final path = Path();
    for (int i = 0; i < sides; i++) {
      final a = (i * 2 * math.pi / sides) - math.pi / 2;
      final pt = Offset(center.dx + math.cos(a) * r, center.dy + math.sin(a) * r);
      if (i == 0) {
        path.moveTo(pt.dx, pt.dy);
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _Penalty3DArenaPainter oldDelegate) => true;
}
