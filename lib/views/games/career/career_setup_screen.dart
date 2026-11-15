import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/career_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/career_game_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/stadium_background.dart';
import 'career_season_screen.dart';

class CareerSetupScreen extends StatefulWidget {
  const CareerSetupScreen({super.key});

  @override
  State<CareerSetupScreen> createState() => _CareerSetupScreenState();
}

class _CareerSetupScreenState extends State<CareerSetupScreen> {
  late final TextEditingController _nameController;
  PlayerPosition _selectedPosition = PlayerPosition.striker;
  String _selectedRegion = 'Türkiye';

  final List<String> _regions = [
    'Türkiye',
    'İngiltere',
    'İspanya',
    'İtalya',
    'Almanya',
    'Brezilya / Güney Amerika',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(
      text: auth.currentUser?.username ?? 'Kaptan',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onStart() {
    final provider = context.read<CareerGameProvider>();
    provider.startCareer(
      playerName: _nameController.text,
      position: _selectedPosition,
      region: _selectedRegion,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CareerSeasonScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Futbolcu Kariyeri Başlat'),
      ),
      body: StadiumBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Compact Top Header Strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: AppColors.borderGreen.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.stars_outlined, color: AppColors.gold, size: 17),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Altyapıdan zirveye 10 dönem ilerle • İstatistikler jübilede açılır',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 1. Oyuncu Adı
              const Text(
                'FUTBOLCU ADIN / LAKABIN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.pitchGreen,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Adını yaz...',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surface,
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.pitchGreen, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    borderSide: const BorderSide(color: AppColors.pitchGreen),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 2. Mevki Seçimi
              const Text(
                'SAHADAKİ MEVKİN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.pitchGreen,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PlayerPosition.values.map((pos) {
                  final isSelected = _selectedPosition == pos;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedPosition = pos),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.darkGreen
                            : AppColors.surface.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.pitchGreen : AppColors.border,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.pitchGreen : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pos.shortCode,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: isSelected ? Colors.black87 : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            pos.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // 3. Başlangıç Bölgesi
              const Text(
                'BAŞLANGIÇ LİGİ / ÜLKESİ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.pitchGreen,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRegion,
                    isExpanded: true,
                    dropdownColor: AppColors.surface,
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.pitchGreen),
                    items: _regions.map((reg) {
                      return DropdownMenuItem<String>(
                        value: reg,
                        child: Text(reg, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRegion = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Start Career Action Button
              CustomButton(
                text: 'Kariyeri Başlat (17 Yaş)',
                icon: Icons.sports_soccer,
                height: 52,
                onPressed: _onStart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
