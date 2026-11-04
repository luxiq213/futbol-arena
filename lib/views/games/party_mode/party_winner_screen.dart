import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../providers/party_mode_game_provider.dart';
import '../../widgets/custom_button.dart';

class PartyWinnerScreen extends StatelessWidget {
  const PartyWinnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PartyModeGameProvider>();
    final winner = provider.winner;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Heraldic Winner Icon
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.military_tech_outlined,
                    size: 48,
                    color: AppColors.gold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'DÜELLO KAZANANI',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: AppColors.gold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                winner?.name ?? 'Oyuncu',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Tüm rakiplerini geride birakarak turu tamamladin.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Final Standings Table
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Puan Tablosu',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...provider.players.map((p) {
                      final isWinner = p.id == winner?.id;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              isWinner ? Icons.check_circle : Icons.remove,
                              size: 16,
                              color: isWinner ? AppColors.gold : AppColors.textMuted,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  p.avatar,
                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                p.name,
                                style: TextStyle(
                                  color: isWinner ? AppColors.gold : Colors.white70,
                                  fontWeight: isWinner ? FontWeight.w700 : FontWeight.w400,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '${p.score} Puan',
                              style: TextStyle(
                                color: isWinner ? AppColors.gold : AppColors.textMuted,
                                fontWeight: FontWeight.w600,
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

              CustomButton(
                text: 'Yeniden Baslat',
                icon: Icons.refresh,
                backgroundColor: AppColors.pitchGreen,
                textColor: Colors.white,
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
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
