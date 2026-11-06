import 'dart:math';

enum PlayModeType {
  solo,
  onlineMatchmaking,
  friendInvite,
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
        return 'Ortak Oyuncu Düellosu';
      case GameTargetType.fiveClubs:
        return '5 Takım 1 Oyuncu';
      case GameTargetType.footballGrid:
        return 'Futbol Grid (3x3)';
    }
  }

  String get shortDescription {
    switch (this) {
      case GameTargetType.commonPlayer:
        return 'İki kulüpte de forma giymiş ortak efsaneleri bul.';
      case GameTargetType.fiveClubs:
        return '5 kulübün en çoğunda oynamış ortak futbolcuyu tahmin et.';
      case GameTargetType.footballGrid:
        return '3x3 kulüp kesişim matrisindeki hücreleri doğru oyuncularla doldur.';
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

  static OpponentProfile randomAiRival() {
    final random = Random();
    const rivals = [
      OpponentProfile(
        id: 'ai_1',
        name: 'TaktikDehası_10',
        avatar: 'TD',
        favoriteTeam: 'Galatasaray',
        rankTitle: 'Taktik Dehası',
        isAiFallback: true,
      ),
      OpponentProfile(
        id: 'ai_2',
        name: 'KadıköyBoğası',
        avatar: 'KB',
        favoriteTeam: 'Fenerbahçe',
        rankTitle: 'Usta Analist',
        isAiFallback: true,
      ),
      OpponentProfile(
        id: 'ai_3',
        name: 'KartalPençesi_1903',
        avatar: 'KP',
        favoriteTeam: 'Beşiktaş',
        rankTitle: 'Büyük Kaptan',
        isAiFallback: true,
      ),
      OpponentProfile(
        id: 'ai_4',
        name: 'KaradenizFırtınası',
        avatar: 'KF',
        favoriteTeam: 'Trabzonspor',
        rankTitle: 'Kadro Gurusu',
        isAiFallback: true,
      ),
      OpponentProfile(
        id: 'ai_5',
        name: 'ElClasico_Uzmanı',
        avatar: 'EC',
        favoriteTeam: 'Real Madrid',
        rankTitle: 'Avrupa Efsanesi',
        isAiFallback: true,
      ),
      OpponentProfile(
        id: 'ai_6',
        name: 'TikiTaka_Maestro',
        avatar: 'TM',
        favoriteTeam: 'Barcelona',
        rankTitle: 'Orta Saha Maestrosu',
        isAiFallback: true,
      ),
    ];
    return rivals[random.nextInt(rivals.length)];
  }
}
