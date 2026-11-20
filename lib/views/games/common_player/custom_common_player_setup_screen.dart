import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/text_normalizer.dart';
import '../../../../data/models/club_model.dart';
import '../../../../data/models/play_mode_model.dart';
import '../../../../data/repositories/football_database.dart';
import '../../widgets/club_crest_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stadium_background.dart';
import '../online_lobby/matchmaking_screen.dart';

class CustomCommonPlayerSetupScreen extends StatefulWidget {
  final GameDifficulty difficulty;

  const CustomCommonPlayerSetupScreen({
    super.key,
    this.difficulty = GameDifficulty.medium,
  });

  @override
  State<CustomCommonPlayerSetupScreen> createState() =>
      _CustomCommonPlayerSetupScreenState();
}

class _CustomCommonPlayerSetupScreenState
    extends State<CustomCommonPlayerSetupScreen> {
  final FootballDatabase _db = FootballDatabase();
  final TextEditingController _teamAController = TextEditingController();
  final TextEditingController _teamBController = TextEditingController();

  late final List<ClubModel> _allEntities;
  ClubModel? _teamA;
  ClubModel? _teamB;
  int _activeField = 0; // 0: Team A, 1: Team B
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _allEntities = [
      ..._db.getAllClubs(),
      ..._db.getAllNationalTeams(),
    ];
    _teamA = _db.getClub('galatasaray') ?? _allEntities.first;
    _teamB = _db.getClub('real_madrid') ?? _allEntities[1];
    _teamAController.text = _teamA?.name ?? '';
    _teamBController.text = _teamB?.name ?? '';
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    super.dispose();
  }

  List<ClubModel> get _filteredCandidates {
    final q = TextNormalizer.normalize(_searchQuery);
    final baseList = _activeField == 0
        ? _allEntities.where((e) => !e.isNationalTeam).toList()
        : _allEntities.where((e) => e.id != _teamA?.id).toList();

    final matches = q.isEmpty
        ? baseList
        : baseList.where((e) {
            final cleanName = TextNormalizer.normalize(e.name);
            final cleanShort = TextNormalizer.normalize(e.shortName);
            final cleanCountry = TextNormalizer.normalize(e.country);
            return cleanName.contains(q) ||
                cleanShort.contains(q) ||
                cleanCountry.contains(q);
          }).toList();

    // When picking Team B, prioritize entities that actually share mutual players with Team A
    if (_activeField == 1 && _teamA != null) {
      matches.sort((a, b) {
        final aCount = _db.getMutualPlayers(_teamA!.id, a.id).length;
        final bCount = _db.getMutualPlayers(_teamA!.id, b.id).length;
        return bCount.compareTo(aCount);
      });
    }
    return matches.take(24).toList();
  }

  int get _mutualCount {
    if (_teamA == null || _teamB == null || _teamA!.id == _teamB!.id) {
      return 0;
    }
    return _db.getMutualPlayers(_teamA!.id, _teamB!.id).length;
  }

  void _selectEntity(ClubModel club) {
    setState(() {
      if (_activeField == 0) {
        _teamA = club;
        _teamAController.text = club.name;
        _activeField = 1;
        _searchQuery = '';
      } else {
        _teamB = club;
        _teamBController.text = club.name;
        _searchQuery = '';
      }
    });
  }

  void _startMatchmaking() {
    if (_teamA == null || _teamB == null || _mutualCount <= 0) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => MatchmakingScreen(
          targetGame: GameTargetType.commonPlayer,
          difficulty: widget.difficulty,
          customClubA: _teamA,
          customClubB: _teamB,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mutual = _mutualCount;
    final candidates = _filteredCandidates;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('3-2-1 Özel Online Eşleşme'),
      ),
      body: StadiumBackground(
        showFieldLines: true,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.45),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: AppColors.gold,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'İstediğin iki takımı yaz veya seç; online/AI rakiple bu takımların ortak oyuncularını bul!',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Interactive Team A & Team B Picker Inputs
                    Row(
                      children: [
                        Expanded(
                          child: _buildTeamSlotBox(
                            title: '1. TAKIM',
                            club: _teamA,
                            isActive: _activeField == 0,
                            onTap: () => setState(() {
                              _activeField = 0;
                              _searchQuery = '';
                            }),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '×',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: _buildTeamSlotBox(
                            title: '2. TAKIM / ÜLKE',
                            club: _teamB,
                            isActive: _activeField == 1,
                            onTap: () => setState(() {
                              _activeField = 1;
                              _searchQuery = '';
                            }),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Mutual player validation banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: (mutual > 0 ? AppColors.pitchGreen : AppColors.error)
                            .withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: mutual > 0
                              ? AppColors.pitchGreen
                              : AppColors.error,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            mutual > 0
                                ? Icons.check_circle_outline
                                : Icons.warning_amber_rounded,
                            size: 16,
                            color: mutual > 0
                                ? AppColors.greenLight
                                : Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              mutual > 0
                                  ? '${_teamA?.name} × ${_teamB?.name}: Veritabanında $mutual ortak oyuncu var!'
                                  : 'Bu iki takım arasında veritabanımızda ortak oyuncu bulunamadı. Farklı bir takım seç.',
                              style: TextStyle(
                                fontSize: 11.2,
                                fontWeight: FontWeight.w700,
                                color: mutual > 0
                                    ? AppColors.greenLight
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      _activeField == 0
                          ? '1. TAKIMI YAZ VEYA SEÇ:'
                          : '2. TAKIMI (VEYA ÜLKEYİ) YAZ VEYA SEÇ:',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 7),

                    // Search bar for selecting Team A or Team B
                    TextField(
                      key: ValueKey('team_search_$_activeField'),
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: _activeField == 0
                            ? 'Kulüp adı yaz (Örn: Galatasaray, Milan, Arsenal)...'
                            : 'Kulüp veya Ülke yaz (Örn: Fenerbahçe, Brezilya)...',
                        hintStyle: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.gold,
                          size: 18,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Matching club / country chips
                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: candidates.map((club) {
                        final isPicked = (_activeField == 0 && _teamA?.id == club.id) ||
                            (_activeField == 1 && _teamB?.id == club.id);
                        final sharedCount = _activeField == 1 && _teamA != null
                            ? _db.getMutualPlayers(_teamA!.id, club.id).length
                            : null;
                        final disabledPair = sharedCount != null && sharedCount == 0;

                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => _selectEntity(club),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isPicked
                                  ? AppColors.pitchGreen.withValues(alpha: 0.30)
                                  : (disabledPair
                                      ? AppColors.surface.withValues(alpha: 0.45)
                                      : AppColors.surface.withValues(alpha: 0.92)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isPicked
                                    ? AppColors.gold
                                    : (sharedCount != null && sharedCount > 0
                                        ? AppColors.pitchGreen.withValues(alpha: 0.65)
                                        : AppColors.border),
                                width: isPicked ? 1.3 : 0.9,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClubCrestWidget(club: club, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  club.name,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isPicked
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: disabledPair
                                        ? AppColors.textMuted
                                        : Colors.white,
                                  ),
                                ),
                                if (sharedCount != null && sharedCount > 0) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4.5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '$sharedCount',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Start Matchmaking Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: CustomButton(
                text: 'Online Eşleşme Başlat (${widget.difficulty.label})',
                icon: Icons.public_rounded,
                backgroundColor: AppColors.pitchGreen,
                onPressed: mutual > 0 ? _startMatchmaking : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSlotBox({
    required String title,
    required ClubModel? club,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF123826).withValues(alpha: 0.94)
              : AppColors.surface.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isActive ? AppColors.gold : AppColors.border,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: isActive ? AppColors.gold : AppColors.textMuted,
                letterSpacing: 0.7,
              ),
            ),
            const SizedBox(height: 6),
            if (club != null) ...[
              ClubCrestWidget(club: club, size: 32),
              const SizedBox(height: 5),
              Text(
                club.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ] else
              const Text(
                'Seç...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}
