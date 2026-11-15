import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/play_mode_model.dart';
import '../../../../data/repositories/football_database.dart';
import '../../../../providers/auction_duel_game_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/duel_scoreboard_banner.dart';
import '../../widgets/stadium_background.dart';
import '../common_player/widgets/search_guess_bar.dart';

class AuctionDuelScreen extends StatelessWidget {
  final PlayModeType playMode;
  final GameDifficulty difficulty;
  final OpponentProfile? opponent;

  const AuctionDuelScreen({
    super.key,
    this.playMode = PlayModeType.solo,
    this.difficulty = GameDifficulty.medium,
    this.opponent,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return ChangeNotifierProvider(
      create: (_) => AuctionDuelGameProvider(
        playMode: playMode,
        difficulty: difficulty,
        opponent: opponent,
      ),
      child: Consumer<AuctionDuelGameProvider>(
        builder: (context, game, _) {
          final cat = game.category;
          if (cat == null) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: const Text('Açık Artırma Düellosu'),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_outline, color: AppColors.gold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${game.score} Puan',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: StadiumBackground(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. Live Scoreboard
                          DuelScoreboardBanner(
                            userName: user?.username ?? 'Kaptan',
                            userAvatar: user?.avatar ?? 'goat_10',
                            userScore: game.score,
                            opponent: game.effectiveOpponent,
                            opponentScore: game.opponentScore,
                          ),
                          const SizedBox(height: 8),

                          // 2. Compact Auction Category Card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF143D29),
                                  Color(0xFF0A2116),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.65),
                                width: 1.1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.gavel_rounded, size: 11, color: AppColors.gold),
                                          const SizedBox(width: 4),
                                          Text(
                                            cat.badge,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.gold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      'Havuz: ${cat.validPlayers.length} Yıldız',
                                      style: const TextStyle(
                                        fontSize: 9.8,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.greenLight,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cat.title,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cat.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 3. Phase-Specific Body
                          if (game.phase == AuctionPhase.bidding)
                            _buildBiddingPhaseView(game)
                          else if (game.phase == AuctionPhase.provingByUser)
                            _buildProvingByUserView(game)
                          else if (game.phase == AuctionPhase.provingByOpponent)
                            _buildProvingByOpponentView(game)
                          else
                            _buildRoundSummaryView(game, cat),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Controls
                  _buildBottomActionBar(context, game),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBiddingPhaseView(AuctionDuelGameProvider game) {
    final isUserHolding = game.bidHolder == BidHolder.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Central Bid Counter Dial
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUserHolding ? AppColors.pitchGreen : AppColors.gold,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              const Text(
                'MASADAKİ GÜNCEL İDDİA',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${game.currentBid}',
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FUTBOLCU SAYARIM!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isUserHolding
                      ? AppColors.pitchGreen.withValues(alpha: 0.22)
                      : AppColors.gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isUserHolding
                      ? 'Son İddia Sahibi: SEN (${game.effectiveOpponent.name} düşünüyor...)'
                      : 'Son İddia Sahibi: ${game.effectiveOpponent.name} • Sıra Sende!',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isUserHolding ? AppColors.greenLight : AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Bidding Log History
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.forum_outlined, size: 14, color: AppColors.greenLight),
                  SizedBox(width: 6),
                  Text(
                    'AÇIK ARTIRMA MASASI DİYALOĞU',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: AppColors.greenLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...game.bidLog.map((entry) {
                final isMe = entry.startsWith('Sen:');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isMe ? Icons.person : Icons.smart_toy_outlined,
                        size: 14,
                        color: isMe ? AppColors.greenLight : AppColors.gold,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          entry,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isMe ? FontWeight.w700 : FontWeight.w600,
                            color: isMe ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProvingByUserView(AuctionDuelGameProvider game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Timer & Target Progress Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold, width: 1.4),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: game.proveSecondsLeft <= 8
                      ? AppColors.error.withValues(alpha: 0.22)
                      : AppColors.darkGreen,
                  border: Border.all(
                    color: game.proveSecondsLeft <= 8 ? AppColors.error : AppColors.gold,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${game.proveSecondsLeft}s',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: game.proveSecondsLeft <= 8 ? AppColors.error : AppColors.gold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'İDDİANI KANITLAMA ZAMANI!',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rakibin "Kanıtla!" dedi. Süre dolmadan ${game.currentBid} doğru futbolcuyu yaz!',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pitchGreen.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.pitchGreen),
                ),
                child: Text(
                  '${game.foundPlayers.length} / ${game.currentBid}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        if (game.lastFeedback != null)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: game.isSuccessFeedback
                  ? AppColors.pitchGreen.withValues(alpha: 0.25)
                  : AppColors.error.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: game.isSuccessFeedback ? AppColors.pitchGreen : AppColors.error,
              ),
            ),
            child: Text(
              game.lastFeedback!,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: game.isSuccessFeedback ? AppColors.gold : Colors.white,
              ),
            ),
          ),

        // Search & Guess Input
        SearchGuessBar(
          onSubmitted: (query) {
            game.submitProveGuess(query);
          },
        ),

        const SizedBox(height: 12),

        // Found Players List
        if (game.foundPlayers.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: game.foundPlayers.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final p = entry.value;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.darkGreen,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.pitchGreen),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#$idx ',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gold,
                      ),
                    ),
                    Text(
                      p.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildProvingByOpponentView(AuctionDuelGameProvider game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.gold),
          ),
          const SizedBox(height: 10),
          Text(
            '${game.effectiveOpponent.name} İddiasını Kanıtlamaya Çalışıyor...',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sayılan: ${game.foundPlayers.length} / ${game.currentBid} Futbolcu',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: game.foundPlayers.map((p) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundSummaryView(AuctionDuelGameProvider game, AuctionCategory cat) {
    final won = game.didUserWinRound;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: won
                ? AppColors.pitchGreen.withValues(alpha: 0.25)
                : AppColors.error.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: won ? AppColors.pitchGreen : AppColors.error,
              width: 1.4,
            ),
          ),
          child: Column(
            children: [
              Icon(
                won ? Icons.emoji_events_outlined : Icons.warning_amber_rounded,
                color: won ? AppColors.gold : Colors.redAccent,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                game.roundSummaryTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: won ? AppColors.gold : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                game.roundSummarySubtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Show valid players in category
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.90),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kategorideki Tüm Yıldızlar (${cat.validPlayers.length}):',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cat.validPlayers.map((p) {
                  final wasNamed = game.foundPlayers.any((f) => f.id == p.id);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: wasNamed
                          ? AppColors.pitchGreen.withValues(alpha: 0.30)
                          : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: wasNamed ? AppColors.pitchGreen : AppColors.border,
                      ),
                    ),
                    child: Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: wasNamed ? FontWeight.w800 : FontWeight.w500,
                        color: wasNamed ? AppColors.gold : Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar(BuildContext context, AuctionDuelGameProvider game) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Builder(
        builder: (context) {
          if (game.phase == AuctionPhase.bidding) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: '+1 Artır (${game.currentBid + 1} İsim)',
                        height: 44,
                        backgroundColor: AppColors.surfaceLight,
                        textColor: Colors.white,
                        icon: Icons.trending_up_rounded,
                        onPressed: game.canUserRaise ? () => game.userRaiseBid(1) : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomButton(
                        text: '+2 Artır (${game.currentBid + 2} İsim)',
                        height: 44,
                        backgroundColor: AppColors.surfaceLight,
                        textColor: AppColors.greenLight,
                        icon: Icons.double_arrow_rounded,
                        onPressed: game.canUserRaise ? () => game.userRaiseBid(2) : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomButton(
                  text: 'KANITLA! (${game.effectiveOpponent.name} ${game.currentBid} İsim Saysın)',
                  height: 46,
                  backgroundColor: AppColors.gold,
                  textColor: AppColors.background,
                  icon: Icons.gavel_rounded,
                  onPressed: game.canUserCallProve ? () => game.userCallProve() : null,
                ),
              ],
            );
          }

          if (game.phase == AuctionPhase.provingByUser) {
            return CustomButton(
              text: 'Pes Et / Turu Bitir',
              height: 44,
              isOutlined: true,
              icon: Icons.flag_outlined,
              onPressed: () => game.giveUpUserProving(),
            );
          }

          if (game.phase == AuctionPhase.roundSummary) {
            return CustomButton(
              text: 'Sonraki Açık Artırma Turu',
              height: 46,
              backgroundColor: AppColors.pitchGreen,
              textColor: Colors.white,
              icon: Icons.arrow_forward_rounded,
              onPressed: () {
                if (game.didUserWinRound) {
                  context.read<AuthProvider>().addPoints(130, won: true);
                }
                game.startNewRound();
              },
            );
          }

          return const SizedBox(height: 44);
        },
      ),
    );
  }
}
