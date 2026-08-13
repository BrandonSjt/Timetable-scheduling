import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:timetable/features/search_station/data/datasources/station_remote_data_source.dart';

void main() {
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
