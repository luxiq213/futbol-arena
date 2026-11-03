import 'dart:math';
import 'package:flutter/material.dart';
import '../models/club_model.dart';
import '../models/player_model.dart';
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
      badgeText: '👑',
    ),
    'barcelona': const ClubModel(
      id: 'barcelona',
      name: 'Barcelona',
      shortName: 'FCB',
      country: 'İspanya',
      league: 'La Liga',
      primaryColor: Color(0xFF004D98),
      secondaryColor: Color(0xFFA50044),
      badgeText: '🔵🔴',
    ),
    'arsenal': const ClubModel(
      id: 'arsenal',
      name: 'Arsenal',
      shortName: 'ARS',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFFEF0107),
      secondaryColor: Color(0xFFFFFFFF),
      badgeText: '🔴⚪',
    ),
    'man_united': const ClubModel(
      id: 'man_united',
      name: 'Manchester United',
      shortName: 'MUN',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFFDA291C),
      secondaryColor: Color(0xFFFBE122),
      badgeText: '👹',
    ),
    'man_city': const ClubModel(
      id: 'man_city',
      name: 'Manchester City',
      shortName: 'MCI',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFF6CABDD),
      secondaryColor: Color(0xFF1C2C5B),
      badgeText: '🩵',
    ),
    'chelsea': const ClubModel(
      id: 'chelsea',
      name: 'Chelsea',
      shortName: 'CHE',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFF034694),
      secondaryColor: Color(0xFFEE242C),
      badgeText: '🦁',
    ),
    'liverpool': const ClubModel(
      id: 'liverpool',
      name: 'Liverpool',
      shortName: 'LIV',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFFC8102E),
      secondaryColor: Color(0xFF00B2A9),
      badgeText: '🔴',
    ),
    'bayern': const ClubModel(
      id: 'bayern',
      name: 'Bayern Münih',
      shortName: 'BAY',
      country: 'Almanya',
      league: 'Bundesliga',
      primaryColor: Color(0xFFDC052D),
      secondaryColor: Color(0xFF0066B2),
      badgeText: '⭐',
    ),
    'dortmund': const ClubModel(
      id: 'dortmund',
      name: 'Borussia Dortmund',
      shortName: 'BVB',
      country: 'Almanya',
      league: 'Bundesliga',
      primaryColor: Color(0xFFFDE100),
      secondaryColor: Color(0xFF000000),
      badgeText: '🐝',
    ),
    'psg': const ClubModel(
      id: 'psg',
      name: 'Paris Saint-Germain',
      shortName: 'PSG',
      country: 'Fransa',
      league: 'Ligue 1',
      primaryColor: Color(0xFF004170),
      secondaryColor: Color(0xFFDA291C),
      badgeText: '🗼',
    ),
    'juventus': const ClubModel(
      id: 'juventus',
      name: 'Juventus',
      shortName: 'JUV',
      country: 'İtalya',
      league: 'Serie A',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFF000000),
      badgeText: '🦓',
    ),
    'milan': const ClubModel(
      id: 'milan',
      name: 'AC Milan',
      shortName: 'MIL',
      country: 'İtalya',
      league: 'Serie A',
      primaryColor: Color(0xFFFB090B),
      secondaryColor: Color(0xFF000000),
      badgeText: '🔴⚫',
    ),
    'inter': const ClubModel(
      id: 'inter',
      name: 'Inter Milan',
      shortName: 'INT',
      country: 'İtalya',
      league: 'Serie A',
      primaryColor: Color(0xFF010E80),
      secondaryColor: Color(0xFF000000),
      badgeText: '🔵⚫',
    ),
    'atletico_madrid': const ClubModel(
      id: 'atletico_madrid',
      name: 'Atletico Madrid',
      shortName: 'ATM',
      country: 'İspanya',
      league: 'La Liga',
      primaryColor: Color(0xFFCB3524),
      secondaryColor: Color(0xFF272E61),
      badgeText: '🔴⚪',
    ),
    'galatasaray': const ClubModel(
      id: 'galatasaray',
      name: 'Galatasaray',
      shortName: 'GS',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFFA90432),
      secondaryColor: Color(0xFFFDB912),
      badgeText: '🦁💛❤️',
    ),
    'fenerbahce': const ClubModel(
      id: 'fenerbahce',
      name: 'Fenerbahçe',
      shortName: 'FB',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFFFFED00),
      secondaryColor: Color(0xFF002D72),
      badgeText: '🟡🔵',
    ),
    'besiktas': const ClubModel(
      id: 'besiktas',
      name: 'Beşiktaş',
      shortName: 'BJK',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFF000000),
      secondaryColor: Color(0xFFFFFFFF),
      badgeText: '🦅⚪⚫',
    ),
    'trabzonspor': const ClubModel(
      id: 'trabzonspor',
      name: 'Trabzonspor',
      shortName: 'TS',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFF800000),
      secondaryColor: Color(0xFF41748D),
      badgeText: '🍷💙',
    ),
  };

  // --- PLAYERS DATABASE ---
  final List<PlayerModel> _players = [
    // MESUT ÖZIL
    const PlayerModel(
      id: 'mesut_ozil',
      name: 'Mesut Özil',
      country: 'Almanya',
      position: 'Orta Saha (10 Numara)',
      clubIds: ['real_madrid', 'arsenal', 'fenerbahce'],
      aliases: ['ozil', 'mesut'],
      activeYears: '2006-2023',
      hint: 'Alman pas ustası, Dünya Kupası şampiyonu, asist kralı.',
    ),
    // CRISTIANO RONALDO
    const PlayerModel(
      id: 'cristiano_ronaldo',
      name: 'Cristiano Ronaldo',
      country: 'Portekiz',
      position: 'Forvet',
      clubIds: ['man_united', 'real_madrid', 'juventus'],
      aliases: ['cr7', 'ronaldo', 'cristiano'],
      activeYears: '2002-Aktif',
      hint: '5 Ballon d\'Or sahibi, tarihin en golcü oyuncularından biri.',
    ),
    // LIONEL MESSI
    const PlayerModel(
      id: 'lionel_messi',
      name: 'Lionel Messi',
      country: 'Arjantin',
      position: 'Forvet / Kanat',
      clubIds: ['barcelona', 'psg'],
      aliases: ['messi', 'leo messi', 'goat'],
      activeYears: '2004-Aktif',
      hint: '8 Ballon d\'Or sahibi, Dünya Kupası şampiyonu.',
    ),
    // NEYMAR JR
    const PlayerModel(
      id: 'neymar_jr',
      name: 'Neymar Jr',
      country: 'Brezilya',
      position: 'Kanat / Forvet',
      clubIds: ['barcelona', 'psg'],
      aliases: ['neymar', 'neymar da silva'],
      activeYears: '2009-Aktif',
      hint: 'Brezilyalı sambacı, rekor transfer ücretiyle PSG\'ye geçmişti.',
    ),
    // ZLATAN IBRAHIMOVIC
    const PlayerModel(
      id: 'zlatan_ibrahimovic',
      name: 'Zlatan Ibrahimović',
      country: 'İsveç',
      position: 'Santrafor',
      clubIds: ['juventus', 'inter', 'barcelona', 'milan', 'psg', 'man_united'],
      aliases: ['zlatan', 'ibrahimovic', 'ibra'],
      activeYears: '1999-2023',
      hint: 'Akrobatik gollere imza atan İsveçli dev golcü.',
    ),
    // LUIS FIGO
    const PlayerModel(
      id: 'luis_figo',
      name: 'Luís Figo',
      country: 'Portekiz',
      position: 'Sağ Kanat',
      clubIds: ['barcelona', 'real_madrid', 'inter'],
      aliases: ['figo', 'luis figo'],
      activeYears: '1989-2009',
      hint: 'Barcelona\'dan doğrudan Real Madrid\'e transfer olarak tarihe geçti.',
    ),
    // RONALDO NAZARIO
    const PlayerModel(
      id: 'ronaldo_nazario',
      name: 'Ronaldo Nazário (Fenomeno)',
      country: 'Brezilya',
      position: 'Santrafor',
      clubIds: ['barcelona', 'inter', 'real_madrid', 'milan'],
      aliases: ['ronaldo', 'el fenomeno', 'r9'],
      activeYears: '1993-2011',
      hint: 'Brezilyalı efsane 9 numara, 2002 Dünya Kupası yıldızı.',
    ),
    // WESLEY SNEIJDER
    const PlayerModel(
      id: 'wesley_sneijder',
      name: 'Wesley Sneijder',
      country: 'Hollanda',
      position: '10 Numara',
      clubIds: ['real_madrid', 'inter', 'galatasaray'],
      aliases: ['sneijder', 'wesley'],
      activeYears: '2002-2019',
      hint: 'Inter ile 2010 Şampiyonlar Ligi şampiyonu, Galatasaray\'ın 10 numarası.',
    ),
    // DIDIER DROGBA
    const PlayerModel(
      id: 'didier_drogba',
      name: 'Didier Drogba',
      country: 'Fildişi Sahili',
      position: 'Santrafor',
      clubIds: ['chelsea', 'galatasaray'],
      aliases: ['drogba'],
      activeYears: '1998-2018',
      hint: 'Münih\'teki Şampiyonlar Ligi finalinin kahramanı ve sarı-kırmızılı efsane.',
    ),
    // ROBERTO CARLOS
    const PlayerModel(
      id: 'roberto_carlos',
      name: 'Roberto Carlos',
      country: 'Brezilya',
      position: 'Sol Bek',
      clubIds: ['inter', 'real_madrid', 'fenerbahce'],
      aliases: ['carlos', 'roberto carlos'],
      activeYears: '1991-2012',
      hint: 'Füzeleriyle meşhur Brezilyalı efsane sol bek.',
    ),
    // ARDA TURAN
    const PlayerModel(
      id: 'arda_turan',
      name: 'Arda Turan',
      country: 'Türkiye',
      position: 'Kanat / Oyun Kurucu',
      clubIds: ['galatasaray', 'atletico_madrid', 'barcelona'],
      aliases: ['arda', 'arda turan'],
      activeYears: '2005-2022',
      hint: 'Atletico ile La Liga kazanan ve Barça\'ya transfer olan Türk kaptan.',
    ),
    // NICOLAS ANELKA
    const PlayerModel(
      id: 'nicolas_anelka',
      name: 'Nicolas Anelka',
      country: 'Fransa',
      position: 'Santrafor',
      clubIds: ['psg', 'arsenal', 'real_madrid', 'liverpool', 'man_city', 'fenerbahce', 'chelsea', 'juventus'],
      aliases: ['anelka'],
      activeYears: '1996-2015',
      hint: 'Avrupa\'nın gezgin santraforu, neredeyse tüm devlerde oynadı!',
    ),
    // CESC FABREGAS
    const PlayerModel(
      id: 'cesc_fabregas',
      name: 'Cesc Fàbregas',
      country: 'İspanya',
      position: 'Orta Saha',
      clubIds: ['arsenal', 'barcelona', 'chelsea'],
      aliases: ['fabregas', 'cesc'],
      activeYears: '2003-2023',
      hint: 'Arsenal kaptanıydı, memleketi Barcelona\'ya döndü, sonra Chelsea\'ye gitti.',
    ),
    // EDEN HAZARD
    const PlayerModel(
      id: 'eden_hazard',
      name: 'Eden Hazard',
      country: 'Belçika',
      position: 'Sol Kanat',
      clubIds: ['chelsea', 'real_madrid'],
      aliases: ['hazard', 'eden'],
      activeYears: '2007-2023',
      hint: 'Chelsea\'de fırtınalar estirip rekor bedelle Real Madrid\'e giden Belçikalı sihirbaz.',
    ),
    // THIBAUT COURTOIS
    const PlayerModel(
      id: 'thibaut_courtois',
      name: 'Thibaut Courtois',
      country: 'Belçika',
      position: 'Kaleci',
      clubIds: ['chelsea', 'atletico_madrid', 'real_madrid'],
      aliases: ['courtois', 'tibocurtua'],
      activeYears: '2009-Aktif',
      hint: 'Madrid\'in iki devinde de kaleyi korumuş Belçikalı eldiven.',
    ),
    // ANGEL DI MARIA
    const PlayerModel(
      id: 'angel_di_maria',
      name: 'Ángel Di María',
      country: 'Arjantin',
      position: 'Kanat / Ofansif',
      clubIds: ['real_madrid', 'man_united', 'psg', 'juventus'],
      aliases: ['di maria', 'dimaria', 'fideo'],
      activeYears: '2005-Aktif',
      hint: 'Finallerin adamı, sol ayağıyla harikalar yaratan Arjantinli.',
    ),
    // TONI KROOS
    const PlayerModel(
      id: 'toni_kroos',
      name: 'Toni Kroos',
      country: 'Almanya',
      position: 'Merkez Orta Saha',
      clubIds: ['bayern', 'real_madrid'],
      aliases: ['kroos', 'toni'],
      activeYears: '2007-2024',
      hint: 'Alman pas profesörü, kariyerini 6 Şampiyonlar Ligi kupasıyla noktaladı.',
    ),
    // XABI ALONSO
    const PlayerModel(
      id: 'xabi_alonso',
      name: 'Xabi Alonso',
      country: 'İspanya',
      position: 'Defansif Orta Saha',
      clubIds: ['liverpool', 'real_madrid', 'bayern'],
      aliases: ['alonso', 'xabi'],
      activeYears: '1999-2017',
      hint: 'Uzun pasları ve oyun aklıyla Liverpool, Real Madrid ve Bayern\'de oynadı.',
    ),
    // ARJEN ROBBEN
    const PlayerModel(
      id: 'arjen_robben',
      name: 'Arjen Robben',
      country: 'Hollanda',
      position: 'Sağ Kanat',
      clubIds: ['chelsea', 'real_madrid', 'bayern'],
      aliases: ['robben', 'arjen'],
      activeYears: '2000-2021',
      hint: 'Sağdan içeri çekip sol ayağıyla köşeye vuran Hollandalı efsane.',
    ),
    // ANDREA PIRLO
    const PlayerModel(
      id: 'andrea_pirlo',
      name: 'Andrea Pirlo',
      country: 'İtalya',
      position: 'Regista / Orta Saha',
      clubIds: ['inter', 'milan', 'juventus'],
      aliases: ['pirlo', 'maestro'],
      activeYears: '1995-2017',
      hint: 'İtalya\'nın üç devinde de forma giymiş frikik ustası maestro.',
    ),
    // GHEORGHE HAGI
    const PlayerModel(
      id: 'gheorghe_hagi',
      name: 'Gheorghe Hagi',
      country: 'Romanya',
      position: '10 Numara',
      clubIds: ['real_madrid', 'barcelona', 'galatasaray'],
      aliases: ['hagi', 'karpatlarin maradonasi'],
      activeYears: '1982-2001',
      hint: 'Karpatların Maradonası, El Clasico taraflarını ve Galatasaray\'ı büyüledi.',
    ),
    // GHEORGHE POPESCU
    const PlayerModel(
      id: 'gheorghe_popescu',
      name: 'Gheorghe Popescu',
      country: 'Romanya',
      position: 'Stoper / Defans',
      clubIds: ['barcelona', 'galatasaray'],
      aliases: ['popescu'],
      activeYears: '1985-2003',
      hint: 'Galatasaray\'a 2000 UEFA Kupası\'nı getiren son penaltıyı atan Rumen stoper.',
    ),
    // ARDA GULER
    const PlayerModel(
      id: 'arda_guler',
      name: 'Arda Güler',
      country: 'Türkiye',
      position: '10 Numara / Kanat',
      clubIds: ['fenerbahce', 'real_madrid'],
      aliases: ['arda guler', 'guler', 'arda'],
      activeYears: '2021-Aktif',
      hint: 'Fenerbahçe altyapısından Real Madrid\'e transfer olan genç Türk yıldız.',
    ),
    // GUTI HERNANDEZ
    const PlayerModel(
      id: 'guti_hernandez',
      name: 'Guti Hernández',
      country: 'İspanya',
      position: 'Orta Saha',
      clubIds: ['real_madrid', 'besiktas'],
      aliases: ['guti'],
      activeYears: '1995-2011',
      hint: 'Topuk paslarıyla ünlü Real Madrid kaptanı, Beşiktaş\'ta da oynadı.',
    ),
    // PEPE
    const PlayerModel(
      id: 'pepe',
      name: 'Pepe (Kepler Laveran)',
      country: 'Portekiz',
      position: 'Stoper',
      clubIds: ['real_madrid', 'besiktas'],
      aliases: ['pepe'],
      activeYears: '2001-2024',
      hint: 'Real Madrid\'in sert stoperi, Türkiye\'de Beşiktaş formasını giydi.',
    ),
    // MARIO GOMEZ
    const PlayerModel(
      id: 'mario_gomez',
      name: 'Mario Gomez',
      country: 'Almanya',
      position: 'Santrafor',
      clubIds: ['bayern', 'besiktas'],
      aliases: ['gomez', 'mario gomez'],
      activeYears: '2003-2020',
      hint: 'Bayern ile Şampiyonlar Ligi, Beşiktaş ile Süper Lig şampiyonu olan gol makinesi.',
    ),
    // HAKAN CALHANOGLU
    const PlayerModel(
      id: 'hakan_calhanoglu',
      name: 'Hakan Çalhanoğlu',
      country: 'Türkiye',
      position: 'Orta Saha',
      clubIds: ['milan', 'inter'],
      aliases: ['calhanoglu', 'hakan', 'hakan calhanoglu'],
      activeYears: '2011-Aktif',
      hint: 'Milano derbisinin iki yakasında da forma giyen A Milli Takım kaptanımız.',
    ),
    // FELIPE MELO
    const PlayerModel(
      id: 'felipe_melo',
      name: 'Felipe Melo',
      country: 'Brezilya',
      position: 'Ön Libero',
      clubIds: ['juventus', 'galatasaray', 'inter'],
      aliases: ['melo', 'pitbull'],
      activeYears: '2001-Aktif',
      hint: 'Pitbull lakaplı agresif Brezilyalı orta saha.',
    ),
    // ALEX TELLES
    const PlayerModel(
      id: 'alex_telles',
      name: 'Alex Telles',
      country: 'Brezilya',
      position: 'Sol Bek',
      clubIds: ['galatasaray', 'inter', 'man_united'],
      aliases: ['telles', 'alex telles'],
      activeYears: '2011-Aktif',
      hint: 'Gremio\'dan Galatasaray\'a gelip Inter ve Manchester United\'a transfer oldu.',
    ),
    // ROBIN VAN PERSIE
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
    // NANI (LUIS NANI)
    const PlayerModel(
      id: 'luis_nani',
      name: 'Luís Nani',
      country: 'Portekiz',
      position: 'Kanat',
      clubIds: ['man_united', 'fenerbahce'],
      aliases: ['nani'],
      activeYears: '2005-Aktif',
      hint: 'Man Utd\'da Şampiyonlar Ligi kazandı, 2015\'te Fenerbahçe\'ye transfer oldu.',
    ),
    // SAMIR NASRI
    const PlayerModel(
      id: 'samir_nasri',
      name: 'Samir Nasri',
      country: 'Fransa',
      position: 'Oyun Kurucu',
      clubIds: ['arsenal', 'man_city'],
      aliases: ['nasri'],
      activeYears: '2004-2020',
      hint: 'Arsenal\'den Man City\'ye geçip şampiyonluklar yaşayan Fransız yetenek.',
    ),
    // EMMANUEL ADEBAYOR
    const PlayerModel(
      id: 'emmanuel_adebayor',
      name: 'Emmanuel Adebayor',
      country: 'Togo',
      position: 'Santrafor',
      clubIds: ['arsenal', 'man_city', 'real_madrid'],
      aliases: ['adebayor'],
      activeYears: '2001-2023',
      hint: 'Arsenal\'e gol attıktan sonra eski taraftarına doğru depar atıp kutlayan forvet.',
    ),
    // GABRIEL JESUS
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
    // OLEKSANDR ZINCHENKO
    const PlayerModel(
      id: 'oleksandr_zinchenko',
      name: 'Oleksandr Zinchenko',
      country: 'Ukrayna',
      position: 'Sol Bek / Orta Saha',
      clubIds: ['man_city', 'arsenal'],
      aliases: ['zinchenko'],
      activeYears: '2015-Aktif',
      hint: 'Guardiola\'nın City\'sinden Arteta\'nın Arsenal\'ine transfer oldu.',
    ),
    // RAHEEM STERLING
    const PlayerModel(
      id: 'raheem_sterling',
      name: 'Raheem Sterling',
      country: 'İngiltere',
      position: 'Kanat',
      clubIds: ['liverpool', 'man_city', 'chelsea', 'arsenal'],
      aliases: ['sterling', 'raheem'],
      activeYears: '2012-Aktif',
      hint: 'İngiltere Premier Lig devlerinin dördünde birden forma giydi!',
    ),
    // KAI HAVERTZ
    const PlayerModel(
      id: 'kai_havertz',
      name: 'Kai Havertz',
      country: 'Almanya',
      position: 'Ofansif Orta Saha / Forvet',
      clubIds: ['chelsea', 'arsenal'],
      aliases: ['havertz', 'kai'],
      activeYears: '2016-Aktif',
      hint: 'Chelsea ile Şampiyonlar Ligi finalinde gol attı, sonra Arsenal\'e geçti.',
    ),
    // JORGINHO
    const PlayerModel(
      id: 'jorginho',
      name: 'Jorginho',
      country: 'İtalya',
      position: 'Orta Saha',
      clubIds: ['chelsea', 'arsenal'],
      aliases: ['jorginho'],
      activeYears: '2010-Aktif',
      hint: 'Zıplayarak penaltı atışıyla tanınan İtalyan milli oyuncu.',
    ),
    // PETR CECH
    const PlayerModel(
      id: 'petr_cech',
      name: 'Petr Čech',
      country: 'Çekya',
      position: 'Kaleci',
      clubIds: ['chelsea', 'arsenal'],
      aliases: ['cech', 'petr cech'],
      activeYears: '1999-2019',
      hint: 'Kaskıyla efsaneleşen Çek dev kaleci, Londra\'nın iki devinde kupa kaldırdı.',
    ),
    // ASHLEY COLE
    const PlayerModel(
      id: 'ashley_cole',
      name: 'Ashley Cole',
      country: 'İngiltere',
      position: 'Sol Bek',
      clubIds: ['arsenal', 'chelsea'],
      aliases: ['cole', 'ashley cole'],
      activeYears: '1998-2019',
      hint: 'Yenilmez Arsenal kadrosundan Chelsea\'ye geçen İngiliz sol bek efsanesi.',
    ),
    // DAVID LUIZ
    const PlayerModel(
      id: 'david_luiz',
      name: 'David Luiz',
      country: 'Brezilya',
      position: 'Stoper',
      clubIds: ['chelsea', 'psg', 'arsenal'],
      aliases: ['david luiz', 'luiz'],
      activeYears: '2006-Aktif',
      hint: 'Kıvırcık saçları ve uzaktan frikikleriyle tanınan Brezilyalı savunmacı.',
    ),
    // OLIVIER GIROUD
    const PlayerModel(
      id: 'olivier_giroud',
      name: 'Olivier Giroud',
      country: 'Fransa',
      position: 'Santrafor',
      clubIds: ['arsenal', 'chelsea', 'milan'],
      aliases: ['giroud'],
      activeYears: '2005-Aktif',
      hint: 'Akrep vuruşu golüyle Puskas ödülü alan Fransız milli forvet.',
    ),
    // ROBERT LEWANDOWSKI
    const PlayerModel(
      id: 'robert_lewandowski',
      name: 'Robert Lewandowski',
      country: 'Polonya',
      position: 'Santrafor',
      clubIds: ['dortmund', 'bayern', 'barcelona'],
      aliases: ['lewandowski', 'lewa'],
      activeYears: '2005-Aktif',
      hint: '9 dakikada 5 gol atan Polonyalı gol makinesi.',
    ),
    // MARIO GOTZE
    const PlayerModel(
      id: 'mario_gotze',
      name: 'Mario Götze',
      country: 'Almanya',
      position: 'Ofansif Orta Saha',
      clubIds: ['dortmund', 'bayern'],
      aliases: ['gotze', 'mario gotze'],
      activeYears: '2009-Aktif',
      hint: '2014 Dünya Kupası finalinde uzatmalarda kupayı getiren golün sahibi.',
    ),
    // MATS HUMMELS
    const PlayerModel(
      id: 'mats_hummels',
      name: 'Mats Hummels',
      country: 'Almanya',
      position: 'Stoper',
      clubIds: ['bayern', 'dortmund'],
      aliases: ['hummels'],
      activeYears: '2006-Aktif',
      hint: 'Bayern ile Dortmund arasında iki kez transfer olmuş Alman stoper.',
    ),
    // ERLING HAALAND (Dortmund & Man City)
    const PlayerModel(
      id: 'erling_haaland',
      name: 'Erling Haaland',
      country: 'Norveç',
      position: 'Santrafor',
      clubIds: ['dortmund', 'man_city'],
      aliases: ['haaland', 'erling'],
      activeYears: '2015-Aktif',
      hint: 'Gol rekorlarını altüst eden Norveçli canavar.',
    ),
    // ILKAY GUNDOGAN
    const PlayerModel(
      id: 'ilkay_gundogan',
      name: 'İlkay Gündoğan',
      country: 'Almanya',
      position: 'Merkez Orta Saha',
      clubIds: ['dortmund', 'man_city', 'barcelona'],
      aliases: ['ilkay', 'gundogan'],
      activeYears: '2008-Aktif',
      hint: 'Man City ile 3 kupalı sezonun kaptanı, Türk asıllı Alman yıldız.',
    ),
    // LUIS SUAREZ
    const PlayerModel(
      id: 'luis_suarez',
      name: 'Luis Suárez',
      country: 'Uruguay',
      position: 'Santrafor',
      clubIds: ['liverpool', 'barcelona', 'atletico_madrid'],
      aliases: ['suarez', 'el pistolero'],
      activeYears: '2005-Aktif',
      hint: 'El Pistolero! Liverpool\'da gol kralı, Barcelona\'da MSN üçlüsünün 9 numarası.',
    ),
    // PHILIPPE COUTINHO
    const PlayerModel(
      id: 'philippe_coutinho',
      name: 'Philippe Coutinho',
      country: 'Brezilya',
      position: 'Ofansif Orta Saha',
      clubIds: ['inter', 'liverpool', 'barcelona', 'bayern'],
      aliases: ['coutinho'],
      activeYears: '2008-Aktif',
      hint: 'Liverpool\'dan Barcelona\'ya 140M€ üzerinde bedelle transfer oldu.',
    ),
    // JAVIER MASCHERANO
    const PlayerModel(
      id: 'javier_mascherano',
      name: 'Javier Mascherano',
      country: 'Arjantin',
      position: 'Ön Libero / Stoper',
      clubIds: ['liverpool', 'barcelona'],
      aliases: ['mascherano', 'el jefecito'],
      activeYears: '2003-2020',
      hint: 'Savaşçı ruhuyla tanınan Arjantinli savunma ustası.',
    ),
    // SERGIO AGUERO
    const PlayerModel(
      id: 'sergio_aguero',
      name: 'Sergio Agüero',
      country: 'Arjantin',
      position: 'Santrafor',
      clubIds: ['atletico_madrid', 'man_city', 'barcelona'],
      aliases: ['aguero', 'kun aguero', 'kun'],
      activeYears: '2003-2021',
      hint: '93:20 unutulmaz şampiyonluk golünün sahibi City efsanesi.',
    ),
    // RODRI
    const PlayerModel(
      id: 'rodri',
      name: 'Rodri (Rodrigo Hernández)',
      country: 'İspanya',
      position: 'Ön Libero',
      clubIds: ['atletico_madrid', 'man_city'],
      aliases: ['rodri', 'rodrigo'],
      activeYears: '2015-Aktif',
      hint: '2024 Ballon d\'Or kazananı, Şampiyonlar Ligi finalinin tek golünü atan yıldız.',
    ),
    // JULIAN ALVAREZ
    const PlayerModel(
      id: 'julian_alvarez',
      name: 'Julián Álvarez',
      country: 'Arjantin',
      position: 'Santrafor',
      clubIds: ['man_city', 'atletico_madrid'],
      aliases: ['alvarez', 'la arana', 'orümcek'],
      activeYears: '2018-Aktif',
      hint: 'Dünya Kupası ve Şampiyonlar Ligi kazanan genç yıldız, Madrid\'e geçti.',
    ),
    // DAVID BECKHAM
    const PlayerModel(
      id: 'david_beckham',
      name: 'David Beckham',
      country: 'İngiltere',
      position: 'Sağ Kanat / Orta Saha',
      clubIds: ['man_united', 'real_madrid', 'milan', 'psg'],
      aliases: ['beckham', 'becks'],
      activeYears: '1992-2013',
      hint: 'Tarihin en iyi frikikçilerinden biri, 7 numaranın ikon ismi.',
    ),
    // CASEMIRO
    const PlayerModel(
      id: 'casemiro',
      name: 'Casemiro (Carlos Henrique)',
      country: 'Brezilya',
      position: 'Ön Libero',
      clubIds: ['real_madrid', 'man_united'],
      aliases: ['casemiro'],
      activeYears: '2010-Aktif',
      hint: 'Real Madrid orta sahasının tankı, 5 Devler Ligi şampiyonu.',
    ),
    // RAPHAEL VARANE
    const PlayerModel(
      id: 'raphael_varane',
      name: 'Raphaël Varane',
      country: 'Fransa',
      position: 'Stoper',
      clubIds: ['real_madrid', 'man_united'],
      aliases: ['varane'],
      activeYears: '2010-2024',
      hint: 'Fransız Dünya Kupası şampiyonu zarif stoper.',
    ),
    // RUUD VAN NISTELROOY
    const PlayerModel(
      id: 'ruud_van_nistelrooy',
      name: 'Ruud van Nistelrooy',
      country: 'Hollanda',
      position: 'Santrafor',
      clubIds: ['man_united', 'real_madrid'],
      aliases: ['van nistelrooy', 'van nistelrooy', 'ruud'],
      activeYears: '1993-2012',
      hint: 'Ceza sahası içi ölümcül bitiricisi Hollandalı forvet.',
    ),
    // GIANLUIGI BUFFON
    const PlayerModel(
      id: 'gianluigi_buffon',
      name: 'Gianluigi Buffon',
      country: 'İtalya',
      position: 'Kaleci',
      clubIds: ['juventus', 'psg'],
      aliases: ['buffon', 'gigi'],
      activeYears: '1995-2023',
      hint: 'İtalya ile 2006 Dünya Kupası kazanan efsanevi kaleci.',
    ),
    // DANI ALVES
    const PlayerModel(
      id: 'dani_alves',
      name: 'Dani Alves',
      country: 'Brezilya',
      position: 'Sağ Bek',
      clubIds: ['barcelona', 'juventus', 'psg'],
      aliases: ['alves', 'dani alves'],
      activeYears: '2001-2023',
      hint: 'Futbol tarihinin en çok kupa kazanan sağ beki.',
    ),
    // OUSMANE DEMBELE
    const PlayerModel(
      id: 'ousmane_dembele',
      name: 'Ousmane Dembélé',
      country: 'Fransa',
      position: 'İki Ayaklı Kanat',
      clubIds: ['dortmund', 'barcelona', 'psg'],
      aliases: ['dembele', 'ousmane'],
      activeYears: '2015-Aktif',
      hint: 'Her iki ayağını da eşit derecede harika kullanan Fransız sprinter kanat.',
    ),
    // KINGSLEY COMAN
    const PlayerModel(
      id: 'kingsley_coman',
      name: 'Kingsley Coman',
      country: 'Fransa',
      position: 'Kanat',
      clubIds: ['psg', 'juventus', 'bayern'],
      aliases: ['coman'],
      activeYears: '2013-Aktif',
      hint: 'Kariyerinde her sezon lig şampiyonluğu yaşayan Fransız kanat.',
    ),
    // BURAK YILMAZ
    const PlayerModel(
      id: 'burak_yilmaz',
      name: 'Burak Yılmaz',
      country: 'Türkiye',
      position: 'Santrafor',
      clubIds: ['besiktas', 'fenerbahce', 'trabzonspor', 'galatasaray'],
      aliases: ['burak', 'kral'],
      activeYears: '2002-2023',
      hint: 'Dört büyüklerin dördünde birden forma giymiş efsane gol kralı.',
    ),
    // SERGEN YALCIN
    const PlayerModel(
      id: 'sergen_yalcin',
      name: 'Sergen Yalçın',
      country: 'Türkiye',
      position: '10 Numara',
      clubIds: ['besiktas', 'fenerbahce', 'galatasaray', 'trabzonspor'],
      aliases: ['sergen'],
      activeYears: '1991-2008',
      hint: 'Sol ayağı bir raket olan, 4 büyüklerin hepsinde oynamış Türk futbol dâhisi.',
    ),
    // CANER ERKIN
    const PlayerModel(
      id: 'caner_erkin',
      name: 'Caner Erkin',
      country: 'Türkiye',
      position: 'Sol Bek',
      clubIds: ['galatasaray', 'fenerbahce', 'inter', 'besiktas'],
      aliases: ['caner'],
      activeYears: '2004-Aktif',
      hint: 'Kavisli ortalarıyla meşhur, üç büyüklerde ve Inter\'de oynayan sol bek.',
    ),
    // EMRE BELÖZOĞLU
    const PlayerModel(
      id: 'emre_belozoglu',
      name: 'Emre Belözoğlu',
      country: 'Türkiye',
      position: 'Orta Saha',
      clubIds: ['galatasaray', 'inter', 'fenerbahce', 'atletico_madrid'],
      aliases: ['emre'],
      activeYears: '1996-2020',
      hint: 'UEFA Kupası şampiyonu, Inter ve Atletico forması giymiş milli maestro.',
    ),
    // HAKAN ŞÜKÜR
    const PlayerModel(
      id: 'hakan_sukur',
      name: 'Hakan Şükür',
      country: 'Türkiye',
      position: 'Santrafor',
      clubIds: ['galatasaray', 'inter'],
      aliases: ['kral hakan', 'sukur'],
      activeYears: '1987-2008',
      hint: 'Dünya Kupası tarihinin en hızlı golünü atan milli santrafor.',
    ),
    // RIGOBERT SONG
    const PlayerModel(
      id: 'rigobert_song',
      name: 'Rigobert Song',
      country: 'Kamerun',
      position: 'Stoper',
      clubIds: ['liverpool', 'galatasaray', 'trabzonspor'],
      aliases: ['song', 'rigobert song'],
      activeYears: '1994-2010',
      hint: 'Kamerunlu efsane stoper, Liverpool, GS ve Trabzonspor\'da oynadı.',
    ),
    // ALEXANDER SORLOTH
    const PlayerModel(
      id: 'alexander_sorloth',
      name: 'Alexander Sørloth',
      country: 'Norveç',
      position: 'Santrafor',
      clubIds: ['trabzonspor', 'atletico_madrid'],
      aliases: ['sorloth'],
      activeYears: '2013-Aktif',
      hint: 'Trabzonspor\'da gol kralı olan Kuzeyin Kralı, La Liga devine transfer oldu.',
    ),
    // HAKAN UNVER
    const PlayerModel(
      id: 'hamit_altintop',
      name: 'Hamit Altıntop',
      country: 'Türkiye',
      position: 'Orta Saha',
      clubIds: ['bayern', 'real_madrid', 'galatasaray'],
      aliases: ['hamit', 'altintop'],
      activeYears: '2000-2018',
      hint: 'Puskas Yılın Golü ödüllü, Bayern, Real Madrid ve Galatasaray forması giymiş milli yıldız.',
    ),
    // LORIS KARIUS
    const PlayerModel(
      id: 'loris_karius',
      name: 'Loris Karius',
      country: 'Almanya',
      position: 'Kaleci',
      clubIds: ['liverpool', 'besiktas'],
      aliases: ['karius'],
      activeYears: '2012-Aktif',
      hint: '2018 Şampiyonlar Ligi finali sonrası Beşiktaş\'a kiralanan Alman kaleci.',
    ),
    // MIRALEM PJANIC
    const PlayerModel(
      id: 'miralem_pjanic',
      name: 'Miralem Pjanić',
      country: 'Bosna-Hersek',
      position: 'Orta Saha',
      clubIds: ['juventus', 'barcelona', 'besiktas'],
      aliases: ['pjanic'],
      activeYears: '2007-Aktif',
      hint: 'Bosnalı frikik ustası; Juventus, Barcelona ve Beşiktaş forması giydi.',
    ),
    // RICARDO QUARESMA
    const PlayerModel(
      id: 'ricardo_quaresma',
      name: 'Ricardo Quaresma',
      country: 'Portekiz',
      position: 'Kanat',
      clubIds: ['barcelona', 'inter', 'chelsea', 'besiktas'],
      aliases: ['quaresma', 'trivela', 'q7'],
      activeYears: '2001-2022',
      hint: 'Trivela ve rabona hareketleriyle dünyayı büyüleyen Beşiktaş ikonu.',
    ),
    // SIMAO SABROSA
    const PlayerModel(
      id: 'simao_sabrosa',
      name: 'Simão Sabrosa',
      country: 'Portekiz',
      position: 'Kanat',
      clubIds: ['barcelona', 'atletico_madrid', 'besiktas'],
      aliases: ['simao'],
      activeYears: '1997-2014',
      hint: 'Barcelona ve Atletico Madrid sonrası Beşiktaş\'a gelen Portekizli yıldız.',
    ),
    // HUGO ALMEIDA
    const PlayerModel(
      id: 'hugo_almeida',
      name: 'Hugo Almeida',
      country: 'Portekiz',
      position: 'Santrafor',
      clubIds: ['besiktas'],
      aliases: ['almeida'],
      activeYears: '2001-2020',
      hint: 'Beşiktaş\'ın sol ayaklı dev forveti.',
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
}
