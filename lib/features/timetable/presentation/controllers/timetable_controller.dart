import '../../data/datasources/timetable_local_data_source.dart';
import '../../data/repositories/timetable_repository_impl.dart';
import '../../domain/entities/train_schedule.dart';
import '../../domain/usecases/get_timetable.dart';

class TimetableController {
  TimetableController()
    : _getTimetable = GetTimetable(
        const TimetableRepositoryImpl(TimetableLocalDataSource()),
      );

  final GetTimetable _getTimetable;

  List<TrainSchedule> loadSchedules() {
    return _getTimetable();
  }
}
