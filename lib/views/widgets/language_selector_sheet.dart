import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/l10n/app_strings.dart';
import '../../providers/locale_provider.dart';
import 'app_notification.dart';

void showLanguageSelectorSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => const _LanguageSelectorSheetContent(),
  );
}

class _LanguageSelectorSheetContent extends StatelessWidget {
  const _LanguageSelectorSheetContent();

  @override
  Widget build(BuildContext context) {
    final localeProv = context.watch<LocaleProvider>();
    final activeCode = localeProv.languageCode;
    final maxHeight = MediaQuery.of(context).size.height * 0.82;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
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
            color: AppColors.pitchGreen.withValues(alpha: 0.45),
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.pitchGreen.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: AppColors.pitchGreen),
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    color: AppColors.greenLight,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localeProv.t('select_language_title'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'TR • EN • ES • PT • DE • FR • IT • NL • PL • AR • RU • JA • KO • ID • EL • RO • HR • SV • UK • ZH',
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
              ],
            ),
            const SizedBox(height: 14),
            Flexible(
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: AppStrings.supportedLanguages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 3.1,
                ),
                itemBuilder: (context, index) {
                  final lang = AppStrings.supportedLanguages[index];
                  final isSelected = lang.code == activeCode;

                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      await localeProv.setLanguage(lang.code);
                      if (context.mounted) {
                        Navigator.pop(context);
                        AppNotification.show(
                          context,
                          title: '${lang.nativeName} (${lang.shortCode})',
                          subtitle: '${localeProv.t("language_label")}: ${lang.nativeName}',
                          type: AppNotificationType.success,
                          icon: Icons.language_rounded,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.pitchGreen.withValues(alpha: 0.25)
                            : Colors.black.withValues(alpha: 0.30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.gold : AppColors.border,
                          width: isSelected ? 1.4 : 0.9,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.gold.withValues(alpha: 0.22)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              lang.shortCode,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isSelected ? AppColors.gold : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.nativeName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isSelected ? AppColors.gold : Colors.white,
                                  ),
                                ),
                                Text(
                                  lang.englishName,
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
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppColors.gold,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
