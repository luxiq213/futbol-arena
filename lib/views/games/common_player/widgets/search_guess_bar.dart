import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/player_model.dart';
import '../../../../data/repositories/football_database.dart';

class SearchGuessBar extends StatefulWidget {
  final Function(String) onSubmitted;
  final int searchLimit;
  final List<String>? priorityClubIds;
  final bool showClubTags;

  const SearchGuessBar({
    super.key,
    required this.onSubmitted,
    this.searchLimit = 6,
    this.priorityClubIds,
    this.showClubTags = false,
  });

  @override
  State<SearchGuessBar> createState() => _SearchGuessBarState();
}

class _SearchGuessBarState extends State<SearchGuessBar> {
  final TextEditingController _controller = TextEditingController();
  final FootballDatabase _db = FootballDatabase();
  List<PlayerModel> _suggestions = [];

  List<String> _sharedClubsWith(PlayerModel player) {
    final targetIds = widget.priorityClubIds;
    if (targetIds == null || targetIds.isEmpty) return const [];
    return player.clubIds.where((id) => targetIds.contains(id)).toList();
  }

  void _onChanged(String val) {
    if (val.trim().length >= 2) {
      final results = List<PlayerModel>.from(
        _db.searchPlayers(val, limit: widget.searchLimit),
      );
      if (widget.priorityClubIds != null && widget.priorityClubIds!.isNotEmpty) {
        results.sort((a, b) {
          final aShared = _sharedClubsWith(a).isNotEmpty ? 1 : 0;
          final bShared = _sharedClubsWith(b).isNotEmpty ? 1 : 0;
          return bShared.compareTo(aShared);
        });
      }
      setState(() {
        _suggestions = results;
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
        // Search Input Row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                onSubmitted: _submit,
                textInputAction: TextInputAction.send,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Futbolcu ismi yazın (Örn: Sneijder, Ronaldo)...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.gold, size: 18),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 16),
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
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: AppColors.pitchGreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
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
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) => const Divider(color: AppColors.border, height: 1),
              itemBuilder: (context, index) {
                final player = _suggestions[index];
                final sharedClubIds = _sharedClubsWith(player);
                final isBridgeMatch = sharedClubIds.isNotEmpty;
                final clubLabel = widget.showClubTags
                    ? player.clubIds
                        .map((id) => _db.getClub(id)?.shortName ?? id)
                        .take(4)
                        .join(' • ')
                    : '';

                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isBridgeMatch
                          ? AppColors.pitchGreen.withValues(alpha: 0.25)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(6),
                      border: isBridgeMatch
                          ? Border.all(color: AppColors.pitchGreen, width: 0.9)
                          : null,
                    ),
                    child: Center(
                      child: Icon(
                        isBridgeMatch ? Icons.link_rounded : Icons.person_outline,
                        size: 14,
                        color: isBridgeMatch ? AppColors.greenLight : AppColors.gold,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          player.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (isBridgeMatch) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.pitchGreen.withValues(alpha: 0.24),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Ortak: ${_db.getClub(sharedClubIds.first)?.shortName ?? ""}',
                            style: const TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.greenLight,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    clubLabel.isNotEmpty
                        ? '${player.country} • $clubLabel'
                        : '${player.country} • ${player.position}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                  trailing: const Icon(Icons.north_west, color: AppColors.textMuted, size: 14),
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
