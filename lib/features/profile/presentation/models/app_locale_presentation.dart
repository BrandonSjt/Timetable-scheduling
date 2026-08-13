import '../../../../core/localization/app_locale.dart';
import '../../../../l10n/app_localizations.dart';

extension AppLocalePresentation on AppLocale {
  String localizedName(AppLocalizations l10n) => switch (this) {
    AppLocale.indonesian => l10n.languageIndonesian,
    AppLocale.english => l10n.languageEnglish,
    AppLocale.simplifiedChinese => l10n.languageSimplifiedChinese,
    AppLocale.arabic => l10n.languageArabic,
  };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
    AppLocale.indonesian => l10n.languageIndonesianDesc,
    AppLocale.english => l10n.languageEnglishDesc,
    AppLocale.simplifiedChinese => l10n.languageSimplifiedChineseDesc,
    AppLocale.arabic => l10n.languageArabicDesc,
  };
}
