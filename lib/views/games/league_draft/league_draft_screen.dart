import 'dart:async';
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
  bool _isFastStream = false;

  @override
  void dispose() {
    _stopLiveStream();
    super.dispose();
  }

  void _stopLiveStream() {
    _liveStreamTimer?.cancel();
    _liveStreamTimer = null;
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

    final latest = provider.latestSimulatedFixture;
    bool isHumanMatch = false;
    if (latest != null &&
        latest.homeIndex < provider.participants.length &&
        latest.awayIndex < provider.participants.length) {
      final h = provider.participants[latest.homeIndex];
      final a = provider.participants[latest.awayIndex];
      isHumanMatch = !h.isBot || !a.isBot;
    }

    // In 18/20-team leagues (306-380 matches), let AI matches flow briskly
    // and pause slightly longer on human matches so the user clearly reads their score!
    final delayMs = isHumanMatch
        ? (_isFastStream ? 210 : 440)
        : (_isFastStream ? 34 : 80);

    _liveStreamTimer = Timer(Duration(milliseconds: delayMs), () {
      if (!mounted ||
          provider.phase != LeagueDraftPhase.leagueSimulation ||
          provider.isAllFixturesPlayed) {
        _stopLiveStream();
        if (mounted) setState(() {});
        return;
      }
      provider.simulateNextSingleFixture();
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

    // Immediately simulate 1 match so the user sees instant response
    provider.simulateNextSingleFixture();
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
      body: StadiumBackground(
        showLiveMatch: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _buildPhaseContent(context, provider),
        ),
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
        return _buildLeagueSimulationPhase(context, provider);
    }
  }

  // ===========================================================================
  // PHASE 0: ONLINE LEAGUE LOBBY (INVITE UP TO LEAGUE SIZE, REST ARE AI BOTS)
  // ===========================================================================
  Widget _buildSetupPhase(BuildContext context, LeagueDraftProvider provider) {
    const capacities = [18, 20];
    final totalWeeks = (provider.leagueCapacity - 1) * 2;

    return SingleChildScrollView(
      key: const ValueKey('setup'),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Online Lobby Room Header Card (Room Code + Invite + Join by Code)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF14422D).withValues(alpha: 0.94),
                  const Color(0xFF071B12).withValues(alpha: 0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.75), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.hub_rounded, color: AppColors.gold, size: 22),
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
                                  color: AppColors.pitchGreen.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  'ONLINE LİG LOBİSİ • SEZON #${provider.seasonNumber} (${provider.leagueCapacity} TAKIM)',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.greenLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Oda Davet Kodu: #${provider.lobbyRoomCode}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Gerçek futbol ligi formatında (${provider.leagueCapacity} Takım • $totalWeeks Hafta) istediğin kadar arkadaş davet edebilirsin; davet edilmeyen tüm koltuklar otomatik olarak Yapay Zeka (AI Bot) kulüplerle tamamlanır!',
                  style: const TextStyle(
                    fontSize: 11.2,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: const BorderSide(color: AppColors.gold),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: provider.lobbyRoomCode));
                          AppNotification.show(
                            context,
                            title: 'Davet Kodu Kopyalandı (#${provider.lobbyRoomCode})',
                            message: 'Kodu arkadaşlarına gönder veya "+ Arkadaş Davet Et" ile lobiye ekle!',
                            type: AppNotificationType.highlight,
                            icon: Icons.copy_rounded,
                          );
                        },
                        icon: const Icon(Icons.share_rounded, size: 15),
                        label: const Text(
                          'Davet Kodu Paylaş',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.greenLight,
                          side: BorderSide(color: AppColors.pitchGreen.withValues(alpha: 0.7)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () => _showJoinLobbyByCodeDialog(context, provider),
                        icon: const Icon(Icons.login_rounded, size: 15),
                        label: const Text(
                          'Başka Lobiye Katıl',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Real Football League Format & Team Count Selector (18 Takım Süper Lig/Bundesliga, 20 Takım PL/LaLiga/SerieA)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '1. GERÇEK FUTBOL LİGİ TAKIM SAYISI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: AppColors.greenLight,
                ),
              ),
              Text(
                '${provider.invitedHumanCount} Oyuncu + ${provider.botFillCount} AI Kulüp',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: capacities.map((cap) {
              final isSelected = provider.leagueCapacity == cap;
              final subtitle = cap == 18
                  ? '34 Hafta • Süper Lig / Bundesliga'
                  : '38 Hafta • Premier League / La Liga / Serie A';
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: cap == capacities.last ? 0 : 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(11),
                    onTap: () => provider.setLeagueCapacity(cap),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.pitchGreen.withValues(alpha: 0.28)
                            : AppColors.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: isSelected ? AppColors.gold : AppColors.border,
                          width: isSelected ? 1.4 : 0.8,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$cap Takımlı Lig',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.2,
                              color: isSelected ? AppColors.gold : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          // 3. Pool Selector & Database Browser Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '2. LİG & TARİHİ SEZON HAVUZU SEÇİMİ',
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
                    'Veritabanını İncele (${LeagueDraftProvider.allEraClubPacks.length} Takım/Yıl • ${LeagueDraftProvider.allManagers.length} Hoca) ›',
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
                label: 'Dünya Süper Ligi • 20 Takım (${LeagueDraftProvider.allEraClubPacks.length} Paket)',
              ),
              _buildPoolFilterChip(
                provider: provider,
                theme: LeaguePoolTheme.superLigHistory,
                label: 'Türkiye Süper Lig • 18 Takım (14 Paket)',
              ),
              _buildPoolFilterChip(
                provider: provider,
                theme: LeaguePoolTheme.europeanGiants,
                label: 'Avrupa Devler Ligi • 20 Takım (40 Paket)',
              ),
              _buildPoolFilterChip(
                provider: provider,
                theme: LeaguePoolTheme.worldCupLegends,
                label: 'Milli Takım & Süper Lig • 18 Takım',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Quick Start Button right above the 18/20 team list so the user can start immediately
          CustomButton(
            text: '${provider.seasonNumber}. Sezon Kadro Seçimini Başlat (${provider.leagueCapacity} Takım • $totalWeeks Hafta)',
            icon: Icons.play_arrow_rounded,
            backgroundColor: AppColors.pitchGreen,
            textColor: Colors.white,
            onPressed: provider.startDraftFromLobby,
          ),
          const SizedBox(height: 15),

          // 4. Lobby Slots (Invited Friends + Auto AI Bot Fillers up to 18 or 20 Teams)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '3. LİG TAKIMLARI (${provider.invitedHumanCount} OYUNCU • ${provider.botFillCount} AI KULÜP)',
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

          ...List.generate(provider.lobbySlots.length, (index) {
            final slot = provider.lobbySlots[index];
            final isHuman = !slot.isBot;
            return Container(
              margin: const EdgeInsets.only(bottom: 7),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: isHuman
                    ? const Color(0xFF103826).withValues(alpha: 0.92)
                    : AppColors.surface.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isHuman
                      ? (slot.isHost ? AppColors.gold : AppColors.pitchGreen)
                      : AppColors.border,
                  width: isHuman ? 1.2 : 0.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isHuman
                          ? AppColors.pitchGreen.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isHuman
                          ? (slot.isHost ? Icons.stars_rounded : Icons.person_rounded)
                          : Icons.smart_toy_outlined,
                      size: 17,
                      color: isHuman
                          ? (slot.isHost ? AppColors.gold : AppColors.greenLight)
                          : AppColors.textSecondary,
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
                                color: isHuman
                                    ? (slot.isHost
                                        ? AppColors.gold.withValues(alpha: 0.22)
                                        : AppColors.pitchGreen.withValues(alpha: 0.24))
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                slot.isHost
                                    ? 'ODA KURUCU (SEN)'
                                    : (isHuman ? 'DAVETLİ ARKADAŞ' : 'AI BOT (OTOMATİK)'),
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  color: isHuman
                                      ? (slot.isHost ? AppColors.gold : AppColors.greenLight)
                                      : AppColors.textSecondary,
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
                          '${index + 1}. ${slot.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isHuman ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isHuman) ...[
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'İsmi Düzenle',
                      onPressed: () => _showRenameSlotDialog(context, provider, index, slot.name),
                      icon: const Icon(Icons.edit_outlined, size: 17, color: AppColors.greenLight),
                    ),
                    if (!slot.isHost)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: 'Koltuğu AI Bot Yap',
                        onPressed: () => provider.convertSlotToBot(index),
                        icon: const Icon(Icons.person_remove_outlined, size: 17, color: Colors.redAccent),
                      ),
                  ] else ...[
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _showInviteFriendDialog(context, provider, targetSlotIndex: index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_add_alt_rounded, size: 12, color: AppColors.gold),
                            SizedBox(width: 4),
                            Text(
                              'Davet Et',
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
                  ],
                ],
              ),
            );
          }),

          const SizedBox(height: 14),

          CustomButton(
            text: '${provider.seasonNumber}. Sezon Kadro Seçimini Başlat (${provider.leagueCapacity} Takım)',
            icon: Icons.play_arrow_rounded,
            backgroundColor: AppColors.pitchGreen,
            textColor: Colors.white,
            onPressed: provider.startDraftFromLobby,
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
  // PHASE 3: PICK 11 PLAYERS BY RANDOM ERA / CLUB SPIN
  // ===========================================================================
  Widget _buildPickPlayersPhase(BuildContext context, LeagueDraftProvider provider) {
    final active = provider.activeParticipant;
    final pack = provider.currentSpunClubPack;
    if (pack == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      key: ValueKey('pick_${active.id}_${active.squad.length}'),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Progress & Fast-Fill Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${active.name} • ${active.formation?.code ?? "4-3-3"} (${active.manager?.name ?? ""})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Oyuncu Seçimi: ${provider.currentSlotIndex + 1} / 11 • Mevki: ${provider.currentNeededRoleLabel}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: provider.autoCompleteCurrentParticipantSquad,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bolt_rounded, size: 13, color: AppColors.gold),
                        SizedBox(width: 3),
                        Text(
                          'Hızlı Tamamla',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
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

          // Spun Historical Club + Year Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF15452F).withValues(alpha: 0.94),
                  const Color(0xFF081F15).withValues(alpha: 0.96),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold, width: 1.3),
            ),
            child: Row(
              children: [
                ClubCrestWidget(
                  club: FootballDatabase().getClub(pack.clubId) ??
                      FootballDatabase().getAllClubs().first,
                  size: 54,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '${pack.seasonLabel} SEZONU',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF06160F),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Flexible(
                            child: Text(
                              'GELEN TAKIM & YIL',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.greenLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pack.seasonLabel} ${pack.clubName}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        pack.eraTitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (provider.remainingRerolls > 0) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: provider.rerollCurrentClubPack,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.gold, width: 0.9),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh_rounded, size: 13, color: AppColors.gold),
                                const SizedBox(width: 4),
                                Text(
                                  'Başka Takım/Yıl Çek (Kalan Hak: ${provider.remainingRerolls})',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.gold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          const Text(
            'BU KADRODAN 1 OYUNCU SEÇ VE TAKIMINA EKLE:',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
              color: AppColors.greenLight,
            ),
          ),
          const SizedBox(height: 6),

          // 3 Player Candidates from that Historical Club & Year
          ...provider.currentPlayerChoices.map((player) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () => provider.selectPlayerForSquad(player),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: AppColors.borderGreen.withValues(alpha: 0.65),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.pitchGreen.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.pitchGreen),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${player.rating}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.gold,
                              ),
                            ),
                            Text(
                              player.specificPosition,
                              style: const TextStyle(
                                fontSize: 8,
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
                            Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${player.seasonLabel} ${player.clubName} • ${player.specificPosition}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.pitchGreen.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Kadrona Kat',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.greenLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 10),

          // Live Drafted Squad Preview
          if (active.squad.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'KURULAN İLK 11 (${active.squad.length}/11)',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                      Text(
                        'Takım Gücü: ${active.overallTeamPower} OVR',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.greenLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: active.squad.map((p) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.45)),
                        ),
                        child: Text(
                          '${p.specificPosition}: ${p.name} (${p.rating})',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
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
  // PHASE 4: LIVE FLOWING LEAGUE SIMULATION & RETURN TO LOBBY FOR NEXT SEASON
  // ===========================================================================
  Widget _buildLeagueSimulationPhase(BuildContext context, LeagueDraftProvider provider) {
    final table = provider.standings;
    final champion = provider.champion;
    final latestMatch = provider.latestSimulatedFixture;
    final isStreaming = _liveStreamTimer != null;
    final totalMatches = provider.fixtures.isEmpty ? 1 : provider.fixtures.length;
    final playedCount = provider.playedFixturesCount;
    final progress = (playedCount / totalMatches).clamp(0.0, 1.0);
    final recentPlayed = provider.playedFixturesReverse.take(6).toList();

    // Show matches of the latest played matchday (or matchday 1 if none played yet)
    final playedDays = provider.fixtures.where((f) => f.isPlayed).map((f) => f.matchday).toList();
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
          // 1. LIVE MATCH STREAM TICKER (ÖNÜNDEN AKARAK GEÇEN MAÇ SONUÇLARI EKRANI)
          if (!provider.isAllFixturesPlayed)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF14452F).withValues(alpha: 0.95),
                    const Color(0xFF071B12).withValues(alpha: 0.96),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isStreaming ? AppColors.gold : AppColors.pitchGreen,
                  width: 1.4,
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
                            isStreaming
                                ? 'CANLI MAÇ AKIŞI • HAFTA ${latestMatch?.matchday ?? provider.currentMatchday}/${provider.totalMatchdays}'
                                : 'SİMÜLASYON MERKEZİ • HAFTA ${provider.currentMatchday}/${provider.totalMatchdays}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$playedCount / $totalMatches Maç',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.greenLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.black.withValues(alpha: 0.35),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Animated Live Match Scoreboard Passing in Front of the User
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: latestMatch == null
                        ? Container(
                            key: const ValueKey('waiting_kickoff'),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.play_circle_fill_rounded, color: AppColors.gold, size: 32),
                                SizedBox(height: 6),
                                Text(
                                  'Kadrolar ve Fikstür Hazır! Başlat\'a dokun, maçların sonuçları önünden canlı akarak geçsin!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildFlowingMatchHighlightCard(provider, latestMatch),
                  ),

                  const SizedBox(height: 12),

                  // Stream Controls: Canlı Akışı Başlat / Duraklat / Hız / Tek Hafta / Tümünü Bitir
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isStreaming ? AppColors.gold : AppColors.pitchGreen,
                            foregroundColor: isStreaming ? const Color(0xFF06160F) : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          onPressed: () => _toggleLiveMatchStream(provider),
                          icon: Icon(
                            isStreaming ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 18,
                          ),
                          label: Text(
                            isStreaming
                                ? 'Akışı Duraklat'
                                : (playedCount == 0 ? 'Maçları Canlı Akıt' : 'Akışa Devam Et'),
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      InkWell(
                        borderRadius: BorderRadius.circular(11),
                        onTap: () => _toggleLiveMatchStream(provider, fastMode: !_isFastStream),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
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
                          provider.simulateNextMatchday();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 11),
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
                            padding: const EdgeInsets.symmetric(vertical: 11),
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
                            'Sonuca Geç',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // 2. SEASON CHAMPION & CONTINUE TO LOBBY CARD (WHEN ALL MATCHES FINISH)
          if (champion != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gold.withValues(alpha: 0.28),
                    const Color(0xFF0E2D20).withValues(alpha: 0.96),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.gold, width: 1.6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 36),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${provider.seasonNumber}. SEZON SONUCU • LİG ŞAMPİYONU!',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              champion.name,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Hoca: ${champion.manager?.name ?? ""} (${champion.formation?.code ?? ""}) • ${champion.points} Puan (${champion.goalsFor} Gol)',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.greenLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (provider.topScorers.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  'Gol Kralı: ${provider.topScorers.first.key} (${provider.topScorers.first.value} Gol)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.gold,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomButton(
                    text: 'Devam Et • Lobiye Dön (${provider.seasonNumber + 1}. Sezonu Oyna)',
                    icon: Icons.meeting_room_rounded,
                    backgroundColor: AppColors.pitchGreen,
                    textColor: Colors.white,
                    onPressed: () {
                      _stopLiveStream();
                      provider.continueToLobbyForNextSeason();
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
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
                            provider.replaySeasonWithSameSquads();
                            _toggleLiveMatchStream(provider);
                          },
                          icon: const Icon(Icons.replay_rounded, size: 16),
                          label: const Text(
                            'Aynı Kadrolarla Tekrar Akıt',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // 3. RECENT FLOWING RESULTS RIBBON (ÖNÜNDEN GEÇEN SON MAÇLAR ŞERİDİ)
          if (recentPlayed.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.34),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt_rounded, size: 14, color: AppColors.gold),
                      SizedBox(width: 4),
                      Text(
                        'ÖNÜNDEN GEÇEN SON MAÇ SONUÇLARI (CANLI AKIŞ)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.gold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: recentPlayed.map((m) {
                        final h = provider.participants[m.homeIndex];
                        final a = provider.participants[m.awayIndex];
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.45)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'H${m.matchday}: ',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.gold,
                                ),
                              ),
                              Text(
                                '${h.name} ${m.homeGoals}-${m.awayGoals} ${a.name}',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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

    return Container(
      key: ValueKey('flow_${match.matchday}_${match.homeIndex}_${match.awayIndex}'),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.65), width: 1.1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${match.matchday}. HAFTA MAÇ SONUCU (90\' BİTTİ)',
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: AppColors.gold,
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
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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
                  color: AppColors.pitchGreen.withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.gold, width: 1.1),
                ),
                child: Text(
                  '${match.homeGoals} - ${match.awayGoals}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.gold,
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
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
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
  }

  void _showTeamSquadSheet(BuildContext context, LeagueParticipant team) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A2419),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                'Hoca: ${team.manager?.name ?? ""} (${team.manager?.styleTitle ?? ""}) • Diziliş: ${team.formation?.code ?? ""}',
                style: const TextStyle(fontSize: 11.5, color: AppColors.gold),
              ),
              const Divider(height: 18, color: AppColors.border),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: team.squad.length,
                  itemBuilder: (_, i) {
                    final p = team.squad[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 34,
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
                                fontSize: 12,
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
        );
      },
    );
  }

  Widget _buildActivePlayerBanner(String playerTitle, String stepLabel, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepLabel,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            playerTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
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
