import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/play_mode_model.dart';
import '../../../../providers/party_mode_game_provider.dart';
import '../../widgets/custom_button.dart';
import 'party_game_screen.dart';

class PartySetupScreen extends StatefulWidget {
  final CommonPlayerPairMode initialPairFormat;

  const PartySetupScreen({
    super.key,
    this.initialPairFormat = CommonPlayerPairMode.clubVsClub,
  });

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
      create: (_) => PartyModeGameProvider(initialPairFormat: widget.initialPairFormat),
      child: Consumer<PartyModeGameProvider>(
        builder: (context, provider, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: const Text(
                '3-2-1 Düello Modu',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mode Information Card
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.alarm, color: AppColors.gold, size: 28),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Arkadaşlarla Yan Yana Oynanış',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '3-2-1 sayımından sonra Takım × Takım veya Takım × Ülke eşleşmesi belirir. Sırası gelen oyuncu süre bitmeden ortak futbolcuyu sesli olarak söyler.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Pair Format Selector (Takım × Takım | Takım × Ülke | Karışık)
                    const Text(
                      'Eşleşme Formatı (3-2-1 Modu)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: CommonPlayerPairMode.values.map((mode) {
                        final isSelected = provider.pairFormat == mode;
                        final modeIcon = mode == CommonPlayerPairMode.clubVsClub
                            ? Icons.shield_outlined
                            : (mode == CommonPlayerPairMode.clubVsCountry
                                ? Icons.public_rounded
                                : Icons.shuffle_rounded);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => provider.setPairFormat(mode),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.pitchGreen.withValues(alpha: 0.25)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.gold : AppColors.border,
                                  width: isSelected ? 1.3 : 1.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    modeIcon,
                                    size: 16,
                                    color: isSelected ? AppColors.gold : AppColors.textMuted,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    mode.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isSelected ? Colors.white : AppColors.textSecondary,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Turn Timer Duration
                    const Text(
                      'Tur Başına Süre',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.pitchGreen : AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.gold : AppColors.border,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$sec sn',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? AppColors.gold : Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Lives Selection
                    const Text(
                      'Oyuncu Başına Can Hakkı',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
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
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.surfaceLight : AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? AppColors.gold : AppColors.border,
                                ),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.favorite,
                                      size: 14,
                                      color: isSelected ? AppColors.error : AppColors.textMuted,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$lives Can',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: isSelected ? Colors.white : AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 22),

                    // Player List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Oyuncu Listesi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${provider.players.length} Oyuncu',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Add Player Input
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _playerController,
                            textCapitalization: TextCapitalization.words,
                            onSubmitted: (_) => _addPlayer(provider),
                            style: const TextStyle(fontSize: 13),
                            decoration: const InputDecoration(
                              hintText: 'Yeni oyuncu adı girin...',
                              prefixIcon: Icon(Icons.person_add_alt, color: AppColors.gold, size: 18),
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: AppColors.pitchGreen,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            onPressed: () => _addPlayer(provider),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Players List
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.players.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final player = provider.players[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    player.avatar,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Row(
                                children: List.generate(
                                  provider.initialLives,
                                  (_) => const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 1),
                                    child: Icon(Icons.favorite, size: 13, color: AppColors.error),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (provider.players.length > 2)
                                GestureDetector(
                                  onTap: () => provider.removePlayer(player.id),
                                  child: const Icon(Icons.close, color: AppColors.textMuted, size: 16),
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Start Game Button
                    CustomButton(
                      text: 'Düelloyu Başlat',
                      icon: Icons.play_arrow_outlined,
                      backgroundColor: AppColors.pitchGreen,
                      textColor: Colors.white,
                      height: 48,
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
                    const SizedBox(height: 16),
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
