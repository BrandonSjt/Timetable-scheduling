import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timetable/core/theme/app_colors.dart';
import 'package:timetable/l10n/app_localizations.dart';
import 'package:timetable/shared/widgets/bottom_nav_bar.dart';

Widget _localized(
  Widget child, {
  Locale locale = const Locale('id'),
  double textScale = 1,
  double bottomPadding = 0,
}) => MaterialApp(
  locale: locale,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      padding: EdgeInsets.only(bottom: bottomPadding),
    ),
    child: child!,
  ),
  home: Scaffold(bottomNavigationBar: child),
);

void main() {
  final indicator = find.byKey(const ValueKey('bottom-nav-active-indicator'));

  testWidgets('four short rounded side separators replace the boxed borders', (
    tester,
  ) async {
    await tester.pumpWidget(_localized(const AppBottomNavBar(currentIndex: 3)));
    for (var index = 0; index < 4; index++) {
      final finder = find.byKey(ValueKey('bottom-nav-item-separator-$index'));
      expect(finder, findsOneWidget);
      final decoration =
          tester.widget<Container>(finder).decoration! as BoxDecoration;
      expect(decoration.color, AppColors.textHint.withValues(alpha: 0.4));
      expect(decoration.borderRadius, BorderRadius.circular(1));
      expect(tester.getSize(finder), const Size(1, 28));
    }
    expect(
      find.byKey(const ValueKey('bottom-nav-item-separator-4')),
      findsNothing,
    );
    for (var index = 0; index < 5; index++) {
      expect(
        find.byKey(ValueKey('bottom-nav-item-border-$index')),
        findsNothing,
      );
    }
  });

  testWidgets('navbar has no full-width top border', (tester) async {
    await tester.pumpWidget(_localized(const AppBottomNavBar(currentIndex: 0)));

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AppBottomNavBar),
            matching: find.byType(Container),
          )
          .first,
    );
    expect((container.decoration! as BoxDecoration).border, isNull);
  });

  testWidgets(
    'active tab keeps purple icon and label without a top indicator',
    (tester) async {
      const labels = ['Beranda', 'Jadwal', 'Tiket', 'Asisten', 'Akun'];
      for (var index = 0; index < labels.length; index++) {
        await tester.pumpWidget(
          _localized(AppBottomNavBar(currentIndex: index)),
        );
        await tester.pumpAndSettle();

        expect(indicator, findsNothing);
        final activeLabel = tester.widget<Text>(find.text(labels[index]));
        expect(activeLabel.style!.color, AppColors.primaryPurple);
        expect(activeLabel.style!.fontWeight, FontWeight.w700);

        final icons = find.descendant(
          of: find.byType(AppBottomNavBar),
          matching: find.byType(Icon),
        );
        final iconY = tester.getCenter(icons.first).dy;
        for (var i = 0; i < labels.length; i++) {
          expect(tester.getCenter(icons.at(i)).dy, iconY);
          expect(
            tester.widget<Icon>(icons.at(i)).color,
            i == index ? AppColors.primaryPurple : AppColors.textHint,
          );
        }
      }
    },
  );

  testWidgets('navbar fits small screens, large text, and every locale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final locale in AppLocalizations.supportedLocales) {
      await tester.pumpWidget(
        _localized(
          const AppBottomNavBar(currentIndex: 2),
          locale: locale,
          textScale: 2,
          bottomPadding: 24,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull, reason: locale.toString());
      expect(indicator, findsNothing);
      expect(tester.getSize(find.byType(AppBottomNavBar)).height, 124);
      final targets = find.descendant(
        of: find.byType(AppBottomNavBar),
        matching: find.byType(GestureDetector),
      );
      for (var i = 0; i < 5; i++) {
        expect(tester.getSize(targets.at(i)).width, greaterThanOrEqualTo(48));
        expect(tester.getSize(targets.at(i)).height, greaterThanOrEqualTo(48));
      }
    }
  });

  testWidgets('navbar is a flat five-item row with Home first', (tester) async {
    await tester.pumpWidget(_localized(const AppBottomNavBar(currentIndex: 0)));
    await tester.pumpAndSettle();

    const labels = ['Beranda', 'Jadwal', 'Tiket', 'Asisten', 'Akun'];
    final centers = labels
        .map((label) => tester.getCenter(find.text(label)).dx)
        .toList();

    expect(centers, orderedEquals([...centers]..sort()));
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    expect(find.byType(ClipPath), findsNothing);
  });

  testWidgets('navbar keeps the existing timetable route', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: Text('home route'),
            bottomNavigationBar: AppBottomNavBar(currentIndex: 0),
          ),
        ),
        GoRoute(
          path: '/timetable',
          builder: (_, _) => const Scaffold(
            body: Text('timetable route'),
            bottomNavigationBar: AppBottomNavBar(currentIndex: 1),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('id'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jadwal'));
    await tester.pumpAndSettle();

    expect(find.text('timetable route'), findsOneWidget);
    expect(indicator, findsNothing);
    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
  });
}
