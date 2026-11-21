import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../widgets/app_notification.dart';
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
  bool _awaitingOAuthSignIn = false;

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
      AppNotification.show(
        context,
        title: 'Eksik Bilgi',
        message: 'Lütfen e-posta adresinizi ve şifrenizi eksiksiz girin.',
        type: AppNotificationType.error,
        icon: Icons.warning_amber_rounded,
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

  void _onAppleLogin() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.loginWithApple();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      AppNotification.show(
        context,
        title: 'Apple ile Giriş Yapılamadı',
        message: 'İşlem iptal edildi veya tamamlanamadı.',
        type: AppNotificationType.warning,
        icon: Icons.apple,
      );
    }
  }

  void _onGoogleLogin() async {
    _awaitingOAuthSignIn = true;
    final auth = context.read<AuthProvider>();
    final launched = await auth.loginWithGoogle();
    if (!mounted) return;
    if (!launched) {
      _awaitingOAuthSignIn = false;
      AppNotification.show(
        context,
        title: 'Google ile Giriş Yapılamadı',
        message: 'Bağlantı başlatılamadı, lütfen tekrar deneyin.',
        type: AppNotificationType.error,
        icon: Icons.g_mobiledata_rounded,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAppleDevice = defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    // Auto-close LoginScreen only when an active Google OAuth flow completes
    if (_awaitingOAuthSignIn &&
        auth.currentUser != null &&
        !auth.currentUser!.isGuest &&
        !auth.isLoading) {
      _awaitingOAuthSignIn = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Giriş Yap', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: StadiumBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              // App Emblem / Vector Badge
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.borderActive, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield_outlined,
                      color: AppColors.gold,
                      size: 38,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Futbol Arena',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
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
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'E-posta veya Kullanıcı Adı',
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

              const SizedBox(height: 16),

              // PASSWORD INPUT
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Şifre',
                  labelStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.gold),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
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

              const SizedBox(height: 24),

              // LOGIN BUTTON
              CustomButton(
                text: 'Giriş Yap',
                backgroundColor: AppColors.pitchGreen,
                textColor: AppColors.textPrimary,
                isLoading: auth.isLoading,
                onPressed: _onLogin,
              ),

              const SizedBox(height: 12),

              // GUEST LOGIN BUTTON
              CustomButton(
                text: 'Misafir Olarak Devam Et',
                isOutlined: true,
                icon: Icons.bolt_outlined,
                isLoading: auth.isLoading,
                onPressed: _onGuestPlay,
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'VEYA HIZLI GİRİŞ',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (isAppleDevice) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: auth.isLoading ? null : _onAppleLogin,
                  icon: const Icon(Icons.apple, size: 22),
                  label: const Text(
                    'Apple ile Devam Et',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],

              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.surface.withValues(alpha: 0.92),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: auth.isLoading ? null : _onGoogleLogin,
                icon: const Icon(
                  Icons.g_mobiledata_rounded,
                  color: AppColors.gold,
                  size: 26,
                ),
                label: const Text(
                  'Google ile Devam Et',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
