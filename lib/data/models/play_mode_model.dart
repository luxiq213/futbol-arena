import 'dart:math';

enum PlayModeType {
  solo,
  onlineMatchmaking,
  friendInvite,
}

enum GameDifficulty {
  easy,
  medium,
  hard,
}

enum CommonPlayerPairMode {
  clubVsClub,
  clubVsCountry,
  mixed,
}

extension CommonPlayerPairModeExtension on CommonPlayerPairMode {
  String get label {
    switch (this) {
      case CommonPlayerPairMode.clubVsClub:
        return 'Takım × Takım';
      case CommonPlayerPairMode.clubVsCountry:
        return 'Takım × Ülke';
      case CommonPlayerPairMode.mixed:
        return 'Karışık';
    }
  }

  String get shortTag {
    switch (this) {
      case CommonPlayerPairMode.clubVsClub:
        return 'KULÜP × KULÜP';
      case CommonPlayerPairMode.clubVsCountry:
        return 'KULÜP × ÜLKE';
      case CommonPlayerPairMode.mixed:
        return 'KARIŞIK FORMAT';
    }
  }

  String get description {
    switch (this) {
      case CommonPlayerPairMode.clubVsClub:
        return 'Her iki kulüpte de forma giymiş ortak futbolcuları bul (Örn: Galatasaray × Real Madrid).';
      case CommonPlayerPairMode.clubVsCountry:
        return 'O kulüpte oynamış ve o ülkenin vatandaşı olan yıldızları bul (Örn: Fenerbahçe × Brezilya).';
      case CommonPlayerPairMode.mixed:
        return 'Hem Takım × Takım hem de Takım × Ülke eşleşmeleri karışık olarak karşına çıkar.';
    }
  }
}

extension GameDifficultyExtension on GameDifficulty {
  String get label {
    switch (this) {
      case GameDifficulty.easy:
        return 'Kolay';
      case GameDifficulty.medium:
        return 'Orta';
      case GameDifficulty.hard:
        return 'Zor';
    }
  }

  String get badgeText {
    switch (this) {
      case GameDifficulty.easy:
        return 'AMATÖR • 1.0x XP';
      case GameDifficulty.medium:
        return 'PROFESYONEL • 1.2x XP';
      case GameDifficulty.hard:
        return 'EFSANE • 1.5x XP';
    }
  }

  String get description {
    switch (this) {
      case GameDifficulty.easy:
        return 'Popüler kulüp eşleşmeleri (4+ ortak oyuncu), Grid\'de 12 hak.';
      case GameDifficulty.medium:
        return 'Dengeli kulüp eşleşmeleri (2-4 ortak oyuncu), Grid\'de 9 hak.';
      case GameDifficulty.hard:
        return 'Nadir kesişimler (1-2 ortak oyuncu), Grid\'de 6 hak ve 1.5x puan!';
    }
  }

  double get pointsMultiplier {
    switch (this) {
      case GameDifficulty.easy:
        return 1.0;
      case GameDifficulty.medium:
        return 1.2;
      case GameDifficulty.hard:
        return 1.5;
    }
  }

  int get gridGuessesAllowed {
    switch (this) {
      case GameDifficulty.easy:
        return 12;
      case GameDifficulty.medium:
        return 9;
      case GameDifficulty.hard:
        return 6;
    }
  }

  double get aiAccuracyChance {
    switch (this) {
      case GameDifficulty.easy:
        return 0.45;
      case GameDifficulty.medium:
        return 0.68;
      case GameDifficulty.hard:
        return 0.88;
    }
  }
}

enum GameTargetType {
  commonPlayer,
  fiveClubs,
  footballGrid,
}

extension GameTargetTypeExtension on GameTargetType {
  String get title {
    switch (this) {
      case GameTargetType.commonPlayer:
        return 'Ortak Oyuncu (3-2-1)';
      case GameTargetType.fiveClubs:
        return '5 Takım 1 Oyuncu';
      case GameTargetType.footballGrid:
        return 'Futbol Grid (3x3)';
    }
  }

  String get shortDescription {
    switch (this) {
      case GameTargetType.commonPlayer:
        return 'Takım × Takım veya Takım × Ülke kesişimlerinde ortak efsaneleri bul.';
      case GameTargetType.fiveClubs:
        return '5 kulübün en çoğunda oynamış ortak futbolcuyu tahmin et.';
      case GameTargetType.footballGrid:
        return '3x3 kulüp, kupa ve milli takım kesişim matrisini doğru oyuncularla doldur.';
    }
  }
}

class OpponentProfile {
  final String id;
  final String name;
  final String avatar;
  final String favoriteTeam;
  final String rankTitle;
  final bool isAiFallback;

  const OpponentProfile({
    required this.id,
    required this.name,
    required this.avatar,
    required this.favoriteTeam,
    this.rankTitle = 'Usta Analist',
    this.isAiFallback = true,
  });

  String get modeBadgeLabel => isAiFallback ? 'Yapay Zeka Rakip' : 'Arkadaş Düellosu';

  static OpponentProfile randomAiRival({GameDifficulty difficulty = GameDifficulty.medium}) {
    final random = Random();
    final rankByDiff = difficulty == GameDifficulty.hard
        ? 'Efsane Analist'
        : (difficulty == GameDifficulty.medium ? 'Profesyonel' : 'Genç Yetenek');

    final rivals = [
      OpponentProfile(
        id: 'ai_1',
        name: 'TaktikDehası_10',
        avatar: 'TD',
        favoriteTeam: 'Galatasaray',
        rankTitle: rankByDiff,
        isAiFallback: true,
      ),
      OpponentProfile(
        id: 'ai_2',
        name: 'KadıköyBoğası',
        avatar: 'KB',
        favoriteTeam: 'Fenerbahçe',
        rankTitle: rankByDiff,
        isAiFallback: true,
      ),
      OpponentProfile(
        id: 'ai_3',
        name: 'KartalPençesi_1903',
        avatar: 'KP',
        favoriteTeam: 'Beşiktaş',
        rankTitle: rankByDiff,
        isAiFallback: true,
      ),
      OpponentProfile(
        id: 'ai_4',
        name: 'KaradenizFırtınası',
        avatar: 'KF',
        favoriteTeam: 'Trabzonspor',
        rankTitle: rankByDiff,
        isAiFallback: true,
      ),
      OpponentProfile(
        id: 'ai_5',
        name: 'ElClasico_Uzmanı',
        avatar: 'EC',
        favoriteTeam: 'Real Madrid',
        rankTitle: rankByDiff,
        isAiFallback: true,
      ),
      OpponentProfile(
        id: 'ai_6',
        name: 'TikiTaka_Maestro',
        avatar: 'TM',
        favoriteTeam: 'Barcelona',
        rankTitle: rankByDiff,
        isAiFallback: true,
      ),
    ];
    return rivals[random.nextInt(rivals.length)];
  }
}
