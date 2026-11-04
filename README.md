# ⚽ Futbol Party (Mobile Football Party Game)

Arkadaş grupları için tasarlanmış, hem aynı masada/yan yana hem de online odalar kurularak oynanabilen **Flutter tabanlı (iOS & Android)** futbol bilgi ve parti oyunu.

---

## 🎮 Mevcut Oyun Modları & Özellikler

### 1. 💣 3-2-1 Bomba! (Yan Yana / Pass & Play)
- **Konsept:** Arkadaşlar yan yana otururken telefon sırayla elden ele geçer veya masanın ortasına konur.
- **Akış:**
  - 3... 2... 1... geri sayım başlar (titreşim & ses efektleri ile).
  - Ekranda 2 rastgele dev kulüp belirir (Örn: *Real Madrid* & *Arsenal* veya *Galatasaray* & *Inter*).
  - Sırası gelen oyuncu süre bitmeden (5, 8, 10 veya 15 saniye) bu iki kulüpte birden oynamış ortak futbolcuyu sesli olarak söyler!
  - `BİLDİ! ✅` (+100 XP) veya `PAS / YANDI ❌` (-1 Can).
  - Canları bitenler elenir, son hayatta kalan şampiyon ilan edilir ve konfetiler patlar!

### 2. ⚽ Ortak Futbolcu (Klasik Meydan Okuma)
- Ekranda 2 kulüp arması, renkleri ve lig detaylarıyla görüntülenir.
- Akıllı oyuncu arama çubuğu (Türkçe karakter ve özel harf duyarsız, örneğin "ozil", "özil", "ronaldo", "ibrahimovic").
- Bulunan efsaneler listelenir, ipucu sistemi ve pes edenler için tüm ortak oyuncuları gösteren detay sayfası mevcuttur.

### 3. 🌐 Online Meydan Okuma (Lobi & Oda Sistemi)
- 6 haneli özel oda kodu oluşturma (Örn: `FTB782`).
- Kodu arkadaşına WhatsApp veya mesajla göndererek aynı odaya bağlanma.
- Lobi durumu, oyuncu hazır kontrolleri ve canlı maç başlatma altyapısı.

### 4. 🏆 Sıralama & Liderlik Tablosu (Leaderboard)
- **Genel Sıralama:** Global oyuncuların sıralaması ve kürsü (1., 2., 3. madalyaları).
- **Arkadaşlarım Sıralaması:** Arkadaşlar arasındaki güncel puanlar, galibiyetler ve lig unvanları.
- Oyuncunun kendi sıralaması özel yeşil neon vurguyla gösterilir.

### 5. 👤 Hesap Oluşturma & Profil Yönetimi
- E-posta/şifre ile kayıt olma ve giriş yapma.
- **Hemen Oyna (Misafir Modu):** Kayıt olmadan anında oyuna giriş imkanı.
- Karakter avatarları seçimi (⚽, 👑, ⚡, 🦅, 🦁, 🎯, 🔥 vb.).
- Tuttuğu takımı seçme (Galatasaray, Fenerbahçe, Beşiktaş, Trabzonspor, Real Madrid, Barcelona vb.).
- Detaylı istatistikler: Toplam XP, Galibiyet Oranı %, Oynanan Maç, Galibiyet Serisi (Streak).

---

## 🏗️ Mimari & Proje Yapısı

```
lib/
├── core/
│   ├── constants/       # AppColors (Stadyum teması), AppStrings
│   ├── theme/           # Google Fonts (Poppins), Karanlık stadyum teması
│   └── utils/           # TextNormalizer (Türkçe fuzzy eşleşme), GameFeedback (Haptik titreşim)
├── data/
│   ├── models/          # ClubModel, PlayerModel, UserModel, LeaderboardEntry, GameRoomModel
│   └── repositories/    # FootballDatabase (150+ ortak futbolcu & dev kulüpler), AuthRepository, LeaderboardRepository
├── providers/           # Provider State Management
│   ├── auth_provider.dart
│   ├── common_player_game_provider.dart
│   ├── party_mode_game_provider.dart
│   ├── online_room_provider.dart
│   └── leaderboard_provider.dart
├── views/
│   ├── auth/            # Login, Register
│   ├── home/            # Ana Menü, Oyun Modu Kartları, Gelecek Modlar Alanı
│   ├── games/
│   │   ├── common_player/   # Ortak Oyuncu Quiz ekranı & widget'ları
│   │   ├── party_mode/      # 3-2-1 Bomba Kurulum, Oyun ve Şampiyon ekranı
│   │   └── online_lobby/    # Oda kurma, katılma ve aktif lobi
│   ├── leaderboard/     # Genel & Arkadaşlar Liderlik Tablosu
│   └── profile/         # Profil, Takım & Avatar seçimi, İstatistikler
└── main.dart
```

---

## 🚀 Nasıl Çalıştırılır?

### Mobil Cihazda (Android / iOS):
```bash
# Android için (Emülatör veya USB bağlı telefon):
flutter run

# iOS için (Mac ortamında Xcode / Simülatör):
flutter run -d ios
```

### Tarayıcıda Hızlı Test (Chrome / Edge):
```bash
flutter run -d chrome
```

---

## 🔮 Sonraki Adımlarda Eklenecek Modlar İçin Hazır Alanlar:
Uygulamanın ana ekranında **"Yakında Gelecek Modlar"** bölümü modüler olarak bırakılmıştır. Dilediğin diğer oyun fikirlerini (Kariyer yolu, Transfer bedeli bilme, 11'i tamamlama vb.) tek bir dosya ile doğrudan ekleyebiliriz!
