import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/stadium_background.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedAvatar = '👑';
  String _selectedTeam = 'Galatasaray';

  final List<String> _avatars = ['👑', '⚡', '🦁', '🦅', '🎯', '⚽', '🔥', '🧤'];
  final List<String> _teams = [
    'Galatasaray',
    'Fenerbahçe',
    'Beşiktaş',
    'Trabzonspor',
    'Real Madrid',
    'Barcelona',
    'Arsenal',
    'Manchester City',
    'Bayern Münih',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun.'),
          backgroundColor: AppColors.crimson,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      username: username,
      email: email,
      password: password,
      favoriteTeam: _selectedTeam,
      avatar: _selectedAvatar,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Hesap Oluştur', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: StadiumBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Futbolculuk Lisansını Al!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Profilini oluştur, puanlarını biriktir ve arkadaş sıralamasında zirveye çık.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 24),

              // USERNAME
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Kullanıcı Adı / Lakap',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.pitchGreen),
                ),
              ),

              const SizedBox(height: 14),

              // EMAIL
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.pitchGreen),
                ),
              ),

              const SizedBox(height: 14),

              // PASSWORD
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: Icon(Icons.lock_outline, color: AppColors.pitchGreen),
                ),
              ),

              const SizedBox(height: 18),

              // AVATAR PICKER
              const Text(
                'Profil Karakteri',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
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
                        width: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.pitchGreen : AppColors.surface,
                          border: Border.all(
                            color: isSelected ? AppColors.pitchGreen : AppColors.cardBorder,
                          ),
                        ),
                        child: Center(
                          child: Text(av, style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // FAVORITE TEAM
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
                    value: _selectedTeam,
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

              const SizedBox(height: 28),

              // REGISTER BUTTON
              CustomButton(
                text: 'Hesap Oluştur ve Başla',
                gradient: AppColors.pitchGradient,
                textColor: Colors.black87,
                isLoading: auth.isLoading,
                onPressed: _onRegister,
              ),

              const SizedBox(height: 16),

              // LOGIN REDIRECT
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Zaten hesabın var mı?',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Giriş Yap',
                      style: TextStyle(
                        color: AppColors.pitchGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
