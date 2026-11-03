import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/online_room_provider.dart';
import '../../widgets/stadium_background.dart';
import '../../widgets/custom_button.dart';
import 'active_room_screen.dart';

class LobbyHubScreen extends StatefulWidget {
  const LobbyHubScreen({super.key});

  @override
  State<LobbyHubScreen> createState() => _LobbyHubScreenState();
}

class _LobbyHubScreenState extends State<LobbyHubScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _onCreateRoom() async {
    final auth = context.read<AuthProvider>();
    final roomProvider = context.read<OnlineRoomProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    await roomProvider.createRoom(user);
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ActiveRoomScreen()),
    );
  }

  void _onJoinRoom() async {
    final auth = context.read<AuthProvider>();
    final roomProvider = context.read<OnlineRoomProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final success = await roomProvider.joinRoom(_codeController.text, user);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ActiveRoomScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(roomProvider.errorMessage ?? 'Odaya katılırken hata oluştu.'),
          backgroundColor: AppColors.crimson,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<OnlineRoomProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Online Meydan Okuma',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: StadiumBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.blueGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.electricBlue.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('🌐', style: TextStyle(fontSize: 28)),
                        SizedBox(width: 10),
                        Text(
                          'Online Oda Kur & Katıl',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Farklı yerlerdeki arkadaşlarınla oda kodu paylaşarak aynı anda düelloya girin!',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // CREATE ROOM SECTION
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yeni Bir Lobi Başlat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Odayı oluşturduktan sonra 6 haneli kodu arkadaşlarına yolla.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Yeni Oda Oluştur',
                      icon: Icons.add_circle_outline,
                      gradient: AppColors.pitchGradient,
                      textColor: Colors.black87,
                      isLoading: roomProvider.isCreatingRoom,
                      onPressed: _onCreateRoom,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // JOIN ROOM SECTION
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Arkadaşının Odasına Katıl',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Arkadaşından aldığın oda kodunu buraya gir.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: AppColors.pitchGreen,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Örn: FTB789',
                        prefixIcon: const Icon(Icons.vpn_key, color: AppColors.pitchGreen),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.pitchGreen),
                          onPressed: _onJoinRoom,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    CustomButton(
                      text: 'Odaya Gir',
                      isOutlined: true,
                      icon: Icons.login_rounded,
                      isLoading: roomProvider.isCreatingRoom,
                      onPressed: _onJoinRoom,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
