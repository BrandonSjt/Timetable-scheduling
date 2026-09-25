import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:timetable/features/search_station/data/datasources/station_remote_data_source.dart';

void main() {
  test(
    'station catalogue follows pages instead of losing later stations',
    () async {
      final source = StationRemoteDataSource(
        client: MockClient((request) async {
          final page = int.parse(request.url.queryParameters['page']!);
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': '$page',
                  'slug': page == 1 ? 'bogor' : 'jurangmangu',
                  'name': page == 1 ? 'Bogor' : 'Jurangmangu',
                  'isKrl': true,
                },
              ],
              'meta': {'page': page, 'total': 2},
            }),
            200,
          );
        }),
      );
      expect((await source.getStations()).map((s) => s.slug), [
        'bogor',
        'jurangmangu',
      ]);
    },
  );
  test('remote station catalog parses backend envelope', () async {
    final source = StationRemoteDataSource(
      client: MockClient(
        (_) async => http.Response(
          '{"success":true,"data":[{"id":"1","slug":"bogor","name":"Bogor","shortName":"Bogor","officialName":"Bogor","operationalCode":"BOO","isKrl":true,"isAccessible":true,"publicCodes":[{"code":"B26"}]}]}',
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    final stations = await source.getStations();
    expect(stations.single.slug, 'bogor');
    expect(stations.single.codes, 'B26');
  });
}
