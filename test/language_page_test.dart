import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/core/localization/app_locale.dart';
import 'package:timetable/core/localization/locale_controller.dart';
import 'package:timetable/core/routing/router.dart';
import 'package:timetable/main.dart';

import 'helpers/fake_locale_storage.dart';

void main() {
  testWidgets('injected locale controls MaterialApp', (tester) async {
    final controller = LocaleController(initialLocale: AppLocale.arabic);
    addTearDown(controller.dispose);

    await tester.pumpWidget(MyApp(localeController: controller));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      AppLocale.arabic.locale,
    );
  });

  testWidgets('default test app remains Indonesian', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).locale,
      AppLocale.indonesian.locale,
    );
  });

  testWidgets('language page offers and persists all four locales', (
    tester,
  ) async {
    final storage = FakeLocaleStorage();
    final controller = LocaleController(
      initialLocale: AppLocale.indonesian,
      storage: storage,
    );
    addTearDown(controller.dispose);
    appRouter.go('/bahasa');

    await tester.pumpWidget(MyApp(localeController: controller));
    await tester.pumpAndSettle();

    for (final label in const <String>[
      'Indonesia',
      'English',
      '简体中文',
      'العربية',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.text('简体中文'));
    await tester.pumpAndSettle();

    expect(storage.value, 'zh-Hans');
    expect(controller.value, AppLocale.simplifiedChinese);
    expect(find.text('应用程序语言'), findsOneWidget);
  });

  testWidgets('profile shows the active localized language name', (
    tester,
  ) async {
    final controller = LocaleController(
      initialLocale: AppLocale.simplifiedChinese,
    );
    addTearDown(controller.dispose);
    appRouter.go('/akun');

    await tester.pumpWidget(MyApp(localeController: controller));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('简体中文'), findsOneWidget);
  });

  testWidgets(
    'write failure keeps Arabic active and shows localized feedback',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final storage = FakeLocaleStorage()
        ..writeError = StateError('write failed');
      final controller = LocaleController(
        initialLocale: AppLocale.indonesian,
        storage: storage,
      );
      addTearDown(controller.dispose);
      appRouter.go('/bahasa');

      await tester.pumpWidget(MyApp(localeController: controller));
      await tester.pumpAndSettle();
      await tester.tap(find.text('العربية'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.value, AppLocale.arabic);
      expect(
        find.text('تم تغيير اللغة لهذه الجلسة، ولكن لا يمكن حفظ تفضيلاتك.'),
        findsOneWidget,
      );
      final context = tester.element(find.byType(Scaffold).first);
      expect(Directionality.of(context), TextDirection.ltr);
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);

      appRouter.go('/');
      await tester.pumpAndSettle();
      final homeContext = tester.element(find.byType(Scaffold).first);
      expect(Directionality.of(homeContext), TextDirection.ltr);
      expect(
        tester.getCenter(find.byIcon(Icons.calendar_month_outlined)).dx,
        lessThan(tester.getCenter(find.byIcon(Icons.person_outline_rounded)).dx),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
