import 'package:flutter/material.dart';

import '../../../../core/localization/app_locale.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/widgets/auth_scope.dart';
import '../models/app_locale_presentation.dart';
import '../widgets/profile_detail_scaffold.dart';

/// Pilihan bahasa aplikasi untuk mode tamu.
class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  Future<void> _applyLanguage(AppLocale newLocale) async {
    final auth = AuthScope.of(context, listen: false);
    final saved = await LocaleScope.of(context).select(newLocale);

    if (auth.isAuthenticated) {
      await auth.updateProfile(language: newLocale.storageTag);
    }
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            saved
                ? l10n.languageAppliedSnackbar
                : l10n.languageSaveFailedSnackbar,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = LocaleScope.of(context).value;
    final l10n = AppLocalizations.of(context)!;

    return ProfileDetailScaffold(
      title: l10n.languagePageTitle,
      subtitle: l10n.languagePageSubtitle,
      children: [
        Text(
          l10n.languageApp,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.languageDescription,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),
        for (final option in AppLocale.values) ...[
          _LanguageOption(
            title: option.localizedName(l10n),
            subtitle: option.localizedDescription(l10n),
            selected: currentLocale == option,
            onTap: () => _applyLanguage(option),
          ),
          if (option != AppLocale.values.last) const SizedBox(height: 12),
        ],
        const SizedBox(height: 52),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.preview,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.previewAccount,
                style: const TextStyle(
                  color: Color(0xFF632BFF),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.previewGuestActive,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 42),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              // The language is applied instantly when the option is tapped,
              // but we keep the button to dismiss or as a secondary confirmation if needed.
              // In this prototype, we just go back.
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              l10n.applyLanguage,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Center(
          child: Text(
            l10n.languageAppliedNote,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      hint: subtitle,
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 26,
                  height: 26,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.primaryBlue : Colors.white,
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryBlue
                          : AppColors.textHint,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
