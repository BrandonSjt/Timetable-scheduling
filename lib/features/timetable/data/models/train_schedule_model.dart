import '../../domain/entities/train_schedule.dart';

/// Model untuk parsing JSON response dari backend API.
///
/// Contoh response JSON per item dari GET /api/v1/schedules:
/// ```json
/// {
///   "id": "uuid",
///   "trainName": "KRL Commuter Line",
///   "route": "Manggarai - Jakarta Kota",
///   "departureTime": "06:05",
///   "arrivalTime": "06:15",
///   "platform": "10",
///   "trainType": "KRL",
///   "isWeekend": false,
///   "station": { "name": "Manggarai", ... }
/// }
/// ```
class TrainScheduleModel extends TrainSchedule {
  const TrainScheduleModel({
    required super.trainName,
    required super.route,
    required super.departureTime,
    required super.arrivalTime,
    required super.platform,
    required super.trainType,
    required super.stationName,
    required super.isWeekend,
  });

  factory TrainScheduleModel.fromJson(Map<String, dynamic> json) {
    // stationName diambil dari nested station.name jika ada,
    // fallback ke string kosong jika tidak ada relasi station.
    final stationMap = json['station'] as Map<String, dynamic>?;
    final stationName = (stationMap?['name'] as String?) ?? '';

    return TrainScheduleModel(
      trainName: (json['trainName'] as String?) ?? '',
      route: (json['route'] as String?) ?? '',
      departureTime: (json['departureTime'] as String?) ?? '',
      arrivalTime: (json['arrivalTime'] as String?) ?? '',
      platform: (json['platform'] as String?) ?? '',
      trainType: (json['trainType'] as String?) ?? '',
      stationName: stationName,
      isWeekend: (json['isWeekend'] as bool?) ?? false,
    );
  }
}
