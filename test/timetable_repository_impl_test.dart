import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/timetable/data/datasources/timetable_local_data_source.dart';
import 'package:timetable/features/timetable/data/datasources/timetable_remote_data_source.dart';
import 'package:timetable/features/timetable/data/repositories/timetable_repository_impl.dart';
import 'package:timetable/features/timetable/domain/entities/train_schedule.dart';

class _Remote implements TimetableRemoteDataSource {
  _Remote(this.handler);

  final Future<List<TrainSchedule>> Function() handler;

  @override
  Future<List<TrainSchedule>> getSchedules({
    required String station,
    String? trainType,
    bool? isWeekend,
  }) => handler();
}

class _EmptyLocal implements TimetableLocalDataSource {
  const _EmptyLocal();

  @override
  List<TrainSchedule> getSchedules() => const [];
}

void main() {
  test('network failure with empty local fallback rethrows for retry UI', () async {
    final repository = TimetableRepositoryImpl(
      remoteDataSource: _Remote(
        () async => throw Exception('cold start timeout'),
      ),
      localDataSource: const _EmptyLocal(),
    );

    await expectLater(
      repository.getSchedules(station: 'Manggarai'),
      throwsA(isA<Exception>()),
    );
  });

  test('network failure keeps local schedules when available', () async {
    final repository = TimetableRepositoryImpl(
      remoteDataSource: _Remote(
        () async => throw Exception('cold start timeout'),
      ),
      localDataSource: const TimetableLocalDataSource(),
    );

    final schedules = await repository.getSchedules(station: 'Manggarai');
    expect(schedules, isNotEmpty);
    expect(schedules.every((item) => item.stationName == 'Manggarai'), isTrue);
  });
}
