/// Central configuration for Supabase Free Tier, Apple StoreKit (IAP), AdMob, and Store URLs.
class AppConfig {
  AppConfig._();

  /// Supabase Project URL (e.g. 'https://xyzcompany.supabase.co')
  /// Can be passed via `--dart-define=SUPABASE_URL=...` or pasted directly here.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase Anonymous Public Key
  /// Can be passed via `--dart-define=SUPABASE_ANON_KEY=...` or pasted directly here.
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// True when valid Supabase project credentials are provided.
  /// When false, the app seamlessly uses local offline/fallback mode.
  static bool get isSupabaseConfigured =>
      supabaseUrl.trim().isNotEmpty &&
      supabaseAnonKey.trim().isNotEmpty &&
      supabaseUrl.startsWith('http');

  /// Apple App Store Connect & Google Play Console Non-Consumable Product ID
  /// for permanent Ad-Free Mode.
  static const String adFreeProductId = 'com.futbol.party.ad_free_lifetime';

  /// Set to false if you want to ship v1.0 completely ad-free without IAP/Ad banners,
  /// or leave true when StoreKit product `com.futbol.party.ad_free_lifetime` is added in App Store Connect.
  static const bool enableAdsAndIapInStoreBuild = true;

  /// Public Privacy Policy & Support URLs for App Store Connect metadata
  static const String privacyPolicyUrl = 'https://futbolparty.app/privacy';
  static const String termsOfUseUrl = 'https://futbolparty.app/terms';
  static const String supportEmail = 'destek@futbolparty.app';
}
