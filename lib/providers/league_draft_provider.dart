import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/models/league_draft_model.dart';

enum LeagueDraftPhase {
  setup,
  pickManager,
  pickFormation,
  pickPlayers,
  nextPlayerHandoff,
  leagueSimulation,
}

class LeagueDraftProvider extends ChangeNotifier {
  final Random _rng = Random();

  LeagueDraftPhase _phase = LeagueDraftPhase.setup;
  final List<LeagueParticipant> _participants = [];
  int _activeParticipantIndex = 0;

  // Current 3 random choices for the active participant
  List<ManagerOption> _currentManagerChoices = [];
  List<FormationOption> _currentFormationChoices = [];
  EraClubPack? _currentSpunClubPack;
  List<EraPlayerCandidate> _currentPlayerChoices = [];

  // League Fixtures & Scorer Leaderboard
  final List<LeagueMatchFixture> _fixtures = [];
  int _currentMatchday = 1;
  int _totalMatchdays = 1;
  final Map<String, int> _goalScorerCounts = {};
  final Map<String, String> _goalScorerClubTags = {};

  LeagueDraftPhase get phase => _phase;
  List<LeagueParticipant> get participants => List.unmodifiable(_participants);
  int get activeParticipantIndex => _activeParticipantIndex;
  LeagueParticipant get activeParticipant => _participants[_activeParticipantIndex];

  List<ManagerOption> get currentManagerChoices => _currentManagerChoices;
  List<FormationOption> get currentFormationChoices => _currentFormationChoices;
  EraClubPack? get currentSpunClubPack => _currentSpunClubPack;
  List<EraPlayerCandidate> get currentPlayerChoices => _currentPlayerChoices;

  List<LeagueMatchFixture> get fixtures => List.unmodifiable(_fixtures);
  int get currentMatchday => _currentMatchday;
  int get totalMatchdays => _totalMatchdays;

  int get currentSlotIndex => activeParticipant.squad.length;

  String get currentNeededRole {
    final form = activeParticipant.formation;
    if (form == null) return 'MID';
    final roles = form.draftSlotRoles;
    if (currentSlotIndex >= roles.length) return 'FWD';
    return roles[currentSlotIndex];
  }

  String get currentNeededRoleLabel {
    switch (currentNeededRole) {
      case 'GK':
        return 'Kaleci (KL)';
      case 'DEF':
        return 'Defans (DF)';
      case 'MID':
        return 'Orta Saha (OS)';
      case 'FWD':
      default:
        return 'Hücum / Forvet (SNT)';
    }
  }

  bool get isAllFixturesPlayed =>
      _fixtures.isNotEmpty && _fixtures.every((f) => f.isPlayed);

  /// Sorted League Table (Points -> Goal Difference -> Goals For -> Overall Power)
  List<LeagueParticipant> get standings {
    final copy = List<LeagueParticipant>.from(_participants);
    copy.sort((a, b) {
      if (b.points != a.points) return b.points.compareTo(a.points);
      if (b.goalDifference != a.goalDifference) {
        return b.goalDifference.compareTo(a.goalDifference);
      }
      if (b.goalsFor != a.goalsFor) return b.goalsFor.compareTo(a.goalsFor);
      return b.overallTeamPower.compareTo(a.overallTeamPower);
    });
    return copy;
  }

  /// Top Goalscorers list
  List<MapEntry<String, int>> get topScorers {
    final entries = _goalScorerCounts.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(8).toList();
  }

  String scorerClubTag(String playerName) => _goalScorerClubTags[playerName] ?? '';

  /// Start a Solo League (User + 3 AI Managers = 4-team League) or Friends League (N friends)
  void startDraft({
    required List<String> playerNames,
    required bool isSoloMode,
  }) {
    _participants.clear();
    _fixtures.clear();
    _goalScorerCounts.clear();
    _goalScorerClubTags.clear();

    if (isSoloMode) {
      final humanName = playerNames.isNotEmpty && playerNames.first.trim().isNotEmpty
          ? playerNames.first.trim()
          : 'Kaptan FC';
      _participants.add(LeagueParticipant(id: 'p_0', name: humanName, isBot: false));
      const botNames = [' Taktik Dehası AI', 'Galaktikos Bot', 'Kuzey Yıldızı AI'];
      for (int i = 0; i < botNames.length; i++) {
        _participants.add(
          LeagueParticipant(id: 'bot_$i', name: botNames[i].trim(), isBot: true),
        );
      }
    } else {
      for (int i = 0; i < playerNames.length; i++) {
        final clean = playerNames[i].trim().isEmpty
            ? 'Oyuncu ${i + 1}'
            : playerNames[i].trim();
        _participants.add(LeagueParticipant(id: 'p_$i', name: clean, isBot: false));
      }
    }

    _activeParticipantIndex = 0;
    _prepareManagerChoicesForActive();
    _phase = LeagueDraftPhase.pickManager;
    notifyListeners();
  }

  void _prepareManagerChoicesForActive() {
    final pool = List<ManagerOption>.from(allManagers)..shuffle(_rng);
    _currentManagerChoices = pool.take(3).toList();
  }

  void _prepareFormationChoicesForActive() {
    final pool = List<FormationOption>.from(allFormations)..shuffle(_rng);
    _currentFormationChoices = pool.take(3).toList();
  }

  void selectManager(ManagerOption manager) {
    activeParticipant.manager = manager;
    _prepareFormationChoicesForActive();
    _phase = LeagueDraftPhase.pickFormation;
    notifyListeners();
  }

  void selectFormation(FormationOption formation) {
    activeParticipant.formation = formation;
    _spinNextHistoricalClubForActive();
    _phase = LeagueDraftPhase.pickPlayers;
    notifyListeners();
  }

  void _spinNextHistoricalClubForActive() {
    final neededRole = currentNeededRole;
    final alreadyPickedIds = activeParticipant.squad.map((e) => e.id).toSet();

    // Filter packs that have at least 1 unpicked player in the needed role
    final shuffledPacks = List<EraClubPack>.from(allEraClubPacks)..shuffle(_rng);
    EraClubPack chosenPack = shuffledPacks.first;

    for (final pack in shuffledPacks) {
      final matching = pack.roster
          .where((p) => p.role == neededRole && !alreadyPickedIds.contains(p.id))
          .toList();
      if (matching.isNotEmpty) {
        chosenPack = pack;
        break;
      }
    }

    _currentSpunClubPack = chosenPack;

    // Build 3 choices from this historical club & year:
    // Prefer players of the needed role first, then fill up to 3 from the same historical squad
    final roleMatches = chosenPack.roster
        .where((p) => p.role == neededRole && !alreadyPickedIds.contains(p.id))
        .toList()
      ..shuffle(_rng);

    final othersInPack = chosenPack.roster
        .where((p) => p.role != neededRole && !alreadyPickedIds.contains(p.id))
        .toList()
      ..shuffle(_rng);

    final combined = <EraPlayerCandidate>[...roleMatches, ...othersInPack];
    if (combined.length < 3) {
      // Fallback if somehow already picked
      for (final p in chosenPack.roster) {
        if (!combined.contains(p)) combined.add(p);
      }
    }

    _currentPlayerChoices = combined.take(3).toList();
  }

  void selectPlayerForSquad(EraPlayerCandidate player) {
    // Store with the active slot's needed role so the formation lines stay balanced
    final adaptedPlayer = EraPlayerCandidate(
      id: player.id,
      name: player.name,
      role: currentNeededRole,
      specificPosition: player.specificPosition,
      rating: player.rating,
      clubId: player.clubId,
      clubName: player.clubName,
      seasonLabel: player.seasonLabel,
    );

    activeParticipant.squad.add(adaptedPlayer);

    if (activeParticipant.squad.length >= 11) {
      _advanceToNextParticipantOrStartLeague();
    } else {
      _spinNextHistoricalClubForActive();
    }
    notifyListeners();
  }

  /// Quickly auto-drafts the remaining slots for the current participant
  void autoCompleteCurrentParticipantSquad() {
    activeParticipant.manager ??= (_currentManagerChoices.isNotEmpty
        ? _currentManagerChoices.first
        : allManagers.first);
    activeParticipant.formation ??= (_currentFormationChoices.isNotEmpty
        ? _currentFormationChoices.first
        : allFormations.first);

    while (activeParticipant.squad.length < 11) {
      _spinNextHistoricalClubForActive();
      final pick = _currentPlayerChoices.first;
      final adapted = EraPlayerCandidate(
        id: pick.id,
        name: pick.name,
        role: currentNeededRole,
        specificPosition: pick.specificPosition,
        rating: pick.rating,
        clubId: pick.clubId,
        clubName: pick.clubName,
        seasonLabel: pick.seasonLabel,
      );
      activeParticipant.squad.add(adapted);
    }

    _advanceToNextParticipantOrStartLeague();
    notifyListeners();
  }

  void _advanceToNextParticipantOrStartLeague() {
    // Check if there is another human participant waiting to draft
    int nextIndex = _activeParticipantIndex + 1;
    while (nextIndex < _participants.length && _participants[nextIndex].isBot) {
      _autoDraftBotParticipant(_participants[nextIndex]);
      nextIndex++;
    }

    if (nextIndex < _participants.length) {
      _activeParticipantIndex = nextIndex;
      _phase = LeagueDraftPhase.nextPlayerHandoff;
    } else {
      // Make sure all bots have drafted
      for (final p in _participants) {
        if (p.isBot && p.squad.length < 11) {
          _autoDraftBotParticipant(p);
        }
      }
      _generateLeagueFixtures();
      _phase = LeagueDraftPhase.leagueSimulation;
    }
  }

  void beginNextHumanTurn() {
    _prepareManagerChoicesForActive();
    _phase = LeagueDraftPhase.pickManager;
    notifyListeners();
  }

  void _autoDraftBotParticipant(LeagueParticipant bot) {
    final mgrs = List<ManagerOption>.from(allManagers)..shuffle(_rng);
    final forms = List<FormationOption>.from(allFormations)..shuffle(_rng);
    bot.manager = mgrs.first;
    bot.formation = forms.first;
    bot.squad.clear();

    final roles = bot.formation!.draftSlotRoles;
    final packs = List<EraClubPack>.from(allEraClubPacks);

    for (final role in roles) {
      packs.shuffle(_rng);
      final pack = packs.first;
      final candidates = pack.roster.where((p) => p.role == role).toList();
      final chosen = candidates.isNotEmpty
          ? candidates[_rng.nextInt(candidates.length)]
          : pack.roster[_rng.nextInt(pack.roster.length)];
      bot.squad.add(
        EraPlayerCandidate(
          id: chosen.id,
          name: chosen.name,
          role: role,
          specificPosition: chosen.specificPosition,
          rating: chosen.rating,
          clubId: chosen.clubId,
          clubName: chosen.clubName,
          seasonLabel: chosen.seasonLabel,
        ),
      );
    }
  }

  /// Generates a full home & away round-robin schedule (Çift Devreli Lig Fikstürü)
  void _generateLeagueFixtures() {
    _fixtures.clear();
    _goalScorerCounts.clear();
    _goalScorerClubTags.clear();
    for (final p in _participants) {
      p.resetLeagueStats();
    }

    final n = _participants.length;
    final indices = List<int>.generate(n, (i) => i);
    if (n % 2 != 0) {
      indices.add(-1); // Bye week marker for odd number of players
    }

    final totalTeams = indices.length;
    final roundsPerHalf = totalTeams - 1;
    final matchesPerRound = totalTeams ~/ 2;

    int matchdayCounter = 1;
    final rotating = List<int>.from(indices);

    // First half (Home)
    final firstHalfFixtures = <LeagueMatchFixture>[];
    for (int round = 0; round < roundsPerHalf; round++) {
      for (int m = 0; m < matchesPerRound; m++) {
        final t1 = rotating[m];
        final t2 = rotating[totalTeams - 1 - m];
        if (t1 != -1 && t2 != -1) {
          final fixture = round % 2 == 0
              ? LeagueMatchFixture(matchday: matchdayCounter, homeIndex: t1, awayIndex: t2)
              : LeagueMatchFixture(matchday: matchdayCounter, homeIndex: t2, awayIndex: t1);
          _fixtures.add(fixture);
          firstHalfFixtures.add(fixture);
        }
      }
      matchdayCounter++;
      // Rotate all except the first element
      final last = rotating.removeLast();
      rotating.insert(1, last);
    }

    // Second half (Away / Reverse fixtures)
    for (int round = 1; round <= roundsPerHalf; round++) {
      final roundMatches = firstHalfFixtures.where((f) => f.matchday == round).toList();
      for (final f in roundMatches) {
        _fixtures.add(
          LeagueMatchFixture(
            matchday: matchdayCounter,
            homeIndex: f.awayIndex,
            awayIndex: f.homeIndex,
          ),
        );
      }
      matchdayCounter++;
    }

    _totalMatchdays = matchdayCounter - 1;
    _currentMatchday = 1;
  }

  /// Simulates all matches of the current matchday
  void simulateNextMatchday() {
    if (isAllFixturesPlayed) return;

    final dayMatches = _fixtures
        .where((f) => f.matchday == _currentMatchday && !f.isPlayed)
        .toList();

    for (final match in dayMatches) {
      _simulateSingleMatch(match);
    }

    if (_currentMatchday < _totalMatchdays) {
      final nextUnplayed = _fixtures.where((f) => !f.isPlayed).toList();
      if (nextUnplayed.isNotEmpty) {
        _currentMatchday = nextUnplayed.first.matchday;
      }
    }

    notifyListeners();
  }

  /// Simulates all remaining matchdays at once
  void simulateAllRemainingMatchdays() {
    for (final match in _fixtures) {
      if (!match.isPlayed) {
        _simulateSingleMatch(match);
      }
    }
    _currentMatchday = _totalMatchdays;
    notifyListeners();
  }

  /// Resets the current league scores and replays the season with the same drafted squads
  void replaySeasonWithSameSquads() {
    _generateLeagueFixtures();
    notifyListeners();
  }

  void _simulateSingleMatch(LeagueMatchFixture match) {
    final home = _participants[match.homeIndex];
    final away = _participants[match.awayIndex];

    // Calculate expected goal potential based on Attack vs Opponent Defense + Home advantage
    final homeAdvantage = 2;
    final homeDiff = (home.attackPower + homeAdvantage) - away.defensePower;
    final awayDiff = away.attackPower - (home.defensePower + 1);

    int homeGoals = _sampleGoals(homeDiff);
    int awayGoals = _sampleGoals(awayDiff);

    match.homeGoals = homeGoals;
    match.awayGoals = awayGoals;
    match.isPlayed = true;
    match.events.clear();

    for (int g = 0; g < homeGoals; g++) {
      final scorer = _pickScorerFromSquad(home);
      final minute = 4 + _rng.nextInt(87);
      final tag = '${scorer.seasonLabel} ${scorer.clubName}';
      match.events.add(
        LeagueGoalEvent(
          minute: minute,
          scorerName: scorer.name,
          clubEraTag: tag,
          isHomeGoal: true,
        ),
      );
      _goalScorerCounts[scorer.name] = (_goalScorerCounts[scorer.name] ?? 0) + 1;
      _goalScorerClubTags[scorer.name] = '${home.name} • $tag';
    }

    for (int g = 0; g < awayGoals; g++) {
      final scorer = _pickScorerFromSquad(away);
      final minute = 4 + _rng.nextInt(87);
      final tag = '${scorer.seasonLabel} ${scorer.clubName}';
      match.events.add(
        LeagueGoalEvent(
          minute: minute,
          scorerName: scorer.name,
          clubEraTag: tag,
          isHomeGoal: false,
        ),
      );
      _goalScorerCounts[scorer.name] = (_goalScorerCounts[scorer.name] ?? 0) + 1;
      _goalScorerClubTags[scorer.name] = '${away.name} • $tag';
    }

    match.events.sort((a, b) => a.minute.compareTo(b.minute));

    // Update standings stats
    home.played++;
    away.played++;
    home.goalsFor += homeGoals;
    home.goalsAgainst += awayGoals;
    away.goalsFor += awayGoals;
    away.goalsAgainst += homeGoals;

    if (homeGoals > awayGoals) {
      home.won++;
      home.points += 3;
      away.lost++;
    } else if (homeGoals < awayGoals) {
      away.won++;
      away.points += 3;
      home.lost++;
    } else {
      home.drawn++;
      away.drawn++;
      home.points += 1;
      away.points += 1;
    }
  }

  int _sampleGoals(int powerDiff) {
    final baseChance = (0.38 + (powerDiff * 0.025)).clamp(0.18, 0.72);
    int goals = 0;
    for (int attempt = 0; attempt < 5; attempt++) {
      if (_rng.nextDouble() < baseChance) {
        goals++;
      }
    }
    return goals;
  }

  EraPlayerCandidate _pickScorerFromSquad(LeagueParticipant team) {
    if (team.squad.isEmpty) {
      return const EraPlayerCandidate(
        id: 'default',
        name: 'Yıldız Golcü',
        role: 'FWD',
        specificPosition: 'SNT',
        rating: 90,
        clubId: 'real_madrid',
        clubName: 'Real Madrid',
        seasonLabel: '2016-17',
      );
    }
    final fwds = team.squad.where((p) => p.role == 'FWD').toList();
    final mids = team.squad.where((p) => p.role == 'MID').toList();
    final defs = team.squad.where((p) => p.role == 'DEF').toList();

    final roll = _rng.nextDouble();
    if (roll < 0.62 && fwds.isNotEmpty) {
      return fwds[_rng.nextInt(fwds.length)];
    } else if (roll < 0.90 && mids.isNotEmpty) {
      return mids[_rng.nextInt(mids.length)];
    } else if (defs.isNotEmpty) {
      return defs[_rng.nextInt(defs.length)];
    }
    return team.squad[_rng.nextInt(team.squad.length)];
  }

  // ===========================================================================
  // STATIC DATA: 16 ICONIC MANAGERS, 8 FORMATIONS, 20 HISTORICAL CLUB ERAS
  // ===========================================================================

  static const List<ManagerOption> allManagers = [
    ManagerOption(
      id: 'mgr_terim',
      name: 'Fatih Terim',
      nationality: 'Türkiye',
      styleTitle: 'İmparator • Tam Saha Baskı',
      bonusDescription: '+5 Hücum Gücü • Finallerde ekstra motivasyon',
      rating: 93,
      attackBonus: 5,
      defenseBonus: 2,
    ),
    ManagerOption(
      id: 'mgr_guardiola',
      name: 'Pep Guardiola',
      nationality: 'İspanya',
      styleTitle: 'Tiki-Taka & Pozisyon Oyunu',
      bonusDescription: '+5 Hücum • +4 Savunma Kontrolü',
      rating: 96,
      attackBonus: 5,
      defenseBonus: 4,
    ),
    ManagerOption(
      id: 'mgr_mourinho',
      name: 'José Mourinho',
      nationality: 'Portekiz',
      styleTitle: 'The Special One • Keskin Kontra',
      bonusDescription: '+6 Savunma Duvarı • +3 Kontra Hücum',
      rating: 95,
      attackBonus: 3,
      defenseBonus: 6,
    ),
    ManagerOption(
      id: 'mgr_ancelotti',
      name: 'Carlo Ancelotti',
      nationality: 'İtalya',
      styleTitle: 'Don Carlo • Şampiyonlar Ligi Ustası',
      bonusDescription: '+4 Hücum • +4 Savunma Dengesi',
      rating: 96,
      attackBonus: 4,
      defenseBonus: 5,
    ),
    ManagerOption(
      id: 'mgr_ferguson',
      name: 'Sir Alex Ferguson',
      nationality: 'İskoçya',
      styleTitle: 'Fergie Time • Son Dakika Fırtınası',
      bonusDescription: '+5 Hücum • +4 Savunma Direnci',
      rating: 97,
      attackBonus: 5,
      defenseBonus: 4,
    ),
    ManagerOption(
      id: 'mgr_klopp',
      name: 'Jürgen Klopp',
      nationality: 'Almanya',
      styleTitle: 'Heavy Metal Futbol & Gegenpressing',
      bonusDescription: '+6 Hücum Temposu • +2 Savunma',
      rating: 95,
      attackBonus: 6,
      defenseBonus: 2,
    ),
    ManagerOption(
      id: 'mgr_zidane',
      name: 'Zinedine Zidane',
      nationality: 'Fransa',
      styleTitle: 'Üçleme Efsanesi • Yıldız Yönetimi',
      bonusDescription: '+5 Hücum • +3 Savunma',
      rating: 94,
      attackBonus: 5,
      defenseBonus: 3,
    ),
    ManagerOption(
      id: 'mgr_simeone',
      name: 'Diego Simeone',
      nationality: 'Arjantin',
      styleTitle: 'Cholo • Geçilmez Kale',
      bonusDescription: '+6 Demir Savunma • +2 Kontra',
      rating: 93,
      attackBonus: 2,
      defenseBonus: 6,
    ),
    ManagerOption(
      id: 'mgr_wenger',
      name: 'Arsène Wenger',
      nationality: 'Fransa',
      styleTitle: 'Yenilmezler • Akıcı Pas Oyunu',
      bonusDescription: '+5 Hücum Estetiği • +3 Savunma',
      rating: 94,
      attackBonus: 5,
      defenseBonus: 3,
    ),
    ManagerOption(
      id: 'mgr_senol',
      name: 'Şenol Güneş',
      nationality: 'Türkiye',
      styleTitle: '2002 Dünya Üçüncüsü • Hücum Futbolu',
      bonusDescription: '+4 Hücum • +3 Savunma',
      rating: 91,
      attackBonus: 4,
      defenseBonus: 3,
    ),
    ManagerOption(
      id: 'mgr_okan',
      name: 'Okan Buruk',
      nationality: 'Türkiye',
      styleTitle: 'Önde Şok Pres & Rekor Galibiyet',
      bonusDescription: '+4 Hücum • +3 Savunma',
      rating: 90,
      attackBonus: 4,
      defenseBonus: 3,
    ),
    ManagerOption(
      id: 'mgr_cruyff',
      name: 'Johan Cruyff',
      nationality: 'Hollanda',
      styleTitle: 'Total Futbolun Kurucusu',
      bonusDescription: '+6 Hücum Yaratıcılığı • +3 Savunma',
      rating: 96,
      attackBonus: 6,
      defenseBonus: 3,
    ),
  ];

  static const List<FormationOption> allFormations = [
    FormationOption(
      id: 'form_433',
      code: '4-3-3',
      title: '4-3-3 Hücum Kanatları',
      description: '4 Defans • 3 Orta Saha • 3 Forvet',
      defenders: 4,
      midfielders: 3,
      forwards: 3,
      attackBonus: 4,
      defenseBonus: 2,
    ),
    FormationOption(
      id: 'form_4231',
      code: '4-2-3-1',
      title: '4-2-3-1 Modern Maestro',
      description: '4 Defans • 5 Orta Saha • 1 Santrfor',
      defenders: 4,
      midfielders: 5,
      forwards: 1,
      attackBonus: 3,
      defenseBonus: 3,
    ),
    FormationOption(
      id: 'form_352',
      code: '3-5-2',
      title: '3-5-2 Merkez Hakimiyeti',
      description: '3 Stoper • 5 Orta Saha • 2 Forvet',
      defenders: 3,
      midfielders: 5,
      forwards: 2,
      attackBonus: 4,
      defenseBonus: 2,
    ),
    FormationOption(
      id: 'form_442',
      code: '4-4-2',
      title: '4-4-2 Klasik Çift Santrfor',
      description: '4 Defans • 4 Orta Saha • 2 Forvet',
      defenders: 4,
      midfielders: 4,
      forwards: 2,
      attackBonus: 3,
      defenseBonus: 3,
    ),
    FormationOption(
      id: 'form_343',
      code: '3-4-3',
      title: '3-4-3 Total Hücum',
      description: '3 Defans • 4 Orta Saha • 3 Forvet',
      defenders: 3,
      midfielders: 4,
      forwards: 3,
      attackBonus: 5,
      defenseBonus: 1,
    ),
    FormationOption(
      id: 'form_532',
      code: '5-3-2',
      title: '5-3-2 Demir Savunma & Kontra',
      description: '5 Defans • 3 Orta Saha • 2 Forvet',
      defenders: 5,
      midfielders: 3,
      forwards: 2,
      attackBonus: 1,
      defenseBonus: 5,
    ),
  ];

  static const List<EraClubPack> allEraClubPacks = [
    EraClubPack(
      id: 'gs_1999_00',
      clubId: 'galatasaray',
      clubName: 'Galatasaray',
      seasonLabel: '1999-00',
      eraTitle: 'UEFA Kupası & Süper Kupa Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'taffarel_00', name: 'Cláudio Taffarel', role: 'GK', specificPosition: 'KL', rating: 91, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'popescu_00', name: 'Gheorghe Popescu', role: 'DEF', specificPosition: 'STP', rating: 90, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'bulent_00', name: 'Bülent Korkmaz', role: 'DEF', specificPosition: 'STP', rating: 90, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'hagi_00', name: 'Gheorghe Hagi', role: 'MID', specificPosition: 'OOS', rating: 95, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'okan_00', name: 'Okan Buruk', role: 'MID', specificPosition: 'OS', rating: 88, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'jardel_00', name: 'Mário Jardel', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'hakan_sukur_00', name: 'Hakan Şükür', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '1999-00'),
      ],
    ),
    EraClubPack(
      id: 'gs_2012_13',
      clubId: 'galatasaray',
      clubName: 'Galatasaray',
      seasonLabel: '2012-13',
      eraTitle: 'Şampiyonlar Ligi Çeyrek Final Kadrosu',
      roster: [
        EraPlayerCandidate(id: 'muslera_13', name: 'Fernando Muslera', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'eboue_13', name: 'Emmanuel Eboué', role: 'DEF', specificPosition: 'SĞB', rating: 87, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'sneijder_13', name: 'Wesley Sneijder', role: 'MID', specificPosition: 'OOS', rating: 93, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'melo_13', name: 'Felipe Melo', role: 'MID', specificPosition: 'DOS', rating: 89, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'drogba_13', name: 'Didier Drogba', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'burak_13', name: 'Burak Yılmaz', role: 'FWD', specificPosition: 'SNT', rating: 89, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2012-13'),
      ],
    ),
    EraClubPack(
      id: 'fb_2007_08',
      clubId: 'fenerbahce',
      clubName: 'Fenerbahçe',
      seasonLabel: '2007-08',
      eraTitle: 'Şampiyonlar Ligi Çeyrek Final Efsanesi',
      roster: [
        EraPlayerCandidate(id: 'volkan_08', name: 'Volkan Demirel', role: 'GK', specificPosition: 'KL', rating: 89, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2007-08'),
        EraPlayerCandidate(id: 'rcarlos_08', name: 'Roberto Carlos', role: 'DEF', specificPosition: 'SLB', rating: 92, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2007-08'),
        EraPlayerCandidate(id: 'lugano_08', name: 'Diego Lugano', role: 'DEF', specificPosition: 'STP', rating: 90, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2007-08'),
        EraPlayerCandidate(id: 'alex_08', name: 'Alex de Souza', role: 'MID', specificPosition: 'OOS', rating: 94, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2007-08'),
        EraPlayerCandidate(id: 'aurelio_08', name: 'Mehmet Aurélio', role: 'MID', specificPosition: 'DOS', rating: 88, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2007-08'),
        EraPlayerCandidate(id: 'anelka_06', name: 'Nicolas Anelka', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'rvp_15', name: 'Robin van Persie', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2015-16'),
      ],
    ),
    EraClubPack(
      id: 'bjk_2016_17',
      clubId: 'besiktas',
      clubName: 'Beşiktaş',
      seasonLabel: '2016-17',
      eraTitle: 'Namağlup Şampiyonlar Ligi & Şampiyon Kadro',
      roster: [
        EraPlayerCandidate(id: 'fabri_17', name: 'Fabri', role: 'GK', specificPosition: 'KL', rating: 87, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'pepe_17', name: 'Pepe', role: 'DEF', specificPosition: 'STP', rating: 91, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2017-18'),
        EraPlayerCandidate(id: 'adriano_17', name: 'Adriano Correia', role: 'DEF', specificPosition: 'SLB', rating: 88, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'talisca_17', name: 'Anderson Talisca', role: 'MID', specificPosition: 'OOS', rating: 90, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'atiba_17', name: 'Atiba Hutchinson', role: 'MID', specificPosition: 'OS', rating: 88, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'quaresma_17', name: 'Ricardo Quaresma', role: 'FWD', specificPosition: 'SĞK', rating: 91, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'gomez_16', name: 'Mario Gómez', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2015-16'),
      ],
    ),
    EraClubPack(
      id: 'barca_2010_11',
      clubId: 'barcelona',
      clubName: 'Barcelona',
      seasonLabel: '2010-11',
      eraTitle: 'Pep\'in Altın Tiki-Taka Şampiyonlar Ligi Kadrosu',
      roster: [
        EraPlayerCandidate(id: 'valdes_11', name: 'Víctor Valdés', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2010-11'),
        EraPlayerCandidate(id: 'puyol_11', name: 'Carles Puyol', role: 'DEF', specificPosition: 'STP', rating: 94, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2010-11'),
        EraPlayerCandidate(id: 'alves_11', name: 'Dani Alves', role: 'DEF', specificPosition: 'SĞB', rating: 93, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2010-11'),
        EraPlayerCandidate(id: 'xavi_11', name: 'Xavi Hernández', role: 'MID', specificPosition: 'OS', rating: 96, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2010-11'),
        EraPlayerCandidate(id: 'iniesta_11', name: 'Andrés Iniesta', role: 'MID', specificPosition: 'OS', rating: 96, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2010-11'),
        EraPlayerCandidate(id: 'messi_11', name: 'Lionel Messi', role: 'FWD', specificPosition: 'SNT', rating: 99, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2010-11'),
        EraPlayerCandidate(id: 'villa_11', name: 'David Villa', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2010-11'),
      ],
    ),
    EraClubPack(
      id: 'barca_2005_06',
      clubId: 'barcelona',
      clubName: 'Barcelona',
      seasonLabel: '2005-06',
      eraTitle: 'Ronaldinho & Eto\'o Şampiyonlar Ligi Zaferi',
      roster: [
        EraPlayerCandidate(id: 'valdes_06', name: 'Víctor Valdés', role: 'GK', specificPosition: 'KL', rating: 88, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'marquez_06', name: 'Rafael Márquez', role: 'DEF', specificPosition: 'STP', rating: 90, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'deco_06', name: 'Deco', role: 'MID', specificPosition: 'OOS', rating: 92, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'ronaldinho_06', name: 'Ronaldinho', role: 'FWD', specificPosition: 'SLK', rating: 98, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'etoo_06', name: 'Samuel Eto\'o', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2005-06'),
      ],
    ),
    EraClubPack(
      id: 'rm_2016_17',
      clubId: 'real_madrid',
      clubName: 'Real Madrid',
      seasonLabel: '2016-17',
      eraTitle: 'Üst Üste Şampiyonlar Ligi Hanedanı',
      roster: [
        EraPlayerCandidate(id: 'navas_17', name: 'Keylor Navas', role: 'GK', specificPosition: 'KL', rating: 91, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'ramos_17', name: 'Sergio Ramos', role: 'DEF', specificPosition: 'STP', rating: 95, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'marcelo_17', name: 'Marcelo', role: 'DEF', specificPosition: 'SLB', rating: 93, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'modric_17', name: 'Luka Modrić', role: 'MID', specificPosition: 'OS', rating: 95, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'kroos_17', name: 'Toni Kroos', role: 'MID', specificPosition: 'OS', rating: 94, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'cronaldo_17', name: 'Cristiano Ronaldo', role: 'FWD', specificPosition: 'SNT', rating: 99, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'benzema_17', name: 'Karim Benzema', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2016-17'),
      ],
    ),
    EraClubPack(
      id: 'rm_2001_02',
      clubId: 'real_madrid',
      clubName: 'Real Madrid',
      seasonLabel: '2001-02',
      eraTitle: 'Los Galácticos Dönemi',
      roster: [
        EraPlayerCandidate(id: 'casillas_02', name: 'Iker Casillas', role: 'GK', specificPosition: 'KL', rating: 95, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2001-02'),
        EraPlayerCandidate(id: 'rcarlos_02', name: 'Roberto Carlos', role: 'DEF', specificPosition: 'SLB', rating: 95, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2001-02'),
        EraPlayerCandidate(id: 'hierro_02', name: 'Fernando Hierro', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2001-02'),
        EraPlayerCandidate(id: 'zidane_02', name: 'Zinedine Zidane', role: 'MID', specificPosition: 'OOS', rating: 97, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2001-02'),
        EraPlayerCandidate(id: 'figo_02', name: 'Luís Figo', role: 'MID', specificPosition: 'SĞK', rating: 94, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2001-02'),
        EraPlayerCandidate(id: 'r9_02', name: 'Ronaldo Nazário', role: 'FWD', specificPosition: 'SNT', rating: 98, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2002-03'),
        EraPlayerCandidate(id: 'raul_02', name: 'Raúl González', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2001-02'),
      ],
    ),
    EraClubPack(
      id: 'milan_2004_05',
      clubId: 'milan',
      clubName: 'AC Milan',
      seasonLabel: '2004-05',
      eraTitle: 'Efsane Kırmızı-Siyah Kadro',
      roster: [
        EraPlayerCandidate(id: 'dida_05', name: 'Dida', role: 'GK', specificPosition: 'KL', rating: 91, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'maldini_05', name: 'Paolo Maldini', role: 'DEF', specificPosition: 'STP', rating: 97, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'nesta_05', name: 'Alessandro Nesta', role: 'DEF', specificPosition: 'STP', rating: 95, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'cafu_05', name: 'Cafu', role: 'DEF', specificPosition: 'SĞB', rating: 94, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'kaka_05', name: 'Kaká', role: 'MID', specificPosition: 'OOS', rating: 96, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'pirlo_05', name: 'Andrea Pirlo', role: 'MID', specificPosition: 'OS', rating: 95, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'sheva_05', name: 'Andriy Shevchenko', role: 'FWD', specificPosition: 'SNT', rating: 95, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2004-05'),
      ],
    ),
    EraClubPack(
      id: 'inter_2009_10',
      clubId: 'inter',
      clubName: 'Inter Milan',
      seasonLabel: '2009-10',
      eraTitle: 'Mourinho\'nun Tarihi Üçleme (Treble) Kadrosu',
      roster: [
        EraPlayerCandidate(id: 'jcesar_10', name: 'Júlio César', role: 'GK', specificPosition: 'KL', rating: 93, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '2009-10'),
        EraPlayerCandidate(id: 'zanetti_10', name: 'Javier Zanetti', role: 'DEF', specificPosition: 'SĞB', rating: 93, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '2009-10'),
        EraPlayerCandidate(id: 'lucio_10', name: 'Lúcio', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '2009-10'),
        EraPlayerCandidate(id: 'sneijder_10', name: 'Wesley Sneijder', role: 'MID', specificPosition: 'OOS', rating: 94, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '2009-10'),
        EraPlayerCandidate(id: 'cambiasso_10', name: 'Esteban Cambiasso', role: 'MID', specificPosition: 'DOS', rating: 91, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '2009-10'),
        EraPlayerCandidate(id: 'milito_10', name: 'Diego Milito', role: 'FWD', specificPosition: 'SNT', rating: 93, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '2009-10'),
      ],
    ),
    EraClubPack(
      id: 'arsenal_2003_04',
      clubId: 'arsenal',
      clubName: 'Arsenal',
      seasonLabel: '2003-04',
      eraTitle: 'The Invincibles (Namağlup Şampiyon)',
      roster: [
        EraPlayerCandidate(id: 'lehmann_04', name: 'Jens Lehmann', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'campbell_04', name: 'Sol Campbell', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'acole_04', name: 'Ashley Cole', role: 'DEF', specificPosition: 'SLB', rating: 92, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'vieira_04', name: 'Patrick Vieira', role: 'MID', specificPosition: 'OS', rating: 94, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'pires_04', name: 'Robert Pirès', role: 'MID', specificPosition: 'SLK', rating: 92, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'henry_04', name: 'Thierry Henry', role: 'FWD', specificPosition: 'SNT', rating: 97, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'bergkamp_04', name: 'Dennis Bergkamp', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2003-04'),
      ],
    ),
    EraClubPack(
      id: 'mancity_2022_23',
      clubId: 'man_city',
      clubName: 'Manchester City',
      seasonLabel: '2022-23',
      eraTitle: 'Tarihi Üçleme (Treble) Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'ederson_23', name: 'Ederson', role: 'GK', specificPosition: 'KL', rating: 91, clubId: 'man_city', clubName: 'Manchester City', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'dias_23', name: 'Rúben Dias', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'man_city', clubName: 'Manchester City', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'walker_23', name: 'Kyle Walker', role: 'DEF', specificPosition: 'SĞB', rating: 91, clubId: 'man_city', clubName: 'Manchester City', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'kdb_23', name: 'Kevin De Bruyne', role: 'MID', specificPosition: 'OOS', rating: 96, clubId: 'man_city', clubName: 'Manchester City', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'rodri_23', name: 'Rodri', role: 'MID', specificPosition: 'DOS', rating: 95, clubId: 'man_city', clubName: 'Manchester City', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'haaland_23', name: 'Erling Haaland', role: 'FWD', specificPosition: 'SNT', rating: 96, clubId: 'man_city', clubName: 'Manchester City', seasonLabel: '2022-23'),
      ],
    ),
    EraClubPack(
      id: 'bayern_2019_20',
      clubId: 'bayern',
      clubName: 'Bayern Münih',
      seasonLabel: '2019-20',
      eraTitle: 'Altı Kupalı Kusursuz Makine',
      roster: [
        EraPlayerCandidate(id: 'neuer_20', name: 'Manuel Neuer', role: 'GK', specificPosition: 'KL', rating: 96, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'davies_20', name: 'Alphonso Davies', role: 'DEF', specificPosition: 'SLB', rating: 90, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'lahm_13', name: 'Philipp Lahm', role: 'DEF', specificPosition: 'SĞB', rating: 94, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'kimmich_20', name: 'Joshua Kimmich', role: 'MID', specificPosition: 'OS', rating: 92, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'muller_20', name: 'Thomas Müller', role: 'MID', specificPosition: 'OOS', rating: 93, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'lewa_20', name: 'Robert Lewandowski', role: 'FWD', specificPosition: 'SNT', rating: 97, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'robben_13', name: 'Arjen Robben', role: 'FWD', specificPosition: 'SĞK', rating: 94, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2012-13'),
      ],
    ),
    EraClubPack(
      id: 'liv_2018_19',
      clubId: 'liverpool',
      clubName: 'Liverpool',
      seasonLabel: '2018-19',
      eraTitle: 'Klopp\'un Avrupa Şampiyonu Kadrosu',
      roster: [
        EraPlayerCandidate(id: 'alisson_19', name: 'Alisson Becker', role: 'GK', specificPosition: 'KL', rating: 93, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'vandijk_19', name: 'Virgil van Dijk', role: 'DEF', specificPosition: 'STP', rating: 95, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'trent_19', name: 'Trent Alexander-Arnold', role: 'DEF', specificPosition: 'SĞB', rating: 91, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'gerrard_05', name: 'Steven Gerrard', role: 'MID', specificPosition: 'OS', rating: 95, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'salah_19', name: 'Mohamed Salah', role: 'FWD', specificPosition: 'SĞK', rating: 95, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'mane_19', name: 'Sadio Mané', role: 'FWD', specificPosition: 'SLK', rating: 93, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2018-19'),
      ],
    ),
    EraClubPack(
      id: 'manutd_2007_08',
      clubId: 'man_united',
      clubName: 'Manchester United',
      seasonLabel: '2007-08',
      eraTitle: 'Sir Alex Ferguson Şampiyonlar Ligi Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'vandersar_08', name: 'Edwin van der Sar', role: 'GK', specificPosition: 'KL', rating: 93, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '2007-08'),
        EraPlayerCandidate(id: 'ferdinand_08', name: 'Rio Ferdinand', role: 'DEF', specificPosition: 'STP', rating: 94, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '2007-08'),
        EraPlayerCandidate(id: 'vidic_08', name: 'Nemanja Vidić', role: 'DEF', specificPosition: 'STP', rating: 93, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '2007-08'),
        EraPlayerCandidate(id: 'scholes_08', name: 'Paul Scholes', role: 'MID', specificPosition: 'OS', rating: 94, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '2007-08'),
        EraPlayerCandidate(id: 'beckham_99', name: 'David Beckham', role: 'MID', specificPosition: 'SĞK', rating: 93, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'rooney_08', name: 'Wayne Rooney', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '2007-08'),
      ],
    ),
    EraClubPack(
      id: 'juve_2005_06',
      clubId: 'juventus',
      clubName: 'Juventus',
      seasonLabel: '2005-06',
      eraTitle: 'Torino Efsaneleri & Dünya Şampiyonları',
      roster: [
        EraPlayerCandidate(id: 'buffon_06', name: 'Gianluigi Buffon', role: 'GK', specificPosition: 'KL', rating: 97, clubId: 'juventus', clubName: 'Juventus', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'cannavaro_06', name: 'Fabio Cannavaro', role: 'DEF', specificPosition: 'STP', rating: 96, clubId: 'juventus', clubName: 'Juventus', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'chiellini_15', name: 'Giorgio Chiellini', role: 'DEF', specificPosition: 'STP', rating: 93, clubId: 'juventus', clubName: 'Juventus', seasonLabel: '2014-15'),
        EraPlayerCandidate(id: 'nedved_06', name: 'Pavel Nedvěd', role: 'MID', specificPosition: 'OS', rating: 94, clubId: 'juventus', clubName: 'Juventus', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'delpiero_06', name: 'Alessandro Del Piero', role: 'FWD', specificPosition: 'SNT', rating: 95, clubId: 'juventus', clubName: 'Juventus', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'ibra_06', name: 'Zlatan Ibrahimović', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'juventus', clubName: 'Juventus', seasonLabel: '2005-06'),
      ],
    ),
  ];
}
