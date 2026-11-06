import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isEmbedded;

  const ProfileScreen({super.key, this.isEmbedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _avatarCodes = ['KP', 'SC', 'ST', 'PM', 'DF', 'GK'];

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
    _selectedAvatar = (user != null && _avatarCodes.contains(user.avatar)) ? user.avatar : 'KP';
    _selectedTeam = user?.favoriteTeam ?? 'Galatasaray';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    context.read<AuthProvider>().updateProfile(
      username: _nameController.text.trim(),
      avatar: _selectedAvatar,
      favoriteTeam: _selectedTeam,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil güncellendi.'),
        backgroundColor: AppColors.pitchGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final winRate = user.matchesPlayed > 0
        ? ((user.matchesWon / user.matchesPlayed) * 100).toStringAsFixed(0)
        : '0';

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Profile Summary Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.pitchGreen, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    _selectedAvatar,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user.username,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.rankTitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tuttuğu Takım: ${user.favoriteTeam}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 4 Stats Grid
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Toplam XP', '${user.points}', Icons.star_outline, AppColors.gold),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard('Galibiyet Oranı', '%$winRate', Icons.trending_up, AppColors.silver),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Oynanan Maç', '${user.matchesPlayed}', Icons.sports_soccer_outlined, AppColors.silver),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard('Kazanma Serisi', '${user.currentStreak}', Icons.local_fire_department_outlined, AppColors.gold),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Edit Profile Form
        const Text(
          'Profil Ayarları',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 10),

        TextField(
          controller: _nameController,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            labelText: 'Kullanıcı Adı',
            prefixIcon: Icon(Icons.person_outline, color: AppColors.gold, size: 18),
          ),
        ),
        const SizedBox(height: 14),

        // Avatar selector
        const Text(
          'Profil Rolü / Kısaltması',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(_avatarCodes.length, (idx) {
            final code = _avatarCodes[idx];
            final isSelected = _selectedAvatar == code;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedAvatar = code),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.darkGreen : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.pitchGreen : AppColors.border,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      code,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.gold : AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 14),

        // Favorite Team
        const Text(
          'Tuttuğun Takım',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
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

        const SizedBox(height: 18),

        CustomButton(
          text: 'Değişiklikleri Kaydet',
          icon: Icons.check,
          backgroundColor: AppColors.pitchGreen,
          textColor: Colors.white,
          onPressed: _saveProfile,
        ),

        const SizedBox(height: 10),

        CustomButton(
          text: user.isGuest ? 'Kalıcı Hesap Aç / Giriş Yap' : 'Çıkış Yap',
          isOutlined: true,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
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
      padding: const EdgeInsets.all(12),
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
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              Icon(icon, color: color, size: 15),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
