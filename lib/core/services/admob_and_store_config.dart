import 'dart:io';
import 'package:flutter/foundation.dart';

/// Centralized configuration for Google AdMob and App Store / Google Play In-App Purchase.
/// Replace the production IDs below with your own AdMob Unit IDs before publishing.
class AdMobAndStoreConfig {
  /// Single Non-Consumable In-App Purchase Product ID (App Store Connect & Google Play Console)
  static const String adFreeProductId = 'futbol_trivia_remove_ads_lifetime';

  /// Replace with your production AdMob Banner Unit IDs when going live
  static const String _prodAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _prodIosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  /// Replace with your production AdMob Interstitial Unit IDs when going live
  static const String _prodAndroidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _prodIosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111'
          : _prodAndroidBannerId;
    } else if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/2934735716'
          : _prodIosBannerId;
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isAndroid) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/1033173712'
          : _prodAndroidInterstitialId;
    } else if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/4411468910'
          : _prodIosInterstitialId;
    }
    return '';
  }
}
