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
  final int _maxStages = 6;

  ClubModel? _currentClub;
  List<ClubModel> _currentOffers = [];
  final List<ClubModel> _careerClubsHistory = [];
  final List<SeasonPerformance> _seasonHistory = [];
  final List<String> _highlightsHistory = [];
  CareerSummary? _finalSummary;

  // Getters
  bool get isCareerActive => _isCareerActive;
  bool get isCareerFinished => _isCareerFinished;
  String get playerName => _playerName;
  PlayerPosition get position => _position;
  String get region => _region;
  int get currentStageIndex => _currentStageIndex;
  int get currentAge => _stageAges[_currentStageIndex.clamp(0, _stageAges.length - 1)];
  String get currentStageTitle => _stageTitles[_currentStageIndex.clamp(0, _stageTitles.length - 1)];
  ClubModel? get currentClub => _currentClub;
  List<ClubModel> get currentOffers => _currentOffers;
  List<ClubModel> get careerClubsHistory => _careerClubsHistory;
  List<SeasonPerformance> get seasonHistory => _seasonHistory;
  List<String> get highlightsHistory => _highlightsHistory;
  CareerSummary? get finalSummary => _finalSummary;

  static const List<int> _stageAges = [18, 22, 26, 30, 33, 36];
  static const List<String> _stageTitles = [
    'Altyapı & İlk Çıkış',
    'Gelişim & Büyük Sıçrama',
    'Zirve / Prime Dönemi',
    'Yıldız Liderlik',
    'Usta Kaptanlık',
    'Jübile & Son Dans',
  ];

  /// Start a brand new player career
  void startCareer({
    required String playerName,
    required PlayerPosition position,
    required String region,
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

    // Pick authentic starting club based on region
    final startingClub = _getInitialClubForRegion(region);
    _currentClub = startingClub;
    _careerClubsHistory.add(startingClub);

    // Generate initial performance and first transfer offers
    final initialSeason = _simulateSeason(startingClub, 18);
    _seasonHistory.add(initialSeason);
    _highlightsHistory.add('Profesyonel sözleşmeyi imzaladın ve ilk sezonunda dikkatleri üzerine çektin!');

    _generateNextOffers();
    notifyListeners();
  }

  /// User chooses to transfer to Club A, Club B, or stay
  void selectTransferDecision(ClubModel? chosenClub) {
    if (_isCareerFinished) return;

    if (chosenClub != null && chosenClub.id != _currentClub?.id) {
      _currentClub = chosenClub;
      if (!_careerClubsHistory.any((c) => c.id == chosenClub.id)) {
        _careerClubsHistory.add(chosenClub);
      }
    }

    _currentStageIndex++;

    if (_currentStageIndex >= _maxStages) {
      _finishCareer();
    } else {
      final seasonAge = currentAge;
      final seasonPerf = _simulateSeason(_currentClub!, seasonAge);
      _seasonHistory.add(seasonPerf);

      final highlight = _generateHighlight(_currentClub!, seasonAge, seasonPerf);
      _highlightsHistory.add(highlight);

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
    rating += (allTrophies.length * 1.5).round();
    if (_position == PlayerPosition.striker || _position == PlayerPosition.winger) {
      rating += (totalGoals / 40).round();
    } else {
      rating += (totalAssists / 20).round();
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
      allTrophies: allTrophies,
      clubsPlayed: List.from(_careerClubsHistory),
      careerRating: rating,
      legacyTitle: legacy,
    );
  }

  SeasonPerformance _simulateSeason(ClubModel club, int age) {
    int matches = 34 + _random.nextInt(18); // 34 - 52 maç
    int goals = 0;
    int assists = 0;
    final List<String> trophies = [];

    // Prime bonus at age 25-29
    final isPrime = age >= 25 && age <= 29;
    final multiplier = isPrime ? 1.3 : 1.0;

    switch (_position) {
      case PlayerPosition.striker:
        goals = ((18 + _random.nextInt(22)) * multiplier).round();
        assists = ((4 + _random.nextInt(9)) * multiplier).round();
        break;
      case PlayerPosition.winger:
        goals = ((12 + _random.nextInt(18)) * multiplier).round();
        assists = ((10 + _random.nextInt(16)) * multiplier).round();
        break;
      case PlayerPosition.attackingMid:
        goals = ((10 + _random.nextInt(15)) * multiplier).round();
        assists = ((14 + _random.nextInt(18)) * multiplier).round();
        break;
      case PlayerPosition.centralMid:
        goals = ((5 + _random.nextInt(9)) * multiplier).round();
        assists = ((8 + _random.nextInt(14)) * multiplier).round();
        break;
      case PlayerPosition.defender:
        goals = (1 + _random.nextInt(5));
        assists = (2 + _random.nextInt(6));
        break;
      case PlayerPosition.goalkeeper:
        goals = _random.nextInt(100) == 0 ? 1 : 0;
        assists = (0 + _random.nextInt(2));
        break;
    }

    // Trophy Simulation according to Club Tier
    final isTopTier = [
      'real_madrid', 'man_city', 'bayern', 'barcelona', 'psg', 'inter', 'liverpool', 'arsenal'
    ].contains(club.id);

    final isTurkishGiant = [
      'galatasaray', 'fenerbahce', 'besiktas', 'trabzonspor'
    ].contains(club.id);

    // League Title
    if ((isTopTier && _random.nextDouble() < 0.65) || (isTurkishGiant && _random.nextDouble() < 0.55) || _random.nextDouble() < 0.35) {
      trophies.add(club.league.isNotEmpty ? '${club.league} Şampiyonu' : 'Lig Şampiyonu');
    }

    // Domestic Cup
    if (_random.nextDouble() < 0.40) {
      trophies.add('Ulusal Kupa Şampiyonu');
    }

    // UEFA Champions League / European Glory
    if (isTopTier && _random.nextDouble() < 0.38) {
      trophies.add('Şampiyonlar Ligi');
    } else if (isTurkishGiant && _random.nextDouble() < 0.12) {
      trophies.add('Avrupa Ligi');
    }

    // Individual Glory in Prime
    if (isPrime && (goals >= 35 || assists >= 25) && trophies.isNotEmpty) {
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
      'Derbide 90+4. dakikada attığın unutulmaz golle tribünleri ayağa kaldırdın!',
      'Sezonun en iyi oyuncusu seçildin ve kaptanlık pazubandını koluna taktın.',
      'Büyük kupa finalinde maçın adamı seçilerek kupayı havaya kaldırdın.',
      'Muhteşem vole golün dünya çapında yılın golleri arasına girdi.',
      'Kritik deplasmanda sergilediğin resitalle rakip taraftarlarca alkışlandın.',
      'Şampiyonluk maçında hat-trick yaparak kulüp tarihine adını altın harflerle yazdırdın.',
    ];
    return highlights[_random.nextInt(highlights.length)];
  }

  void _generateNextOffers() {
    final allClubs = _database.getAllClubs();
    final available = allClubs.where((c) => c.id != _currentClub?.id).toList();
    available.shuffle(_random);

    _currentOffers = available.take(2).toList();
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

    // Default authentic academy clubs (Ajax, Sporting, Porto, etc.)
    final academy = _database.getClub('ajax') ?? _database.getClub('sporting') ?? allClubs.first;
    return academy;
  }
}
