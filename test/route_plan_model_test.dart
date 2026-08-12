import 'package:flutter_test/flutter_test.dart';
import 'package:timetable/features/route_result/data/models/route_plan_model.dart';
import 'package:timetable/features/route_result/domain/entities/route_plan.dart';

const routeFixture = <String, dynamic>{
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
  'preference': 'FASTEST',
  'steps': [
    {
      'text': 'Naik dari Bogor',
      'durationText': '0 menit',
      'detailNote': 'KRL Lin Bogor',
      'icon': 'train',
      'color': '#E53935',
      'isHeader': true,
      'isTransit': false,
      'isDestination': false,
    },
    {
      'text': 'Transit di Duri',
      'durationText': '5 menit',
      'detailNote': 'Pindah ke KRL Lin Tangerang',
      'icon': 'directions_walk',
      'color': '#8E44AD',
      'isHeader': false,
      'isTransit': true,
      'isDestination': false,
    },
    {
      'text': 'Tiba di Tangerang',
      'durationText': '134 menit',
      'detailNote': 'Tujuan',
      'icon': 'place',
      'color': '#DC2626',
      'isHeader': false,
      'isTransit': false,
      'isDestination': true,
    },
  ],
  'stationSequence': [
    {
      'stationId': 'station-bogor',
      'name': 'Bogor',
      'nodeCode': 'B26',
      'line': {
        'id': 'line-bogor',
        'slug': 'bogor',
        'name': 'KRL Lin Bogor',
        'color': '#E53935',
        'serviceType': 'KRL',
      },
    },
    {
      'stationId': 'station-tangerang',
      'name': 'Tangerang',
      'nodeCode': 'T01',
      'line': {
        'id': 'line-tangerang',
        'slug': 'tangerang',
        'name': 'KRL Lin Tangerang',
        'color': '#8E44AD',
        'serviceType': 'KRL',
      },
    },
  ],
  'exitGateA': 'Pintu utama',
  'exitGateB': 'Area antar-jemput',
};

void main() {
  test('route plan model maps the complete backend response', () {
    final route = RoutePlanModel.fromJson(routeFixture);
    expect(route.from, 'Bogor');
    expect(route.to, 'Tangerang');
    expect(route.preference, RoutePreference.fastest);
    expect(route.transferCount, 1);
    expect(
      route.steps.singleWhere((step) => step.isTransit).text,
      contains('Transit'),
    );
    expect(route.stationSequence.first.line.slug, 'bogor');
  });
}
