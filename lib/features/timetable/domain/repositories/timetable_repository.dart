import '../entities/train_schedule.dart';

abstract class TimetableRepository {
  List<TrainSchedule> getSchedules();
}
