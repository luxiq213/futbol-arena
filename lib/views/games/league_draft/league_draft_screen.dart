import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/league_draft_model.dart';
import '../../../data/repositories/football_database.dart';
import '../../../providers/league_draft_provider.dart';
import '../../widgets/app_notification.dart';
import '../../widgets/club_crest_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stadium_background.dart';

class LeagueDraftScreen extends StatelessWidget {
  const LeagueDraftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeagueDraftProvider(),
      child: const _LeagueDraftView(),
    );
  }
}

class _LeagueDraftView extends StatefulWidget {
  const _LeagueDraftView();

  @override
  State<_LeagueDraftView> createState() => _LeagueDraftViewState();
}

class _LeagueDraftViewState extends State<_LeagueDraftView> {
  Timer? _liveStreamTimer;
  Timer? _flashTimer;
  late final TextEditingController _teamNameController;
  bool _isFastStream = false;
  int _autoStartedSeason = -1;
  bool _showLossFlash = false;
  bool _showWinFlash = false;
  int _lossImpactTick = 0;

  @override
  void initState() {
    super.initState();
    _teamNameController = TextEditingController(text: 'Kaptan FC');
  }

  @override
  void dispose() {
    _stopLiveStream();
    _flashTimer?.cancel();
    _teamNameController.dispose();
    super.dispose();
  }

  void _stopLiveStream() {
    _liveStreamTimer?.cancel();
    _liveStreamTimer = null;
  }

  void _simulateWeekWithFeedback(LeagueDraftProvider provider) {
    provider.simulateNextMatchday();
    final latest = provider.latestSimulatedFixture;
    if (latest == null) return;

    final home = provider.participants[latest.homeIndex];
    final away = provider.participants[latest.awayIndex];
    final isHumanInMatch = !home.isBot || !away.isBot;
    if (!isHumanInMatch) return;

    final userIsHome = !home.isBot;
    final myGoals = userIsHome ? latest.homeGoals : latest.awayGoals;
    final oppGoals = userIsHome ? latest.awayGoals : latest.homeGoals;

    _flashTimer?.cancel();
    if (myGoals < oppGoals) {
      HapticFeedback.heavyImpact();
      if (mounted) {
        setState(() {
          _showLossFlash = true;
          _showWinFlash = false;
          _lossImpactTick++;
        });
      }
      _flashTimer = Timer(const Duration(milliseconds: 520), () {
        if (mounted) setState(() => _showLossFlash = false);
      });
    } else if (myGoals > oppGoals) {
      HapticFeedback.lightImpact();
      if (mounted) {
        setState(() {
          _showWinFlash = true;
          _showLossFlash = false;
        });
      }
      _flashTimer = Timer(const Duration(milliseconds: 380), () {
        if (mounted) setState(() => _showWinFlash = false);
      });
    }
  }

  void _scheduleNextStreamStep(LeagueDraftProvider provider) {
    _liveStreamTimer?.cancel();
    if (!mounted ||
        provider.phase != LeagueDraftPhase.leagueSimulation ||
        provider.isAllFixturesPlayed) {
      _liveStreamTimer = null;
      if (mounted) setState(() {});
      return;
    }

    // Readable pace so each matchday result and impact feedback are clearly felt
    final delayMs = _isFastStream ? 360 : 850;

    _liveStreamTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted ||
          provider.phase != LeagueDraftPhase.leagueSimulation ||
          provider.isAllFixturesPlayed) {
        _stopLiveStream();
        if (mounted) setState(() {});
        return;
      }
      _simulateWeekWithFeedback(provider);
      if (provider.isAllFixturesPlayed) {
        _stopLiveStream();
        if (mounted) setState(() {});
      } else {
        _scheduleNextStreamStep(provider);
      }
    });
  }

  void _toggleLiveMatchStream(LeagueDraftProvider provider, {bool? fastMode}) {
    if (fastMode != null) {
      _isFastStream = fastMode;
    }
    if (_liveStreamTimer != null && fastMode == null) {
      setState(_stopLiveStream);
      return;
    }
    _stopLiveStream();
    if (provider.isAllFixturesPlayed) return;

    // Immediately simulate 1 matchday so the user sees instant response
    _simulateWeekWithFeedback(provider);
    if (provider.isAllFixturesPlayed) {
      setState(() {});
      return;
    }

    setState(() {
      _scheduleNextStreamStep(provider);
    });
  }

  void _showInviteFriendDialog(
    BuildContext context,
    LeagueDraftProvider provider, {
    int? targetSlotIndex,
  }) {
    if (!provider.canInviteMoreFriends) {
      AppNotification.show(
        context,
        title: 'Lobi Kapasitesi Dolu',
        message: 'Tüm koltuklar dolu! Daha fazla arkadaş davet etmek için lig takım sayısını artırabilirsin.',
        type: AppNotificationType.warning,
        icon: Icons.groups_rounded,
      );
      return;
    }

    final controller = TextEditingController(
      text: '${provider.invitedHumanCount + 1}. Menajer',
    );
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A2419),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.gold, width: 1.2),
          ),
          title: Text(
            'Lobiye Arkadaş Davet Et (#${provider.lobbyRoomCode})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Davet ettiğin arkadaşın lobi koltuğuna yerleşir; kalan boş koltuklar otomatik olarak Yapay Zeka (AI Bot) kalır.',
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: const InputDecoration(
                  labelText: 'Arkadaşının Adı / Takım Adı',
                  prefixIcon: Icon(Icons.person_add_alt_1_rounded, color: AppColors.gold, size: 18),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Vazgeç', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pitchGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                provider.inviteFriendToLobby(
                  controller.text,
                  targetSlotIndex: targetSlotIndex,
                );
                Navigator.pop(ctx);
                AppNotification.show(
                  context,
                  title: 'Arkadaş Lobiye Katıldı',
                  message: '${controller.text.trim().isEmpty ? "Yeni Menajer" : controller.text.trim()} lobiye eklendi! Kalan ${provider.botFillCount} koltuk AI Bot.',
                  type: AppNotificationType.success,
                  icon: Icons.check_circle_outline_rounded,
                );
              },
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Lobiye Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameSlotDialog(
    BuildContext context,
    LeagueDraftProvider provider,
    int slotIndex,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A2419),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.pitchGreen, width: 1.2),
          ),
          title: const Text(
            'Menajer / Takım Adını Düzenle',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: const InputDecoration(
              labelText: 'Yeni Menajer / Takım Adı',
              prefixIcon: Icon(Icons.edit_rounded, color: AppColors.greenLight, size: 18),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Vazgeç', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pitchGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                provider.updateLobbySlotName(slotIndex, controller.text);
                Navigator.pop(ctx);
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  void _showJoinLobbyByCodeDialog(BuildContext context, LeagueDraftProvider provider) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: 'Misafir Kaptan');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A2419),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.gold, width: 1.2),
          ),
          title: const Text(
            '6 Haneli Lobi Koduna Katıl',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                decoration: const InputDecoration(
                  labelText: 'Oda / Lobi Kodu (Örn: 482915)',
                  prefixIcon: Icon(Icons.tag_rounded, color: AppColors.gold, size: 18),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: const InputDecoration(
                  labelText: 'Senin Takım / Menajer Adın',
                  prefixIcon: Icon(Icons.shield_outlined, color: AppColors.greenLight, size: 18),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Vazgeç', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pitchGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final ok = provider.joinLobbyByCode(codeCtrl.text, nameCtrl.text);
                Navigator.pop(ctx);
                if (ok) {
                  AppNotification.show(
                    context,
                    title: 'Lobiye Bağlandın!',
                    message: '#${provider.lobbyRoomCode} numaralı lig lobisine katıldın.',
                    type: AppNotificationType.success,
                    icon: Icons.wifi_tethering_rounded,
                  );
                } else {
                  AppNotification.show(
                    context,
                    title: 'Geçersiz Kod',
                    message: 'Lütfen en az 4-6 haneli geçerli bir lobi kodu gir.',
                    type: AppNotificationType.error,
                    icon: Icons.error_outline_rounded,
                  );
                }
              },
              icon: const Icon(Icons.login_rounded, size: 16),
              label: const Text('Lobiye Katıl'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeagueDraftProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Lig Draft • Sezon #${provider.seasonNumber}',
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_tethering_rounded, size: 13, color: AppColors.gold),
                const SizedBox(width: 4),
                Text(
                  'Lobi #${provider.lobbyRoomCode}',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          StadiumBackground(
            showLiveMatch: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _buildPhaseContent(context, provider),
            ),
          ),
          // Red Impact / Goal Vignette Flash Overlay
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  gradient: (_showLossFlash || _showWinFlash)
                      ? RadialGradient(
                          center: Alignment.center,
                          radius: 0.95,
                          colors: [
                            Colors.transparent,
                            (_showLossFlash ? AppColors.error : AppColors.pitchGreen)
                                .withValues(alpha: _showLossFlash ? 0.36 : 0.22),
                          ],
                          stops: const [0.42, 1.0],
                        )
                      : null,
                  border: _showLossFlash
                      ? Border.all(
                          color: AppColors.error.withValues(alpha: 0.72),
                          width: 3.5,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseContent(BuildContext context, LeagueDraftProvider provider) {
    switch (provider.phase) {
      case LeagueDraftPhase.setup:
        return _buildSetupPhase(context, provider);
      case LeagueDraftPhase.pickManager:
        return _buildPickManagerPhase(context, provider);
      case LeagueDraftPhase.pickFormation:
        return _buildPickFormationPhase(context, provider);
      case LeagueDraftPhase.pickPlayers:
        return _buildPickPlayersPhase(context, provider);
      case LeagueDraftPhase.nextPlayerHandoff:
        return _buildHandoffPhase(context, provider);
      case LeagueDraftPhase.leagueSimulation:
        if (!provider.isAllFixturesPlayed &&
            provider.playedFixturesCount == 0 &&
            _liveStreamTimer == null &&
            _autoStartedSeason != provider.seasonNumber) {
          _autoStartedSeason = provider.seasonNumber;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                provider.phase == LeagueDraftPhase.leagueSimulation &&
                !provider.isAllFixturesPlayed &&
                _liveStreamTimer == null) {
              _toggleLiveMatchStream(provider);
            }
          });
        }
        return _buildLeagueSimulationPhase(context, provider);
    }
  }

  // ===========================================================================
  // PHASE 0: ONLINE LEAGUE LOBBY (INVITE UP TO LEAGUE SIZE, REST ARE AI BOTS)
  // ===========================================================================
  Widget _buildSetupPhase(BuildContext context, LeagueDraftProvider provider) {
    final totalWeeks = (provider.leagueCapacity - 1) * 2;
    final humanSlots = provider.lobbySlots.where((s) => !s.isBot).toList();
    final hostName = humanSlots.isNotEmpty ? humanSlots.first.name : '';
    if (_teamNameController.text.isEmpty && hostName.isNotEmpty) {
      _teamNameController.text = hostName;
    }

    return SingleChildScrollView(
      key: const ValueKey('setup'),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Compact Online Lobby Room Top HUD Strip (Fixed 18 Teams)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF14422D).withValues(alpha: 0.94),
                  const Color(0xFF071B12).withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.7), width: 1.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.hub_rounded, color: AppColors.gold, size: 17),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Oda #${provider.lobbyRoomCode} • Sezon #${provider.seasonNumber}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '18 Takımlı Lig ($totalWeeks Hafta)',
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
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: provider.lobbyRoomCode));
                    AppNotification.show(
                      context,
                      title: 'Davet Kodu Kopyalandı (#${provider.lobbyRoomCode})',
                      message: 'Kodu arkadaşlarına gönder veya "+ Arkadaş Davet Et" ile lobiye ekle!',
                      type: AppNotificationType.highlight,
                      icon: Icons.copy_rounded,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.7)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share_rounded, size: 12, color: AppColors.gold),
                        SizedBox(width: 3),
                        Text(
                          'Kodu Paylaş',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showJoinLobbyByCodeDialog(context, provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.pitchGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.pitchGreen.withValues(alpha: 0.7)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.login_rounded, size: 12, color: AppColors.greenLight),
                        SizedBox(width: 3),
                        Text(
                          'Katıl',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.greenLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 1. Editable Custom Team Name
          const Text(
            '1. TAKIMININ İSMİ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: AppColors.greenLight,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _teamNameController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            onChanged: (val) => provider.updateLobbySlotName(0, val),
            decoration: InputDecoration(
              hintText: 'Örn: Kartal FC, Boğaz Gücü...',
              hintStyle: const TextStyle(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surface.withValues(alpha: 0.92),
              prefixIcon: const Icon(
                Icons.shield_outlined,
                color: AppColors.gold,
                size: 19,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.gold.withValues(alpha: 0.45)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.pitchGreen, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Pool Selector & Database Browser Button (Fixed 18 Teams)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2. LİG & TARİHİ SEZON HAVUZU',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: AppColors.greenLight,
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showDatabaseBrowserSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.pitchGreen.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.pitchGreen.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    'Veritabanı (${LeagueDraftProvider.allEraClubPacks.length} Paket • ${LeagueDraftProvider.allManagers.length} Hoca) ›',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.greenLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _buildPoolFilterChip(
                provider: provider,
                theme: LeaguePoolTheme.allWorldHistory,
                label: 'Dünya Süper Ligi • 18 Takım (${LeagueDraftProvider.allEraClubPacks.length} Paket)',
              ),
              _buildPoolFilterChip(
                provider: provider,
                theme: LeaguePoolTheme.superLigHistory,
                label: 'Türkiye Süper Lig • 18 Takım',
              ),
              _buildPoolFilterChip(
                provider: provider,
                theme: LeaguePoolTheme.europeanGiants,
                label: 'Avrupa Devler Ligi • 18 Takım',
              ),
              _buildPoolFilterChip(
                provider: provider,
                theme: LeaguePoolTheme.worldCupLegends,
                label: 'Milli Takım & Süper Lig • 18 Takım',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Start Button right here
          CustomButton(
            text: '${provider.seasonNumber}. Sezon Kadro Seçimini Başlat (18 Takım)',
            icon: Icons.play_arrow_rounded,
            backgroundColor: AppColors.pitchGreen,
            textColor: Colors.white,
            onPressed: provider.startDraftFromLobby,
          ),
          const SizedBox(height: 16),

          // 3. Human Participants Only + AI Auto-Fill Info Notice (No clutter of 17 AI rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '3. KATILAN OYUNCULAR (${humanSlots.length}/18)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: AppColors.greenLight,
                ),
              ),
              if (provider.canInviteMoreFriends)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _showInviteFriendDialog(context, provider),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.75)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add_alt_1_rounded, size: 13, color: AppColors.gold),
                        SizedBox(width: 4),
                        Text(
                          '+ Arkadaş Davet Et',
                          style: TextStyle(
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
          const SizedBox(height: 8),

          ...humanSlots.map((slot) {
            final index = slot.slotIndex;
            return Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFF103826).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: slot.isHost ? AppColors.gold : AppColors.pitchGreen,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.pitchGreen.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      slot.isHost ? Icons.stars_rounded : Icons.person_rounded,
                      size: 17,
                      color: slot.isHost ? AppColors.gold : AppColors.greenLight,
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
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: slot.isHost
                                    ? AppColors.gold.withValues(alpha: 0.22)
                                    : AppColors.pitchGreen.withValues(alpha: 0.24),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                slot.isHost ? 'SENİN TAKIMIN' : 'DAVETLİ OYUNCU',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: slot.isHost ? AppColors.gold : AppColors.greenLight,
                                ),
                              ),
                            ),
                            if (slot.championshipsWon > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${slot.championshipsWon} Şampiyonluk',
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF06160F),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          slot.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'İsmi Düzenle',
                    onPressed: () => _showRenameSlotDialog(context, provider, index, slot.name),
                    icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.greenLight),
                  ),
                  if (!slot.isHost)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Oyuncuyu Çıkar',
                      onPressed: () => provider.convertSlotToBot(index),
                      icon: const Icon(Icons.person_remove_outlined, size: 17, color: Colors.redAccent),
                    ),
                ],
              ),
            );
          }),

          // Clean AI completion info banner
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.greenLight,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    '18 takımlık ligde yeterli gerçek oyuncu olmazsa kalan ${provider.botFillCount} kontenjan yapay zeka (AI) takımlarıyla otomatik tamamlanır.',
                    style: const TextStyle(
                      fontSize: 11.2,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PHASE 1: PICK 1 OF 3 RANDOM MANAGERS
  // ===========================================================================
  Widget _buildPickManagerPhase(BuildContext context, LeagueDraftProvider provider) {
    final active = provider.activeParticipant;

    return SingleChildScrollView(
      key: ValueKey('mgr_${active.id}'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActivePlayerBanner(
            active.name,
            'ADIM 1 / 3 • TEKNİK DİREKTÖR SEÇİMİ',
            'Rastgele gelen 3 efsane hocadan birini takımının başına geçir.',
          ),
          const SizedBox(height: 14),
          ...provider.currentManagerChoices.map((mgr) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => provider.selectManager(mgr),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF103324).withValues(alpha: 0.92),
                        const Color(0xFF071A12).withValues(alpha: 0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.55),
                      width: 1.1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${mgr.rating}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: AppColors.gold,
                              ),
                            ),
                            const Text(
                              'HOCA',
                              style: TextStyle(
                                fontSize: 7.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    mgr.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${mgr.nationality})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.greenLight,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mgr.styleTitle,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mgr.bonusDescription,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.gold,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // PHASE 2: PICK 1 OF 3 RANDOM FORMATIONS
  // ===========================================================================
  Widget _buildPickFormationPhase(BuildContext context, LeagueDraftProvider provider) {
    final active = provider.activeParticipant;

    return SingleChildScrollView(
      key: ValueKey('form_${active.id}'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildActivePlayerBanner(
            '${active.name} • Hoca: ${active.manager?.name ?? ""}',
            'ADIM 2 / 3 • TAKTİK DİZİLİŞ SEÇİMİ',
            'Rastgele gelen 3 dizilişten birini seçerek saha dizilimini belirle.',
          ),
          const SizedBox(height: 14),
          ...provider.currentFormationChoices.map((form) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => provider.selectFormation(form),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF103324).withValues(alpha: 0.92),
                        const Color(0xFF071A12).withValues(alpha: 0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.pitchGreen.withValues(alpha: 0.65),
                      width: 1.1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.pitchGreen.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: AppColors.pitchGreen),
                        ),
                        child: Text(
                          form.code,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              form.title,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              form.description,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.greenLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+${form.attackBonus} Hücum • +${form.defenseBonus} Savunma Dengesi',
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: AppColors.greenLight,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ===========================================================================
  // PHASE 3: VISUAL 11-SLOT FORMATION PITCH + 5 PLAYERS FROM SPUN HISTORICAL CLUB
  // ===========================================================================
  Widget _buildPickPlayersPhase(BuildContext context, LeagueDraftProvider provider) {
    final active = provider.activeParticipant;
    final pack = provider.currentSpunClubPack;
    if (pack == null) return const SizedBox.shrink();

    final form = active.formation ?? LeagueDraftProvider.allFormations.first;
    final labels = form.specificSlotLabels;
    final selectedSlot = provider.selectedPitchSlotIndex.clamp(0, 10);
    final selectedLabel = labels[selectedSlot];

    return SingleChildScrollView(
      key: ValueKey('pick_${active.id}_${active.squad.length}_$selectedSlot'),
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Compact Header Strip: Manager, Formation, Squad Progress (X/11) (No auto-fill skip)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${active.name} • ${form.code} (${active.manager?.name ?? ""})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                      Text(
                        'Kadro: ${active.squad.length}/11 • Hedef Mevki: $selectedLabel (${provider.currentNeededRoleLabel})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.pitchGreen.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.pitchGreen),
                  ),
                  child: Text(
                    '${active.squad.length}/11',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.greenLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 2. Taller, Airy 2D Tactical Pitch with Field Markings
          _buildInteractiveFormationPitch(
            provider: provider,
            participant: active,
            interactive: true,
          ),

          const SizedBox(height: 10),

          // 3. Animated Spun Club Roulette + 3 Sequential Mystery Boxes
          _DraftRevealArena(
            key: ValueKey(
              'reveal_${active.id}_${active.squad.length}_${pack.id}_${provider.remainingRerolls}',
            ),
            provider: provider,
            pack: pack,
            choices: provider.currentPlayerChoices,
            selectedSlotIndex: selectedSlot,
            selectedSlotLabel: selectedLabel,
          ),
        ],
      ),
    );
  }

  /// Renders a taller, airier 2D tactical football pitch with real pitch markings
  Widget _buildInteractiveFormationPitch({
    required LeagueDraftProvider? provider,
    required LeagueParticipant participant,
    required bool interactive,
  }) {
    final form = participant.formation ?? LeagueDraftProvider.allFormations.first;
    final labels = form.specificSlotLabels;
    final defCount = form.defenders;
    final midCount = form.midfielders;

    final gkIndices = <int>[0];
    final defIndices = List<int>.generate(defCount, (i) => 1 + i);
    final midIndices = List<int>.generate(midCount, (i) => 1 + defCount + i);
    final fwdStart = 1 + defCount + midCount;
    final fwdIndices = List<int>.generate(11 - fwdStart, (i) => fwdStart + i);

    Widget buildSlotNode(int slotIdx) {
      final assigned = participant.pitchSlots[slotIdx] ??
          (slotIdx < participant.squad.length ? participant.squad[slotIdx] : null);
      final isSelected = interactive && provider?.selectedPitchSlotIndex == slotIdx;
      final posCode = slotIdx < labels.length ? labels[slotIdx] : 'OS';

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.5),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: interactive && provider != null
                ? () => provider.selectPitchSlot(slotIdx)
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: assigned != null
                    ? const Color(0xFF0A281B).withValues(alpha: 0.94)
                    : (isSelected
                        ? AppColors.gold.withValues(alpha: 0.24)
                        : Colors.black.withValues(alpha: 0.36)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.gold
                      : (assigned != null
                          ? AppColors.pitchGreen
                          : Colors.white.withValues(alpha: 0.26)),
                  width: isSelected ? 1.7 : 1.0,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.gold
                              : (assigned != null
                                  ? AppColors.pitchGreen
                                  : Colors.white.withValues(alpha: 0.16)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          posCode,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? const Color(0xFF06160F) : Colors.white,
                          ),
                        ),
                      ),
                      if (assigned != null) ...[
                        const SizedBox(width: 3),
                        Text(
                          '${assigned.rating}',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    assigned != null
                        ? _shortPlayerName(assigned.name)
                        : (isSelected ? 'Hedef' : 'Boş'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9.8,
                      fontWeight: assigned != null || isSelected
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: assigned != null
                          ? Colors.white
                          : (isSelected ? AppColors.gold : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 288),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF155B3A),
            Color(0xFF0E4129),
            Color(0xFF155B3A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.pitchGreen.withValues(alpha: 0.8),
          width: 1.3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: CustomPaint(
          painter: _TacticalPitchPainter(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(9, 12, 9, 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SAHA DİZİLİŞİ (${form.code}) • ${participant.squad.length}/11',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.gold,
                      ),
                    ),
                    Text(
                      'Güç: ${participant.overallTeamPower} OVR',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Forwards Line (Top of Pitch)
                Row(children: fwdIndices.map(buildSlotNode).toList()),
                const SizedBox(height: 15),
                // Midfielders Line
                Row(children: midIndices.map(buildSlotNode).toList()),
                const SizedBox(height: 15),
                // Defenders Line
                Row(children: defIndices.map(buildSlotNode).toList()),
                const SizedBox(height: 15),
                // Goalkeeper Line (Bottom of Pitch)
                Row(
                  children: [
                    const Spacer(),
                    ...gkIndices.map(buildSlotNode),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _shortPlayerName(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length <= 1) return fullName;
    return parts.last;
  }

  // ===========================================================================
  // PHASE 3.5: HANDOFF TO NEXT FRIEND
  // ===========================================================================
  Widget _buildHandoffPhase(BuildContext context, LeagueDraftProvider provider) {
    final prevPlayer = provider.participants[provider.activeParticipantIndex - 1];
    final nextPlayer = provider.activeParticipant;

    return Padding(
      key: ValueKey('handoff_${nextPlayer.id}'),
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold, width: 1.3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.swap_horiz_rounded, color: AppColors.gold, size: 42),
              const SizedBox(height: 10),
              Text(
                '${prevPlayer.name} Kadrosunu Tamamladı!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.greenLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hoca: ${prevPlayer.manager?.name ?? ""} • Diziliş: ${prevPlayer.formation?.code ?? ""} • Güç: ${prevPlayer.overallTeamPower} OVR',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const Divider(height: 24, color: AppColors.border),
              const Text(
                'SIRADAKİ MENAJER:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nextPlayer.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: '${nextPlayer.name} Kadro Kurmaya Başlasın',
                icon: Icons.sports_soccer_rounded,
                backgroundColor: AppColors.pitchGreen,
                textColor: Colors.white,
                onPressed: provider.beginNextHumanTurn,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PHASE 4: LIVE FLOWING LEAGUE SIMULATION & END-OF-SEASON SUMMARY
  // ===========================================================================
  Widget _buildLeagueSimulationPhase(BuildContext context, LeagueDraftProvider provider) {
    final table = provider.standings;
    final champion = provider.champion;
    final latestMatch = provider.latestSimulatedFixture;
    final isStreaming = _liveStreamTimer != null;
    final totalWeeks = provider.totalMatchdays <= 0 ? 1 : provider.totalMatchdays;
    final playedDays = provider.fixtures.where((f) => f.isPlayed).map((f) => f.matchday).toSet();
    final playedWeekCount = playedDays.length;
    final progress = (playedWeekCount / totalWeeks).clamp(0.0, 1.0);
    final userHistory = provider.userPlayedFixturesReverse;

    final myTeam = provider.participants.firstWhere(
      (p) => !p.isBot,
      orElse: () => provider.participants.first,
    );
    final myRank = table.indexWhere((p) => p.id == myTeam.id) + 1;

    final displayMatchday = playedDays.isNotEmpty
        ? playedDays.reduce((a, b) => a > b ? a : b)
        : provider.currentMatchday;
    final dayMatches = provider.fixtures.where((f) => f.matchday == displayMatchday).toList();

    return SingleChildScrollView(
      key: const ValueKey('league_sim'),
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. LIVE WEEK-BY-WEEK MATCH STREAM TICKER
          if (!provider.isAllFixturesPlayed)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF14452F).withValues(alpha: 0.95),
                    const Color(0xFF071B12).withValues(alpha: 0.96),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isStreaming ? AppColors.gold : AppColors.pitchGreen,
                  width: 1.3,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isStreaming ? AppColors.gold : AppColors.pitchGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'CANLI LİG SİMÜLASYONU • HAFTA $playedWeekCount / $totalWeeks',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Sıran: $myRank. (${myTeam.points} P)',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.greenLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.black.withValues(alpha: 0.35),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Animated Live Match Scoreboard Passing in Front of the User
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: latestMatch == null
                        ? Container(
                            key: const ValueKey('waiting_kickoff'),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: const Text(
                              'Kadro tamamlandı! Lig maçları hafta hafta simüle ediliyor...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : _buildFlowingMatchHighlightCard(provider, latestMatch),
                  ),

                  const SizedBox(height: 10),

                  // Stream Controls: Duraklat/Devam, 2x Hız, +1 Hafta, Sonuca Geç
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isStreaming ? AppColors.gold : AppColors.pitchGreen,
                            foregroundColor: isStreaming ? const Color(0xFF06160F) : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          onPressed: () => _toggleLiveMatchStream(provider),
                          icon: Icon(
                            isStreaming ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 17,
                          ),
                          label: Text(
                            isStreaming ? 'Duraklat' : 'Devam Et',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        borderRadius: BorderRadius.circular(11),
                        onTap: () => _toggleLiveMatchStream(provider, fastMode: !_isFastStream),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
                          decoration: BoxDecoration(
                            color: _isFastStream
                                ? AppColors.gold.withValues(alpha: 0.22)
                                : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: _isFastStream ? AppColors.gold : AppColors.border,
                            ),
                          ),
                          child: Text(
                            _isFastStream ? '2x Hız' : '1x Hız',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: _isFastStream ? AppColors.gold : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        borderRadius: BorderRadius.circular(11),
                        onTap: () {
                          _stopLiveStream();
                          _simulateWeekWithFeedback(provider);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.pitchGreen.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: AppColors.pitchGreen.withValues(alpha: 0.7),
                            ),
                          ),
                          child: const Text(
                            '+1 Hafta',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.greenLight,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        flex: 3,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gold,
                            side: const BorderSide(color: AppColors.gold),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          onPressed: () {
                            _stopLiveStream();
                            provider.simulateAllRemainingMatchdays();
                          },
                          icon: const Icon(Icons.fast_forward_rounded, size: 15),
                          label: const Text(
                            'Sezon Sonu',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // 2. END-OF-SEASON SUMMARY REPORT ("LİG SONU: BU OLDU, ŞU OLDU") + VIEW/SHARE SQUAD + NEW TEAM
          if (champion != null)
            _buildEndOfSeasonSummaryCard(
              context: context,
              provider: provider,
              champion: champion,
              myTeam: myTeam,
              myRank: myRank,
              totalTeams: table.length,
            ),

          // 3. USER'S WEEK-BY-WEEK MATCH RESULTS (GALİBİYET / BERABERLİK / MAĞLUBİYET + SKOR)
          if (userHistory.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TAKIMININ HAFTA HAFTA MAÇ GEÇMİŞİ',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.gold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${myTeam.won}G • ${myTeam.drawn}B • ${myTeam.lost}M (${myTeam.points} P)',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.greenLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: userHistory.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 6),
                      itemBuilder: (context, index) {
                        final m = userHistory[index];
                        final h = provider.participants[m.homeIndex];
                        final a = provider.participants[m.awayIndex];
                        final isHome = h.id == myTeam.id;
                        final myGoals = isHome ? m.homeGoals : m.awayGoals;
                        final oppGoals = isHome ? m.awayGoals : m.homeGoals;
                        final oppName = isHome ? a.name : h.name;

                        final bool isWin = myGoals > oppGoals;
                        final bool isDraw = myGoals == oppGoals;
                        final Color badgeColor = isWin
                            ? AppColors.pitchGreen
                            : (isDraw ? AppColors.gold : AppColors.error);
                        final String badgeCode = isWin ? 'G' : (isDraw ? 'B' : 'M');

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.32),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: badgeColor.withValues(alpha: 0.7)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  badgeCode,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: isDraw ? const Color(0xFF06160F) : Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'H${m.matchday}: $myGoals-$oppGoals $oppName',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Live Standings Table
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CANLI PUAN DURUMU (KADRO İÇİN TAKIMA DOKUN)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.greenLight,
                      ),
                    ),
                    Text(
                      'GÇ   O   G   B   M   AV   P',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 14, color: AppColors.border),
                ...List.generate(table.length, (idx) {
                  final team = table[idx];
                  final isLeader = idx == 0;
                  final isChampionsLeague = idx >= 1 && idx <= 3;
                  final isRelegation = table.length >= 16 && idx >= table.length - 3;
                  final isHuman = !team.isBot;

                  Color rankBgColor = Colors.white.withValues(alpha: 0.06);
                  Color rankTextColor = Colors.white;
                  if (isLeader) {
                    rankBgColor = AppColors.gold.withValues(alpha: 0.24);
                    rankTextColor = AppColors.gold;
                  } else if (isChampionsLeague) {
                    rankBgColor = AppColors.pitchGreen.withValues(alpha: 0.22);
                    rankTextColor = AppColors.greenLight;
                  } else if (isRelegation) {
                    rankBgColor = Colors.redAccent.withValues(alpha: 0.20);
                    rankTextColor = Colors.redAccent;
                  }

                  return InkWell(
                    onTap: () => _showTeamSquadSheet(context, team),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      decoration: BoxDecoration(
                        color: isHuman
                            ? AppColors.pitchGreen.withValues(alpha: 0.16)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isHuman
                            ? Border.all(color: AppColors.gold.withValues(alpha: 0.55), width: 0.9)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: rankBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: rankTextColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        team.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.2,
                                          fontWeight: FontWeight.w800,
                                          color: isLeader
                                              ? AppColors.gold
                                              : (isHuman ? AppColors.greenLight : Colors.white),
                                        ),
                                      ),
                                    ),
                                    if (isHuman) ...[
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.gold,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'SEN',
                                          style: TextStyle(
                                            fontSize: 7.5,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF06160F),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(
                                  '${team.manager?.name ?? ""} • ${team.formation?.code ?? ""}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${team.overallTeamPower}   ${team.played}   ${team.won}   ${team.drawn}   ${team.lost}   ${team.goalDifference >= 0 ? "+${team.goalDifference}" : team.goalDifference}   ',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${team.points}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.greenLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Matchday Results & Goalscorers
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$displayMatchday. HAFTA MAÇ SONUÇLARI & GOLLER (${provider.totalMatchdays} HAFTA)',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 8),
                ...dayMatches.map((m) {
                  final home = provider.participants[m.homeIndex];
                  final away = provider.participants[m.awayIndex];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                home.name,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: m.isPlayed
                                    ? AppColors.pitchGreen.withValues(alpha: 0.25)
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                m.isPlayed ? '${m.homeGoals} - ${m.awayGoals}' : 'v',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                away.name,
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (m.isPlayed && m.events.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          ...m.events.map((ev) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                '${ev.minute}\' ${ev.scorerName} (${ev.clubEraTag})',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: ev.isHomeGoal
                                      ? AppColors.greenLight
                                      : AppColors.gold,
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Top Scorers Race
          if (provider.topScorers.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.90),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'GOL KRALLIĞI YARIŞI',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.greenLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...provider.topScorers.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.sports_soccer_rounded, size: 13, color: AppColors.gold),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${entry.key} (${provider.scorerClubTag(entry.key)})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Text(
                            '${entry.value} Gol',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFlowingMatchHighlightCard(
    LeagueDraftProvider provider,
    LeagueMatchFixture match,
  ) {
    final home = provider.participants[match.homeIndex];
    final away = provider.participants[match.awayIndex];
    final isHumanInMatch = !home.isBot || !away.isBot;
    final userIsHome = !home.isBot;

    String outcomeLabel = '${match.matchday}. HAFTA MAÇ SONUCU';
    Color outcomeColor = AppColors.gold;
    if (isHumanInMatch) {
      final myGoals = userIsHome ? match.homeGoals : match.awayGoals;
      final oppGoals = userIsHome ? match.awayGoals : match.homeGoals;
      if (myGoals > oppGoals) {
        outcomeLabel = '${match.matchday}. HAFTA • GALİBİYET (+3 PUAN)';
        outcomeColor = AppColors.pitchGreen;
      } else if (myGoals == oppGoals) {
        outcomeLabel = '${match.matchday}. HAFTA • BERABERLİK (+1 PUAN)';
        outcomeColor = AppColors.gold;
      } else {
        outcomeLabel = '${match.matchday}. HAFTA • MAĞLUBİYET (0 PUAN)';
        outcomeColor = AppColors.error;
      }
    }

    final card = Container(
      key: ValueKey('flow_${match.matchday}_${match.homeIndex}_${match.awayIndex}'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHumanInMatch && outcomeColor == AppColors.error
            ? const Color(0xFF3A0A0E).withValues(alpha: 0.88)
            : Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: outcomeColor.withValues(alpha: 0.90),
          width: outcomeColor == AppColors.error ? 1.8 : 1.3,
        ),
        boxShadow: isHumanInMatch && outcomeColor == AppColors.error
            ? [
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.42),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: outcomeColor.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: outcomeColor.withValues(alpha: 0.7)),
            ),
            child: Text(
              outcomeLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: outcomeColor == AppColors.pitchGreen ? AppColors.greenLight : outcomeColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      home.name,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: !home.isBot ? AppColors.gold : Colors.white,
                      ),
                    ),
                    Text(
                      '${home.manager?.name ?? ""} (${home.overallTeamPower} OVR)',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: outcomeColor.withValues(alpha: 0.26),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: outcomeColor, width: 1.2),
                ),
                child: Text(
                  '${match.homeGoals} - ${match.awayGoals}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      away.name,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: !away.isBot ? AppColors.gold : Colors.white,
                      ),
                    ),
                    Text(
                      '${away.manager?.name ?? ""} (${away.overallTeamPower} OVR)',
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (match.events.isNotEmpty) ...[
            const Divider(height: 14, color: AppColors.border),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              children: match.events.map((ev) {
                return Text(
                  '${ev.minute}\' ${ev.scorerName} (${ev.clubEraTag})',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ev.isHomeGoal ? AppColors.greenLight : AppColors.gold,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );

    if (isHumanInMatch && outcomeColor == AppColors.error) {
      return TweenAnimationBuilder<double>(
        key: ValueKey('shake_${match.matchday}_$_lossImpactTick'),
        tween: Tween<double>(begin: 1.0, end: 0.0),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOut,
        builder: (context, t, child) {
          final dx = math.sin(t * math.pi * 6) * 8.0 * t;
          return Transform.translate(
            offset: Offset(dx, 0),
            child: child,
          );
        },
        child: card,
      );
    }
    return card;
  }

  Widget _buildEndOfSeasonSummaryCard({
    required BuildContext context,
    required LeagueDraftProvider provider,
    required LeagueParticipant champion,
    required LeagueParticipant myTeam,
    required int myRank,
    required int totalTeams,
  }) {
    final isUserChampion = champion.id == myTeam.id;
    String statusSummary;
    Color statusColor;
    if (myRank == 1) {
      statusSummary = 'LİG ŞAMPİYONU OLDUN! Kupayı kaldırdın!';
      statusColor = AppColors.gold;
    } else if (myRank <= 4) {
      statusSummary = 'Ligi $myRank. sırada bitirerek Şampiyonlar Ligi potasına girdin!';
      statusColor = AppColors.greenLight;
    } else if (myRank <= 6) {
      statusSummary = 'Ligi $myRank. sırada tamamlayarak Avrupa Kupası bileti aldın.';
      statusColor = AppColors.greenLight;
    } else if (totalTeams >= 16 && myRank >= totalTeams - 2) {
      statusSummary = 'Ligi $myRank. sırada tamamladın ve küme düşme hattında kaldın.';
      statusColor = AppColors.error;
    } else {
      statusSummary = 'Ligi $myRank. sırada orta sıralarda tamamladın.';
      statusColor = Colors.white;
    }

    final topScorerText = provider.topScorers.isNotEmpty
        ? '${provider.topScorers.first.key} (${provider.topScorers.first.value} Gol)'
        : 'Belirlenmedi';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.24),
            const Color(0xFF0E2D20).withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 32),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${provider.seasonNumber}. SEZON SONU RAPORU • NELER OLDU?',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isUserChampion
                          ? 'ŞAMPİYON: ${myTeam.name}!'
                          : 'Şampiyon: ${champion.name} (${champion.points} P)',
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      statusSummary,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Season Breakdown Box ("Bu oldu, şu oldu")
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• Senin Derecen: $myRank / $totalTeams Takım • ${myTeam.points} Puan (${myTeam.overallTeamPower} OVR)',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 3),
                Text(
                  '• Karnen: ${myTeam.played} Maçta ${myTeam.won} Galibiyet, ${myTeam.drawn} Beraberlik, ${myTeam.lost} Mağlubiyet',
                  style: const TextStyle(fontSize: 11, color: AppColors.greenLight, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '• Gol İstatistiğin: ${myTeam.goalsFor} Gol Attın, ${myTeam.goalsAgainst} Gol Yedin (Averaj: ${myTeam.goalDifference >= 0 ? "+${myTeam.goalDifference}" : myTeam.goalDifference})',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 3),
                Text(
                  '• Sezonun Gol Kralı: $topScorerText',
                  style: const TextStyle(fontSize: 11, color: AppColors.gold, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // View Squad & Share Squad Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.pitchGreen, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  onPressed: () => _showTeamSquadSheet(context, myTeam),
                  icon: const Icon(Icons.stadium_outlined, size: 16, color: AppColors.greenLight),
                  label: const Text(
                    'Kadromu Gör',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    side: const BorderSide(color: AppColors.gold, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  onPressed: () => _shareSquadAndSeasonResult(
                    context,
                    provider: provider,
                    team: myTeam,
                    rank: myRank,
                    totalTeams: totalTeams,
                  ),
                  icon: const Icon(Icons.share_outlined, size: 16, color: AppColors.gold),
                  label: const Text(
                    'Kadroyu Paylaş',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Next Season: Always Build a Brand New Team (No Continuing with Same Squad!)
          CustomButton(
            text: '${provider.seasonNumber + 1}. Sezon İçin Yeni Takım Kur',
            icon: Icons.autorenew_rounded,
            backgroundColor: AppColors.pitchGreen,
            textColor: Colors.white,
            onPressed: () {
              _stopLiveStream();
              provider.startNewSeasonWithNewTeam();
            },
          ),
          const SizedBox(height: 6),
          CustomButton(
            text: 'Lobiye Dön (${provider.seasonNumber + 1}. Sezon Ayarları)',
            icon: Icons.meeting_room_outlined,
            isOutlined: true,
            height: 42,
            onPressed: () {
              _stopLiveStream();
              provider.continueToLobbyForNextSeason();
            },
          ),
        ],
      ),
    );
  }

  void _shareSquadAndSeasonResult(
    BuildContext context, {
    required LeagueDraftProvider provider,
    required LeagueParticipant team,
    required int rank,
    required int totalTeams,
  }) {
    final squadLines = team.squad
        .map((p) => '${p.specificPosition}: ${p.name} (${p.rating} - ${p.seasonLabel} ${p.clubName})')
        .join('\n');
    final shareText = '''
Futbol Arena • Lig Draft (${provider.seasonNumber}. Sezon)
Takım: ${team.name} (${team.overallTeamPower} OVR)
Hoca: ${team.manager?.name ?? "-"} • Diziliş: ${team.formation?.code ?? "-"}
Lig Sonucu: $rank / $totalTeams Takım • ${team.points} Puan (${team.won}G ${team.drawn}B ${team.lost}M)
İlk 11 Kadrom:
$squadLines
'''.trim();

    Clipboard.setData(ClipboardData(text: shareText));
    AppNotification.show(
      context,
      title: 'Kadro & Sezon Özeti Kopyalandı',
      message: 'İlk 11 kadron ve lig derecen panoya kopyalandı, istediğin yerde paylaşabilirsin!',
      type: AppNotificationType.success,
      icon: Icons.share_rounded,
    );
  }

  void _showTeamSquadSheet(BuildContext context, LeagueParticipant team) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0A2419),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${team.name} • ${team.overallTeamPower} OVR',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Hoca: ${team.manager?.name ?? ""} • Diziliş: ${team.formation?.code ?? ""}',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.gold),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInteractiveFormationPitch(
                  provider: null,
                  participant: team,
                  interactive: false,
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: team.squad.length,
                    itemBuilder: (_, i) {
                      final p = team.squad[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.5),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 36,
                              child: Text(
                                p.specificPosition,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.greenLight,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${p.name} (${p.seasonLabel} ${p.clubName})',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              '${p.rating} OVR',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActivePlayerBanner(String playerTitle, String stepLabel, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.55)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      stepLabel,
                      style: const TextStyle(
                        fontSize: 9.2,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '• $playerTitle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1.5),
                Text(
                  subtitle,
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
        ],
      ),
    );
  }

  Widget _buildPoolFilterChip({
    required LeagueDraftProvider provider,
    required LeaguePoolTheme theme,
    required String label,
  }) {
    final isSelected = provider.poolTheme == theme;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => provider.setPoolTheme(theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pitchGreen.withValues(alpha: 0.25)
              : AppColors.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.border,
            width: isSelected ? 1.3 : 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.public_rounded,
              size: 13,
              color: isSelected ? AppColors.gold : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatabaseBrowserSheet(BuildContext context) {
    final packs = LeagueDraftProvider.allEraClubPacks;
    final managers = LeagueDraftProvider.allManagers;
    final totalPlayers = packs.fold<int>(0, (sum, p) => sum + p.roster.length);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.84,
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF071B12),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Kadro & Lig Veritabanı (${packs.length} Tarihi Takım • ${managers.length} Hoca • $totalPlayers Futbolcu)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Süper Lig, Premier League, La Liga, Serie A, Bundesliga, Ligue 1, Güney Amerika ve Dünya Kupası efsane dönem kadroları:',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: packs.length,
                  itemBuilder: (_, idx) {
                    final pack = packs[idx];
                    final club = FootballDatabase().getClub(pack.clubId) ??
                        FootballDatabase().getAllClubs().first;
                    final starNames = pack.roster.map((e) => e.name).join(' • ');
                    return Container(
                      margin: const EdgeInsets.only(bottom: 7),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      child: Row(
                        children: [
                          ClubCrestWidget(club: club, size: 36),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withValues(alpha: 0.22),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        pack.seasonLabel,
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        pack.clubName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  pack.eraTitle,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.greenLight,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  starNames,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TacticalPitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Subtle horizontal grass stripes
    final stripePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;
    const stripeCount = 6;
    final stripeH = size.height / stripeCount;
    for (int i = 0; i < stripeCount; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * stripeH, size.width, stripeH),
        stripePaint,
      );
    }

    // Halfway line & center circle
    final midY = size.height * 0.52;
    canvas.drawLine(Offset(10, midY), Offset(size.width - 10, midY), paint);
    canvas.drawCircle(Offset(size.width / 2, midY), 34, paint);

    // Top penalty area (Attacking goal)
    final topBoxW = size.width * 0.48;
    canvas.drawRect(
      Rect.fromLTWH((size.width - topBoxW) / 2, 0, topBoxW, 40),
      paint,
    );

    // Bottom penalty area (GK box)
    canvas.drawRect(
      Rect.fromLTWH((size.width - topBoxW) / 2, size.height - 40, topBoxW, 40),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DraftRevealArena extends StatefulWidget {
  final LeagueDraftProvider provider;
  final EraClubPack pack;
  final List<EraPlayerCandidate> choices;
  final int selectedSlotIndex;
  final String selectedSlotLabel;

  const _DraftRevealArena({
    super.key,
    required this.provider,
    required this.pack,
    required this.choices,
    required this.selectedSlotIndex,
    required this.selectedSlotLabel,
  });

  @override
  State<_DraftRevealArena> createState() => _DraftRevealArenaState();
}

class _DraftRevealArenaState extends State<_DraftRevealArena> {
  final List<Timer> _timers = [];
  int _rouletteStep = 0;
  bool _clubLocked = false;
  int _openedBoxes = 0;

  late final List<EraClubPack> _rouletteSamples;

  @override
  void initState() {
    super.initState();
    final pool = widget.provider.activePoolPacks;
    _rouletteSamples = pool.isNotEmpty
        ? pool.take(6).toList()
        : [widget.pack];
    _startSequence();
  }

  void _startSequence() {
    // 1. Quick club roulette spin ticks
    for (int i = 1; i <= 3; i++) {
      _timers.add(
        Timer(Duration(milliseconds: i * 95), () {
          if (!mounted) return;
          setState(() => _rouletteStep = i);
        }),
      );
    }

    // 2. Lock spun club
    _timers.add(
      Timer(const Duration(milliseconds: 360), () {
        if (!mounted) return;
        HapticFeedback.selectionClick();
        setState(() => _clubLocked = true);
      }),
    );

    // 3. Sequentially pop open the 3 mystery boxes (pıt - pıt - pıt)
    const boxDelays = [500, 720, 940];
    for (int i = 0; i < boxDelays.length; i++) {
      _timers.add(
        Timer(Duration(milliseconds: boxDelays[i]), () {
          if (!mounted) return;
          HapticFeedback.selectionClick();
          setState(() => _openedBoxes = i + 1);
        }),
      );
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayedPack = _clubLocked
        ? widget.pack
        : _rouletteSamples[_rouletteStep % _rouletteSamples.length];
    final displayedClub = FootballDatabase().getClub(displayedPack.clubId) ??
        FootballDatabase().getAllClubs().first;
    final boxCount = widget.choices.length.clamp(0, 3);
    final allBoxesReady = _openedBoxes >= boxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Animated Club Roulette Header
        AnimatedScale(
          scale: _clubLocked ? 1.0 : 0.97,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF15452F).withValues(alpha: 0.94),
                  const Color(0xFF081F15).withValues(alpha: 0.96),
                ],
              ),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: _clubLocked
                    ? AppColors.gold
                    : AppColors.pitchGreen.withValues(alpha: 0.7),
                width: _clubLocked ? 1.3 : 1.0,
              ),
            ),
            child: Row(
              children: [
                ClubCrestWidget(club: displayedClub, size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: _clubLocked
                                  ? AppColors.gold
                                  : AppColors.pitchGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _clubLocked
                                  ? '${displayedPack.seasonLabel} KULÜBÜ'
                                  : 'KULÜP ÇEKİLİYOR...',
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                color: _clubLocked
                                    ? const Color(0xFF06160F)
                                    : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              displayedPack.eraTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.greenLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayedPack.clubName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_clubLocked && widget.provider.remainingRerolls > 0)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: widget.provider.rerollCurrentClubPack,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.gold, width: 0.9),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.refresh_rounded,
                            size: 12,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Değiştir (${widget.provider.remainingRerolls})',
                            style: const TextStyle(
                              fontSize: 9.5,
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
          ),
        ),

        const SizedBox(height: 10),

        Text(
          allBoxesReady
              ? '3 KUTUDAN BİRİNİ SEÇ VE KADROYA EKLE:'
              : 'KULÜP KUTULARI SIRAYLA AÇILIYOR...',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: AppColors.greenLight,
          ),
        ),
        const SizedBox(height: 8),

        // 3 Sequentially Revealed Mystery Player Boxes
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(boxCount, (i) {
            final player = widget.choices[i];
            final isOpened = i < _openedBoxes;
            final isExactMatch =
                player.role == widget.provider.currentNeededRole;
            final isAnyOpenMatch =
                isExactMatch || widget.provider.hasOpenSlotForRole(player.role);

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == boxCount - 1 ? 0 : 7),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: !isOpened
                      ? Container(
                          key: ValueKey('closed_$i'),
                          height: 144,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.surface.withValues(alpha: 0.94),
                                AppColors.darkGreen.withValues(alpha: 0.55),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.45),
                              width: 1.1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                color: AppColors.gold,
                                size: 28,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${i + 1}. KUTU',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Açılıyor...',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          key: ValueKey('open_${player.id}_$i'),
                          borderRadius: BorderRadius.circular(14),
                          onTap: allBoxesReady
                              ? () => widget.provider.selectPlayerForSquad(
                                    player,
                                    targetSlotIndex: widget.selectedSlotIndex,
                                  )
                              : null,
                          child: Container(
                            height: 144,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF103324).withValues(alpha: 0.96),
                                  const Color(0xFF071A12).withValues(alpha: 0.96),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isExactMatch
                                    ? AppColors.gold
                                    : (isAnyOpenMatch
                                        ? AppColors.pitchGreen
                                        : Colors.orangeAccent.withValues(alpha: 0.8)),
                                width: isExactMatch ? 1.5 : 1.1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isAnyOpenMatch
                                            ? AppColors.pitchGreen.withValues(alpha: 0.25)
                                            : Colors.orangeAccent.withValues(alpha: 0.22),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        player.specificPosition,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: isAnyOpenMatch
                                              ? AppColors.greenLight
                                              : Colors.orangeAccent,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${player.rating}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  player.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.15,
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isExactMatch
                                        ? AppColors.gold.withValues(alpha: 0.22)
                                        : (isAnyOpenMatch
                                            ? AppColors.pitchGreen.withValues(alpha: 0.22)
                                            : Colors.orangeAccent.withValues(alpha: 0.20)),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    isExactMatch
                                        ? 'TAM MEVKİ'
                                        : (isAnyOpenMatch
                                            ? 'KADROYA AL'
                                            : 'ZORUNLU ${widget.selectedSlotLabel}'),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                      color: isExactMatch
                                          ? AppColors.gold
                                          : (isAnyOpenMatch
                                              ? AppColors.greenLight
                                              : Colors.orangeAccent),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
