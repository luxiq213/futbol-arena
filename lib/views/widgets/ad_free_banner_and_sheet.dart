import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'app_notification.dart';

/// Displays a sleek sponsor/ad banner for free-tier users.
/// Automatically hides itself completely when [user.isAdFree] is true.
class AdBannerWidget extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const AdBannerWidget({
    super.key,
    this.margin = const EdgeInsets.only(top: 2, bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.enableAdsAndIapInStoreBuild) {
      return const SizedBox.shrink();
    }
    final user = context.watch<AuthProvider>().currentUser;
    final loc = context.watch<LocaleProvider>();
    if (user != null && user.isAdFree) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: margin,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF071B13).withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.85),
          width: 0.9,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 0.7),
            ),
            child: Text(
              loc.t('ad_label'),
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  loc.t('ad_banner_title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  loc.t('ad_banner_sub'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => showAdFreePurchaseSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.55), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.block_flipped, size: 11, color: AppColors.gold),
                  const SizedBox(width: 4),
                  Text(
                    loc.t('remove_ads_short'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows the app's ONLY monetization option: One-time Ad-Free Mode purchase.
void showAdFreePurchaseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const _AdFreePurchaseSheetContent(),
  );
}

class _AdFreePurchaseSheetContent extends StatelessWidget {
  const _AdFreePurchaseSheetContent();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = context.watch<LocaleProvider>();
    final user = auth.currentUser;
    final isGuest = user == null || user.isGuest;
    final isAdFree = user?.isAdFree ?? false;

    return Container(
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        MediaQuery.of(context).padding.bottom + 18,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0E2D20),
            Color(0xFF06160F),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.45),
          width: 1.1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold, width: 1.1),
                ),
                child: Icon(
                  isAdFree ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                  color: AppColors.gold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            loc.t('ad_free_title'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isAdFree ? AppColors.pitchGreen : AppColors.gold)
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isAdFree ? AppColors.pitchGreen : AppColors.gold,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            isAdFree ? loc.t('ad_free_active') : loc.t('ad_free_single_sale'),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isAdFree ? AppColors.greenLight : AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loc.t('ad_free_subtitle'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildFeatureItem(
            Icons.block_rounded,
            loc.t('ad_free_feat1_title'),
            loc.t('ad_free_feat1_sub'),
          ),
          const SizedBox(height: 8),
          _buildFeatureItem(
            Icons.balance_rounded,
            loc.t('ad_free_feat2_title'),
            loc.t('ad_free_feat2_sub'),
          ),
          const SizedBox(height: 8),
          _buildFeatureItem(
            Icons.all_inclusive_rounded,
            loc.t('ad_free_feat3_title'),
            loc.t('ad_free_feat3_sub'),
          ),
          const SizedBox(height: 14),

          if (isGuest) ...[
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.55),
                  width: 0.9,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lock_person_outlined, color: AppColors.gold, size: 18),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.t('account_req_title'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc.t('account_req_sub'),
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Colors.white,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pitchGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: Text(
                loc.t('create_account_btn'),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: Text(
                loc.t('login_existing_btn'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                ),
              ),
            ),
          ] else if (!isAdFree) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.pitchGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.pitchGreen.withValues(alpha: 0.45)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: AppColors.greenLight, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${user.username} (${user.email})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greenLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: const Color(0xFF071A12),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final ok = await auth.purchaseAdFree();
                if (ok && context.mounted) {
                  Navigator.pop(context);
                  AppNotification.show(
                    context,
                    title: loc.t('ad_free_title'),
                    subtitle: '${user.username} • ${loc.t("ad_free_active")}',
                    type: AppNotificationType.success,
                    icon: Icons.verified_rounded,
                  );
                }
              },
              icon: const Icon(Icons.workspace_premium_rounded, size: 18),
              label: Text(
                loc.t('buy_ad_free_btn'),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: () async {
                final ok = await auth.restorePurchases();
                if (ok && context.mounted) {
                  Navigator.pop(context);
                  AppNotification.show(
                    context,
                    title: loc.t('restore_purchases_btn'),
                    subtitle: '${user.username} • ${loc.t("ad_free_active")}',
                    type: AppNotificationType.success,
                    icon: Icons.restore_rounded,
                  );
                }
              },
              icon: const Icon(Icons.restore_rounded, size: 15, color: AppColors.textSecondary),
              label: Text(
                loc.t('restore_purchases_btn'),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.pitchGreen.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.pitchGreen),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.greenLight, size: 18),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '${loc.t("ad_free_title")} • ${loc.t("ad_free_active")} (${user.username})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () async {
                  await auth.setAdFreeMode(false);
                  if (context.mounted) {
                    Navigator.pop(context);
                    AppNotification.show(
                      context,
                      title: 'Reklamlı Görünüme Dönüldü (Test)',
                      subtitle: 'Reklam alanları tekrar görünür hale getirildi.',
                      type: AppNotificationType.highlight,
                      icon: Icons.visibility_outlined,
                    );
                  }
                },
                child: const Text(
                  'Test İçin Reklamlı Görünüme Geri Dön',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.gold, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
