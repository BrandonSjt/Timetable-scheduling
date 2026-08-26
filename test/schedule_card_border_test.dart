import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/core/theme/app_colors.dart';
import 'package:timetable/features/timetable/domain/entities/train_schedule.dart';
import 'package:timetable/features/timetable/presentation/widgets/schedule_card.dart';

import 'helpers/localized_test_app.dart';

void main() {
  testWidgets('schedule card outer border is visually distinct', (
    tester,
  ) async {
    await tester.pumpWidget(
      localizedTestApp(
        home: const Scaffold(
          body: ScheduleCard(
            schedule: TrainSchedule(
              trainName: 'KRL Commuter Line',
              route: 'Manggarai - Tanah Abang - Duri',
              departureTime: '06:00',
              arrivalTime: '06:12',
              platform: '6',
              trainType: 'KRL',
              stationName: 'Manggarai',
              isWeekend: false,
            ),
          ),
        ),
      ),
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

    expect(border.top.width, 1.25);
    expect(border.top.color, AppColors.primaryPurple.withValues(alpha: 0.24));
  });
}
