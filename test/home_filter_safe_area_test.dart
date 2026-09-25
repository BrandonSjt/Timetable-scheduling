import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/core/routing/router.dart';
import 'package:timetable/main.dart';

void main() {
  for (final scale in [1.0, 2.0]) {
    testWidgets(
      'filter respects bottom navigation inset and scrolls at scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(390, 700);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(bottom: 32);
        tester.view.viewPadding = const FakeViewPadding(bottom: 32);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        appRouter.go('/');
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.menu_rounded));
        await tester.pumpAndSettle();
        final list = find.descendant(
          of: find.byType(Drawer),
          matching: find.byType(ListView),
        );
        expect(tester.getRect(list).bottom, lessThanOrEqualTo(668));
        final option = find.byKey(const ValueKey('home-filter-lrt_jakarta'));
        await tester.scrollUntilVisible(
          option,
          500,
          scrollable: find
              .descendant(
                of: find.byType(Drawer),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(option).bottom, lessThanOrEqualTo(656));
        expect(tester.getRect(option).height, greaterThanOrEqualTo(48));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
