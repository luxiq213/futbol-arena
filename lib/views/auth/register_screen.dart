import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/app_notification.dart';
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
  String _selectedAvatar = 'KP';
  String _selectedTeam = 'Galatasaray';

  final List<String> _avatars = ['KP', 'SC', 'ST', 'OR', 'DF', 'KL', 'TR', 'YD'];
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
    'Inter',
    'Milan',
    'Liverpool',
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
      AppNotification.show(
        context,
        title: 'Eksik Bilgi',
        message: 'Lütfen kullanıcı adı, e-posta ve şifre alanlarını eksiksiz doldurun.',
        type: AppNotificationType.error,
        icon: Icons.warning_amber_rounded,
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
        title: const Text('Hesap Oluştur', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StadiumBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Oyuncu Profilini Oluştur',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
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
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Kullanıcı Adı / Lakap',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.gold),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gold),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // EMAIL
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.mail_outline, color: AppColors.gold),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gold),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // PASSWORD
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.gold),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.gold),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // MONOGRAM AVATAR PICKER
              const Text(
                'Profil Monogramı',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatars.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final av = _avatars[index];
                    final isSelected = _selectedAvatar == av;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = av),
                      child: Container(
                        width: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? AppColors.darkGreen : AppColors.surface,
                          border: Border.all(
                            color: isSelected ? AppColors.pitchGreen : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            av,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.gold : AppColors.silver,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 18),

              // FAVORITE TEAM
              const Text(
                'Favori Takım',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTeam,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gold),
                    items: _teams.map((team) {
                      return DropdownMenuItem<String>(
                        value: team,
                        child: Text(team, style: const TextStyle(color: AppColors.textPrimary)),
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
                backgroundColor: AppColors.pitchGreen,
                textColor: AppColors.textPrimary,
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
                        color: AppColors.gold,
                        fontWeight: FontWeight.w700,
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
