import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/core/localization/app_locale.dart';

void main() {
  test('saved locale wins over device locale', () {
    expect(
      AppLocale.resolve(
        savedTag: 'ar',
        deviceLocales: const <Locale>[Locale('id')],
      ),
      AppLocale.arabic,
    );
  });

  test('resolves supported regional device locales', () {
    final cases = <Locale, AppLocale>{
      const Locale('id', 'ID'): AppLocale.indonesian,
      const Locale('en', 'US'): AppLocale.english,
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'):
          AppLocale.simplifiedChinese,
      const Locale('zh', 'CN'): AppLocale.simplifiedChinese,
      const Locale('zh', 'SG'): AppLocale.simplifiedChinese,
      const Locale('ar', 'EG'): AppLocale.arabic,
    };

    for (final entry in cases.entries) {
      expect(AppLocale.fromDeviceLocale(entry.key), entry.value);
    }
  });

  test('uses the first supported device locale', () {
    expect(
      AppLocale.resolve(
        deviceLocales: const <Locale>[Locale('fr'), Locale('ar', 'SA')],
      ),
      AppLocale.arabic,
    );
  });

  test('falls back to English for malformed and unsupported locales', () {
    for (final locale in const <Locale>[
      Locale('fr'),
      Locale('zh', 'TW'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
        countryCode: 'CN',
      ),
    ]) {
      expect(
        AppLocale.resolve(savedTag: 'broken', deviceLocales: <Locale>[locale]),
        AppLocale.english,
      );
    }
  });

  test('maps only canonical saved tags', () {
    expect(AppLocale.fromStorageTag('id'), AppLocale.indonesian);
    expect(AppLocale.fromStorageTag('en'), AppLocale.english);
    expect(AppLocale.fromStorageTag('zh-Hans'), AppLocale.simplifiedChinese);
    expect(AppLocale.fromStorageTag('ar'), AppLocale.arabic);
    expect(AppLocale.fromStorageTag('zh-TW'), isNull);
    expect(AppLocale.fromStorageTag(null), isNull);
  });
}
