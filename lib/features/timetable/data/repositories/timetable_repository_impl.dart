import '../../domain/entities/train_schedule.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../datasources/timetable_local_data_source.dart';
import '../datasources/timetable_remote_data_source.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  const TimetableRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final TimetableRemoteDataSource remoteDataSource;
  final TimetableLocalDataSource localDataSource;

  @override
  Future<List<TrainSchedule>> getSchedules({
    String? station,
    String? trainType,
    bool? isWeekend,
  }) async {
    // Never substitute example schedules for missing/failed official data.
    return remoteDataSource.getSchedules(
      station: station == 'Semua Stasiun' ? null : station,
      trainType: trainType,
      isWeekend: isWeekend,
    );
  }
}
