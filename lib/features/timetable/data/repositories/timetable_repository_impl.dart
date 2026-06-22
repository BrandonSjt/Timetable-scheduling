import '../../domain/entities/train_schedule.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../datasources/timetable_local_data_source.dart';

class TimetableRepositoryImpl implements TimetableRepository {
  const TimetableRepositoryImpl(this.localDataSource);

  final TimetableLocalDataSource localDataSource;

  @override
  List<TrainSchedule> getSchedules() {
    return localDataSource.getSchedules();
  }
}
