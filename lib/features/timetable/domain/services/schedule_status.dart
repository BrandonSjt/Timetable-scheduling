import '../entities/train_schedule.dart';

enum ScheduleStatusKind { upcoming, soon, now, passed, unavailable }

class ScheduleStatus {
  const ScheduleStatus({
    required this.label,
    required this.kind,
    required this.departureAt,
  });

  final String label;
  final ScheduleStatusKind kind;
  final DateTime? departureAt;

  bool get hasDeparted => kind == ScheduleStatusKind.passed;
}

abstract final class ScheduleStatusCalculator {
  static ScheduleStatus calculate({
    required TrainSchedule schedule,
    required DateTime now,
    DateTime? serviceDate,
  }) {
    final parts = schedule.departureTime.split(':');
    if (parts.length != 2) return _unavailable;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return _unavailable;
    }

    final base = serviceDate ?? now;
    final departureAt = DateTime(
      base.year,
      base.month,
      base.day + schedule.dayOffset,
      hour,
      minute,
    );
    final secondsUntil = departureAt.difference(now).inSeconds;

    if (secondsUntil > 300) {
      final minutes = (secondsUntil / 60).ceil();
      return ScheduleStatus(
        label: 'Berangkat $minutes menit lagi',
        kind: ScheduleStatusKind.upcoming,
        departureAt: departureAt,
      );
    }
    if (secondsUntil > 60) {
      return ScheduleStatus(
        label: 'Segera berangkat',
        kind: ScheduleStatusKind.soon,
        departureAt: departureAt,
      );
    }
    if (secondsUntil >= -60) {
      return ScheduleStatus(
        label: 'Berangkat sekarang',
        kind: ScheduleStatusKind.now,
        departureAt: departureAt,
      );
    }
    return ScheduleStatus(
      label: 'Jadwal lewat',
      kind: ScheduleStatusKind.passed,
      departureAt: departureAt,
    );
  }

  static const _unavailable = ScheduleStatus(
    label: 'Status jadwal tidak tersedia',
    kind: ScheduleStatusKind.unavailable,
    departureAt: null,
  );
}
