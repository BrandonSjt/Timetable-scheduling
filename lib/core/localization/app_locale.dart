import 'package:flutter/widgets.dart';

enum AppLocale {
  indonesian(Locale('id'), 'id'),
  english(Locale('en'), 'en'),
  simplifiedChinese(
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    'zh-Hans',
  ),
  arabic(Locale('ar'), 'ar');

  const AppLocale(this.locale, this.storageTag);

  final Locale locale;
  final String storageTag;

  static AppLocale? fromStorageTag(String? tag) => switch (tag) {
    'id' => AppLocale.indonesian,
    'en' => AppLocale.english,
    'zh-Hans' => AppLocale.simplifiedChinese,
    'ar' => AppLocale.arabic,
    _ => null,
  };

  static AppLocale? fromDeviceLocale(Locale locale) {
    if (locale.languageCode == 'id') return AppLocale.indonesian;
    if (locale.languageCode == 'en') return AppLocale.english;
    if (locale.languageCode == 'ar') return AppLocale.arabic;
    if (locale.languageCode != 'zh') return null;

    if (locale.scriptCode == 'Hans' ||
        locale.countryCode == 'CN' ||
        locale.countryCode == 'SG') {
      return AppLocale.simplifiedChinese;
    }
    return null;
  }

  static AppLocale resolve({
    String? savedTag,
    required Iterable<Locale> deviceLocales,
  }) {
    final saved = fromStorageTag(savedTag);
    if (saved != null) return saved;

    for (final locale in deviceLocales) {
      final match = fromDeviceLocale(locale);
      if (match != null) return match;
    }
    return AppLocale.english;
  }
}
