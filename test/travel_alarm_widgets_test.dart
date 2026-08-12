import 'dart:ui' show SemanticsAction, Tristate;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/travel_alarm/presentation/widgets/travel_alarm_button.dart';
import 'package:timetable/features/travel_alarm/presentation/widgets/travel_alarm_disable_dialog.dart';
import 'package:timetable/features/travel_alarm/presentation/widgets/travel_alarm_setup_sheet.dart';

import 'localized_test_app.dart';

void main() {
  testWidgets('alarm setup enables both categories by default', (
    WidgetTester tester,
  ) async {
    TravelAlarmSelection? result;
    await tester.pumpWidget(
      LocalizedTestApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showTravelAlarmSetupSheet(
                  context,
                  from: 'Setiabudi',
                  to: 'Manggarai',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Aktifkan pengingat perjalanan?'), findsOneWidget);
    expect(find.text('Setiabudi ke Manggarai'), findsOneWidget);
    expect(
      tester
          .widget<Switch>(find.byKey(const Key('departure-alarm-toggle')))
          .value,
      isTrue,
    );
    expect(
      tester
          .widget<Switch>(find.byKey(const Key('destination-alarm-toggle')))
          .value,
      isTrue,
    );

    final departureSemantics = tester
        .getSemantics(find.bySemanticsLabel('Pengingat kereta datang'))
        .getSemanticsData();
    expect(departureSemantics.hasAction(SemanticsAction.tap), isTrue);
    expect(departureSemantics.flagsCollection.isToggled, Tristate.isTrue);

    await tester.tap(find.text('Aktifkan alarm'));
    await tester.pumpAndSettle();

    expect(
      result,
      const TravelAlarmSelection(departure: true, destination: true),
    );
  });

  testWidgets('alarm setup can skip without returning a selection', (
    WidgetTester tester,
  ) async {
    TravelAlarmSelection? result;
    await tester.pumpWidget(
      LocalizedTestApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showTravelAlarmSetupSheet(
                  context,
                  from: 'Setiabudi',
                  to: 'Manggarai',
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  testWidgets('alarm button exposes active and inactive semantics', (
    WidgetTester tester,
  ) async {
    var active = false;
    await tester.pumpWidget(
      LocalizedTestApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: TravelAlarmButton(
              isActive: active,
              onPressed: () => setState(() => active = !active),
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Aktifkan alarm perjalanan'), findsOneWidget);

    await tester.tap(find.byType(TravelAlarmButton));
    await tester.pump();

    expect(
      find.bySemanticsLabel(
        'Alarm perjalanan aktif, ketuk untuk menonaktifkan',
      ),
      findsOneWidget,
    );
  });

  testWidgets('disable dialog requires explicit confirmation', (
    WidgetTester tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      LocalizedTestApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showTravelAlarmDisableDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Matikan alarm perjalanan?'), findsOneWidget);
    expect(find.text('Kembali'), findsOneWidget);
    expect(find.text('Matikan alarm'), findsOneWidget);

    await tester.tap(find.text('Matikan alarm'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('alarm setup supports 200 percent text scaling', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      LocalizedTestApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showTravelAlarmSetupSheet(
                context,
                from: 'Setiabudi',
                to: 'Manggarai',
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Aktifkan pengingat perjalanan?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
