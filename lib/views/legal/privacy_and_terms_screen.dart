import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../widgets/stadium_background.dart';

class PrivacyAndTermsScreen extends StatelessWidget {
  const PrivacyAndTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Gizlilik Politikası ve Koşullar',
          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
        ),
      ),
      body: StadiumBackground(
        showLiveMatch: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                icon: Icons.shield_outlined,
                title: '1. Genel Bilgilendirme ve Veri Sorumlusu',
                body:
                    'Futbol Trivia ("Uygulama"), futbol bilgi yarışması ve kariyer simülasyonu deneyimi sunan bir mobil oyundur. Kullanıcı gizliliği hem KVKK hem GDPR hem de Apple App Store ve Google Play Store mağaza standartlarına uygun olarak korunmaktadır.',
              ),
              const SizedBox(height: 10),
              _buildSectionCard(
                icon: Icons.storage_rounded,
                title: '2. Toplanan Veriler ve Kullanım Amacı',
                body:
                    '• Hesap Bilgileri: Kayıt olmanız durumunda yalnızca belirlediğiniz kullanıcı adı, e-posta adresi, seçtiğiniz avatar ve favori takım bilgisi profilinizi ve sıralama tablosundaki (Leaderboard) puanınızı senkronize etmek için saklanır.\n'
                    '• Misafir Modu: Hesap oluşturmadan Misafir olarak oynadığınızda verileriniz yalnızca cihazınızda (SharedPreferences) yerel olarak tutulur.\n'
                    '• Satın Alım Durumu: Uygulamadaki tek satın alım seçeneği olan "Reklamsız Mod" hakkınızın cihaz değiştirdiğinizde korunabilmesi için kalıcı hesabınızla ilişkilendirilir.',
              ),
              const SizedBox(height: 10),
              _buildSectionCard(
                icon: Icons.ads_click_rounded,
                title: '3. Google AdMob ve Reklam Hizmetleri',
                body:
                    'Ücretsiz sürümde uygulama içi banner ve oyun sonu geçiş reklamları için Google AdMob altyapısı kullanılmaktadır. Google AdMob, reklam gösterimi ve frekans sınırlandırması için cihazınızın reklam kimliğini (Advertising ID / IDFA) işleyebilir. "Reklamsız Mod" satın alındığında tüm reklam istekleri ve gösterimleri kalıcı olarak durdurulur.',
              ),
              const SizedBox(height: 10),
              _buildSectionCard(
                icon: Icons.workspace_premium_outlined,
                title: '4. Uygulama İçi Satın Alımlar ve Geri Yükleme',
                body:
                    'Uygulamada şans kutusu, altın paketi veya abonelik satışı bulunmamaktadır. Tek satın alım seçeneği ömür boyu geçerli "Reklamsız Mod"dur. Ödemeler doğrudan Apple App Store veya Google Play Store güvenli ödeme altyapısı üzerinden gerçekleşir; kredi kartı bilgileriniz tarafımızca görülmez veya saklanmaz. Cihaz değiştirdiğinizde "Satın Alımı Geri Yükle (Restore Purchases)" butonuyla hakkınızı ücretsiz geri yükleyebilirsiniz.',
              ),
              const SizedBox(height: 10),
              _buildSectionCard(
                icon: Icons.delete_forever_outlined,
                title: '5. Hesap ve Veri Silme Hakkı (Right to Erasure)',
                body:
                    'Kullanıcılarımız istedikleri anda uygulama içerisindeki "Profil > Hesabımı Kalıcı Olarak Sil" butonunu kullanarak hesaplarını, kullanıcı adlarını, e-posta kayıtlarını ve tüm oyun istatistiklerini anında ve geri döndürülemez biçimde silebilirler.',
              ),
              const SizedBox(height: 10),
              _buildSectionCard(
                icon: Icons.gavel_rounded,
                title: '6. Telif Hakları ve Bağımsızlık Beyanı',
                body:
                    'Bu uygulamadaki kulüp renkleri, kalkan tasarımları, futbolcu kariyer verileri ve illüstrasyonlar tamamen bağımsız trivia/bilgi yarışması amacıyla oluşturulmuştur. Hiçbir resmi futbol federasyonu, lig veya kulüp ile doğrudan bağlantılı veya sponsorlu değildir.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
