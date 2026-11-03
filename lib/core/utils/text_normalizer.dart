class TextNormalizer {
  /// Normalizes a string for fuzzy football player name search
  /// e.g. "Mesut Özil" -> "mesut ozil"
  /// "Luka Modrić" -> "luka modric"
  /// "Gheorghe Hagi" -> "gheorghe hagi"
  static String normalize(String input) {
    if (input.isEmpty) return '';

    String result = input.toLowerCase().trim();

    const Map<String, String> charMap = {
      'ç': 'c', 'ğ': 'g', 'ı': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u',
      'İ': 'i', 'Ç': 'c', 'Ğ': 'g', 'Ö': 'o', 'Ş': 's', 'Ü': 'u',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
      'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
      'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
      'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ø': 'o',
      'ú': 'u', 'ù': 'u', 'û': 'u',
      'ñ': 'n',
      'ć': 'c', 'č': 'c',
      'š': 's',
      'ž': 'z',
      'đ': 'd',
      'ý': 'y', 'ÿ': 'y',
    };

    charMap.forEach((key, val) {
      result = result.replaceAll(key, val);
    });

    // Remove punctuation, dashes, quotes
    result = result.replaceAll(RegExp(r"[^\w\s]"), '');
    // Collapse multiple spaces
    result = result.replaceAll(RegExp(r'\s+'), ' ');

    return result.trim();
  }

  /// Checks if a query matches a player's full name or nickname
  static bool matches(String query, String fullName, [List<String>? aliases]) {
    final cleanQuery = normalize(query);
    if (cleanQuery.isEmpty) return false;

    final cleanName = normalize(fullName);
    if (cleanName == cleanQuery) return true;
    if (cleanName.contains(cleanQuery)) return true;

    // Check last name only (e.g. user typed "Ronaldo" or "Özil")
    final parts = cleanName.split(' ');
    for (var part in parts) {
      if (part == cleanQuery) return true;
    }

    if (aliases != null) {
      for (final alias in aliases) {
        final cleanAlias = normalize(alias);
        if (cleanAlias == cleanQuery || cleanAlias.contains(cleanQuery)) {
          return true;
        }
      }
    }

    return false;
  }
}
