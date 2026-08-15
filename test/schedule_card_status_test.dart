import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/core/theme/app_colors.dart';
import 'package:timetable/features/timetable/domain/entities/train_schedule.dart';
import 'package:timetable/features/timetable/presentation/widgets/schedule_card.dart';

import 'helpers/localized_test_app.dart';

void main() {
  const schedule = TrainSchedule(
    trainName: 'KRL 1001',
    route: 'Bogor - Jakarta Kota',
    departureTime: '10:00',
    arrivalTime: '11:00',
    platform: '1',
    trainType: 'KRL',
    stationName: 'Bogor',
    isWeekend: false,
  );

  Future<void> pumpCard(
    WidgetTester tester, {
    required DateTime now,
    bool isNextUpcoming = false,
  }) {
    return tester.pumpWidget(
      localizedTestApp(
        home: Scaffold(
          body: ScheduleCard(
            schedule: schedule,
            now: now,
            isNextUpcoming: isNextUpcoming,
          ),
        ),
      ),
    );
  }

  testWidgets('shows schedule-based countdown status', (tester) async {
    await pumpCard(tester, now: DateTime(2026, 8, 15, 9, 53));

    expect(find.text('Berangkat 7 menit lagi'), findsOneWidget);
    expect(find.byKey(const Key('schedule-status')), findsOneWidget);
  });

  testWidgets('shows now status at departure time', (tester) async {
    await pumpCard(tester, now: DateTime(2026, 8, 15, 10));

    expect(find.text('Berangkat sekarang'), findsOneWidget);
  });

  testWidgets('de-emphasizes a passed schedule', (tester) async {
    await pumpCard(tester, now: DateTime(2026, 8, 15, 10, 2));

    expect(find.text('Jadwal lewat'), findsOneWidget);
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(ScheduleCard),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, lessThan(1));
  });

  testWidgets('highlights the nearest upcoming schedule', (tester) async {
    await pumpCard(
      tester,
      now: DateTime(2026, 8, 15, 9, 53),
      isNextUpcoming: true,
    );

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(ScheduleCard),
            matching: find.byType(Container),
          )
          .first,
    );
    final border = (container.decoration! as BoxDecoration).border! as Border;
    expect(border.top.color, AppColors.primaryBlue);
    expect(border.top.width, 1.75);
  });
}
