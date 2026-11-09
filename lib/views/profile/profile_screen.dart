import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../legal/privacy_and_terms_screen.dart';
import '../widgets/ad_free_banner_and_sheet.dart';
import '../widgets/app_notification.dart';
import '../widgets/custom_button.dart';
import '../widgets/language_selector_sheet.dart';
import '../widgets/player_avatar_widget.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isEmbedded;

  const ProfileScreen({super.key, this.isEmbedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _teams = [
    'Galatasaray',
    'Fenerbahçe',
    'Beşiktaş',
    'Trabzonspor',
    'Real Madrid',
    'Barcelona',
    'Arsenal',
    'Manchester City',
    'Manchester United',
    'Bayern Münih',
    'Paris Saint-Germain',
    'AC Milan',
    'Inter Milan',
    'Juventus',
    'Liverpool',
    'Chelsea',
  ];

  late TextEditingController _nameController;
  late String _selectedAvatar;
  late String _selectedTeam;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.username ?? 'Kaptan');
    _selectedAvatar = PlayerAvatarRegistry.resolve(user?.avatar ?? 'goat_10').id;
    _selectedTeam = user?.favoriteTeam ?? 'Galatasaray';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final preset = PlayerAvatarRegistry.resolve(_selectedAvatar);
    context.read<AuthProvider>().updateProfile(
      username: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Kaptan',
      avatar: _selectedAvatar,
      favoriteTeam: _selectedTeam,
    );
    AppNotification.show(
      context,
      title: 'Profil ve Futbolcu Avatarı Güncellendi',
      subtitle: '${_nameController.text.trim()} • ${preset.name} ($_selectedTeam) kaydedildi.',
      type: AppNotificationType.success,
      icon: Icons.verified_user_outlined,
    );
  }

  void _confirmDeleteAccount(BuildContext context, LocaleProvider loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0A2419),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.55)),
        ),
        title: Text(
          loc.t('delete_account_confirm_title'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        content: Text(
          loc.t('delete_account_confirm_sub'),
          style: const TextStyle(
            fontSize: 12.5,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              loc.t('cancel'),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().deleteAccount();
              if (context.mounted) {
                AppNotification.show(
                  context,
                  title: loc.t('delete_account_btn'),
                  subtitle: 'Hesabınız ve ilişkili tüm verileriniz kalıcı olarak silindi.',
                  type: AppNotificationType.warning,
                  icon: Icons.delete_forever_outlined,
                );
              }
            },
            child: Text(
              loc.t('confirm_delete'),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = context.watch<LocaleProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedPreset = PlayerAvatarRegistry.resolve(_selectedAvatar);
    final winRate = user.matchesPlayed > 0
        ? ((user.matchesWon / user.matchesPlayed) * 100).toStringAsFixed(0)
        : '0';

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile Summary Card with Illustrated Footballer Portrait
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              PlayerAvatarWidget(
                avatarKey: _selectedAvatar,
                size: 72,
                borderColor: AppColors.gold,
                borderWidth: 1.8,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5), width: 0.8),
                          ),
                          child: Text(
                            selectedPreset.name,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${selectedPreset.roleLabel} • ${user.rankTitle}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greenLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Tuttuğu Kulüp: ${user.favoriteTeam}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 4 Stats Grid
        Row(
          children: [
            Expanded(
              child: _buildStatCard(loc.t('stat_total_xp'), '${user.points}', Icons.star_outline, AppColors.gold),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(loc.t('stat_win_rate'), '%$winRate', Icons.trending_up, AppColors.greenLight),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(loc.t('stat_matches'), '${user.matchesPlayed}', Icons.sports_soccer_outlined, AppColors.silver),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(loc.t('stat_streak'), '${user.currentStreak}', Icons.local_fire_department_outlined, AppColors.gold),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // App Language Selector Card (10 Languages)
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => showLanguageSelectorSheet(context),
          child: Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.borderGreen.withValues(alpha: 0.55),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pitchGreen.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.pitchGreen, width: 0.9),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: AppColors.greenLight,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.t('language_label'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${loc.currentLanguage.nativeName} (${loc.currentLanguage.shortCode}) • 10 Dil',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.greenLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.gold,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Single Monetization Option: Ad-Free Mode Card
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF133626).withValues(alpha: 0.90),
                const Color(0xFF081B13).withValues(alpha: 0.92),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: user.isAdFree
                  ? AppColors.pitchGreen.withValues(alpha: 0.65)
                  : AppColors.gold.withValues(alpha: 0.55),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (user.isAdFree ? AppColors.pitchGreen : AppColors.gold)
                      .withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: user.isAdFree ? AppColors.pitchGreen : AppColors.gold,
                    width: 0.9,
                  ),
                ),
                child: Icon(
                  user.isAdFree ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                  color: user.isAdFree ? AppColors.greenLight : AppColors.gold,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.isAdFree
                          ? 'Reklamsız Mod Aktif'
                          : 'Reklamsız Mod (Tek Satın Alım)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.isAdFree
                          ? 'Uygulamadaki tüm reklamlar kalıcı olarak kapatıldı.'
                          : user.isGuest
                              ? 'Reklamsız Modu satın almak için önce ücretsiz kalıcı hesap oluşturmalısınız.'
                              : 'Oyun içi paket satışı yoktur; tek seferlik ödeme ile tüm reklamları kaldır.',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                borderRadius: BorderRadius.circular(9),
                onTap: () => showAdFreePurchaseSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: user.isAdFree
                        ? AppColors.pitchGreen.withValues(alpha: 0.20)
                        : AppColors.gold,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    user.isAdFree
                        ? 'Yönet'
                        : user.isGuest
                            ? 'Hesap Aç'
                            : '₺49,99',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: user.isAdFree ? AppColors.greenLight : const Color(0xFF071A12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Preset Footballer Avatar Picker Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'HAZIR FUTBOLCU AVATARI SEÇ',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
                color: AppColors.greenLight,
              ),
            ),
            Text(
              'Seçili: ${selectedPreset.name}',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.gold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: PlayerAvatarRegistry.presets.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            final preset = PlayerAvatarRegistry.presets[index];
            final isSelected = _selectedAvatar == preset.id;

            return GestureDetector(
              onTap: () => setState(() => _selectedAvatar = preset.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.darkGreen.withValues(alpha: 0.75)
                      : AppColors.surface.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.gold : AppColors.border,
                    width: isSelected ? 1.5 : 0.9,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PlayerAvatarWidget(
                      avatarKey: preset.id,
                      size: 46,
                      borderColor: isSelected ? AppColors.gold : AppColors.borderGreen,
                      borderWidth: isSelected ? 1.5 : 1.0,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      preset.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? AppColors.gold : Colors.white,
                      ),
                    ),
                    Text(
                      preset.roleLabel,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // Edit Profile Form
        const Text(
          'KULLANICI ADI & FAVORİ KULÜP',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
            color: AppColors.greenLight,
          ),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: _nameController,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            labelText: 'Kullanıcı Adı',
            prefixIcon: Icon(Icons.person_outline, color: AppColors.gold, size: 18),
          ),
        ),
        const SizedBox(height: 12),

        // Favorite Team
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _teams.contains(_selectedTeam) ? _selectedTeam : _teams.first,
              isExpanded: true,
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
              items: _teams.map((team) {
                return DropdownMenuItem<String>(
                  value: team,
                  child: Text(team, style: const TextStyle(color: Colors.white, fontSize: 13)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedTeam = val);
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        CustomButton(
          text: loc.t('save_changes'),
          icon: Icons.check_circle_outline,
          backgroundColor: AppColors.pitchGreen,
          textColor: Colors.white,
          onPressed: _saveProfile,
        ),

        const SizedBox(height: 10),

        CustomButton(
          text: user.isGuest ? loc.t('open_perm_account') : loc.t('logout_btn'),
          isOutlined: true,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),

        const SizedBox(height: 14),

        // Privacy Policy & Terms Link (App Store & Google Play Mandatory)
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyAndTermsScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.policy_outlined, size: 17, color: AppColors.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc.t('privacy_and_terms'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Delete Account Button (App Store Guideline 5.1.1(v) & Google Play Mandatory)
        TextButton.icon(
          onPressed: () => _confirmDeleteAccount(context, loc),
          icon: const Icon(Icons.delete_forever_outlined, size: 16, color: Colors.redAccent),
          label: Text(
            loc.t('delete_account_btn'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.redAccent,
            ),
          ),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Profil & İstatistikler', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: content,
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              ),
              Icon(icon, color: color, size: 15),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
