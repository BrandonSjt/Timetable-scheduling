import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/route_result/domain/entities/route_plan.dart';
import 'package:timetable/features/route_result/domain/repositories/route_repository.dart';
import 'package:timetable/features/route_result/domain/services/route_speech_service.dart';
import 'package:timetable/features/route_result/presentation/controllers/route_controller.dart';
import 'package:timetable/features/route_result/presentation/pages/route_result_page.dart';
import 'package:timetable/features/route_result/presentation/pages/route_map_preview_page.dart';
import 'package:timetable/l10n/app_localizations.dart';
import 'helpers/route_test_data.dart';

class _Repository implements RouteRepository {
  _Repository(this.handler);
  final Future<RoutePlan> Function() handler;

  @override
  Future<RoutePlan> plan({
    required String from,
    required String to,
    required RoutePreference preference,
    int passengerCount = 1,
  }) => handler();
}

class _Speech implements RouteSpeechService {
  @override
  Future<void> pause() async {}
  @override
  Future<void> speak(String text, String languageCode) async {}
  @override
  Future<void> stop() async {}
}

Widget _page(RouteController controller) => MaterialApp(
  locale: const Locale('id'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: RouteResultPage(controller: controller, from: 'bogor', to: 'tangerang'),
);

void main() {
  testWidgets('route page renders loading and exact retry error', (
    tester,
  ) async {
    final pending = Completer<RoutePlan>();
    final loading = RouteController(
      _Repository(() => pending.future),
      _Speech(),
    );
    await tester.pumpWidget(_page(loading));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());

    final failing = RouteController(
      _Repository(() async => throw Exception('offline')),
      _Speech(),
    );
    await tester.pumpWidget(_page(failing));
    await tester.pumpAndSettle();
    expect(
      find.text('Tidak dapat memuat rute. Periksa koneksi dan coba lagi.'),
      findsOneWidget,
    );
    expect(find.text('Coba Lagi'), findsOneWidget);
    expect(find.text('Halim'), findsNothing);
  });

  testWidgets('route page renders backend result and accessible controls', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = RouteController(
      _Repository(() async => testRoute),
      _Speech(),
    );
    await tester.pumpWidget(_page(controller));
    await tester.pumpAndSettle();

    expect(find.text('Bogor'), findsWidgets);
    expect(find.text('Tangerang'), findsWidgets);
    expect(find.text('134'), findsOneWidget);
    expect(find.text('Rp10.000'), findsWidgets);
    expect(find.text('Pindah peron di Duri'), findsOneWidget);
    expect(find.text('Lanjut naik KRL Lin Tangerang'), findsOneWidget);
    expect(find.byKey(const Key('journey-map-preview-button')), findsOneWidget);
    expect(find.text('Urutan stasiun'), findsNothing);

    await tester.tap(find.text('Aksesibel'));
    await tester.pumpAndSettle();
    expect(find.text('Bacakan Rute'), findsOneWidget);
    expect(find.text('Ulangi'), findsOneWidget);
    expect(find.text('Jeda'), findsOneWidget);
    expect(find.text('Hentikan'), findsOneWidget);
  });

  testWidgets('route timeline marks a pedestrian transfer distinctly', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final controller = RouteController(
      _Repository(() async => testWalkingRoute),
      _Speech(),
    );

    await tester.pumpWidget(_page(controller));
    await tester.pumpAndSettle();

    expect(
      find.text('Berjalan dari Cikoko menuju Stasiun Cawang'),
      findsOneWidget,
    );
    expect(find.text('Lanjut naik KRL Lin Bogor'), findsOneWidget);
    expect(find.byKey(const ValueKey('route-timeline-walk-1')), findsOneWidget);
    expect(find.byKey(const Key('journey-map-preview-button')), findsNothing);
  });

  testWidgets('journey map preview focuses route lines and origin', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: RouteMapPreviewPage(route: testRoute),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Preview Line Perjalanan'), findsOneWidget);
    expect(find.text('You Are Here: Bogor'), findsOneWidget);
    expect(find.text('Lin Bogor'), findsOneWidget);
    expect(find.text('Lin Tangerang'), findsOneWidget);
    expect(find.text('Semua Line'), findsOneWidget);

    await tester.tap(find.text('Semua Line'));
    await tester.pump();
    expect(find.text('Fokus Perjalanan'), findsOneWidget);
  });
}
