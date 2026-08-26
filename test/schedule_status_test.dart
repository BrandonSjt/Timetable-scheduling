import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/timetable/domain/entities/train_schedule.dart';
import 'package:timetable/features/timetable/domain/services/schedule_status.dart';

void main() {
  const baseSchedule = TrainSchedule(
    trainName: 'KRL 1001',
    route: 'Bogor - Jakarta Kota',
    departureTime: '10:00',
    arrivalTime: '11:00',
    platform: '1',
    trainType: 'KRL',
    stationName: 'Bogor',
    isWeekend: false,
  );

  group('ScheduleStatusCalculator', () {
    test('shows a countdown when departure is more than five minutes away', () {
      final status = ScheduleStatusCalculator.calculate(
        schedule: baseSchedule,
        now: DateTime(2026, 8, 15, 9, 53),
      );

      expect(status.label, 'Berangkat 7 menit lagi');
      expect(status.kind, ScheduleStatusKind.upcoming);
      expect(status.hasDeparted, isFalse);
    });

    test('shows soon inside the five-minute window', () {
      final status = ScheduleStatusCalculator.calculate(
        schedule: baseSchedule,
        now: DateTime(2026, 8, 15, 9, 57),
      );

      expect(status.label, 'Segera berangkat');
      expect(status.kind, ScheduleStatusKind.soon);
    });

    test('shows now inside the one-minute tolerance', () {
      for (final now in [
        DateTime(2026, 8, 15, 9, 59),
        DateTime(2026, 8, 15, 10),
        DateTime(2026, 8, 15, 10, 1),
      ]) {
        final status = ScheduleStatusCalculator.calculate(
          schedule: baseSchedule,
          now: now,
        );
        expect(status.label, 'Berangkat sekarang');
        expect(status.kind, ScheduleStatusKind.now);
      }
    });

    test('marks a schedule as passed after the tolerance', () {
      final status = ScheduleStatusCalculator.calculate(
        schedule: baseSchedule,
        now: DateTime(2026, 8, 15, 10, 2),
      );

      expect(status.label, 'Jadwal lewat');
      expect(status.kind, ScheduleStatusKind.passed);
      expect(status.hasDeparted, isTrue);
    });

    test('honors dayOffset for after-midnight service calls', () {
      const nextDay = TrainSchedule(
        trainName: 'KRL 1002',
        route: 'Jakarta Kota - Bogor',
        departureTime: '00:05',
        arrivalTime: '01:15',
        platform: '2',
        trainType: 'KRL',
        stationName: 'Jakarta Kota',
        isWeekend: false,
        dayOffset: 1,
      );

      final status = ScheduleStatusCalculator.calculate(
        schedule: nextDay,
        now: DateTime(2026, 8, 15, 23, 59),
      );

      expect(status.label, 'Berangkat 6 menit lagi');
      expect(status.departureAt, DateTime(2026, 8, 16, 0, 5));
    });

    test('handles malformed departure time without crashing', () {
      const invalid = TrainSchedule(
        trainName: 'KRL 1003',
        route: 'Bogor - Jakarta Kota',
        departureTime: '--',
        arrivalTime: '--',
        platform: '-',
        trainType: 'KRL',
        stationName: 'Bogor',
        isWeekend: false,
      );

      final status = ScheduleStatusCalculator.calculate(
        schedule: invalid,
        now: DateTime(2026, 8, 15, 10),
      );

      expect(status.kind, ScheduleStatusKind.unavailable);
      expect(status.label, 'Status jadwal tidak tersedia');
    });
  });
}
