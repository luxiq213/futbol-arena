import 'dart:math';
import 'package:flutter/material.dart';
import '../models/club_model.dart';
import '../models/player_model.dart';
import '../models/grid_challenge_model.dart';
import '../models/play_mode_model.dart';
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
    'bursaspor': const ClubModel(
      id: 'bursaspor',
      name: 'Bursaspor',
      shortName: 'BUR',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFF008542),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.stripesVertical,
    ),
    'basaksehir': const ClubModel(
      id: 'basaksehir',
      name: 'Başakşehir',
      shortName: 'İBF',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFFF37021),
      secondaryColor: Color(0xFF1A2B4C),
      pattern: BadgePattern.halves,
    ),
    'sivasspor': const ClubModel(
      id: 'sivasspor',
      name: 'Sivasspor',
      shortName: 'SVS',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFFE30613),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.stripesVertical,
    ),
    'adana_demirspor': const ClubModel(
      id: 'adana_demirspor',
      name: 'Adana Demirspor',
      shortName: 'ADS',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFF004B93),
      secondaryColor: Color(0xFF5BC2E7),
      pattern: BadgePattern.stripesVertical,
    ),
    'samsunspor': const ClubModel(
      id: 'samsunspor',
      name: 'Samsunspor',
      shortName: 'SAM',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFFD91920),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.diagonalSash,
    ),
    'goztepe': const ClubModel(
      id: 'goztepe',
      name: 'Göztepe',
      shortName: 'GÖZ',
      country: 'Türkiye',
      league: 'Süper Lig',
      primaryColor: Color(0xFFFFD100),
      secondaryColor: Color(0xFFE30613),
      pattern: BadgePattern.halves,
    ),
    'leicester': const ClubModel(
      id: 'leicester',
      name: 'Leicester City',
      shortName: 'LEI',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFF003090),
      secondaryColor: Color(0xFFFDBE11),
      pattern: BadgePattern.solidWithTrim,
    ),
    'newcastle': const ClubModel(
      id: 'newcastle',
      name: 'Newcastle United',
      shortName: 'NEW',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFF000000),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.stripesVertical,
    ),
    'aston_villa': const ClubModel(
      id: 'aston_villa',
      name: 'Aston Villa',
      shortName: 'AVL',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFF670E36),
      secondaryColor: Color(0xFF95BFE5),
      pattern: BadgePattern.solidWithTrim,
    ),
    'west_ham': const ClubModel(
      id: 'west_ham',
      name: 'West Ham United',
      shortName: 'WHU',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFF7A263A),
      secondaryColor: Color(0xFF1BB1E7),
      pattern: BadgePattern.solidWithTrim,
    ),
    'everton': const ClubModel(
      id: 'everton',
      name: 'Everton',
      shortName: 'EVE',
      country: 'İngiltere',
      league: 'Premier League',
      primaryColor: Color(0xFF003399),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.solidWithTrim,
    ),
    'valencia': const ClubModel(
      id: 'valencia',
      name: 'Valencia CF',
      shortName: 'VAL',
      country: 'İspanya',
      league: 'La Liga',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFFFF6600),
      accentColor: Color(0xFF000000),
      pattern: BadgePattern.solidWithTrim,
    ),
    'villarreal': const ClubModel(
      id: 'villarreal',
      name: 'Villarreal CF',
      shortName: 'VIL',
      country: 'İspanya',
      league: 'La Liga',
      primaryColor: Color(0xFFFFE667),
      secondaryColor: Color(0xFF005187),
      pattern: BadgePattern.solidWithTrim,
    ),
    'deportivo': const ClubModel(
      id: 'deportivo',
      name: 'Deportivo La Coruña',
      shortName: 'DEP',
      country: 'İspanya',
      league: 'La Liga',
      primaryColor: Color(0xFF003399),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.stripesVertical,
    ),
    'real_sociedad': const ClubModel(
      id: 'real_sociedad',
      name: 'Real Sociedad',
      shortName: 'RSO',
      country: 'İspanya',
      league: 'La Liga',
      primaryColor: Color(0xFF0067B1),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.stripesVertical,
    ),
    'real_betis': const ClubModel(
      id: 'real_betis',
      name: 'Real Betis',
      shortName: 'BET',
      country: 'İspanya',
      league: 'La Liga',
      primaryColor: Color(0xFF0BB363),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.stripesVertical,
    ),
    'lazio': const ClubModel(
      id: 'lazio',
      name: 'SS Lazio',
      shortName: 'LAZ',
      country: 'İtalya',
      league: 'Serie A',
      primaryColor: Color(0xFF87D8F7),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.solidWithTrim,
    ),
    'fiorentina': const ClubModel(
      id: 'fiorentina',
      name: 'ACF Fiorentina',
      shortName: 'FIO',
      country: 'İtalya',
      league: 'Serie A',
      primaryColor: Color(0xFF482E92),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.solidWithTrim,
    ),
    'parma': const ClubModel(
      id: 'parma',
      name: 'Parma Calcio',
      shortName: 'PAR',
      country: 'İtalya',
      league: 'Serie A',
      primaryColor: Color(0xFFFFD200),
      secondaryColor: Color(0xFF003399),
      pattern: BadgePattern.stripesVertical,
    ),
    'atalanta': const ClubModel(
      id: 'atalanta',
      name: 'Atalanta BC',
      shortName: 'ATA',
      country: 'İtalya',
      league: 'Serie A',
      primaryColor: Color(0xFF1E71B8),
      secondaryColor: Color(0xFF000000),
      pattern: BadgePattern.stripesVertical,
    ),
    'wolfsburg': const ClubModel(
      id: 'wolfsburg',
      name: 'VfL Wolfsburg',
      shortName: 'WOB',
      country: 'Almanya',
      league: 'Bundesliga',
      primaryColor: Color(0xFF65B32E),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.solidWithTrim,
    ),
    'schalke': const ClubModel(
      id: 'schalke',
      name: 'Schalke 04',
      shortName: 'S04',
      country: 'Almanya',
      league: 'Bundesliga',
      primaryColor: Color(0xFF004D9D),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.solidWithTrim,
    ),
    'werder_bremen': const ClubModel(
      id: 'werder_bremen',
      name: 'Werder Bremen',
      shortName: 'SVW',
      country: 'Almanya',
      league: 'Bundesliga',
      primaryColor: Color(0xFF1D9053),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.diagonalSash,
    ),
    'leipzig': const ClubModel(
      id: 'leipzig',
      name: 'RB Leipzig',
      shortName: 'RBL',
      country: 'Almanya',
      league: 'Bundesliga',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFFDD0741),
      pattern: BadgePattern.solidWithTrim,
    ),
    'lyon': const ClubModel(
      id: 'lyon',
      name: 'Olympique Lyonnais',
      shortName: 'OL',
      country: 'Fransa',
      league: 'Ligue 1',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFF15367E),
      accentColor: Color(0xFFDA001A),
      pattern: BadgePattern.solidWithTrim,
    ),
    'marseille': const ClubModel(
      id: 'marseille',
      name: 'Olympique Marseille',
      shortName: 'OM',
      country: 'Fransa',
      league: 'Ligue 1',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFF2FAEE0),
      pattern: BadgePattern.solidWithTrim,
    ),
    'lille': const ClubModel(
      id: 'lille',
      name: 'LOSC Lille',
      shortName: 'LIL',
      country: 'Fransa',
      league: 'Ligue 1',
      primaryColor: Color(0xFFE01E13),
      secondaryColor: Color(0xFF1B243E),
      pattern: BadgePattern.solidWithTrim,
    ),
    'psv': const ClubModel(
      id: 'psv',
      name: 'PSV Eindhoven',
      shortName: 'PSV',
      country: 'Hollanda',
      league: 'Eredivisie',
      primaryColor: Color(0xFFED1C24),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.stripesVertical,
    ),
    'celtic': const ClubModel(
      id: 'celtic',
      name: 'Celtic FC',
      shortName: 'CEL',
      country: 'İskoçya',
      league: 'Premiership',
      primaryColor: Color(0xFF018749),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.stripesVertical,
    ),
    'santos': const ClubModel(
      id: 'santos',
      name: 'Santos FC',
      shortName: 'SAN',
      country: 'Brezilya',
      league: 'Brasileirão',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFF000000),
      pattern: BadgePattern.diagonalSash,
    ),
    'boca_juniors': const ClubModel(
      id: 'boca_juniors',
      name: 'Boca Juniors',
      shortName: 'BOC',
      country: 'Arjantin',
      league: 'Primera División',
      primaryColor: Color(0xFF003399),
      secondaryColor: Color(0xFFFFCC00),
      pattern: BadgePattern.halves,
    ),
  };

  // --- NATIONAL TEAMS / COUNTRIES (FOR TAKIM x ÜLKE MODE) ---
  final Map<String, ClubModel> _nationalTeams = {
    'nat_brezilya': const ClubModel(
      id: 'nat_brezilya',
      name: 'Brezilya',
      shortName: 'BRA',
      country: 'Güney Amerika',
      league: 'Milli Takım',
      primaryColor: Color(0xFFFFDF00),
      secondaryColor: Color(0xFF009C3B),
      accentColor: Color(0xFF002776),
      pattern: BadgePattern.solidWithTrim,
    ),
    'nat_fransa': const ClubModel(
      id: 'nat_fransa',
      name: 'Fransa',
      shortName: 'FRA',
      country: 'Avrupa',
      league: 'Milli Takım',
      primaryColor: Color(0xFF002395),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFED2939),
      pattern: BadgePattern.stripesVertical,
    ),
    'nat_arjantin': const ClubModel(
      id: 'nat_arjantin',
      name: 'Arjantin',
      shortName: 'ARG',
      country: 'Güney Amerika',
      league: 'Milli Takım',
      primaryColor: Color(0xFF74ACDF),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFF6B40E),
      pattern: BadgePattern.stripesVertical,
    ),
    'nat_portekiz': const ClubModel(
      id: 'nat_portekiz',
      name: 'Portekiz',
      shortName: 'POR',
      country: 'Avrupa',
      league: 'Milli Takım',
      primaryColor: Color(0xFFFF0000),
      secondaryColor: Color(0xFF006600),
      accentColor: Color(0xFFFFCC00),
      pattern: BadgePattern.halves,
    ),
    'nat_almanya': const ClubModel(
      id: 'nat_almanya',
      name: 'Almanya',
      shortName: 'GER',
      country: 'Avrupa',
      league: 'Milli Takım',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFFDD0000),
      accentColor: Color(0xFFFFCE00),
      pattern: BadgePattern.solidWithTrim,
    ),
    'nat_ingiltere': const ClubModel(
      id: 'nat_ingiltere',
      name: 'İngiltere',
      shortName: 'ENG',
      country: 'Avrupa',
      league: 'Milli Takım',
      primaryColor: Color(0xFFFFFFFF),
      secondaryColor: Color(0xFFCE1124),
      accentColor: Color(0xFF00247D),
      pattern: BadgePattern.solidWithTrim,
    ),
    'nat_ispanya': const ClubModel(
      id: 'nat_ispanya',
      name: 'İspanya',
      shortName: 'ESP',
      country: 'Avrupa',
      league: 'Milli Takım',
      primaryColor: Color(0xFFAA151B),
      secondaryColor: Color(0xFFF1BF00),
      pattern: BadgePattern.solidWithTrim,
    ),
    'nat_italya': const ClubModel(
      id: 'nat_italya',
      name: 'İtalya',
      shortName: 'ITA',
      country: 'Avrupa',
      league: 'Milli Takım',
      primaryColor: Color(0xFF0064AA),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF009246),
      pattern: BadgePattern.solidWithTrim,
    ),
    'nat_turkiye': const ClubModel(
      id: 'nat_turkiye',
      name: 'Türkiye',
      shortName: 'TUR',
      country: 'Avrupa / Asya',
      league: 'Milli Takım',
      primaryColor: Color(0xFFE30A17),
      secondaryColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.solidWithTrim,
    ),
    'nat_hollanda': const ClubModel(
      id: 'nat_hollanda',
      name: 'Hollanda',
      shortName: 'NED',
      country: 'Avrupa',
      league: 'Milli Takım',
      primaryColor: Color(0xFFF36C21),
      secondaryColor: Color(0xFF21468B),
      accentColor: Color(0xFFFFFFFF),
      pattern: BadgePattern.solidWithTrim,
    ),
    'nat_belcika': const ClubModel(
      id: 'nat_belcika',
      name: 'Belçika',
      shortName: 'BEL',
      country: 'Avrupa',
      league: 'Milli Takım',
      primaryColor: Color(0xFFE30613),
      secondaryColor: Color(0xFFFFD500),
      accentColor: Color(0xFF000000),
      pattern: BadgePattern.stripesVertical,
    ),
    'nat_uruguay': const ClubModel(
      id: 'nat_uruguay',
      name: 'Uruguay',
      shortName: 'URU',
      country: 'Güney Amerika',
      league: 'Milli Takım',
      primaryColor: Color(0xFF55A6D9),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFFCD116),
      pattern: BadgePattern.stripesVertical,
    ),
    'nat_hirvatistan': const ClubModel(
      id: 'nat_hirvatistan',
      name: 'Hırvatistan',
      shortName: 'CRO',
      country: 'Avrupa',
      league: 'Milli Takım',
      primaryColor: Color(0xFFFF0000),
      secondaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF171796),
      pattern: BadgePattern.stripesVertical,
    ),
    'nat_kolombiya': const ClubModel(
      id: 'nat_kolombiya',
      name: 'Kolombiya',
      shortName: 'COL',
      country: 'Güney Amerika',
      league: 'Milli Takım',
      primaryColor: Color(0xFFFCD116),
      secondaryColor: Color(0xFF003893),
      accentColor: Color(0xFFCE1126),
      pattern: BadgePattern.solidWithTrim,
    ),
    'nat_fas': const ClubModel(
      id: 'nat_fas',
      name: 'Fas',
      shortName: 'MAR',
      country: 'Afrika',
      league: 'Milli Takım',
      primaryColor: Color(0xFFC1272D),
      secondaryColor: Color(0xFF006233),
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
      hint: '5 Ballon d\'Or sahibi efsane, Manchester United, Madrid ve Juventus forması giydi.',
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
      hint: 'Ajax, Juventus, Inter, Barcelona, Milan, PSG ve Manchester United forması giymiş gezgin dev forvet.',
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
      hint: 'Gülümsemesi ve sambasıyla meşhur büyücü; PSG, Barcelona ve Milan\'da oynadı.',
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
      hint: 'Atletico ile La Liga şampiyonu olup Barcelona\'ya transfer olan Türk futbol ikonu.',
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
      hint: 'PSG, Arsenal, Real Madrid, Liverpool, City, Fenerbahçe, Chelsea ve Juventus forması giydi!',
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
      hint: 'Finallerin adamı! Real Madrid, Manchester United, PSG ve Juventus forması giydi.',
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
      hint: 'Tarihin en popüler frikikçisi; Manchester United, Real Madrid, Milan ve PSG\'de oynadı.',
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
      hint: 'Ceza sahası içi ölümcül bitirici; Manchester United ve Real Madrid\'de gol krallıkları yaşadı.',
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
      hint: 'İtalya ile Dünya Kupası kazanan efsane kaleci; Juventus ve PSG kalelerini korudu.',
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
      hint: 'Galatasaray, Fenerbahçe, Beşiktaş üç büyüklerinde ve Inter\'de forma giymiş sol bek.',
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
      hint: 'Dünya Kupası tarihinin en hızlı golcüsü, Galatasaray ve Inter santraforu.',
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
      hint: 'Trivela ve rabona ustası Portekizli büyücü; Sporting, Barcelona, Porto, Inter, Chelsea ve Beşiktaş ikonu.',
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
      hint: 'Sporting, Barcelona, Benfica, Atletico ve Beşiktaş\'ta oynamış Portekizli kanat.',
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
      hint: 'Pitbull lakaplı agresif Brezilyalı orta saha; Juventus, Galatasaray ve Inter\'de oynadı.',
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
      hint: 'Galatasaray, Inter, Porto, Manchester United ve Sevilla forması giymiş Brezilyalı sol bek.',
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
      hint: 'Sporting altyapısı, Manchester United ile Devler Ligi şampiyonu, Fenerbahçe\'de de oynadı.',
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
      hint: 'Atletico Madrid, City efsanesi (93:20 golü) ve kariyerini Barcelona\'da noktalayan santrafor.',
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
      hint: 'Ballon d\'Or sahibi İngiliz yıldız; Liverpool, Real Madrid ve Manchester United formaları giydi.',
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
      hint: 'Chelsea, Manchester United, Inter, Roma ve Napoli formaları giyen dev Belçikalı 9 numara.',
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
      hint: 'Chelsea ve Dortmund sonrası Türkiye\'de Beşiktaş, Fenerbahçe ve Galatasaray formalarını giyen Batman.',
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
      hint: 'Fas ile Dünya Kupası yarı finali oynayan tank; Manchester United ve Fenerbahçe forması giydi.',
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
      hint: 'Dortmund ve Arsenal\'de gol krallıkları yaşadı; Milan, Barcelona ve Chelsea\'de de oynadı.',
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
      hint: 'Dortmund, Manchester United (Avrupa Ligi golü), Arsenal, Roma ve Inter forması giydi.',
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
      hint: 'El Tigre! Porto, Atletico Madrid, Monaco, Manchester United, Chelsea ve Galatasaray santraforu.',
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
      hint: 'Juventus, Cruyff\'un Barcelona Rüya Takımı ve ardından Real Madrid\'de şampiyon olan Danimarkalı dahi.',
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
      hint: 'İspanya\'nın üç devi Barcelona, Real Madrid ve Atletico Madrid formalarını giyen sarı saçlı melek.',
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
      hint: 'Dünya Kupası şampiyonu; Chelsea, Manchester United ve Galatasaray formaları giydi.',
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
      hint: 'Arsenal yenilmez kaptanı; Milan, Juventus, Inter ve City formaları da giydi.',
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
      hint: 'El Matador! Napoli, PSG tarihinin en çok gol atanlarından ve Manchester United santraforu.',
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
      hint: 'El Apache! Manchester United, ezeli rakip Man City ve Juventus\'un savaşçı golcüsü.',
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
      hint: 'Bobo Vieri; Juventus, Atletico (gol kralı), Inter (rekor bonservis), Milan ve Monaco\'da oynadı.',
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
      hint: 'Inter altyapısı, Juventus efsanesi, Milan ve kariyer sonu Fenerbahçe forması giyen Euro 2020 şampiyonu.',
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
      hint: 'Gözlükleriyle meşhur Pitbull; Ajax, Milan, Juventus, Barcelona, Inter ve Spurs\'te oynadı.',
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
      hint: '2006 Dünya Kupası\'nı kaldırıp Ballon d\'Or kazanan stoper; Napoli, Inter, Juventus ve Real Madrid.',
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
      hint: 'City altyapısı, Dortmund\'da fırtına, Manchester United ve Chelsea forması giydi.',
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
      hint: 'Bayern, Napoli, Atletico, Beşiktaş, Milan, Trabzonspor ve Fenerbahçe formaları giydi.',
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
      hint: 'Tottenham, Dortmund, Milan, Barcelona ve Beşiktaş forması giyen gezgin Ganalı.',
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
    // 181. ALEX DE SOUZA
    const PlayerModel(
      id: 'alex_de_souza',
      name: 'Alex de Souza',
      country: 'Brezilya',
      position: '10 Numara',
      clubIds: ['fenerbahce'],
      aliases: ['alex', 'alex de souza', 'doktor'],
      activeYears: '1995-2014',
      hint: 'Kadıköy\'de heykeli dikilen, Fenerbahçe\'nin efsanevi Brezilyalı 10 numarası ve kaptanı.',
    ),
    // 182. FERNANDO MUSLERA
    const PlayerModel(
      id: 'fernando_muslera',
      name: 'Fernando Muslera',
      country: 'Uruguay',
      position: 'Kaleci',
      clubIds: ['galatasaray'],
      aliases: ['muslera', 'nando'],
      activeYears: '2004-Aktif',
      hint: 'Galatasaray tarihinde en çok kupa kazanan yabancı efsane Uruguaylı kaleci.',
    ),
    // 183. CLAUDIO TAFFAREL
    const PlayerModel(
      id: 'claudio_taffarel',
      name: 'Cláudio Taffarel',
      country: 'Brezilya',
      position: 'Kaleci',
      clubIds: ['galatasaray'],
      aliases: ['taffarel'],
      activeYears: '1985-2003',
      hint: 'Brezilya ile Dünya Kupası, Galatasaray ile 2000 UEFA Kupası kazanan efsane kaleci.',
    ),
    // 184. HAKAN ŞÜKÜR
    const PlayerModel(
      id: 'hakan_sukur',
      name: 'Hakan Şükür',
      country: 'Türkiye',
      position: 'Santrafor',
      clubIds: ['galatasaray', 'inter'],
      aliases: ['kral', 'hakan sukur'],
      activeYears: '1987-2008',
      hint: 'Süper Lig tarihinin en golcü ismi; Galatasaray ve Inter forması giydi.',
    ),
    // 185. EMRE BELÖZOĞLU
    const PlayerModel(
      id: 'emre_belozoglu',
      name: 'Emre Belözoğlu',
      country: 'Türkiye',
      position: 'Orta Saha',
      clubIds: ['galatasaray', 'inter', 'fenerbahce', 'atletico_madrid'],
      aliases: ['emre', 'emre belozoglu'],
      activeYears: '1996-2020',
      hint: 'Galatasaray ile UEFA Kupası, ardından Inter, Fenerbahçe ve Atletico Madrid formaları giydi.',
    ),
    // 186. SERGEN YALÇIN
    const PlayerModel(
      id: 'sergen_yalcin',
      name: 'Sergen Yalçın',
      country: 'Türkiye',
      position: '10 Numara',
      clubIds: ['besiktas', 'fenerbahce', 'galatasaray', 'trabzonspor'],
      aliases: ['sergen', 'sergen yalcin'],
      activeYears: '1991-2008',
      hint: 'Beşiktaş efsanesi ve Türkiye\'nin dört büyük kulübünde de forma giymiş sol ayaklı dahi.',
    ),
    // 187. CANER ERKİN
    const PlayerModel(
      id: 'caner_erkin',
      name: 'Caner Erkin',
      country: 'Türkiye',
      position: 'Sol Bek',
      clubIds: ['galatasaray', 'fenerbahce', 'inter', 'besiktas'],
      aliases: ['caner', 'caner erkin'],
      activeYears: '2004-Aktif',
      hint: 'Galatasaray, Fenerbahçe, Inter ve Beşiktaş forması giymiş adrese teslim ortalarıyla ünlü sol bek.',
    ),
    // 188. UĞURCAN ÇAKIR
    const PlayerModel(
      id: 'ugurcan_cakir',
      name: 'Uğurcan Çakır',
      country: 'Türkiye',
      position: 'Kaleci',
      clubIds: ['trabzonspor'],
      aliases: ['ugurcan', 'ugurcan cakir'],
      activeYears: '2014-Aktif',
      hint: 'Trabzonspor\'un 2021-22 Süper Lig şampiyonluğundaki kaptanı ve milli kalecisi.',
    ),
    // 189. NEYMAR JR
    const PlayerModel(
      id: 'neymar',
      name: 'Neymar Jr',
      country: 'Brezilya',
      position: 'Kanat / Forvet',
      clubIds: ['barcelona', 'psg'],
      aliases: ['neymar', 'neymar jr', 'neymar da silva'],
      activeYears: '2009-Aktif',
      hint: 'MSN üçlüsüyle Barcelona\'da Şampiyonlar Ligi kazanan ve PSG rekoru kıran Brezilyalı süperstar.',
    ),
    // 190. KYLIAN MBAPPÉ
    const PlayerModel(
      id: 'kylian_mbappe',
      name: 'Kylian Mbappé',
      country: 'Fransa',
      position: 'Forvet',
      clubIds: ['monaco', 'psg', 'real_madrid'],
      aliases: ['mbappe', 'kylian', 'kylian mbappe'],
      activeYears: '2015-Aktif',
      hint: 'Monaco çıkışlı, PSG tarihinin en golcü oyuncusu ve Real Madrid süperstarı.',
    ),
    // 191. VINÍCIUS JÚNIOR
    const PlayerModel(
      id: 'vinicius_junior',
      name: 'Vinícius Júnior',
      country: 'Brezilya',
      position: 'Sol Kanat',
      clubIds: ['real_madrid'],
      aliases: ['vinicius', 'vini', 'vini jr'],
      activeYears: '2017-Aktif',
      hint: 'Real Madrid formasıyla iki kez Şampiyonlar Ligi finalinde gol atan Brezilyalı kanat yıldızı.',
    ),
    // 192. İRFAN CAN KAHVECİ
    const PlayerModel(
      id: 'irfan_can_kahveci',
      name: 'İrfan Can Kahveci',
      country: 'Türkiye',
      position: 'Orta Saha / Kanat',
      clubIds: ['basaksehir', 'fenerbahce'],
      aliases: ['irfan', 'irfancan', 'irfan can', 'kahveci'],
      activeYears: '2014-Aktif',
      hint: 'Başakşehir ile Süper Lig şampiyonu olup Fenerbahçe forması giyen milli sol ayaklı yıldız.',
    ),
    // 193. FERDİ KADIOĞLU
    const PlayerModel(
      id: 'ferdi_kadioglu',
      name: 'Ferdi Kadıoğlu',
      country: 'Türkiye',
      position: 'Sol Bek',
      clubIds: ['fenerbahce'],
      aliases: ['ferdi', 'kadioglu'],
      activeYears: '2016-Aktif',
      hint: 'Fenerbahçe formasıyla gösterdiği performansla Avrupa sahnesine yükselen milli bek.',
    ),
    // 194. BARIŞ ALPER YILMAZ
    const PlayerModel(
      id: 'baris_alper_yilmaz',
      name: 'Barış Alper Yılmaz',
      country: 'Türkiye',
      position: 'Kanat',
      clubIds: ['galatasaray'],
      aliases: ['baris', 'baris alper', 'bay'],
      activeYears: '2017-Aktif',
      hint: 'Galatasaray ve A Milli Takım\'ın çok yönlü hücum ve kanat oyuncusu.',
    ),
    // 195. GEDSON FERNANDES
    const PlayerModel(
      id: 'gedson_fernandes',
      name: 'Gedson Fernandes',
      country: 'Portekiz',
      position: 'Orta Saha',
      clubIds: ['benfica', 'tottenham', 'galatasaray', 'besiktas'],
      aliases: ['gedson', 'fernandes'],
      activeYears: '2017-Aktif',
      hint: 'Benfica ve Tottenham sonrası Galatasaray ve Beşiktaş formaları giyen dinamik orta saha.',
    ),
    // 196. ALTAY BAYINDIR
    const PlayerModel(
      id: 'altay_bayindir',
      name: 'Altay Bayındır',
      country: 'Türkiye',
      position: 'Kaleci',
      clubIds: ['fenerbahce', 'man_united'],
      aliases: ['altay', 'bayindir'],
      activeYears: '2016-Aktif',
      hint: 'Fenerbahçe kaptanlığının ardından Manchester United\'a transfer olan milli kaleci.',
    ),
    // 197. YUNUS AKGÜN
    const PlayerModel(
      id: 'yunus_akgun',
      name: 'Yunus Akgün',
      country: 'Türkiye',
      position: 'Sağ Kanat',
      clubIds: ['galatasaray', 'adana_demirspor', 'leicester'],
      aliases: ['yunus', 'akgun'],
      activeYears: '2018-Aktif',
      hint: 'Galatasaray altyapısından çıkıp Adana Demirspor ve Leicester City formaları giydi.',
    ),
    // 198. İSMAİL YÜKSEK
    const PlayerModel(
      id: 'ismail_yuksek',
      name: 'İsmail Yüksek',
      country: 'Türkiye',
      position: 'Ön Libero',
      clubIds: ['fenerbahce', 'bursaspor', 'adana_demirspor'],
      aliases: ['ismail', 'yuksek'],
      activeYears: '2018-Aktif',
      hint: 'Fenerbahçe ve A Milli Takım orta sahasının mücadeleci ön liberosu.',
    ),
    // 199. MERT GÜNOK
    const PlayerModel(
      id: 'mert_gunok',
      name: 'Mert Günok',
      country: 'Türkiye',
      position: 'Kaleci',
      clubIds: ['fenerbahce', 'bursaspor', 'basaksehir', 'besiktas'],
      aliases: ['mert', 'gunok'],
      activeYears: '2007-Aktif',
      hint: 'Fenerbahçe, Başakşehir ve Beşiktaş kalelerini koruyan tecrübeli milli file bekçisi.',
    ),
    // 200. FERNANDO MUSLERA
    const PlayerModel(
      id: 'fernando_muslera',
      name: 'Fernando Muslera',
      country: 'Uruguay',
      position: 'Kaleci',
      clubIds: ['lazio', 'galatasaray'],
      aliases: ['muslera', 'nando'],
      activeYears: '2004-Aktif',
      hint: 'Lazio sonrası Galatasaray tarihinin en çok kupa kazanan efsane kalecisi.',
    ),
    // 201. ALEX DE SOUZA
    const PlayerModel(
      id: 'alex_de_souza',
      name: 'Alex de Souza',
      country: 'Brezilya',
      position: '10 Numara',
      clubIds: ['parma', 'fenerbahce'],
      aliases: ['alex', 'kralex', 'doktor'],
      activeYears: '1995-2014',
      hint: 'Fenerbahçe efsanesi ve Heykeli dikilen Brezilyalı 10 numara.',
    ),
    // 202. GUTI HERNÁNDEZ
    const PlayerModel(
      id: 'guti',
      name: 'Guti',
      country: 'İspanya',
      position: 'Orta Saha',
      clubIds: ['real_madrid', 'besiktas'],
      aliases: ['guti', 'guti hernandez'],
      activeYears: '1995-2011',
      hint: 'Real Madrid efsanesi olarak yıllarca kaptanlık yaptıktan sonra Beşiktaş forması giydi.',
    ),
    // 203. MARIO GÓMEZ
    const PlayerModel(
      id: 'mario_gomez',
      name: 'Mario Gómez',
      country: 'Almanya',
      position: 'Santrafor',
      clubIds: ['bayern', 'fiorentina', 'besiktas', 'wolfsburg'],
      aliases: ['gomez', 'mario gomez'],
      activeYears: '2003-2020',
      hint: 'Bayern Münih ile Şampiyonlar Ligi, Beşiktaş ile Süper Lig gol krallığı ve şampiyonluk kazandı.',
    ),
    // 204. MICHY BATSHUAYI
    const PlayerModel(
      id: 'michy_batshuayi',
      name: 'Michy Batshuayi',
      country: 'Belçika',
      position: 'Santrafor',
      clubIds: ['chelsea', 'dortmund', 'valencia', 'besiktas', 'fenerbahce', 'galatasaray'],
      aliases: ['batshuayi', 'batsman'],
      activeYears: '2011-Aktif',
      hint: 'Chelsea, Dortmund ve Valencia sonrası Beşiktaş, Fenerbahçe ve Galatasaray\'da forma giydi.',
    ),
    // 205. DAVINSON SÁNCHEZ
    const PlayerModel(
      id: 'davinson_sanchez',
      name: 'Davinson Sánchez',
      country: 'Kolombiya',
      position: 'Stoper',
      clubIds: ['ajax', 'tottenham', 'galatasaray'],
      aliases: ['davinson', 'sanchez'],
      activeYears: '2013-Aktif',
      hint: 'Ajax ve Tottenham savunmalarının ardından Galatasaray savunmasının lideri oldu.',
    ),
    // 206. KIM MIN-JAE
    const PlayerModel(
      id: 'kim_min_jae',
      name: 'Kim Min-Jae',
      country: 'Güney Kore',
      position: 'Stoper',
      clubIds: ['fenerbahce', 'napoli', 'bayern'],
      aliases: ['kim', 'min jae', 'kim min jae'],
      activeYears: '2016-Aktif',
      hint: 'Fenerbahçe\'den Napoli\'ye şampiyonluk yaşamaya gidip ardından Bayern Münih\'e transfer oldu.',
    ),
    // 207. MIRALEM PJANIĆ
    const PlayerModel(
      id: 'miralem_pjanic',
      name: 'Miralem Pjanić',
      country: 'Bosna Hersek',
      position: 'Orta Saha',
      clubIds: ['roma', 'juventus', 'barcelona', 'besiktas'],
      aliases: ['pjanic'],
      activeYears: '2007-Aktif',
      hint: 'Roma, Juventus ve Barcelona frikik ustası olarak Beşiktaş orta sahasında da görev yaptı.',
    ),
    // 208. LEROY SANÉ
    const PlayerModel(
      id: 'leroy_sane',
      name: 'Leroy Sané',
      country: 'Almanya',
      position: 'Kanat',
      clubIds: ['schalke', 'man_city', 'bayern'],
      aliases: ['sane', 'leroy sane'],
      activeYears: '2014-Aktif',
      hint: 'Schalke 04 çıkışlı, Manchester City ve Bayern Münih formaları giymiş süratli Alman kanat.',
    ),
    // 209. OUSMANE DEMBÉLÉ
    const PlayerModel(
      id: 'ousmane_dembele',
      name: 'Ousmane Dembélé',
      country: 'Fransa',
      position: 'Kanat',
      clubIds: ['dortmund', 'barcelona', 'psg'],
      aliases: ['dembele', 'ousmane'],
      activeYears: '2015-Aktif',
      hint: 'Dortmund ve Barcelona sonrası PSG\'ye transfer olan Dünya Kupası şampiyonu Fransız kanat.',
    ),
    // 210. JOÃO CANCELO
    const PlayerModel(
      id: 'joao_cancelo',
      name: 'João Cancelo',
      country: 'Portekiz',
      position: 'Bek',
      clubIds: ['benfica', 'valencia', 'inter', 'juventus', 'man_city', 'bayern', 'barcelona'],
      aliases: ['cancelo'],
      activeYears: '2012-Aktif',
      hint: 'Avrupa\'nın neredeyse tüm dev liglerinde (Benfica, Inter, Juve, City, Bayern, Barça) oynadı.',
    ),
    // 211. LAMINE YAMAL
    const PlayerModel(
      id: 'lamine_yamal',
      name: 'Lamine Yamal',
      country: 'İspanya',
      position: 'Sağ Kanat',
      clubIds: ['barcelona'],
      aliases: ['yamal', 'lamine'],
      activeYears: '2023-Aktif',
      hint: 'La Masia harikası ve Euro 2024 şampiyonu İspanyol genç süperstar.',
    ),
    // 212. PEDRI
    const PlayerModel(
      id: 'pedri',
      name: 'Pedri',
      country: 'İspanya',
      position: 'Orta Saha',
      clubIds: ['barcelona'],
      aliases: ['pedri', 'pedri gonzalez'],
      activeYears: '2019-Aktif',
      hint: 'Barcelona orta sahasının beyin takımındaki altın çocuk.',
    ),
    // 213. BUKAYO SAKA
    const PlayerModel(
      id: 'bukayo_saka',
      name: 'Bukayo Saka',
      country: 'İngiltere',
      position: 'Sağ Kanat',
      clubIds: ['arsenal'],
      aliases: ['saka', 'starboy'],
      activeYears: '2018-Aktif',
      hint: 'Arsenal akademisinden çıkan İngiltere ve Premier League yıldızı.',
    ),
    // 214. COLE PALMER
    const PlayerModel(
      id: 'cole_palmer',
      name: 'Cole Palmer',
      country: 'İngiltere',
      position: '10 Numara',
      clubIds: ['man_city', 'chelsea'],
      aliases: ['palmer', 'cold palmer'],
      activeYears: '2020-Aktif',
      hint: 'Manchester City altyapısından çıkıp Chelsea\'nin gol ve asist liderine dönüştü.',
    ),
    // 215. PHIL FODEN
    const PlayerModel(
      id: 'phil_foden',
      name: 'Phil Foden',
      country: 'İngiltere',
      position: 'Hücum / Orta Saha',
      clubIds: ['man_city'],
      aliases: ['foden'],
      activeYears: '2017-Aktif',
      hint: 'Manchester City akademisinin yetiştirdiği Premier League Yılın Oyuncusu ödüllü yıldız.',
    ),
    // 216. JAMAL MUSIALA
    const PlayerModel(
      id: 'jamal_musiala',
      name: 'Jamal Musiala',
      country: 'Almanya',
      position: '10 Numara',
      clubIds: ['chelsea', 'bayern'],
      aliases: ['musiala', 'bambi'],
      activeYears: '2020-Aktif',
      hint: 'Chelsea altyapısında yetiştikten sonra Bayern Münih\'in süper yıldızı oldu.',
    ),
    // 217. RAFAEL LEÃO
    const PlayerModel(
      id: 'rafael_leao',
      name: 'Rafael Leão',
      country: 'Portekiz',
      position: 'Sol Kanat',
      clubIds: ['sporting', 'milan'],
      aliases: ['leao', 'rafael leao'],
      activeYears: '2018-Aktif',
      hint: 'Sporting CP çıkışlı, AC Milan ile Serie A şampiyonluğu MVP\'si seçilen Portekizli.',
    ),
    // 218. THEO HERNÁNDEZ
    const PlayerModel(
      id: 'theo_hernandez',
      name: 'Theo Hernández',
      country: 'Fransa',
      position: 'Sol Bek',
      clubIds: ['atletico_madrid', 'real_madrid', 'milan'],
      aliases: ['theo', 'theo hernandez'],
      activeYears: '2015-Aktif',
      hint: 'Madrid derbisinin iki yakasından geçip AC Milan savunmasının solunu fethetti.',
    ),
    // 219. FEDERICO VALVERDE
    const PlayerModel(
      id: 'federico_valverde',
      name: 'Federico Valverde',
      country: 'Uruguay',
      position: 'Orta Saha',
      clubIds: ['deportivo', 'real_madrid'],
      aliases: ['valverde', 'fede'],
      activeYears: '2015-Aktif',
      hint: 'Deportivo kiralığı sonrası Real Madrid orta sahasının bitmeyen motoru.',
    ),
    // 220. RAPHINHA
    const PlayerModel(
      id: 'raphinha',
      name: 'Raphinha',
      country: 'Brezilya',
      position: 'Kanat',
      clubIds: ['sporting', 'barcelona'],
      aliases: ['raphinha'],
      activeYears: '2015-Aktif',
      hint: 'Sporting CP sonrası Barcelona kaptanlığına yükselen Brezilyalı sol ayak.',
    ),
    // 221. ABDÜLKERİM BARDAKCI
    const PlayerModel(
      id: 'abdulkerim_bardakci',
      name: 'Abdülkerim Bardakcı',
      country: 'Türkiye',
      position: 'Stoper',
      clubIds: ['galatasaray'],
      aliases: ['abdulkerim', 'apo', 'bardakci'],
      activeYears: '2011-Aktif',
      hint: 'Galatasaray ve A Milli Takım\'ın sol ayaklı stoperi.',
    ),
    // 222. SEMİH KILIÇSOY
    const PlayerModel(
      id: 'semih_kilicsoy',
      name: 'Semih Kılıçsoy',
      country: 'Türkiye',
      position: 'Forvet',
      clubIds: ['besiktas'],
      aliases: ['semih', 'kilicsoy'],
      activeYears: '2023-Aktif',
      hint: 'Beşiktaş altyapısından yetişen genç Türk golcü.',
    ),
  ];

  /// Get list of all clubs
  List<ClubModel> getAllClubs() => _clubs.values.toList();

  /// Get club or national team by ID
  ClubModel? getClub(String id) => _clubs[id] ?? _nationalTeams[id];

  /// Get all national teams
  List<ClubModel> getAllNationalTeams() => _nationalTeams.values.toList();

  /// Get all players
  List<PlayerModel> getAllPlayers() => _players;

  bool _doesPlayerBelongToEntity(PlayerModel player, String entityId) {
    final natTeam = _nationalTeams[entityId];
    if (natTeam != null) {
      return player.country == natTeam.name;
    }
    return player.playedFor(entityId);
  }

  /// Find all players who match BOTH entities (Club x Club or Club x Country)
  List<PlayerModel> getMutualPlayers(String clubAId, String clubBId) {
    return _players
        .where(
          (p) =>
              _doesPlayerBelongToEntity(p, clubAId) &&
              _doesPlayerBelongToEntity(p, clubBId),
        )
        .toList();
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

  /// Get all unique (Club x Country) pairs that share at least 1 player
  List<MapEntry<ClubModel, ClubModel>> getValidClubCountryPairs() {
    final List<MapEntry<ClubModel, ClubModel>> validPairs = [];
    final clubList = _clubs.values.toList();
    final countryList = _nationalTeams.values.toList();

    for (final club in clubList) {
      for (final country in countryList) {
        if (getMutualPlayers(club.id, country.id).isNotEmpty) {
          validPairs.add(MapEntry(club, country));
        }
      }
    }
    return validPairs;
  }

  /// Get a random pair (Club x Club or Club x Country) filtered by difficulty level
  MapEntry<ClubModel, ClubModel> getRandomClubPair({
    GameDifficulty difficulty = GameDifficulty.medium,
    CommonPlayerPairMode pairFormat = CommonPlayerPairMode.clubVsClub,
  }) {
    final effectiveFormat = pairFormat == CommonPlayerPairMode.mixed
        ? (_random.nextBool()
            ? CommonPlayerPairMode.clubVsClub
            : CommonPlayerPairMode.clubVsCountry)
        : pairFormat;

    final pairs = effectiveFormat == CommonPlayerPairMode.clubVsCountry
        ? getValidClubCountryPairs()
        : getValidClubPairs();

    if (pairs.isEmpty) {
      return MapEntry(_clubs['real_madrid']!, _clubs['arsenal']!);
    }

    final filtered = pairs.where((pair) {
      final count = getMutualPlayers(pair.key.id, pair.value.id).length;
      switch (difficulty) {
        case GameDifficulty.easy:
          return count >= 4;
        case GameDifficulty.medium:
          return count >= 2 && count <= 4;
        case GameDifficulty.hard:
          return count >= 1 && count <= 2;
      }
    }).toList();

    final targetList = filtered.isNotEmpty ? filtered : pairs;
    return targetList[_random.nextInt(targetList.length)];
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

  // --- TROPHY & ACHIEVEMENT SETS FOR 3x3 GRID ---
  static const Set<String> _uclWinners = {
    'cristiano_ronaldo',
    'lionel_messi',
    'ronaldinho',
    'kaka',
    'zinedine_zidane',
    'david_beckham',
    'luis_figo',
    'samuel_etoo',
    'thierry_henry',
    'angel_di_maria',
    'karim_benzema',
    'luka_modric',
    'toni_kroos',
    'gareth_bale',
    'sergio_ramos',
    'marcelo',
    'casemiro',
    'pepe',
    'xabi_alonso',
    'arjen_robben',
    'franck_ribery',
    'thomas_muller',
    'manuel_neuer',
    'david_alaba',
    'thiago_alcantara',
    'robert_lewandowski',
    'erling_haaland',
    'kevin_de_bruyne',
    'ilkay_gundogan',
    'rodri',
    'bernardo_silva',
    'riyad_mahrez',
    'julian_alvarez',
    'mohamed_salah',
    'sadio_mane',
    'virgil_van_dijk',
    'steven_gerrard',
    'fernando_torres',
    'didier_drogba',
    'frank_lampard',
    'john_terry',
    'petr_cech',
    'ashley_cole',
    'david_luiz',
    'ngolo_kante',
    'kai_havertz',
    'jorginho',
    'mateo_kovacic',
    'antonio_rudiger',
    'hakim_ziyech',
    'olivier_giroud',
    'wesley_sneijder',
    'clarence_seedorf',
    'andrea_pirlo',
    'paolo_maldini',
    'alessandro_nesta',
    'filippo_inzaghi',
    'andriy_shevchenko',
    'deco',
    'ricardo_carvalho',
    'wayne_rooney',
    'rio_ferdinand',
    'paul_scholes',
    'ryan_giggs',
    'carlos_tevez',
    'gerard_pique',
    'xavi_hernandez',
    'andres_iniesta',
    'sergio_busquets',
    'dani_alves',
    'neymar',
    'luis_suarez',
    'ivan_rakitic',
    'javier_mascherano',
    'david_villa',
    'yaya_toure',
    'achraf_hakimi',
    'marco_asensio',
    'thibaut_courtois',
    'eden_hazard',
    'alvaro_morata',
    'juan_mata',
    'philippe_coutinho',
    'ivan_perisic',
    'kingsley_coman',
    'alex_oxlade_chamberlain',
    'roberto_carlos',
    'raul_gonzalez',
    'iker_casillas',
    'nicolas_anelka',
  };

  static const Set<String> _worldCupWinners = {
    'lionel_messi',
    'angel_di_maria',
    'julian_alvarez',
    'paulo_dybala',
    'ronaldo_nazario',
    'ronaldinho',
    'rivaldo',
    'roberto_carlos',
    'cafu',
    'kaka',
    'zinedine_zidane',
    'thierry_henry',
    'patrick_vieira',
    'kylian_mbappe',
    'antoine_griezmann',
    'paul_pogba',
    'ngolo_kante',
    'olivier_giroud',
    'raphael_varane',
    'ousmane_dembele',
    'manuel_neuer',
    'thomas_muller',
    'toni_kroos',
    'mesut_ozil',
    'lukas_podolski',
    'bastian_schweinsteiger',
    'philipp_lahm',
    'miroslav_klose',
    'mats_hummels',
    'mario_gotze',
    'jerome_boateng',
    'iker_casillas',
    'sergio_ramos',
    'carles_puyol',
    'gerard_pique',
    'xavi_hernandez',
    'andres_iniesta',
    'sergio_busquets',
    'xabi_alonso',
    'david_villa',
    'fernando_torres',
    'cesc_fabregas',
    'juan_mata',
    'david_silva',
    'gianluigi_buffon',
    'fabio_cannavaro',
    'alessandro_nesta',
    'andrea_pirlo',
    'francesco_totti',
    'alessandro_del_piero',
    'filippo_inzaghi',
  };

  static const Set<String> _ballonDorWinners = {
    'cristiano_ronaldo',
    'lionel_messi',
    'ronaldo_nazario',
    'ronaldinho',
    'rivaldo',
    'kaka',
    'zinedine_zidane',
    'luis_figo',
    'luka_modric',
    'karim_benzema',
    'rodri',
    'michael_owen',
    'andriy_shevchenko',
    'pavel_nedved',
    'fabio_cannavaro',
    'roberto_baggio',
  };

  static const Set<String> _goldenBootWinners = {
    'cristiano_ronaldo',
    'lionel_messi',
    'erling_haaland',
    'robert_lewandowski',
    'luis_suarez',
    'thierry_henry',
    'ronaldo_nazario',
    'zlatan_ibrahimovic',
    'harry_kane',
    'kylian_mbappe',
    'mohamed_salah',
    'didier_drogba',
    'robin_van_persie',
    'sergio_aguero',
    'karim_benzema',
    'ruud_van_nistelrooy',
    'andriy_shevchenko',
    'filippo_inzaghi',
    'francesco_totti',
    'alessandro_del_piero',
    'samuel_etoo',
    'david_villa',
    'radamel_falcao',
    'edinson_cavani',
    'gonzalo_higuain',
    'mauro_icardi',
    'ciro_immobile',
    'victor_osimhen',
    'aubameyang',
    'wayne_rooney',
    'michael_owen',
    'fernando_torres',
    'mario_gomez',
    'burak_yilmaz',
    'alex_de_souza',
    'hakan_sukur',
    'edin_dzeko',
    'romelu_lukaku',
    'carlos_tevez',
    'james_rodriguez',
    'dries_mertens',
  };

  GridCriterion _clubCrit(String clubId) {
    final club = _clubs[clubId]!;
    return GridCriterion(
      id: clubId,
      label: club.name,
      sublabel: club.league,
      type: GridCriterionType.club,
      isClub: true,
      club: club,
    );
  }

  static const GridCriterion _critUcl = GridCriterion(
    id: 'trophy_ucl',
    label: 'Şampiyonlar Ligi',
    sublabel: 'Kupa Şampiyonu',
    type: GridCriterionType.trophy,
    badgeCode: 'UCL',
  );

  static const GridCriterion _critWorldCup = GridCriterion(
    id: 'trophy_wc',
    label: 'Dünya Kupası',
    sublabel: 'Milli Takım Zaferi',
    type: GridCriterionType.trophy,
    badgeCode: 'WC',
  );

  static const GridCriterion _critBallonDor = GridCriterion(
    id: 'trophy_ballon_dor',
    label: 'Ballon d\'Or',
    sublabel: 'Altın Top Kazananı',
    type: GridCriterionType.trophy,
    badgeCode: 'BDO',
  );

  static const GridCriterion _critSuperLig = GridCriterion(
    id: 'trophy_super_lig',
    label: 'Süper Lig Şampiyonu',
    sublabel: 'Türkiye Zaferi',
    type: GridCriterionType.trophy,
    badgeCode: 'SL',
  );

  static const GridCriterion _critPremierLeague = GridCriterion(
    id: 'trophy_epl',
    label: 'Premier League',
    sublabel: 'İngiltere Şampiyonu',
    type: GridCriterionType.trophy,
    badgeCode: 'EPL',
  );

  static const GridCriterion _critLaLiga = GridCriterion(
    id: 'trophy_laliga',
    label: 'La Liga Şampiyonu',
    sublabel: 'İspanya Zaferi',
    type: GridCriterionType.trophy,
    badgeCode: 'LAL',
  );

  static const GridCriterion _critSerieA = GridCriterion(
    id: 'trophy_seriea',
    label: 'Serie A Şampiyonu',
    sublabel: 'İtalya Zaferi',
    type: GridCriterionType.trophy,
    badgeCode: 'SER',
  );

  static const GridCriterion _critGoldenBoot = GridCriterion(
    id: 'trophy_golden_boot',
    label: 'Gol Kralı',
    sublabel: 'Altın Ayakkabı',
    type: GridCriterionType.trophy,
    badgeCode: 'GB',
  );

  static const GridCriterion _critBrazil = GridCriterion(
    id: 'nat_brezilya',
    label: 'Brezilya Milli',
    sublabel: 'Sambacılar',
    type: GridCriterionType.nationality,
    badgeCode: 'BRA',
  );

  static const GridCriterion _critFrance = GridCriterion(
    id: 'nat_fransa',
    label: 'Fransa Milli',
    sublabel: 'Horozlar',
    type: GridCriterionType.nationality,
    badgeCode: 'FRA',
  );

  static const GridCriterion _critArgentina = GridCriterion(
    id: 'nat_arjantin',
    label: 'Arjantin Milli',
    sublabel: 'Tangocular',
    type: GridCriterionType.nationality,
    badgeCode: 'ARG',
  );

  static const GridCriterion _critPortugal = GridCriterion(
    id: 'nat_portekiz',
    label: 'Portekiz Milli',
    sublabel: 'Avrupa',
    type: GridCriterionType.nationality,
    badgeCode: 'POR',
  );

  static const GridCriterion _critGermany = GridCriterion(
    id: 'nat_almanya',
    label: 'Almanya Milli',
    sublabel: 'Panzerler',
    type: GridCriterionType.nationality,
    badgeCode: 'GER',
  );

  static const GridCriterion _critEngland = GridCriterion(
    id: 'nat_ingiltere',
    label: 'İngiltere Milli',
    sublabel: 'Üç Aslan',
    type: GridCriterionType.nationality,
    badgeCode: 'ENG',
  );

  static const GridCriterion _critSpain = GridCriterion(
    id: 'nat_ispanya',
    label: 'İspanya Milli',
    sublabel: 'Boğalar',
    type: GridCriterionType.nationality,
    badgeCode: 'ESP',
  );

  static const GridCriterion _critTurkey = GridCriterion(
    id: 'nat_turkiye',
    label: 'Türkiye Milli',
    sublabel: 'Ay-Yıldızlılar',
    type: GridCriterionType.nationality,
    badgeCode: 'TUR',
  );

  bool _doesPlayerMatchCriterion(PlayerModel player, GridCriterion crit) {
    if (crit.isClub || _clubs.containsKey(crit.id)) {
      return player.playedFor(crit.id);
    }

    switch (crit.id) {
      case 'trophy_ucl':
        return _uclWinners.contains(player.id) ||
            player.trophies.contains('trophy_ucl') ||
            player.hint.contains('Şampiyonlar Ligi') ||
            player.hint.contains('Devler Ligi');
      case 'trophy_wc':
        return _worldCupWinners.contains(player.id) ||
            player.trophies.contains('trophy_wc') ||
            player.hint.contains('Dünya Kupası şampiyonu');
      case 'trophy_ballon_dor':
        return _ballonDorWinners.contains(player.id) ||
            player.trophies.contains('trophy_ballon_dor') ||
            player.hint.contains('Ballon d\'Or');
      case 'trophy_golden_boot':
        return _goldenBootWinners.contains(player.id) ||
            player.position.contains('Santrafor') ||
            player.position.contains('Forvet');
      case 'trophy_super_lig':
        return player.playedFor('galatasaray') ||
            player.playedFor('fenerbahce') ||
            player.playedFor('besiktas') ||
            player.playedFor('trabzonspor');
      case 'trophy_epl':
        return player.playedFor('man_united') ||
            player.playedFor('man_city') ||
            player.playedFor('chelsea') ||
            player.playedFor('arsenal') ||
            player.playedFor('liverpool');
      case 'trophy_laliga':
        return player.playedFor('real_madrid') ||
            player.playedFor('barcelona') ||
            player.playedFor('atletico_madrid');
      case 'trophy_seriea':
        return player.playedFor('juventus') ||
            player.playedFor('inter') ||
            player.playedFor('milan') ||
            player.playedFor('napoli') ||
            player.playedFor('roma');
      case 'nat_brezilya':
        return player.country == 'Brezilya';
      case 'nat_fransa':
        return player.country == 'Fransa';
      case 'nat_arjantin':
        return player.country == 'Arjantin';
      case 'nat_portekiz':
        return player.country == 'Portekiz';
      case 'nat_almanya':
        return player.country == 'Almanya';
      case 'nat_ingiltere':
        return player.country == 'İngiltere';
      case 'nat_ispanya':
        return player.country == 'İspanya';
      case 'nat_italya':
        return player.country == 'İtalya';
      case 'nat_turkiye':
        return player.country == 'Türkiye';
      case 'nat_hollanda':
        return player.country == 'Hollanda';
      default:
        return player.matchesGridCriterion(crit.id);
    }
  }

  /// 3x3 Grid Challenges (Clubs, Trophies, and Nationalities)
  List<GridChallenge> getGridChallenges({GridThemeType? theme}) {
    final allChallenges = <GridChallenge>[
      // 1. Kupalar & Dev Kulüpler (Trophies + Giants)
      GridChallenge(
        title: 'Devler Ligi & Altın Top Matrisi',
        theme: GridThemeType.trophiesAndClubs,
        rowCriteria: [
          _clubCrit('real_madrid'),
          _clubCrit('barcelona'),
          _clubCrit('milan'),
        ],
        colCriteria: [
          _critUcl,
          _critBallonDor,
          _critWorldCup,
        ],
      ),

      // 2. Kupalar, Milli Takımlar & Kulüpler Karışık
      GridChallenge(
        title: 'Şampiyonlar & Milli Takım Matrisi',
        theme: GridThemeType.mixed,
        rowCriteria: [
          _critUcl,
          _critGoldenBoot,
          _critPremierLeague,
        ],
        colCriteria: [
          _clubCrit('real_madrid'),
          _clubCrit('chelsea'),
          _critBrazil,
        ],
      ),

      // 3. Süper Lig, Kupalar & Avrupa Devleri
      GridChallenge(
        title: 'Süper Lig & Avrupa Kupaları',
        theme: GridThemeType.superLigSpecial,
        rowCriteria: [
          _clubCrit('galatasaray'),
          _clubCrit('fenerbahce'),
          _clubCrit('besiktas'),
        ],
        colCriteria: [
          _critUcl,
          _critGoldenBoot,
          _critPremierLeague,
        ],
      ),

      // 4. Milli Takımlar & Büyük Kupalar
      GridChallenge(
        title: 'Milli Yıldızlar & Kupa Zaferleri',
        theme: GridThemeType.nationsAndTrophies,
        rowCriteria: [
          _critBrazil,
          _critFrance,
          _critArgentina,
        ],
        colCriteria: [
          _critUcl,
          _critLaLiga,
          _critSerieA,
        ],
      ),

      // 5. Avrupa Lig Şampiyonlukları & Kulüpler
      GridChallenge(
        title: 'Lig Şampiyonları & Kupa Koleksiyoncuları',
        theme: GridThemeType.trophiesAndClubs,
        rowCriteria: [
          _clubCrit('juventus'),
          _clubCrit('inter'),
          _clubCrit('bayern'),
        ],
        colCriteria: [
          _critUcl,
          _critWorldCup,
          _critGoldenBoot,
        ],
      ),

      // 6. Milli Takımlar & Süper Lig / Avrupa
      GridChallenge(
        title: 'Ülkeler & Şampiyonluklar',
        theme: GridThemeType.nationsAndTrophies,
        rowCriteria: [
          _critPortugal,
          _critGermany,
          _critSpain,
        ],
        colCriteria: [
          _clubCrit('real_madrid'),
          _critUcl,
          _critPremierLeague,
        ],
      ),

      // 7. Klasik Kulüpler 1
      GridChallenge(
        title: 'Klasik Avrupa & Süper Lig Kesişimi',
        theme: GridThemeType.classicClubs,
        rowCriteria: [
          _clubCrit('real_madrid'),
          _clubCrit('barcelona'),
          _clubCrit('galatasaray'),
        ],
        colCriteria: [
          _clubCrit('arsenal'),
          _clubCrit('inter'),
          _clubCrit('chelsea'),
        ],
      ),

      // 8. Klasik Kulüpler 2
      GridChallenge(
        title: 'Dev Kulüpler Transfer Kesişimi',
        theme: GridThemeType.classicClubs,
        rowCriteria: [
          _clubCrit('man_united'),
          _clubCrit('bayern'),
          _clubCrit('fenerbahce'),
        ],
        colCriteria: [
          _clubCrit('real_madrid'),
          _clubCrit('juventus'),
          _clubCrit('chelsea'),
        ],
      ),

      // 9. Karışık Süper Lig, Milli Takım & Kupa
      GridChallenge(
        title: 'Süper Lig, Milli Takım ve Devler',
        theme: GridThemeType.superLigSpecial,
        rowCriteria: [
          _critSuperLig,
          _critLaLiga,
          _critSerieA,
        ],
        colCriteria: [
          _critTurkey,
          _critBrazil,
          _critUcl,
        ],
      ),

      // 10. İngiltere, Fransa & İspanya Milli Yıldızlar
      GridChallenge(
        title: 'Avrupa Milli Takımları & Dev Kulüpler',
        theme: GridThemeType.nationsAndTrophies,
        rowCriteria: [
          _critEngland,
          _critFrance,
          _critSpain,
        ],
        colCriteria: [
          _clubCrit('real_madrid'),
          _clubCrit('chelsea'),
          _critPremierLeague,
        ],
      ),
    ];

    if (theme == null || theme == GridThemeType.mixed) {
      return allChallenges;
    }
    final filtered = allChallenges.where((c) => c.theme == theme).toList();
    return filtered.isNotEmpty ? filtered : allChallenges;
  }

  GridChallenge getRandom3x3GridChallenge({GridThemeType? theme}) {
    final challenges = getGridChallenges(theme: theme);
    return challenges[_random.nextInt(challenges.length)];
  }

  bool validateGridCell(GridCriterion row, GridCriterion col, PlayerModel player) {
    return _doesPlayerMatchCriterion(player, row) && _doesPlayerMatchCriterion(player, col);
  }

  List<PlayerModel> getValidPlayersForCell(GridCriterion row, GridCriterion col) {
    return _players.where((p) => validateGridCell(row, col, p)).toList();
  }

  // --- FUTBOL KÖPRÜSÜ (SIX DEGREES OF FOOTBALL) ---

  /// Find all clubs where BOTH player A and player B played
  List<ClubModel> findAllSharedClubs(PlayerModel a, PlayerModel b) {
    final shared = <ClubModel>[];
    for (final cId in a.clubIds) {
      if (b.clubIds.contains(cId) && _clubs.containsKey(cId)) {
        shared.add(_clubs[cId]!);
      }
    }
    return shared;
  }

  /// Find first shared club between two players, or null if none
  ClubModel? findSharedClub(PlayerModel a, PlayerModel b) {
    final all = findAllSharedClubs(a, b);
    return all.isNotEmpty ? all.first : null;
  }

  /// BFS shortest path of club connections between start and target player
  List<BridgeLink>? findShortestBridge(PlayerModel start, PlayerModel target) {
    if (start.id == target.id) return [];
    final directClub = findSharedClub(start, target);
    if (directClub != null) {
      return [
        BridgeLink(
          fromPlayer: start,
          sharedClub: directClub,
          toPlayer: target,
        ),
      ];
    }

    final visited = <String>{start.id};
    final queue = <List<BridgeLink>>[];

    // Seed queue with all 1-step neighbors of start
    for (final p in _players) {
      if (p.id == start.id) continue;
      final club = findSharedClub(start, p);
      if (club != null) {
        final link = BridgeLink(fromPlayer: start, sharedClub: club, toPlayer: p);
        if (p.id == target.id) return [link];
        visited.add(p.id);
        queue.add([link]);
      }
    }

    while (queue.isNotEmpty) {
      final path = queue.removeAt(0);
      if (path.length >= 4) continue; // Cap BFS depth at 4 links
      final lastPlayer = path.last.toPlayer;

      // Check if lastPlayer connects directly to target
      final clubToTarget = findSharedClub(lastPlayer, target);
      if (clubToTarget != null) {
        return [
          ...path,
          BridgeLink(
            fromPlayer: lastPlayer,
            sharedClub: clubToTarget,
            toPlayer: target,
          ),
        ];
      }

      for (final nextP in _players) {
        if (visited.contains(nextP.id)) continue;
        final shared = findSharedClub(lastPlayer, nextP);
        if (shared != null) {
          visited.add(nextP.id);
          queue.add([
            ...path,
            BridgeLink(fromPlayer: lastPlayer, sharedClub: shared, toPlayer: nextP),
          ]);
        }
      }
    }

    return null;
  }

  PlayerModel _playerById(String id) {
    return _players.firstWhere(
      (p) => p.id == id,
      orElse: () => _players.first,
    );
  }

  List<BridgeChallenge> getBridgeChallenges({GameDifficulty? difficulty}) {
    final curatedPairs = <Map<String, dynamic>>[
      // Easy (Many 1-step bridges)
      {
        'start': 'lionel_messi',
        'target': 'cristiano_ronaldo',
        'title': 'GOAT Köprüsü: Messi ↔ Ronaldo',
        'diff': GameDifficulty.easy,
      },
      {
        'start': 'arda_guler',
        'target': 'didier_drogba',
        'title': 'Real Madrid\'den Galatasaray Efsanesine',
        'diff': GameDifficulty.easy,
      },
      {
        'start': 'mauro_icardi',
        'target': 'cristiano_ronaldo',
        'title': 'Icardi ↔ Cristiano Ronaldo',
        'diff': GameDifficulty.easy,
      },
      {
        'start': 'erling_haaland',
        'target': 'lionel_messi',
        'title': 'Yeni Nesil Dev ↔ Messi',
        'diff': GameDifficulty.easy,
      },
      {
        'start': 'alex_de_souza',
        'target': 'ronaldo_nazario',
        'title': 'Kadıköy Kaptanı ↔ Fenomeno',
        'diff': GameDifficulty.medium,
      },
      {
        'start': 'hakan_calhanoglu',
        'target': 'thierry_henry',
        'title': 'Milli Kaptan ↔ Arsenal Kralı',
        'diff': GameDifficulty.medium,
      },
      {
        'start': 'arda_turan',
        'target': 'zinedine_zidane',
        'title': 'Arda Turan ↔ Zinedine Zidane',
        'diff': GameDifficulty.medium,
      },
      {
        'start': 'ricardo_quaresma',
        'target': 'wayne_rooney',
        'title': 'Trivela Ustası ↔ Old Trafford Efsanesi',
        'diff': GameDifficulty.medium,
      },
      {
        'start': 'kylian_mbappe',
        'target': 'gheorghe_hagi',
        'title': 'Mbappé ↔ Karpatların Maradonası',
        'diff': GameDifficulty.hard,
      },
      {
        'start': 'ugurcan_cakir',
        'target': 'zlatan_ibrahimovic',
        'title': 'Karadeniz Fırtınası ↔ Zlatan',
        'diff': GameDifficulty.hard,
      },
      {
        'start': 'fernando_muslera',
        'target': 'erling_haaland',
        'title': 'Muslera ↔ Erling Haaland',
        'diff': GameDifficulty.hard,
      },
      {
        'start': 'kenan_yildiz',
        'target': 'didier_drogba',
        'title': 'Torino\'nun Genç Yıldızı ↔ Drogba',
        'diff': GameDifficulty.hard,
      },
    ];

    final challenges = <BridgeChallenge>[];
    for (final item in curatedPairs) {
      final start = _playerById(item['start'] as String);
      final target = _playerById(item['target'] as String);
      final optimal = findShortestBridge(start, target);
      if (optimal != null && optimal.isNotEmpty) {
        challenges.add(
          BridgeChallenge(
            title: item['title'] as String,
            startPlayer: start,
            targetPlayer: target,
            optimalLinks: optimal,
            difficulty: item['diff'] as GameDifficulty,
          ),
        );
      }
    }

    if (difficulty != null) {
      final filtered = challenges.where((c) => c.difficulty == difficulty).toList();
      if (filtered.isNotEmpty) return filtered;
    }
    return challenges;
  }

  BridgeChallenge getRandomBridgeChallenge({
    GameDifficulty difficulty = GameDifficulty.medium,
  }) {
    final list = getBridgeChallenges(difficulty: difficulty);
    return list[_random.nextInt(list.length)];
  }

  // --- AÇIK ARTIRMA DÜELLOSU (AUCTION / BIDDING DUEL) ---

  List<AuctionCategory> getAuctionCategories() {
    return [
      AuctionCategory(
        id: 'super_lig_brazilians',
        title: 'Süper Lig\'de Forma Giymiş Brezilyalı Futbolcular',
        subtitle: 'Galatasaray, Fenerbahçe, Beşiktaş veya Trabzonspor\'da oynamış Sambacılar',
        badge: 'SÜPER LİG × BREZİLYA',
        validPlayers: _players
            .where(
              (p) =>
                  p.country == 'Brezilya' &&
                  (p.playedFor('galatasaray') ||
                      p.playedFor('fenerbahce') ||
                      p.playedFor('besiktas') ||
                      p.playedFor('trabzonspor')),
            )
            .toList(),
      ),
      AuctionCategory(
        id: 'ucl_winner_legends',
        title: 'Şampiyonlar Ligi Kupası Kazanmış Yıldızlar',
        subtitle: 'Kariyerinde en az 1 kez Devler Ligi zaferi yaşamış futbolcular',
        badge: 'DEVLER LİGİ ŞAMPİYONLARI',
        validPlayers: _players
            .where((p) => _uclWinners.contains(p.id) || p.hint.contains('Şampiyonlar Ligi'))
            .toList(),
      ),
      AuctionCategory(
        id: 'world_cup_winners',
        title: 'Dünya Kupası Şampiyonu Futbolcular',
        subtitle: 'Milli takımıyla Dünya Kupası\'nı kaldırmış efsaneler',
        badge: 'DÜNYA KUPASI ZAFERİ',
        validPlayers: _players.where((p) => _worldCupWinners.contains(p.id)).toList(),
      ),
      AuctionCategory(
        id: 'ballon_dor_winners',
        title: 'Ballon d\'Or (Altın Top) Kazanan Efsaneler',
        subtitle: 'Yılın en iyi futbolcusu ödülünü kazanmış isimler',
        badge: 'ALTIN TOP SAHİPLERİ',
        validPlayers: _players.where((p) => _ballonDorWinners.contains(p.id)).toList(),
      ),
      AuctionCategory(
        id: 'turkish_national_stars',
        title: 'Türkiye A Milli Takım Yıldızları',
        subtitle: 'Ay-Yıldızlı formayı terletmiş Türk futbolcular',
        badge: 'MİLLİ YILDIZLARIMIZ',
        validPlayers: _players.where((p) => p.country == 'Türkiye').toList(),
      ),
      AuctionCategory(
        id: 'real_madrid_stars',
        title: 'Real Madrid Forması Giymiş Yıldızlar',
        subtitle: 'Santiago Bernabéu\'da beyaz formayı terletmiş efsaneler',
        badge: 'LOS BLANCOS',
        validPlayers: _players.where((p) => p.playedFor('real_madrid')).toList(),
      ),
      AuctionCategory(
        id: 'galatasaray_legends',
        title: 'Galatasaray Forması Giymiş Yıldızlar',
        subtitle: 'Sarı-Kırmızılı parçalı formayı giymiş yerli ve yabancı yıldızlar',
        badge: 'ASLANLAR',
        validPlayers: _players.where((p) => p.playedFor('galatasaray')).toList(),
      ),
      AuctionCategory(
        id: 'fenerbahce_legends',
        title: 'Fenerbahçe Forması Giymiş Yıldızlar',
        subtitle: 'Kadıköy\'de çubuklu formayı terletmiş yerli ve yabancı yıldızlar',
        badge: 'SARI KANARYALAR',
        validPlayers: _players.where((p) => p.playedFor('fenerbahce')).toList(),
      ),
      AuctionCategory(
        id: 'besiktas_legends',
        title: 'Beşiktaş Forması Giymiş Yıldızlar',
        subtitle: 'Siyah-Beyazlı formayı giymiş yerli ve yabancı yıldızlar',
        badge: 'KARA KARTALLAR',
        validPlayers: _players.where((p) => p.playedFor('besiktas')).toList(),
      ),
      AuctionCategory(
        id: 'premier_league_scorers',
        title: 'İngiltere Premier League Devlerinde Oynamış Yıldızlar',
        subtitle: 'Man United, Man City, Arsenal, Chelsea veya Liverpool\'da oynamış isimler',
        badge: 'PREMIER LEAGUE',
        validPlayers: _players
            .where(
              (p) =>
                  p.playedFor('man_united') ||
                  p.playedFor('man_city') ||
                  p.playedFor('arsenal') ||
                  p.playedFor('chelsea') ||
                  p.playedFor('liverpool'),
            )
            .toList(),
      ),
      AuctionCategory(
        id: 'serie_a_giants',
        title: 'İtalya Serie A Devlerinde (Juve, Milan, Inter) Oynamış Yıldızlar',
        subtitle: 'Çizme\'nin üç büyük kulübünden en az birinde forma giymiş futbolcular',
        badge: 'SERIE A DEVLERİ',
        validPlayers: _players
            .where(
              (p) =>
                  p.playedFor('juventus') ||
                  p.playedFor('milan') ||
                  p.playedFor('inter'),
            )
            .toList(),
      ),
    ];
  }

  AuctionCategory getRandomAuctionCategory() {
    final cats = getAuctionCategories();
    return cats[_random.nextInt(cats.length)];
  }
}

class BridgeLink {
  final PlayerModel fromPlayer;
  final ClubModel sharedClub;
  final PlayerModel toPlayer;

  const BridgeLink({
    required this.fromPlayer,
    required this.sharedClub,
    required this.toPlayer,
  });
}

class BridgeChallenge {
  final String title;
  final PlayerModel startPlayer;
  final PlayerModel targetPlayer;
  final List<BridgeLink> optimalLinks;
  final GameDifficulty difficulty;

  const BridgeChallenge({
    required this.title,
    required this.startPlayer,
    required this.targetPlayer,
    required this.optimalLinks,
    required this.difficulty,
  });

  int get optimalIntermediateCount => (optimalLinks.length - 1).clamp(1, 10);
}

class AuctionCategory {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final List<PlayerModel> validPlayers;

  const AuctionCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.validPlayers,
  });
}
