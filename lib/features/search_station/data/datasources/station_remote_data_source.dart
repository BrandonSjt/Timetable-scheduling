import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/station_model.dart';

class StationRemoteDataSource {
  StationRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();
  final http.Client _client;

  Future<List<StationModel>> getStations() async {
    final response = await _client
        .get(Uri.parse('${ApiConfig.baseUrl}/stations?limit=200'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat stasiun (${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return (body['data'] as List<dynamic>)
        .map((value) => StationModel.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }
}
