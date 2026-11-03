import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/party_mode_game_provider.dart';
import '../../widgets/stadium_background.dart';
import '../../widgets/custom_button.dart';
import 'party_game_screen.dart';

class PartySetupScreen extends StatefulWidget {
  const PartySetupScreen({super.key});

  @override
  State<PartySetupScreen> createState() => _PartySetupScreenState();
}

class _PartySetupScreenState extends State<PartySetupScreen> {
  final TextEditingController _playerController = TextEditingController();

  void _addPlayer(PartyModeGameProvider provider) {
    if (_playerController.text.trim().isNotEmpty) {
      provider.addPlayer(_playerController.text.trim());
      _playerController.clear();
    }
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PartyModeGameProvider(),
      child: Consumer<PartyModeGameProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                '3-2-1 Bomba (Yan Yana Mod)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
            body: StadiumBackground(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // GAME INFO CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Row(
                        children: [
                          Text('💣', style: TextStyle(fontSize: 36)),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Arkadaşlarınla Masada / Yan Yana',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '3-2-1 sayımından sonra ekranda kulüpler belirir. Sırası gelen oyuncu süre bitmeden ortak futbolcuyu sesli söyler!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // TIMER SELECTION
                    const Text(
                      'Tur Başına Süre',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [5, 8, 10, 15].map((sec) {
                        final isSelected = provider.selectedTimerDuration == sec;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => provider.setTimerDuration(sec),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.pitchGreen : AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.pitchGreen : AppColors.cardBorder,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$sec sn',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),

                    // LIVES SELECTION
                    const Text(
                      'Oyuncu Başına Can',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [1, 2, 3, 5].map((lives) {
                        final isSelected = provider.initialLives == lives;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => provider.setInitialLives(lives),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.crimson : AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? AppColors.crimson : AppColors.cardBorder,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '❤️ $lives Can',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? Colors.white : AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // PLAYERS LIST HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Oyuncu Listesi',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${provider.players.length} Oyuncu',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.pitchGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // ADD PLAYER INPUT
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _playerController,
                            textCapitalization: TextCapitalization.words,
                            onSubmitted: (_) => _addPlayer(provider),
                            decoration: InputDecoration(
                              hintText: 'Yeni arkadaş ekle (örn: Selin)...',
                              prefixIcon: const Icon(Icons.person_add, color: AppColors.pitchGreen),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: AppColors.pitchGreen,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.black87),
                            onPressed: () => _addPlayer(provider),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // PLAYERS CHIPS
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.players.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final player = provider.players[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Text(player.avatar, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  provider.initialLives,
                                  (_) => const Text('❤️', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (provider.players.length > 2)
                                IconButton(
                                  icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
                                  onPressed: () => provider.removePlayer(player.id),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // START BUTTON
                    CustomButton(
                      text: '3-2-1 BAŞLAT!',
                      icon: Icons.play_arrow_rounded,
                      gradient: AppColors.fireGradient,
                      textColor: Colors.white,
                      height: 56,
                      onPressed: () {
                        provider.startGame();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: provider,
                              child: const PartyGameScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
