import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/online_room_provider.dart';
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
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<OnlineRoomProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Online Meydan Okuma',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cell_tower_outlined, color: AppColors.gold, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'Online Lobi & Oda Daveti',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Farklı yerlerdeki arkadaşlarınla 6 haneli oda kodu paylaşarak aynı anda düelloya katılın.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Create Room Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yeni Lobi Oluştur',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Oda oluşturulduktan sonra kodu arkadaşına ileterek maçı başlat.',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    CustomButton(
                      text: 'Yeni Oda Kur',
                      icon: Icons.add_circle_outline,
                      backgroundColor: AppColors.deepPurple,
                      textColor: Colors.white,
                      isLoading: roomProvider.isCreatingRoom,
                      onPressed: _onCreateRoom,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Join Room Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Odaya Katıl',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Arkadaşından aldığın 6 haneli kodu buraya gir.',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _codeController,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: AppColors.gold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Örn: FTB789',
                        prefixIcon: const Icon(Icons.vpn_key_outlined, color: AppColors.gold, size: 18),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.gold, size: 18),
                          onPressed: _onJoinRoom,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
