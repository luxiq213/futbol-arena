import 'package:flutter_test/flutter_test.dart';
import 'package:futbol_party/core/utils/text_normalizer.dart';
import 'package:futbol_party/data/repositories/football_database.dart';

void main() {
  group('TextNormalizer tests', () {
    test('normalizes Turkish letters, diacritics and casing', () {
      expect(TextNormalizer.normalize('Hakan Çalhanoğlu'), 'hakan calhanoglu');
      expect(TextNormalizer.normalize('İlkay Gündoğan'), 'ilkay gundogan');
      expect(TextNormalizer.normalize('Şükrü Saracoğlu'), 'sukru saracoglu');
      expect(TextNormalizer.normalize('Zinédine ZIDANE'), 'zinedine zidane');
    });

    test('matches correctly matches fuzzy input queries and aliases', () {
      expect(TextNormalizer.matches('sneijder', 'Wesley Sneijder'), isTrue);
      expect(TextNormalizer.matches('hagi', 'Gheorghe Hagi'), isTrue);
      expect(TextNormalizer.matches('calhanoglu', 'Hakan Çalhanoğlu'), isTrue);
      expect(TextNormalizer.matches('ronaldo', 'Cristiano Ronaldo', ['CR7']), isTrue);
      expect(TextNormalizer.matches('CR7', 'Cristiano Ronaldo', ['CR7']), isTrue);
    });
  });

  group('FootballDatabase logic tests', () {
    final db = FootballDatabase();

    test('database contains comprehensive players', () {
      final players = db.getAllPlayers();
      expect(players.length, greaterThanOrEqualTo(100));
    });

    test('finds mutual players between Galatasaray and Real Madrid', () {
      final mutual = db.getMutualPlayers('galatasaray', 'real_madrid');
      expect(mutual.isNotEmpty, isTrue);
      final names = mutual.map((p) => p.name).toList();
      expect(names.contains('Wesley Sneijder'), isTrue);
      expect(names.contains('Gheorghe Hagi'), isTrue);
    });

    test('finds mutual players between Inter and Milan', () {
      final mutual = db.getMutualPlayers('inter', 'milan');
      expect(mutual.isNotEmpty, isTrue);
      final names = mutual.map((p) => p.name).toList();
      expect(names.contains('Zlatan Ibrahimović'), isTrue);
      expect(names.contains('Hakan Çalhanoğlu'), isTrue);
    });

    test('generates valid 5 Clubs challenge', () {
      final challenge = db.getRandom5ClubsChallenge();
      expect(challenge.clubs.length, 5);
      expect(challenge.bestAnswer.name.isNotEmpty, isTrue);
      expect(challenge.maxMatchCount, greaterThanOrEqualTo(3));
    });

    test('generates valid 3x3 Grid challenge', () {
      final grid = db.getRandom3x3GridChallenge();
      expect(grid.rowCriteria.length, 3);
      expect(grid.colCriteria.length, 3);

      final validPlayers = db.getValidPlayersForCell(
        grid.rowCriteria[0],
        grid.colCriteria[0],
      );
      expect(validPlayers, isA<List>());
    });

    test('searchPlayers returns matches with accents and lowercase query', () {
      final results = db.searchPlayers('ozil');
      expect(results.any((p) => p.name == 'Mesut Özil'), isTrue);

      final ardResults = db.searchPlayers('arda');
      expect(ardResults.any((p) => p.name.contains('Arda')), isTrue);

      final neymarResults = db.searchPlayers('neymar');
      expect(neymarResults.any((p) => p.id == 'neymar'), isTrue);

      final irfanSpaceless = db.searchPlayers('irfancan');
      expect(irfanSpaceless.any((p) => p.id == 'irfan_can_kahveci'), isTrue);

      final mbappeResults = db.searchPlayers('mbappe');
      expect(mbappeResults.any((p) => p.id == 'kylian_mbappe'), isTrue);
    });
  });
}
