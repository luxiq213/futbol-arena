import 'dart:math';
import 'package:flutter/material.dart';
import '../models/club_model.dart';
import '../models/player_model.dart';
import '../models/grid_challenge_model.dart';
import '../../core/utils/text_normalizer.dart';

class FootballDatabase {
  static final FootballDatabase _instance = FootballDatabase._internal();
  factory FootballDatabase() => _instance;
  FootballDatabase._internal();

  final Random _random = Random();

  // --- CLUBS ---
  final Map<String, ClubModel> _clubs = {
    'real_madrid': const ClubModel(
      id: 'real_madrid',
      name: 'Real Madrid',
      shortName: 'RMA',
      country: 'İspanya',
      league: 'La Liga',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFFFEBE10),
      accentColor: Color(0xFF1E284A),
      pattern: BadgePattern.solidWithTrim,
    ),
    'barcelona': const ClubModel(
      id: 'barcelona',
      name: 'Barcelona',
      shortName: 'FCB',
      country: 'İspanya',
      league: 'La Liga',
      primaryColor: Color(0xFF004D98),
      secondaryColor: Color(0xFFA50044),
      accentColor: Color(0xFFEDBB00),
      pattern: BadgePattern.stripesVertical,
    ),
    'atletico_madrid': const ClubModel(
      id: 'atletico_madrid',
      name: 'Atlético Madrid',
      shortName: 'ATM',
      country: 'İspanya',
      league: 'La Liga',
      primaryColor: Color(0xFFCB3524),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF272E61),
      pattern: BadgePattern.stripesVertical,
    ),
    'sevilla': const ClubModel(
      id: 'sevilla',
      name: 'Sevilla',
      shortName: 'SEV',
      country: 'İspanya',
      league: 'La Liga',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFFD4001F),
      pattern: BadgePattern.solidWithTrim,
    ),
    'arsenal': const ClubModel(
      id: 'arsenal',
      name: 'Arsenal',
      shortName: 'ARS',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFFEF0107),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF063672),
      pattern: BadgePattern.solidWithTrim,
    ),
    'man_united': const ClubModel(
      id: 'man_united',
      name: 'Manchester United',
      shortName: 'MUN',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFFDA291C),
      secondaryColor: Color(0xFFFBE122),
      accentColor: Color(0xFF000000),
      pattern: BadgePattern.solidWithTrim,
    ),
    'man_city': const ClubModel(
      id: 'man_city',
      name: 'Manchester City',
      shortName: 'MCI',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFF6CABDD),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF1C2C5B),
      pattern: BadgePattern.solidWithTrim,
    ),
    'chelsea': const ClubModel(
      id: 'chelsea',
      name: 'Chelsea',
      shortName: 'CHE',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFF034694),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFEE242C),
      pattern: BadgePattern.solidWithTrim,
    ),
    'liverpool': const ClubModel(
      id: 'liverpool',
      name: 'Liverpool',
      shortName: 'LIV',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFFC8102E),
      secondaryColor: Color(0xFF00B2A9),
      accentColor: Color(0xFFF6EB61),
      pattern: BadgePattern.solidWithTrim,
    ),
    'tottenham': const ClubModel(
      id: 'tottenham',
      name: 'Tottenham Hotspur',
      shortName: 'TOT',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFF132257),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.solidWithTrim,
    ),
    'bayern': const ClubModel(
      id: 'bayern',
      name: 'Bayern Münih',
      shortName: 'BAY',
      country: 'Almanya',
      league: 'Bundesliga',
      primaryColor: Color(0xFFDC052D),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF0066B2),
      pattern: BadgePattern.solidWithTrim,
    ),
    'dortmund': const ClubModel(
      id: 'dortmund',
      name: 'Borussia Dortmund',
      shortName: 'BVB',
      country: 'Almanya',
      league: 'Bundesliga',
      primaryColor: Color(0xFFFDE100),
      secondaryColor: Color(0xFF000000),
      pattern: BadgePattern.solidWithTrim,
    ),
    'leverkusen': const ClubModel(
      id: 'leverkusen',
      name: 'Bayer Leverkusen',
      shortName: 'B04',
      country: 'Almanya',
      league: 'Bundesliga',
      primaryColor: Color(0xFF000000),
      secondaryColor: Color(0xFFE32221),
      pattern: BadgePattern.stripesVertical,
    ),
    'psg': const ClubModel(
      id: 'psg',
      name: 'Paris Saint-Germain',
      shortName: 'PSG',
      country: 'Fransa',
      league: 'Ligue 1',
      primaryColor: Color(0xFF004170),
      secondaryColor: Color(0xFFDA291C),
      accentColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.solidWithTrim,
    ),
    'monaco': const ClubModel(
      id: 'monaco',
      name: 'AS Monaco',
      shortName: 'ASM',
      country: 'Fransa',
      league: 'Ligue 1',
      primaryColor: Color(0xFFE2001A),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.halves,
    ),
    'juventus': const ClubModel(
      id: 'juventus',
      name: 'Juventus',
      shortName: 'JUV',
      country: 'İtalya',
      league: 'Serie A',
      primaryColor: Color(0xFF000000),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFFFD700),
      pattern: BadgePattern.stripesVertical,
    ),
    'milan': const ClubModel(
      id: 'milan',
      name: 'AC Milan',
      shortName: 'MIL',
      country: 'İtalya',
      league: 'Serie A',
      primaryColor: Color(0xFFFB090B),
      secondaryColor: Color(0xFF000000),
      pattern: BadgePattern.stripesVertical,
    ),
    'inter': const ClubModel(
      id: 'inter',
      name: 'Inter Milan',
      shortName: 'INT',
      country: 'İtalya',
      league: 'Serie A',
      primaryColor: Color(0xFF010E80),
      secondaryColor: Color(0xFF000000),
      pattern: BadgePattern.stripesVertical,
    ),
    'roma': const ClubModel(
      id: 'roma',
      name: 'AS Roma',
      shortName: 'ROM',
      country: 'İtalya',
      league: 'Serie A',
      primaryColor: Color(0xFF8E1F2F),
      secondaryColor: Color(0xFFF0BC42),
      pattern: BadgePattern.solidWithTrim,
    ),
    'napoli': const ClubModel(
      id: 'napoli',
      name: 'Napoli',
      shortName: 'NAP',
      country: 'İtalya',
      league: 'Serie A',
      primaryColor: Color(0xFF12A0D7),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.solidWithTrim,
    ),
    'galatasaray': const ClubModel(
      id: 'galatasaray',
      name: 'Galatasaray',
      shortName: 'GS',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFFA90432),
      secondaryColor: Color(0xFFFDB912),
      pattern: BadgePattern.halves,
    ),
    'fenerbahce': const ClubModel(
      id: 'fenerbahce',
      name: 'Fenerbahçe',
      shortName: 'FB',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFFFFED00),
      secondaryColor: Color(0xFF002D72),
      pattern: BadgePattern.stripesVertical,
    ),
    'besiktas': const ClubModel(
      id: 'besiktas',
      name: 'Beşiktaş',
      shortName: 'BJK',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFF000000),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFE30613),
      pattern: BadgePattern.stripesVertical,
    ),
    'trabzonspor': const ClubModel(
      id: 'trabzonspor',
      name: 'Trabzonspor',
      shortName: 'TS',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFF800000),
      secondaryColor: Color(0xFF41748D),
      pattern: BadgePattern.diagonalSash,
    ),
    'porto': const ClubModel(
      id: 'porto',
      name: 'FC Porto',
      shortName: 'FCP',
      country: 'Portekiz',
      league: 'Liga Portugal',
      primaryColor: Color(0xFF002F6C),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.stripesVertical,
    ),
    'benfica': const ClubModel(
      id: 'benfica',
      name: 'SL Benfica',
      shortName: 'SLB',
      country: 'Portekiz',
      league: 'Liga Portugal',
      primaryColor: Color(0xFFE8112d),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.solidWithTrim,
    ),
    'sporting': const ClubModel(
      id: 'sporting',
      name: 'Sporting CP',
      shortName: 'SCP',
      country: 'Portekiz',
      league: 'Liga Portugal',
      primaryColor: Color(0xFF008057),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFFFE500),
      pattern: BadgePattern.stripesVertical,
    ),
    'ajax': const ClubModel(
      id: 'ajax',
      name: 'Ajax',
      shortName: 'AJA',
      country: 'Hollanda',
      league: 'Eredivisie',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFFD2122E),
      pattern: BadgePattern.solidWithTrim,
    ),
  };

  // --- EXTENSIVE PLAYERS DATABASE (170+ PLAYERS) ---
  final List<PlayerModel> _players = [
    // 1. CRISTIANO RONALDO
    const PlayerModel(
      id: 'cristiano_ronaldo',
      name: 'Cristiano Ronaldo',
      country: 'Portekiz',
      position: 'Forvet',
      clubIds: ['sporting', 'man_united', 'real_madrid', 'juventus'],
      aliases: ['cr7', 'ronaldo', 'cristiano'],
      activeYears: '2002-Aktif',
      hint: '5 Ballon d\'Or sahibi efsane, Man Utd, Madrid ve Juve forması giydi.',
    ),
    // 2. LIONEL MESSI
    const PlayerModel(
      id: 'lionel_messi',
      name: 'Lionel Messi',
      country: 'Arjantin',
      position: 'Forvet / 10 Numara',
      clubIds: ['barcelona', 'psg'],
      aliases: ['messi', 'leo messi', 'goat'],
      activeYears: '2004-Aktif',
      hint: '8 Ballon d\'Or kazananı, Barcelona efsanesi ve Dünya Kupası şampiyonu.',
    ),
    // 3. ZLATAN IBRAHIMOVIC
    const PlayerModel(
      id: 'zlatan_ibrahimovic',
      name: 'Zlatan Ibrahimović',
      country: 'İsveç',
      position: 'Santrafor',
      clubIds: ['ajax', 'juventus', 'inter', 'barcelona', 'milan', 'psg', 'man_united'],
      aliases: ['zlatan', 'ibrahimovic', 'ibra'],
      activeYears: '1999-2023',
      hint: 'Ajax, Juve, Inter, Barca, Milan, PSG ve Man Utd forması giymiş gezgin dev forvet.',
    ),
    // 4. RONALDO NAZARIO
    const PlayerModel(
      id: 'ronaldo_nazario',
      name: 'Ronaldo Nazário (Fenomeno)',
      country: 'Brezilya',
      position: 'Santrafor',
      clubIds: ['barcelona', 'inter', 'real_madrid', 'milan'],
      aliases: ['ronaldo', 'el fenomeno', 'r9'],
      activeYears: '1993-2011',
      hint: 'Hem El Clasico hem de Milano derbisinin iki yakasında da oynamış Brezilyalı efsane 9.',
    ),
    // 5. RONALDINHO
    const PlayerModel(
      id: 'ronaldinho',
      name: 'Ronaldinho Gaúcho',
      country: 'Brezilya',
      position: '10 Numara / Sol Kanat',
      clubIds: ['psg', 'barcelona', 'milan'],
      aliases: ['ronaldinho', 'gaucho', 'dinho'],
      activeYears: '1998-2015',
      hint: 'Gülümsemesi ve sambasıyla meşhur büyücü; PSG, Barça ve Milan\'da oynadı.',
    ),
    // 6. LUIS FIGO
    const PlayerModel(
      id: 'luis_figo',
      name: 'Luís Figo',
      country: 'Portekiz',
      position: 'Sağ Kanat',
      clubIds: ['sporting', 'barcelona', 'real_madrid', 'inter'],
      aliases: ['figo', 'luis figo'],
      activeYears: '1989-2009',
      hint: 'Barcelona\'dan doğrudan Real Madrid\'e geçerek tarihe geçen Portekizli yıldız.',
    ),
    // 7. MESUT ÖZIL
    const PlayerModel(
      id: 'mesut_ozil',
      name: 'Mesut Özil',
      country: 'Almanya',
      position: '10 Numara',
      clubIds: ['real_madrid', 'arsenal', 'fenerbahce'],
      aliases: ['ozil', 'mesut', 'mesut ozil'],
      activeYears: '2006-2023',
      hint: 'Dünya Kupası şampiyonu, Real Madrid, Arsenal ve Fenerbahçe\'nin 10 numarası.',
    ),
    // 8. WESLEY SNEIJDER
    const PlayerModel(
      id: 'wesley_sneijder',
      name: 'Wesley Sneijder',
      country: 'Hollanda',
      position: '10 Numara',
      clubIds: ['ajax', 'real_madrid', 'inter', 'galatasaray'],
      aliases: ['sneijder', 'wesley'],
      activeYears: '2002-2019',
      hint: 'Inter ile Devler Ligi şampiyonu, Galatasaray\'ın efsanevi 10 numarası.',
    ),
    // 9. DIDIER DROGBA
    const PlayerModel(
      id: 'didier_drogba',
      name: 'Didier Drogba',
      country: 'Fildişi Sahili',
      position: 'Santrafor',
      clubIds: ['chelsea', 'galatasaray'],
      aliases: ['drogba'],
      activeYears: '1998-2018',
      hint: 'Münih\'teki Şampiyonlar Ligi finalinin kahramanı ve sarı-kırmızılı efsane forvet.',
    ),
    // 10. ROBERTO CARLOS
    const PlayerModel(
      id: 'roberto_carlos',
      name: 'Roberto Carlos',
      country: 'Brezilya',
      position: 'Sol Bek',
      clubIds: ['inter', 'real_madrid', 'fenerbahce'],
      aliases: ['carlos', 'roberto carlos'],
      activeYears: '1991-2012',
      hint: 'Füzeleriyle meşhur Brezilyalı sol bek efsanesi.',
    ),
    // 11. GHEORGHE HAGI
    const PlayerModel(
      id: 'gheorghe_hagi',
      name: 'Gheorghe Hagi',
      country: 'Romanya',
      position: '10 Numara',
      clubIds: ['real_madrid', 'barcelona', 'galatasaray'],
      aliases: ['hagi', 'karpatlarin maradonasi'],
      activeYears: '1982-2001',
      hint: 'Karpatların Maradonası! Real Madrid, Barcelona ve Galatasaray\'ın efsanesi.',
    ),
    // 12. GHEORGHE POPESCU
    const PlayerModel(
      id: 'gheorghe_popescu',
      name: 'Gheorghe Popescu',
      country: 'Romanya',
      position: 'Stoper',
      clubIds: ['tottenham', 'barcelona', 'galatasaray'],
      aliases: ['popescu'],
      activeYears: '1985-2003',
      hint: 'Tottenham, Barcelona ve Galatasaray forması giydi; 2000 UEFA Kupası son penaltısını attı.',
    ),
    // 13. ARDA TURAN
    const PlayerModel(
      id: 'arda_turan',
      name: 'Arda Turan',
      country: 'Türkiye',
      position: 'Oyun Kurucu / Kanat',
      clubIds: ['galatasaray', 'atletico_madrid', 'barcelona'],
      aliases: ['arda', 'arda turan'],
      activeYears: '2005-2022',
      hint: 'Atletico ile La Liga şampiyonu olup Barça\'ya transfer olan Türk futbol ikonu.',
    ),
    // 14. NICOLAS ANELKA
    const PlayerModel(
      id: 'nicolas_anelka',
      name: 'Nicolas Anelka',
      country: 'Fransa',
      position: 'Santrafor',
      clubIds: ['psg', 'arsenal', 'real_madrid', 'liverpool', 'man_city', 'fenerbahce', 'chelsea', 'juventus'],
      aliases: ['anelka'],
      activeYears: '1996-2015',
      hint: 'PSG, Arsenal, Real Madrid, Liverpool, City, FB, Chelsea ve Juve forması giydi!',
    ),
    // 15. CESC FABREGAS
    const PlayerModel(
      id: 'cesc_fabregas',
      name: 'Cesc Fàbregas',
      country: 'İspanya',
      position: 'Orta Saha',
      clubIds: ['arsenal', 'barcelona', 'chelsea', 'monaco'],
      aliases: ['fabregas', 'cesc'],
      activeYears: '2003-2023',
      hint: 'Arsenal kaptanıydı, Barcelona\'ya döndü, ardından Chelsea ve Monaco\'da oynadı.',
    ),
    // 16. EDEN HAZARD
    const PlayerModel(
      id: 'eden_hazard',
      name: 'Eden Hazard',
      country: 'Belçika',
      position: 'Sol Kanat',
      clubIds: ['chelsea', 'real_madrid'],
      aliases: ['hazard', 'eden'],
      activeYears: '2007-2023',
      hint: 'Chelsea\'de fırtına estirip dev bonservisle Real Madrid\'e transfer oldu.',
    ),
    // 17. THIBAUT COURTOIS
    const PlayerModel(
      id: 'thibaut_courtois',
      name: 'Thibaut Courtois',
      country: 'Belçika',
      position: 'Kaleci',
      clubIds: ['atletico_madrid', 'chelsea', 'real_madrid'],
      aliases: ['courtois'],
      activeYears: '2009-Aktif',
      hint: 'Madrid\'in iki devinde de ve Chelsea\'de kaleyi korumuş Belçikalı dev kaleci.',
    ),
    // 18. ANGEL DI MARIA
    const PlayerModel(
      id: 'angel_di_maria',
      name: 'Ángel Di María',
      country: 'Arjantin',
      position: 'Kanat / Ofansif',
      clubIds: ['benfica', 'real_madrid', 'man_united', 'psg', 'juventus'],
      aliases: ['di maria', 'dimaria', 'fideo'],
      activeYears: '2005-Aktif',
      hint: 'Finallerin adamı! Real Madrid, Man Utd, PSG ve Juventus forması giydi.',
    ),
    // 19. TONI KROOS
    const PlayerModel(
      id: 'toni_kroos',
      name: 'Toni Kroos',
      country: 'Almanya',
      position: 'Merkez Orta Saha',
      clubIds: ['bayern', 'leverkusen', 'real_madrid'],
      aliases: ['kroos', 'toni'],
      activeYears: '2007-2024',
      hint: 'Bayern ve Real Madrid ile toplam 6 Şampiyonlar Ligi kazanan pas profesörü.',
    ),
    // 20. XABI ALONSO
    const PlayerModel(
      id: 'xabi_alonso',
      name: 'Xabi Alonso',
      country: 'İspanya',
      position: 'Defansif Orta Saha',
      clubIds: ['liverpool', 'real_madrid', 'bayern'],
      aliases: ['alonso', 'xabi'],
      activeYears: '1999-2017',
      hint: 'Liverpool, Real Madrid ve Bayern formalarıyla uzun pas ustası maestro.',
    ),
    // 21. ARJEN ROBBEN
    const PlayerModel(
      id: 'arjen_robben',
      name: 'Arjen Robben',
      country: 'Hollanda',
      position: 'Sağ Kanat',
      clubIds: ['chelsea', 'real_madrid', 'bayern'],
      aliases: ['robben', 'arjen'],
      activeYears: '2000-2021',
      hint: 'Sağdan içeri çekip sol ayağıyla köşeye vuran Hollandalı; Chelsea, Real ve Bayern\'de oynadı.',
    ),
    // 22. ANDREA PIRLO
    const PlayerModel(
      id: 'andrea_pirlo',
      name: 'Andrea Pirlo',
      country: 'İtalya',
      position: 'Regista / Orta Saha',
      clubIds: ['inter', 'milan', 'juventus'],
      aliases: ['pirlo', 'maestro'],
      activeYears: '1995-2017',
      hint: 'İtalya\'nın üç devi Inter, Milan ve Juventus\'ta oynamış frikik virtüözü.',
    ),
    // 23. CLARENCE SEEDORF
    const PlayerModel(
      id: 'clarence_seedorf',
      name: 'Clarence Seedorf',
      country: 'Hollanda',
      position: 'Orta Saha',
      clubIds: ['ajax', 'real_madrid', 'inter', 'milan'],
      aliases: ['seedorf'],
      activeYears: '1992-2014',
      hint: '3 farklı kulüple (Ajax, Real Madrid, Milan) Şampiyonlar Ligi kazanan tek futbolcu.',
    ),
    // 24. DAVID BECKHAM
    const PlayerModel(
      id: 'david_beckham',
      name: 'David Beckham',
      country: 'İngiltere',
      position: 'Orta Saha / Kanat',
      clubIds: ['man_united', 'real_madrid', 'milan', 'psg'],
      aliases: ['beckham', 'becks'],
      activeYears: '1992-2013',
      hint: 'Tarihin en popüler frikikçisi; Man Utd, Real Madrid, Milan ve PSG\'de oynadı.',
    ),
    // 25. CASEMIRO
    const PlayerModel(
      id: 'casemiro',
      name: 'Casemiro',
      country: 'Brezilya',
      position: 'Ön Libero',
      clubIds: ['porto', 'real_madrid', 'man_united'],
      aliases: ['casemiro'],
      activeYears: '2010-Aktif',
      hint: 'Porto, Real Madrid ve Manchester United orta sahasının savaşçısı.',
    ),
    // 26. RAPHAEL VARANE
    const PlayerModel(
      id: 'raphael_varane',
      name: 'Raphaël Varane',
      country: 'Fransa',
      position: 'Stoper',
      clubIds: ['real_madrid', 'man_united'],
      aliases: ['varane'],
      activeYears: '2010-2024',
      hint: 'Real Madrid ve Manchester United\'da oynamış Fransız Dünya Kupası şampiyonu.',
    ),
    // 27. RUUD VAN NISTELROOY
    const PlayerModel(
      id: 'ruud_van_nistelrooy',
      name: 'Ruud van Nistelrooy',
      country: 'Hollanda',
      position: 'Santrafor',
      clubIds: ['man_united', 'real_madrid'],
      aliases: ['van nistelrooy', 'ruud'],
      activeYears: '1993-2012',
      hint: 'Ceza sahası içi ölümcül bitirici; Man Utd ve Real Madrid\'de gol krallıkları yaşadı.',
    ),
    // 28. GIANLUIGI BUFFON
    const PlayerModel(
      id: 'gianluigi_buffon',
      name: 'Gianluigi Buffon',
      country: 'İtalya',
      position: 'Kaleci',
      clubIds: ['juventus', 'psg'],
      aliases: ['buffon', 'gigi'],
      activeYears: '1995-2023',
      hint: 'İtalya ile Dünya Kupası kazanan efsane kaleci; Juve ve PSG kalelerini korudu.',
    ),
    // 29. DANI ALVES
    const PlayerModel(
      id: 'dani_alves',
      name: 'Dani Alves',
      country: 'Brezilya',
      position: 'Sağ Bek',
      clubIds: ['sevilla', 'barcelona', 'juventus', 'psg'],
      aliases: ['alves', 'dani alves'],
      activeYears: '2001-2023',
      hint: 'Sevilla, Barcelona, Juventus ve PSG ile 40\'tan fazla kupa kazandı.',
    ),
    // 30. OUSMANE DEMBELE
    const PlayerModel(
      id: 'ousmane_dembele',
      name: 'Ousmane Dembélé',
      country: 'Fransa',
      position: 'Kanat',
      clubIds: ['dortmund', 'barcelona', 'psg'],
      aliases: ['dembele', 'ousmane'],
      activeYears: '2015-Aktif',
      hint: 'İki ayağını da kullanan sprinter; Dortmund, Barcelona ve PSG forması giydi.',
    ),
    // 31. KINGSLEY COMAN
    const PlayerModel(
      id: 'kingsley_coman',
      name: 'Kingsley Coman',
      country: 'Fransa',
      position: 'Kanat',
      clubIds: ['psg', 'juventus', 'bayern'],
      aliases: ['coman'],
      activeYears: '2013-Aktif',
      hint: 'PSG altyapısı, Juventus ve Bayern Münih ile her sezon şampiyonluk yaşadı.',
    ),
    // 32. BURAK YILMAZ
    const PlayerModel(
      id: 'burak_yilmaz',
      name: 'Burak Yılmaz',
      country: 'Türkiye',
      position: 'Santrafor',
      clubIds: ['besiktas', 'fenerbahce', 'trabzonspor', 'galatasaray'],
      aliases: ['burak', 'kral burak'],
      activeYears: '2002-2023',
      hint: 'Dört büyüklerin dördünde birden forma giyen ve iki kez gol kralı olan milli forvet.',
    ),
    // 33. SERGEN YALÇIN
    const PlayerModel(
      id: 'sergen_yalcin',
      name: 'Sergen Yalçın',
      country: 'Türkiye',
      position: '10 Numara',
      clubIds: ['besiktas', 'fenerbahce', 'galatasaray', 'trabzonspor'],
      aliases: ['sergen'],
      activeYears: '1991-2008',
      hint: 'Dört büyüklerin hepsinde oynamış sol ayağı dahi Türk futbol efsanesi.',
    ),
    // 34. CANER ERKİN
    const PlayerModel(
      id: 'caner_erkin',
      name: 'Caner Erkin',
      country: 'Türkiye',
      position: 'Sol Bek',
      clubIds: ['galatasaray', 'fenerbahce', 'inter', 'besiktas'],
      aliases: ['caner', 'fisek'],
      activeYears: '2004-Aktif',
      hint: 'GS, FB, BJK üç büyüklerinde ve Inter\'de forma giymiş sol bek.',
    ),
    // 35. EMRE BELÖZOĞLU
    const PlayerModel(
      id: 'emre_belozoglu',
      name: 'Emre Belözoğlu',
      country: 'Türkiye',
      position: 'Orta Saha',
      clubIds: ['galatasaray', 'inter', 'fenerbahce', 'atletico_madrid'],
      aliases: ['emre'],
      activeYears: '1996-2020',
      hint: 'Galatasaray, Inter, Fenerbahçe ve Atletico Madrid formalarını terletti.',
    ),
    // 36. HAKAN ŞÜKÜR
    const PlayerModel(
      id: 'hakan_sukur',
      name: 'Hakan Şükür',
      country: 'Türkiye',
      position: 'Santrafor',
      clubIds: ['galatasaray', 'inter'],
      aliases: ['kral hakan', 'sukur'],
      activeYears: '1987-2008',
      hint: 'Dünya Kupası tarihinin en hızlı golcüsü, GS ve Inter santraforu.',
    ),
    // 37. RIGOBERT SONG
    const PlayerModel(
      id: 'rigobert_song',
      name: 'Rigobert Song',
      country: 'Kamerun',
      position: 'Stoper',
      clubIds: ['liverpool', 'galatasaray', 'trabzonspor'],
      aliases: ['song', 'rigobert song'],
      activeYears: '1994-2010',
      hint: 'Kamerunlu kaptan; Liverpool, Galatasaray ve Trabzonspor\'da savunmanın lideriydi.',
    ),
    // 38. ALEXANDER SÖRLOTH
    const PlayerModel(
      id: 'alexander_sorloth',
      name: 'Alexander Sørloth',
      country: 'Norveç',
      position: 'Santrafor',
      clubIds: ['trabzonspor', 'atletico_madrid'],
      aliases: ['sorloth', 'kuzeyin krali'],
      activeYears: '2013-Aktif',
      hint: 'Trabzonspor\'da gol kralı olan Kuzeyin Kralı, La Liga\'da Atletico Madrid\'e transfer oldu.',
    ),
    // 39. HAMİT ALTINTOP
    const PlayerModel(
      id: 'hamit_altintop',
      name: 'Hamit Altıntop',
      country: 'Türkiye',
      position: 'Orta Saha',
      clubIds: ['bayern', 'real_madrid', 'galatasaray'],
      aliases: ['hamit', 'altintop'],
      activeYears: '2000-2018',
      hint: 'Puskas ödüllü füzenin sahibi; Bayern, Real Madrid ve Galatasaray forması giydi.',
    ),
    // 40. LORIS KARIUS
    const PlayerModel(
      id: 'loris_karius',
      name: 'Loris Karius',
      country: 'Almanya',
      position: 'Kaleci',
      clubIds: ['liverpool', 'besiktas'],
      aliases: ['karius'],
      activeYears: '2012-Aktif',
      hint: 'Liverpool ile Şampiyonlar Ligi finali oynayıp Beşiktaş\'a transfer olan Alman eldiven.',
    ),
    // 41. MIRALEM PJANIC
    const PlayerModel(
      id: 'miralem_pjanic',
      name: 'Miralem Pjanić',
      country: 'Bosna-Hersek',
      position: 'Orta Saha',
      clubIds: ['roma', 'juventus', 'barcelona', 'besiktas'],
      aliases: ['pjanic'],
      activeYears: '2007-Aktif',
      hint: 'Roma, Juventus, Barcelona ve Beşiktaş forması giyen Bosnalı frikik ustası.',
    ),
    // 42. RICARDO QUARESMA
    const PlayerModel(
      id: 'ricardo_quaresma',
      name: 'Ricardo Quaresma',
      country: 'Portekiz',
      position: 'Kanat',
      clubIds: ['sporting', 'barcelona', 'porto', 'inter', 'chelsea', 'besiktas'],
      aliases: ['quaresma', 'trivela', 'q7'],
      activeYears: '2001-2022',
      hint: 'Trivela ve rabona ustası Portekizli büyücü; Sporting, Barça, Porto, Inter, Chelsea ve BJK ikonu.',
    ),
    // 43. SIMAO SABROSA
    const PlayerModel(
      id: 'simao_sabrosa',
      name: 'Simão Sabrosa',
      country: 'Portekiz',
      position: 'Kanat',
      clubIds: ['sporting', 'barcelona', 'benfica', 'atletico_madrid', 'besiktas'],
      aliases: ['simao'],
      activeYears: '1997-2014',
      hint: 'Sporting, Barça, Benfica, Atletico ve Beşiktaş\'ta oynamış Portekizli kanat.',
    ),
    // 44. GUTI HERNANDEZ
    const PlayerModel(
      id: 'guti_hernandez',
      name: 'Guti Hernández',
      country: 'İspanya',
      position: 'Orta Saha',
      clubIds: ['real_madrid', 'besiktas'],
      aliases: ['guti'],
      activeYears: '1995-2011',
      hint: 'Topuk paslarının efendisi Real Madrid kaptanı, kariyerini Beşiktaş\'ta noktaladı.',
    ),
    // 45. PEPE
    const PlayerModel(
      id: 'pepe',
      name: 'Pepe',
      country: 'Portekiz',
      position: 'Stoper',
      clubIds: ['porto', 'real_madrid', 'besiktas'],
      aliases: ['pepe'],
      activeYears: '2001-2024',
      hint: 'Porto, Real Madrid ve Beşiktaş\'ın efsanevi sert savunmacısı.',
    ),
    // 46. MARIO GOMEZ
    const PlayerModel(
      id: 'mario_gomez',
      name: 'Mario Gomez',
      country: 'Almanya',
      position: 'Santrafor',
      clubIds: ['bayern', 'besiktas'],
      aliases: ['gomez', 'mario gomez'],
      activeYears: '2003-2020',
      hint: 'Bayern ile Şampiyonlar Ligi, Beşiktaş ile Süper Lig şampiyonluğu ve gol krallığı yaşadı.',
    ),
    // 47. HAKAN ÇALHANOĞLU
    const PlayerModel(
      id: 'hakan_calhanoglu',
      name: 'Hakan Çalhanoğlu',
      country: 'Türkiye',
      position: 'Orta Saha',
      clubIds: ['leverkusen', 'milan', 'inter'],
      aliases: ['calhanoglu', 'hakan'],
      activeYears: '2011-Aktif',
      hint: 'Milano derbisinin iki yakasında da forma giyen milli takım kaptanımız.',
    ),
    // 48. FELIPE MELO
    const PlayerModel(
      id: 'felipe_melo',
      name: 'Felipe Melo',
      country: 'Brezilya',
      position: 'Ön Libero',
      clubIds: ['juventus', 'galatasaray', 'inter'],
      aliases: ['melo', 'pitbull'],
      activeYears: '2001-Aktif',
      hint: 'Pitbull lakaplı agresif Brezilyalı orta saha; Juve, Galatasaray ve Inter\'de oynadı.',
    ),
    // 49. ALEX TELLES
    const PlayerModel(
      id: 'alex_telles',
      name: 'Alex Telles',
      country: 'Brezilya',
      position: 'Sol Bek',
      clubIds: ['galatasaray', 'inter', 'porto', 'man_united', 'sevilla'],
      aliases: ['telles', 'alex telles'],
      activeYears: '2011-Aktif',
      hint: 'Galatasaray, Inter, Porto, Man United ve Sevilla forması giymiş Brezilyalı sol bek.',
    ),
    // 50. ROBIN VAN PERSIE
    const PlayerModel(
      id: 'robin_van_persie',
      name: 'Robin van Persie',
      country: 'Hollanda',
      position: 'Santrafor',
      clubIds: ['arsenal', 'man_united', 'fenerbahce'],
      aliases: ['van persie', 'rvp'],
      activeYears: '2001-2019',
      hint: 'Arsenal ve Manchester United\'da Premier Lig gol kralı, Kadıköy\'de uçan Hollandalı.',
    ),
    // 51. LUIS NANI
    const PlayerModel(
      id: 'luis_nani',
      name: 'Luís Nani',
      country: 'Portekiz',
      position: 'Kanat',
      clubIds: ['sporting', 'man_united', 'fenerbahce'],
      aliases: ['nani'],
      activeYears: '2005-Aktif',
      hint: 'Sporting altyapısı, Man Utd ile Devler Ligi şampiyonu, Fenerbahçe\'de de oynadı.',
    ),
    // 52. SAMIR NASRI
    const PlayerModel(
      id: 'samir_nasri',
      name: 'Samir Nasri',
      country: 'Fransa',
      position: 'Oyun Kurucu',
      clubIds: ['arsenal', 'man_city', 'sevilla'],
      aliases: ['nasri'],
      activeYears: '2004-2020',
      hint: 'Arsenal\'den Man City\'ye geçip şampiyonluklar yaşayan, Sevilla\'da da oynayan Fransız.',
    ),
    // 53. EMMANUEL ADEBAYOR
    const PlayerModel(
      id: 'emmanuel_adebayor',
      name: 'Emmanuel Adebayor',
      country: 'Togo',
      position: 'Santrafor',
      clubIds: ['monaco', 'arsenal', 'man_city', 'real_madrid', 'tottenham'],
      aliases: ['adebayor'],
      activeYears: '2001-2023',
      hint: 'Monaco, Arsenal, Man City, Real Madrid ve Tottenham forması giyen golcü.',
    ),
    // 54. GABRIEL JESUS
    const PlayerModel(
      id: 'gabriel_jesus',
      name: 'Gabriel Jesus',
      country: 'Brezilya',
      position: 'Santrafor',
      clubIds: ['man_city', 'arsenal'],
      aliases: ['jesus', 'gabriel jesus'],
      activeYears: '2015-Aktif',
      hint: 'Manchester City\'den Arsenal\'e transfer olan Brezilyalı 9 numara.',
    ),
    // 55. OLEKSANDR ZINCHENKO
    const PlayerModel(
      id: 'oleksandr_zinchenko',
      name: 'Oleksandr Zinchenko',
      country: 'Ukrayna',
      position: 'Sol Bek',
      clubIds: ['man_city', 'arsenal'],
      aliases: ['zinchenko'],
      activeYears: '2015-Aktif',
      hint: 'Manchester City\'den Arsenal\'e transfer olan Ukraynalı sol bek.',
    ),
    // 56. RAHEEM STERLING
    const PlayerModel(
      id: 'raheem_sterling',
      name: 'Raheem Sterling',
      country: 'İngiltere',
      position: 'Kanat',
      clubIds: ['liverpool', 'man_city', 'chelsea', 'arsenal'],
      aliases: ['sterling', 'raheem'],
      activeYears: '2012-Aktif',
      hint: 'Liverpool, Man City, Chelsea ve Arsenal; İngiltere\'nin 4 büyük devinde birden oynadı!',
    ),
    // 57. KAI HAVERTZ
    const PlayerModel(
      id: 'kai_havertz',
      name: 'Kai Havertz',
      country: 'Almanya',
      position: 'Forvet / Ofansif',
      clubIds: ['leverkusen', 'chelsea', 'arsenal'],
      aliases: ['havertz', 'kai'],
      activeYears: '2016-Aktif',
      hint: 'Leverkusen, Chelsea (CL finali golü) ve Arsenal formaları giydi.',
    ),
    // 58. JORGINHO
    const PlayerModel(
      id: 'jorginho',
      name: 'Jorginho',
      country: 'İtalya',
      position: 'Orta Saha',
      clubIds: ['napoli', 'chelsea', 'arsenal'],
      aliases: ['jorginho'],
      activeYears: '2010-Aktif',
      hint: 'Napoli, Chelsea ve Arsenal forması giyen zıplayan penaltıcı.',
    ),
    // 59. PETR CECH
    const PlayerModel(
      id: 'petr_cech',
      name: 'Petr Čech',
      country: 'Çekya',
      position: 'Kaleci',
      clubIds: ['chelsea', 'arsenal'],
      aliases: ['cech', 'petr cech'],
      activeYears: '1999-2019',
      hint: 'Kaskıyla efsaneleşen Çek dev kaleci; Chelsea ve Arsenal kalelerini korudu.',
    ),
    // 60. ASHLEY COLE
    const PlayerModel(
      id: 'ashley_cole',
      name: 'Ashley Cole',
      country: 'İngiltere',
      position: 'Sol Bek',
      clubIds: ['arsenal', 'chelsea', 'roma'],
      aliases: ['cole', 'ashley cole'],
      activeYears: '1998-2019',
      hint: 'Arsenal yenilmezlerinden Chelsea\'ye geçen ve Roma\'da da oynayan sol bek efsanesi.',
    ),
    // 61. DAVID LUIZ
    const PlayerModel(
      id: 'david_luiz',
      name: 'David Luiz',
      country: 'Brezilya',
      position: 'Stoper',
      clubIds: ['benfica', 'chelsea', 'psg', 'arsenal'],
      aliases: ['david luiz', 'luiz'],
      activeYears: '2006-Aktif',
      hint: 'Benfica, Chelsea, PSG ve Arsenal forması giyen kıvırcık saçlı savunmacı.',
    ),
    // 62. OLIVIER GIROUD
    const PlayerModel(
      id: 'olivier_giroud',
      name: 'Olivier Giroud',
      country: 'Fransa',
      position: 'Santrafor',
      clubIds: ['arsenal', 'chelsea', 'milan'],
      aliases: ['giroud'],
      activeYears: '2005-Aktif',
      hint: 'Arsenal, Chelsea ve Milan santraforu; Fransa ile Dünya Kupası şampiyonu.',
    ),
    // 63. ROBERT LEWANDOWSKI
    const PlayerModel(
      id: 'robert_lewandowski',
      name: 'Robert Lewandowski',
      country: 'Polonya',
      position: 'Santrafor',
      clubIds: ['dortmund', 'bayern', 'barcelona'],
      aliases: ['lewandowski', 'lewa'],
      activeYears: '2005-Aktif',
      hint: 'Dortmund, Bayern ve Barcelona\'da gol krallıkları yaşayan Polonyalı makine.',
    ),
    // 64. MARIO GOTZE
    const PlayerModel(
      id: 'mario_gotze',
      name: 'Mario Götze',
      country: 'Almanya',
      position: 'Ofansif Orta Saha',
      clubIds: ['dortmund', 'bayern'],
      aliases: ['gotze'],
      activeYears: '2009-Aktif',
      hint: 'Dortmund ve Bayern forması giydi; 2014 Dünya Kupası finali altın golünü attı.',
    ),
    // 65. MATS HUMMELS
    const PlayerModel(
      id: 'mats_hummels',
      name: 'Mats Hummels',
      country: 'Almanya',
      position: 'Stoper',
      clubIds: ['bayern', 'dortmund', 'roma'],
      aliases: ['hummels'],
      activeYears: '2006-Aktif',
      hint: 'Bayern ve Dortmund arasında transfer olmuş, Roma\'ya geçen Alman stoper.',
    ),
    // 66. ERLING HAALAND
    const PlayerModel(
      id: 'erling_haaland',
      name: 'Erling Haaland',
      country: 'Norveç',
      position: 'Santrafor',
      clubIds: ['dortmund', 'man_city'],
      aliases: ['haaland', 'erling'],
      activeYears: '2015-Aktif',
      hint: 'Dortmund\'dan City\'ye transfer olup tüm gol rekorlarını altüst eden Norveçli canavar.',
    ),
    // 67. ILKAY GÜNDOĞAN
    const PlayerModel(
      id: 'ilkay_gundogan',
      name: 'İlkay Gündoğan',
      country: 'Almanya',
      position: 'Orta Saha',
      clubIds: ['dortmund', 'man_city', 'barcelona'],
      aliases: ['ilkay', 'gundogan'],
      activeYears: '2008-Aktif',
      hint: 'Dortmund, Manchester City kaptanlığı ve Barcelona forması giyen Türk asıllı yıldız.',
    ),
    // 68. LUIS SUAREZ
    const PlayerModel(
      id: 'luis_suarez',
      name: 'Luis Suárez',
      country: 'Uruguay',
      position: 'Santrafor',
      clubIds: ['ajax', 'liverpool', 'barcelona', 'atletico_madrid'],
      aliases: ['suarez', 'el pistolero'],
      activeYears: '2005-Aktif',
      hint: 'El Pistolero; Ajax, Liverpool, Barcelona (MSN) ve Atletico Madrid\'de şampiyon oldu.',
    ),
    // 69. PHILIPPE COUTINHO
    const PlayerModel(
      id: 'philippe_coutinho',
      name: 'Philippe Coutinho',
      country: 'Brezilya',
      position: 'Ofansif Orta Saha',
      clubIds: ['inter', 'liverpool', 'barcelona', 'bayern'],
      aliases: ['coutinho'],
      activeYears: '2008-Aktif',
      hint: 'Inter, Liverpool, rekor bedelle Barcelona ve kiralık Bayern\'de oynadı.',
    ),
    // 70. JAVIER MASCHERANO
    const PlayerModel(
      id: 'javier_mascherano',
      name: 'Javier Mascherano',
      country: 'Arjantin',
      position: 'Ön Libero / Stoper',
      clubIds: ['liverpool', 'barcelona'],
      aliases: ['mascherano', 'el jefecito'],
      activeYears: '2003-2020',
      hint: 'Savaşçı ruhuyla Liverpool ve Barcelona\'nın değişilmezi olan Arjantinli.',
    ),
    // 71. SERGIO AGÜERO
    const PlayerModel(
      id: 'sergio_aguero',
      name: 'Sergio Agüero',
      country: 'Arjantin',
      position: 'Santrafor',
      clubIds: ['atletico_madrid', 'man_city', 'barcelona'],
      aliases: ['aguero', 'kun aguero'],
      activeYears: '2003-2021',
      hint: 'Atletico Madrid, City efsanesi (93:20 golü) ve kariyerini Barça\'da noktalayan santrafor.',
    ),
    // 72. RODRI
    const PlayerModel(
      id: 'rodri',
      name: 'Rodri',
      country: 'İspanya',
      position: 'Ön Libero',
      clubIds: ['atletico_madrid', 'man_city'],
      aliases: ['rodri', 'rodrigo hernandez'],
      activeYears: '2015-Aktif',
      hint: '2024 Ballon d\'Or kazananı; Atletico Madrid\'den Manchester City\'ye geçti.',
    ),
    // 73. JULIAN ALVAREZ
    const PlayerModel(
      id: 'julian_alvarez',
      name: 'Julián Álvarez',
      country: 'Arjantin',
      position: 'Forvet',
      clubIds: ['man_city', 'atletico_madrid'],
      aliases: ['alvarez', 'la arana'],
      activeYears: '2018-Aktif',
      hint: 'Dünya Kupası şampiyonu, Manchester City\'den Atletico Madrid\'e rekorla transfer oldu.',
    ),
    // 74. MICHAEL OWEN
    const PlayerModel(
      id: 'michael_owen',
      name: 'Michael Owen',
      country: 'İngiltere',
      position: 'Santrafor',
      clubIds: ['liverpool', 'real_madrid', 'man_united'],
      aliases: ['owen', 'michael owen'],
      activeYears: '1996-2013',
      hint: 'Ballon d\'Or sahibi İngiliz yıldız; Liverpool, Real Madrid ve Man United formaları giydi.',
    ),
    // 75. ALVARO MORATA
    const PlayerModel(
      id: 'alvaro_morata',
      name: 'Álvaro Morata',
      country: 'İspanya',
      position: 'Santrafor',
      clubIds: ['real_madrid', 'juventus', 'chelsea', 'atletico_madrid', 'milan'],
      aliases: ['morata'],
      activeYears: '2010-Aktif',
      hint: 'Real Madrid, Juventus, Chelsea, Atletico Madrid ve Milan santraforu.',
    ),
    // 76. MATEO KOVACIC
    const PlayerModel(
      id: 'mateo_kovacic',
      name: 'Mateo Kovačić',
      country: 'Hırvatistan',
      position: 'Orta Saha',
      clubIds: ['inter', 'real_madrid', 'chelsea', 'man_city'],
      aliases: ['kovacic'],
      activeYears: '2010-Aktif',
      hint: 'Inter, Real Madrid, Chelsea ve Manchester City formalarıyla 4 Şampiyonlar Ligi kazandı.',
    ),
    // 77. ANTONIO RÜDIGER
    const PlayerModel(
      id: 'antonio_rudiger',
      name: 'Antonio Rüdiger',
      country: 'Almanya',
      position: 'Stoper',
      clubIds: ['roma', 'chelsea', 'real_madrid'],
      aliases: ['rudiger'],
      activeYears: '2012-Aktif',
      hint: 'Roma, Chelsea ve Real Madrid savunmasının hızlı ve sert stoperi.',
    ),
    // 78. ALEXIS SANCHEZ
    const PlayerModel(
      id: 'alexis_sanchez',
      name: 'Alexis Sánchez',
      country: 'Şili',
      position: 'Forvet / Kanat',
      clubIds: ['barcelona', 'arsenal', 'man_united', 'inter'],
      aliases: ['alexis', 'sanchez'],
      activeYears: '2005-Aktif',
      hint: 'Barcelona, Arsenal, Manchester United ve Inter forması giyen Şilili yıldız.',
    ),
    // 79. ROMELU LUKAKU
    const PlayerModel(
      id: 'romelu_lukaku',
      name: 'Romelu Lukaku',
      country: 'Belçika',
      position: 'Santrafor',
      clubIds: ['chelsea', 'man_united', 'inter', 'roma', 'napoli'],
      aliases: ['lukaku'],
      activeYears: '2009-Aktif',
      hint: 'Chelsea, Man United, Inter, Roma ve Napoli formaları giyen dev Belçikalı 9 numara.',
    ),
    // 80. HAKIM ZIYECH
    const PlayerModel(
      id: 'hakim_ziyech',
      name: 'Hakim Ziyech',
      country: 'Fas',
      position: 'Sağ Kanat',
      clubIds: ['ajax', 'chelsea', 'galatasaray'],
      aliases: ['ziyech'],
      activeYears: '2012-Aktif',
      hint: 'Sol ayağı sihirli Faslı yıldız; Ajax, Chelsea ve Galatasaray forması giydi.',
    ),
    // 81. MAURO ICARDI
    const PlayerModel(
      id: 'mauro_icardi',
      name: 'Mauro Icardi',
      country: 'Arjantin',
      position: 'Santrafor',
      clubIds: ['inter', 'psg', 'galatasaray'],
      aliases: ['icardi'],
      activeYears: '2012-Aktif',
      hint: 'Inter kaptanı ve gol kralı, PSG ve Galatasaray\'ın sevgilisi Arjantinli bitirici.',
    ),
    // 82. DRIES MERTENS
    const PlayerModel(
      id: 'dries_mertens',
      name: 'Dries Mertens',
      country: 'Belçika',
      position: 'Forvet / 10 Numara',
      clubIds: ['napoli', 'galatasaray'],
      aliases: ['mertens', 'ciro'],
      activeYears: '2005-Aktif',
      hint: 'Napoli tarihinin en golcü futbolcusu, Galatasaray şampiyonluklarının mimarı.',
    ),
    // 83. LUCAS TORREIRA
    const PlayerModel(
      id: 'lucas_torreira',
      name: 'Lucas Torreira',
      country: 'Uruguay',
      position: 'Ön Libero',
      clubIds: ['arsenal', 'atletico_madrid', 'galatasaray'],
      aliases: ['torreira'],
      activeYears: '2014-Aktif',
      hint: 'Atom karınca; Arsenal, Atletico Madrid ve Galatasaray orta sahasının dinamosu.',
    ),
    // 84. MICHY BATSHUAYI
    const PlayerModel(
      id: 'michy_batshuayi',
      name: 'Michy Batshuayi',
      country: 'Belçika',
      position: 'Santrafor',
      clubIds: ['chelsea', 'dortmund', 'besiktas', 'fenerbahce', 'galatasaray'],
      aliases: ['batshuayi', 'batsman'],
      activeYears: '2011-Aktif',
      hint: 'Chelsea ve Dortmund sonrası Türkiye\'de BJK, FB ve GS formalarını giyen Batman.',
    ),
    // 85. VICTOR OSIMHEN
    const PlayerModel(
      id: 'victor_osimhen',
      name: 'Victor Osimhen',
      country: 'Nijerya',
      position: 'Santrafor',
      clubIds: ['napoli', 'galatasaray'],
      aliases: ['osimhen'],
      activeYears: '2017-Aktif',
      hint: 'Napoli\'ye 33 yıl sonra şampiyonluk getiren maskeli Afrika kralı, Galatasaray\'a transfer oldu.',
    ),
    // 86. DAVINSON SANCHEZ
    const PlayerModel(
      id: 'davinson_sanchez',
      name: 'Davinson Sánchez',
      country: 'Kolombiya',
      position: 'Stoper',
      clubIds: ['ajax', 'tottenham', 'galatasaray'],
      aliases: ['davinson', 'sanchez'],
      activeYears: '2013-Aktif',
      hint: 'Ajax, Tottenham ve Galatasaray savunmasının Kolombiyalı tank stoperi.',
    ),
    // 87. SACHA BOEY
    const PlayerModel(
      id: 'sacha_boey',
      name: 'Sacha Boey',
      country: 'Fransa',
      position: 'Sağ Bek',
      clubIds: ['galatasaray', 'bayern'],
      aliases: ['boey', 'sacha boey'],
      activeYears: '2019-Aktif',
      hint: 'Galatasaray\'dan rekor bedelle Bayern Münih\'e transfer olan Fransız sağ bek.',
    ),
    // 88. FRANCK RIBERY
    const PlayerModel(
      id: 'franck_ribery',
      name: 'Franck Ribéry',
      country: 'Fransa',
      position: 'Sol Kanat',
      clubIds: ['galatasaray', 'bayern'],
      aliases: ['ribery', 'scarface'],
      activeYears: '2000-2022',
      hint: 'Genç yaşta Galatasaray\'da parlayıp Bayern Münih efsanesine dönüşen Fransız sihirbaz.',
    ),
    // 89. DIRK KUYT
    const PlayerModel(
      id: 'dirk_kuyt',
      name: 'Dirk Kuyt',
      country: 'Hollanda',
      position: 'Kanat / Forvet',
      clubIds: ['liverpool', 'fenerbahce'],
      aliases: ['kuyt'],
      activeYears: '1998-2018',
      hint: 'Hiç durmayan ciğersiz Hollandalı; Liverpool ve Fenerbahçe taraftarının sevgilisi.',
    ),
    // 90. RAUL MEIRELES
    const PlayerModel(
      id: 'raul_meireles',
      name: 'Raul Meireles',
      country: 'Portekiz',
      position: 'Orta Saha',
      clubIds: ['porto', 'liverpool', 'chelsea', 'fenerbahce'],
      aliases: ['meireles'],
      activeYears: '2001-2016',
      hint: 'Dövmeleri ve sakalıyla ikon Portekizli; Porto, Liverpool, Chelsea ve Fenerbahçe\'de oynadı.',
    ),
    // 91. BRUNO ALVES
    const PlayerModel(
      id: 'bruno_alves',
      name: 'Bruno Alves',
      country: 'Portekiz',
      position: 'Stoper',
      clubIds: ['porto', 'fenerbahce'],
      aliases: ['bruno alves', 'alves'],
      activeYears: '1999-2022',
      hint: 'Porto kaptanlığı yapmış sert Portekizli stoper, Fenerbahçe\'de şampiyon oldu.',
    ),
    // 92. MARTIN SKRTEL
    const PlayerModel(
      id: 'martin_skrtel',
      name: 'Martin Škrtel',
      country: 'Slovakya',
      position: 'Stoper',
      clubIds: ['liverpool', 'fenerbahce'],
      aliases: ['skrtel'],
      activeYears: '2001-2022',
      hint: 'Liverpool savunmasının komutanıydı, ardından Fenerbahçe stoperi oldu.',
    ),
    // 93. SIMON KJAER
    const PlayerModel(
      id: 'simon_kjaer',
      name: 'Simon Kjær',
      country: 'Danimarka',
      position: 'Stoper',
      clubIds: ['roma', 'fenerbahce', 'sevilla', 'milan'],
      aliases: ['kjaer'],
      activeYears: '2007-Aktif',
      hint: 'Roma, Fenerbahçe, Sevilla ve Milan\'da forma giymiş Danimarka kaptanı.',
    ),
    // 94. KIM MIN-JAE
    const PlayerModel(
      id: 'kim_min_jae',
      name: 'Kim Min-jae',
      country: 'Güney Kore',
      position: 'Stoper',
      clubIds: ['fenerbahce', 'napoli', 'bayern'],
      aliases: ['kim', 'canavar'],
      activeYears: '2017-Aktif',
      hint: 'Fenerbahçe\'den Napoli\'ye gidip Serie A şampiyonu olan ve Bayern\'e geçen canavar.',
    ),
    // 95. ELJIF ELMAS
    const PlayerModel(
      id: 'eljif_elmas',
      name: 'Eljif Elmas',
      country: 'Kuzey Makedonya',
      position: 'Orta Saha',
      clubIds: ['fenerbahce', 'napoli'],
      aliases: ['elmas', 'eljif'],
      activeYears: '2015-Aktif',
      hint: 'Fenerbahçe\'den Napoli\'ye transfer olup Serie A şampiyonluğu yaşayan Makedon yetenek.',
    ),
    // 96. EDIN DZEKO
    const PlayerModel(
      id: 'edin_dzeko',
      name: 'Edin Džeko',
      country: 'Bosna-Hersek',
      position: 'Santrafor',
      clubIds: ['man_city', 'roma', 'inter', 'fenerbahce'],
      aliases: ['dzeko', 'bosna elmasi'],
      activeYears: '2003-Aktif',
      hint: 'Man City, Roma ve Inter sonrası Fenerbahçe kaptanı olan Boşnak gol makinesi.',
    ),
    // 97. DUSAN TADIC
    const PlayerModel(
      id: 'dusan_tadic',
      name: 'Dušan Tadić',
      country: 'Sırbistan',
      position: 'Kanat / 10 Numara',
      clubIds: ['ajax', 'fenerbahce'],
      aliases: ['tadic'],
      activeYears: '2006-Aktif',
      hint: 'Ajax\'ın yarı final oynayan tarihi kadrosunun kaptanı, Fenerbahçe\'nin maestrosu.',
    ),
    // 98. FRED
    const PlayerModel(
      id: 'fred_rodrigues',
      name: 'Fred (Frederico Rodrigues)',
      country: 'Brezilya',
      position: 'Orta Saha',
      clubIds: ['man_united', 'fenerbahce'],
      aliases: ['fred'],
      activeYears: '2012-Aktif',
      hint: 'Manchester United orta sahasından Fenerbahçe\'ye transfer olan dinamik Sambacı.',
    ),
    // 99. SOFYAN AMRABAT
    const PlayerModel(
      id: 'sofyan_amrabat',
      name: 'Sofyan Amrabat',
      country: 'Fas',
      position: 'Ön Libero',
      clubIds: ['man_united', 'fenerbahce'],
      aliases: ['amrabat', 'sofyan'],
      activeYears: '2014-Aktif',
      hint: 'Fas ile Dünya Kupası yarı finali oynayan tank; Man United ve Fenerbahçe forması giydi.',
    ),
    // 100. YOUSSEF EN-NESYRI
    const PlayerModel(
      id: 'youssef_en_nesyri',
      name: 'Youssef En-Nesyri',
      country: 'Fas',
      position: 'Santrafor',
      clubIds: ['sevilla', 'fenerbahce'],
      aliases: ['en nesyri', 'ennesyri'],
      activeYears: '2016-Aktif',
      hint: 'Sevilla ile Avrupa Ligleri kazanan hava topu ustası Faslı forvet, Fenerbahçe\'ye geldi.',
    ),
    // 101. CIRO IMMOBILE
    const PlayerModel(
      id: 'ciro_immobile',
      name: 'Ciro Immobile',
      country: 'İtalya',
      position: 'Santrafor',
      clubIds: ['juventus', 'dortmund', 'sevilla', 'besiktas'],
      aliases: ['immobile'],
      activeYears: '2009-Aktif',
      hint: 'Lazio tarihinin gol kralı; Juventus, Dortmund, Sevilla ve Beşiktaş forması giydi.',
    ),
    // 102. RAFA SILVA
    const PlayerModel(
      id: 'rafa_silva',
      name: 'Rafa Silva',
      country: 'Portekiz',
      position: 'Kanat / 10 Numara',
      clubIds: ['benfica', 'besiktas'],
      aliases: ['rafa', 'rafa silva'],
      activeYears: '2011-Aktif',
      hint: 'Benfica\'da yıllarca şampiyonluklar yaşayan Portekizli hızlı yıldız Beşiktaş\'a geldi.',
    ),
    // 103. JOAO MARIO
    const PlayerModel(
      id: 'joao_mario',
      name: 'João Mário',
      country: 'Portekiz',
      position: 'Orta Saha',
      clubIds: ['sporting', 'inter', 'benfica', 'besiktas'],
      aliases: ['joao mario'],
      activeYears: '2011-Aktif',
      hint: 'Sporting, Inter, Benfica ve Beşiktaş forması giyen Euro 2016 şampiyonu Portekizli.',
    ),
    // 104. ALEX OXLADE-CHAMBERLAIN
    const PlayerModel(
      id: 'alex_oxlade_chamberlain',
      name: 'Alex Oxlade-Chamberlain',
      country: 'İngiltere',
      position: 'Orta Saha',
      clubIds: ['arsenal', 'liverpool', 'besiktas'],
      aliases: ['chamberlain', 'the ox'],
      activeYears: '2010-Aktif',
      hint: 'Arsenal ve Liverpool ile Devler Ligi kazandı, Beşiktaş\'a transfer oldu.',
    ),
    // 105. DELE ALLI
    const PlayerModel(
      id: 'dele_alli',
      name: 'Dele Alli',
      country: 'İngiltere',
      position: 'Ofansif Orta Saha',
      clubIds: ['tottenham', 'besiktas'],
      aliases: ['dele', 'alli'],
      activeYears: '2012-Aktif',
      hint: 'Tottenham\'da parlayan İngiliz milli yıldız, kiralık olarak Beşiktaş\'a gelmişti.',
    ),
    // 106. PIERRE-EMERICK AUBAMEYANG
    const PlayerModel(
      id: 'aubameyang',
      name: 'Pierre-Emerick Aubameyang',
      country: 'Gabon',
      position: 'Santrafor',
      clubIds: ['milan', 'monaco', 'dortmund', 'arsenal', 'barcelona', 'chelsea'],
      aliases: ['auba', 'aubameyang'],
      activeYears: '2008-Aktif',
      hint: 'Dortmund ve Arsenal\'de gol krallıkları yaşadı; Milan, Barça ve Chelsea\'de de oynadı.',
    ),
    // 107. HENRIKH MKHITARYAN
    const PlayerModel(
      id: 'mkhitaryan',
      name: 'Henrikh Mkhitaryan',
      country: 'Ermenistan',
      position: 'Orta Saha',
      clubIds: ['dortmund', 'man_united', 'arsenal', 'roma', 'inter'],
      aliases: ['mkhitaryan', 'miki'],
      activeYears: '2006-Aktif',
      hint: 'Dortmund, Man Utd (Avrupa Ligi golü), Arsenal, Roma ve Inter forması giydi.',
    ),
    // 108. JAMES RODRIGUEZ
    const PlayerModel(
      id: 'james_rodriguez',
      name: 'James Rodríguez',
      country: 'Kolombiya',
      position: '10 Numara',
      clubIds: ['porto', 'monaco', 'real_madrid', 'bayern'],
      aliases: ['james', 'james rodriguez'],
      activeYears: '2006-Aktif',
      hint: '2014 Dünya Kupası gol kralı; Porto, Monaco, Real Madrid ve Bayern\'de oynadı.',
    ),
    // 109. RADAMEL FALCAO
    const PlayerModel(
      id: 'radamel_falcao',
      name: 'Radamel Falcao',
      country: 'Kolombiya',
      position: 'Santrafor',
      clubIds: ['porto', 'atletico_madrid', 'monaco', 'man_united', 'chelsea', 'galatasaray'],
      aliases: ['falcao', 'el tigre'],
      activeYears: '1999-Aktif',
      hint: 'El Tigre! Porto, Atletico Madrid, Monaco, Man Utd, Chelsea ve Galatasaray santraforu.',
    ),
    // 110. DIEGO COSTA
    const PlayerModel(
      id: 'diego_costa',
      name: 'Diego Costa',
      country: 'İspanya',
      position: 'Santrafor',
      clubIds: ['atletico_madrid', 'chelsea'],
      aliases: ['diego costa', 'costa'],
      activeYears: '2006-Aktif',
      hint: 'Simeone\'nin Atletico\'su ve Conte\'nin Chelsea\'sinde Premier Lig/La Liga şampiyonu santrafor.',
    ),
    // 111. DAVID VILLA
    const PlayerModel(
      id: 'david_villa',
      name: 'David Villa',
      country: 'İspanya',
      position: 'Santrafor',
      clubIds: ['barcelona', 'atletico_madrid'],
      aliases: ['villa', 'el guaje'],
      activeYears: '2000-2020',
      hint: 'İspanya tarihinin en golcüsü; Barcelona ve Atletico Madrid ile lig şampiyonlukları yaşadı.',
    ),
    // 112. FERNANDO TORRES
    const PlayerModel(
      id: 'fernando_torres',
      name: 'Fernando Torres',
      country: 'İspanya',
      position: 'Santrafor',
      clubIds: ['atletico_madrid', 'liverpool', 'chelsea', 'milan'],
      aliases: ['torres', 'el nino'],
      activeYears: '2001-2019',
      hint: 'El Niño! Atletico altyapısı, Liverpool\'da fırtına, Chelsea ile Şampiyonlar Ligi ve Milan.',
    ),
    // 113. SAMUEL ETO'O
    const PlayerModel(
      id: 'samuel_etoo',
      name: 'Samuel Eto\'o',
      country: 'Kamerun',
      position: 'Santrafor',
      clubIds: ['real_madrid', 'barcelona', 'inter', 'chelsea'],
      aliases: ['etoo'],
      activeYears: '1997-2019',
      hint: 'Real Madrid, Barcelona (üçleme), Inter (üçleme) ve Chelsea santraforu.',
    ),
    // 114. MICHAEL LAUDRUP
    const PlayerModel(
      id: 'michael_laudrup',
      name: 'Michael Laudrup',
      country: 'Danimarka',
      position: '10 Numara',
      clubIds: ['juventus', 'barcelona', 'real_madrid', 'ajax'],
      aliases: ['laudrup'],
      activeYears: '1981-1998',
      hint: 'Juve, Cruyff\'un Barça Rüya Takımı ve ardından Real Madrid\'de şampiyon olan Danimarkalı dahi.',
    ),
    // 115. LUIS ENRIQUE
    const PlayerModel(
      id: 'luis_enrique',
      name: 'Luis Enrique',
      country: 'İspanya',
      position: 'Orta Saha',
      clubIds: ['real_madrid', 'barcelona'],
      aliases: ['enrique', 'luis enrique'],
      activeYears: '1989-2004',
      hint: 'Real Madrid\'den doğrudan Barcelona\'ya transfer olup Katalanların efsane kaptanı oldu.',
    ),
    // 116. BERND SCHUSTER
    const PlayerModel(
      id: 'bernd_schuster',
      name: 'Bernd Schuster',
      country: 'Almanya',
      position: 'Orta Saha',
      clubIds: ['barcelona', 'real_madrid', 'atletico_madrid', 'leverkusen'],
      aliases: ['schuster'],
      activeYears: '1978-1997',
      hint: 'İspanya\'nın üç devi Barça, Real Madrid ve Atletico Madrid formalarını giyen sarı saçlı melek.',
    ),
    // 117. JAVIER SAVIOLA
    const PlayerModel(
      id: 'javier_saviola',
      name: 'Javier Saviola',
      country: 'Arjantin',
      position: 'Santrafor',
      clubIds: ['barcelona', 'monaco', 'sevilla', 'real_madrid', 'benfica'],
      aliases: ['saviola', 'el conejito'],
      activeYears: '1998-2016',
      hint: 'Tavşan lakaplı forvet; Barcelona, Monaco, Sevilla, Real Madrid ve Benfica\'da oynadı.',
    ),
    // 118. JUAN MATA
    const PlayerModel(
      id: 'juan_mata',
      name: 'Juan Mata',
      country: 'İspanya',
      position: '10 Numara',
      clubIds: ['chelsea', 'man_united', 'galatasaray'],
      aliases: ['mata'],
      activeYears: '2006-Aktif',
      hint: 'Dünya Kupası şampiyonu; Chelsea, Man United ve Galatasaray formaları giydi.',
    ),
    // 119. NEMANJA MATIC
    const PlayerModel(
      id: 'nemanja_matic',
      name: 'Nemanja Matić',
      country: 'Sırbistan',
      position: 'Ön Libero',
      clubIds: ['chelsea', 'benfica', 'man_united', 'roma'],
      aliases: ['matic'],
      activeYears: '2005-Aktif',
      hint: 'Benfica, Chelsea, Manchester United ve Roma\'da Mourinho\'nun değişilmezi oldu.',
    ),
    // 120. WILLIAN
    const PlayerModel(
      id: 'willian_borges',
      name: 'Willian',
      country: 'Brezilya',
      position: 'Kanat',
      clubIds: ['chelsea', 'arsenal'],
      aliases: ['willian'],
      activeYears: '2006-Aktif',
      hint: 'Chelsea\'de yıllarca kupa kaldırdıktan sonra Londra\'nın diğer yakası Arsenal\'e geçti.',
    ),
    // 121. KOLO TOURÉ
    const PlayerModel(
      id: 'kolo_toure',
      name: 'Kolo Touré',
      country: 'Fildişi Sahili',
      position: 'Stoper',
      clubIds: ['arsenal', 'man_city', 'liverpool'],
      aliases: ['kolo toure', 'kolo'],
      activeYears: '1999-2017',
      hint: 'Arsenal\'in namağlup şampiyonu, Manchester City ve Liverpool forması giydi.',
    ),
    // 122. YAYA TOURÉ
    const PlayerModel(
      id: 'yaya_toure',
      name: 'Yaya Touré',
      country: 'Fildişi Sahili',
      position: 'Merkez Orta Saha',
      clubIds: ['monaco', 'barcelona', 'man_city'],
      aliases: ['yaya toure', 'yaya'],
      activeYears: '2001-2019',
      hint: 'Monaco, Barcelona (üçleme) ve Manchester City tarihinin orta saha devi.',
    ),
    // 123. SOL CAMPBELL
    const PlayerModel(
      id: 'sol_campbell',
      name: 'Sol Campbell',
      country: 'İngiltere',
      position: 'Stoper',
      clubIds: ['tottenham', 'arsenal'],
      aliases: ['campbell', 'sol campbell'],
      activeYears: '1992-2011',
      hint: 'Tottenham kaptanıyken ezeli rakip Arsenal\'e bedelsiz geçerek Premier Lig tarihine geçti.',
    ),
    // 124. WILLIAM GALLAS
    const PlayerModel(
      id: 'william_gallas',
      name: 'William Gallas',
      country: 'Fransa',
      position: 'Stoper',
      clubIds: ['chelsea', 'arsenal', 'tottenham'],
      aliases: ['gallas'],
      activeYears: '1995-2014',
      hint: 'Londra\'nın üç büyük devi Chelsea, Arsenal ve Tottenham formalarının hepsini giydi!',
    ),
    // 125. PATRICK VIEIRA
    const PlayerModel(
      id: 'patrick_vieira',
      name: 'Patrick Vieira',
      country: 'Fransa',
      position: 'Orta Saha',
      clubIds: ['milan', 'arsenal', 'juventus', 'inter', 'man_city'],
      aliases: ['vieira'],
      activeYears: '1993-2011',
      hint: 'Arsenal yenilmez kaptanı; Milan, Juve, Inter ve City formaları da giydi.',
    ),
    // 126. GAEL CLICHY
    const PlayerModel(
      id: 'gael_clichy',
      name: 'Gaël Clichy',
      country: 'Fransa',
      position: 'Sol Bek',
      clubIds: ['arsenal', 'man_city'],
      aliases: ['clichy'],
      activeYears: '2002-2023',
      hint: 'Arsenal ve Manchester City ile Premier Lig şampiyonlukları yaşadı.',
    ),
    // 127. BACARY SAGNA
    const PlayerModel(
      id: 'bacary_sagna',
      name: 'Bacary Sagna',
      country: 'Fransa',
      position: 'Sağ Bek',
      clubIds: ['arsenal', 'man_city'],
      aliases: ['sagna'],
      activeYears: '2004-2019',
      hint: 'Arsenal\'den Manchester City\'ye transfer olan Fransız sağ bek.',
    ),
    // 128. LASSANA DIARRA
    const PlayerModel(
      id: 'lassana_diarra',
      name: 'Lassana Diarra',
      country: 'Fransa',
      position: 'Ön Libero',
      clubIds: ['chelsea', 'arsenal', 'real_madrid', 'psg'],
      aliases: ['diarra', 'lass'],
      activeYears: '2004-2019',
      hint: 'Chelsea, Arsenal, Real Madrid (10 numara formayı giymişti!) ve PSG forması giydi.',
    ),
    // 129. MARTIN ODEGAARD
    const PlayerModel(
      id: 'martin_odegaard',
      name: 'Martin Ødegaard',
      country: 'Norveç',
      position: '10 Numara',
      clubIds: ['real_madrid', 'arsenal'],
      aliases: ['odegaard', 'martin odegaard'],
      activeYears: '2014-Aktif',
      hint: '16 yaşında Real Madrid\'e transfer oldu, günümüzde Arsenal\'in kaptanı ve beyni.',
    ),
    // 130. DANI CEBALLOS
    const PlayerModel(
      id: 'dani_ceballos',
      name: 'Dani Ceballos',
      country: 'İspanya',
      position: 'Merkez Orta Saha',
      clubIds: ['real_madrid', 'arsenal'],
      aliases: ['ceballos'],
      activeYears: '2014-Aktif',
      hint: 'Real Madrid ve Arsenal orta sahalarında teknik paslarıyla bilinen İspanyol.',
    ),
    // 131. JUDE BELLINGHAM
    const PlayerModel(
      id: 'jude_bellingham',
      name: 'Jude Bellingham',
      country: 'İngiltere',
      position: 'Ofansif Orta Saha',
      clubIds: ['dortmund', 'real_madrid'],
      aliases: ['bellingham', 'jude'],
      activeYears: '2019-Aktif',
      hint: 'Dortmund\'dan Real Madrid\'e transfer olup ilk sezonunda La Liga ve Devler Ligi kazandı.',
    ),
    // 132. ACHRAF HAKIMI
    const PlayerModel(
      id: 'achraf_hakimi',
      name: 'Achraf Hakimi',
      country: 'Fas',
      position: 'Sağ Bek',
      clubIds: ['real_madrid', 'dortmund', 'inter', 'psg'],
      aliases: ['hakimi'],
      activeYears: '2016-Aktif',
      hint: 'Real Madrid altyapısı; Dortmund, Inter ve PSG\'de dünyanın en iyi sağ beklerinden biri oldu.',
    ),
    // 133. THEO HERNANDEZ
    const PlayerModel(
      id: 'theo_hernandez',
      name: 'Theo Hernández',
      country: 'Fransa',
      position: 'Sol Bek',
      clubIds: ['atletico_madrid', 'real_madrid', 'milan'],
      aliases: ['theo', 'theo hernandez'],
      activeYears: '2015-Aktif',
      hint: 'Atletico altyapısı, Real Madrid ve Milan\'ın fırtına sol beki.',
    ),
    // 134. MARCOS LLORENTE
    const PlayerModel(
      id: 'marcos_llorente',
      name: 'Marcos Llorente',
      country: 'İspanya',
      position: 'Orta Saha / Kanat',
      clubIds: ['real_madrid', 'atletico_madrid'],
      aliases: ['llorente', 'marcos llorente'],
      activeYears: '2015-Aktif',
      hint: 'Real Madrid altyapısından çıkıp ezeli rakip Atletico Madrid\'e transfer olan joker oyuncu.',
    ),
    // 135. THIAGO SILVA
    const PlayerModel(
      id: 'thiago_silva',
      name: 'Thiago Silva',
      country: 'Brezilya',
      position: 'Stoper',
      clubIds: ['porto', 'milan', 'psg', 'chelsea'],
      aliases: ['thiago silva'],
      activeYears: '2002-Aktif',
      hint: 'O Monstro! Porto, Milan, PSG ve Chelsea ile Şampiyonlar Ligi kazanan Brezilyalı efsane.',
    ),
    // 136. GIANLUIGI DONNARUMMA
    const PlayerModel(
      id: 'gianluigi_donnarumma',
      name: 'Gianluigi Donnarumma',
      country: 'İtalya',
      position: 'Kaleci',
      clubIds: ['milan', 'psg'],
      aliases: ['donnarumma'],
      activeYears: '2015-Aktif',
      hint: '16 yaşında Milan kalesine geçen, Euro 2020 MVP\'si olup PSG\'ye transfer olan İtalyan.',
    ),
    // 137. EDINSON CAVANI
    const PlayerModel(
      id: 'edinson_cavani',
      name: 'Edinson Cavani',
      country: 'Uruguay',
      position: 'Santrafor',
      clubIds: ['napoli', 'psg', 'man_united'],
      aliases: ['cavani', 'el matador'],
      activeYears: '2005-Aktif',
      hint: 'El Matador! Napoli, PSG tarihinin en çok gol atanlarından ve Man United santraforu.',
    ),
    // 138. GONZALO HIGUAIN
    const PlayerModel(
      id: 'gonzalo_higuain',
      name: 'Gonzalo Higuaín',
      country: 'Arjantin',
      position: 'Santrafor',
      clubIds: ['real_madrid', 'napoli', 'juventus', 'milan', 'chelsea'],
      aliases: ['higuain', 'el pipita'],
      activeYears: '2005-2022',
      hint: 'El Pipita; Real Madrid, Napoli (36 gollü Serie A rekoru), Juventus, Milan ve Chelsea\'de oynadı.',
    ),
    // 139. CARLOS TEVEZ
    const PlayerModel(
      id: 'carlos_tevez',
      name: 'Carlos Tévez',
      country: 'Arjantin',
      position: 'Forvet',
      clubIds: ['man_united', 'man_city', 'juventus'],
      aliases: ['tevez', 'apache'],
      activeYears: '2001-2021',
      hint: 'El Apache! Man United, ezeli rakip Man City ve Juventus\'un savaşçı golcüsü.',
    ),
    // 140. HERNAN CRESPO
    const PlayerModel(
      id: 'hernan_crespo',
      name: 'Hernán Crespo',
      country: 'Arjantin',
      position: 'Santrafor',
      clubIds: ['inter', 'chelsea', 'milan'],
      aliases: ['crespo'],
      activeYears: '1993-2012',
      hint: 'Inter, Chelsea ve Milan santraforu (İstanbul\'daki 2005 finalinde iki gol atmıştı).',
    ),
    // 141. CHRISTIAN VIERI
    const PlayerModel(
      id: 'christian_vieri',
      name: 'Christian Vieri',
      country: 'İtalya',
      position: 'Santrafor',
      clubIds: ['juventus', 'atletico_madrid', 'inter', 'milan', 'monaco'],
      aliases: ['vieri', 'bobo'],
      activeYears: '1991-2009',
      hint: 'Bobo Vieri; Juve, Atletico (gol kralı), Inter (rekor bonservis), Milan ve Monaco\'da oynadı.',
    ),
    // 142. FILIPPO INZAGHI
    const PlayerModel(
      id: 'filippo_inzaghi',
      name: 'Filippo Inzaghi',
      country: 'İtalya',
      position: 'Santrafor',
      clubIds: ['juventus', 'milan'],
      aliases: ['inzaghi', 'pippo'],
      activeYears: '1991-2012',
      hint: 'Ofsayt çizgisinde yaşayan gol koklayıcısı; Juventus ve Milan formalarıyla efsaneleşti.',
    ),
    // 143. ROBERTO BAGGIO
    const PlayerModel(
      id: 'roberto_baggio',
      name: 'Roberto Baggio',
      country: 'İtalya',
      position: '10 Numara',
      clubIds: ['juventus', 'milan', 'inter'],
      aliases: ['baggio', 'il divin codino'],
      activeYears: '1982-2004',
      hint: 'Kutsal Atkuyruğu! Ballon d\'Or sahibi; Juventus, Milan ve Inter üçlüsünde forma giydi.',
    ),
    // 144. LEONARDO BONUCCI
    const PlayerModel(
      id: 'leonardo_bonucci',
      name: 'Leonardo Bonucci',
      country: 'İtalya',
      position: 'Stoper',
      clubIds: ['inter', 'juventus', 'milan', 'fenerbahce'],
      aliases: ['bonucci'],
      activeYears: '2005-2024',
      hint: 'Inter altyapısı, Juve efsanesi, Milan ve kariyer sonu Fenerbahçe forması giyen Euro 2020 şampiyonu.',
    ),
    // 145. EDGAR DAVIDS
    const PlayerModel(
      id: 'edgar_davids',
      name: 'Edgar Davids',
      country: 'Hollanda',
      position: 'Orta Saha',
      clubIds: ['ajax', 'milan', 'juventus', 'barcelona', 'inter', 'tottenham'],
      aliases: ['davids', 'pitbull davids'],
      activeYears: '1991-2014',
      hint: 'Gözlükleriyle meşhur Pitbull; Ajax, Milan, Juve, Barça, Inter ve Spurs\'te oynadı.',
    ),
    // 146. FABIO CANNAVARO
    const PlayerModel(
      id: 'fabio_cannavaro',
      name: 'Fabio Cannavaro',
      country: 'İtalya',
      position: 'Stoper',
      clubIds: ['napoli', 'inter', 'juventus', 'real_madrid'],
      aliases: ['cannavaro'],
      activeYears: '1992-2011',
      hint: '2006 Dünya Kupası\'nı kaldırıp Ballon d\'Or kazanan stoper; Napoli, Inter, Juve ve Real Madrid.',
    ),
    // 147. JUAN CUADRADO
    const PlayerModel(
      id: 'juan_cuadrado',
      name: 'Juan Cuadrado',
      country: 'Kolombiya',
      position: 'Sağ Kanat / Bek',
      clubIds: ['chelsea', 'juventus', 'inter'],
      aliases: ['cuadrado'],
      activeYears: '2008-Aktif',
      hint: 'Chelsea, Juventus ve Inter formalarıyla İtalya\'da şampiyonluklar yaşayan Kolombiyalı.',
    ),
    // 148. ARTURO VIDAL
    const PlayerModel(
      id: 'arturo_vidal',
      name: 'Arturo Vidal',
      country: 'Şili',
      position: 'Orta Saha',
      clubIds: ['leverkusen', 'juventus', 'bayern', 'barcelona', 'inter'],
      aliases: ['vidal', 'el rey'],
      activeYears: '2005-Aktif',
      hint: 'Leverkusen, Juventus, Bayern, Barcelona ve Inter ile üst üste lig şampiyonlukları kazandı.',
    ),
    // 149. JOAO CANCELO
    const PlayerModel(
      id: 'joao_cancelo',
      name: 'João Cancelo',
      country: 'Portekiz',
      position: 'Bek',
      clubIds: ['benfica', 'inter', 'juventus', 'man_city', 'bayern', 'barcelona'],
      aliases: ['cancelo'],
      activeYears: '2012-Aktif',
      hint: 'Benfica, Inter, Juventus, Manchester City, Bayern ve Barcelona forması giyen ofansif bek.',
    ),
    // 150. BERNARDO SILVA
    const PlayerModel(
      id: 'bernardo_silva',
      name: 'Bernardo Silva',
      country: 'Portekiz',
      position: 'Oyun Kurucu',
      clubIds: ['benfica', 'monaco', 'man_city'],
      aliases: ['bernardo', 'bernardo silva'],
      activeYears: '2013-Aktif',
      hint: 'Benfica altyapısı, Monaco ile Ligue 1 zaferi ve Guardiola\'nın City\'sinin beyni.',
    ),
    // 151. RUBEN DIAS
    const PlayerModel(
      id: 'ruben_dias',
      name: 'Rúben Dias',
      country: 'Portekiz',
      position: 'Stoper',
      clubIds: ['benfica', 'man_city'],
      aliases: ['ruben dias', 'dias'],
      activeYears: '2015-Aktif',
      hint: 'Benfica altyapısından City\'ye gidip Premier Lig\'de yılın oyuncusu seçilen stoper.',
    ),
    // 152. DARWIN NUNEZ
    const PlayerModel(
      id: 'darwin_nunez',
      name: 'Darwin Núñez',
      country: 'Uruguay',
      position: 'Santrafor',
      clubIds: ['benfica', 'liverpool'],
      aliases: ['darwin', 'nunez'],
      activeYears: '2017-Aktif',
      hint: 'Benfica\'da gol kralı olup dev bonservisle Liverpool\'a transfer olan Uruguaylı 9 numara.',
    ),
    // 153. DIOGO JOTA
    const PlayerModel(
      id: 'diogo_jota',
      name: 'Diogo Jota',
      country: 'Portekiz',
      position: 'Forvet',
      clubIds: ['atletico_madrid', 'porto', 'liverpool'],
      aliases: ['jota', 'diogo jota'],
      activeYears: '2014-Aktif',
      hint: 'Atletico Madrid, Porto ve Liverpool formalarıyla kupa kaldıran Portekizli forvet.',
    ),
    // 154. LUIS DIAZ
    const PlayerModel(
      id: 'luis_diaz',
      name: 'Luis Díaz',
      country: 'Kolombiya',
      position: 'Sol Kanat',
      clubIds: ['porto', 'liverpool'],
      aliases: ['luis diaz', 'lucho'],
      activeYears: '2016-Aktif',
      hint: 'Porto\'da parlayıp Liverpool\'a transfer olan Kolombiyalı dribling ustası kanat.',
    ),
    // 155. EDER MILITAO
    const PlayerModel(
      id: 'eder_militao',
      name: 'Éder Militão',
      country: 'Brezilya',
      position: 'Stoper',
      clubIds: ['porto', 'real_madrid'],
      aliases: ['militao'],
      activeYears: '2017-Aktif',
      hint: 'Porto\'dan Real Madrid\'e transfer olup Devler Ligi ve La Liga kazanan Brezilyalı stoper.',
    ),
    // 156. DANILO
    const PlayerModel(
      id: 'danilo_luiz',
      name: 'Danilo',
      country: 'Brezilya',
      position: 'Sağ Bek / Stoper',
      clubIds: ['porto', 'real_madrid', 'man_city', 'juventus'],
      aliases: ['danilo'],
      activeYears: '2009-Aktif',
      hint: 'Porto, Real Madrid, Manchester City ve Juventus forması giyen Brezilya kaptanı.',
    ),
    // 157. ALEX SANDRO
    const PlayerModel(
      id: 'alex_sandro',
      name: 'Alex Sandro',
      country: 'Brezilya',
      position: 'Sol Bek',
      clubIds: ['porto', 'juventus'],
      aliases: ['alex sandro'],
      activeYears: '2008-Aktif',
      hint: 'Porto ve Juventus sol kanadını yıllarca savunan Brezilyalı.',
    ),
    // 158. BRUNO FERNANDES
    const PlayerModel(
      id: 'bruno_fernandes',
      name: 'Bruno Fernandes',
      country: 'Portekiz',
      position: '10 Numara',
      clubIds: ['sporting', 'man_united'],
      aliases: ['bruno', 'bruno fernandes'],
      activeYears: '2012-Aktif',
      hint: 'Sporting kaptanlığından Manchester United kaptanlığına geçen Portekizli oyun kurucu.',
    ),
    // 159. RAPHINHA
    const PlayerModel(
      id: 'raphinha_dias',
      name: 'Raphinha',
      country: 'Brezilya',
      position: 'Sağ Kanat',
      clubIds: ['sporting', 'barcelona'],
      aliases: ['raphinha'],
      activeYears: '2015-Aktif',
      hint: 'Sporting CP, Leeds United ve Barcelona\'nın Brezilyalı golcü sağ kanadı.',
    ),
    // 160. MANUEL UGARTE
    const PlayerModel(
      id: 'manuel_ugarte',
      name: 'Manuel Ugarte',
      country: 'Uruguay',
      position: 'Ön Libero',
      clubIds: ['sporting', 'psg', 'man_united'],
      aliases: ['ugarte'],
      activeYears: '2016-Aktif',
      hint: 'Sporting, PSG ve Manchester United orta sahasında oynayan Uruguaylı savaşçı.',
    ),
    // 161. JADON SANCHO
    const PlayerModel(
      id: 'jadon_sancho',
      name: 'Jadon Sancho',
      country: 'İngiltere',
      position: 'Kanat',
      clubIds: ['man_city', 'dortmund', 'man_united', 'chelsea'],
      aliases: ['sancho', 'jadon'],
      activeYears: '2017-Aktif',
      hint: 'City altyapısı, Dortmund\'da fırtına, Man United ve Chelsea forması giydi.',
    ),
    // 162. COLE PALMER
    const PlayerModel(
      id: 'cole_palmer',
      name: 'Cole Palmer',
      country: 'İngiltere',
      position: 'Ofansif Kanat / 10',
      clubIds: ['man_city', 'chelsea'],
      aliases: ['palmer', 'cold palmer'],
      activeYears: '2020-Aktif',
      hint: 'Cold Palmer! Manchester City altyapısından Chelsea\'ye geçip Premier Lig yıldızına dönüştü.',
    ),
    // 163. MANUEL AKANJI
    const PlayerModel(
      id: 'manuel_akanji',
      name: 'Manuel Akanji',
      country: 'İsviçre',
      position: 'Stoper / Bek',
      clubIds: ['dortmund', 'man_city'],
      aliases: ['akanji'],
      activeYears: '2014-Aktif',
      hint: 'Dortmund\'dan City\'ye transfer olup Guardiola ile Şampiyonlar Ligi kazanan İsviçreli savunmacı.',
    ),
    // 164. TOMAS ROSICKY
    const PlayerModel(
      id: 'tomas_rosicky',
      name: 'Tomáš Rosický',
      country: 'Çekya',
      position: 'Orta Saha',
      clubIds: ['dortmund', 'arsenal'],
      aliases: ['rosicky', 'kucuk mozart'],
      activeYears: '1998-2017',
      hint: 'Küçük Mozart! Dortmund ve Arsenal formalarıyla zarafetini konuşturan Çek maestro.',
    ),
    // 165. NURI SAHIN
    const PlayerModel(
      id: 'nuri_sahin',
      name: 'Nuri Şahin',
      country: 'Türkiye',
      position: 'Orta Saha',
      clubIds: ['dortmund', 'real_madrid', 'liverpool'],
      aliases: ['nuri', 'nuri sahin'],
      activeYears: '2005-2021',
      hint: 'Bundesliga yılın oyuncusu; Dortmund, Real Madrid ve Liverpool formalarını terletti.',
    ),
    // 166. TALISCA
    const PlayerModel(
      id: 'anderson_talisca',
      name: 'Anderson Talisca',
      country: 'Brezilya',
      position: '10 Numara / Forvet',
      clubIds: ['benfica', 'besiktas'],
      aliases: ['talisca'],
      activeYears: '2014-Aktif',
      hint: 'Benfica\'dan Beşiktaş\'a kiralanıp şampiyonluk yaşayan sol ayaklı frikik ustası Sambacı.',
    ),
    // 167. VINCENT ABOUBAKAR
    const PlayerModel(
      id: 'vincent_aboubakar',
      name: 'Vincent Aboubakar',
      country: 'Kamerun',
      position: 'Santrafor',
      clubIds: ['porto', 'besiktas'],
      aliases: ['aboubakar'],
      activeYears: '2010-Aktif',
      hint: 'Porto ve Beşiktaş ile şampiyonluklar yaşayan Kamerunlu güçlü santrafor.',
    ),
    // 168. DEMBA BA
    const PlayerModel(
      id: 'demba_ba',
      name: 'Demba Ba',
      country: 'Senegal',
      position: 'Santrafor',
      clubIds: ['chelsea', 'besiktas'],
      aliases: ['demba ba'],
      activeYears: '2005-2021',
      hint: 'Chelsea ve Beşiktaş taraftarının şarkılar bestelediği Senegalli golcü.',
    ),
    // 169. JOSE SOSA
    const PlayerModel(
      id: 'jose_sosa',
      name: 'José Sosa',
      country: 'Arjantin',
      position: '10 Numara',
      clubIds: ['bayern', 'napoli', 'atletico_madrid', 'besiktas', 'milan', 'trabzonspor', 'fenerbahce'],
      aliases: ['sosa'],
      activeYears: '2002-Aktif',
      hint: 'Bayern, Napoli, Atletico, BJK, Milan, Trabzonspor ve Fenerbahçe formaları giydi.',
    ),
    // 170. KEVIN-PRINCE BOATENG
    const PlayerModel(
      id: 'kevin_prince_boateng',
      name: 'Kevin-Prince Boateng',
      country: 'Gana',
      position: 'Orta Saha',
      clubIds: ['tottenham', 'dortmund', 'milan', 'barcelona', 'besiktas'],
      aliases: ['boateng', 'prince'],
      activeYears: '2005-2023',
      hint: 'Tottenham, Dortmund, Milan, Barça ve Beşiktaş forması giyen gezgin Ganalı.',
    ),
    // 171. MAREK HAMSIK
    const PlayerModel(
      id: 'marek_hamsik',
      name: 'Marek Hamšík',
      country: 'Slovakya',
      position: 'Merkez Orta Saha',
      clubIds: ['napoli', 'trabzonspor'],
      aliases: ['hamsik', 'grande'],
      activeYears: '2004-2023',
      hint: 'Napoli efsanesi ve kaptanı; Trabzonspor ile tarihi Süper Lig şampiyonluğu yaşadı.',
    ),
    // 172. ANTHONY NWAKAEME
    const PlayerModel(
      id: 'anthony_nwakaeme',
      name: 'Anthony Nwakaeme',
      country: 'Nijerya',
      position: 'Sol Kanat',
      clubIds: ['trabzonspor'],
      aliases: ['nwakaeme', 'tony'],
      activeYears: '2010-Aktif',
      hint: 'Top saklama ustası, Trabzonspor\'un şampiyonluğunun sihirbazı.',
    ),
    // 173. ARDA GÜLER
    const PlayerModel(
      id: 'arda_guler',
      name: 'Arda Güler',
      country: 'Türkiye',
      position: '10 Numara / Sağ Kanat',
      clubIds: ['fenerbahce', 'real_madrid'],
      aliases: ['arda guler', 'guler', 'arda'],
      activeYears: '2021-Aktif',
      hint: 'Fenerbahçe altyapısından çıkıp Real Madrid\'e transfer olan genç Türk yıldız.',
    ),
    // 174. KENAN YILDIZ
    const PlayerModel(
      id: 'kenan_yildiz',
      name: 'Kenan Yıldız',
      country: 'Türkiye',
      position: 'Forvet / Sol Kanat',
      clubIds: ['bayern', 'juventus'],
      aliases: ['kenan', 'kenan yildiz'],
      activeYears: '2022-Aktif',
      hint: 'Bayern Münih altyapısı sonrası Juventus\'un efsanevi 10 numarasını giyen Türk yıldız.',
    ),
    // 175. KEREM AKTÜRKOĞLU
    const PlayerModel(
      id: 'kerem_akturkoglu',
      name: 'Kerem Aktürkoğlu',
      country: 'Türkiye',
      position: 'Sol Kanat',
      clubIds: ['galatasaray', 'benfica'],
      aliases: ['kerem', 'harry potter'],
      activeYears: '2016-Aktif',
      hint: 'Harry Potter sevinciyle tanınan; Galatasaray\'dan Benfica\'ya transfer olan milli yıldız.',
    ),
    // 176. ORKUN KÖKÇÜ
    const PlayerModel(
      id: 'orkun_kokcu',
      name: 'Orkun Kökçü',
      country: 'Türkiye',
      position: 'Orta Saha',
      clubIds: ['benfica'],
      aliases: ['orkun', 'kokcu'],
      activeYears: '2018-Aktif',
      hint: 'Feyenoord kaptanlığından sonra Benfica\'ya rekor bedelle geçen A Milli orta saha.',
    ),
    // 177. CENGİZ ÜNDER
    const PlayerModel(
      id: 'cengiz_under',
      name: 'Cengiz Ünder',
      country: 'Türkiye',
      position: 'Sağ Kanat',
      clubIds: ['roma', 'fenerbahce'],
      aliases: ['cengiz', 'cengiz under'],
      activeYears: '2014-Aktif',
      hint: 'Sol ayağının içiyle uzak köşeye vuran milli sağ kanat; Roma ve Fenerbahçe\'de oynadı.',
    ),
    // 178. ÇAĞLAR SÖYÜNCÜ
    const PlayerModel(
      id: 'caglar_soyuncu',
      name: 'Çağlar Söyüncü',
      country: 'Türkiye',
      position: 'Stoper',
      clubIds: ['atletico_madrid', 'fenerbahce'],
      aliases: ['caglar', 'soyuncu'],
      activeYears: '2014-Aktif',
      hint: 'Leicester ile FA Cup kazanan, Atletico Madrid ve Fenerbahçe formaları giyen milli stoper.',
    ),
    // 179. MERİH DEMİRAL
    const PlayerModel(
      id: 'merih_demiral',
      name: 'Merih Demiral',
      country: 'Türkiye',
      position: 'Stoper',
      clubIds: ['sporting', 'fenerbahce', 'juventus'],
      aliases: ['merih', 'demiral'],
      activeYears: '2016-Aktif',
      hint: 'Fenerbahçe altyapısı, Sporting B ve Juventus ile Serie A şampiyonu olan milli savunmacı.',
    ),
    // 180. DANIEL STURRIDGE
    const PlayerModel(
      id: 'daniel_sturridge',
      name: 'Daniel Sturridge',
      country: 'İngiltere',
      position: 'Santrafor',
      clubIds: ['man_city', 'chelsea', 'liverpool', 'trabzonspor'],
      aliases: ['sturridge'],
      activeYears: '2006-2022',
      hint: 'Kollarıyla dans eden İngiliz forvet; City, Chelsea, Liverpool ve Trabzonspor forması giydi.',
    ),
  ];

  /// Get list of all clubs
  List<ClubModel> getAllClubs() => _clubs.values.toList();

  /// Get club by ID
  ClubModel? getClub(String id) => _clubs[id];

  /// Get all players
  List<PlayerModel> getAllPlayers() => _players;

  /// Find all players who played for BOTH clubs
  List<PlayerModel> getMutualPlayers(String clubAId, String clubBId) {
    return _players.where((p) => p.playedForBoth(clubAId, clubBId)).toList();
  }

  /// Get all unique club pairs that actually share at least 1 player
  List<MapEntry<ClubModel, ClubModel>> getValidClubPairs() {
    final List<MapEntry<ClubModel, ClubModel>> validPairs = [];
    final clubList = _clubs.values.toList();

    for (int i = 0; i < clubList.length; i++) {
      for (int j = i + 1; j < clubList.length; j++) {
        final c1 = clubList[i];
        final c2 = clubList[j];
        if (getMutualPlayers(c1.id, c2.id).isNotEmpty) {
          validPairs.add(MapEntry(c1, c2));
        }
      }
    }
    return validPairs;
  }

  /// Get a random club pair that has at least 1 common player
  MapEntry<ClubModel, ClubModel> getRandomClubPair() {
    final pairs = getValidClubPairs();
    if (pairs.isEmpty) {
      return MapEntry(_clubs['real_madrid']!, _clubs['arsenal']!);
    }
    return pairs[_random.nextInt(pairs.length)];
  }

  /// Search players by query (autocomplete suggestions)
  List<PlayerModel> searchPlayers(String query, {int limit = 6}) {
    if (query.trim().isEmpty) return [];
    final matches = _players.where((p) => TextNormalizer.matches(query, p.name, p.aliases)).toList();
    if (matches.length > limit) {
      return matches.sublist(0, limit);
    }
    return matches;
  }

  /// 5 Clubs 1 Player Challenge sets
  List<FiveClubsChallenge> getFiveClubsChallenges() {
    return [
      FiveClubsChallenge(
        clubs: [
          _clubs['ajax']!,
          _clubs['juventus']!,
          _clubs['inter']!,
          _clubs['barcelona']!,
          _clubs['psg']!,
        ],
        bestAnswer: _players.firstWhere((p) => p.id == 'zlatan_ibrahimovic'),
        maxMatchCount: 5,
      ),
      FiveClubsChallenge(
        clubs: [
          _clubs['arsenal']!,
          _clubs['chelsea']!,
          _clubs['real_madrid']!,
          _clubs['psg']!,
          _clubs['liverpool']!,
        ],
        bestAnswer: _players.firstWhere((p) => p.id == 'nicolas_anelka'),
        maxMatchCount: 5,
      ),
      FiveClubsChallenge(
        clubs: [
          _clubs['sporting']!,
          _clubs['man_united']!,
          _clubs['real_madrid']!,
          _clubs['juventus']!,
          _clubs['bayern']!,
        ],
        bestAnswer: _players.firstWhere((p) => p.id == 'cristiano_ronaldo'),
        maxMatchCount: 4,
      ),
      FiveClubsChallenge(
        clubs: [
          _clubs['porto']!,
          _clubs['atletico_madrid']!,
          _clubs['monaco']!,
          _clubs['chelsea']!,
          _clubs['galatasaray']!,
        ],
        bestAnswer: _players.firstWhere((p) => p.id == 'radamel_falcao'),
        maxMatchCount: 5,
      ),
      FiveClubsChallenge(
        clubs: [
          _clubs['galatasaray']!,
          _clubs['fenerbahce']!,
          _clubs['besiktas']!,
          _clubs['trabzonspor']!,
          _clubs['real_madrid']!,
        ],
        bestAnswer: _players.firstWhere((p) => p.id == 'burak_yilmaz'),
        maxMatchCount: 4,
      ),
      FiveClubsChallenge(
        clubs: [
          _clubs['milan']!,
          _clubs['monaco']!,
          _clubs['dortmund']!,
          _clubs['arsenal']!,
          _clubs['chelsea']!,
        ],
        bestAnswer: _players.firstWhere((p) => p.id == 'aubameyang'),
        maxMatchCount: 5,
      ),
      FiveClubsChallenge(
        clubs: [
          _clubs['sevilla']!,
          _clubs['barcelona']!,
          _clubs['juventus']!,
          _clubs['psg']!,
          _clubs['liverpool']!,
        ],
        bestAnswer: _players.firstWhere((p) => p.id == 'dani_alves'),
        maxMatchCount: 4,
      ),
    ];
  }

  FiveClubsChallenge getRandom5ClubsChallenge() {
    final challenges = getFiveClubsChallenges();
    return challenges[_random.nextInt(challenges.length)];
  }

  /// Evaluate user's player choice in 5 clubs
  int evaluatePlayerFor5Clubs(PlayerModel player, List<ClubModel> targetClubs) {
    return targetClubs.where((c) => player.playedFor(c.id)).length;
  }

  /// 3x3 Grid Challenges
  List<GridChallenge> getGridChallenges() {
    return [
      // Challenge 1
      GridChallenge(
        rowCriteria: [
          GridCriterion(
            id: 'real_madrid',
            label: 'Real Madrid',
            sublabel: 'La Liga',
            isClub: true,
            club: _clubs['real_madrid'],
          ),
          GridCriterion(
            id: 'barcelona',
            label: 'Barcelona',
            sublabel: 'La Liga',
            isClub: true,
            club: _clubs['barcelona'],
          ),
          GridCriterion(
            id: 'galatasaray',
            label: 'Galatasaray',
            sublabel: 'Süper Lig',
            isClub: true,
            club: _clubs['galatasaray'],
          ),
        ],
        colCriteria: [
          GridCriterion(
            id: 'arsenal',
            label: 'Arsenal',
            sublabel: 'Premier League',
            isClub: true,
            club: _clubs['arsenal'],
          ),
          GridCriterion(
            id: 'inter',
            label: 'Inter Milan',
            sublabel: 'Serie A',
            isClub: true,
            club: _clubs['inter'],
          ),
          GridCriterion(
            id: 'chelsea',
            label: 'Chelsea',
            sublabel: 'Premier League',
            isClub: true,
            club: _clubs['chelsea'],
          ),
        ],
      ),
      // Challenge 2
      GridChallenge(
        rowCriteria: [
          GridCriterion(
            id: 'man_united',
            label: 'Man United',
            sublabel: 'Premier League',
            isClub: true,
            club: _clubs['man_united'],
          ),
          GridCriterion(
            id: 'bayern',
            label: 'Bayern Münih',
            sublabel: 'Bundesliga',
            isClub: true,
            club: _clubs['bayern'],
          ),
          GridCriterion(
            id: 'fenerbahce',
            label: 'Fenerbahçe',
            sublabel: 'Süper Lig',
            isClub: true,
            club: _clubs['fenerbahce'],
          ),
        ],
        colCriteria: [
          GridCriterion(
            id: 'real_madrid',
            label: 'Real Madrid',
            sublabel: 'La Liga',
            isClub: true,
            club: _clubs['real_madrid'],
          ),
          GridCriterion(
            id: 'juventus',
            label: 'Juventus',
            sublabel: 'Serie A',
            isClub: true,
            club: _clubs['juventus'],
          ),
          GridCriterion(
            id: 'arsenal',
            label: 'Arsenal',
            sublabel: 'Premier League',
            isClub: true,
            club: _clubs['arsenal'],
          ),
        ],
      ),
      // Challenge 3
      GridChallenge(
        rowCriteria: [
          GridCriterion(
            id: 'besiktas',
            label: 'Beşiktaş',
            sublabel: 'Süper Lig',
            isClub: true,
            club: _clubs['besiktas'],
          ),
          GridCriterion(
            id: 'chelsea',
            label: 'Chelsea',
            sublabel: 'Premier League',
            isClub: true,
            club: _clubs['chelsea'],
          ),
          GridCriterion(
            id: 'milan',
            label: 'AC Milan',
            sublabel: 'Serie A',
            isClub: true,
            club: _clubs['milan'],
          ),
        ],
        colCriteria: [
          GridCriterion(
            id: 'real_madrid',
            label: 'Real Madrid',
            sublabel: 'La Liga',
            isClub: true,
            club: _clubs['real_madrid'],
          ),
          GridCriterion(
            id: 'barcelona',
            label: 'Barcelona',
            sublabel: 'La Liga',
            isClub: true,
            club: _clubs['barcelona'],
          ),
          GridCriterion(
            id: 'arsenal',
            label: 'Arsenal',
            sublabel: 'Premier League',
            isClub: true,
            club: _clubs['arsenal'],
          ),
        ],
      ),
    ];
  }

  GridChallenge getRandom3x3GridChallenge() {
    final challenges = getGridChallenges();
    return challenges[_random.nextInt(challenges.length)];
  }

  bool validateGridCell(GridCriterion row, GridCriterion col, PlayerModel player) {
    return player.matchesGridCriterion(row.id) && player.matchesGridCriterion(col.id);
  }

  List<PlayerModel> getValidPlayersForCell(GridCriterion row, GridCriterion col) {
    return _players.where((p) => validateGridCell(row, col, p)).toList();
  }
}
