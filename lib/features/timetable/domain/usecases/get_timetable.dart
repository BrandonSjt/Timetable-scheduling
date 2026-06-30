import '../entities/train_schedule.dart';
import '../repositories/timetable_repository.dart';

class GetTimetable {
  const GetTimetable(this.repository);

  final TimetableRepository repository;

  List<TrainSchedule> call() {
    return repository.getSchedules();
  }
}
