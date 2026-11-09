import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/league_draft_model.dart';
import '../../../data/repositories/football_database.dart';
import '../../../providers/league_draft_provider.dart';
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
  bool _isSoloMode = false;
  final List<TextEditingController> _controllers = [
    TextEditingController(text: '1. Menajer'),
    TextEditingController(text: '2. Menajer'),
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addFriendField() {
    setState(() {
      _controllers.add(
        TextEditingController(text: '${_controllers.length + 1}. Menajer'),
      );
    });
  }

  void _removeFriendField(int index) {
    if (_controllers.length <= 2) return;
    setState(() {
      final removed = _controllers.removeAt(index);
      removed.dispose();
    });
  }

  void _startDraft(LeagueDraftProvider provider) {
    final names = _isSoloMode
        ? [_controllers.first.text]
        : _controllers.map((c) => c.text).toList();
    provider.startDraft(
      playerNames: names,
      isSoloMode: _isSoloMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeagueDraftProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Kadro Kur & Lig Simüle Et',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: StadiumBackground(
        showLiveMatch: false,
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _buildPhaseContent(context, provider),
          ),
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
  // PHASE 0: SETUP (SOLO OR UNLIMITED FRIENDS)
  // ===========================================================================
  Widget _buildSetupPhase(BuildContext context, LeagueDraftProvider provider) {
    return SingleChildScrollView(
      key: const ValueKey('setup'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF123C29).withValues(alpha: 0.92),
                  const Color(0xFF071B12).withValues(alpha: 0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.pitchGreen.withValues(alpha: 0.6)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Efsane Kadronu Kur ve Ligi Simüle Et',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '1. Rastgele gelen 3 efsane hocadan 1\'ini seç.\n'
                  '2. Rastgele gelen 3 dizilişten 1\'ini seç.\n'
                  '3. Her mevkide rastgele gelen Yıl + Takım paketinden (Örn: 2004-05 Milan, 1999-00 Galatasaray) 1 oyuncu seçerek 11\'ini tamamla ve çift devreli ligi simüle et!',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Mode Selector: Arkadaşlarla vs Tek Başına
          Row(
            children: [
              Expanded(
                child: _buildModeToggleCard(
                  title: 'Arkadaşlarla Lig',
                  subtitle: 'İstediğin kadar arkadaş ekle',
                  icon: Icons.groups_rounded,
                  isSelected: !_isSoloMode,
                  onTap: () => setState(() => _isSoloMode = false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildModeToggleCard(
                  title: 'Tek Başına (AI Lig)',
                  subtitle: '3 Bot Menajere karşı',
                  icon: Icons.smart_toy_outlined,
                  isSelected: _isSoloMode,
                  onTap: () => setState(() => _isSoloMode = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Pool Selector & Database Browser Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TAKIM & SEZON HAVUZU SEÇİMİ',
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
                label: 'Tüm Dünya & Tarih (${LeagueDraftProvider.allEraClubPacks.length} Paket)',
              ),
              _buildPoolFilterChip(
                provider: provider,
                theme: LeaguePoolTheme.superLigHistory,
                label: 'Süper Lig Tarihi (14 Paket)',
              ),
              _buildPoolFilterChip(
                provider: provider,
                theme: LeaguePoolTheme.europeanGiants,
                label: 'Avrupa Devleri (40 Paket)',
              ),
              _buildPoolFilterChip(
                provider: provider,
                theme: LeaguePoolTheme.worldCupLegends,
                label: 'Milli Takım & Süper Lig Efsaneleri',
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _isSoloMode
                    ? 'TAKIM / MENAJER ADIN'
                    : 'KATILAN ARKADAŞLAR (${_controllers.length} KİŞİ)',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: AppColors.greenLight,
                ),
              ),
              if (!_isSoloMode)
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _addFriendField,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_add_alt_1_rounded, size: 13, color: AppColors.gold),
                        SizedBox(width: 4),
                        Text(
                          '+ Arkadaş Ekle',
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

          if (_isSoloMode)
            TextField(
              controller: _controllers.first,
              style: const TextStyle(fontSize: 13.5, color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Kulüp veya Menajer Adın',
                prefixIcon: Icon(Icons.shield_outlined, color: AppColors.gold, size: 18),
              ),
            )
          else
            ...List.generate(_controllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controllers[index],
                        style: const TextStyle(fontSize: 13, color: Colors.white),
                        decoration: InputDecoration(
                          labelText: '${index + 1}. Arkadaş / Takım Adı',
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.greenLight,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    if (_controllers.length > 2) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () => _removeFriendField(index),
                        icon: const Icon(
                          Icons.remove_circle_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

          const SizedBox(height: 16),

          CustomButton(
            text: 'Kadro Seçimine Başla (Hoca • Diziliş • 11)',
            icon: Icons.play_arrow_rounded,
            backgroundColor: AppColors.pitchGreen,
            textColor: Colors.white,
            onPressed: () => _startDraft(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildModeToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pitchGreen.withValues(alpha: 0.24)
              : AppColors.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.gold : AppColors.border,
            width: isSelected ? 1.4 : 0.9,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.gold : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
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
  // PHASE 4: FULL LEAGUE SIMULATION (STANDINGS, FIXTURES & TOP SCORERS)
  // ===========================================================================
  Widget _buildLeagueSimulationPhase(BuildContext context, LeagueDraftProvider provider) {
    final table = provider.standings;
    final champion = provider.isAllFixturesPlayed && table.isNotEmpty ? table.first : null;

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
          // Champion Banner when season finishes
          if (champion != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.gold.withValues(alpha: 0.25),
                    const Color(0xFF0E2D20).withValues(alpha: 0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SEZON TAMAMLANDI • LİG ŞAMPİYONU!',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: AppColors.gold,
                          ),
                        ),
                        Text(
                          champion.name,
                          style: const TextStyle(
                            fontSize: 18,
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Simulation Action Buttons
          if (!provider.isAllFixturesPlayed)
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pitchGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: provider.simulateNextMatchday,
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: Text(
                      '${provider.currentMatchday}. Haftayı Simüle Et',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: const BorderSide(color: AppColors.gold),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: provider.simulateAllRemainingMatchdays,
                    icon: const Icon(Icons.fast_forward_rounded, size: 16),
                    label: const Text(
                      'Tüm Sezon',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.pitchGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: provider.replaySeasonWithSameSquads,
                    icon: const Icon(Icons.replay_rounded, size: 17),
                    label: const Text(
                      'Aynı Kadrolarla Rövanş',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: const BorderSide(color: AppColors.gold),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _startDraft(provider),
                    icon: const Icon(Icons.shuffle_rounded, size: 17),
                    label: const Text(
                      'Yeni Kadrolar Kur',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12),

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
                  return InkWell(
                    onTap: () => _showTeamSquadSheet(context, team),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isLeader
                                  ? AppColors.gold.withValues(alpha: 0.22)
                                  : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: isLeader ? AppColors.gold : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  team.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: isLeader ? AppColors.gold : Colors.white,
                                  ),
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
