import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/stadium_background.dart';
import '../widgets/custom_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen e-posta ve şifrenizi girin.'),
          backgroundColor: AppColors.crimson,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(email, pass);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
    }
  }

  void _onGuestPlay() async {
    final auth = context.read<AuthProvider>();
    await auth.loginAsGuest();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Giriş Yap', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: StadiumBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // Logo / Icon
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.pitchGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.pitchGreen.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('⚽', style: TextStyle(fontSize: 44)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Futbol Party\'ye Hoş Geldin!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Arkadaşlarınla futbol bilgini yarıştırmak için giriş yap.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),

              const SizedBox(height: 32),

              // EMAIL INPUT
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'E-posta veya Kullanıcı Adı',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.pitchGreen),
                ),
              ),

              const SizedBox(height: 16),

              // PASSWORD INPUT
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.pitchGreen),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // LOGIN BUTTON
              CustomButton(
                text: 'Giriş Yap',
                gradient: AppColors.pitchGradient,
                textColor: Colors.black87,
                isLoading: auth.isLoading,
                onPressed: _onLogin,
              ),

              const SizedBox(height: 12),

              // GUEST LOGIN BUTTON
              CustomButton(
                text: 'Hemen Misafir Olarak Oyna',
                isOutlined: true,
                icon: Icons.flash_on,
                isLoading: auth.isLoading,
                onPressed: _onGuestPlay,
              ),

              const SizedBox(height: 28),

              // REGISTER REDIRECT
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hesabın yok mu?',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Kayıt Ol',
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
