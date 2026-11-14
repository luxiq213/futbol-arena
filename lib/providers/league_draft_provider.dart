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

enum LeaguePoolTheme {
  allWorldHistory,
  superLigHistory,
  europeanGiants,
  worldCupLegends,
}

class LeagueDraftProvider extends ChangeNotifier {
  final Random _rng = Random();

  static const List<String> _defaultBotNames = [
    'Taktik Dehası AI',
    'Galaktikos Bot',
    'Kuzey Fırtınası AI',
    'Anadolu Kartalı Bot',
    'Sambacılar AI',
    'Panzerler Bot',
    'Boğazın Efendisi AI',
    'Total Futbol Bot',
    'Catenaccio AI',
    'Kralın Takımı Bot',
    'Altın Jenerasyon AI',
  ];

  LeagueDraftPhase _phase = LeagueDraftPhase.setup;
  LeaguePoolTheme _poolTheme = LeaguePoolTheme.allWorldHistory;

  // Online Lobby State (Room Code, Capacity, Invited Friends + AI Bots, Multi-Season Tracker)
  String _lobbyRoomCode = '482915';
  int _leagueCapacity = 4;
  int _seasonNumber = 1;
  bool _championshipAwardedForCurrentSeason = false;
  final List<LeagueLobbySlot> _lobbySlots = [];

  final List<LeagueParticipant> _participants = [];
  int _activeParticipantIndex = 0;

  // Current 3 random choices for the active participant
  List<ManagerOption> _currentManagerChoices = [];
  List<FormationOption> _currentFormationChoices = [];
  EraClubPack? _currentSpunClubPack;
  List<EraPlayerCandidate> _currentPlayerChoices = [];
  final Set<String> _usedPackIdsInCurrentTurn = {};
  int _remainingRerolls = 3;

  // League Fixtures & Live Ticker State
  final List<LeagueMatchFixture> _fixtures = [];
  LeagueMatchFixture? _latestSimulatedFixture;
  int _currentMatchday = 1;
  int _totalMatchdays = 1;
  final Map<String, int> _goalScorerCounts = {};
  final Map<String, String> _goalScorerClubTags = {};

  LeagueDraftProvider() {
    _lobbyRoomCode = (100000 + _rng.nextInt(900000)).toString();
    _rebuildLobbySlotsForCapacity(4);
  }

  LeagueDraftPhase get phase => _phase;
  LeaguePoolTheme get poolTheme => _poolTheme;
  String get lobbyRoomCode => _lobbyRoomCode;
  int get leagueCapacity => _leagueCapacity;
  int get seasonNumber => _seasonNumber;
  List<LeagueLobbySlot> get lobbySlots => List.unmodifiable(_lobbySlots);
  int get invitedHumanCount => _lobbySlots.where((s) => !s.isBot).length;
  int get botFillCount => _lobbySlots.where((s) => s.isBot).length;
  bool get canInviteMoreFriends => invitedHumanCount < _leagueCapacity;

  int get remainingRerolls => _remainingRerolls;
  List<LeagueParticipant> get participants => List.unmodifiable(_participants);
  int get activeParticipantIndex => _activeParticipantIndex;
  LeagueParticipant get activeParticipant => _participants[_activeParticipantIndex];

  List<ManagerOption> get currentManagerChoices => _currentManagerChoices;
  List<FormationOption> get currentFormationChoices => _currentFormationChoices;
  EraClubPack? get currentSpunClubPack => _currentSpunClubPack;
  List<EraPlayerCandidate> get currentPlayerChoices => _currentPlayerChoices;

  List<LeagueMatchFixture> get fixtures => List.unmodifiable(_fixtures);
  LeagueMatchFixture? get latestSimulatedFixture => _latestSimulatedFixture;
  List<LeagueMatchFixture> get playedFixturesReverse =>
      _fixtures.where((f) => f.isPlayed).toList().reversed.toList();
  int get playedFixturesCount => _fixtures.where((f) => f.isPlayed).length;
  int get currentMatchday => _currentMatchday;
  int get totalMatchdays => _totalMatchdays;
  LeagueParticipant? get champion =>
      isAllFixturesPlayed && standings.isNotEmpty ? standings.first : null;

  void _rebuildLobbySlotsForCapacity(int newCapacity) {
    _leagueCapacity = newCapacity.clamp(2, 12);
    final existingHumans = _lobbySlots.where((s) => !s.isBot).toList();
    final existingTrophies = <String, int>{
      for (final s in _lobbySlots) s.name: s.championshipsWon,
    };

    _lobbySlots.clear();
    if (existingHumans.isEmpty) {
      _lobbySlots.add(
        LeagueLobbySlot(
          slotIndex: 0,
          name: 'Kaptan FC (Ev Sahibi)',
          isBot: false,
          isHost: true,
        ),
      );
    } else {
      for (int i = 0; i < existingHumans.length && i < _leagueCapacity; i++) {
        _lobbySlots.add(
          LeagueLobbySlot(
            slotIndex: i,
            name: existingHumans[i].name,
            isBot: false,
            isHost: i == 0,
            championshipsWon: existingHumans[i].championshipsWon,
          ),
        );
      }
    }

    int botNameCursor = 0;
    while (_lobbySlots.length < _leagueCapacity) {
      final slotIdx = _lobbySlots.length;
      final bName = _defaultBotNames[botNameCursor % _defaultBotNames.length];
      botNameCursor++;
      _lobbySlots.add(
        LeagueLobbySlot(
          slotIndex: slotIdx,
          name: bName,
          isBot: true,
          isHost: false,
          championshipsWon: existingTrophies[bName] ?? 0,
        ),
      );
    }
  }

  /// Sets the total number of teams in the league; empty slots are automatically AI Bots
  void setLeagueCapacity(int capacity) {
    _rebuildLobbySlotsForCapacity(capacity);
    notifyListeners();
  }

  /// Invites a friend into an available AI Bot slot (up to leagueCapacity)
  bool inviteFriendToLobby(String friendName, {int? targetSlotIndex}) {
    int slotIdx = targetSlotIndex ?? -1;
    if (slotIdx < 0 || slotIdx >= _lobbySlots.length || !_lobbySlots[slotIdx].isBot) {
      slotIdx = _lobbySlots.indexWhere((s) => s.isBot);
    }
    if (slotIdx == -1) return false; // All slots up to leagueCapacity are already human players

    final cleanName = friendName.trim().isEmpty
        ? '${invitedHumanCount + 1}. Davetli Menajer'
        : friendName.trim();

    _lobbySlots[slotIdx].name = cleanName;
    _lobbySlots[slotIdx].isBot = false;
    _lobbySlots[slotIdx].isReady = true;
    notifyListeners();
    return true;
  }

  /// Removes an invited friend slot and turns it back into an AI Bot slot
  void convertSlotToBot(int slotIndex) {
    if (slotIndex <= 0 || slotIndex >= _lobbySlots.length) return;
    final bName = _defaultBotNames[slotIndex % _defaultBotNames.length];
    _lobbySlots[slotIndex].name = bName;
    _lobbySlots[slotIndex].isBot = true;
    notifyListeners();
  }

  void updateLobbySlotName(int slotIndex, String newName) {
    if (slotIndex < 0 || slotIndex >= _lobbySlots.length) return;
    if (newName.trim().isEmpty) return;
    _lobbySlots[slotIndex].name = newName.trim();
    notifyListeners();
  }

  void regenerateRoomCode() {
    _lobbyRoomCode = (100000 + _rng.nextInt(900000)).toString();
    notifyListeners();
  }

  bool joinLobbyByCode(String code, String playerName) {
    final trimmed = code.trim();
    if (trimmed.length < 4) return false;
    _lobbyRoomCode = trimmed.toUpperCase();
    if (_lobbySlots.isNotEmpty) {
      _lobbySlots[0].name = 'Oda Kurucu (#$_lobbyRoomCode)';
    }
    inviteFriendToLobby(playerName.trim().isEmpty ? 'Misafir Menajer' : playerName.trim());
    notifyListeners();
    return true;
  }

  void setPoolTheme(LeaguePoolTheme theme) {
    _poolTheme = theme;
    notifyListeners();
  }

  List<EraClubPack> get activePoolPacks {
    const superLigIds = {
      'galatasaray',
      'fenerbahce',
      'besiktas',
      'trabzonspor',
      'bursaspor',
      'basaksehir',
      'sivasspor',
      'adana_demirspor',
      'samsunspor',
      'goztepe',
    };
    switch (_poolTheme) {
      case LeaguePoolTheme.superLigHistory:
        return allEraClubPacks.where((p) => superLigIds.contains(p.clubId)).toList();
      case LeaguePoolTheme.europeanGiants:
        return allEraClubPacks
            .where((p) => !superLigIds.contains(p.clubId) && !p.clubId.startsWith('nat_'))
            .toList();
      case LeaguePoolTheme.worldCupLegends:
        return allEraClubPacks
            .where((p) => p.clubId.startsWith('nat_') || superLigIds.contains(p.clubId))
            .toList();
      case LeaguePoolTheme.allWorldHistory:
        return allEraClubPacks;
    }
  }

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

  /// Starts the draft directly from the current Online/Invite Lobby slots (Friends + AI Bots)
  void startDraftFromLobby() {
    _participants.clear();
    _fixtures.clear();
    _latestSimulatedFixture = null;
    _goalScorerCounts.clear();
    _goalScorerClubTags.clear();
    _championshipAwardedForCurrentSeason = false;

    for (int i = 0; i < _lobbySlots.length; i++) {
      final slot = _lobbySlots[i];
      _participants.add(
        LeagueParticipant(
          id: slot.isBot ? 'bot_$i' : 'p_$i',
          name: slot.name,
          isBot: slot.isBot,
          championshipsWon: slot.championshipsWon,
        ),
      );
    }

    _activeParticipantIndex = 0;
    while (_activeParticipantIndex < _participants.length &&
        _participants[_activeParticipantIndex].isBot) {
      _autoDraftBotParticipant(_participants[_activeParticipantIndex]);
      _activeParticipantIndex++;
    }

    if (_activeParticipantIndex >= _participants.length) {
      _activeParticipantIndex = 0;
    }

    _remainingRerolls = 3;
    _usedPackIdsInCurrentTurn.clear();
    _prepareManagerChoicesForActive();
    _phase = LeagueDraftPhase.pickManager;
    notifyListeners();
  }

  /// Start a Solo League (User + AI Managers) or Friends + AI Bots League up to leagueCapacity
  void startDraft({
    required List<String> playerNames,
    required bool isSoloMode,
    int? leagueCapacity,
  }) {
    _participants.clear();
    _fixtures.clear();
    _latestSimulatedFixture = null;
    _goalScorerCounts.clear();
    _goalScorerClubTags.clear();
    _championshipAwardedForCurrentSeason = false;

    final targetCap = leagueCapacity ?? (isSoloMode ? 4 : max(_leagueCapacity, playerNames.length));
    _leagueCapacity = targetCap.clamp(2, 12);
    _lobbySlots.clear();

    if (isSoloMode) {
      final humanName = playerNames.isNotEmpty && playerNames.first.trim().isNotEmpty
          ? playerNames.first.trim()
          : 'Kaptan FC';
      _lobbySlots.add(
        LeagueLobbySlot(slotIndex: 0, name: humanName, isBot: false, isHost: true),
      );
      for (int i = 1; i < _leagueCapacity; i++) {
        final bName = _defaultBotNames[(i - 1) % _defaultBotNames.length];
        _lobbySlots.add(
          LeagueLobbySlot(slotIndex: i, name: bName, isBot: true, isHost: false),
        );
      }
    } else {
      for (int i = 0; i < playerNames.length; i++) {
        final clean = playerNames[i].trim().isEmpty
            ? 'Oyuncu ${i + 1}'
            : playerNames[i].trim();
        _lobbySlots.add(
          LeagueLobbySlot(slotIndex: i, name: clean, isBot: false, isHost: i == 0),
        );
      }
      // If leagueCapacity is larger than invited human count, fill the rest with AI Bots!
      if (leagueCapacity != null && _lobbySlots.length < _leagueCapacity) {
        int botIdx = 0;
        while (_lobbySlots.length < _leagueCapacity) {
          final bName = _defaultBotNames[botIdx % _defaultBotNames.length];
          botIdx++;
          _lobbySlots.add(
            LeagueLobbySlot(
              slotIndex: _lobbySlots.length,
              name: bName,
              isBot: true,
              isHost: false,
            ),
          );
        }
      } else {
        _leagueCapacity = _lobbySlots.length;
      }
    }

    startDraftFromLobby();
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

  /// Allows the active human participant to reroll for a different Historical Year+Club Pack (3 times per turn)
  void rerollCurrentClubPack() {
    if (_remainingRerolls <= 0) return;
    _remainingRerolls--;
    _spinNextHistoricalClubForActive();
    notifyListeners();
  }

  void _spinNextHistoricalClubForActive() {
    final neededRole = currentNeededRole;
    final alreadyPickedIds = activeParticipant.squad.map((e) => e.id).toSet();

    // Filter packs from the selected pool that were not already spun in this turn
    final pool = activePoolPacks.isNotEmpty ? activePoolPacks : allEraClubPacks;
    final freshPool = pool.where((p) => !_usedPackIdsInCurrentTurn.contains(p.id)).toList();
    final candidatePacks = (freshPool.isNotEmpty ? freshPool : List<EraClubPack>.from(pool))
      ..shuffle(_rng);

    EraClubPack chosenPack = candidatePacks.first;

    for (final pack in candidatePacks) {
      final matching = pack.roster
          .where((p) => p.role == neededRole && !alreadyPickedIds.contains(p.id))
          .toList();
      if (matching.isNotEmpty) {
        chosenPack = pack;
        break;
      }
    }

    _usedPackIdsInCurrentTurn.add(chosenPack.id);
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
    _remainingRerolls = 3;
    _usedPackIdsInCurrentTurn.clear();
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
    final pool = activePoolPacks.isNotEmpty ? activePoolPacks : allEraClubPacks;
    final packs = List<EraClubPack>.from(pool);

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

  /// Simulates the next single unplayed fixture so results flow one by one in front of the user
  LeagueMatchFixture? simulateNextSingleFixture() {
    if (isAllFixturesPlayed) return null;

    final nextUnplayed = _fixtures.where((f) => !f.isPlayed).toList();
    if (nextUnplayed.isEmpty) return null;

    final match = nextUnplayed.first;
    _currentMatchday = match.matchday;
    _simulateSingleMatch(match);
    _latestSimulatedFixture = match;

    final remaining = _fixtures.where((f) => !f.isPlayed).toList();
    if (remaining.isNotEmpty) {
      _currentMatchday = remaining.first.matchday;
    } else {
      _currentMatchday = _totalMatchdays;
      _checkAndAwardChampionshipIfFinished();
    }

    notifyListeners();
    return match;
  }

  /// Simulates all matches of the current matchday
  void simulateNextMatchday() {
    if (isAllFixturesPlayed) return;

    final dayMatches = _fixtures
        .where((f) => f.matchday == _currentMatchday && !f.isPlayed)
        .toList();

    for (final match in dayMatches) {
      _simulateSingleMatch(match);
      _latestSimulatedFixture = match;
    }

    if (_currentMatchday < _totalMatchdays) {
      final nextUnplayed = _fixtures.where((f) => !f.isPlayed).toList();
      if (nextUnplayed.isNotEmpty) {
        _currentMatchday = nextUnplayed.first.matchday;
      }
    }

    if (isAllFixturesPlayed) {
      _checkAndAwardChampionshipIfFinished();
    }

    notifyListeners();
  }

  /// Simulates all remaining matchdays at once
  void simulateAllRemainingMatchdays() {
    for (final match in _fixtures) {
      if (!match.isPlayed) {
        _simulateSingleMatch(match);
        _latestSimulatedFixture = match;
      }
    }
    _currentMatchday = _totalMatchdays;
    _checkAndAwardChampionshipIfFinished();
    notifyListeners();
  }

  void _checkAndAwardChampionshipIfFinished() {
    if (_championshipAwardedForCurrentSeason || !isAllFixturesPlayed) return;
    final winner = champion;
    if (winner == null) return;
    _championshipAwardedForCurrentSeason = true;
    winner.championshipsWon += 1;

    for (final slot in _lobbySlots) {
      if (slot.name == winner.name) {
        slot.championshipsWon = winner.championshipsWon;
        break;
      }
    }
  }

  /// Resets the current league scores and replays the season with the same drafted squads
  void replaySeasonWithSameSquads() {
    _championshipAwardedForCurrentSeason = false;
    _latestSimulatedFixture = null;
    _generateLeagueFixtures();
    notifyListeners();
  }

  /// Returns to the same Online/Invite Lobby for the next season, keeping room code, friends, bots, and trophy counts
  void continueToLobbyForNextSeason() {
    _checkAndAwardChampionshipIfFinished();
    _seasonNumber += 1;
    _fixtures.clear();
    _latestSimulatedFixture = null;
    _goalScorerCounts.clear();
    _goalScorerClubTags.clear();
    _participants.clear();
    _phase = LeagueDraftPhase.setup;
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
    ManagerOption(
      id: 'mgr_sergen',
      name: 'Sergen Yalçın',
      nationality: 'Türkiye',
      styleTitle: 'Yaratıcı Hücum & Büyük Maç Ustası',
      bonusDescription: '+5 Hücum • +2 Savunma',
      rating: 90,
      attackBonus: 5,
      defenseBonus: 2,
    ),
    ManagerOption(
      id: 'mgr_denizli',
      name: 'Mustafa Denizli',
      nationality: 'Türkiye',
      styleTitle: '3 Büyüklerle Şampiyonluk & Avrupa Yarı Finali',
      bonusDescription: '+4 Hücum • +4 Savunma',
      rating: 91,
      attackBonus: 4,
      defenseBonus: 4,
    ),
    ManagerOption(
      id: 'mgr_lucescu',
      name: 'Mircea Lucescu',
      nationality: 'Romanya',
      styleTitle: 'Satranç Ustası • Süper Kupa & 100. Yıl',
      bonusDescription: '+3 Hücum • +5 Taktik Savunma',
      rating: 92,
      attackBonus: 3,
      defenseBonus: 5,
    ),
    ManagerOption(
      id: 'mgr_aykut',
      name: 'Aykut Kocaman',
      nationality: 'Türkiye',
      styleTitle: 'UEFA Yarı Finali & Sistem Disiplini',
      bonusDescription: '+3 Hücum • +5 Savunma Organizasyonu',
      rating: 89,
      attackBonus: 3,
      defenseBonus: 5,
    ),
    ManagerOption(
      id: 'mgr_alonso',
      name: 'Xabi Alonso',
      nationality: 'İspanya',
      styleTitle: 'Namağlup Modern Taktisyen',
      bonusDescription: '+5 Hücum • +4 Savunma',
      rating: 94,
      attackBonus: 5,
      defenseBonus: 4,
    ),
    ManagerOption(
      id: 'mgr_arteta',
      name: 'Mikel Arteta',
      nationality: 'İspanya',
      styleTitle: 'Duran Top & Mikro Alan Kontrolü',
      bonusDescription: '+4 Hücum • +5 Savunma',
      rating: 92,
      attackBonus: 4,
      defenseBonus: 5,
    ),
    ManagerOption(
      id: 'mgr_conte',
      name: 'Antonio Conte',
      nationality: 'İtalya',
      styleTitle: '3-5-2 Kanat Bek & Tutkulu Pres',
      bonusDescription: '+4 Hücum • +5 Savunma',
      rating: 93,
      attackBonus: 4,
      defenseBonus: 5,
    ),
    ManagerOption(
      id: 'mgr_enrique',
      name: 'Luis Enrique',
      nationality: 'İspanya',
      styleTitle: 'MSN Üçleme (Treble) Mimarı',
      bonusDescription: '+6 Hücum • +2 Savunma',
      rating: 93,
      attackBonus: 6,
      defenseBonus: 2,
    ),
    ManagerOption(
      id: 'mgr_tuchel',
      name: 'Thomas Tuchel',
      nationality: 'Almanya',
      styleTitle: 'Eleme Turları & Taktik Bukalemun',
      bonusDescription: '+3 Hücum • +6 Savunma',
      rating: 92,
      attackBonus: 3,
      defenseBonus: 6,
    ),
    ManagerOption(
      id: 'mgr_inzaghi',
      name: 'Simone Inzaghi',
      nationality: 'İtalya',
      styleTitle: 'Akışkan 3-5-2 & Geçiş Oyunu',
      bonusDescription: '+4 Hücum • +5 Savunma',
      rating: 92,
      attackBonus: 4,
      defenseBonus: 5,
    ),
    ManagerOption(
      id: 'mgr_emery',
      name: 'Unai Emery',
      nationality: 'İspanya',
      styleTitle: 'Avrupa Kupaları & Analiz Uzmanı',
      bonusDescription: '+4 Hücum • +4 Savunma',
      rating: 91,
      attackBonus: 4,
      defenseBonus: 4,
    ),
    ManagerOption(
      id: 'mgr_ranieri',
      name: 'Claudio Ranieri',
      nationality: 'İtalya',
      styleTitle: 'Leicester Mucizesi & Hızlı Kontra',
      bonusDescription: '+4 Kontra Hücum • +5 Savunma',
      rating: 91,
      attackBonus: 4,
      defenseBonus: 5,
    ),
    ManagerOption(
      id: 'mgr_capello',
      name: 'Fabio Capello',
      nationality: 'İtalya',
      styleTitle: 'Yenilmez İtalyan Disiplini',
      bonusDescription: '+3 Hücum • +6 Demir Savunma',
      rating: 94,
      attackBonus: 3,
      defenseBonus: 6,
    ),
    ManagerOption(
      id: 'mgr_lippi',
      name: 'Marcello Lippi',
      nationality: 'İtalya',
      styleTitle: '2006 Dünya Kupası & ŞL Şampiyonu',
      bonusDescription: '+4 Hücum • +5 Savunma',
      rating: 94,
      attackBonus: 4,
      defenseBonus: 5,
    ),
    ManagerOption(
      id: 'mgr_delbosque',
      name: 'Vicente del Bosque',
      nationality: 'İspanya',
      styleTitle: 'Dünya & Avrupa Şampiyonu Bilge',
      bonusDescription: '+5 Hücum • +4 Savunma',
      rating: 95,
      attackBonus: 5,
      defenseBonus: 4,
    ),
    ManagerOption(
      id: 'mgr_heynckes',
      name: 'Jupp Heynckes',
      nationality: 'Almanya',
      styleTitle: '2013 Kusursuz Alman Üçlemesi',
      bonusDescription: '+5 Hücum • +4 Savunma',
      rating: 95,
      attackBonus: 5,
      defenseBonus: 4,
    ),
    ManagerOption(
      id: 'mgr_vangaal',
      name: 'Louis van Gaal',
      nationality: 'Hollanda',
      styleTitle: 'Ajax 95 Gençlik Akademisi & Sistem',
      bonusDescription: '+5 Hücum • +3 Savunma',
      rating: 93,
      attackBonus: 5,
      defenseBonus: 3,
    ),
    ManagerOption(
      id: 'mgr_bielsa',
      name: 'Marcelo Bielsa',
      nationality: 'Arjantin',
      styleTitle: 'El Loco • Durmaksızın Adam Adama Pres',
      bonusDescription: '+6 Hücum Coşkusu • +1 Savunma',
      rating: 90,
      attackBonus: 6,
      defenseBonus: 1,
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
    FormationOption(
      id: 'form_41212',
      code: '4-1-2-1-2',
      title: '4-1-2-1-2 Elmas (Dar Merkez)',
      description: '4 Defans • 4 Elmas Orta Saha • 2 Forvet',
      defenders: 4,
      midfielders: 4,
      forwards: 2,
      attackBonus: 4,
      defenseBonus: 2,
    ),
    FormationOption(
      id: 'form_4321',
      code: '4-3-2-1',
      title: '4-3-2-1 Çam Ağacı (Ancelotti)',
      description: '4 Defans • 5 Orta Saha / 10 Numara • 1 Forvet',
      defenders: 4,
      midfielders: 5,
      forwards: 1,
      attackBonus: 3,
      defenseBonus: 4,
    ),
    FormationOption(
      id: 'form_424',
      code: '4-2-4',
      title: '4-2-4 Brezilya Samba Hücumu',
      description: '4 Defans • 2 Orta Saha • 4 Hücumcu',
      defenders: 4,
      midfielders: 2,
      forwards: 4,
      attackBonus: 6,
      defenseBonus: 0,
    ),
    FormationOption(
      id: 'form_541',
      code: '5-4-1',
      title: '5-4-1 Catenaccio Kalesi',
      description: '5 Defans • 4 Orta Saha • 1 Kontra Forvet',
      defenders: 5,
      midfielders: 4,
      forwards: 1,
      attackBonus: 1,
      defenseBonus: 6,
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
    // --- EK SÜPER LİG TARİHİ SEZON PAKETLERİ ---
    EraClubPack(
      id: 'gs_2023_24',
      clubId: 'galatasaray',
      clubName: 'Galatasaray',
      seasonLabel: '2023-24',
      eraTitle: '102 Puanlı Rekor Şampiyonluk Kadrosu',
      roster: [
        EraPlayerCandidate(id: 'muslera_24', name: 'Fernando Muslera', role: 'GK', specificPosition: 'KL', rating: 89, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'davinson_24', name: 'Davinson Sánchez', role: 'DEF', specificPosition: 'STP', rating: 89, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'boey_24', name: 'Sacha Boey', role: 'DEF', specificPosition: 'SĞB', rating: 88, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'abdulkerim_24', name: 'Abdülkerim Bardakcı', role: 'DEF', specificPosition: 'STP', rating: 87, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'torreira_24', name: 'Lucas Torreira', role: 'MID', specificPosition: 'DOS', rating: 90, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'mertens_24', name: 'Dries Mertens', role: 'MID', specificPosition: 'OOS', rating: 90, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'icardi_24', name: 'Mauro Icardi', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'barisalper_24', name: 'Barış Alper Yılmaz', role: 'FWD', specificPosition: 'SĞK', rating: 88, clubId: 'galatasaray', clubName: 'Galatasaray', seasonLabel: '2023-24'),
      ],
    ),
    EraClubPack(
      id: 'fb_2004_05',
      clubId: 'fenerbahce',
      clubName: 'Fenerbahçe',
      seasonLabel: '2004-05',
      eraTitle: 'Alex, Hooijdonk & Anelka Şampiyonluğu',
      roster: [
        EraPlayerCandidate(id: 'rustu_05', name: 'Rüştü Reçber', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'luciano_05', name: 'Fábio Luciano', role: 'DEF', specificPosition: 'STP', rating: 88, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'umitozat_05', name: 'Ümit Özat', role: 'DEF', specificPosition: 'SLB', rating: 87, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'appiah_05', name: 'Stephen Appiah', role: 'MID', specificPosition: 'OS', rating: 90, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'tuncay_05', name: 'Tuncay Şanlı', role: 'MID', specificPosition: 'SLK', rating: 89, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'hooijdonk_05', name: 'Pierre van Hooijdonk', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'nobre_05', name: 'Mert Nobre', role: 'FWD', specificPosition: 'SNT', rating: 88, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2004-05'),
      ],
    ),
    EraClubPack(
      id: 'fb_2023_24',
      clubId: 'fenerbahce',
      clubName: 'Fenerbahçe',
      seasonLabel: '2023-24',
      eraTitle: '99 Puan & 99 Gol Kadrosu',
      roster: [
        EraPlayerCandidate(id: 'livakovic_24', name: 'Dominik Livaković', role: 'GK', specificPosition: 'KL', rating: 88, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'ferdi_24', name: 'Ferdi Kadıoğlu', role: 'DEF', specificPosition: 'SLB', rating: 90, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'djiku_24', name: 'Alexander Djiku', role: 'DEF', specificPosition: 'STP', rating: 87, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'fred_24', name: 'Fred', role: 'MID', specificPosition: 'OS', rating: 89, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'szymanski_24', name: 'Sebastian Szymański', role: 'MID', specificPosition: 'OOS', rating: 88, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'irfancan_24', name: 'İrfan Can Kahveci', role: 'MID', specificPosition: 'SĞK', rating: 89, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'dzeko_24', name: 'Edin Džeko', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'tadic_24', name: 'Dušan Tadić', role: 'FWD', specificPosition: 'SLK', rating: 90, clubId: 'fenerbahce', clubName: 'Fenerbahçe', seasonLabel: '2023-24'),
      ],
    ),
    EraClubPack(
      id: 'bjk_2002_03',
      clubId: 'besiktas',
      clubName: 'Beşiktaş',
      seasonLabel: '2002-03',
      eraTitle: '100. Yıl Efsane Şampiyon Kadrosu',
      roster: [
        EraPlayerCandidate(id: 'cordoba_03', name: 'Óscar Córdoba', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2002-03'),
        EraPlayerCandidate(id: 'zago_03', name: 'Antonio Carlos Zago', role: 'DEF', specificPosition: 'STP', rating: 89, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2002-03'),
        EraPlayerCandidate(id: 'uzulmez_03', name: 'İbrahim Üzülmez', role: 'DEF', specificPosition: 'SLB', rating: 87, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2002-03'),
        EraPlayerCandidate(id: 'sergen_03', name: 'Sergen Yalçın', role: 'MID', specificPosition: 'OOS', rating: 93, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2002-03'),
        EraPlayerCandidate(id: 'tumer_03', name: 'Tümer Metin', role: 'MID', specificPosition: 'OS', rating: 88, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2002-03'),
        EraPlayerCandidate(id: 'ilhan_03', name: 'İlhan Mansız', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2002-03'),
        EraPlayerCandidate(id: 'nouma_03', name: 'Pascal Nouma', role: 'FWD', specificPosition: 'SNT', rating: 89, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2002-03'),
      ],
    ),
    EraClubPack(
      id: 'bjk_2020_21',
      clubId: 'besiktas',
      clubName: 'Beşiktaş',
      seasonLabel: '2020-21',
      eraTitle: 'Sergen Yalçın Çifte Kupa Şampiyonluğu',
      roster: [
        EraPlayerCandidate(id: 'ersin_21', name: 'Ersin Destanoğlu', role: 'GK', specificPosition: 'KL', rating: 85, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'vida_21', name: 'Domagoj Vida', role: 'DEF', specificPosition: 'STP', rating: 88, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'rosier_21', name: 'Valentin Rosier', role: 'DEF', specificPosition: 'SĞB', rating: 87, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'josef_21', name: 'Josef de Souza', role: 'MID', specificPosition: 'DOS', rating: 89, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'ghezzal_21', name: 'Rachid Ghezzal', role: 'MID', specificPosition: 'SĞK', rating: 90, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'aboubakar_21', name: 'Vincent Aboubakar', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'larin_21', name: 'Cyle Larin', role: 'FWD', specificPosition: 'SNT', rating: 88, clubId: 'besiktas', clubName: 'Beşiktaş', seasonLabel: '2020-21'),
      ],
    ),
    EraClubPack(
      id: 'ts_2021_22',
      clubId: 'trabzonspor',
      clubName: 'Trabzonspor',
      seasonLabel: '2021-22',
      eraTitle: 'Karadeniz Fırtınası Şampiyonluk Sezonu',
      roster: [
        EraPlayerCandidate(id: 'ugurcan_22', name: 'Uğurcan Çakır', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'vhugo_22', name: 'Vitor Hugo', role: 'DEF', specificPosition: 'STP', rating: 87, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'bperes_22', name: 'Bruno Peres', role: 'DEF', specificPosition: 'SĞB', rating: 86, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'hamsik_22', name: 'Marek Hamšík', role: 'MID', specificPosition: 'OS', rating: 91, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'bakasetas_22', name: 'Anastasios Bakasetas', role: 'MID', specificPosition: 'OOS', rating: 88, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'nwakaeme_22', name: 'Anthony Nwakaeme', role: 'FWD', specificPosition: 'SLK', rating: 90, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'visca_22', name: 'Edin Višća', role: 'FWD', specificPosition: 'SĞK', rating: 89, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'cornelius_22', name: 'Andreas Cornelius', role: 'FWD', specificPosition: 'SNT', rating: 88, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2021-22'),
      ],
    ),
    EraClubPack(
      id: 'ts_2010_11',
      clubId: 'trabzonspor',
      clubName: 'Trabzonspor',
      seasonLabel: '2010-11',
      eraTitle: '82 Puanlı Efsane Fırtına Kadrosu',
      roster: [
        EraPlayerCandidate(id: 'onur_11', name: 'Onur Kıvrak', role: 'GK', specificPosition: 'KL', rating: 89, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2010-11'),
        EraPlayerCandidate(id: 'egemen_11', name: 'Egemen Korkmaz', role: 'DEF', specificPosition: 'STP', rating: 87, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2010-11'),
        EraPlayerCandidate(id: 'selcuk_11', name: 'Selçuk İnan', role: 'MID', specificPosition: 'OS', rating: 90, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2010-11'),
        EraPlayerCandidate(id: 'colman_11', name: 'Gustavo Colman', role: 'MID', specificPosition: 'OS', rating: 88, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2010-11'),
        EraPlayerCandidate(id: 'jaja_11', name: 'Jajá Coelho', role: 'MID', specificPosition: 'OOS', rating: 89, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2010-11'),
        EraPlayerCandidate(id: 'burak_ts11', name: 'Burak Yılmaz', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2010-11'),
        EraPlayerCandidate(id: 'yattara_11', name: 'İbrahima Yattara', role: 'FWD', specificPosition: 'SĞK', rating: 89, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '2010-11'),
      ],
    ),
    EraClubPack(
      id: 'ts_1995_96',
      clubId: 'trabzonspor',
      clubName: 'Trabzonspor',
      seasonLabel: '1995-96',
      eraTitle: 'Şota & Hami Mandıralı Efsanesi',
      roster: [
        EraPlayerCandidate(id: 'metin_96', name: 'Metin Aktaş', role: 'GK', specificPosition: 'KL', rating: 85, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '1995-96'),
        EraPlayerCandidate(id: 'ogun_96', name: 'Ogün Temizkanoğlu', role: 'DEF', specificPosition: 'STP', rating: 89, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '1995-96'),
        EraPlayerCandidate(id: 'abdullah_96', name: 'Abdullah Ercan', role: 'DEF', specificPosition: 'SLB', rating: 89, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '1995-96'),
        EraPlayerCandidate(id: 'unal_96', name: 'Ünal Karaman', role: 'MID', specificPosition: 'OS', rating: 89, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '1995-96'),
        EraPlayerCandidate(id: 'tolunay_96', name: 'Tolunay Kafkas', role: 'MID', specificPosition: 'DOS', rating: 87, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '1995-96'),
        EraPlayerCandidate(id: 'hami_96', name: 'Hami Mandıralı', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '1995-96'),
        EraPlayerCandidate(id: 'shota_96', name: 'Şota Arveladze', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'trabzonspor', clubName: 'Trabzonspor', seasonLabel: '1995-96'),
      ],
    ),
    EraClubPack(
      id: 'bursa_2009_10',
      clubId: 'bursaspor',
      clubName: 'Bursaspor',
      seasonLabel: '2009-10',
      eraTitle: 'Anadolu Devrimi Süper Lig Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'ivankov_10', name: 'Dimitar Ivankov', role: 'GK', specificPosition: 'KL', rating: 87, clubId: 'bursaspor', clubName: 'Bursaspor', seasonLabel: '2009-10'),
        EraPlayerCandidate(id: 'omer_10', name: 'Ömer Erdoğan', role: 'DEF', specificPosition: 'STP', rating: 87, clubId: 'bursaspor', clubName: 'Bursaspor', seasonLabel: '2009-10'),
        EraPlayerCandidate(id: 'alitandogan_10', name: 'Ali Tandoğan', role: 'DEF', specificPosition: 'SĞB', rating: 86, clubId: 'bursaspor', clubName: 'Bursaspor', seasonLabel: '2009-10'),
        EraPlayerCandidate(id: 'batalla_10', name: 'Pablo Batalla', role: 'MID', specificPosition: 'OOS', rating: 91, clubId: 'bursaspor', clubName: 'Bursaspor', seasonLabel: '2009-10'),
        EraPlayerCandidate(id: 'ergic_10', name: 'Ivan Ergić', role: 'MID', specificPosition: 'OS', rating: 87, clubId: 'bursaspor', clubName: 'Bursaspor', seasonLabel: '2009-10'),
        EraPlayerCandidate(id: 'volkansen_10', name: 'Volkan Şen', role: 'FWD', specificPosition: 'SĞK', rating: 87, clubId: 'bursaspor', clubName: 'Bursaspor', seasonLabel: '2009-10'),
        EraPlayerCandidate(id: 'sercan_10', name: 'Sercan Yıldırım', role: 'FWD', specificPosition: 'SNT', rating: 86, clubId: 'bursaspor', clubName: 'Bursaspor', seasonLabel: '2009-10'),
      ],
    ),
    EraClubPack(
      id: 'basaksehir_2019_20',
      clubId: 'basaksehir',
      clubName: 'Başakşehir',
      seasonLabel: '2019-20',
      eraTitle: '2019-20 Süper Lig Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'mert_20', name: 'Mert Günok', role: 'GK', specificPosition: 'KL', rating: 88, clubId: 'basaksehir', clubName: 'Başakşehir', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'skrtel_20', name: 'Martin Škrtel', role: 'DEF', specificPosition: 'STP', rating: 88, clubId: 'basaksehir', clubName: 'Başakşehir', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'clichy_20', name: 'Gaël Clichy', role: 'DEF', specificPosition: 'SLB', rating: 87, clubId: 'basaksehir', clubName: 'Başakşehir', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'irfan_20', name: 'İrfan Can Kahveci', role: 'MID', specificPosition: 'OS', rating: 88, clubId: 'basaksehir', clubName: 'Başakşehir', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'visca_20', name: 'Edin Višća', role: 'FWD', specificPosition: 'SĞK', rating: 90, clubId: 'basaksehir', clubName: 'Başakşehir', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'dembaba_20', name: 'Demba Ba', role: 'FWD', specificPosition: 'SNT', rating: 88, clubId: 'basaksehir', clubName: 'Başakşehir', seasonLabel: '2019-20'),
      ],
    ),
    EraClubPack(
      id: 'sivas_2008_09',
      clubId: 'sivasspor',
      clubName: 'Sivasspor',
      seasonLabel: '2008-09',
      eraTitle: 'Şampiyonluk Yarışı & Yiğidolar Efsanesi',
      roster: [
        EraPlayerCandidate(id: 'petkovic_09', name: 'Michael Petkovic', role: 'GK', specificPosition: 'KL', rating: 85, clubId: 'sivasspor', clubName: 'Sivasspor', seasonLabel: '2008-09'),
        EraPlayerCandidate(id: 'bilica_09', name: 'Fábio Bilica', role: 'DEF', specificPosition: 'STP', rating: 85, clubId: 'sivasspor', clubName: 'Sivasspor', seasonLabel: '2008-09'),
        EraPlayerCandidate(id: 'abdurrahman_09', name: 'Abdurrahman Dereli', role: 'DEF', specificPosition: 'SĞB', rating: 84, clubId: 'sivasspor', clubName: 'Sivasspor', seasonLabel: '2008-09'),
        EraPlayerCandidate(id: 'musa_09', name: 'Musa Aydın', role: 'MID', specificPosition: 'OS', rating: 85, clubId: 'sivasspor', clubName: 'Sivasspor', seasonLabel: '2008-09'),
        EraPlayerCandidate(id: 'mehmetyildiz_09', name: 'Mehmet Yıldız', role: 'FWD', specificPosition: 'SNT', rating: 87, clubId: 'sivasspor', clubName: 'Sivasspor', seasonLabel: '2008-09'),
        EraPlayerCandidate(id: 'balili_09', name: 'Pini Balili', role: 'FWD', specificPosition: 'SNT', rating: 85, clubId: 'sivasspor', clubName: 'Sivasspor', seasonLabel: '2008-09'),
      ],
    ),
    EraClubPack(
      id: 'ads_2022_23',
      clubId: 'adana_demirspor',
      clubName: 'Adana Demirspor',
      seasonLabel: '2022-23',
      eraTitle: 'Mavi Şimşekler Avrupa Yürüyüşü',
      roster: [
        EraPlayerCandidate(id: 'ertac_23', name: 'Ertaç Özbir', role: 'GK', specificPosition: 'KL', rating: 84, clubId: 'adana_demirspor', clubName: 'Adana Demirspor', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'svensson_23', name: 'Jonas Svensson', role: 'DEF', specificPosition: 'SĞB', rating: 85, clubId: 'adana_demirspor', clubName: 'Adana Demirspor', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'belhanda_23', name: 'Younès Belhanda', role: 'MID', specificPosition: 'OOS', rating: 87, clubId: 'adana_demirspor', clubName: 'Adana Demirspor', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'ndiaye_23', name: 'Badou Ndiaye', role: 'MID', specificPosition: 'OS', rating: 86, clubId: 'adana_demirspor', clubName: 'Adana Demirspor', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'balotelli_22', name: 'Mario Balotelli', role: 'FWD', specificPosition: 'SNT', rating: 89, clubId: 'adana_demirspor', clubName: 'Adana Demirspor', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'onyekuru_23', name: 'Henry Onyekuru', role: 'FWD', specificPosition: 'SLK', rating: 87, clubId: 'adana_demirspor', clubName: 'Adana Demirspor', seasonLabel: '2022-23'),
      ],
    ),
    EraClubPack(
      id: 'samsun_1993_94',
      clubId: 'samsunspor',
      clubName: 'Samsunspor',
      seasonLabel: '1993-94',
      eraTitle: 'Karadeniz Efsanesi Tanju & Serkan Dönemi',
      roster: [
        EraPlayerCandidate(id: 'goksel_94', name: 'Göksel Gencer', role: 'GK', specificPosition: 'KL', rating: 84, clubId: 'samsunspor', clubName: 'Samsunspor', seasonLabel: '1993-94'),
        EraPlayerCandidate(id: 'ercan_94', name: 'Ercan Koloğlu', role: 'DEF', specificPosition: 'STP', rating: 86, clubId: 'samsunspor', clubName: 'Samsunspor', seasonLabel: '1993-94'),
        EraPlayerCandidate(id: 'ertugrul_94', name: 'Ertuğrul Sağlam', role: 'MID', specificPosition: 'OOS', rating: 89, clubId: 'samsunspor', clubName: 'Samsunspor', seasonLabel: '1993-94'),
        EraPlayerCandidate(id: 'celil_94', name: 'Celil Sağır', role: 'MID', specificPosition: 'OS', rating: 86, clubId: 'samsunspor', clubName: 'Samsunspor', seasonLabel: '1993-94'),
        EraPlayerCandidate(id: 'tanju_87', name: 'Tanju Çolak', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'samsunspor', clubName: 'Samsunspor', seasonLabel: '1986-87'),
        EraPlayerCandidate(id: 'serkan_94', name: 'Serkan Aykut', role: 'FWD', specificPosition: 'SNT', rating: 89, clubId: 'samsunspor', clubName: 'Samsunspor', seasonLabel: '1999-00'),
      ],
    ),

    // --- EK PREMIER LEAGUE TARİHİ SEZON PAKETLERİ ---
    EraClubPack(
      id: 'arsenal_2023_24',
      clubId: 'arsenal',
      clubName: 'Arsenal',
      seasonLabel: '2023-24',
      eraTitle: 'Arteta\'nın Modern Kuzey Londra Gücü',
      roster: [
        EraPlayerCandidate(id: 'raya_24', name: 'David Raya', role: 'GK', specificPosition: 'KL', rating: 89, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'saliba_24', name: 'William Saliba', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'gabriel_24', name: 'Gabriel Magalhães', role: 'DEF', specificPosition: 'STP', rating: 90, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'rice_24', name: 'Declan Rice', role: 'MID', specificPosition: 'DOS', rating: 92, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'odegaard_24', name: 'Martin Ødegaard', role: 'MID', specificPosition: 'OOS', rating: 93, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'saka_24', name: 'Bukayo Saka', role: 'FWD', specificPosition: 'SĞK', rating: 93, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'havertz_24', name: 'Kai Havertz', role: 'FWD', specificPosition: 'SNT', rating: 89, clubId: 'arsenal', clubName: 'Arsenal', seasonLabel: '2023-24'),
      ],
    ),
    EraClubPack(
      id: 'manutd_1998_99',
      clubId: 'man_united',
      clubName: 'Manchester United',
      seasonLabel: '1998-99',
      eraTitle: 'Camp Nou Mucizesi & Tarihi Treble',
      roster: [
        EraPlayerCandidate(id: 'schmeichel_99', name: 'Peter Schmeichel', role: 'GK', specificPosition: 'KL', rating: 95, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'stam_99', name: 'Jaap Stam', role: 'DEF', specificPosition: 'STP', rating: 94, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'gneville_99', name: 'Gary Neville', role: 'DEF', specificPosition: 'SĞB', rating: 90, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'keane_99', name: 'Roy Keane', role: 'MID', specificPosition: 'OS', rating: 94, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'giggs_99', name: 'Ryan Giggs', role: 'MID', specificPosition: 'SLK', rating: 93, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'yorke_99', name: 'Dwight Yorke', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'solskjaer_99', name: 'Ole Gunnar Solskjær', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'man_united', clubName: 'Manchester United', seasonLabel: '1998-99'),
      ],
    ),
    EraClubPack(
      id: 'chelsea_2004_05',
      clubId: 'chelsea',
      clubName: 'Chelsea',
      seasonLabel: '2004-05',
      eraTitle: 'Mourinho Rekor Savunma (15 Gol Yiyen Şampiyon)',
      roster: [
        EraPlayerCandidate(id: 'cech_05', name: 'Petr Čech', role: 'GK', specificPosition: 'KL', rating: 95, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'terry_05', name: 'John Terry', role: 'DEF', specificPosition: 'STP', rating: 94, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'carvalho_05', name: 'Ricardo Carvalho', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'lampard_05', name: 'Frank Lampard', role: 'MID', specificPosition: 'OS', rating: 95, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'makelele_05', name: 'Claude Makélélé', role: 'MID', specificPosition: 'DOS', rating: 93, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'drogba_05', name: 'Didier Drogba', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'robben_05', name: 'Arjen Robben', role: 'FWD', specificPosition: 'SĞK', rating: 92, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2004-05'),
      ],
    ),
    EraClubPack(
      id: 'chelsea_2011_12',
      clubId: 'chelsea',
      clubName: 'Chelsea',
      seasonLabel: '2011-12',
      eraTitle: 'Münih\'te Şampiyonlar Ligi Zaferi',
      roster: [
        EraPlayerCandidate(id: 'cech_12', name: 'Petr Čech', role: 'GK', specificPosition: 'KL', rating: 94, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2011-12'),
        EraPlayerCandidate(id: 'acole_12', name: 'Ashley Cole', role: 'DEF', specificPosition: 'SLB', rating: 92, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2011-12'),
        EraPlayerCandidate(id: 'dluiz_12', name: 'David Luiz', role: 'DEF', specificPosition: 'STP', rating: 89, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2011-12'),
        EraPlayerCandidate(id: 'mata_12', name: 'Juan Mata', role: 'MID', specificPosition: 'OOS', rating: 91, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2011-12'),
        EraPlayerCandidate(id: 'ramires_12', name: 'Ramires', role: 'MID', specificPosition: 'OS', rating: 89, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2011-12'),
        EraPlayerCandidate(id: 'drogba_12', name: 'Didier Drogba', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2011-12'),
        EraPlayerCandidate(id: 'torres_12', name: 'Fernando Torres', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2011-12'),
      ],
    ),
    EraClubPack(
      id: 'chelsea_2020_21',
      clubId: 'chelsea',
      clubName: 'Chelsea',
      seasonLabel: '2020-21',
      eraTitle: 'Tuchel\'in Geçilmez Şampiyonlar Ligi Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'mendy_21', name: 'Édouard Mendy', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'tsilva_21', name: 'Thiago Silva', role: 'DEF', specificPosition: 'STP', rating: 93, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'rudiger_21', name: 'Antonio Rüdiger', role: 'DEF', specificPosition: 'STP', rating: 91, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'kante_21', name: 'N\'Golo Kanté', role: 'MID', specificPosition: 'DOS', rating: 95, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'jorginho_21', name: 'Jorginho', role: 'MID', specificPosition: 'OS', rating: 91, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'havertz_21', name: 'Kai Havertz', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'chelsea', clubName: 'Chelsea', seasonLabel: '2020-21'),
      ],
    ),
    EraClubPack(
      id: 'liv_2004_05',
      clubId: 'liverpool',
      clubName: 'Liverpool',
      seasonLabel: '2004-05',
      eraTitle: 'İstanbul Mucizesi Şampiyonlar Ligi Kadrosu',
      roster: [
        EraPlayerCandidate(id: 'dudek_05', name: 'Jerzy Dudek', role: 'GK', specificPosition: 'KL', rating: 89, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'carragher_05', name: 'Jamie Carragher', role: 'DEF', specificPosition: 'STP', rating: 91, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'hyypia_05', name: 'Sami Hyypiä', role: 'DEF', specificPosition: 'STP', rating: 90, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'riise_05', name: 'John Arne Riise', role: 'DEF', specificPosition: 'SLB', rating: 89, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'xabialonso_05', name: 'Xabi Alonso', role: 'MID', specificPosition: 'OS', rating: 93, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'lgarcia_05', name: 'Luis García', role: 'MID', specificPosition: 'OOS', rating: 89, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'baros_05', name: 'Milan Baroš', role: 'FWD', specificPosition: 'SNT', rating: 89, clubId: 'liverpool', clubName: 'Liverpool', seasonLabel: '2004-05'),
      ],
    ),
    EraClubPack(
      id: 'mancity_2017_18',
      clubId: 'man_city',
      clubName: 'Manchester City',
      seasonLabel: '2017-18',
      eraTitle: '100 Puanlı Centurions Kadrosu',
      roster: [
        EraPlayerCandidate(id: 'ederson_18', name: 'Ederson', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'man_city', clubName: 'Manchester City', seasonLabel: '2017-18'),
        EraPlayerCandidate(id: 'kompany_18', name: 'Vincent Kompany', role: 'DEF', specificPosition: 'STP', rating: 93, clubId: 'man_city', clubName: 'Manchester City', seasonLabel: '2017-18'),
        EraPlayerCandidate(id: 'dsilva_18', name: 'David Silva', role: 'MID', specificPosition: 'OS', rating: 94, clubId: 'man_city', clubName: 'Manchester City', seasonLabel: '2017-18'),
        EraPlayerCandidate(id: 'fernandinho_18', name: 'Fernandinho', role: 'MID', specificPosition: 'DOS', rating: 91, clubId: 'man_city', clubName: 'Manchester City', seasonLabel: '2017-18'),
        EraPlayerCandidate(id: 'aguero_18', name: 'Sergio Agüero', role: 'FWD', specificPosition: 'SNT', rating: 95, clubId: 'man_city', clubName: 'Manchester City', seasonLabel: '2017-18'),
        EraPlayerCandidate(id: 'sterling_18', name: 'Raheem Sterling', role: 'FWD', specificPosition: 'SĞK', rating: 91, clubId: 'man_city', clubName: 'Manchester City', seasonLabel: '2017-18'),
      ],
    ),
    EraClubPack(
      id: 'leicester_2015_16',
      clubId: 'leicester',
      clubName: 'Leicester City',
      seasonLabel: '2015-16',
      eraTitle: '5000\'e 1 Premier League Mucizesi',
      roster: [
        EraPlayerCandidate(id: 'kschmeichel_16', name: 'Kasper Schmeichel', role: 'GK', specificPosition: 'KL', rating: 89, clubId: 'leicester', clubName: 'Leicester City', seasonLabel: '2015-16'),
        EraPlayerCandidate(id: 'morgan_16', name: 'Wes Morgan', role: 'DEF', specificPosition: 'STP', rating: 87, clubId: 'leicester', clubName: 'Leicester City', seasonLabel: '2015-16'),
        EraPlayerCandidate(id: 'fuchs_16', name: 'Christian Fuchs', role: 'DEF', specificPosition: 'SLB', rating: 86, clubId: 'leicester', clubName: 'Leicester City', seasonLabel: '2015-16'),
        EraPlayerCandidate(id: 'kante_16', name: 'N\'Golo Kanté', role: 'MID', specificPosition: 'DOS', rating: 93, clubId: 'leicester', clubName: 'Leicester City', seasonLabel: '2015-16'),
        EraPlayerCandidate(id: 'mahrez_16', name: 'Riyad Mahrez', role: 'MID', specificPosition: 'SĞK', rating: 92, clubId: 'leicester', clubName: 'Leicester City', seasonLabel: '2015-16'),
        EraPlayerCandidate(id: 'vardy_16', name: 'Jamie Vardy', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'leicester', clubName: 'Leicester City', seasonLabel: '2015-16'),
      ],
    ),
    EraClubPack(
      id: 'tottenham_2018_19',
      clubId: 'tottenham',
      clubName: 'Tottenham Hotspur',
      seasonLabel: '2018-19',
      eraTitle: 'Şampiyonlar Ligi Finalisti Kadro',
      roster: [
        EraPlayerCandidate(id: 'lloris_19', name: 'Hugo Lloris', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'tottenham', clubName: 'Tottenham Hotspur', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'vertonghen_19', name: 'Jan Vertonghen', role: 'DEF', specificPosition: 'STP', rating: 90, clubId: 'tottenham', clubName: 'Tottenham Hotspur', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'alderweireld_19', name: 'Toby Alderweireld', role: 'DEF', specificPosition: 'STP', rating: 90, clubId: 'tottenham', clubName: 'Tottenham Hotspur', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'eriksen_19', name: 'Christian Eriksen', role: 'MID', specificPosition: 'OOS', rating: 92, clubId: 'tottenham', clubName: 'Tottenham Hotspur', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'dele_19', name: 'Dele Alli', role: 'MID', specificPosition: 'OOS', rating: 89, clubId: 'tottenham', clubName: 'Tottenham Hotspur', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'kane_19', name: 'Harry Kane', role: 'FWD', specificPosition: 'SNT', rating: 95, clubId: 'tottenham', clubName: 'Tottenham Hotspur', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'son_19', name: 'Son Heung-min', role: 'FWD', specificPosition: 'SLK', rating: 93, clubId: 'tottenham', clubName: 'Tottenham Hotspur', seasonLabel: '2018-19'),
      ],
    ),
    EraClubPack(
      id: 'newcastle_1995_96',
      clubId: 'newcastle',
      clubName: 'Newcastle United',
      seasonLabel: '1995-96',
      eraTitle: 'Shearer & Ginola "The Entertainers"',
      roster: [
        EraPlayerCandidate(id: 'given_96', name: 'Shay Given', role: 'GK', specificPosition: 'KL', rating: 89, clubId: 'newcastle', clubName: 'Newcastle United', seasonLabel: '1997-98'),
        EraPlayerCandidate(id: 'albert_96', name: 'Philippe Albert', role: 'DEF', specificPosition: 'STP', rating: 87, clubId: 'newcastle', clubName: 'Newcastle United', seasonLabel: '1995-96'),
        EraPlayerCandidate(id: 'ginola_96', name: 'David Ginola', role: 'MID', specificPosition: 'SLK', rating: 91, clubId: 'newcastle', clubName: 'Newcastle United', seasonLabel: '1995-96'),
        EraPlayerCandidate(id: 'speed_98', name: 'Gary Speed', role: 'MID', specificPosition: 'OS', rating: 88, clubId: 'newcastle', clubName: 'Newcastle United', seasonLabel: '1997-98'),
        EraPlayerCandidate(id: 'shearer_96', name: 'Alan Shearer', role: 'FWD', specificPosition: 'SNT', rating: 95, clubId: 'newcastle', clubName: 'Newcastle United', seasonLabel: '1996-97'),
        EraPlayerCandidate(id: 'ferdinand_les_96', name: 'Les Ferdinand', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'newcastle', clubName: 'Newcastle United', seasonLabel: '1995-96'),
      ],
    ),

    // --- EK LA LIGA TARİHİ SEZON PAKETLERİ ---
    EraClubPack(
      id: 'rm_2013_14',
      clubId: 'real_madrid',
      clubName: 'Real Madrid',
      seasonLabel: '2013-14',
      eraTitle: 'La Décima (92:48 Lizbon Zaferi)',
      roster: [
        EraPlayerCandidate(id: 'casillas_14', name: 'Iker Casillas', role: 'GK', specificPosition: 'KL', rating: 91, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'ramos_14', name: 'Sergio Ramos', role: 'DEF', specificPosition: 'STP', rating: 95, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'pepe_14', name: 'Pepe', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'dimaria_14', name: 'Ángel Di María', role: 'MID', specificPosition: 'OS', rating: 93, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'alonso_14', name: 'Xabi Alonso', role: 'MID', specificPosition: 'DOS', rating: 92, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'bale_14', name: 'Gareth Bale', role: 'FWD', specificPosition: 'SĞK', rating: 94, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'cr7_14', name: 'Cristiano Ronaldo', role: 'FWD', specificPosition: 'SNT', rating: 99, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2013-14'),
      ],
    ),
    EraClubPack(
      id: 'rm_2023_24',
      clubId: 'real_madrid',
      clubName: 'Real Madrid',
      seasonLabel: '2023-24',
      eraTitle: '15. Şampiyonlar Ligi & Yeni Nesil Galaktikos',
      roster: [
        EraPlayerCandidate(id: 'courtois_24', name: 'Thibaut Courtois', role: 'GK', specificPosition: 'KL', rating: 95, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'rudiger_24', name: 'Antonio Rüdiger', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'carvajal_24', name: 'Dani Carvajal', role: 'DEF', specificPosition: 'SĞB', rating: 92, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'bellingham_24', name: 'Jude Bellingham', role: 'MID', specificPosition: 'OOS', rating: 95, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'valverde_24', name: 'Federico Valverde', role: 'MID', specificPosition: 'OS', rating: 93, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'arda_24', name: 'Arda Güler', role: 'MID', specificPosition: 'OOS', rating: 88, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'vinicius_24', name: 'Vinícius Júnior', role: 'FWD', specificPosition: 'SLK', rating: 96, clubId: 'real_madrid', clubName: 'Real Madrid', seasonLabel: '2023-24'),
      ],
    ),
    EraClubPack(
      id: 'barca_2014_15',
      clubId: 'barcelona',
      clubName: 'Barcelona',
      seasonLabel: '2014-15',
      eraTitle: 'MSN (Messi-Suárez-Neymar) Treble Kadrosu',
      roster: [
        EraPlayerCandidate(id: 'terstegen_15', name: 'Marc-André ter Stegen', role: 'GK', specificPosition: 'KL', rating: 91, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2014-15'),
        EraPlayerCandidate(id: 'pique_15', name: 'Gerard Piqué', role: 'DEF', specificPosition: 'STP', rating: 93, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2014-15'),
        EraPlayerCandidate(id: 'alba_15', name: 'Jordi Alba', role: 'DEF', specificPosition: 'SLB', rating: 91, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2014-15'),
        EraPlayerCandidate(id: 'busquets_15', name: 'Sergio Busquets', role: 'MID', specificPosition: 'DOS', rating: 94, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2014-15'),
        EraPlayerCandidate(id: 'rakitic_15', name: 'Ivan Rakitić', role: 'MID', specificPosition: 'OS', rating: 91, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2014-15'),
        EraPlayerCandidate(id: 'suarez_15', name: 'Luis Suárez', role: 'FWD', specificPosition: 'SNT', rating: 96, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2014-15'),
        EraPlayerCandidate(id: 'neymar_15', name: 'Neymar Jr', role: 'FWD', specificPosition: 'SLK', rating: 96, clubId: 'barcelona', clubName: 'Barcelona', seasonLabel: '2014-15'),
      ],
    ),
    EraClubPack(
      id: 'atm_2013_14',
      clubId: 'atletico_madrid',
      clubName: 'Atlético Madrid',
      seasonLabel: '2013-14',
      eraTitle: 'Simeone & Arda Turan La Liga Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'courtois_14', name: 'Thibaut Courtois', role: 'GK', specificPosition: 'KL', rating: 92, clubId: 'atletico_madrid', clubName: 'Atlético Madrid', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'godin_14', name: 'Diego Godín', role: 'DEF', specificPosition: 'STP', rating: 94, clubId: 'atletico_madrid', clubName: 'Atlético Madrid', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'filipeluis_14', name: 'Filipe Luís', role: 'DEF', specificPosition: 'SLB', rating: 90, clubId: 'atletico_madrid', clubName: 'Atlético Madrid', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'ardaturan_14', name: 'Arda Turan', role: 'MID', specificPosition: 'OS', rating: 91, clubId: 'atletico_madrid', clubName: 'Atlético Madrid', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'koke_14', name: 'Koke', role: 'MID', specificPosition: 'OS', rating: 90, clubId: 'atletico_madrid', clubName: 'Atlético Madrid', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'dcosta_14', name: 'Diego Costa', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'atletico_madrid', clubName: 'Atlético Madrid', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'griezmann_16', name: 'Antoine Griezmann', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'atletico_madrid', clubName: 'Atlético Madrid', seasonLabel: '2015-16'),
      ],
    ),
    EraClubPack(
      id: 'sevilla_2015_16',
      clubId: 'sevilla',
      clubName: 'Sevilla',
      seasonLabel: '2015-16',
      eraTitle: 'Üst Üste 3. Avrupa Ligi Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'srico_16', name: 'Sergio Rico', role: 'GK', specificPosition: 'KL', rating: 86, clubId: 'sevilla', clubName: 'Sevilla', seasonLabel: '2015-16'),
        EraPlayerCandidate(id: 'rami_16', name: 'Adil Rami', role: 'DEF', specificPosition: 'STP', rating: 87, clubId: 'sevilla', clubName: 'Sevilla', seasonLabel: '2015-16'),
        EraPlayerCandidate(id: 'jnavas_16', name: 'Jesús Navas', role: 'DEF', specificPosition: 'SĞB', rating: 89, clubId: 'sevilla', clubName: 'Sevilla', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'banega_16', name: 'Éver Banega', role: 'MID', specificPosition: 'OOS', rating: 90, clubId: 'sevilla', clubName: 'Sevilla', seasonLabel: '2015-16'),
        EraPlayerCandidate(id: 'krychowiak_16', name: 'Grzegorz Krychowiak', role: 'MID', specificPosition: 'DOS', rating: 88, clubId: 'sevilla', clubName: 'Sevilla', seasonLabel: '2015-16'),
        EraPlayerCandidate(id: 'gameiro_16', name: 'Kévin Gameiro', role: 'FWD', specificPosition: 'SNT', rating: 89, clubId: 'sevilla', clubName: 'Sevilla', seasonLabel: '2015-16'),
        EraPlayerCandidate(id: 'kanoute_07', name: 'Frédéric Kanouté', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'sevilla', clubName: 'Sevilla', seasonLabel: '2006-07'),
      ],
    ),
    EraClubPack(
      id: 'valencia_2003_04',
      clubId: 'valencia',
      clubName: 'Valencia CF',
      seasonLabel: '2003-04',
      eraTitle: 'La Liga & UEFA Kupası Çifte Zaferi',
      roster: [
        EraPlayerCandidate(id: 'canizares_04', name: 'Santiago Cañizares', role: 'GK', specificPosition: 'KL', rating: 91, clubId: 'valencia', clubName: 'Valencia CF', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'ayala_04', name: 'Roberto Ayala', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'valencia', clubName: 'Valencia CF', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'marchena_04', name: 'Carlos Marchena', role: 'DEF', specificPosition: 'STP', rating: 89, clubId: 'valencia', clubName: 'Valencia CF', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'aimar_04', name: 'Pablo Aimar', role: 'MID', specificPosition: 'OOS', rating: 91, clubId: 'valencia', clubName: 'Valencia CF', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'baraja_04', name: 'Rubén Baraja', role: 'MID', specificPosition: 'OS', rating: 90, clubId: 'valencia', clubName: 'Valencia CF', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'vicente_04', name: 'Vicente Rodríguez', role: 'FWD', specificPosition: 'SLK', rating: 90, clubId: 'valencia', clubName: 'Valencia CF', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'mista_04', name: 'Mista', role: 'FWD', specificPosition: 'SNT', rating: 88, clubId: 'valencia', clubName: 'Valencia CF', seasonLabel: '2003-04'),
      ],
    ),
    EraClubPack(
      id: 'villarreal_2005_06',
      clubId: 'villarreal',
      clubName: 'Villarreal CF',
      seasonLabel: '2005-06',
      eraTitle: 'Riquelme & Forlán Sarı Denizaltı',
      roster: [
        EraPlayerCandidate(id: 'viera_06', name: 'Sebastián Viera', role: 'GK', specificPosition: 'KL', rating: 86, clubId: 'villarreal', clubName: 'Villarreal CF', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'grodriguez_06', name: 'Gonzalo Rodríguez', role: 'DEF', specificPosition: 'STP', rating: 88, clubId: 'villarreal', clubName: 'Villarreal CF', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'capdevila_08', name: 'Joan Capdevila', role: 'DEF', specificPosition: 'SLB', rating: 88, clubId: 'villarreal', clubName: 'Villarreal CF', seasonLabel: '2007-08'),
        EraPlayerCandidate(id: 'riquelme_06', name: 'Juan Román Riquelme', role: 'MID', specificPosition: 'OOS', rating: 94, clubId: 'villarreal', clubName: 'Villarreal CF', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'senna_06', name: 'Marcos Senna', role: 'MID', specificPosition: 'DOS', rating: 90, clubId: 'villarreal', clubName: 'Villarreal CF', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'forlan_06', name: 'Diego Forlán', role: 'FWD', specificPosition: 'SNT', rating: 93, clubId: 'villarreal', clubName: 'Villarreal CF', seasonLabel: '2005-06'),
      ],
    ),
    EraClubPack(
      id: 'deportivo_1999_00',
      clubId: 'deportivo',
      clubName: 'Deportivo La Coruña',
      seasonLabel: '1999-00',
      eraTitle: 'Super Depor La Liga Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'molina_00', name: 'José Francisco Molina', role: 'GK', specificPosition: 'KL', rating: 87, clubId: 'deportivo', clubName: 'Deportivo La Coruña', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'naybet_00', name: 'Noureddine Naybet', role: 'DEF', specificPosition: 'STP', rating: 90, clubId: 'deportivo', clubName: 'Deportivo La Coruña', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'djalminha_00', name: 'Djalminha', role: 'MID', specificPosition: 'OOS', rating: 92, clubId: 'deportivo', clubName: 'Deportivo La Coruña', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'valeron_02', name: 'Juan Carlos Valerón', role: 'MID', specificPosition: 'OOS', rating: 91, clubId: 'deportivo', clubName: 'Deportivo La Coruña', seasonLabel: '2001-02'),
        EraPlayerCandidate(id: 'makaay_00', name: 'Roy Makaay', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'deportivo', clubName: 'Deportivo La Coruña', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'tristan_02', name: 'Diego Tristán', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'deportivo', clubName: 'Deportivo La Coruña', seasonLabel: '2001-02'),
      ],
    ),
    EraClubPack(
      id: 'sociedad_2002_03',
      clubId: 'real_sociedad',
      clubName: 'Real Sociedad',
      seasonLabel: '2002-03',
      eraTitle: 'Nihat Kahveci & Kovacevic Fırtınası',
      roster: [
        EraPlayerCandidate(id: 'westerveld_03', name: 'Sander Westerveld', role: 'GK', specificPosition: 'KL', rating: 86, clubId: 'real_sociedad', clubName: 'Real Sociedad', seasonLabel: '2002-03'),
        EraPlayerCandidate(id: 'aranburu_03', name: 'Mikel Aranburu', role: 'DEF', specificPosition: 'SĞB', rating: 85, clubId: 'real_sociedad', clubName: 'Real Sociedad', seasonLabel: '2002-03'),
        EraPlayerCandidate(id: 'xabi_soc03', name: 'Xabi Alonso', role: 'MID', specificPosition: 'OS', rating: 90, clubId: 'real_sociedad', clubName: 'Real Sociedad', seasonLabel: '2002-03'),
        EraPlayerCandidate(id: 'karpin_03', name: 'Valeri Karpin', role: 'MID', specificPosition: 'SĞK', rating: 88, clubId: 'real_sociedad', clubName: 'Real Sociedad', seasonLabel: '2002-03'),
        EraPlayerCandidate(id: 'nihat_03', name: 'Nihat Kahveci', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'real_sociedad', clubName: 'Real Sociedad', seasonLabel: '2002-03'),
        EraPlayerCandidate(id: 'kovacevic_03', name: 'Darko Kovačević', role: 'FWD', specificPosition: 'SNT', rating: 89, clubId: 'real_sociedad', clubName: 'Real Sociedad', seasonLabel: '2002-03'),
      ],
    ),

    // --- EK SERIE A TARİHİ SEZON PAKETLERİ ---
    EraClubPack(
      id: 'milan_1989_90',
      clubId: 'milan',
      clubName: 'AC Milan',
      seasonLabel: '1989-90',
      eraTitle: 'Sacchi\'nin Ölümsüzleri & Hollanda Üçlüsü',
      roster: [
        EraPlayerCandidate(id: 'galli_90', name: 'Giovanni Galli', role: 'GK', specificPosition: 'KL', rating: 88, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '1989-90'),
        EraPlayerCandidate(id: 'baresi_90', name: 'Franco Baresi', role: 'DEF', specificPosition: 'STP', rating: 97, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '1989-90'),
        EraPlayerCandidate(id: 'costacurta_90', name: 'Alessandro Costacurta', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '1989-90'),
        EraPlayerCandidate(id: 'rijkaard_90', name: 'Frank Rijkaard', role: 'MID', specificPosition: 'DOS', rating: 95, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '1989-90'),
        EraPlayerCandidate(id: 'gullit_90', name: 'Ruud Gullit', role: 'MID', specificPosition: 'OOS', rating: 96, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '1989-90'),
        EraPlayerCandidate(id: 'vanbasten_90', name: 'Marco van Basten', role: 'FWD', specificPosition: 'SNT', rating: 98, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '1989-90'),
      ],
    ),
    EraClubPack(
      id: 'milan_2021_22',
      clubId: 'milan',
      clubName: 'AC Milan',
      seasonLabel: '2021-22',
      eraTitle: '11 Yıl Sonra Gelen Scudetto Zaferi',
      roster: [
        EraPlayerCandidate(id: 'maignan_22', name: 'Mike Maignan', role: 'GK', specificPosition: 'KL', rating: 92, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'theo_22', name: 'Theo Hernández', role: 'DEF', specificPosition: 'SLB', rating: 92, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'tomori_22', name: 'Fikayo Tomori', role: 'DEF', specificPosition: 'STP', rating: 88, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'tonali_22', name: 'Sandro Tonali', role: 'MID', specificPosition: 'OS', rating: 89, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'leao_22', name: 'Rafael Leão', role: 'FWD', specificPosition: 'SLK', rating: 92, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2021-22'),
        EraPlayerCandidate(id: 'giroud_22', name: 'Olivier Giroud', role: 'FWD', specificPosition: 'SNT', rating: 89, clubId: 'milan', clubName: 'AC Milan', seasonLabel: '2021-22'),
      ],
    ),
    EraClubPack(
      id: 'inter_1997_98',
      clubId: 'inter',
      clubName: 'Inter Milan',
      seasonLabel: '1997-98',
      eraTitle: 'Il Fenomeno Ronaldo & UEFA Kupası',
      roster: [
        EraPlayerCandidate(id: 'pagliuca_98', name: 'Gianluca Pagliuca', role: 'GK', specificPosition: 'KL', rating: 91, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '1997-98'),
        EraPlayerCandidate(id: 'bergomi_98', name: 'Giuseppe Bergomi', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '1997-98'),
        EraPlayerCandidate(id: 'simeone_98', name: 'Diego Simeone', role: 'MID', specificPosition: 'DOS', rating: 91, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '1997-98'),
        EraPlayerCandidate(id: 'djorkaeff_98', name: 'Youri Djorkaeff', role: 'MID', specificPosition: 'OOS', rating: 91, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '1997-98'),
        EraPlayerCandidate(id: 'ronaldo_inter98', name: 'Ronaldo Nazário', role: 'FWD', specificPosition: 'SNT', rating: 99, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '1997-98'),
        EraPlayerCandidate(id: 'zamorano_98', name: 'Iván Zamorano', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '1997-98'),
      ],
    ),
    EraClubPack(
      id: 'inter_2023_24',
      clubId: 'inter',
      clubName: 'Inter Milan',
      seasonLabel: '2023-24',
      eraTitle: '20. Scudetto (İkinci Yıldız) Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'sommer_24', name: 'Yann Sommer', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'bastoni_24', name: 'Alessandro Bastoni', role: 'DEF', specificPosition: 'STP', rating: 91, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'dimarco_24', name: 'Federico Dimarco', role: 'DEF', specificPosition: 'SLB', rating: 90, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'hakan_24', name: 'Hakan Çalhanoğlu', role: 'MID', specificPosition: 'DOS', rating: 93, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'barella_24', name: 'Nicolò Barella', role: 'MID', specificPosition: 'OS', rating: 92, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'lautaro_24', name: 'Lautaro Martínez', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'inter', clubName: 'Inter Milan', seasonLabel: '2023-24'),
      ],
    ),
    EraClubPack(
      id: 'juve_2014_15',
      clubId: 'juventus',
      clubName: 'Juventus',
      seasonLabel: '2014-15',
      eraTitle: 'BBC Savunması & Şampiyonlar Ligi Finali',
      roster: [
        EraPlayerCandidate(id: 'buffon_15', name: 'Gianluigi Buffon', role: 'GK', specificPosition: 'KL', rating: 94, clubId: 'juventus', clubName: 'Juventus', seasonLabel: '2014-15'),
        EraPlayerCandidate(id: 'bonucci_15', name: 'Leonardo Bonucci', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'juventus', clubName: 'Juventus', seasonLabel: '2014-15'),
        EraPlayerCandidate(id: 'barzagli_15', name: 'Andrea Barzagli', role: 'DEF', specificPosition: 'STP', rating: 91, clubId: 'juventus', clubName: 'Juventus', seasonLabel: '2014-15'),
        EraPlayerCandidate(id: 'pogba_15', name: 'Paul Pogba', role: 'MID', specificPosition: 'OS', rating: 93, clubId: 'juventus', clubName: 'Juventus', seasonLabel: '2014-15'),
        EraPlayerCandidate(id: 'vidal_15', name: 'Arturo Vidal', role: 'MID', specificPosition: 'OS', rating: 92, clubId: 'juventus', clubName: 'Juventus', seasonLabel: '2014-15'),
        EraPlayerCandidate(id: 'tevez_15', name: 'Carlos Tevez', role: 'FWD', specificPosition: 'SNT', rating: 93, clubId: 'juventus', clubName: 'Juventus', seasonLabel: '2014-15'),
      ],
    ),
    EraClubPack(
      id: 'roma_2000_01',
      clubId: 'roma',
      clubName: 'AS Roma',
      seasonLabel: '2000-01',
      eraTitle: 'Totti & Batistuta Tarihi Scudetto',
      roster: [
        EraPlayerCandidate(id: 'antonioli_01', name: 'Francesco Antonioli', role: 'GK', specificPosition: 'KL', rating: 87, clubId: 'roma', clubName: 'AS Roma', seasonLabel: '2000-01'),
        EraPlayerCandidate(id: 'samuel_01', name: 'Walter Samuel', role: 'DEF', specificPosition: 'STP', rating: 93, clubId: 'roma', clubName: 'AS Roma', seasonLabel: '2000-01'),
        EraPlayerCandidate(id: 'candela_01', name: 'Vincent Candela', role: 'DEF', specificPosition: 'SLB', rating: 90, clubId: 'roma', clubName: 'AS Roma', seasonLabel: '2000-01'),
        EraPlayerCandidate(id: 'totti_01', name: 'Francesco Totti', role: 'MID', specificPosition: 'OOS', rating: 96, clubId: 'roma', clubName: 'AS Roma', seasonLabel: '2000-01'),
        EraPlayerCandidate(id: 'derossi_06', name: 'Daniele De Rossi', role: 'MID', specificPosition: 'DOS', rating: 92, clubId: 'roma', clubName: 'AS Roma', seasonLabel: '2006-07'),
        EraPlayerCandidate(id: 'batistuta_01', name: 'Gabriel Batistuta', role: 'FWD', specificPosition: 'SNT', rating: 95, clubId: 'roma', clubName: 'AS Roma', seasonLabel: '2000-01'),
        EraPlayerCandidate(id: 'montella_01', name: 'Vincenzo Montella', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'roma', clubName: 'AS Roma', seasonLabel: '2000-01'),
      ],
    ),
    EraClubPack(
      id: 'napoli_1989_90',
      clubId: 'napoli',
      clubName: 'Napoli',
      seasonLabel: '1989-90',
      eraTitle: 'Diego Maradona & Careca Efsanesi',
      roster: [
        EraPlayerCandidate(id: 'galli_nap90', name: 'Giuliano Giuliani', role: 'GK', specificPosition: 'KL', rating: 86, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '1989-90'),
        EraPlayerCandidate(id: 'ferrara_90', name: 'Ciro Ferrara', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '1989-90'),
        EraPlayerCandidate(id: 'alemao_90', name: 'Alemão', role: 'MID', specificPosition: 'DOS', rating: 89, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '1989-90'),
        EraPlayerCandidate(id: 'maradona_90', name: 'Diego Armando Maradona', role: 'MID', specificPosition: 'OOS', rating: 99, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '1989-90'),
        EraPlayerCandidate(id: 'careca_90', name: 'Careca', role: 'FWD', specificPosition: 'SNT', rating: 93, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '1989-90'),
        EraPlayerCandidate(id: 'zola_90', name: 'Gianfranco Zola', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '1989-90'),
      ],
    ),
    EraClubPack(
      id: 'napoli_2022_23',
      clubId: 'napoli',
      clubName: 'Napoli',
      seasonLabel: '2022-23',
      eraTitle: '33 Yıl Sonra Gelen Scudetto Zaferi',
      roster: [
        EraPlayerCandidate(id: 'meret_23', name: 'Alex Meret', role: 'GK', specificPosition: 'KL', rating: 88, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'kim_23', name: 'Kim Min-jae', role: 'DEF', specificPosition: 'STP', rating: 91, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'dilorenzo_23', name: 'Giovanni Di Lorenzo', role: 'DEF', specificPosition: 'SĞB', rating: 89, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'lobotka_23', name: 'Stanislav Lobotka', role: 'MID', specificPosition: 'DOS', rating: 89, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'zielinski_23', name: 'Piotr Zieliński', role: 'MID', specificPosition: 'OS', rating: 89, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'osimhen_23', name: 'Victor Osimhen', role: 'FWD', specificPosition: 'SNT', rating: 93, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '2022-23'),
        EraPlayerCandidate(id: 'kvara_23', name: 'Khvicha Kvaratskhelia', role: 'FWD', specificPosition: 'SLK', rating: 92, clubId: 'napoli', clubName: 'Napoli', seasonLabel: '2022-23'),
      ],
    ),
    EraClubPack(
      id: 'lazio_1999_00',
      clubId: 'lazio',
      clubName: 'SS Lazio',
      seasonLabel: '1999-00',
      eraTitle: 'Nesta, Nedvěd & Verón Scudetto Kadrosu',
      roster: [
        EraPlayerCandidate(id: 'marchegiani_00', name: 'Luca Marchegiani', role: 'GK', specificPosition: 'KL', rating: 88, clubId: 'lazio', clubName: 'SS Lazio', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'nesta_laz00', name: 'Alessandro Nesta', role: 'DEF', specificPosition: 'STP', rating: 95, clubId: 'lazio', clubName: 'SS Lazio', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'mihajlovic_00', name: 'Siniša Mihajlović', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'lazio', clubName: 'SS Lazio', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'veron_00', name: 'Juan Sebastián Verón', role: 'MID', specificPosition: 'OS', rating: 93, clubId: 'lazio', clubName: 'SS Lazio', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'nedved_laz00', name: 'Pavel Nedvěd', role: 'MID', specificPosition: 'SLK', rating: 93, clubId: 'lazio', clubName: 'SS Lazio', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'salas_00', name: 'Marcelo Salas', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'lazio', clubName: 'SS Lazio', seasonLabel: '1999-00'),
      ],
    ),
    EraClubPack(
      id: 'fiorentina_1998_99',
      clubId: 'fiorentina',
      clubName: 'ACF Fiorentina',
      seasonLabel: '1998-99',
      eraTitle: 'Batigol & Rui Costa Mor Menekşeler',
      roster: [
        EraPlayerCandidate(id: 'toldo_99', name: 'Francesco Toldo', role: 'GK', specificPosition: 'KL', rating: 92, clubId: 'fiorentina', clubName: 'ACF Fiorentina', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'ujfalusi_06', name: 'Tomáš Ujfaluši', role: 'DEF', specificPosition: 'STP', rating: 89, clubId: 'fiorentina', clubName: 'ACF Fiorentina', seasonLabel: '2005-06'),
        EraPlayerCandidate(id: 'ruicosta_99', name: 'Rui Costa', role: 'MID', specificPosition: 'OOS', rating: 94, clubId: 'fiorentina', clubName: 'ACF Fiorentina', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'livraghi_99', name: 'Angelo Di Livio', role: 'MID', specificPosition: 'SĞK', rating: 88, clubId: 'fiorentina', clubName: 'ACF Fiorentina', seasonLabel: '1999-00'),
        EraPlayerCandidate(id: 'batistuta_99', name: 'Gabriel Batistuta', role: 'FWD', specificPosition: 'SNT', rating: 96, clubId: 'fiorentina', clubName: 'ACF Fiorentina', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'edmundo_99', name: 'Edmundo', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'fiorentina', clubName: 'ACF Fiorentina', seasonLabel: '1998-99'),
      ],
    ),
    EraClubPack(
      id: 'parma_1998_99',
      clubId: 'parma',
      clubName: 'Parma Calcio',
      seasonLabel: '1998-99',
      eraTitle: 'Buffon, Thuram, Cannavaro & Crespo UEFA Zaferi',
      roster: [
        EraPlayerCandidate(id: 'buffon_par99', name: 'Gianluigi Buffon', role: 'GK', specificPosition: 'KL', rating: 94, clubId: 'parma', clubName: 'Parma Calcio', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'thuram_99', name: 'Lilian Thuram', role: 'DEF', specificPosition: 'SĞB', rating: 95, clubId: 'parma', clubName: 'Parma Calcio', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'cannavaro_par99', name: 'Fabio Cannavaro', role: 'DEF', specificPosition: 'STP', rating: 94, clubId: 'parma', clubName: 'Parma Calcio', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'dbaggio_99', name: 'Dino Baggio', role: 'MID', specificPosition: 'OS', rating: 90, clubId: 'parma', clubName: 'Parma Calcio', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'crespo_99', name: 'Hernán Crespo', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'parma', clubName: 'Parma Calcio', seasonLabel: '1998-99'),
        EraPlayerCandidate(id: 'chiesa_99', name: 'Enrico Chiesa', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'parma', clubName: 'Parma Calcio', seasonLabel: '1998-99'),
      ],
    ),
    EraClubPack(
      id: 'atalanta_2023_24',
      clubId: 'atalanta',
      clubName: 'Atalanta BC',
      seasonLabel: '2023-24',
      eraTitle: 'Gasperini & Lookman Avrupa Ligi Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'carnesecchi_24', name: 'Marco Carnesecchi', role: 'GK', specificPosition: 'KL', rating: 86, clubId: 'atalanta', clubName: 'Atalanta BC', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'djimsiti_24', name: 'Berat Djimsiti', role: 'DEF', specificPosition: 'STP', rating: 87, clubId: 'atalanta', clubName: 'Atalanta BC', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'ederson_ata24', name: 'Éderson', role: 'MID', specificPosition: 'OS', rating: 89, clubId: 'atalanta', clubName: 'Atalanta BC', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'koopmeiners_24', name: 'Teun Koopmeiners', role: 'MID', specificPosition: 'OOS', rating: 90, clubId: 'atalanta', clubName: 'Atalanta BC', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'lookman_24', name: 'Ademola Lookman', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'atalanta', clubName: 'Atalanta BC', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'scamacca_24', name: 'Gianluca Scamacca', role: 'FWD', specificPosition: 'SNT', rating: 88, clubId: 'atalanta', clubName: 'Atalanta BC', seasonLabel: '2023-24'),
      ],
    ),

    // --- EK BUNDESLIGA, LIGUE 1 & AVRUPA DEVLERİ ---
    EraClubPack(
      id: 'bayern_2012_13',
      clubId: 'bayern',
      clubName: 'Bayern Münih',
      seasonLabel: '2012-13',
      eraTitle: 'Robbery (Robben & Ribéry) Tarihi Treble',
      roster: [
        EraPlayerCandidate(id: 'neuer_13', name: 'Manuel Neuer', role: 'GK', specificPosition: 'KL', rating: 95, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'alaba_13', name: 'David Alaba', role: 'DEF', specificPosition: 'SLB', rating: 92, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'boateng_13', name: 'Jérôme Boateng', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'schweini_13', name: 'Bastian Schweinsteiger', role: 'MID', specificPosition: 'OS', rating: 94, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'ribery_13', name: 'Franck Ribéry', role: 'FWD', specificPosition: 'SLK', rating: 96, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'mandzukic_13', name: 'Mario Mandžukić', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'bayern', clubName: 'Bayern Münih', seasonLabel: '2012-13'),
      ],
    ),
    EraClubPack(
      id: 'dortmund_2012_13',
      clubId: 'dortmund',
      clubName: 'Borussia Dortmund',
      seasonLabel: '2012-13',
      eraTitle: 'Klopp\'un Sarı Duvar Şampiyonlar Ligi Finalisti',
      roster: [
        EraPlayerCandidate(id: 'weidenfeller_13', name: 'Roman Weidenfeller', role: 'GK', specificPosition: 'KL', rating: 89, clubId: 'dortmund', clubName: 'Borussia Dortmund', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'hummels_13', name: 'Mats Hummels', role: 'DEF', specificPosition: 'STP', rating: 93, clubId: 'dortmund', clubName: 'Borussia Dortmund', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'piszczek_13', name: 'Łukasz Piszczek', role: 'DEF', specificPosition: 'SĞB', rating: 89, clubId: 'dortmund', clubName: 'Borussia Dortmund', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'ilkay_13', name: 'İlkay Gündoğan', role: 'MID', specificPosition: 'OS', rating: 91, clubId: 'dortmund', clubName: 'Borussia Dortmund', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'gotze_13', name: 'Mario Götze', role: 'MID', specificPosition: 'OOS', rating: 91, clubId: 'dortmund', clubName: 'Borussia Dortmund', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'reus_13', name: 'Marco Reus', role: 'FWD', specificPosition: 'SLK', rating: 93, clubId: 'dortmund', clubName: 'Borussia Dortmund', seasonLabel: '2012-13'),
        EraPlayerCandidate(id: 'lewa_bvb13', name: 'Robert Lewandowski', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'dortmund', clubName: 'Borussia Dortmund', seasonLabel: '2012-13'),
      ],
    ),
    EraClubPack(
      id: 'leverkusen_2023_24',
      clubId: 'leverkusen',
      clubName: 'Bayer Leverkusen',
      seasonLabel: '2023-24',
      eraTitle: 'Xabi Alonso Namağlup Bundesliga Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'hradecky_24', name: 'Lukáš Hrádecký', role: 'GK', specificPosition: 'KL', rating: 88, clubId: 'leverkusen', clubName: 'Bayer Leverkusen', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'grimaldo_24', name: 'Alejandro Grimaldo', role: 'DEF', specificPosition: 'SLB', rating: 92, clubId: 'leverkusen', clubName: 'Bayer Leverkusen', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'frimpong_24', name: 'Jeremie Frimpong', role: 'DEF', specificPosition: 'SĞB', rating: 91, clubId: 'leverkusen', clubName: 'Bayer Leverkusen', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'xhaka_24', name: 'Granit Xhaka', role: 'MID', specificPosition: 'OS', rating: 91, clubId: 'leverkusen', clubName: 'Bayer Leverkusen', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'wirtz_24', name: 'Florian Wirtz', role: 'MID', specificPosition: 'OOS', rating: 93, clubId: 'leverkusen', clubName: 'Bayer Leverkusen', seasonLabel: '2023-24'),
        EraPlayerCandidate(id: 'boniface_24', name: 'Victor Boniface', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'leverkusen', clubName: 'Bayer Leverkusen', seasonLabel: '2023-24'),
      ],
    ),
    EraClubPack(
      id: 'leverkusen_2001_02',
      clubId: 'leverkusen',
      clubName: 'Bayer Leverkusen',
      seasonLabel: '2001-02',
      eraTitle: 'Ballack & Yıldıray Baştürk ŞL Finalisti',
      roster: [
        EraPlayerCandidate(id: 'butt_02', name: 'Hans-Jörg Butt', role: 'GK', specificPosition: 'KL', rating: 87, clubId: 'leverkusen', clubName: 'Bayer Leverkusen', seasonLabel: '2001-02'),
        EraPlayerCandidate(id: 'lucio_lev02', name: 'Lúcio', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'leverkusen', clubName: 'Bayer Leverkusen', seasonLabel: '2001-02'),
        EraPlayerCandidate(id: 'ballack_02', name: 'Michael Ballack', role: 'MID', specificPosition: 'OS', rating: 94, clubId: 'leverkusen', clubName: 'Bayer Leverkusen', seasonLabel: '2001-02'),
        EraPlayerCandidate(id: 'yildiray_02', name: 'Yıldıray Baştürk', role: 'MID', specificPosition: 'OOS', rating: 90, clubId: 'leverkusen', clubName: 'Bayer Leverkusen', seasonLabel: '2001-02'),
        EraPlayerCandidate(id: 'zeren_02', name: 'Zé Roberto', role: 'MID', specificPosition: 'SLK', rating: 91, clubId: 'leverkusen', clubName: 'Bayer Leverkusen', seasonLabel: '2001-02'),
        EraPlayerCandidate(id: 'berbatov_02', name: 'Dimitar Berbatov', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'leverkusen', clubName: 'Bayer Leverkusen', seasonLabel: '2001-02'),
      ],
    ),
    EraClubPack(
      id: 'wolfsburg_2008_09',
      clubId: 'wolfsburg',
      clubName: 'VfL Wolfsburg',
      seasonLabel: '2008-09',
      eraTitle: 'Džeko, Grafite & Misimović Şampiyonluğu',
      roster: [
        EraPlayerCandidate(id: 'benaglio_09', name: 'Diego Benaglio', role: 'GK', specificPosition: 'KL', rating: 87, clubId: 'wolfsburg', clubName: 'VfL Wolfsburg', seasonLabel: '2008-09'),
        EraPlayerCandidate(id: 'barzagli_wob09', name: 'Andrea Barzagli', role: 'DEF', specificPosition: 'STP', rating: 89, clubId: 'wolfsburg', clubName: 'VfL Wolfsburg', seasonLabel: '2008-09'),
        EraPlayerCandidate(id: 'misimovic_09', name: 'Zvjezdan Misimović', role: 'MID', specificPosition: 'OOS', rating: 90, clubId: 'wolfsburg', clubName: 'VfL Wolfsburg', seasonLabel: '2008-09'),
        EraPlayerCandidate(id: 'josue_09', name: 'Josué', role: 'MID', specificPosition: 'DOS', rating: 87, clubId: 'wolfsburg', clubName: 'VfL Wolfsburg', seasonLabel: '2008-09'),
        EraPlayerCandidate(id: 'dzeko_wob09', name: 'Edin Džeko', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'wolfsburg', clubName: 'VfL Wolfsburg', seasonLabel: '2008-09'),
        EraPlayerCandidate(id: 'grafite_09', name: 'Grafite', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'wolfsburg', clubName: 'VfL Wolfsburg', seasonLabel: '2008-09'),
      ],
    ),
    EraClubPack(
      id: 'bremen_2003_04',
      clubId: 'werder_bremen',
      clubName: 'Werder Bremen',
      seasonLabel: '2003-04',
      eraTitle: 'Ümit Davala, Micoud & Aílton Çifte Kupa',
      roster: [
        EraPlayerCandidate(id: 'reinke_04', name: 'Andreas Reinke', role: 'GK', specificPosition: 'KL', rating: 85, clubId: 'werder_bremen', clubName: 'Werder Bremen', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'umitdavala_04', name: 'Ümit Davala', role: 'DEF', specificPosition: 'SĞB', rating: 87, clubId: 'werder_bremen', clubName: 'Werder Bremen', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'micoud_04', name: 'Johan Micoud', role: 'MID', specificPosition: 'OOS', rating: 91, clubId: 'werder_bremen', clubName: 'Werder Bremen', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'ozil_svw09', name: 'Mesut Özil', role: 'MID', specificPosition: 'OOS', rating: 92, clubId: 'werder_bremen', clubName: 'Werder Bremen', seasonLabel: '2008-09'),
        EraPlayerCandidate(id: 'ailton_04', name: 'Aílton', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'werder_bremen', clubName: 'Werder Bremen', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'klose_svw06', name: 'Miroslav Klose', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'werder_bremen', clubName: 'Werder Bremen', seasonLabel: '2005-06'),
      ],
    ),
    EraClubPack(
      id: 'psg_2019_20',
      clubId: 'psg',
      clubName: 'Paris Saint-Germain',
      seasonLabel: '2019-20',
      eraTitle: 'Mbappé & Neymar Şampiyonlar Ligi Finalisti',
      roster: [
        EraPlayerCandidate(id: 'navas_psg20', name: 'Keylor Navas', role: 'GK', specificPosition: 'KL', rating: 91, clubId: 'psg', clubName: 'Paris Saint-Germain', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'marquinhos_20', name: 'Marquinhos', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'psg', clubName: 'Paris Saint-Germain', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'tsilva_psg20', name: 'Thiago Silva', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'psg', clubName: 'Paris Saint-Germain', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'verratti_20', name: 'Marco Verratti', role: 'MID', specificPosition: 'OS', rating: 92, clubId: 'psg', clubName: 'Paris Saint-Germain', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'dimaria_psg20', name: 'Ángel Di María', role: 'MID', specificPosition: 'SĞK', rating: 92, clubId: 'psg', clubName: 'Paris Saint-Germain', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'mbappe_20', name: 'Kylian Mbappé', role: 'FWD', specificPosition: 'SNT', rating: 96, clubId: 'psg', clubName: 'Paris Saint-Germain', seasonLabel: '2019-20'),
        EraPlayerCandidate(id: 'neymar_psg20', name: 'Neymar Jr', role: 'FWD', specificPosition: 'SLK', rating: 95, clubId: 'psg', clubName: 'Paris Saint-Germain', seasonLabel: '2019-20'),
      ],
    ),
    EraClubPack(
      id: 'monaco_2016_17',
      clubId: 'monaco',
      clubName: 'AS Monaco',
      seasonLabel: '2016-17',
      eraTitle: 'Genç Mbappé, Bernardo & Falcao Şampiyonluğu',
      roster: [
        EraPlayerCandidate(id: 'subasic_17', name: 'Danijel Subašić', role: 'GK', specificPosition: 'KL', rating: 88, clubId: 'monaco', clubName: 'AS Monaco', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'glik_17', name: 'Kamil Glik', role: 'DEF', specificPosition: 'STP', rating: 88, clubId: 'monaco', clubName: 'AS Monaco', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'fabinho_17', name: 'Fabinho', role: 'MID', specificPosition: 'DOS', rating: 90, clubId: 'monaco', clubName: 'AS Monaco', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'bsilva_17', name: 'Bernardo Silva', role: 'MID', specificPosition: 'OOS', rating: 91, clubId: 'monaco', clubName: 'AS Monaco', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'falcao_17', name: 'Radamel Falcao', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'monaco', clubName: 'AS Monaco', seasonLabel: '2016-17'),
        EraPlayerCandidate(id: 'mbappe_mon17', name: 'Kylian Mbappé', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'monaco', clubName: 'AS Monaco', seasonLabel: '2016-17'),
      ],
    ),
    EraClubPack(
      id: 'lyon_2004_05',
      clubId: 'lyon',
      clubName: 'Olympique Lyonnais',
      seasonLabel: '2004-05',
      eraTitle: 'Juninho Frikik Ustası & 7 Yıllık Hanedan',
      roster: [
        EraPlayerCandidate(id: 'coupet_05', name: 'Grégory Coupet', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'lyon', clubName: 'Olympique Lyonnais', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'cris_05', name: 'Cris', role: 'DEF', specificPosition: 'STP', rating: 90, clubId: 'lyon', clubName: 'Olympique Lyonnais', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'abidal_05', name: 'Éric Abidal', role: 'DEF', specificPosition: 'SLB', rating: 90, clubId: 'lyon', clubName: 'Olympique Lyonnais', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'juninho_05', name: 'Juninho Pernambucano', role: 'MID', specificPosition: 'OS', rating: 94, clubId: 'lyon', clubName: 'Olympique Lyonnais', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'essien_05', name: 'Michael Essien', role: 'MID', specificPosition: 'OS', rating: 92, clubId: 'lyon', clubName: 'Olympique Lyonnais', seasonLabel: '2004-05'),
        EraPlayerCandidate(id: 'benzema_lyon08', name: 'Karim Benzema', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'lyon', clubName: 'Olympique Lyonnais', seasonLabel: '2007-08'),
      ],
    ),
    EraClubPack(
      id: 'lille_2020_21',
      clubId: 'lille',
      clubName: 'LOSC Lille',
      seasonLabel: '2020-21',
      eraTitle: 'Burak, Yusuf & Zeki Fransa Şampiyonluğu',
      roster: [
        EraPlayerCandidate(id: 'maignan_lil21', name: 'Mike Maignan', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'lille', clubName: 'LOSC Lille', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'fonte_21', name: 'José Fonte', role: 'DEF', specificPosition: 'STP', rating: 88, clubId: 'lille', clubName: 'LOSC Lille', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'zekicelik_21', name: 'Zeki Çelik', role: 'DEF', specificPosition: 'SĞB', rating: 87, clubId: 'lille', clubName: 'LOSC Lille', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'rsanches_21', name: 'Renato Sanches', role: 'MID', specificPosition: 'OS', rating: 87, clubId: 'lille', clubName: 'LOSC Lille', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'yusuf_21', name: 'Yusuf Yazıcı', role: 'MID', specificPosition: 'OOS', rating: 88, clubId: 'lille', clubName: 'LOSC Lille', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'burak_lil21', name: 'Burak Yılmaz', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'lille', clubName: 'LOSC Lille', seasonLabel: '2020-21'),
        EraPlayerCandidate(id: 'jdavid_21', name: 'Jonathan David', role: 'FWD', specificPosition: 'SNT', rating: 88, clubId: 'lille', clubName: 'LOSC Lille', seasonLabel: '2020-21'),
      ],
    ),
    EraClubPack(
      id: 'porto_2003_04',
      clubId: 'porto',
      clubName: 'FC Porto',
      seasonLabel: '2003-04',
      eraTitle: 'Mourinho\'nun Şampiyonlar Ligi Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'vbaia_04', name: 'Vítor Baía', role: 'GK', specificPosition: 'KL', rating: 91, clubId: 'porto', clubName: 'FC Porto', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'rcarvalho_04', name: 'Ricardo Carvalho', role: 'DEF', specificPosition: 'STP', rating: 93, clubId: 'porto', clubName: 'FC Porto', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'pferreira_04', name: 'Paulo Ferreira', role: 'DEF', specificPosition: 'SĞB', rating: 89, clubId: 'porto', clubName: 'FC Porto', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'deco_por04', name: 'Deco', role: 'MID', specificPosition: 'OOS', rating: 94, clubId: 'porto', clubName: 'FC Porto', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'maniche_04', name: 'Maniche', role: 'MID', specificPosition: 'OS', rating: 90, clubId: 'porto', clubName: 'FC Porto', seasonLabel: '2003-04'),
        EraPlayerCandidate(id: 'mccarthy_04', name: 'Benni McCarthy', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'porto', clubName: 'FC Porto', seasonLabel: '2003-04'),
      ],
    ),
    EraClubPack(
      id: 'benfica_2013_14',
      clubId: 'benfica',
      clubName: 'SL Benfica',
      seasonLabel: '2013-14',
      eraTitle: 'Lizbon Kartalları Portekiz Üçlemesi',
      roster: [
        EraPlayerCandidate(id: 'oblak_14', name: 'Jan Oblak', role: 'GK', specificPosition: 'KL', rating: 91, clubId: 'benfica', clubName: 'SL Benfica', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'luisao_14', name: 'Luisão', role: 'DEF', specificPosition: 'STP', rating: 89, clubId: 'benfica', clubName: 'SL Benfica', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'garay_14', name: 'Ezequiel Garay', role: 'DEF', specificPosition: 'STP', rating: 89, clubId: 'benfica', clubName: 'SL Benfica', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'gaitan_14', name: 'Nicolás Gaitán', role: 'MID', specificPosition: 'OOS', rating: 89, clubId: 'benfica', clubName: 'SL Benfica', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'eperez_14', name: 'Enzo Pérez', role: 'MID', specificPosition: 'OS', rating: 88, clubId: 'benfica', clubName: 'SL Benfica', seasonLabel: '2013-14'),
        EraPlayerCandidate(id: 'cardozo_14', name: 'Óscar Cardozo', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'benfica', clubName: 'SL Benfica', seasonLabel: '2013-14'),
      ],
    ),
    EraClubPack(
      id: 'ajax_1994_95',
      clubId: 'ajax',
      clubName: 'Ajax',
      seasonLabel: '1994-95',
      eraTitle: 'Van Gaal\'in Namağlup Şampiyonlar Ligi Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'vds_95', name: 'Edwin van der Sar', role: 'GK', specificPosition: 'KL', rating: 93, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '1994-95'),
        EraPlayerCandidate(id: 'fdeboer_95', name: 'Frank de Boer', role: 'DEF', specificPosition: 'STP', rating: 92, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '1994-95'),
        EraPlayerCandidate(id: 'davids_95', name: 'Edgar Davids', role: 'MID', specificPosition: 'OS', rating: 93, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '1994-95'),
        EraPlayerCandidate(id: 'seedorf_95', name: 'Clarence Seedorf', role: 'MID', specificPosition: 'OS', rating: 93, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '1994-95'),
        EraPlayerCandidate(id: 'litmanen_95', name: 'Jari Litmanen', role: 'MID', specificPosition: 'OOS', rating: 94, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '1994-95'),
        EraPlayerCandidate(id: 'kluivert_95', name: 'Patrick Kluivert', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '1994-95'),
        EraPlayerCandidate(id: 'overmars_95', name: 'Marc Overmars', role: 'FWD', specificPosition: 'SLK', rating: 91, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '1994-95'),
      ],
    ),
    EraClubPack(
      id: 'ajax_2018_19',
      clubId: 'ajax',
      clubName: 'Ajax',
      seasonLabel: '2018-19',
      eraTitle: 'De Ligt, De Jong & Tadić Dev Katilleri',
      roster: [
        EraPlayerCandidate(id: 'onana_19', name: 'André Onana', role: 'GK', specificPosition: 'KL', rating: 88, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'deligt_19', name: 'Matthijs de Ligt', role: 'DEF', specificPosition: 'STP', rating: 91, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'dblind_19', name: 'Daley Blind', role: 'DEF', specificPosition: 'STP', rating: 88, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'dejong_19', name: 'Frenkie de Jong', role: 'MID', specificPosition: 'OS', rating: 92, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'ziyech_19', name: 'Hakim Ziyech', role: 'MID', specificPosition: 'OOS', rating: 91, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '2018-19'),
        EraPlayerCandidate(id: 'tadic_19', name: 'Dušan Tadić', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'ajax', clubName: 'Ajax', seasonLabel: '2018-19'),
      ],
    ),
    EraClubPack(
      id: 'santos_2011_12',
      clubId: 'santos',
      clubName: 'Santos FC',
      seasonLabel: '2011-12',
      eraTitle: 'Neymar & Ganso Copa Libertadores Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'rafael_11', name: 'Rafael Cabral', role: 'GK', specificPosition: 'KL', rating: 85, clubId: 'santos', clubName: 'Santos FC', seasonLabel: '2011-12'),
        EraPlayerCandidate(id: 'danilo_11', name: 'Danilo', role: 'DEF', specificPosition: 'SĞB', rating: 88, clubId: 'santos', clubName: 'Santos FC', seasonLabel: '2011-12'),
        EraPlayerCandidate(id: 'asandro_11', name: 'Alex Sandro', role: 'DEF', specificPosition: 'SLB', rating: 88, clubId: 'santos', clubName: 'Santos FC', seasonLabel: '2011-12'),
        EraPlayerCandidate(id: 'ganso_11', name: 'Paulo Henrique Ganso', role: 'MID', specificPosition: 'OOS', rating: 89, clubId: 'santos', clubName: 'Santos FC', seasonLabel: '2011-12'),
        EraPlayerCandidate(id: 'elano_11', name: 'Elano', role: 'MID', specificPosition: 'OS', rating: 88, clubId: 'santos', clubName: 'Santos FC', seasonLabel: '2011-12'),
        EraPlayerCandidate(id: 'neymar_san11', name: 'Neymar Jr', role: 'FWD', specificPosition: 'SLK', rating: 94, clubId: 'santos', clubName: 'Santos FC', seasonLabel: '2011-12'),
      ],
    ),
    EraClubPack(
      id: 'boca_2000_01',
      clubId: 'boca_juniors',
      clubName: 'Boca Juniors',
      seasonLabel: '2000-01',
      eraTitle: 'Riquelme & Palermo Kıtalararası Kupa Zaferi',
      roster: [
        EraPlayerCandidate(id: 'cordoba_boca00', name: 'Óscar Córdoba', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'boca_juniors', clubName: 'Boca Juniors', seasonLabel: '2000-01'),
        EraPlayerCandidate(id: 'bermudez_00', name: 'Jorge Bermúdez', role: 'DEF', specificPosition: 'STP', rating: 89, clubId: 'boca_juniors', clubName: 'Boca Juniors', seasonLabel: '2000-01'),
        EraPlayerCandidate(id: 'ibarra_00', name: 'Hugo Ibarra', role: 'DEF', specificPosition: 'SĞB', rating: 88, clubId: 'boca_juniors', clubName: 'Boca Juniors', seasonLabel: '2000-01'),
        EraPlayerCandidate(id: 'riquelme_boca00', name: 'Juan Román Riquelme', role: 'MID', specificPosition: 'OOS', rating: 95, clubId: 'boca_juniors', clubName: 'Boca Juniors', seasonLabel: '2000-01'),
        EraPlayerCandidate(id: 'palermo_00', name: 'Martín Palermo', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'boca_juniors', clubName: 'Boca Juniors', seasonLabel: '2000-01'),
        EraPlayerCandidate(id: 'delgado_00', name: 'Marcelo Delgado', role: 'FWD', specificPosition: 'SNT', rating: 88, clubId: 'boca_juniors', clubName: 'Boca Juniors', seasonLabel: '2000-01'),
      ],
    ),

    // --- MİLLİ TAKIM DÜNYA KUPASI & EURO EFSANE PAKETLERİ ---
    EraClubPack(
      id: 'turkiye_2002',
      clubId: 'nat_turkiye',
      clubName: 'Türkiye Milli Takımı',
      seasonLabel: '2002 DK',
      eraTitle: '2002 Dünya Kupası Üçüncüsü Destanı',
      roster: [
        EraPlayerCandidate(id: 'rustu_tr02', name: 'Rüştü Reçber', role: 'GK', specificPosition: 'KL', rating: 93, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: '2002 DK'),
        EraPlayerCandidate(id: 'alpay_tr02', name: 'Alpay Özalan', role: 'DEF', specificPosition: 'STP', rating: 90, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: '2002 DK'),
        EraPlayerCandidate(id: 'bulent_tr02', name: 'Bülent Korkmaz', role: 'DEF', specificPosition: 'STP', rating: 91, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: '2002 DK'),
        EraPlayerCandidate(id: 'emre_tr02', name: 'Emre Belözoğlu', role: 'MID', specificPosition: 'OS', rating: 91, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: '2002 DK'),
        EraPlayerCandidate(id: 'hasansas_tr02', name: 'Hasan Şaş', role: 'FWD', specificPosition: 'SLK', rating: 93, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: '2002 DK'),
        EraPlayerCandidate(id: 'ilhan_tr02', name: 'İlhan Mansız', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: '2002 DK'),
        EraPlayerCandidate(id: 'hakan_tr02', name: 'Hakan Şükür', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: '2002 DK'),
      ],
    ),
    EraClubPack(
      id: 'turkiye_2008',
      clubId: 'nat_turkiye',
      clubName: 'Türkiye Milli Takımı',
      seasonLabel: 'EURO 2008',
      eraTitle: 'EURO 2008 Yarı Final & Geri Dönüş Kralları',
      roster: [
        EraPlayerCandidate(id: 'volkan_tr08', name: 'Volkan Demirel', role: 'GK', specificPosition: 'KL', rating: 89, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: 'EURO 2008'),
        EraPlayerCandidate(id: 'servet_tr08', name: 'Servet Çetin', role: 'DEF', specificPosition: 'STP', rating: 88, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: 'EURO 2008'),
        EraPlayerCandidate(id: 'hamit_tr08', name: 'Hamit Altıntop', role: 'MID', specificPosition: 'SĞK', rating: 91, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: 'EURO 2008'),
        EraPlayerCandidate(id: 'arda_tr08', name: 'Arda Turan', role: 'MID', specificPosition: 'SLK', rating: 91, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: 'EURO 2008'),
        EraPlayerCandidate(id: 'nihat_tr08', name: 'Nihat Kahveci', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: 'EURO 2008'),
        EraPlayerCandidate(id: 'semih_tr08', name: 'Semih Şentürk', role: 'FWD', specificPosition: 'SNT', rating: 90, clubId: 'nat_turkiye', clubName: 'Türkiye', seasonLabel: 'EURO 2008'),
      ],
    ),
    EraClubPack(
      id: 'brezilya_2002',
      clubId: 'nat_brezilya',
      clubName: 'Brezilya Milli Takımı',
      seasonLabel: '2002 DK',
      eraTitle: 'Ronaldo, Rivaldo & Ronaldinho 5. Dünya Kupası',
      roster: [
        EraPlayerCandidate(id: 'marcos_br02', name: 'Marcos', role: 'GK', specificPosition: 'KL', rating: 90, clubId: 'nat_brezilya', clubName: 'Brezilya', seasonLabel: '2002 DK'),
        EraPlayerCandidate(id: 'cafu_br02', name: 'Cafu', role: 'DEF', specificPosition: 'SĞB', rating: 95, clubId: 'nat_brezilya', clubName: 'Brezilya', seasonLabel: '2002 DK'),
        EraPlayerCandidate(id: 'rcarlos_br02', name: 'Roberto Carlos', role: 'DEF', specificPosition: 'SLB', rating: 96, clubId: 'nat_brezilya', clubName: 'Brezilya', seasonLabel: '2002 DK'),
        EraPlayerCandidate(id: 'rivaldo_br02', name: 'Rivaldo', role: 'MID', specificPosition: 'OOS', rating: 96, clubId: 'nat_brezilya', clubName: 'Brezilya', seasonLabel: '2002 DK'),
        EraPlayerCandidate(id: 'ronaldinho_br02', name: 'Ronaldinho', role: 'MID', specificPosition: 'OOS', rating: 96, clubId: 'nat_brezilya', clubName: 'Brezilya', seasonLabel: '2002 DK'),
        EraPlayerCandidate(id: 'r9_br02', name: 'Ronaldo Nazário', role: 'FWD', specificPosition: 'SNT', rating: 99, clubId: 'nat_brezilya', clubName: 'Brezilya', seasonLabel: '2002 DK'),
      ],
    ),
    EraClubPack(
      id: 'fransa_1998',
      clubId: 'nat_fransa',
      clubName: 'Fransa Milli Takımı',
      seasonLabel: '1998 DK',
      eraTitle: 'Zidane & Henry Dünya Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'barthez_fr98', name: 'Fabien Barthez', role: 'GK', specificPosition: 'KL', rating: 91, clubId: 'nat_fransa', clubName: 'Fransa', seasonLabel: '1998 DK'),
        EraPlayerCandidate(id: 'desailly_fr98', name: 'Marcel Desailly', role: 'DEF', specificPosition: 'STP', rating: 94, clubId: 'nat_fransa', clubName: 'Fransa', seasonLabel: '1998 DK'),
        EraPlayerCandidate(id: 'thuram_fr98', name: 'Lilian Thuram', role: 'DEF', specificPosition: 'SĞB', rating: 95, clubId: 'nat_fransa', clubName: 'Fransa', seasonLabel: '1998 DK'),
        EraPlayerCandidate(id: 'zidane_fr98', name: 'Zinedine Zidane', role: 'MID', specificPosition: 'OOS', rating: 98, clubId: 'nat_fransa', clubName: 'Fransa', seasonLabel: '1998 DK'),
        EraPlayerCandidate(id: 'vieira_fr98', name: 'Patrick Vieira', role: 'MID', specificPosition: 'DOS', rating: 93, clubId: 'nat_fransa', clubName: 'Fransa', seasonLabel: '1998 DK'),
        EraPlayerCandidate(id: 'henry_fr98', name: 'Thierry Henry', role: 'FWD', specificPosition: 'SNT', rating: 95, clubId: 'nat_fransa', clubName: 'Fransa', seasonLabel: '1998 DK'),
      ],
    ),
    EraClubPack(
      id: 'arjantin_2022',
      clubId: 'nat_arjantin',
      clubName: 'Arjantin Milli Takımı',
      seasonLabel: '2022 DK',
      eraTitle: 'Lionel Messi Katar Dünya Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'emartinez_ar22', name: 'Emiliano Martínez', role: 'GK', specificPosition: 'KL', rating: 92, clubId: 'nat_arjantin', clubName: 'Arjantin', seasonLabel: '2022 DK'),
        EraPlayerCandidate(id: 'romero_ar22', name: 'Cristian Romero', role: 'DEF', specificPosition: 'STP', rating: 91, clubId: 'nat_arjantin', clubName: 'Arjantin', seasonLabel: '2022 DK'),
        EraPlayerCandidate(id: 'macallister_ar22', name: 'Alexis Mac Allister', role: 'MID', specificPosition: 'OS', rating: 91, clubId: 'nat_arjantin', clubName: 'Arjantin', seasonLabel: '2022 DK'),
        EraPlayerCandidate(id: 'dimaria_ar22', name: 'Ángel Di María', role: 'MID', specificPosition: 'SĞK', rating: 94, clubId: 'nat_arjantin', clubName: 'Arjantin', seasonLabel: '2022 DK'),
        EraPlayerCandidate(id: 'messi_ar22', name: 'Lionel Messi', role: 'FWD', specificPosition: 'SNT', rating: 99, clubId: 'nat_arjantin', clubName: 'Arjantin', seasonLabel: '2022 DK'),
        EraPlayerCandidate(id: 'alvarez_ar22', name: 'Julián Álvarez', role: 'FWD', specificPosition: 'SNT', rating: 91, clubId: 'nat_arjantin', clubName: 'Arjantin', seasonLabel: '2022 DK'),
      ],
    ),
    EraClubPack(
      id: 'ispanya_2010',
      clubId: 'nat_ispanya',
      clubName: 'İspanya Milli Takımı',
      seasonLabel: '2010 DK',
      eraTitle: 'Altın Nesil Dünya & Avrupa Şampiyonu',
      roster: [
        EraPlayerCandidate(id: 'casillas_es10', name: 'Iker Casillas', role: 'GK', specificPosition: 'KL', rating: 95, clubId: 'nat_ispanya', clubName: 'İspanya', seasonLabel: '2010 DK'),
        EraPlayerCandidate(id: 'ramos_es10', name: 'Sergio Ramos', role: 'DEF', specificPosition: 'SĞB', rating: 94, clubId: 'nat_ispanya', clubName: 'İspanya', seasonLabel: '2010 DK'),
        EraPlayerCandidate(id: 'puyol_es10', name: 'Carles Puyol', role: 'DEF', specificPosition: 'STP', rating: 95, clubId: 'nat_ispanya', clubName: 'İspanya', seasonLabel: '2010 DK'),
        EraPlayerCandidate(id: 'xavi_es10', name: 'Xavi Hernández', role: 'MID', specificPosition: 'OS', rating: 96, clubId: 'nat_ispanya', clubName: 'İspanya', seasonLabel: '2010 DK'),
        EraPlayerCandidate(id: 'iniesta_es10', name: 'Andrés Iniesta', role: 'MID', specificPosition: 'OS', rating: 96, clubId: 'nat_ispanya', clubName: 'İspanya', seasonLabel: '2010 DK'),
        EraPlayerCandidate(id: 'villa_es10', name: 'David Villa', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'nat_ispanya', clubName: 'İspanya', seasonLabel: '2010 DK'),
      ],
    ),
    EraClubPack(
      id: 'almanya_2014',
      clubId: 'nat_almanya',
      clubName: 'Almanya Milli Takımı',
      seasonLabel: '2014 DK',
      eraTitle: 'Brezilya\'da Dünya Şampiyonu Panzerler',
      roster: [
        EraPlayerCandidate(id: 'neuer_de14', name: 'Manuel Neuer', role: 'GK', specificPosition: 'KL', rating: 96, clubId: 'nat_almanya', clubName: 'Almanya', seasonLabel: '2014 DK'),
        EraPlayerCandidate(id: 'lahm_de14', name: 'Philipp Lahm', role: 'DEF', specificPosition: 'SĞB', rating: 95, clubId: 'nat_almanya', clubName: 'Almanya', seasonLabel: '2014 DK'),
        EraPlayerCandidate(id: 'hummels_de14', name: 'Mats Hummels', role: 'DEF', specificPosition: 'STP', rating: 93, clubId: 'nat_almanya', clubName: 'Almanya', seasonLabel: '2014 DK'),
        EraPlayerCandidate(id: 'kroos_de14', name: 'Toni Kroos', role: 'MID', specificPosition: 'OS', rating: 95, clubId: 'nat_almanya', clubName: 'Almanya', seasonLabel: '2014 DK'),
        EraPlayerCandidate(id: 'ozil_de14', name: 'Mesut Özil', role: 'MID', specificPosition: 'OOS', rating: 93, clubId: 'nat_almanya', clubName: 'Almanya', seasonLabel: '2014 DK'),
        EraPlayerCandidate(id: 'klose_de14', name: 'Miroslav Klose', role: 'FWD', specificPosition: 'SNT', rating: 92, clubId: 'nat_almanya', clubName: 'Almanya', seasonLabel: '2014 DK'),
        EraPlayerCandidate(id: 'muller_de14', name: 'Thomas Müller', role: 'FWD', specificPosition: 'SĞK', rating: 94, clubId: 'nat_almanya', clubName: 'Almanya', seasonLabel: '2014 DK'),
      ],
    ),
    EraClubPack(
      id: 'italya_2006',
      clubId: 'nat_italya',
      clubName: 'İtalya Milli Takımı',
      seasonLabel: '2006 DK',
      eraTitle: 'Berlin\'de 4. Dünya Kupası Zaferi',
      roster: [
        EraPlayerCandidate(id: 'buffon_it06', name: 'Gianluigi Buffon', role: 'GK', specificPosition: 'KL', rating: 97, clubId: 'nat_italya', clubName: 'İtalya', seasonLabel: '2006 DK'),
        EraPlayerCandidate(id: 'cannavaro_it06', name: 'Fabio Cannavaro', role: 'DEF', specificPosition: 'STP', rating: 97, clubId: 'nat_italya', clubName: 'İtalya', seasonLabel: '2006 DK'),
        EraPlayerCandidate(id: 'grosso_it06', name: 'Fabio Grosso', role: 'DEF', specificPosition: 'SLB', rating: 90, clubId: 'nat_italya', clubName: 'İtalya', seasonLabel: '2006 DK'),
        EraPlayerCandidate(id: 'pirlo_it06', name: 'Andrea Pirlo', role: 'MID', specificPosition: 'OS', rating: 96, clubId: 'nat_italya', clubName: 'İtalya', seasonLabel: '2006 DK'),
        EraPlayerCandidate(id: 'gattuso_it06', name: 'Gennaro Gattuso', role: 'MID', specificPosition: 'DOS', rating: 92, clubId: 'nat_italya', clubName: 'İtalya', seasonLabel: '2006 DK'),
        EraPlayerCandidate(id: 'totti_it06', name: 'Francesco Totti', role: 'FWD', specificPosition: 'OOS', rating: 95, clubId: 'nat_italya', clubName: 'İtalya', seasonLabel: '2006 DK'),
        EraPlayerCandidate(id: 'delpiero_it06', name: 'Alessandro Del Piero', role: 'FWD', specificPosition: 'SNT', rating: 94, clubId: 'nat_italya', clubName: 'İtalya', seasonLabel: '2006 DK'),
      ],
    ),
  ];
}
