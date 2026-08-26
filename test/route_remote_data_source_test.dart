import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:timetable/core/config/api_config.dart';
import 'package:timetable/features/route_result/data/datasources/route_remote_data_source.dart';
import 'package:timetable/features/route_result/domain/entities/route_plan.dart';

const _response = {
  'success': true,
  'data': {
    'from': 'Bogor',
    'to': 'Tangerang',
    'travelTime': 134,
    'fare': 10000,
    'unitFare': 10000,
    'currency': 'IDR',
    'passengerCount': 1,
    'stops': 31,
    'serviceInfo': 'Layanan normal',
    'hasTransit': true,
    'transferCount': 1,
    'preference': 'MIN_TRANSFERS',
    'steps': <Map<String, dynamic>>[],
    'stationSequence': <Map<String, dynamic>>[],
    'exitGateA': 'Pintu utama',
    'exitGateB': 'Area antar-jemput',
  },
};

void main() {
  test(
    'route source posts stable identities and selected preference',
    () async {
      http.Request? captured;
      final source = RouteRemoteDataSource(
        client: MockClient((request) async {
          captured = request;
          return http.Response(jsonEncode(_response), 200);
        }),
      );

      final route = await source.plan(
        from: 'bogor',
        to: 'tangerang',
        preference: RoutePreference.minimumTransfers,
      );

      expect(captured!.method, 'POST');
      expect(captured!.url.toString(), '${ApiConfig.baseUrl}/routes/plan');
      expect(jsonDecode(captured!.body), {
        'from': 'bogor',
        'to': 'tangerang',
        'passengerCount': 1,
        'preference': 'MIN_TRANSFERS',
      });
      expect(route.preference, RoutePreference.minimumTransfers);
    },
  );

  test('route source converts non-success response into domain failure', () {
    final source = RouteRemoteDataSource(
      client: MockClient((_) async => http.Response('{}', 503)),
    );

    expect(
      () => source.plan(
        from: 'bogor',
        to: 'tangerang',
        preference: RoutePreference.fastest,
      ),
      throwsA(isA<RouteRequestException>()),
    );
  });
}
