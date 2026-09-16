import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_timeouts.dart';
import '../models/station_model.dart';

class StationRemoteDataSource {
  StationRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<StationModel>> getStations() async {
    final stations = <StationModel>[];
    final seenIds = <String>{};
    int? total;
    var page = 1;
    while (true) {
      final response = await _client
          .get(Uri.parse('${ApiConfig.baseUrl}/stations?limit=200&page=$page'))
          .timeout(ApiTimeouts.request);
      if (response.statusCode != 200) {
        throw Exception('Gagal memuat stasiun (${response.statusCode})');
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>;
      final meta = body['meta'] as Map<String, dynamic>?;
      final currentTotal = meta?['total'] as int?;
      if ((page > 1 && total != currentTotal) ||
          (meta?['page'] != null && meta!['page'] != page)) {
        throw Exception('Katalog stasiun berubah saat dimuat. Coba lagi.');
      }
      total = currentTotal;
      if (data.isEmpty && total != null && stations.length < total) {
        throw Exception('Katalog stasiun belum lengkap.');
      }
      for (final value in data) {
        final id = (value as Map<String, dynamic>)['id'] as String;
        if (!seenIds.add(id)) {
          throw Exception('Katalog stasiun duplikat.');
        }
      }
      stations.addAll(
        data
            .map(
              (value) => StationModel.fromJson(value as Map<String, dynamic>),
            )
            .toList(growable: false),
      );
      if (total == null || stations.length == total) return stations;
      if (stations.length > total) {
        throw Exception('Jumlah stasiun tidak konsisten.');
      }
      ++page;
    }
  }
}
