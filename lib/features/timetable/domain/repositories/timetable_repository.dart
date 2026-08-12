import '../entities/train_schedule.dart';

abstract class TimetableRepository {
  /// Ambil daftar jadwal kereta.
  ///
  /// [station] - nama stasiun (wajib jika memanggil remote).
  /// [trainType] - filter jenis kereta: 'KRL', 'LRT', 'MRT', atau null (semua).
  /// [isWeekend] - filter hari: true = weekend, false = weekday, null = semua.
  Future<List<TrainSchedule>> getSchedules({
    String? station,
    String? trainType,
    bool? isWeekend,
  });
}
