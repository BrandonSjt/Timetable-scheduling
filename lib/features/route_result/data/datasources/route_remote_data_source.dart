import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../domain/entities/route_plan.dart';
import '../models/route_plan_model.dart';

class RouteRequestException implements Exception {
  const RouteRequestException();
}

class RouteRemoteDataSource {
  RouteRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<RoutePlanModel> plan({
    required String from,
    required String to,
    required RoutePreference preference,
    int passengerCount = 1,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/routes/plan'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'from': from,
              'to': to,
              'passengerCount': passengerCount,
              'preference': preference.apiValue,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) throw const RouteRequestException();
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['success'] != true || body['data'] is! Map<String, dynamic>) {
        throw const RouteRequestException();
      }
      return RoutePlanModel.fromJson(body['data'] as Map<String, dynamic>);
    } on RouteRequestException {
      rethrow;
    } catch (_) {
      throw const RouteRequestException();
    }
  }
}
