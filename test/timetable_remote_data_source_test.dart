import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:timetable/features/timetable/data/datasources/timetable_remote_data_source.dart';

Map<String, dynamic> _schedule(String id) => {
  'id': id,
  'trainName': 'KA $id',
  'route': 'Jurangmangu - Tanah Abang',
  'departureTime': '00:10',
  'arrivalTime': '00:40',
  'platform': '',
  'trainType': 'KRL',
  'isWeekend': false,
  'dayOffset': 1,
  'station': {'name': 'Jurangmangu'},
};

http.Response _page(
  int page,
  List<String> ids, {
  int total = 3,
  String version = '2026-02',
}) => http.Response(
  jsonEncode({
    'data': ids.map(_schedule).toList(),
    'meta': {'page': page, 'total': total, 'datasetVersion': version},
  }),
  200,
);

void main() {
  test(
    'loads every page, keeps station/day/type filters and overnight offset',
    () async {
      final requested = <int>[];
      final source = TimetableRemoteDataSource(
        client: MockClient((request) async {
          final q = request.url.queryParameters;
          expect(q['station'], 'Jurangmangu');
          expect(q['trainType'], 'KRL');
          expect(q['isWeekend'], 'false');
          final page = int.parse(q['page']!);
          requested.add(page);
          return page == 1 ? _page(1, ['1', '2']) : _page(2, ['3']);
        }),
      );
      final schedules = await source.getSchedules(
        station: 'Jurangmangu',
        trainType: 'KRL',
        isWeekend: false,
      );
      expect(requested, [1, 2]);
      expect(schedules.length, 3);
      expect(schedules.last.dayOffset, 1);
    },
  );

  test('all stations omits station and loads global services', () async {
    final source = TimetableRemoteDataSource(
      client: MockClient((request) async {
        expect(request.url.queryParameters.containsKey('station'), false);
        return _page(1, [], total: 0);
      }),
    );
    expect(await source.getSchedules(station: 'Semua Stasiun'), isEmpty);
  });

  for (final failure in [
    'http',
    'empty',
    'changed',
    'duplicate',
    'wrong-page',
  ]) {
    test('refuses partial schedules after $failure on later page', () async {
      final source = TimetableRemoteDataSource(
        client: MockClient((request) async {
          if (request.url.queryParameters['page'] == '1') {
            return _page(1, ['1', '2']);
          }
          return switch (failure) {
            'http' => http.Response('{}', 503),
            'empty' => _page(2, []),
            'changed' => _page(2, ['3'], version: '2026-03'),
            'duplicate' => _page(2, ['2']),
            _ => _page(1, ['3']),
          };
        }),
      );
      await expectLater(source.getSchedules(), throwsException);
    });
  }
}
