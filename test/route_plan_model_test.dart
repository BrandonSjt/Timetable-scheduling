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
      'kind': 'board',
      'isWalking': false,
      'text': 'Naik dari Bogor',
      'durationText': '105 menit',
      'detailNote': 'KRL Lin Bogor menuju Duri',
      'icon': 'train',
      'color': '#E53935',
      'isHeader': true,
      'isTransit': false,
      'isDestination': false,
    },
    {
      'kind': 'transfer',
      'isWalking': false,
      'text': 'Pindah peron di Duri',
      'durationText': '5 menit',
      'detailNote': 'Pindah ke KRL Lin Tangerang',
      'icon': 'directions_walk',
      'color': '#8E44AD',
      'isHeader': false,
      'isTransit': true,
      'isDestination': false,
    },
    {
      'kind': 'continue',
      'isWalking': false,
      'text': 'Lanjut naik KRL Lin Tangerang',
      'durationText': '24 menit',
      'detailNote': 'Dari Duri menuju Tangerang',
      'icon': 'train',
      'color': '#8E44AD',
      'isHeader': false,
      'isTransit': false,
      'isDestination': false,
    },
    {
      'kind': 'arrive',
      'isWalking': false,
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
    expect(route.steps.map((step) => step.kind), [
      RouteStepKind.board,
      RouteStepKind.transfer,
      RouteStepKind.continueTrip,
      RouteStepKind.arrive,
    ]);
    expect(
      route.steps
          .singleWhere((step) => step.kind == RouteStepKind.transfer)
          .isWalking,
      isFalse,
    );
    expect(route.stationSequence.first.line.slug, 'bogor');
  });

  test('route plan model maps legacy step flags when kind is absent', () {
    final legacyFixture = Map<String, dynamic>.from(routeFixture)
      ..['steps'] = (routeFixture['steps'] as List<dynamic>)
          .map(
            (value) => Map<String, dynamic>.from(value as Map<String, dynamic>)
              ..remove('kind')
              ..remove('isWalking'),
          )
          .toList(growable: false);

    final route = RoutePlanModel.fromJson(legacyFixture);

    expect(route.steps.map((step) => step.kind), [
      RouteStepKind.board,
      RouteStepKind.transfer,
      RouteStepKind.continueTrip,
      RouteStepKind.arrive,
    ]);
    expect(route.steps.every((step) => !step.isWalking), isTrue);
  });

  test('route plan model preserves an explicit walking transfer', () {
    final walkingFixture = Map<String, dynamic>.from(routeFixture)
      ..['steps'] = (routeFixture['steps'] as List<dynamic>)
          .map(
            (value) => Map<String, dynamic>.from(value as Map<String, dynamic>),
          )
          .toList(growable: false);
    final steps = walkingFixture['steps'] as List<Map<String, dynamic>>;
    steps[1]['isWalking'] = true;
    steps[1]['text'] = 'Berjalan dari Cikoko menuju Stasiun Cawang';

    final route = RoutePlanModel.fromJson(walkingFixture);

    expect(
      route.steps.singleWhere((step) => step.isWalking).kind,
      RouteStepKind.transfer,
    );
  });
}
