import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/grid_challenge_model.dart';
import '../../../../data/models/play_mode_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/online_room_provider.dart';
import '../../widgets/app_notification.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stadium_background.dart';
import 'active_room_screen.dart';
import 'matchmaking_screen.dart';
import '../league_draft/league_draft_screen.dart';

class LobbyHubScreen extends StatefulWidget {
  final GameTargetType initialGameTarget;
  final bool isEmbedded;

  const LobbyHubScreen({
    super.key,
    this.initialGameTarget = GameTargetType.commonPlayer,
    this.isEmbedded = false,
  });

  @override
  State<LobbyHubScreen> createState() => _LobbyHubScreenState();
}

class _LobbyHubScreenState extends State<LobbyHubScreen> {
  final TextEditingController _codeController = TextEditingController();
  late GameTargetType _selectedGame;
  GameDifficulty _selectedDifficulty = GameDifficulty.medium;
  CommonPlayerPairMode _selectedPairFormat = CommonPlayerPairMode.clubVsClub;
  GridThemeType _selectedGridTheme = GridThemeType.mixed;

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
      MaterialPageRoute(
        builder: (_) => ActiveRoomScreen(initialGridTheme: _selectedGridTheme),
      ),
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
        MaterialPageRoute(
          builder: (_) => ActiveRoomScreen(initialGridTheme: _selectedGridTheme),
        ),
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
        builder: (_) => MatchmakingScreen(
          targetGame: _selectedGame,
          difficulty: _selectedDifficulty,
          commonPlayerPairFormat: _selectedPairFormat,
          gridTheme: _selectedGridTheme,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roomProvider = context.watch<OnlineRoomProvider>();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
              // 0. Compact Online League Draft Lobby Banner (18-20 Teams, Friend Invites + Auto AI Bots)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0A141E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.65),
                    width: 1.1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: AppColors.gold, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Online Lig Draft (18-20 Takım)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Arkadaş davet et, kalan koltuklar AI Bot olsun',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LeagueDraftScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.hub_rounded, size: 13),
                      label: const Text(
                        'Lobi Aç',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: GameTargetType.values.map((type) {
                          final isSelected = _selectedGame == type;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedGame = type),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
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
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    if (_selectedGame == GameTargetType.commonPlayer) ...[
                      const SizedBox(height: 10),
                      const Text(
                        '3-2-1 FORMATI:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: CommonPlayerPairMode.values.map((mode) {
                            final isSelected = _selectedPairFormat == mode;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedPairFormat = mode),
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.gold.withValues(alpha: 0.16)
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: isSelected ? AppColors.gold : AppColors.border,
                                    width: isSelected ? 1.3 : 0.8,
                                  ),
                                ),
                                child: Text(
                                  mode.label,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? AppColors.gold : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    if (_selectedGame == GameTargetType.footballGrid) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'GRİD KATEGORİSİ SEÇİMİ:',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: GridThemeType.values.map((theme) {
                            final isSelected = _selectedGridTheme == theme;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedGridTheme = theme),
                              child: Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.gold.withValues(alpha: 0.16)
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                    color: isSelected ? AppColors.gold : AppColors.border,
                                    width: isSelected ? 1.3 : 0.8,
                                  ),
                                ),
                                child: Text(
                                  theme.label,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? AppColors.gold : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    const Text(
                      'ZORLUK SEVİYESİ:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: AppColors.greenLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: GameDifficulty.values.map((diff) {
                        final isSelected = _selectedDifficulty == diff;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedDifficulty = diff),
                            child: Container(
                              margin: EdgeInsets.only(
                                right: diff == GameDifficulty.values.last ? 0 : 6,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.pitchGreen.withValues(alpha: 0.26)
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: isSelected ? AppColors.gold : AppColors.border,
                                  width: isSelected ? 1.3 : 0.8,
                                ),
                              ),
                              child: Text(
                                diff.label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
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

              const SizedBox(height: 16),
            ],
          );

    if (widget.isEmbedded) {
      return content;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Online Lobi & Davet'),
      ),
      body: StadiumBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: content,
        ),
      ),
    );
  }
}
