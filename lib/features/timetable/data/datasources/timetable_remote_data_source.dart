import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_timeouts.dart';
import '../../domain/entities/train_schedule.dart';
import '../models/train_schedule_model.dart';

/// Remote data source yang memanggil backend API Express.
///
/// Endpoint: GET /api/v1/schedules
/// Query params:
///   - station: nama stasiun (opsional; kosong = semua perjalanan KA)
///   - trainType: 'KRL' | 'LRT' | 'MRT' (opsional)
///   - isWeekend: 'true' | 'false' (opsional)
///   - limit: jumlah maksimal hasil (default 100)
class TimetableRemoteDataSource {
  TimetableRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<TrainSchedule>> getSchedules({
    String? station,
    String? trainType,
    bool? isWeekend,
  }) async {
    final queryParams = <String, String>{'limit': '100'};
    if (station != null && station != 'Semua Stasiun') {
      queryParams['station'] = station;
    }
    if (trainType != null && trainType != 'Semua') {
      queryParams['trainType'] = trainType;
    }
    if (isWeekend != null) {
      queryParams['isWeekend'] = isWeekend.toString();
    }

    final schedules = <TrainSchedule>[];
    int? total;
    String? datasetVersion;
    var page = 1;
    final seenIds = <String>{};
    while (true) {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/schedules',
      ).replace(queryParameters: {...queryParams, 'page': '$page'});
      final response = await _client
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(ApiTimeouts.request);

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memuat jadwal dari server (status: ${response.statusCode})',
        );
      }
      final body = json.decode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>;
      final meta = body['meta'] as Map<String, dynamic>?;
      final currentTotal = meta?['total'] as int?;
      final currentVersion = meta?['datasetVersion'] as String?;
      if (meta?['page'] != null && meta!['page'] != page) {
        throw Exception('Halaman jadwal tidak konsisten.');
      }
      for (final item in data) {
        final id = (item as Map<String, dynamic>)['id'] as String?;
        if (id != null && !seenIds.add(id)) {
          throw Exception('Jadwal duplikat saat dimuat. Coba lagi.');
        }
      }
      if (page > 1 &&
          (currentTotal != total || currentVersion != datasetVersion)) {
        throw Exception('Dataset jadwal berubah saat dimuat. Coba lagi.');
      }
      total = currentTotal;
      datasetVersion = currentVersion;
      if (data.isEmpty && total != null && schedules.length < total) {
        throw Exception('Jadwal belum lengkap. Coba lagi.');
      }
      schedules.addAll(
        data
            .map(
              (item) =>
                  TrainScheduleModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
      );
      if (total == null || schedules.length == total) return schedules;
      if (schedules.length > total) {
        throw Exception('Jumlah jadwal tidak konsisten.');
      }
      ++page;
    }
  }
}
