import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/party_mode_game_provider.dart';
import '../../widgets/stadium_background.dart';
import '../../widgets/custom_button.dart';

class PartyWinnerScreen extends StatefulWidget {
  const PartyWinnerScreen({super.key});

  @override
  State<PartyWinnerScreen> createState() => _PartyWinnerScreenState();
}

class _PartyWinnerScreenState extends State<PartyWinnerScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PartyModeGameProvider>();
    final winner = provider.winner;

    return Scaffold(
      body: StadiumBackground(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // CROWN & AVATAR
                  Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withOpacity(0.5),
                              blurRadius: 30,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            winner?.avatar ?? '👑',
                            style: const TextStyle(fontSize: 48),
                          ),
                        ),
                      ),
                      const Positioned(
                        top: -24,
                        child: Text('👑', style: TextStyle(fontSize: 34)),
                      ),
                    ],
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 24),

                  const Text(
                    'ŞAMPİYON!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                      color: AppColors.gold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    winner?.name ?? 'Oyuncu',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Futbol bilginle arkadaşlarını eledin ve kupayı kaldırdın!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // FINAL LEADERBOARD TABLE
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Maç Sonu Sıralaması',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...provider.players.map((p) {
                          final isWinner = p.id == winner?.id;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  isWinner ? '🥇' : '❌',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Text(p.avatar, style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    p.name,
                                    style: TextStyle(
                                      color: isWinner ? AppColors.gold : Colors.white70,
                                      fontWeight: isWinner ? FontWeight.w800 : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${p.score} Puan',
                                  style: TextStyle(
                                    color: isWinner ? AppColors.pitchGreen : AppColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // REPLAY OR EXIT
                  CustomButton(
                    text: 'Yeniden Oyna',
                    gradient: AppColors.pitchGradient,
                    textColor: Colors.black87,
                    icon: Icons.refresh,
                    onPressed: () {
                      provider.startGame();
                    },
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'Ana Menüye Dön',
                    isOutlined: true,
                    onPressed: () {
                      provider.resetToSetup();
                      Navigator.pop(context); // Pop winner/game screen
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // CONFETTI BURST
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 50,
                colors: const [
                  AppColors.gold,
                  AppColors.pitchGreen,
                  Colors.white,
                  Colors.deepPurpleAccent,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
