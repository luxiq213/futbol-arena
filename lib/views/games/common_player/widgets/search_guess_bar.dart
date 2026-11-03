import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/player_model.dart';
import '../../../../data/repositories/football_database.dart';

class SearchGuessBar extends StatefulWidget {
  final Function(String) onSubmitted;

  const SearchGuessBar({super.key, required this.onSubmitted});

  @override
  State<SearchGuessBar> createState() => _SearchGuessBarState();
}

class _SearchGuessBarState extends State<SearchGuessBar> {
  final TextEditingController _controller = TextEditingController();
  final FootballDatabase _db = FootballDatabase();
  List<PlayerModel> _suggestions = [];

  void _onChanged(String val) {
    if (val.trim().length >= 2) {
      setState(() {
        _suggestions = _db.searchPlayers(val);
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  void _submit(String text) {
    if (text.trim().isEmpty) return;
    widget.onSubmitted(text.trim());
    _controller.clear();
    setState(() {
      _suggestions = [];
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                onSubmitted: _submit,
                textInputAction: TextInputAction.send,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Futbolcu ismi yazın (örn: Sneijder)...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.pitchGreen),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _suggestions = []);
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 52,
              width: 52,
              decoration: BoxDecoration(
                gradient: AppColors.pitchGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward_rounded, color: Colors.black87),
                onPressed: () => _submit(_controller.text),
              ),
            ),
          ],
        ),

        // Autocomplete Suggestions List
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const Divider(color: AppColors.cardBorder, height: 1),
              itemBuilder: (context, index) {
                final player = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: const CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.surfaceLight,
                    child: Text('⚽', style: TextStyle(fontSize: 12)),
                  ),
                  title: Text(
                    player.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '${player.country} • ${player.position}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  trailing: const Icon(Icons.north_west, color: AppColors.textMuted, size: 16),
                  onTap: () {
                    _submit(player.name);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
