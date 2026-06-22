import '../../domain/entities/train_schedule.dart';

class TimetableLocalDataSource {
  const TimetableLocalDataSource();

  List<TrainSchedule> getSchedules() {
    return const [
      TrainSchedule(
        trainName: 'Argo Bromo',
        route: 'Gambir - Surabaya Pasar Turi',
        departureTime: '08:15',
        arrivalTime: '17:42',
        platform: '2',
      ),
      TrainSchedule(
        trainName: 'Taksaka',
        route: 'Gambir - Yogyakarta',
        departureTime: '09:30',
        arrivalTime: '15:51',
        platform: '4',
      ),
      TrainSchedule(
        trainName: 'Lodaya',
        route: 'Bandung - Solo Balapan',
        departureTime: '11:05',
        arrivalTime: '19:12',
        platform: '1',
      ),
    ];
  }
}
