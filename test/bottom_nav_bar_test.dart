import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:timetable/core/theme/app_colors.dart';
import 'package:timetable/l10n/app_localizations.dart';
import 'package:timetable/shared/widgets/bottom_nav_bar.dart';

Widget _localized(Widget child) => MaterialApp(
  locale: const Locale('id'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(bottomNavigationBar: child),
);

void main() {
  testWidgets('navbar has a one-pixel top border', (tester) async {
    await tester.pumpWidget(_localized(const AppBottomNavBar(currentIndex: 0)));

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AppBottomNavBar),
            matching: find.byType(Container),
          )
          .first,
    );
    final border = (container.decoration! as BoxDecoration).border! as Border;

    expect(border.top.width, 1);
    expect(border.top.color, AppColors.cardBorder);
    expect(border.bottom.width, 0);
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
          builder: (_, _) => const Scaffold(body: Text('timetable route')),
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
  });
}
