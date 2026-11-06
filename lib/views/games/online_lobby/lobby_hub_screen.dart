import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/play_mode_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/online_room_provider.dart';
import '../../widgets/app_notification.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stadium_background.dart';
import 'active_room_screen.dart';
import 'matchmaking_screen.dart';

class LobbyHubScreen extends StatefulWidget {
  final GameTargetType initialGameTarget;

  const LobbyHubScreen({
    super.key,
    this.initialGameTarget = GameTargetType.commonPlayer,
  });

  @override
  State<LobbyHubScreen> createState() => _LobbyHubScreenState();
}

class _LobbyHubScreenState extends State<LobbyHubScreen> {
  final TextEditingController _codeController = TextEditingController();
  late GameTargetType _selectedGame;

  @override
  void initState() {
    super.initState();
    _selectedGame = widget.initialGameTarget;
  }

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

    await roomProvider.createRoom(user, targetGame: _selectedGame);
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

    final success = await roomProvider.joinRoom(
      _codeController.text,
      user,
      targetGame: _selectedGame,
    );
    if (!mounted) return;

    if (success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ActiveRoomScreen()),
      );
    } else {
      AppNotification.show(
        context,
        title: 'Odaya Katılınamadı',
        message: roomProvider.errorMessage ?? 'Odaya katılırken hata oluştu, lütfen davet kodunu kontrol et.',
        type: AppNotificationType.error,
        icon: Icons.error_outline_rounded,
      );
    }
  }

  void _onStartQuickMatchmaking() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MatchmakingScreen(targetGame: _selectedGame),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<OnlineRoomProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 46,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Arkadaş Daveti & Online Eşleşme',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
        ),
      ),
      body: StadiumBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Select Which Game Mode to Play in Duel
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. DÜELLO OYUNUNU SEÇ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.greenLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: GameTargetType.values.map((type) {
                        final isSelected = _selectedGame == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedGame = type),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.darkGreen : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.pitchGreen : AppColors.border,
                                  width: isSelected ? 1.4 : 0.8,
                                ),
                              ),
                              child: Text(
                                type.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  height: 1.15,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 2. Quick Online Matchmaking (Falls back to AI if no online player found)
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.pitchGreen.withValues(alpha: 0.65)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.public_rounded, color: AppColors.greenLight, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Hızlı Online Eşleşme (${_selectedGame.title})',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Online rakip aranır; uygun oyuncu bulunamazsa anında denk seviyede Yapay Zeka rakip ile düello başlar.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Online Rakip Bul / Eşleş',
                      icon: Icons.radar_rounded,
                      backgroundColor: AppColors.pitchGreen,
                      textColor: Colors.white,
                      onPressed: _onStartQuickMatchmaking,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. Create Room for Friend Invite
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.person_add_alt_1_outlined, color: AppColors.gold, size: 19),
                        SizedBox(width: 8),
                        Text(
                          'Arkadaşınla Oyna • Davet Odası Kur',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '6 haneli davet kodu oluşturup arkadaşına gönder, aynı anda düelloya başlayın.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    CustomButton(
                      text: 'Davet Kodlu Oda Kur',
                      icon: Icons.add_circle_outline,
                      isLoading: roomProvider.isCreatingRoom,
                      onPressed: _onCreateRoom,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. Join Friend's Room Section
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Davet Kodu İle Odaya Katıl',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Arkadaşından aldığın 6 haneli davet kodunu aşağıya gir.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
                    CustomButton(
                      text: 'Odaya Katıl',
                      isOutlined: true,
                      icon: Icons.login_rounded,
                      isLoading: roomProvider.isCreatingRoom,
                      onPressed: _onJoinRoom,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
