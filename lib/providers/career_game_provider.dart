import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/models/club_model.dart';
import '../data/models/career_model.dart';
import '../data/repositories/football_database.dart';

class CareerGameProvider extends ChangeNotifier {
  final FootballDatabase _database = FootballDatabase();
  final Random _random = Random();

  bool _isCareerActive = false;
  bool _isCareerFinished = false;

  String _playerName = 'Kaptan';
  PlayerPosition _position = PlayerPosition.striker;
  String _region = 'Türkiye';

  int _currentStageIndex = 0;
  final int _maxStages = 10;

  ClubModel? _currentClub;
  List<ClubModel> _currentOffers = [];
  final List<ClubModel> _careerClubsHistory = [];
  final List<SeasonPerformance> _seasonHistory = [];
  final List<String> _highlightsHistory = [];
  CareerSummary? _finalSummary;

  // Interactive Penalty & Form State
  bool _hasPendingPenalty = true;
  PenaltyShotResult? _lastPenaltyResult;
  int _penaltiesScored = 0;
  int _penaltiesTaken = 0;
  int _formMomentum = 70; // 0 - 100

  // Getters
  bool get isCareerActive => _isCareerActive;
  bool get isCareerFinished => _isCareerFinished;
  String get playerName => _playerName;
  PlayerPosition get position => _position;
  String get region => _region;
  int get currentStageIndex => _currentStageIndex;
  int get maxStages => _maxStages;
  int get currentAge => _stageAges[_currentStageIndex.clamp(0, _stageAges.length - 1)];
  String get currentStageTitle => _stageTitles[_currentStageIndex.clamp(0, _stageTitles.length - 1)];
  ClubModel? get currentClub => _currentClub;
  List<ClubModel> get currentOffers => _currentOffers;
  List<ClubModel> get careerClubsHistory => _careerClubsHistory;
  List<SeasonPerformance> get seasonHistory => _seasonHistory;
  List<String> get highlightsHistory => _highlightsHistory;
  CareerSummary? get finalSummary => _finalSummary;

  bool get hasPendingPenalty => _hasPendingPenalty;
  PenaltyShotResult? get lastPenaltyResult => _lastPenaltyResult;
  int get penaltiesScored => _penaltiesScored;
  int get penaltiesTaken => _penaltiesTaken;
  int get formMomentum => _formMomentum;

  int get marketValueMillions {
    final age = currentAge;
    double baseVal = 14.0;
    if (age <= 18) {
      baseVal = 12.0;
    } else if (age <= 21) {
      baseVal = 28.0;
    } else if (age <= 24) {
      baseVal = 52.0;
    } else if (age <= 28) {
      baseVal = 78.0;
    } else if (age <= 31) {
      baseVal = 55.0;
    } else {
      baseVal = 22.0;
    }
    final formFactor = 0.6 + (_formMomentum / 100.0) * 0.85;
    final trophyBonus = _seasonHistory.fold<int>(0, (s, p) => s + p.trophiesWon.length) * 4.5;
    return (baseVal * formFactor + trophyBonus).round().clamp(5, 180);
  }

  static const List<int> _stageAges = [17, 19, 21, 23, 25, 27, 29, 31, 33, 35];
  static const List<String> _stageTitles = [
    'Altyapı & İlk Profesyonel Maç',
    'Genç Yetenek & Çıkış Sezonu',
    'İlk 11\'in Değişilmezi',
    'Avrupa Vitrininde Parlayış',
    'Altın Çağ Başlangıcı',
    'Zirve / Prime Dönemi',
    'Dünya Yıldızı & Liderlik',
    'Tecrübeli Kaptan',
    'Usta Maestro Dönemi',
    'Jübile & Son Dans',
  ];

  /// Start a brand new player career
  void startCareer({
    required String playerName,
    required String region,
    required PlayerPosition position,
  }) {
    _playerName = playerName.trim().isNotEmpty ? playerName.trim() : 'Kaptan';
    _position = position;
    _region = region;
    _currentStageIndex = 0;
    _isCareerActive = true;
    _isCareerFinished = false;
    _careerClubsHistory.clear();
    _seasonHistory.clear();
    _highlightsHistory.clear();
    _finalSummary = null;
    _penaltiesScored = 0;
    _penaltiesTaken = 0;
    _formMomentum = 72;
    // Penalty does NOT appear on initial screen; it triggers randomly after signing a transfer
    _hasPendingPenalty = false;
    _lastPenaltyResult = null;

    // Pick authentic starting club based on region
    final startingClub = _getInitialClubForRegion(region);
    _currentClub = startingClub;
    _careerClubsHistory.add(startingClub);

    // Generate initial performance and first transfer offers
    final initialSeason = _simulateSeason(startingClub, _stageAges.first);
    _seasonHistory.add(initialSeason);
    _highlightsHistory.add(
      '17 yaşında profesyonel sözleşmeyi imzaladın ve A takımla sahaya çıktın. İstatistiklerin gizli tutuluyor ve jübilede açıklanacak!',
    );

    _generateNextOffers();
    notifyListeners();
  }

  /// Interactive Penalty Shootout triggered after signing a transfer
  PenaltyShotResult takeSeasonPenalty(PenaltyCorner chosenCorner) {
    if (_seasonHistory.isEmpty) {
      return _lastPenaltyResult ??
          PenaltyShotResult(
            playerCorner: chosenCorner,
            keeperCorner: PenaltyCorner.center,
            isGoal: true,
            commentary: 'Penaltı tamamlandı.',
          );
    }

    _hasPendingPenalty = false;
    _penaltiesTaken++;

    final corners = PenaltyCorner.values;
    // Goalkeeper dives: 68% chance player outsmarts keeper, 32% chance keeper guesses the corner
    final bool isSuccess = _random.nextDouble() < 0.68;
    PenaltyCorner keeperCorner;
    if (isSuccess) {
      final otherCorners = corners.where((c) => c != chosenCorner).toList();
      keeperCorner = otherCorners[_random.nextInt(otherCorners.length)];
    } else {
      keeperCorner = chosenCorner;
    }

    final lastIdx = _seasonHistory.length - 1;
    final currentPerf = _seasonHistory[lastIdx];
    final isGk = _position == PlayerPosition.goalkeeper;

    String commentary;
    if (isSuccess) {
      _penaltiesScored++;
      _formMomentum = (_formMomentum + 16).clamp(20, 99);

      final extraGoals = isGk ? 0 : (_position == PlayerPosition.defender ? 2 : 6);
      final extraAssists = isGk ? 1 : 3;
      final updatedTrophies = List<String>.from(currentPerf.trophiesWon);
      if (updatedTrophies.isEmpty && _random.nextDouble() < 0.65) {
        updatedTrophies.add('Ulusal Kupa Şampiyonu');
      }

      _seasonHistory[lastIdx] = currentPerf.copyWith(
        goals: currentPerf.goals + extraGoals,
        assists: currentPerf.assists + extraAssists,
        trophiesWon: updatedTrophies,
      );

      // Upgrade one transfer offer to an elite club if not already present
      final eliteIds = ['real_madrid', 'man_city', 'bayern', 'barcelona', 'liverpool', 'psg', 'galatasaray', 'fenerbahce'];
      final eliteClubs = _database
          .getAllClubs()
          .where((c) => eliteIds.contains(c.id) && c.id != _currentClub?.id)
          .toList();
      if (eliteClubs.isNotEmpty && _currentOffers.isNotEmpty) {
        eliteClubs.shuffle(_random);
        if (!_currentOffers.any((o) => o.id == eliteClubs.first.id)) {
          _currentOffers[0] = eliteClubs.first;
        }
      }

      commentary = isGk
          ? 'İNANILMAZ KURTARIŞ! ${chosenCorner.label} köşesine uzanarak 90. dakikada penaltıyı çıkardın, takımın kupaya uzandı!'
          : 'GOOOL! Topu ${chosenCorner.label} köşesine gönderdin, kaleci ters köşede kaldı! Formun ve piyasa değerin zirveye çıktı!';
    } else {
      _formMomentum = (_formMomentum - 18).clamp(20, 99);

      final reducedGoals = isGk ? currentPerf.goals : (currentPerf.goals - 4).clamp(0, 99);
      final reducedAssists = (currentPerf.assists - 2).clamp(0, 99);
      final updatedTrophies = List<String>.from(currentPerf.trophiesWon);
      if (updatedTrophies.isNotEmpty) {
        updatedTrophies.removeLast();
      }

      _seasonHistory[lastIdx] = currentPerf.copyWith(
        goals: reducedGoals,
        assists: reducedAssists,
        trophiesWon: updatedTrophies,
      );

      commentary = isGk
          ? 'TERS KÖŞE! ${chosenCorner.label} köşesine atladın ama top diğer köşeden ağlara gitti. Kritik maçta moral kaybı yaşadın.'
          : 'KALECİ KURTARDI! ${chosenCorner.label} köşesine vurduğun penaltıyı kaleci çıkardı! Kaçan kritik penaltı sonrası formun düştü.';
    }

    if (_highlightsHistory.isNotEmpty) {
      _highlightsHistory[_highlightsHistory.length - 1] = commentary;
    } else {
      _highlightsHistory.add(commentary);
    }

    _lastPenaltyResult = PenaltyShotResult(
      playerCorner: chosenCorner,
      keeperCorner: keeperCorner,
      isGoal: isSuccess,
      commentary: commentary,
    );

    notifyListeners();
    return _lastPenaltyResult!;
  }

  /// User chooses to transfer to Club A, Club B, or stay.
  /// After signing a transfer, there is a random chance (~42%) that a full-screen
  /// Critical Match Penalty Shootout triggers for that newly signed season.
  void selectTransferDecision(ClubModel? chosenClub, {bool? forcePenalty}) {
    if (_isCareerFinished) return;

    if (chosenClub != null && chosenClub.id != _currentClub?.id) {
      _currentClub = chosenClub;
      if (!_careerClubsHistory.any((c) => c.id == chosenClub.id)) {
        _careerClubsHistory.add(chosenClub);
      }
    }

    _currentStageIndex++;

    if (_currentStageIndex >= _maxStages) {
      _hasPendingPenalty = false;
      _finishCareer();
    } else {
      final seasonAge = currentAge;
      final seasonPerf = _simulateSeason(_currentClub!, seasonAge);
      _seasonHistory.add(seasonPerf);

      final highlight = _generateHighlight(_currentClub!, seasonAge, seasonPerf);
      _highlightsHistory.add(highlight);

      // Random chance (~42%) to trigger a full-screen penalty shootout after signing transfer
      // (Guaranteed at least once by stage 5 if none triggered yet)
      final bool triggerPenalty = forcePenalty ??
          (_random.nextDouble() < 0.42 || (_penaltiesTaken == 0 && _currentStageIndex == 5));
      _hasPendingPenalty = triggerPenalty;
      _lastPenaltyResult = null;

      _generateNextOffers();
    }

    notifyListeners();
  }

  void _finishCareer() {
    _isCareerFinished = true;

    int totalMatches = 0;
    int totalGoals = 0;
    int totalAssists = 0;
    final List<String> allTrophies = [];

    for (var perf in _seasonHistory) {
      totalMatches += perf.matches;
      totalGoals += perf.goals;
      totalAssists += perf.assists;
      allTrophies.addAll(perf.trophiesWon);
    }

    // Calculate FIFA-style Career Rating and Legacy Title
    int rating = 82;
    rating += (allTrophies.length * 1.2).round();
    rating += (_penaltiesScored * 1);
    if (_position == PlayerPosition.striker || _position == PlayerPosition.winger) {
      rating += (totalGoals / 45).round();
    } else {
      rating += (totalAssists / 24).round();
    }
    rating = rating.clamp(84, 98);

    String legacy;
    if (rating >= 95 || allTrophies.contains('Şampiyonlar Ligi')) {
      legacy = 'DÜNYA FUTBOL EFSANESİ';
    } else if (allTrophies.length >= 6) {
      legacy = 'KUPALARIN EFENDİSİ';
    } else if (_careerClubsHistory.length <= 2) {
      legacy = 'KULÜP BAYRAK ADAMI';
    } else {
      legacy = 'UNUTULMAZ YILDIZ';
    }

    _finalSummary = CareerSummary(
      playerName: _playerName,
      position: _position,
      nationality: _region,
      totalMatches: totalMatches,
      totalGoals: totalGoals,
      totalAssists: totalAssists,
      penaltiesScored: _penaltiesScored,
      penaltiesTaken: _penaltiesTaken,
      allTrophies: allTrophies,
      clubsPlayed: List.from(_careerClubsHistory),
      careerRating: rating,
      legacyTitle: legacy,
    );
  }

  SeasonPerformance _simulateSeason(ClubModel club, int age) {
    int matches = 28 + _random.nextInt(16); // 28 - 43 maç per 2-year stage window
    int goals = 0;
    int assists = 0;
    final List<String> trophies = [];

    // Realistic age curve + form momentum multiplier
    final isPrime = age >= 25 && age <= 29;
    double multiplier;
    if (age <= 18) {
      multiplier = 0.65;
    } else if (age <= 21) {
      multiplier = 0.88;
    } else if (isPrime) {
      multiplier = 1.25;
    } else if (age <= 31) {
      multiplier = 1.05;
    } else if (age <= 33) {
      multiplier = 0.85;
    } else {
      multiplier = 0.72;
    }

    // Factor in player's current form momentum (from penalties & past success)
    multiplier *= (0.75 + (_formMomentum / 100.0) * 0.45);

    switch (_position) {
      case PlayerPosition.striker:
        goals = ((14 + _random.nextInt(16)) * multiplier).round();
        assists = ((3 + _random.nextInt(7)) * multiplier).round();
        break;
      case PlayerPosition.winger:
        goals = ((9 + _random.nextInt(14)) * multiplier).round();
        assists = ((8 + _random.nextInt(12)) * multiplier).round();
        break;
      case PlayerPosition.attackingMid:
        goals = ((8 + _random.nextInt(12)) * multiplier).round();
        assists = ((10 + _random.nextInt(14)) * multiplier).round();
        break;
      case PlayerPosition.centralMid:
        goals = ((4 + _random.nextInt(7)) * multiplier).round();
        assists = ((6 + _random.nextInt(11)) * multiplier).round();
        break;
      case PlayerPosition.defender:
        goals = (1 + _random.nextInt(4));
        assists = (1 + _random.nextInt(5));
        break;
      case PlayerPosition.goalkeeper:
        goals = _random.nextInt(100) == 0 ? 1 : 0;
        assists = (0 + _random.nextInt(2));
        break;
    }

    // Trophy Simulation according to Club Tier & Form
    final isTopTier = [
      'real_madrid', 'man_city', 'bayern', 'barcelona', 'psg', 'inter', 'liverpool', 'arsenal'
    ].contains(club.id);

    final isTurkishGiant = [
      'galatasaray', 'fenerbahce', 'besiktas', 'trabzonspor'
    ].contains(club.id);

    final formBonusChance = (_formMomentum - 60) * 0.004;

    // League Title
    if ((isTopTier && _random.nextDouble() < (0.55 + formBonusChance)) ||
        (isTurkishGiant && _random.nextDouble() < (0.48 + formBonusChance)) ||
        _random.nextDouble() < 0.28) {
      trophies.add(club.league.isNotEmpty ? '${club.league} Şampiyonu' : 'Lig Şampiyonu');
    }

    // Domestic Cup
    if (_random.nextDouble() < (0.32 + formBonusChance)) {
      trophies.add('Ulusal Kupa Şampiyonu');
    }

    // UEFA Champions League / European Glory
    if (isTopTier && _random.nextDouble() < (0.30 + formBonusChance)) {
      trophies.add('Şampiyonlar Ligi');
    } else if (isTurkishGiant && _random.nextDouble() < 0.12) {
      trophies.add('Avrupa Ligi');
    }

    // Individual Glory in Prime
    if (isPrime && (goals >= 26 || assists >= 20) && trophies.isNotEmpty) {
      if (_random.nextDouble() < 0.35) {
        trophies.add('Altın Ayakkabı / Ballon d\'Or');
      }
    }

    return SeasonPerformance(
      matches: matches,
      goals: goals,
      assists: assists,
      trophiesWon: trophies,
    );
  }

  String _generateHighlight(ClubModel club, int age, SeasonPerformance perf) {
    final highlights = [
      '${club.name} formasıyla çıktığın derbi maçlardaki performansın tribünleri ayağa kaldırdı (İstatistikler gizli).',
      'Teknik direktörün seni takımın kilit ismi ilan etti; Avrupa kulüplerinin gözlemcileri peşinde.',
      'Kritik haftalarda sorumluluk alarak sahada liderliğini konuşturduğun bir dönem geçirdin.',
      'Şampiyonluk yarışı ve kupa gecelerinde adından sıkça söz ettirdin (Kupa ve gol sayıları jübilede açıklanacak).',
      'Deplasmanda sergilediğin futbol resitaliyle hem kendi taraftarından hem rakiplerden alkış topladın.',
      'Soyunma odasında ve sahada gerçek bir profesyonel olarak kariyer basamaklarını tırmanmaya devam ettin.',
    ];
    return highlights[_random.nextInt(highlights.length)];
  }

  void _generateNextOffers() {
    final allClubs = _database.getAllClubs();
    final available = allClubs.where((c) => c.id != _currentClub?.id).toList();
    available.shuffle(_random);

    _currentOffers = available.take(2).toList();
  }

  /// Provides a strategic contract & role promise for a transfer offer card
  String getOfferRoleDescription(ClubModel club, {required bool isStay}) {
    if (isStay) {
      return 'Takım Kaptanlığı • Taraftarın Bayrak Adamı';
    }
    const topTier = [
      'real_madrid', 'man_city', 'bayern', 'barcelona', 'psg', 'inter', 'liverpool', 'arsenal'
    ];
    const turkishGiants = [
      'galatasaray', 'fenerbahce', 'besiktas', 'trabzonspor'
    ];
    if (topTier.contains(club.id)) {
      return 'Dev Proje • Şampiyonlar Ligi Şampiyonluk Adayı';
    }
    if (turkishGiants.contains(club.id)) {
      return 'Yıldız Transfer • İlk 11 & Şampiyonluk Hedefi';
    }
    return 'Anahtar Oyuncu • İlk 11 Garantisi & Avrupa Hedefi';
  }

  ClubModel _getInitialClubForRegion(String reg) {
    final allClubs = _database.getAllClubs();
    if (reg == 'Türkiye') {
      final trClubs = allClubs.where((c) => c.country == 'Türkiye').toList();
      if (trClubs.isNotEmpty) {
        return trClubs[_random.nextInt(trClubs.length)];
      }
    } else if (reg == 'İspanya') {
      final spClubs = allClubs.where((c) => c.country == 'İspanya').toList();
      if (spClubs.isNotEmpty) return spClubs[_random.nextInt(spClubs.length)];
    } else if (reg == 'İngiltere') {
      final enClubs = allClubs.where((c) => c.country == 'İngiltere').toList();
      if (enClubs.isNotEmpty) return enClubs[_random.nextInt(enClubs.length)];
    } else if (reg == 'İtalya') {
      final itClubs = allClubs.where((c) => c.country == 'İtalya').toList();
      if (itClubs.isNotEmpty) return itClubs[_random.nextInt(itClubs.length)];
    } else if (reg == 'Almanya') {
      final deClubs = allClubs.where((c) => c.country == 'Almanya').toList();
      if (deClubs.isNotEmpty) return deClubs[_random.nextInt(deClubs.length)];
    }

    final academy = _database.getClub('ajax') ?? _database.getClub('sporting') ?? allClubs.first;
    return academy;
  }
}
