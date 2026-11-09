import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/l10n/app_strings.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefKey = 'futbol_party_language_code';
  String _languageCode = 'tr';

  String get languageCode => _languageCode;

  SupportedLanguage get currentLanguage {
    return AppStrings.supportedLanguages.firstWhere(
      (l) => l.code == _languageCode,
      orElse: () => AppStrings.supportedLanguages.first,
    );
  }

  LocaleProvider() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null &&
        AppStrings.supportedLanguages.any((l) => l.code == saved)) {
      _languageCode = saved;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String code) async {
    if (!AppStrings.supportedLanguages.any((l) => l.code == code)) return;
    if (_languageCode == code) return;
    _languageCode = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, code);
  }

  String t(String key) => AppStrings.tr(key, _languageCode);
}
