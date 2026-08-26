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
///   - station: nama stasiun (required jika stationId tidak disediakan)
///   - trainType: 'KRL' | 'LRT' | 'MRT' (opsional)
///   - isWeekend: 'true' | 'false' (opsional)
///   - limit: jumlah maksimal hasil (default 100)
class TimetableRemoteDataSource {
  TimetableRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<TrainSchedule>> getSchedules({
    required String station,
    String? trainType,
    bool? isWeekend,
  }) async {
    final queryParams = <String, String>{'station': station, 'limit': '100'};
    if (trainType != null && trainType != 'Semua') {
      queryParams['trainType'] = trainType;
    }
    if (isWeekend != null) {
      queryParams['isWeekend'] = isWeekend.toString();
    }

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/schedules',
    ).replace(queryParameters: queryParams);

    final response = await _client
        .get(uri, headers: {'Content-Type': 'application/json'})
        .timeout(ApiTimeouts.request);

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>;
      return data
          .map(
            (item) => TrainScheduleModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception(
        'Gagal memuat jadwal dari server (status: ${response.statusCode})',
      );
    }
  }
}
