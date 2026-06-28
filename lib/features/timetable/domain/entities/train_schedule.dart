class TrainSchedule {
  const TrainSchedule({
    required this.trainName,
    required this.route,
    required this.departureTime,
    required this.arrivalTime,
    required this.platform,
    required this.trainType,    // 'KRL', 'LRT', 'MRT'
    required this.stationName,  // 'Setiabudi', 'Cawang', 'Manggarai', 'Tanah Abang', 'Halim'
    required this.isWeekend,    // true = Weekend, false = Weekday
  });

  final String trainName;
  final String route;
  final String departureTime;
  final String arrivalTime;
  final String platform;
  final String trainType;
  final String stationName;
  final bool isWeekend;
}
