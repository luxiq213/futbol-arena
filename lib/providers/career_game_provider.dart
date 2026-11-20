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
  CareerOriginStory? _originStory;

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

  static const List<CareerOriginStory> originStories = [
    CareerOriginStory(
      id: 'legacy_son',
      title: 'Eski Futbolcunun Oğlu',
      badgeTag: 'PREMIER LEAGUE MİRASI',
      originCountry: 'İngiltere',
      originLeague: 'Premier League',
      introStory:
          'Eski bir Premier Lig yıldızının çocuğu olarak çocukluğunu İngiltere stadyumlarının koridorlarında geçirdin. Soyadının getirdiği ağır beklentilere rağmen Ada futbolunda kendi imzanı atmaya başlıyorsun.',
      stageFlavors: [
        'Babandan miras oyun zekanla Premier League savunmalarını şaşkına çevirdin.',
        'İngiliz basını her maçını efsane babanın gençliğiyle kıyaslıyor.',
        'Ada futbolundaki sert tempoya alıştın, dev kulüplerin kapısı aralanıyor.',
      ],
      starterClubIds: ['everton', 'west_ham', 'aston_villa', 'newcastle'],
      progressionClubIds: [
        'liverpool',
        'arsenal',
        'chelsea',
        'man_united',
        'man_city',
        'tottenham',
        'real_madrid',
        'barcelona',
        'bayern',
      ],
      startingMomentumBonus: 4,
    ),
    CareerOriginStory(
      id: 'anadolu_wonderkid',
      title: 'Anadolu\'dan Parlayan Elmas',
      badgeTag: 'ANADOLU ÇIKIŞLI',
      originCountry: 'Türkiye',
      originLeague: 'Süper Lig',
      introStory:
          'Anadolu\'nun mütevazı çim sahalarından Süper Lig vitrinine fırlayan saf bir yeteneksin. Tüm ülkenin üç büyüklerden önce Avrupa kulüplerinin seni kapmasını konuştuğu o genç sensin.',
      stageFlavors: [
        'Anadolu kulübündeki müthiş çıkışın İstanbul devlerini harekete geçirdi.',
        'Süper Lig\'de haftanın oyuncusu seçilerek tüm Türkiye\'nin gündemine oturdun.',
        'Anadolu\'nun bağrından çıkıp Avrupa kulüplerinin gözlemcilerini peşine taktın.',
      ],
      starterClubIds: [
        'bursaspor',
        'sivasspor',
        'goztepe',
        'samsunspor',
        'adana_demirspor',
      ],
      progressionClubIds: [
        'galatasaray',
        'fenerbahce',
        'besiktas',
        'trabzonspor',
        'dortmund',
        'leverkusen',
        'inter',
        'arsenal',
      ],
      startingMomentumBonus: 2,
    ),
    CareerOriginStory(
      id: 'istanbul_derby_kid',
      title: 'Boğaz Derbilerinin Çocuğu',
      badgeTag: 'SÜPER LİG AKADEMİSİ',
      originCountry: 'Türkiye',
      originLeague: 'Süper Lig',
      introStory:
          'Henüz 17 yaşında 50 bin taraftarın uğultusu altında büyük bir Türk kulübünün altyapısından A takıma yükseldin. Derbi baskısını iliklerinde hissederek zirveye yürüyorsun.',
      stageFlavors: [
        'Derbi akşamındaki soğukkanlılığın seni taraftarın yeni gözdesi yaptı.',
        'Şampiyonluk ateşinin yandığı Süper Lig haftalarında sorumluluğu üstlendin.',
        'Türkiye\'nin dev sahnelerinden Avrupa Şampiyonlar Ligi arenasına göz kırptın.',
      ],
      starterClubIds: ['galatasaray', 'fenerbahce', 'besiktas', 'trabzonspor'],
      progressionClubIds: [
        'napoli',
        'roma',
        'benfica',
        'atletico_madrid',
        'psg',
        'inter',
        'galatasaray',
        'fenerbahce',
      ],
      startingMomentumBonus: 5,
    ),
    CareerOriginStory(
      id: 'iberia_maestro',
      title: 'İberya\'nın Pas Dehası',
      badgeTag: 'LA LIGA AKADEMİSİ',
      originCountry: 'İspanya',
      originLeague: 'La Liga',
      introStory:
          'İspanya\'nın teknik futbol ekolünde büyüyen, dar alanda tek dokunuşla savunma hatlarını delen nadir bir yeteneksin. La Liga çimlerinde ilk profesyonel imzanı atıyorsun.',
      stageFlavors: [
        'La Liga\'daki ipek gibi pas tekniğinle dev İspanyol kulüplerinin radarına girdin.',
        'İspanya\'nın taktik zekasını yüksek gol ve asist katkısıyla süsledin.',
        'Bernabéu ve Camp Nou devleri artık bonservisini sormaya başladı.',
      ],
      starterClubIds: [
        'real_sociedad',
        'real_betis',
        'villarreal',
        'valencia',
        'deportivo',
        'sevilla',
      ],
      progressionClubIds: [
        'barcelona',
        'real_madrid',
        'atletico_madrid',
        'man_city',
        'arsenal',
        'psg',
      ],
      startingMomentumBonus: 3,
    ),
    CareerOriginStory(
      id: 'calcio_tactician',
      title: 'Çizme\'nin Taktik Ustası',
      badgeTag: 'SERIE A OKULU',
      originCountry: 'İtalya',
      originLeague: 'Serie A',
      introStory:
          'İtalya\'nın sert savunma satrancı ve disiplinli gençlik akademilerinde yoğruldun. Serie A\'da taktik dehanla rakiplerinin planlarını daha 17 yaşında bozuyorsun.',
      stageFlavors: [
        'Serie A\'nın katı savunmaları arasında bulduğun çözümler hocaları büyüledi.',
        'İtalyan basını seni yeni neslin en akıllı Serie A yıldızı ilan etti.',
        'Milano, Torino ve Roma arasında senin için kıyasıya bir transfer yarışı var.',
      ],
      starterClubIds: ['atalanta', 'fiorentina', 'parma', 'lazio', 'roma'],
      progressionClubIds: [
        'inter',
        'milan',
        'juventus',
        'napoli',
        'real_madrid',
        'bayern',
        'chelsea',
      ],
      startingMomentumBonus: 3,
    ),
    CareerOriginStory(
      id: 'ruhr_dynamo',
      title: 'Ruhr Havzasının Dinamosu',
      badgeTag: 'BUNDESLİGA MAKİNESİ',
      originCountry: 'Almanya',
      originLeague: 'Bundesliga',
      introStory:
          'Almanya\'nın yüksek tempolu gegenpress fabrikasında çelik gibi bir kondisyonla yetiştin. 90 dakika boyunca durmayan motorunla Bundesliga\'yı sarsmaya hazırsın.',
      stageFlavors: [
        'Bundesliga\'nın baş döndüren hızında bitmek bilmeyen enerjinle fark yarattın.',
        'Sarı Duvar veya Bavyera devleri genç yaşına rağmen senin için sıraya girdi.',
        'Alman disipliniyle ulaştığın seviye seni tüm Avrupa\'nın gözdesi yaptı.',
      ],
      starterClubIds: ['schalke', 'wolfsburg', 'werder_bremen', 'leipzig'],
      progressionClubIds: [
        'dortmund',
        'leverkusen',
        'bayern',
        'liverpool',
        'arsenal',
        'real_madrid',
      ],
      startingMomentumBonus: 4,
    ),
    CareerOriginStory(
      id: 'paris_street_flair',
      title: 'Paris Sokaklarından Yıldızlığa',
      badgeTag: 'LIGUE 1 SOKAK FUTBOLU',
      originCountry: 'Fransa',
      originLeague: 'Ligue 1',
      introStory:
          'Paris banliyölerinin beton sahalarından çıkıp Ligue 1 akademilerine seçildin. Çalım cesaretin ve patlayıcı süratinle Fransa\'nın yeni süper yıldız adayısın.',
      stageFlavors: [
        'Ligue 1 savunmalarını sokak futbolu çalımlarınla tek tek geçtin.',
        'Fransa vitrinindeki şovun Premier League ve La Liga devlerini ayağa kaldırdı.',
        'Sokaklardan Dünya futbolunun en parlak sahnesine uzanan yolculuğun sürüyor.',
      ],
      starterClubIds: ['monaco', 'psg'],
      progressionClubIds: [
        'psg',
        'monaco',
        'arsenal',
        'chelsea',
        'real_madrid',
        'barcelona',
        'liverpool',
        'milan',
      ],
      startingMomentumBonus: 6,
    ),
    CareerOriginStory(
      id: 'lisbon_scout_gem',
      title: 'Lizbon Keşif Ağının Mücevheri',
      badgeTag: 'LIGA PORTUGAL VİTRİNİ',
      originCountry: 'Portekiz',
      originLeague: 'Liga Portugal',
      introStory:
          'Avrupa devlerinin her yaz rekor bonservislerle oyuncu kaptığı Portekiz futbol fabrikasından çıktın. Liga Portugal\'da vitrine çıktığın ilk günden beri tüm gözler üzerinde.',
      stageFlavors: [
        'Portekiz\'deki parlayışın sonrası İngiliz ve İspanyol scoutlar tribüne kamp kurdu.',
        'Liga Portugal derbilerinde gösterdiğin klasla değerini katladın.',
        'Avrupa\'nın bir sonraki dev çıkış transferi senin adınla anılıyor.',
      ],
      starterClubIds: ['sporting', 'benfica', 'porto'],
      progressionClubIds: [
        'porto',
        'benfica',
        'sporting',
        'man_united',
        'man_city',
        'chelsea',
        'arsenal',
        'real_madrid',
        'barcelona',
        'psg',
      ],
      startingMomentumBonus: 5,
    ),
    CareerOriginStory(
      id: 'ajax_total_heir',
      title: 'Amsterdam Total Futbol Mirasçısı',
      badgeTag: 'EREDİVİSİE EKOLÜ',
      originCountry: 'Hollanda',
      originLeague: 'Eredivisie',
      introStory:
          'Total Futbol felsefesinin kalbi Amsterdam\'da yetiştin. Oyunu iki yönlü okuyan zekanla Eredivisie\'den Avrupa\'nın en büyük tahtlarına göz dikiyorsun.',
      stageFlavors: [
        'Hollanda akademisinin saf tekniğini Eredivisie sahalarına kusursuz yansıttın.',
        'Ajax okulundan çıkan her efsane gibi senin de hedefin Avrupa\'nın zirvesi.',
        'Avrupa devleri Total Futbol disiplininle seni kadrosuna katmak istiyor.',
      ],
      starterClubIds: ['ajax'],
      progressionClubIds: [
        'barcelona',
        'juventus',
        'man_united',
        'arsenal',
        'bayern',
        'liverpool',
        'inter',
      ],
      startingMomentumBonus: 4,
    ),
    CareerOriginStory(
      id: 'english_cinderella',
      title: 'Ada Masalı: Alt Kümeden Zirveye',
      badgeTag: 'PREMIER LEAGUE MUCİZESİ',
      originCountry: 'İngiltere',
      originLeague: 'Premier League',
      introStory:
          'Kimsenin şans vermediği bir gençlik denemesinden mucize eseri kontrat kaptın. Sürprizlerin ve peri masallarının ligi Premier League\'de sıfırdan zirveye tırmanıyorsun.',
      stageFlavors: [
        'İngiltere alt kademelerinden gelen açlık ve hırsın Premier League\'i fethetti.',
        'Bir peri masalı gibi başlayan Ada kariyerin artık kupa avına dönüştü.',
        'İngiliz futbolunun devleri mütevazı başlangıcından zirveye çıkan seni izliyor.',
      ],
      starterClubIds: ['leicester', 'newcastle', 'tottenham', 'west_ham'],
      progressionClubIds: [
        'arsenal',
        'liverpool',
        'man_city',
        'chelsea',
        'inter',
        'atletico_madrid',
      ],
      startingMomentumBonus: 1,
    ),
  ];

  // Getters
  bool get isCareerActive => _isCareerActive;
  bool get isCareerFinished => _isCareerFinished;
  String get playerName => _playerName;
  PlayerPosition get position => _position;
  String get region => _region;
  CareerOriginStory? get originStory => _originStory;
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

  /// Start a brand new player career with one of the 10 randomized origin stories
  /// (unless a specific region or forcedStory is explicitly requested).
  void startCareer({
    required String playerName,
    required PlayerPosition position,
    String? region,
    CareerOriginStory? forcedStory,
  }) {
    _playerName = playerName.trim().isNotEmpty ? playerName.trim() : 'Kaptan';
    _position = position;

    final CareerOriginStory chosenStory;
    if (forcedStory != null) {
      chosenStory = forcedStory;
    } else if (region != null && region.trim().isNotEmpty) {
      final matching = originStories
          .where((s) => s.originCountry == region.trim())
          .toList();
      chosenStory = matching.isNotEmpty
          ? matching[_random.nextInt(matching.length)]
          : originStories[_random.nextInt(originStories.length)];
    } else {
      chosenStory = originStories[_random.nextInt(originStories.length)];
    }

    _originStory = chosenStory;
    _region = region != null && region.trim().isNotEmpty
        ? region.trim()
        : chosenStory.originCountry;
    _currentStageIndex = 0;
    _isCareerActive = true;
    _isCareerFinished = false;
    _careerClubsHistory.clear();
    _seasonHistory.clear();
    _highlightsHistory.clear();
    _finalSummary = null;
    _penaltiesScored = 0;
    _penaltiesTaken = 0;
    _formMomentum = (70 + chosenStory.startingMomentumBonus).clamp(60, 90);
    // Penalty does NOT appear on initial screen; it triggers randomly after signing a transfer
    _hasPendingPenalty = false;
    _lastPenaltyResult = null;

    // Pick authentic starting club from the drawn origin story's league
    final startingClub = _getInitialClubForStory(chosenStory);
    _currentClub = startingClub;
    _careerClubsHistory.add(startingClub);

    // Generate initial performance and first transfer offers
    final initialSeason = _simulateSeason(startingClub, _stageAges.first);
    _seasonHistory.add(initialSeason);
    _highlightsHistory.add(
      '${chosenStory.title} (${startingClub.country} • ${startingClub.league}): 17 yaşında ${startingClub.name} ile ilk profesyonel imzanı attın. İstatistiklerin jübilede açıklanacak!',
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
      originStoryTitle: _originStory?.title ?? '',
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
    final storyFlavors = _originStory?.stageFlavors ?? const <String>[];
    final genericHighlights = [
      '${club.name} formasıyla çıktığın derbi maçlardaki performansın tribünleri ayağa kaldırdı (İstatistikler gizli).',
      'Teknik direktörün seni takımın kilit ismi ilan etti; Avrupa kulüplerinin gözlemcileri peşinde.',
      'Kritik haftalarda sorumluluk alarak sahada liderliğini konuşturduğun bir dönem geçirdin.',
      'Şampiyonluk yarışı ve kupa gecelerinde adından sıkça söz ettirdin (Kupa ve gol sayıları jübilede açıklanacak).',
      'Deplasmanda sergilediğin futbol resitaliyle hem kendi taraftarından hem rakiplerden alkış topladın.',
      'Soyunma odasında ve sahada gerçek bir profesyonel olarak kariyer basamaklarını tırmanmaya devam ettin.',
    ];
    if (storyFlavors.isNotEmpty && _random.nextDouble() < 0.55) {
      return '${storyFlavors[_random.nextInt(storyFlavors.length)]} (${club.name} • ${club.league})';
    }
    return genericHighlights[_random.nextInt(genericHighlights.length)];
  }

  void _generateNextOffers() {
    final allClubs = _database.getAllClubs();
    final available = allClubs.where((c) => c.id != _currentClub?.id).toList();
    if (available.length <= 2) {
      _currentOffers = available;
      return;
    }

    final story = _originStory;
    if (story == null) {
      available.shuffle(_random);
      _currentOffers = available.take(2).toList();
      return;
    }

    // Story-guided progression:
    // Early career (stages 0..3): anchor heavily in origin league & story starter/step-up clubs.
    // Mid/Prime career (stages 4..7): favor story's progression clubs & continental challengers.
    // Late career (stages 8..9): nostalgic origin-league clubs + final challenges.
    final sameLeaguePool = available
        .where((c) => c.country == story.originCountry)
        .toList()
      ..shuffle(_random);
    final progressionPool = available
        .where((c) => story.progressionClubIds.contains(c.id))
        .toList()
      ..shuffle(_random);

    final picked = <ClubModel>[];
    if (_currentStageIndex <= 3 && sameLeaguePool.isNotEmpty && _random.nextDouble() < 0.80) {
      picked.add(sameLeaguePool.first);
    } else if (progressionPool.isNotEmpty && _random.nextDouble() < 0.78) {
      picked.add(progressionPool.first);
    }

    if (picked.length < 2) {
      final secondPool = (_currentStageIndex >= 7 && sameLeaguePool.isNotEmpty && _random.nextDouble() < 0.45)
          ? sameLeaguePool
          : (progressionPool.isNotEmpty && _random.nextDouble() < 0.60 ? progressionPool : available);
      final candidates = secondPool.where((c) => !picked.any((p) => p.id == c.id)).toList()
        ..shuffle(_random);
      if (candidates.isNotEmpty) {
        picked.add(candidates.first);
      }
    }

    available.shuffle(_random);
    for (final c in available) {
      if (picked.length >= 2) break;
      if (!picked.any((p) => p.id == c.id)) {
        picked.add(c);
      }
    }
    _currentOffers = picked.take(2).toList();
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

  ClubModel _getInitialClubForStory(CareerOriginStory story) {
    final storyClubs = story.starterClubIds
        .map(_database.getClub)
        .whereType<ClubModel>()
        .toList();
    if (storyClubs.isNotEmpty) {
      return storyClubs[_random.nextInt(storyClubs.length)];
    }

    final countryClubs = _database
        .getAllClubs()
        .where((c) => c.country == story.originCountry)
        .toList();
    if (countryClubs.isNotEmpty) {
      return countryClubs[_random.nextInt(countryClubs.length)];
    }

    final allClubs = _database.getAllClubs();
    return _database.getClub('ajax') ?? _database.getClub('sporting') ?? allClubs.first;
  }
}
