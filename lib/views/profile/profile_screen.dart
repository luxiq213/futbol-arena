import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/stadium_background.dart';
import '../widgets/custom_button.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final List<String> _avatars = ['⚽', '👑', '🦁', '🦅', '⚡', '🔥', '🎯', '🚀', '⭐', '🧤'];
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
    _nameController = TextEditingController(text: user?.username ?? 'Futbolcu');
    _selectedAvatar = user?.avatar ?? '⚽';
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
        content: Text('Profil güncellendi! ✅'),
        backgroundColor: AppColors.pitchGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final winRate = user.matchesPlayed > 0
        ? ((user.matchesWon / user.matchesPlayed) * 100).toStringAsFixed(0)
        : '0';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Profilim & İstatistikler',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: StadiumBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // PROFILE HEADER CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    // Avatar with edit glow
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceLight,
                        border: Border.all(color: AppColors.pitchGreen, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.pitchGreen.withOpacity(0.3),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(_selectedAvatar, style: const TextStyle(fontSize: 40)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Rank Title Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                      ),
                      child: Text(
                        user.rankTitle,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tuttuğu Takım: ${user.favoriteTeam}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // STATS GRID
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Toplam XP', '${user.points}', Icons.stars, AppColors.gold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard('Galibiyet Oranı', '%$winRate', Icons.speed, AppColors.pitchGreen),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Oynanan Maç', '${user.matchesPlayed}', Icons.sports_soccer, AppColors.electricBlue),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard('Galibiyet Serisi', '${user.currentStreak} 🔥', Icons.local_fire_department, AppColors.orange),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // EDIT PROFILE SECTION
              const Text(
                'Profili Düzenle',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Username input
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı Adı',
                  prefixIcon: Icon(Icons.person, color: AppColors.pitchGreen),
                ),
              ),
              const SizedBox(height: 16),

              // Avatar picker
              const Text(
                'Avatar Seç',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatars.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final av = _avatars[index];
                    final isSelected = _selectedAvatar == av;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = av),
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.pitchGreen : AppColors.surface,
                          border: Border.all(
                            color: isSelected ? AppColors.pitchGreen : AppColors.cardBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(av, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Favorite Team Dropdown
              const Text(
                'Tuttuğun Takım',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _teams.contains(_selectedTeam) ? _selectedTeam : _teams.first,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.pitchGreen),
                    items: _teams.map((team) {
                      return DropdownMenuItem<String>(
                        value: team,
                        child: Text(team, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTeam = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Save Button
              CustomButton(
                text: 'Değişiklikleri Kaydet',
                icon: Icons.check,
                gradient: AppColors.pitchGradient,
                textColor: Colors.black87,
                onPressed: _saveProfile,
              ),

              const SizedBox(height: 14),

              // Switch Account / Logout
              CustomButton(
                text: user.isGuest ? 'Kalıcı Hesap Oluştur / Giriş Yap' : 'Çıkış Yap',
                isOutlined: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
