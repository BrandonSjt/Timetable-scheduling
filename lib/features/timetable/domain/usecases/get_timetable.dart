import '../entities/train_schedule.dart';
import '../repositories/timetable_repository.dart';

class GetTimetable {
  const GetTimetable(this.repository);

  final TimetableRepository repository;

  Future<List<TrainSchedule>> call({
    String? station,
    String? trainType,
    bool? isWeekend,
  }) {
    return repository.getSchedules(
      station: station,
      trainType: trainType,
      isWeekend: isWeekend,
    );
  }
}
