import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/core/localization/app_locale.dart';
import 'package:timetable/core/localization/locale_controller.dart';

import 'helpers/fake_locale_storage.dart';

void main() {
  group('LocaleController.load', () {
    test('uses a valid saved preference before device locales', () async {
      final storage = FakeLocaleStorage()..value = 'ar';

      final controller = await LocaleController.load(
        storage: storage,
        deviceLocales: const <Locale>[Locale('id')],
      );

      expect(controller.value, AppLocale.arabic);
      controller.dispose();
    });

    test('uses device locale when no preference exists', () async {
      final storage = FakeLocaleStorage();

      final controller = await LocaleController.load(
        storage: storage,
        deviceLocales: const <Locale>[Locale('zh', 'SG')],
      );

      expect(controller.value, AppLocale.simplifiedChinese);
      controller.dispose();
    });

    test('falls back safely when preference reading fails', () async {
      final storage = FakeLocaleStorage()
        ..readError = StateError('read failed');

      final controller = await LocaleController.load(
        storage: storage,
        deviceLocales: const <Locale>[Locale('en', 'US')],
      );

      expect(controller.value, AppLocale.english);
      controller.dispose();
    });
  });

  group('LocaleController.select', () {
    test('updates immediately and persists canonical tag', () async {
      final storage = FakeLocaleStorage();
      final controller = LocaleController(
        initialLocale: AppLocale.indonesian,
        storage: storage,
      );

      final saved = await controller.select(AppLocale.simplifiedChinese);

      expect(controller.value, AppLocale.simplifiedChinese);
      expect(storage.value, 'zh-Hans');
      expect(saved, isTrue);
      controller.dispose();
    });

    test('keeps in-session selection when persistence fails', () async {
      final storage = FakeLocaleStorage()
        ..writeError = StateError('write failed');
      final controller = LocaleController(
        initialLocale: AppLocale.indonesian,
        storage: storage,
      );

      final saved = await controller.select(AppLocale.arabic);

      expect(controller.value, AppLocale.arabic);
      expect(saved, isFalse);
      controller.dispose();
    });

    test('supports deterministic in-memory use without storage', () async {
      final controller = LocaleController(initialLocale: AppLocale.indonesian);

      expect(await controller.select(AppLocale.english), isTrue);
      expect(controller.value, AppLocale.english);
      controller.dispose();
    });
  });
}
